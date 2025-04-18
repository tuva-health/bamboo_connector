{{ config(materialized='table') }}

with raw_table as (

    select

          null as observation_id
        , null as patient_id
        , null as person_id
        , null as encounter_id
        , null as panel_id
        , null as observation_date
        , null as observation_type
        , null as source_code_type
        , null as source_code
        , null as source_description
        , null as normalized_code_type
        , null as normalized_code
        , null as normalized_description
        , null as result
        , null as source_units
        , null as normalized_units
        , null as source_reference_range_low
        , null as source_reference_range_high
        , null as normalized_reference_range_low
        , null as normalized_reference_range_high
        , null as data_source

)

select {% if target.type == 'fabric' %} top 0 {% else %}{% endif %}
  *
from raw_table
{% if target.type == 'fabric' %} {% else %} limit 0 {% endif %}
