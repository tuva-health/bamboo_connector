{{ config(materialized='table') }}

with raw_table as (

    select 

          NULL as medication_id
        , NULL as patient_id
        , NULL as encounter_id
        , NULL as dispensing_date
        , NULL as prescribing_date
        , NULL as source_code_type
        , NULL as source_code
        , NULL as source_description
        , NULL as ndc_code
        , NULL as ndc_description
        , NULL as rxnorm_code
        , NULL as rxnorm_description
        , NULL as atc_code
        , NULL as atc_description
        , NULL as route
        , NULL as strength
        , NULL as quantity
        , NULL as quantity_unit
        , NULL as days_supply
        , NULL as practitioner_id
        , NULL as data_source

)

select * from raw_table