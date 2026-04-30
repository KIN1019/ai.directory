-- cpi_postal_address definition

-- Drop table

-- DROP TABLE cpi_postal_address;

CREATE TABLE cpi_postal_address (
	hospital_code varchar(6) NOT NULL,
	patient_key varchar(16) NOT NULL,
	building varchar(94) NULL,
	room varchar(10) NULL,
	floor varchar(4) NULL,
	block varchar(4) NULL,
	district_code varchar(10) NULL,
	update_hospital varchar(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	source_system varchar(10) NOT NULL
);
CREATE UNIQUE INDEX cpi_postal_add_idx ON cpi_postal_address USING btree (hospital_code, patient_key);




ALTER TABLE cpi_postal_address OWNER TO "HPI_SCHEMA_OWNER_ROLE";
