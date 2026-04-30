-- hpi.adt_case2 source

CREATE OR REPLACE VIEW hpi.adt_case2 with(security_invoker = on)
AS SELECT c.hospital_code,
    c.case_no,
    c.admission_dtm AS admission_datetime,
    c.source_indicator,
    c.source_code,
    c.patient_key AS t_prk,
    c.district_code,
    c.patient_type AS pay_code,
    c.discharge_code,
    c.discharge_dtm AS discharge_datetime,
    c.destination_code,
    c.case_type,
    a.active_indicator,
    c.movement_count,
    0 AS security_count,
    c.access_code,
    c.update_dtm AS system_datetime,
    c.update_by AS "user_ID",
    c.row_update_datetime,
    c.mrt_indicator
   FROM hpi.cpi_case c,
    hpi.cpi_active_case a
  WHERE c.status_code::text <> 'CC'::text AND c.hospital_code::text = a.hospital_code::text AND c.case_no::text = a.case_no::text;




ALTER TABLE adt_case2 OWNER TO "HPI_SCHEMA_OWNER_ROLE";
