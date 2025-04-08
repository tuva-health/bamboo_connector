{{ config(materialized='table') }}

with raw_table as (

    select

          null as procedure_id
        , null as patient_id
        , null as person_id
        , null as encounter_id
        , null as claim_id
        , null as procedure_date
        , null as source_code_type
        , null as source_code
        , null as source_description
        , null as normalized_code_type
        , null as normalized_code
        , null as normalized_description
        , null as modifier_1
        , null as modifier_2
        , null as modifier_3
        , null as modifier_4
        , null as modifier_5
        , null as practitioner_id
        , null as data_source

)

select {% if target.type == 'fabric' %} top 0 {% else %}{% endif %} 
  * 
from raw_table
{% if target.type == 'fabric' %} {% else %} limit 0 {% endif %}