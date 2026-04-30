-- cpi_patient_hospital_data definition

-- Drop table

-- DROP TABLE cpi_patient_hospital_data;

CREATE TABLE cpi_patient_hospital_data (
	patient_key varchar(16) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	mrn varchar(16) NULL,
	remark varchar(510) NULL,
	create_by varchar(16) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_patient_hd_mrn_idx ON cpi_patient_hospital_data USING btree (mrn, hospital_code);
CREATE UNIQUE INDEX cpi_patient_hospital_data_idx ON cpi_patient_hospital_data USING btree (patient_key, hospital_code);



ALTER TABLE cpi_patient_hospital_data OWNER TO "HPI_SCHEMA_OWNER_ROLE";
