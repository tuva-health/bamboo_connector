select distinct
    "Patient ID" as patient_id
  , "Visit ID" as encounter_id
  , "Status Date" as recorded_date
  , "Primary Diagnosis Code"
  , "Primary Diagnosis Description"
  , "Subsequent Diagnosis Codes"
from {{ source('bamboo_adt','adt_raw') }}
