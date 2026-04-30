CREATE TABLE updown_qrtz_fired_triggers (
	sched_name varchar(120) NOT NULL,
	entry_id varchar(95) NOT NULL,
	trigger_name varchar(200) NOT NULL,
	trigger_group varchar(200) NOT NULL,
	instance_name varchar(200) NOT NULL,
	fired_time int8 NOT NULL,
	sched_time int8 NOT NULL,
	priority int4 NOT NULL,
	state varchar(16) NOT NULL,
	job_name varchar(200) NULL,
	job_group varchar(200) NULL,
	is_nonconcurrent bool NULL,
	requests_recovery bool NULL,
	CONSTRAINT qrtz_fired_triggers_pkey PRIMARY KEY (sched_name, entry_id)
);
CREATE INDEX idx_qrtz_ft_inst_job_req_rcvry ON updown_qrtz_fired_triggers USING btree (sched_name, instance_name, requests_recovery);
CREATE INDEX idx_qrtz_ft_j_g ON updown_qrtz_fired_triggers USING btree (sched_name, job_name, job_group);
CREATE INDEX idx_qrtz_ft_jg ON updown_qrtz_fired_triggers USING btree (sched_name, job_group);
CREATE INDEX idx_qrtz_ft_t_g ON updown_qrtz_fired_triggers USING btree (sched_name, trigger_name, trigger_group);
CREATE INDEX idx_qrtz_ft_tg ON updown_qrtz_fired_triggers USING btree (sched_name, trigger_group);
CREATE INDEX idx_qrtz_ft_trig_inst_name ON updown_qrtz_fired_triggers USING btree (sched_name, instance_name);



ALTER TABLE updown_qrtz_fired_triggers OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
