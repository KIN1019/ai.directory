-- hpi.cubicle_view_epr source

CREATE OR REPLACE VIEW hpi.cubicle_view_epr with(security_invoker = on)
AS SELECT hospital_code,
    ward_code,
    cubicle_no,
    effective_date,
    active_status,
    description,
    isolation_facilities,
    project_category,
    care_category,
    sex,
    treatment_location,
    update_datetime,
    update_by,
    source_system,
    patient_category,
    cubicle_service,
    official_bed,
    day_bed
   FROM hpi.cubicle;






ALTER TABLE cubicle_view_epr OWNER TO "HPI_SCHEMA_OWNER_ROLE";
