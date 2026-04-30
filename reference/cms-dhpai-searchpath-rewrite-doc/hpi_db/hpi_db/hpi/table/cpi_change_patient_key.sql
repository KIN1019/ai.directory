-- cpi_change_patient_key definition

-- Drop table

-- DROP TABLE cpi_change_patient_key;

CREATE TABLE cpi_change_patient_key (
	hospital_code varchar(6) NOT NULL,
	transaction_type varchar(6) NOT NULL,
	transaction_datetime timestamp(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	cpi_patient_key varchar(16) NULL,
	hkpmi_patient_key varchar(16) NULL,
	source_system varchar(10) NULL,
	system_datetime timestamp(6) NOT NULL,
	action_code varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_change_patient_key_idx ON cpi_change_patient_key USING btree (hospital_code, transaction_datetime, transaction_type);
CREATE INDEX cpi_change_patient_key_idx2 ON cpi_change_patient_key USING btree (cpi_patient_key);




ALTER TABLE cpi_change_patient_key OWNER TO "HPI_SCHEMA_OWNER_ROLE";
