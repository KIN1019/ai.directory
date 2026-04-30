-- hpi.used_unhkid source

CREATE OR REPLACE VIEW hpi.used_unhkid with(security_invoker = on)
AS SELECT hkid,
    create_dtm,
    block_type,
    request_hosp,
    request_by,
    filler
   FROM hpi.cpi_used_unhkid;






ALTER TABLE used_unhkid OWNER TO "HPI_SCHEMA_OWNER_ROLE";
