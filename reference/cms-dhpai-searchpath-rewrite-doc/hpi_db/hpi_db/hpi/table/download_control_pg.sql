-- download_control definition

-- Drop table

-- DROP TABLE download_control;

CREATE TABLE download_control_pg (
	hospital_code varchar(6) NOT NULL,
	download_key varchar(46) NOT NULL,
	download_priority int4 NOT NULL,
	download_num_rec int4 NOT NULL,
	download_enable varchar(2) NOT NULL,
	download_last_datetime timestamp(6) NOT NULL,
	dnl_server_name varchar NOT NULL,
	row_update_datetime timestamp(6) NULL,
	last_download_system_datetime timestamp(6) NULL,
	delay_time int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX download_control_idx ON download_control_pg USING btree (hospital_code, download_key);
CREATE INDEX download_priority_idx ON download_control_pg USING btree (download_priority);



ALTER TABLE download_control_pg OWNER TO "HPI_SCHEMA_OWNER_ROLE";
