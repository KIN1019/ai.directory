-- audit_log definition

-- Drop table

-- DROP TABLE audit_log;

CREATE TABLE audit_log (
	system_datetime timestamp(6) NOT NULL,
	log_type varchar(6) NOT NULL,
	pat_user_id varchar(24) NOT NULL,
	workstation_id varchar(12) NOT NULL,
	login_id varchar(16) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "AUDLOG_IDX1" ON audit_log USING btree (system_datetime, workstation_id);




ALTER TABLE audit_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
