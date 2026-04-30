-- hkpmi.death_reg_log definition

-- Drop table

-- DROP TABLE hkpmi.death_reg_log;

CREATE TABLE hkpmi.death_reg_log (
	system_datetime timestamp(6) NOT NULL,
	record_date varchar(24) NULL,
	hkid varchar(18) NULL,
	death_indicator varchar(8) NULL,
	death_date varchar(24) NULL,
	death_diagnosis varchar(8) NULL,
	death_external_cause varchar(8) NULL,
	patient_name varchar(160) NULL,
	ccc varchar(48) NULL,
	sex varchar(2) NULL,
	dob varchar(20) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKdreg_ok" ON hkpmi.death_reg_log USING btree (hkid, system_datetime);
CREATE INDEX "death_reg_log_idx2" ON hkpmi.death_reg_log USING btree (system_datetime);



ALTER TABLE hkpmi.death_reg_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
