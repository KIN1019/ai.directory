CREATE TABLE updown_qrtz_simple_triggers (
	sched_name varchar(120) NOT NULL,
	trigger_name varchar(200) NOT NULL,
	trigger_group varchar(200) NOT NULL,
	repeat_count int8 NOT NULL,
	repeat_interval int8 NOT NULL,
	times_triggered int8 NOT NULL,
	CONSTRAINT qrtz_simple_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);



ALTER TABLE updown_qrtz_simple_triggers OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";