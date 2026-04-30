-- hkpmi.ehr_event_log definition

-- Drop table

-- DROP TABLE hkpmi.ehr_event_log;

CREATE TABLE hkpmi.ehr_event_log (
	evt_txn_dtm timestamp(6) NOT NULL,
	evt_log_type varchar(2) NOT NULL,
	act_type varchar(10) NOT NULL,
	evt_code varchar(30) NULL,
	evt_msg_no varchar(40) NULL,
	ehr_msg_file varchar(96) NULL,
	evt_func_detail varchar(510) NULL,
	evt_err_msg varchar(256) NULL,
	evt_hosp_code varchar(6) NULL,
	rtn_code int4 NULL,
	rtn_msg varchar(256) NULL,
	upd_by varchar(24) NOT NULL,
	upd_sys varchar(24) NOT NULL,
	upd_hosp varchar(6) NULL,
	upd_host varchar(30) NULL,
	evt_remarks varchar(256) NULL,
	sys_dtm timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX "XPK_ehr_event_log" ON hkpmi.ehr_event_log USING btree (evt_txn_dtm, evt_log_type);
CREATE UNIQUE INDEX ehr_event_log_uidx ON hkpmi.ehr_event_log USING btree (evt_txn_dtm, evt_log_type, ehr_msg_file);




ALTER TABLE hkpmi.ehr_event_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
