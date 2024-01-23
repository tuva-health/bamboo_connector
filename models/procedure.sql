{{ config(materialized='table') }}

with raw_table as (

    select

          NULL as procedure_id
        , NULL as patient_id
        , NULL as encounter_id
        , NULL as claim_id
        , NULL as procedure_date
        , NULL as source_code_type
        , NULL as source_code
        , NULL as source_description
        , NULL as normalized_code_type
        , NULL as normalized_code
        , NULL as normalized_description
        , NULL as modifier_1
        , NULL as modifier_2
        , NULL as modifier_3
        , NULL as modifier_4
        , NULL as modifier_5
        , NULL as practitioner_id
        , NULL as data_source

)

select * from raw_table