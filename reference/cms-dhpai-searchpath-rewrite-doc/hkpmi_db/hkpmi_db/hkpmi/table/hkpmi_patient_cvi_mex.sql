-- hkpmi_patient_cvi_mex definition

-- Drop table

-- DROP TABLE hkpmi_patient_cvi_mex;

CREATE TABLE hkpmi_patient_cvi_mex (
	source_system varchar(10) NOT NULL,
	patient_key varchar(16) NOT NULL,
	vac_record_key varchar(60) NOT NULL,
	mex_indicator varchar(60) NULL,
	issue_by_inst_english_name varchar(510) NULL,
	issue_by_inst_chinese_name varchar(510) NULL,
	"issue_by_RMP_english_name" varchar(510) NULL,
	"issue_by_RMP_chinese_name" varchar(510) NULL,
	issue_date timestamp NULL,
	valid_till_date timestamp NULL,
	upload_src_system varchar(100) NULL,
	create_datetime timestamp NOT NULL,
	update_datetime timestamp NOT NULL,
	remarks varchar(200) NULL
);

CREATE UNIQUE INDEX hkpmi_patient_cvi_mex_idx ON hkpmi_patient_cvi_mex USING btree (patient_key);
CREATE INDEX hkpmi_patient_cvi_mex_pk_idx ON hkpmi_patient_cvi_mex USING btree (update_datetime, mex_indicator);

ALTER TABLE hkpmi_patient_cvi_mex OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
