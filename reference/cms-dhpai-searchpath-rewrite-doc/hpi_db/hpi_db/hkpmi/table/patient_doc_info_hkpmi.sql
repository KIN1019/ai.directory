-- patient_doc_info_hkpmi definition

-- Drop table

-- DROP FOREIGN TABLE patient_doc_info_hkpmi;

CREATE FOREIGN TABLE patient_doc_info_hkpmi (
	patient_key varchar(16) NOT NULL,
	doc_code varchar(2) NULL,
	doc_no varchar(60) NULL,
	upd_by varchar(24) NULL,
	upd_hosp varchar(6) NULL,
	upd_sys varchar(24) NULL,
	upd_dtm timestamp NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'patient_doc_info');

ALTER TABLE patient_doc_info_hkpmi OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
