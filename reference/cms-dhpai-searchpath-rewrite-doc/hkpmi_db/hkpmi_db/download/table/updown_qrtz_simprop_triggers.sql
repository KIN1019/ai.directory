CREATE TABLE updown_qrtz_simprop_triggers (
	sched_name varchar(120) NOT NULL,
	trigger_name varchar(200) NOT NULL,
	trigger_group varchar(200) NOT NULL,
	str_prop_1 varchar(512) NULL,
	str_prop_2 varchar(512) NULL,
	str_prop_3 varchar(512) NULL,
	int_prop_1 int4 NULL,
	int_prop_2 int4 NULL,
	long_prop_1 int8 NULL,
	long_prop_2 int8 NULL,
	dec_prop_1 numeric(13, 4) NULL,
	dec_prop_2 numeric(13, 4) NULL,
	bool_prop_1 bool NULL,
	bool_prop_2 bool NULL,
	CONSTRAINT qrtz_simprop_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);



ALTER TABLE updown_qrtz_simprop_triggers OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";