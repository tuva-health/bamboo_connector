    select distinct
      "Facility NPI" as facility_npi
    , "Facility Name" as facility_name
    , "Visit ID" as encounter_id
    , "Status" as status
    , "Status Date" as status_date
    , "Setting" as encounter_type
    , "Patient ID" as patient_id
    , "Admitted From" as admitted_from
    , "Discharged Disposition" as discharge_disposition
    , "Attending Provider NPI" as attending_provider_id
    , "Attending Provider First Name" as attending_provider_first_name
    , "Attending Provider Last Name" as attending_provider_last_name
    , "Primary Diagnosis Description" primary_diagnosis_description
    , "Primary Diagnosis Code" as primary_diagnosis_code
    from {{ source('bamboo_adt','adt_raw') }}
