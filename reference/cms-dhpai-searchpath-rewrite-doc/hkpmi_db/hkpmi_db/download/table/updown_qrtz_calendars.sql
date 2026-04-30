CREATE TABLE updown_qrtz_calendars (
	sched_name varchar(120) NOT NULL,
	calendar_name varchar(200) NOT NULL,
	calendar bytea NOT NULL,
	CONSTRAINT qrtz_calendars_pkey PRIMARY KEY (sched_name, calendar_name)
);



ALTER TABLE updown_qrtz_calendars OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
