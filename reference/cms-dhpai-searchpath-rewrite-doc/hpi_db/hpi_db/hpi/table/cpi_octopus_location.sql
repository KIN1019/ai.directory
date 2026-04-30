-- cpi_octopus_location definition

-- Drop table

-- DROP TABLE cpi_octopus_location;

CREATE TABLE cpi_octopus_location (
	hospital_code varchar(6) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	location_id varchar(16) NOT NULL,
	payment_limit int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_octopus_location_idx ON cpi_octopus_location USING btree (hospital_code, workstation_id);




ALTER TABLE cpi_octopus_location OWNER TO "HPI_SCHEMA_OWNER_ROLE";
