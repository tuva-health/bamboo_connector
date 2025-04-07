    select distinct
      "Attending Provider NPI" as attending_provider_npi
    , "Attending Provider First Name" as attending_provider_first_name
    , "Attending Provider Last Name" as attending_provider_last_name
    from {{ source('bamboo_adt','adt_raw_test') }}
    