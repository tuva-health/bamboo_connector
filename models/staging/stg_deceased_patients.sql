select distinct
        "Patient ID" as patient_id
    , 1 as death_flag
    , "Status Date" as death_date
from {{ source('bamboo_adt','adt_raw') }}
where "Status" = 'Deceased'
