-- hkpmi_patient_cvi_message definition

-- Drop table

-- DROP TABLE hkpmi_patient_cvi_message;

CREATE TABLE hkpmi_patient_cvi_message (
	msg_id varchar(20) NOT NULL,
	msg_content varchar(510) NOT NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX hkpmi_patient_cvi_message_idx ON hkpmi_patient_cvi_message USING btree (msg_id);

ALTER TABLE hkpmi_patient_cvi_message OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
