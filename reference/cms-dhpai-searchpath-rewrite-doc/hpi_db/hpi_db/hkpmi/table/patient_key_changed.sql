-- patient_key_changed definition

-- Drop table

-- DROP FOREIGN TABLE patient_key_changed;

CREATE FOREIGN TABLE patient_key_changed (
	old_hkid varchar(24) NOT NULL,
	system_dtm timestamp(6) NOT NULL,
	old_patient_name varchar(96) NOT NULL,
	old_sex varchar(2) NOT NULL,
	old_dob timestamp(6) NULL,
	new_hkid varchar(24) NULL,
	new_patient_name varchar(96) NOT NULL,
	new_sex varchar(2) NOT NULL,
	new_dob timestamp(6) NULL,
	new_patient_key varchar(16) NULL,
	update_by varchar(16) NULL,
	hospital_code varchar(6) NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'patient_key_changed');

ALTER TABLE patient_key_changed OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";