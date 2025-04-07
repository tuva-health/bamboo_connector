{{ config(materialized='table') }}

with raw_table as (

    select

          NULL as observation_id
        , NULL as patient_id
        , NULL as encounter_id
        , NULL as panel_id
        , NULL as observation_date
        , NULL as observation_type
        , NULL as source_code_type
        , NULL as source_code
        , NULL as source_description
        , NULL as normalized_code_type
        , NULL as normalized_code
        , NULL as normalized_description
        , NULL as result
        , NULL as source_units
        , NULL as normalized_units
        , NULL as source_reference_range_low
        , NULL as source_reference_range_high
        , NULL as normalized_reference_range_low
        , NULL as normalized_reference_range_high
        , NULL as data_source

)

select * from raw_table