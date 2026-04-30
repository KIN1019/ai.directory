-- cpi_octopus_record definition

-- Drop table

-- DROP TABLE cpi_octopus_record;

CREATE TABLE cpi_octopus_record (
	hospital_code varchar(6) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	update_by varchar(24) NOT NULL,
	transaction_data bytea NULL,
	upload_ind varchar(2) NULL,
	file_name varchar(96) NULL,
	upload_datetime timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_octopus_record_idx ON cpi_octopus_record USING btree (hospital_code, system_datetime);




ALTER TABLE cpi_octopus_record OWNER TO "HPI_SCHEMA_OWNER_ROLE";
