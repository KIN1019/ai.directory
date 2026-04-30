-- hpi.octopus_record source

CREATE OR REPLACE VIEW hpi.octopus_record with(security_invoker = on)
AS SELECT hospital_code,
    system_datetime,
    workstation_id,
    update_by,
    transaction_data,
    upload_ind,
    file_name,
    upload_datetime
   FROM hpi.cpi_octopus_record;






ALTER TABLE octopus_record OWNER TO "HPI_SCHEMA_OWNER_ROLE";
