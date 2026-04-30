CREATE TABLE updown_qrtz_scheduler_state (
	sched_name varchar(120) NOT NULL,
	instance_name varchar(200) NOT NULL,
	last_checkin_time int8 NOT NULL,
	checkin_interval int8 NOT NULL,
	CONSTRAINT qrtz_scheduler_state_pkey PRIMARY KEY (sched_name, instance_name)
);



ALTER TABLE updown_qrtz_scheduler_state OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";