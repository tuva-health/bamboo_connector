select
    cast(
          MD5(concat_ws('-'
                  , raw_table.attending_provider_npi
                  , raw_table.attending_provider_first_name
                  , raw_table.attending_provider_last_name))
                  as {{ dbt.type_string() }}
        ) as practitioner_id
  , cast(raw_table.attending_provider_npi as {{ dbt.type_string() }} ) as npi
  , cast(raw_table.attending_provider_first_name as {{ dbt.type_string() }} ) as first_name
  , cast(raw_table.attending_provider_last_name as {{ dbt.type_string() }} ) as last_name
  , cast(coalesce(tuva_term_provider.provider_organization_name,
                  tuva_term_provider.parent_organization_name) as {{ dbt.type_string() }} ) as practice_affiliation
  , cast(tuva_term_provider.primary_specialty_description as {{ dbt.type_string() }} ) as specialty
  , cast(NULL as {{ dbt.type_string() }} ) as sub_specialty
  , cast('bamboo' as {{ dbt.type_string() }} ) as data_source
FROM {{ ref('stg_practitioner') }} as raw_table
left join {{ ref('terminology__provider')}} tuva_term_provider
  on attending_provider_npi = tuva_term_provider.npi
