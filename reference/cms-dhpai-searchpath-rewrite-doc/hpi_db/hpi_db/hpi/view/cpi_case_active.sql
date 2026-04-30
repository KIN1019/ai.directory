-- hpi.cpi_case_active source

CREATE OR REPLACE VIEW hpi.cpi_case_active with(security_invoker = on)
AS SELECT c.hospital_code,
    c.case_no,
    c.patient_key,
    c.case_type,
    c.admission_dtm,
    c.source_indicator,
    c.source_code,
    c.patient_type,
    c.discharge_code,
    c.discharge_dtm,
    c.destination_code,
    c.last_specialty,
    c.last_sub_specialty,
    c.last_ward_code,
    c.last_ward_class,
    c.last_bed_no,
    c.pp_code,
    c.access_code,
    c.status_code,
    c.create_by,
    c.create_dtm,
    c.update_by,
    c.update_dtm,
    c.movement_count,
    c.district_code,
    c.mrt_indicator
   FROM hpi.cpi_case c,
    hpi.cpi_ward_list w
  WHERE w.case_no::text = c.case_no::text AND w.hospital_code::text = c.hospital_code::text;

ALTER TABLE cpi_case_active OWNER TO "HPI_SCHEMA_OWNER_ROLE";
