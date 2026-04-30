-- pas_monitor definition

-- Drop table

-- DROP TABLE pas_monitor;

CREATE TABLE pas_monitor (
	monitor_sys varchar(24) NOT NULL,
	monitor_type varchar(20) NOT NULL,
	monitor_dtm timestamp(6) NOT NULL,
	monitor_data varchar(512) NULL,
	sys_now_dtm timestamp(6) NULL,
	hospital_code varchar(6) NULL,
	server_an varchar(40) NULL,
	db_name varchar(40) NULL,
	local_server_name varchar(40) NULL,
	update_by varchar(24) NOT NULL,
	update_sys varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX pas_monitor_pky ON pas_monitor USING btree (monitor_sys, monitor_type, monitor_dtm);




ALTER TABLE pas_monitor OWNER TO "HPI_SCHEMA_OWNER_ROLE";
