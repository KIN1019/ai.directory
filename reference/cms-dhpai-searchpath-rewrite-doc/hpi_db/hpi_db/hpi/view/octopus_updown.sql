-- hpi.octopus_updown source

CREATE OR REPLACE VIEW hpi.octopus_updown with(security_invoker = on)
AS SELECT hospital_code,
    workstation_id,
    transaction_type,
    system_datetime,
    update_by,
    transaction_status,
    file_size,
    file_name
   FROM hpi.cpi_octopus_updown;






ALTER TABLE octopus_updown OWNER TO "HPI_SCHEMA_OWNER_ROLE";
