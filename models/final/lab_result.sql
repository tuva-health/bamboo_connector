{{ config(materialized='table') }}

with raw_table as (

    select 

      NULL as lab_result_id
    , NULL as patient_id
    , NULL as encounter_id
    , NULL as accession_number
    , NULL as source_code_type
    , NULL as source_code
    , NULL as source_description
    , NULL as source_component
    , NULL as normalized_code_type
    , NULL as normalized_code
    , NULL as normalized_description
    , NULL as normalized_component
    , NULL as status
    , NULL as result
    , NULL as result_date
    , NULL as collection_date
    , NULL as source_units
    , NULL as normalized_units
    , NULL as source_reference_range_low
    , NULL as source_reference_range_high
    , NULL as normalized_reference_range_low
    , NULL as normalized_reference_range_high
    , NULL as source_abnormal_flag
    , NULL as normalized_abnormal_flag
    , NULL as specimen
    , NULL as ordering_practitioner_id
    , NULL as data_source

)

select * from raw_table