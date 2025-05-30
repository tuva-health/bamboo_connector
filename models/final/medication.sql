{{ config(materialized='table') }}

with raw_table as (

    select

          null as medication_id
        , null as patient_id
        , null as person_id
        , null as encounter_id
        , null as dispensing_date
        , null as prescribing_date
        , null as source_code_type
        , null as source_code
        , null as source_description
        , null as ndc_code
        , null as ndc_description
        , null as rxnorm_code
        , null as rxnorm_description
        , null as atc_code
        , null as atc_description
        , null as route
        , null as strength
        , null as quantity
        , null as quantity_unit
        , null as days_supply
        , null as practitioner_id
        , null as data_source

)

select {% if target.type == 'fabric' %} top 0 {% else %}{% endif %} 
  *
from raw_table
{% if target.type == 'fabric' %} {% else %} limit 0 {% endif %}
