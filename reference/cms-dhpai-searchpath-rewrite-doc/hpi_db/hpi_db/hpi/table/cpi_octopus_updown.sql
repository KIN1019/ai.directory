-- cpi_octopus_updown definition

-- Drop table

-- DROP TABLE cpi_octopus_updown;

CREATE TABLE cpi_octopus_updown (
	hospital_code varchar(6) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	transaction_type varchar(2) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	transaction_status varchar(2) NOT NULL,
	file_size int4 NULL,
	file_name varchar(510) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_octopus_updown_dtm_idx ON cpi_octopus_updown USING btree (hospital_code, system_datetime, workstation_id, transaction_type);
CREATE UNIQUE INDEX cpi_octopus_updown_idx ON cpi_octopus_updown USING btree (hospital_code, workstation_id, transaction_type, system_datetime);




ALTER TABLE cpi_octopus_updown OWNER TO "HPI_SCHEMA_OWNER_ROLE";
