-- hkpmi.patient_hospital_data definition

-- Drop table

-- DROP TABLE hkpmi.patient_hospital_data;

CREATE TABLE hkpmi.patient_hospital_data (
	patient_key varchar(16) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	mrn varchar(16) NOT NULL,
	update_by varchar(16) NULL,
	source_system_dtm timestamp(6) NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XAK1patient_hospital_data" ON hkpmi.patient_hospital_data USING btree (hospital_code, mrn);
CREATE UNIQUE INDEX "XPKpatient_hospital_data" ON hkpmi.patient_hospital_data USING btree (patient_key, hospital_code);


ALTER TABLE hkpmi.patient_hospital_data OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
