-- hpi.access_changed source

CREATE OR REPLACE VIEW hpi.access_changed with(security_invoker = on)
AS SELECT p.hkid,
    a.original_hkid,
    a.update_dtm AS system_datetime,
    a.access_status,
    a.update_hospital AS hospital_code,
    a.update_by AS user_id
   FROM hpi.cpi_access_changed a,
    hpi.cpi_patient p
  WHERE a.patient_key::text = p.patient_key::text;






ALTER TABLE access_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
