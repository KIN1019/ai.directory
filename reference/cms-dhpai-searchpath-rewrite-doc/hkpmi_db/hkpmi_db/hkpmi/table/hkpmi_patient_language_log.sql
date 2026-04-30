-- hkpmi.hkpmi_patient_language_log definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_patient_language_log;

CREATE TABLE hkpmi.hkpmi_patient_language_log (
	patient_key varchar(16) NOT NULL,
	language_code varchar(10) NULL,
	status varchar(10) NOT NULL,
	source_system varchar(10) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL
);
CREATE UNIQUE INDEX hkpmi_patient_language_log_idx ON hkpmi.hkpmi_patient_language_log USING btree (patient_key, update_datetime);




ALTER TABLE hkpmi.hkpmi_patient_language_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
