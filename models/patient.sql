with raw_table AS (

    select distinct
      "Patient ID" as patient_id
    , "First Name" as first_name
    , "Last Name" as last_name
    , "Gender" as gender
    , "DOB" as dob
    , "Address 1" as address_1
    , "City" as city
    , "State" as state
    , "Zip" as zip_code
    from {{ source('bamboo_adt','adt_raw') }}
    where "Patient ID" in
        ( select patient_id from tuva.core.patient )

),

deduped_patient as (

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
         from raw_table

         )
    where rn = 1

),

death_data as (

    select distinct
          "Patient ID" as patient_id
        , 1 as death_flag
        , "Status Date" as death_date
    from {{ source('bamboo_adt','adt_raw_test') }} /** update this to adt_raw later **/
    where "Status" = 'Deceased'

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
    left join death_data
        on deduped_patient.patient_id = death_data.patient_id

)

select * from combined_table