-- hpi.movement source

CREATE OR REPLACE VIEW hpi.movement with(security_invoker = on)
AS SELECT hospital_code,
    case_no,
    movement_count,
    ward_code,
    bed_no,
    specialty AS specialty_code,
    ward_class,
    movement_type,
    movement_dtm AS movement_datetime,
    treatment_location,
    update_dtm AS system_datetime,
    update_by AS user_id,
    doctor_code
   FROM hpi.cpi_movement m;






ALTER TABLE movement OWNER TO "HPI_SCHEMA_OWNER_ROLE";
