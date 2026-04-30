-- hkpmi.bcf_log definition

-- Drop table

-- DROP TABLE hkpmi.bcf_log;

CREATE TABLE hkpmi.bcf_log (
	hospital_code varchar(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	system_datetime timestamp NOT NULL,
	body_category varchar(2) NOT NULL,
	mortuary_id int4 NOT NULL,
	update_by varchar(24) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	source_system varchar(10) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	lof_hkid varchar(24) NULL
);
CREATE UNIQUE INDEX bcf_log_idx ON hkpmi.bcf_log USING btree (hospital_code, system_datetime);
CREATE INDEX bcf_log_idx2 ON hkpmi.bcf_log USING btree (hkid, system_datetime);




ALTER TABLE hkpmi.bcf_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
