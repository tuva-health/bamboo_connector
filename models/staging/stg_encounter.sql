    select distinct
      "Facility NPI" as facility_npi
    , "Visit ID" as encounter_id
    , "Status" as status
    , "Status Date" as status_date
    , "Setting" as encounter_type
    , "Patient ID" as patient_id
    , "Admitted From" as admitted_from
    , "Discharged Disposition" as discharge_disposition
    , "Attending Provider NPI" as attending_provider_id
    , "Primary Diagnosis Description" primary_diagnosis_description
    , "Primary Diagnosis Code" as primary_diagnosis_code
    from {{ source('bamboo_adt','adt_raw') }}
    where "Patient ID" IN
        ( select patient_id from tuva.core.patient )
