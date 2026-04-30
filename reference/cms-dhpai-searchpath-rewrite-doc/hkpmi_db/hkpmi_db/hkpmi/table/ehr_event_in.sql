-- hkpmi.ehr_event_in definition

-- Drop table

-- DROP TABLE hkpmi.ehr_event_in;

CREATE TABLE hkpmi.ehr_event_in (
	msg_no varchar(40) NOT NULL,
	evt_code varchar(30) NOT NULL,
	txn_dtm timestamp(6) NOT NULL,
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
	old_ehr_hkic varchar(24) NULL,
	old_ehr_surname varchar(80) NULL,
	old_ehr_givenname varchar(80) NULL,
	old_ehr_full_name varchar(200) NULL,
	old_ehr_sex varchar(2) NULL,
	old_ehr_dob varchar(16) NULL,
	old_ehr_exact_dob varchar(8) NULL,
	old_ehr_doc_type varchar(12) NULL,
	old_ehr_doc_no varchar(60) NULL,
	evt_status varchar(2) NOT NULL,
	evt_crt_by varchar(24) NOT NULL,
	evt_crt_sys varchar(24) NOT NULL,
	evt_upd_dtm timestamp(6) NULL,
	evt_upd_by varchar(24) NULL,
	evt_upd_sys varchar(24) NULL,
	sys_dtm timestamp(6) NOT NULL,
	ehr_conf_code varchar(40) NULL,
	ehr_conf_value varchar(40) NULL,
	ehr_smart_id varchar(40) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "PKY_ehr_event_in" ON hkpmi.ehr_event_in USING btree (msg_no);
CREATE INDEX "XIE1_ehr_event_in" ON hkpmi.ehr_event_in USING btree (txn_dtm);
CREATE INDEX "XIE2_ehr_event_in" ON hkpmi.ehr_event_in USING btree (evt_status, txn_dtm);




ALTER TABLE hkpmi.ehr_event_in OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
