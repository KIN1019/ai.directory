-- hkpmi.ehr_event_out definition

-- Drop table

-- DROP TABLE hkpmi.ehr_event_out;

CREATE TABLE hkpmi.ehr_event_out (
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
	pas_hkic varchar(24) NULL,
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
	evt_ack varchar(2) NULL,
	evt_ack_status_ehr varchar(2) NULL,
	evt_ack_status_epr varchar(2) NULL,
	evt_crt_by varchar(24) NOT NULL,
	evt_crt_sys varchar(24) NOT NULL,
	evt_crt_hosp varchar(6) NULL,
	evt_upd_dtm_ehr timestamp(6) NULL,
	evt_upd_dtm_epr timestamp(6) NULL,
	evt_upd_by varchar(24) NULL,
	evt_upd_sys varchar(24) NULL,
	sys_dtm timestamp(6) NOT NULL,
	ehr_ppi_ind varchar(2) NULL,
	ehr_non_ha_ind varchar(2) NULL,
	ehr_status varchar(6) NULL,
	evt_ack_status_ris varchar(2) NULL,
	evt_upd_dtm_ris timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX "XIE1_ehr_event_out" ON hkpmi.ehr_event_out USING btree (txn_dtm);
CREATE INDEX "XIE2_ehr_event_out" ON hkpmi.ehr_event_out USING btree (evt_ack_status_ehr, txn_dtm);
CREATE INDEX "XIE3_ehr_event_out" ON hkpmi.ehr_event_out USING btree (evt_ack_status_epr, txn_dtm);
CREATE INDEX "XIE4_ehr_event_out" ON hkpmi.ehr_event_out USING btree (evt_ack_status_ris, txn_dtm);
CREATE UNIQUE INDEX "XPK_ehr_event_out" ON hkpmi.ehr_event_out USING btree (msg_no, evt_code);




ALTER TABLE hkpmi.ehr_event_out OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
