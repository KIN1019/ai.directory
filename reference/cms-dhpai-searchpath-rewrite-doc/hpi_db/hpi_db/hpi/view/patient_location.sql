-- hpi.patient_location source

CREATE OR REPLACE VIEW hpi.patient_location with(security_invoker = on)
AS SELECT pl.hospital_code,
    pl.case_no,
    p.hkid,
    pl.patient_name AS name,
    pl.name_soundex,
    pl.name_phonetic,
    pl.sex,
    pl.dob,
    pl.chinese_name,
    pl.phone1,
    pl.phone2,
    pl.mobile_phone,
    pl.row_update_datetime
   FROM hpi.cpi_patient p,
    hpi.cpi_patient_location pl
  WHERE p.patient_key::text = pl.patient_key::text;






ALTER TABLE patient_location OWNER TO "HPI_SCHEMA_OWNER_ROLE";
