-- hpi.specialty source

CREATE OR REPLACE VIEW hpi.specialty with(security_invoker = on)
AS SELECT hospital_code,
    specialty_code,
    description,
    treatment_location,
    imis_code,
    from_age,
    to_age,
    sex,
    security_count,
    active_status,
    effective_date,
    user_define,
    treatment_flag
   FROM hpi.ip_specialty s;






ALTER TABLE specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
