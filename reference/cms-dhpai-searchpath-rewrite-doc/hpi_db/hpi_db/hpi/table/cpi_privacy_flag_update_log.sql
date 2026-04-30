-- cpi_privacy_flag_update_log definition

-- Drop table

-- DROP TABLE cpi_privacy_flag_update_log;

CREATE TABLE cpi_privacy_flag_update_log (
	hospital_code varchar(6) NOT NULL,
	patient_key varchar(16) NOT NULL,
	original_patient_key varchar(16) NOT NULL,
	case_no varchar(24) NULL,
	privacy_flag varchar(2) NOT NULL,
	update_system varchar(24) NOT NULL,
	update_function_id int4 NOT NULL,
	update_user_id varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX cpi_privacy_flag_updatelog_ci ON cpi_privacy_flag_update_log USING btree (patient_key, update_datetime);
CREATE INDEX cpi_privacy_flag_updatelog_ni1 ON cpi_privacy_flag_update_log USING btree (update_user_id, update_datetime, update_system);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX cpi_privacy_flag_update_log_ui ON cpi_privacy_flag_update_log USING btree (hospital_code, patient_key, original_patient_key, case_no,privacy_flag, update_system, update_function_id, update_user_id, update_datetime);
CREATE UNIQUE INDEX cpi_privacy_flag_update_log_ui ON cpi_privacy_flag_update_log USING btree (record_id);

ALTER TABLE cpi_privacy_flag_update_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";