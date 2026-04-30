-- hkpmi.ehr_event_conf definition

-- Drop table

-- DROP TABLE hkpmi.ehr_event_conf;

CREATE TABLE hkpmi.ehr_event_conf (
	config_id int4 NOT NULL,
	system_id varchar(24) NOT NULL,
	conf_info varchar(256) NULL,
	last_ehr_event_dtm timestamp(6) NULL,
	last_ehr_event_in_dtm timestamp(6) NULL,
	last_ehr_event_out_dtm timestamp(6) NULL,
	last_poll_dtm_in timestamp(6) NULL,
	last_poll_dtm_out timestamp(6) NULL,
	last_poll_dtm timestamp(6) NULL,
	poll_interval int4 NULL,
	poll_count int4 NULL,
	retry_count int4 NULL,
	run_flag varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPK_ehr_event_conf" ON hkpmi.ehr_event_conf USING btree (config_id, system_id);




ALTER TABLE hkpmi.ehr_event_conf OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
