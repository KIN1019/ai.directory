-- hpi.postal_address source

CREATE OR REPLACE VIEW hpi.postal_address with(security_invoker = on)
AS SELECT a.hospital_code,
    p.hkid,
    a.building,
    a.room,
    a.floor,
    a.block,
    a.district_code,
    a.update_hospital,
    a.update_by,
    a.update_datetime,
    a.source_system
   FROM hpi.cpi_patient p,
    hpi.cpi_postal_address a
  WHERE p.patient_key::text = a.patient_key::text;






ALTER TABLE postal_address OWNER TO "HPI_SCHEMA_OWNER_ROLE";
