-- ocsss_soft_launch_check_log definition

-- Drop table

-- DROP TABLE ocsss_soft_launch_check_log;

CREATE TABLE ocsss_soft_launch_check_log (
	hospital varchar(6) NOT NULL,
	start_datetime timestamp(6) NOT NULL,
	end_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX idx_ocsss_soft_launch_check_log ON ocsss_soft_launch_check_log USING btree (hospital, start_datetime);




ALTER TABLE ocsss_soft_launch_check_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
