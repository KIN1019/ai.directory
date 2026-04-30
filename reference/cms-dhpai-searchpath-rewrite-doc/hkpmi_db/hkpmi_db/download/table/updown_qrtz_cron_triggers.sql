
CREATE TABLE updown_qrtz_cron_triggers (
	sched_name varchar(120) NOT NULL,
	trigger_name varchar(200) NOT NULL,
	trigger_group varchar(200) NOT NULL,
	cron_expression varchar(120) NOT NULL,
	time_zone_id varchar(80) NULL,
	CONSTRAINT qrtz_cron_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);




ALTER TABLE updown_qrtz_cron_triggers OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";