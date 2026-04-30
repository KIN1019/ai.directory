-- hpi.case_hosp_view source

CREATE OR REPLACE VIEW hpi.case_hosp_view with(security_invoker = on)
AS SELECT c.hospital_code,
    c.case_no,
    c.admission_dtm AS admission_datetime,
    c.source_indicator,
    c.source_code,
    p.hkid,
    c.patient_type AS pay_code,
    c.discharge_code,
    c.discharge_dtm AS discharge_datetime,
    c.destination_code,
    c.case_type,
    c.patient_key AS t_prk
   FROM hpi.cpi_case c,
    hpi.cpi_patient p
  WHERE c.patient_key::text = p.patient_key::text AND c.status_code::bpchar <> 'CC'::bpchar;






ALTER TABLE case_hosp_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
