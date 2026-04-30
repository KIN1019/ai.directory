-- hkpmi.patient_doc_info definition

-- Drop table

-- DROP TABLE hkpmi.patient_doc_info;

CREATE TABLE hkpmi.patient_doc_info (
	patient_key varchar(16) NOT NULL,
	doc_code varchar(2) NULL,
	doc_no varchar(60) NULL,
	upd_by varchar(24) NULL,
	upd_hosp varchar(6) NULL,
	upd_sys varchar(24) NULL,
	upd_dtm timestamp(6) NULL
);
CREATE INDEX "XIE1patient_doc_info" ON hkpmi.patient_doc_info USING btree (doc_no);
CREATE UNIQUE INDEX "XPKpatient_doc_info" ON hkpmi.patient_doc_info USING btree (patient_key);




ALTER TABLE hkpmi.patient_doc_info OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
