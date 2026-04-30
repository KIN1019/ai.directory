-- hkpmi.ehr_patient_list definition

-- Drop table

-- DROP TABLE hkpmi.ehr_patient_list;

CREATE TABLE hkpmi.ehr_patient_list (
	ehr_number varchar(24) NOT NULL,
	ehr_start_date varchar(16) NULL,
	ehr_end_date varchar(16) NULL,
	ehr_hkic varchar(24) NULL,
	ehr_surname varchar(80) NULL,
	ehr_givenname varchar(80) NULL,
	ehr_full_name varchar(200) NULL,
	ehr_sex varchar(2) NULL,
	ehr_dob varchar(16) NULL,
	ehr_exact_dob varchar(8) NULL,
	ehr_doc_type varchar(12) NULL,
	ehr_doc_no varchar(60) NULL,
	ehr_death_date varchar(16) NULL,
	ehr_death_time varchar(20) NULL,
	ehr_exact_death varchar(8) NULL,
	ehr_death_ind varchar(8) NULL,
	pas_hkic varchar(24) NULL,
	pas_pky varchar(16) NULL,
	pas_surname varchar(96) NULL,
	pas_givenname varchar(96) NULL,
	pas_full_name varchar(200) NULL,
	pas_sex varchar(2) NULL,
	pas_dob varchar(16) NULL,
	pas_exact_dob varchar(8) NULL,
	pas_doc_type varchar(12) NULL,
	pas_doc_no varchar(60) NULL,
	pas_death_date varchar(16) NULL,
	pas_death_time varchar(20) NULL,
	pas_exact_death varchar(8) NULL,
	pas_death_ind varchar(8) NULL,
	ehr_flag varchar(6) NOT NULL,
	ehr_flag_prev varchar(6) NULL,
	evt_ack varchar(2) NULL,
	crt_by varchar(24) NOT NULL,
	crt_hosp varchar(6) NULL,
	crt_sys varchar(24) NOT NULL,
	crt_dtm timestamp(6) NOT NULL,
	upd_by varchar(24) NULL,
	upd_hosp varchar(6) NULL,
	upd_sys varchar(24) NULL,
	upd_dtm timestamp(6) NULL,
	sys_dtm timestamp(6) NOT NULL,
	ehr_ppi_ind varchar(2) NULL,
	ehr_non_ha_ind varchar(2) NULL,
	ehr_status varchar(6) NULL,
	ehr_smart_id varchar(40) NULL
);
CREATE INDEX "XIE1_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (pas_hkic);
CREATE INDEX "XIE2_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (pas_pky);
CREATE INDEX "XIE3_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (sys_dtm);
CREATE INDEX "XIE4_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (pas_doc_no);
CREATE INDEX "XIE5_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (ehr_doc_no);
CREATE INDEX "XIE6_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (ehr_flag);
CREATE INDEX "XIE7_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (ehr_hkic);
CREATE UNIQUE INDEX "XPK_ehr_patient_list" ON hkpmi.ehr_patient_list USING btree (ehr_number);




ALTER TABLE hkpmi.ehr_patient_list OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
