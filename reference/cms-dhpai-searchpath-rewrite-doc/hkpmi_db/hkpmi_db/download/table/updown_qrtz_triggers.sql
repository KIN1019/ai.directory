CREATE TABLE updown_qrtz_triggers (
	sched_name varchar(120) NOT NULL,
	trigger_name varchar(200) NOT NULL,
	trigger_group varchar(200) NOT NULL,
	job_name varchar(200) NOT NULL,
	job_group varchar(200) NOT NULL,
	description varchar(250) NULL,
	next_fire_time int8 NULL,
	prev_fire_time int8 NULL,
	priority int4 NULL,
	trigger_state varchar(16) NOT NULL,
	trigger_type varchar(8) NOT NULL,
	start_time int8 NOT NULL,
	end_time int8 NULL,
	calendar_name varchar(200) NULL,
	misfire_instr int2 NULL,
	job_data bytea NULL,
	CONSTRAINT qrtz_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);
CREATE INDEX idx_qrtz_t_c ON updown_qrtz_triggers USING btree (sched_name, calendar_name);
CREATE INDEX idx_qrtz_t_g ON updown_qrtz_triggers USING btree (sched_name, trigger_group);
CREATE INDEX idx_qrtz_t_j ON updown_qrtz_triggers USING btree (sched_name, job_name, job_group);
CREATE INDEX idx_qrtz_t_jg ON updown_qrtz_triggers USING btree (sched_name, job_group);
CREATE INDEX idx_qrtz_t_n_g_state ON updown_qrtz_triggers USING btree (sched_name, trigger_group, trigger_state);
CREATE INDEX idx_qrtz_t_n_state ON updown_qrtz_triggers USING btree (sched_name, trigger_name, trigger_group, trigger_state);
CREATE INDEX idx_qrtz_t_next_fire_time ON updown_qrtz_triggers USING btree (sched_name, next_fire_time);
CREATE INDEX idx_qrtz_t_nft_misfire ON updown_qrtz_triggers USING btree (sched_name, misfire_instr, next_fire_time);
CREATE INDEX idx_qrtz_t_nft_st ON updown_qrtz_triggers USING btree (sched_name, trigger_state, next_fire_time);
CREATE INDEX idx_qrtz_t_nft_st_misfire ON updown_qrtz_triggers USING btree (sched_name, misfire_instr, next_fire_time, trigger_state);
CREATE INDEX idx_qrtz_t_nft_st_misfire_grp ON updown_qrtz_triggers USING btree (sched_name, misfire_instr, next_fire_time, trigger_group, trigger_state);
CREATE INDEX idx_qrtz_t_state ON updown_qrtz_triggers USING btree (sched_name, trigger_state);



ALTER TABLE updown_qrtz_triggers OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";

