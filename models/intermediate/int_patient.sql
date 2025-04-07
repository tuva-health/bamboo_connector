with deduped_patient as (

    select
          patient_id
        , first_name
        , last_name
        , gender
        , dob
        , address_1
        , city
        , state
        , zip_code
    from
        (
         select
              patient_id
            , first_name
            , last_name
            , gender
            , dob
            , address_1
            , city
            , state
            , zip_code
            , row_number() over (partition by patient_id order by patient_id) as rn
         from {{ ref('stg_patient') }}

         )
    where rn = 1

),

combined_table AS (

    select
          cast(deduped_patient.patient_id as {{ dbt.type_string() }} ) as patient_id
        , cast(deduped_patient.first_name as {{ dbt.type_string() }} ) as first_name
        , cast(deduped_patient.last_name as {{ dbt.type_string() }} ) as last_name
        , cast(deduped_patient.gender as {{ dbt.type_string() }} ) as sex
        , cast(NULL as {{ dbt.type_string() }} ) as race
        , {{ try_to_cast_date('deduped_patient.dob', 'MM/DD/YYYY') }} as birth_date
        , {{ try_to_cast_date('death_data.death_date') }} as death_date
        , cast(coalesce(death_data.death_flag, 0) as {{ dbt.type_string() }} ) as death_flag
        , cast(deduped_patient.address_1 as {{ dbt.type_string() }} ) as address
        , cast(deduped_patient.city as {{ dbt.type_string() }} ) as city
        , cast(deduped_patient.state as {{ dbt.type_string() }} ) as state
        , cast(deduped_patient.zip_code as {{ dbt.type_string() }} ) as zip_code
        , cast(NULL as {{ dbt.type_string() }} ) as county
        , cast(NULL as {{ dbt.type_string() }} ) as latitude
        , cast(NULL as {{ dbt.type_string() }} ) as longitude
        , cast('bamboo' as {{ dbt.type_string() }} ) as data_source
    from deduped_patient
    left join {{ ref('stg_deceased_patients') }} as death_data
        on deduped_patient.patient_id = death_data.patient_id

)

select * from combined_table
