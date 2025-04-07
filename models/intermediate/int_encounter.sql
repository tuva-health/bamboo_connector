with raw_table as (
    select * from {{ ref('stg_encounter') }}
),

collapsed_encounters as (

    select
         encounter_id
       , patient_id
       , case
            when SUM(case when encounter_type = 'Inpatient' then 1 else 0 end) > 0 then 'Inpatient'
            when SUM(case when encounter_type = 'Emergency' then 1 else 0 end) > 0 then 'Emergency'
            when SUM(case when encounter_type = 'Observation' then 1 else 0 end) > 0 then 'Emergency'
            when SUM(case when encounter_type = 'Skilled' then 1 else 0 end) > 0 then 'Skilled'
            else 'Unknown'
        end as encounter_type
       , MIN(case when status in ('Admitted', 'Transferred', 'Presented') then status_date end) as encounter_start_date
       , MAX(case when status in ('Closed', 'Deceased', 'Discharged') then status_date end) as encounter_end_date
       , DATEDIFF(day, encounter_start_date::DATE, encounter_end_date::DATE) as length_of_stay
    from
       {{ ref('stg_encounter') }}
    GROUP BY
       encounter_id, patient_id

),

admit_data as (
    select
          encounter_id
        , admit_source_code
        , admit_source_description
        , attending_provider_id
        , NULL as admit_type_code
        , NULL as admit_type_description
    from (
        select
              collapsed_encounters.encounter_id
            , case
                when raw_table.admitted_from = 'Home' then 1
                when raw_table.admitted_from = 'Physician Office' then 1
                when raw_table.admitted_from = 'Hospital - Emergency' then 7
                else 9
              end as admit_source_code
            , raw_table.admitted_from as admit_source_description
            , raw_table.attending_provider_id
            , ROW_NUMBER() over (
                partition by collapsed_encounters.encounter_id
                order by
                    case raw_table.status
                        when 'Admitted' then 1
                        when 'Transferred' then 2
                        when 'Presented' then 3
                        else 4
                    end
            ) as rn
        from collapsed_encounters
        left join raw_table
        on raw_table.encounter_id = collapsed_encounters.encounter_id
        and raw_table.status_date = collapsed_encounters.encounter_start_date
        and raw_table.encounter_type = collapsed_encounters.encounter_type
        where raw_table.status in ('Admitted', 'Transferred', 'Presented')
    ) as ranked_data
    where rn = 1
),

discharge_data as (
    select
          encounter_id
        , discharge_disposition_code
        , discharge_disposition_description
    from (
        select
              collapsed_encounters.encounter_id
            , case
                when discharge_disposition = 'Home' then '01'
                when discharge_disposition = 'Long-Term Acute Care Hospital' then '63'
                when discharge_disposition = 'Assisted Living and Home Health' then '04'
                when discharge_disposition = 'Against Medical Advice' then '07'
                when discharge_disposition = 'Skilled Nursing Facility' then '03'
                when discharge_disposition = 'Deceased' then '20'
                when discharge_disposition = 'Hospital' then '02'
                when discharge_disposition = 'Inpatient Rehabilitation Facility' then '62'
                when discharge_disposition = 'Home - with Home Health Services' then '06'
                else NULL
              end as discharge_disposition_code
            , raw_table.discharge_disposition as discharge_disposition_description
            , ROW_NUMBER() over (
                partition by collapsed_encounters.encounter_id
                order by
                    case raw_table.status
                        when 'Discharged' then 1
                        when 'Deceased' then 2
                        when 'Closed' then 3
                        else 4
                    end
            ) as rn
        from collapsed_encounters
        left join raw_table
        on raw_table.encounter_id = collapsed_encounters.encounter_id
        and raw_table.status_date = collapsed_encounters.encounter_end_date
        where raw_table.status IN ('Closed', 'Deceased', 'Discharged')
    ) as ranked_data
    where rn = 1
),

diagnosis_data as (

    select
          encounter_id
        , 'icd-10-cm' as primary_diagnosis_code_type
        , primary_diagnosis_code
        , primary_diagnosis_description as primary_diagnosis_description
    from (
        select
              encounter_id
            , primary_diagnosis_code
            , primary_diagnosis_description
            , row_number() over (partition by encounter_id order by
                                 case status when 'Discharged' then 1
                                               when 'Admitted' then 2
                                               when 'Presented' then 3
                                               else 4 end
                                               , primary_diagnosis_code is not null desc
                                               ) as ranked_diagnosis
        from raw_table
    )
    where ranked_diagnosis = 1

),

facility_data as (

    select distinct
          encounter_id
        , facility_npi
    from raw_table
),

diagnosis_data_mapped as (

    select
          diagnosis_data.encounter_id
        , diagnosis_data.primary_diagnosis_code_type
        , tuva_term_icd_10_cm.icd_10_cm as primary_diagnosis_code
        , tuva_term_icd_10_cm.description as primary_diagnosis_description
    from diagnosis_data
    left join {{ ref('terminology__icd_10_cm')}} tuva_term_icd_10_cm
        on tuva_term_icd_10_cm.icd_10_cm = diagnosis_data.primary_diagnosis_code

),

combined_table as (

    select
          cast(collapsed_encounters.encounter_id as {{ dbt.type_string() }} ) as encounter_id
        , cast(collapsed_encounters.patient_id as {{ dbt.type_string() }} ) as patient_id
        , cast (
            case
            when collapsed_encounters.encounter_type = 'Inpatient' then 'acute inpatient'
            when collapsed_encounters.encounter_type = 'Emergency' then 'emergency department'
            when collapsed_encounters.encounter_type = 'Skilled' then 'skilled nursing facility'
            else 'other'
          end as {{ dbt.type_string() }} ) as encounter_type
        , {{ try_to_cast_date('collapsed_encounters.encounter_start_date', 'MM/DD/YYYY') }} as encounter_start_date
        , {{ try_to_cast_date('collapsed_encounters.encounter_end_date', 'MM/DD/YYYY') }} as encounter_end_date
        , cast(collapsed_encounters.length_of_stay as {{ dbt.type_string() }} ) as length_of_stay
        , cast(coalesce(admit_data.admit_source_code, 9) as {{ dbt.type_string() }} ) as admit_source_code
        , cast(admit_data.admit_source_description as {{ dbt.type_string() }} ) as admit_source_description
        , cast(admit_data.admit_type_code as {{ dbt.type_string() }} ) as admit_type_code
        , cast(admit_data.admit_type_description as {{ dbt.type_string() }} ) as admit_type_description
        , cast(discharge_data.discharge_disposition_code as {{ dbt.type_string() }} ) as discharge_disposition_code
        , cast(discharge_data.discharge_disposition_description as {{ dbt.type_string() }} ) as discharge_disposition_description
        , cast(admit_data.attending_provider_id as {{ dbt.type_string() }} ) as attending_provider_id
        , cast(facility_data.facility_npi as {{ dbt.type_string() }} ) as facility_npi
        , cast(diagnosis_data_mapped.primary_diagnosis_code_type as {{ dbt.type_string() }} ) as primary_diagnosis_code_type
        , cast(diagnosis_data_mapped.primary_diagnosis_code as {{ dbt.type_string() }} ) as primary_diagnosis_code
        , cast(diagnosis_data_mapped.primary_diagnosis_description as {{ dbt.type_string() }} ) as primary_diagnosis_description
        , cast(NULL as {{ dbt.type_string() }} ) as ms_drg_code
        , cast(NULL as {{ dbt.type_string() }} ) as ms_drg_description
        , cast(NULL as {{ dbt.type_string() }} ) as apr_drg_code
        , cast(NULL as {{ dbt.type_string() }} ) as apr_drg_description
        , cast(NULL as {{ dbt.type_string() }} ) as paid_amount
        , cast(NULL as {{ dbt.type_string() }} ) as allowed_amount
        , cast(NULL as {{ dbt.type_string() }} ) as charge_amount
        , cast('bamboo' as {{ dbt.type_string() }} ) as data_source
    from collapsed_encounters
    left join admit_data
        on collapsed_encounters.encounter_id = admit_data.encounter_id
    left join discharge_data
        on collapsed_encounters.encounter_id = discharge_data.encounter_id
    left join diagnosis_data_mapped
        on collapsed_encounters.encounter_id = diagnosis_data_mapped.encounter_id
    left join facility_data
        on collapsed_encounters.encounter_id = facility_data.encounter_id

)

select * from combined_table
