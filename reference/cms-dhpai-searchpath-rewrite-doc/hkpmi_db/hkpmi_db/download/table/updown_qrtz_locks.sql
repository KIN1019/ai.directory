CREATE TABLE updown_qrtz_locks (
	sched_name varchar(120) NOT NULL,
	lock_name varchar(40) NOT NULL,
	CONSTRAINT qrtz_locks_pkey PRIMARY KEY (sched_name, lock_name)
);



ALTER TABLE updown_qrtz_locks OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";