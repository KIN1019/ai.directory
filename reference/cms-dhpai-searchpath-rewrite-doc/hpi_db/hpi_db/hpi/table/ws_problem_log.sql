-- ws_problem_log definition

-- Drop table

-- DROP TABLE ws_problem_log;

CREATE TABLE ws_problem_log (
	hospital_code varchar(6) NOT NULL,
	ws_id varchar(96) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	error_code int4 NOT NULL,
	term_id varchar(96) NOT NULL,
	server_name varchar(96) NULL,
	database_name varchar(96) NULL,
	unhkid_prefix varchar(4) NULL,
	unhkid_min varchar(12) NULL,
	unhkid_max varchar(12) NULL,
	ae_min varchar(12) NULL,
	ae_max varchar(12) NULL,
	hn_min varchar(12) NULL,
	hn_max varchar(12) NULL,
	mini_label_min varchar(20) NULL,
	mini_label_max varchar(20) NULL,
	unhkid_next varchar(12) NULL,
	ae_next varchar(12) NULL,
	hn_next varchar(12) NULL,
	mini_label_next varchar(20) NULL,
	registration_year varchar(4) NULL,
	online_version varchar(96) NULL,
	downtime_version varchar(96) NULL,
	online_datetime timestamp(6) NULL,
	downtime_datetime timestamp(6) NULL,
	online_size int4 NULL,
	downtime_size int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ws_problem_index ON ws_problem_log USING btree (system_datetime, hospital_code, ws_id);




ALTER TABLE ws_problem_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
