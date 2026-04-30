-- hkpmi.hkpmi_pin_change_log definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_pin_change_log;

CREATE TABLE hkpmi.hkpmi_pin_change_log (
	hosp_code varchar(6) NOT NULL,
	txn_dtm timestamp(6) NOT NULL,
	txn_type varchar(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_key varchar(16) NOT NULL,
	old_hkid varchar(24) NULL,
	old_patient_key varchar(16) NULL,
	update_by varchar(24) NOT NULL,
	source_sys varchar(24) NOT NULL,
	source_sys_dtm timestamp(6) NOT NULL,
	update_hosp varchar(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX "XIE1hkpmi_pin_change_log" ON hkpmi.hkpmi_pin_change_log USING btree (old_patient_key);
CREATE INDEX "XIE2hkpmi_pin_change_log" ON hkpmi.hkpmi_pin_change_log USING btree (patient_key);
CREATE INDEX "XIE3hkpmi_pin_change_log" ON hkpmi.hkpmi_pin_change_log USING btree (old_hkid);
CREATE INDEX "XIE4hkpmi_pin_change_log" ON hkpmi.hkpmi_pin_change_log USING btree (hkid);
CREATE UNIQUE INDEX "XPKhkpmi_pin_change_log" ON hkpmi.hkpmi_pin_change_log USING btree (txn_dtm, hosp_code, hkid);




ALTER TABLE hkpmi.hkpmi_pin_change_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
