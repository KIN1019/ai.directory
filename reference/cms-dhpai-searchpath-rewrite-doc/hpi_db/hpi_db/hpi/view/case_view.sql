-- hpi.case_view source

CREATE OR REPLACE VIEW hpi.case_view with(security_invoker = on)
AS SELECT c.hospital_code,
    c.case_no,
    c.admission_dtm AS admission_datetime,
    c.source_indicator,
    c.source_code,
    p.hkid,
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
    c.update_by AS user_id,
    c.row_update_datetime,
    c.patient_key AS t_prk,
    c.mrt_indicator
   FROM hpi.cpi_case c,
    hpi.cpi_patient p,
    hpi.cpi_active_case a
  WHERE c.patient_key::text = p.patient_key::text AND c.status_code::bpchar <> 'CC'::bpchar AND c.hospital_code::text = a.hospital_code::text AND c.case_no::text = a.case_no::text;






ALTER TABLE case_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
