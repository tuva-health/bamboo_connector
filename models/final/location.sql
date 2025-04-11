with combined_table as (

    select
          cast(
               MD5(concat_ws('-'
                        , facility_npi
                        , coalesce(facility_name, '')))
                        as {{ dbt.type_string() }}
               ) as location_id
        , cast(facility_npi as {{ dbt.type_string() }} ) as npi
        , cast(facility_name as {{ dbt.type_string() }} ) as name
        , cast(facility_type as {{ dbt.type_string() }} ) as facility_type
        , cast(tuva_term_provider.parent_organization_name as {{ dbt.type_string() }} ) as parent_organization
        , cast(tuva_term_provider.practice_address_line_1 as {{ dbt.type_string() }} ) as address
        , cast(tuva_term_provider.practice_city as {{ dbt.type_string() }} ) as city
        , cast(tuva_term_provider.practice_state as {{ dbt.type_string() }} ) as state
        , cast(tuva_term_provider.practice_zip_code as {{ dbt.type_string() }} ) as zip_code
        , cast(NULL as {{ dbt.type_string() }} ) as latitude
        , cast(NULL as {{ dbt.type_string() }} ) as longitude
        , cast('bamboo' as {{ dbt.type_string() }} ) as data_source
    from {{ ref('stg_location') }}
    left join {{ ref('terminology__provider')}} tuva_term_provider
      on facility_npi = tuva_term_provider.npi
    where facility_name is not NULL
    and facility_name != ''

)

/*
In some cases, we need to break ties at the same location where there are
multiple facility types per location. Here we assume that any facility
type that is not "Unknown" is higher value to us than an "Unknown" status
*/
select * from combined_table
qualify row_number() over (
  partition by location_id 
  order by 
    case when facility_type = 'Unknown' then 0 
    else 1 end
  desc
) = 1
