-- error_log definition

-- Drop table

-- DROP TABLE error_log;

CREATE TABLE error_log (
	hospital_code varchar(6) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	error_detail varchar(510) NOT NULL,
	record_1 varchar(510) NULL,
	record_2 varchar(510) NULL,
	record_3 varchar(510) NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "Error_log_19777710721" PRIMARY KEY (hospital_code, system_datetime) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE error_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
