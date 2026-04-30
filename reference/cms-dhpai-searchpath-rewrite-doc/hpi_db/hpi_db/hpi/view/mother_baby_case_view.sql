-- hpi.mother_baby_case_view source

CREATE OR REPLACE VIEW hpi.mother_baby_case_view with(security_invoker = on)
AS SELECT p1.hkid AS mother_hkid,
    p2.hkid AS baby_hkid,
    m.mother_hospital_code,
    m.mother_case_no,
    m.baby_hospital_code,
    m.baby_case_no,
    m.birth_order,
    m.pregnancy_number,
    m.birth_place,
    m.birth_location,
    m.create_by,
    m.create_datetime,
    m.update_by,
    m.update_datetime,
    m.active_status
   FROM hpi.mother_baby_case m,
    hpi.cpi_patient p1,
    hpi.cpi_patient p2,
    hpi.cpi_case c1,
    hpi.cpi_case c2
  WHERE c1.patient_key::text = p1.patient_key::text AND c2.patient_key::text = p2.patient_key::text AND m.mother_case_no::text = c1.case_no::text AND m.mother_hospital_code::text = c1.hospital_code::text AND m.baby_case_no::text = c2.case_no::text AND m.baby_hospital_code::text = c2.hospital_code::text;






ALTER TABLE mother_baby_case_view OWNER TO "HPI_SCHEMA_OWNER_ROLE";
