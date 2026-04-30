-- cpi_privacy_flag definition

-- Drop table

-- DROP TABLE cpi_privacy_flag;

CREATE TABLE cpi_privacy_flag (
	hospital_code varchar(6) NOT NULL,
	patient_key varchar(16) NOT NULL,
	privacy_flag varchar(2) NOT NULL,
	last_update_system varchar(24) NOT NULL,
	last_update_function_id int4 NOT NULL,
	last_update_user_id varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NOT NULL
);
CREATE INDEX cpi_privacy_flag_flag_ni1 ON cpi_privacy_flag USING btree (privacy_flag, last_update_datetime);
CREATE UNIQUE INDEX cpi_privacy_flag_uci ON cpi_privacy_flag USING btree (patient_key);




ALTER TABLE cpi_privacy_flag OWNER TO "HPI_SCHEMA_OWNER_ROLE";
