select distinct
    "Patient ID" as patient_id
  , "Visit ID" as encounter_id
  , "Status Date" as recorded_date
  , "Primary Diagnosis Code" as primary_diagnosis_code
  , "Primary Diagnosis Description" as primary_diagnosis_description
  , "Subsequent Diagnosis Codes" as subsequent_diagnosis_codes
from {{ source('bamboo_adt','adt_raw') }}
