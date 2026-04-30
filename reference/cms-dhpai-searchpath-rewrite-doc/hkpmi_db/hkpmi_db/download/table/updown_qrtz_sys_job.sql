CREATE TABLE updown_qrtz_sys_job (
	job_id int8 NOT NULL,
	job_name varchar(64) DEFAULT ''::character varying NOT NULL,
	job_group varchar(64) DEFAULT 'DEFAULT'::character varying NOT NULL,
	invoke_target varchar(500) NOT NULL,
	cron_expression varchar(255) DEFAULT ''::character varying NULL,
	misfire_policy varchar(20) DEFAULT '0'::character varying NULL,
	concurrent bpchar(1) DEFAULT '1'::character(1) NULL,
	status bpchar(1) DEFAULT '0'::character(1) NULL,
	create_by varchar(64) DEFAULT ''::character varying NULL,
	create_time timestamp NULL,
	update_by varchar(64) DEFAULT ''::character varying NULL,
	update_time timestamp NULL,
	remark varchar(500) DEFAULT ''::character varying NULL,
	total int4 NULL,
	CONSTRAINT qrtz_sys_job_pkey PRIMARY KEY (job_id, job_name, job_group)
);




ALTER TABLE updown_qrtz_sys_job OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";