CREATE TABLE updown_qrtz_job_details (
	sched_name varchar(120) NOT NULL,
	job_name varchar(200) NOT NULL,
	job_group varchar(200) NOT NULL,
	description varchar(250) NULL,
	job_class_name varchar(250) NOT NULL,
	is_durable bool NOT NULL,
	is_nonconcurrent bool NOT NULL,
	is_update_data bool NOT NULL,
	requests_recovery bool NOT NULL,
	job_data bytea NULL,
	CONSTRAINT qrtz_job_details_pkey PRIMARY KEY (sched_name, job_name, job_group)
);
CREATE INDEX idx_qrtz_j_grp ON updown_qrtz_job_details USING btree (sched_name, job_group);
CREATE INDEX idx_qrtz_j_req_recovery ON updown_qrtz_job_details USING btree (sched_name, requests_recovery);



ALTER TABLE updown_qrtz_job_details OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";