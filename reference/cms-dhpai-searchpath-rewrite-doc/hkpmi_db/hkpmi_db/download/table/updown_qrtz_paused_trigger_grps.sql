CREATE TABLE updown_qrtz_paused_trigger_grps (
	sched_name varchar(120) NOT NULL,
	trigger_group varchar(200) NOT NULL,
	CONSTRAINT qrtz_paused_trigger_grps_pkey PRIMARY KEY (sched_name, trigger_group)
);



ALTER TABLE updown_qrtz_paused_trigger_grps OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";