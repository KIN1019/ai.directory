-- hpi.new_born source

CREATE OR REPLACE VIEW hpi.new_born with(security_invoker = on)
AS SELECT p1.hkid AS mother_hkid,
    p2.hkid AS new_born_hkid,
    n.hospital_code,
    n.mother_case_no,
    n.birth_order,
    n.pregnancy_number,
    n.create_by,
    n.create_datetime,
    n.update_by,
    n.update_datetime
   FROM hpi.cpi_new_born n,
    hpi.cpi_patient p1,
    hpi.cpi_patient p2
  WHERE n.mother_patient_key::text = p1.patient_key::text AND n.new_born_patient_key::text = p2.patient_key::text;






ALTER TABLE new_born OWNER TO "HPI_SCHEMA_OWNER_ROLE";
