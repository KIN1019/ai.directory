-- hkpmi.hkpmi_patient_info_log definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_patient_info_log;

CREATE TABLE hkpmi.hkpmi_patient_info_log (
	patient_key varchar(16) NOT NULL,
	info_type varchar(2) NOT NULL,
	hkic_symbol varchar(2) NULL,
	old_hkic_symbol varchar(2) NULL,
	doc_code varchar(2) NULL,
	doc_no varchar(60) NULL,
	old_doc_code varchar(2) NULL,
	old_doc_no varchar(60) NULL,
	upd_by varchar(24) NULL,
	upd_hosp varchar(6) NULL,
	upd_sys varchar(24) NULL,
	upd_dtm timestamp(6) NOT NULL
);
CREATE INDEX "XIE1hkpmi_patient_info_log" ON hkpmi.hkpmi_patient_info_log USING btree (patient_key);
CREATE INDEX "XIE2hkpmi_patient_info_log" ON hkpmi.hkpmi_patient_info_log USING btree (upd_dtm);
CREATE UNIQUE INDEX "XPKhkpmi_patient_info_log" ON hkpmi.hkpmi_patient_info_log USING btree (patient_key, info_type, upd_dtm);




ALTER TABLE hkpmi.hkpmi_patient_info_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
