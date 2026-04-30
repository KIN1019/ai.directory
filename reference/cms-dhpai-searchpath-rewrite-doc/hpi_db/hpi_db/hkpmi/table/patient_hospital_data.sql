-- patient_hospital_data definition

-- Drop table

-- DROP FOREIGN TABLE patient_hospital_data;

CREATE FOREIGN TABLE patient_hospital_data (
	patient_key varchar(16) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	mrn varchar(16) NOT NULL,
	update_by varchar(16) NULL,
	source_system_dtm timestamp NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'patient_hospital_data');

ALTER TABLE patient_hospital_data OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
