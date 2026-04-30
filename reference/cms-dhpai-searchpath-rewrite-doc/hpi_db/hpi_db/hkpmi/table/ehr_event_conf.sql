-- ehr_event_conf definition

-- Drop table

-- DROP FOREIGN TABLE ehr_event_conf;

CREATE FOREIGN TABLE ehr_event_conf (
	config_id int4 NOT NULL,
	system_id varchar(24) NOT NULL,
	conf_info varchar(256) NULL,
	last_ehr_event_dtm timestamp NULL,
	last_ehr_event_in_dtm timestamp NULL,
	last_ehr_event_out_dtm timestamp NULL,
	last_poll_dtm_in timestamp NULL,
	last_poll_dtm_out timestamp NULL,
	last_poll_dtm timestamp NULL,
	poll_interval int4 NULL,
	poll_count int4 NULL,
	retry_count int4 NULL,
	run_flag varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'ehr_event_conf');

ALTER TABLE ehr_event_conf OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
