with raw_table as (
    select distinct
      patient_id
    , encounter_id
    , recorded_date
    , primary_diagnosis_code
    , primary_diagnosis_description
    , subsequent_diagnosis_codes
    from {{ ref('stg_condition') }}
),

all_codes as (

    select
          patient_id
        , primary_diagnosis_code as source_code
        , primary_diagnosis_description as source_description
        , recorded_date
        , encounter_id
        , 1 as condition_rank

    from raw_table

    union all

    select
          y.patient_id
        , t.value as source_code
        , null as source_description
        , y.recorded_date
        , y.encounter_id
        , null as condition_rank
    from raw_table as y,
        lateral as split_to_table(y.subsequent_diagnosis_codes, ',') t

),

unique_codes as (

    select distinct
          patient_id
        , source_code
        , source_description
        , recorded_date
        , encounter_id
        , condition_rank
    from all_codes
    where source_code is not null
    and source_code != ''

),

combined_table as (

    select
        cast(
            md5(concat_ws('-'
                          , patient_id
                          , encounter_id
                          , source_code
                          , coalesce(source_description, '')
                          , recorded_date
                          , coalesce(condition_rank, 0)))
                            as {{ dbt.type_string() }}
            ) as condition_id
      , cast(patient_id as {{ dbt.type_string() }}) as patient_id
      , cast(patient_id as {{ dbt.type_string() }}) as person_id
      , cast(encounter_id as {{ dbt.type_string() }}) as encounter_id
      , cast(null as {{ dbt.type_string() }}) as claim_id
      , {{ try_to_cast_date('recorded_date', 'MM/DD/YYYY') }} as recorded_date
      , cast(null as date) as onset_date
      , cast(null as date) as resolved_date
      , cast(null as {{ dbt.type_string() }}) as status
      , cast(null as {{ dbt.type_string() }}) as condition_type
      , cast('icd-10-cm' as {{ dbt.type_string() }}) as source_code_type
      , cast(source_code as {{ dbt.type_string() }}) as source_code
      , cast(source_description as {{ dbt.type_string() }}) as source_description
      , cast('icd-10-cm' as {{ dbt.type_string() }}) as normalized_code_type
      , cast(tuva_term_icd_10_cm.icd_10_cm as {{ dbt.type_string() }}) as normalized_code
      , cast(tuva_term_icd_10_cm.long_description as {{ dbt.type_string() }}) as normalized_description
      , cast(condition_rank as {{ dbt.type_string() }}) as condition_rank
      , cast(null as {{ dbt.type_string() }}) as present_on_admit_code
      , cast(null as {{ dbt.type_string() }}) as present_on_admit_description
      , cast('bamboo' as {{ dbt.type_string() }}) as data_source
    from unique_codes
        left outer join {{ ref('terminology__icd_10_cm') }} as tuva_term_icd_10_cm
            on tuva_term_icd_10_cm.icd_10_cm = source_code

)

select * from combined_table
