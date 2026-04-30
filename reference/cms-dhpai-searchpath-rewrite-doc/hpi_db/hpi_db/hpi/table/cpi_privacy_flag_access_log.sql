-- cpi_privacy_flag_access_log definition

-- Drop table

-- DROP TABLE cpi_privacy_flag_access_log;

CREATE TABLE cpi_privacy_flag_access_log (
	hospital_code varchar(6) NOT NULL,
	patient_key varchar(16) NOT NULL,
	case_no varchar(24) NULL,
	access_search_type varchar(24) NOT NULL,
	access_user_action varchar(24) NOT NULL,
	access_reason_code varchar(6) NULL,
	access_reason varchar(510) NULL,
	access_system varchar(24) NOT NULL,
	access_function_id int4 NOT NULL,
	access_user_id varchar(24) NOT NULL,
	access_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX cpi_privacy_flag_accesslog_ci ON cpi_privacy_flag_access_log USING btree (patient_key, access_datetime);
CREATE INDEX cpi_privacy_flag_accesslog_ni1 ON cpi_privacy_flag_access_log USING btree (access_reason_code, access_datetime);
CREATE INDEX cpi_privacy_flag_accesslog_ni2 ON cpi_privacy_flag_access_log USING btree (access_user_action, access_datetime);
CREATE INDEX cpi_privacy_flag_accesslog_ni3 ON cpi_privacy_flag_access_log USING btree (access_user_id, access_function_id, patient_key, access_datetime);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX cpi_privacy_flag_access_log_ui ON cpi_privacy_flag_access_log USING btree (hospital_code, patient_key, case_no,access_search_type, access_user_action, access_reason_code, access_reason, access_system,access_function_id, access_user_id, access_datetime);
CREATE UNIQUE INDEX cpi_privacy_flag_access_log_ui ON cpi_privacy_flag_access_log USING btree (record_id);

ALTER TABLE cpi_privacy_flag_access_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";