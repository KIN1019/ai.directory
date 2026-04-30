-- patient_doc_info_op definition

-- Drop table

-- DROP TABLE patient_doc_info_op;

CREATE TABLE patient_doc_info_op (
	patient_key varchar(16) NOT NULL,
	doc_code varchar(2) NULL,
	doc_no varchar(60) NULL,
	upd_by varchar(24) NULL,
	upd_hosp varchar(6) NULL,
	upd_sys varchar(24) NULL,
	upd_dtm timestamp NULL,
	CONSTRAINT patient_doc_info_op_pkey PRIMARY KEY (patient_key)
);
CREATE INDEX "XIE1patient_doc_info_op" ON patient_doc_info_op USING btree (doc_no);
CREATE UNIQUE INDEX "XPKpatient_doc_info_op" ON patient_doc_info_op USING btree (patient_key);




ALTER TABLE patient_doc_info_op OWNER TO "HPI_SCHEMA_OWNER_ROLE";