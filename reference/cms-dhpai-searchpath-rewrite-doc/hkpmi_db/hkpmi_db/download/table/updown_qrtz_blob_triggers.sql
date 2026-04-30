CREATE TABLE updown_qrtz_blob_triggers (
	sched_name varchar(120) NOT NULL,
	trigger_name varchar(200) NOT NULL,
	trigger_group varchar(200) NOT NULL,
	blob_data bytea NULL,
	CONSTRAINT qrtz_blob_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);



ALTER TABLE updown_qrtz_blob_triggers OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";