-- user_activity_log definition

-- Drop table

-- DROP TABLE user_activity_log;

CREATE TABLE user_activity_log (
	hospital_code varchar(6) NOT NULL,
	user_id varchar(16) NOT NULL,
	term_id varchar(24) NOT NULL,
	func_id varchar(6) NOT NULL,
	remark varchar(160) NULL,
	system_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX "XPKuser_activity_log" ON user_activity_log USING btree (hospital_code, system_datetime, func_id);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX "user_activity_log_ui" ON user_activity_log USING btree (hospital_code,user_id, term_id, func_id, remark, system_datetime);
CREATE UNIQUE INDEX user_activity_log_ui ON user_activity_log USING btree (record_id);

ALTER TABLE user_activity_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
