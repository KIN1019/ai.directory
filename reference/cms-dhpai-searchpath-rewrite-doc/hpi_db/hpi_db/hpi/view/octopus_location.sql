-- hpi.octopus_location source

CREATE OR REPLACE VIEW hpi.octopus_location with(security_invoker = on)
AS SELECT hospital_code,
    workstation_id,
    location_id
   FROM hpi.cpi_octopus_location;






ALTER TABLE octopus_location OWNER TO "HPI_SCHEMA_OWNER_ROLE";
