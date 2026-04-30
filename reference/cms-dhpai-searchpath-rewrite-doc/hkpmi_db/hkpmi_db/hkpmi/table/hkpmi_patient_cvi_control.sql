-- hkpmi_patient_cvi_control definition

-- Drop table

-- DROP TABLE hkpmi_patient_cvi_control;

CREATE TABLE hkpmi_patient_cvi_control (
	cvi_key varchar(60) NOT NULL,
	cvi_value varchar(200) NOT NULL,
	cvi_key_description varchar(510) NULL,
	update_datetime timestamp NULL
);

CREATE UNIQUE INDEX hkpmi_patient_cvi_control_idx ON hkpmi_patient_cvi_control USING btree (cvi_key);

ALTER TABLE hkpmi_patient_cvi_control OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
