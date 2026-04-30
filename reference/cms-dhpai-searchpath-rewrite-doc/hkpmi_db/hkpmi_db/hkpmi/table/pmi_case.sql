-- hkpmi.pmi_case definition

-- Drop table

-- DROP TABLE hkpmi.pmi_case;

CREATE TABLE hkpmi.pmi_case (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	patient_key varchar(16) NOT NULL,
	case_type varchar(2) NOT NULL,
	adm_dtm timestamp(6) NOT NULL,
	source_indicator varchar(2) NULL,
	source_code varchar(6) NULL,
	patient_type varchar(6) NULL,
	discharge_code varchar(2) NULL,
	discharge_dtm timestamp(6) NULL,
	destination_code varchar(10) NULL,
	adm_specialty_code varchar(8) NULL,
	adm_ward_code varchar(8) NULL,
	adm_ward_class varchar(2) NULL,
	last_specialty_code varchar(8) NULL,
	last_ward_code varchar(8) NULL,
	last_ward_class varchar(2) NULL,
	last_bed_no varchar(10) NULL,
	pp_code varchar(16) NULL,
	access_code int4 NULL,
	create_by varchar(16) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	update_by varchar(16) NOT NULL,
	source_system_dtm timestamp(6) NOT NULL,
	district varchar(10) NULL,
	mrt_indicator varchar(2) NULL,
	movement_count int4 NULL,
	security_count int4 NULL,
	source_system varchar(10) NOT NULL,
	filler varchar(30) NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX "XIE1pmi_case" ON hkpmi.pmi_case USING btree (patient_key);
CREATE UNIQUE INDEX "XPKpmi_case" ON hkpmi.pmi_case USING btree (hospital_code, case_no);



ALTER TABLE hkpmi.pmi_case OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
