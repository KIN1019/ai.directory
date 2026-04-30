-- cpi_patient_hosp_mrn_changed definition

-- Drop table

-- DROP TABLE cpi_patient_hosp_mrn_changed;

CREATE TABLE cpi_patient_hosp_mrn_changed (
	patient_key varchar(16) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	mrn varchar(16) NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_patient_hmrn_changed_idx ON cpi_patient_hosp_mrn_changed USING btree (patient_key, hospital_code, update_dtm);



ALTER TABLE cpi_patient_hosp_mrn_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
