-- hkpmi.non_ha_patient_status definition

-- Drop table

-- DROP TABLE hkpmi.non_ha_patient_status;

CREATE TABLE hkpmi.non_ha_patient_status (
	patient_key varchar(16) NOT NULL,
	status varchar(40) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	source_system varchar(10) NOT NULL
);
CREATE UNIQUE INDEX hkpmi_set_nonha_pat_status_idx ON hkpmi.non_ha_patient_status USING btree (patient_key);
--CREATE INDEX nonha_pat_status_status_idx ON hkpmi.non_ha_patient_status USING btree (status);




ALTER TABLE hkpmi.non_ha_patient_status OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
