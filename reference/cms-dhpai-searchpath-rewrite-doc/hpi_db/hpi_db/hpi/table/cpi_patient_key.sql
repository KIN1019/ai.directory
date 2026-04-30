-- cpi_patient_key definition

-- Drop table

-- DROP TABLE cpi_patient_key;

CREATE TABLE cpi_patient_key (
	hospital_code varchar(6) NOT NULL,
	effective_dtm timestamp(6) NOT NULL,
	patient_key int4 NOT NULL,
	patient_key_from int4 NOT NULL,
	patient_key_to int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_patient_key_idx ON cpi_patient_key USING btree (hospital_code, effective_dtm);




ALTER TABLE cpi_patient_key OWNER TO "HPI_SCHEMA_OWNER_ROLE";
