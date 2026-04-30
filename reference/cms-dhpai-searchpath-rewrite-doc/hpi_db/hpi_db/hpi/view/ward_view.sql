-- hpi.ward_view source

-- Sybase counterpart is "Ward"

CREATE OR REPLACE VIEW hpi.ward_view with(security_invoker = on)
AS SELECT hospital_code,
    ward_code,
    description,
    treatment_location,
    location,
    active_status,
    effective_date,
    user_define,
    care_category,
    default_specialty,
    wristband_no,
    isolation_type
   FROM hpi.ward w;




ALTER TABLE ward_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
