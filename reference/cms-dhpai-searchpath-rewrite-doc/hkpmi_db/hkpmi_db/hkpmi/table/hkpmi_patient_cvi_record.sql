-- hkpmi_patient_cvi_record definition

-- Drop table

-- DROP TABLE hkpmi_patient_cvi_record;

CREATE TABLE hkpmi_patient_cvi_record (
	source_system varchar(10) NOT NULL,
	patient_key varchar(16) NOT NULL,
	vac_record_key varchar(60) NOT NULL,
	status varchar(40) NOT NULL,
	last_check_datetime timestamp NOT NULL,
	create_datetime timestamp NOT NULL,
	update_datetime timestamp NOT NULL
);

CREATE UNIQUE INDEX hkpmi_patient_cvi_record_idx ON hkpmi_patient_cvi_record USING btree (patient_key, vac_record_key);
CREATE INDEX hkpmi_patient_cvi_record_pk_idx ON hkpmi_patient_cvi_record USING btree (patient_key);

ALTER TABLE hkpmi_patient_cvi_record OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
