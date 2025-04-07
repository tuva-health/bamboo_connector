    select distinct
      "Patient ID" as patient_id
    , "First Name" as first_name
    , "Last Name" as last_name
    , "Gender" as gender
    , "DOB" as dob
    , "Address 1" as address_1
    , "City" as city
    , "State" as state
    , "Zip" as zip_code
    from {{ source('bamboo_adt','adt_raw_test') }}
