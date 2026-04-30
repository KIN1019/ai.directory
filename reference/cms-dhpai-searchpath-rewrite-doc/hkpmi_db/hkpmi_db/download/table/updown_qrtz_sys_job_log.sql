CREATE SEQUENCE seq_job_log_id
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1
	CACHE 1
	NO CYCLE;
	


ALTER SEQUENCE seq_job_log_id OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";

CREATE TABLE updown_qrtz_sys_job_log (
	job_log_id int8 DEFAULT nextval('seq_job_log_id'::regclass) NOT NULL,
	job_name varchar(64) NOT NULL,
	job_group varchar(64) NOT NULL,
	invoke_target varchar(500) NOT NULL,
	job_message varchar(500) NULL,
	status bpchar(1) DEFAULT '0'::character(1) NULL,
	exception_info varchar(2000) DEFAULT ''::character varying NULL,
	create_time timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	create_by varchar(64) DEFAULT ''::character varying NULL,
	update_by varchar(64) DEFAULT ''::character varying NULL,
	update_time timestamp NULL,
	start_time timestamp NULL,
	end_time timestamp NULL,
	CONSTRAINT qrtz_sys_job_log_pkey PRIMARY KEY (job_log_id)
);



ALTER TABLE updown_qrtz_sys_job_log OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";