    select distinct
      "Facility NPI" as facility_npi
    , "Facility Name" as facility_name
    , "Facility Type" as facility_type
    from {{ source('bamboo_adt','adt_raw_test') }}
    