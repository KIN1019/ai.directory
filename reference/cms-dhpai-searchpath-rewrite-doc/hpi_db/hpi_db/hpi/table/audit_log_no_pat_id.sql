-- audit_log_no_pat_id definition

-- Drop table

-- DROP TABLE audit_log_no_pat_id;

/*
The PostgreSQL table "audit_log_no_pat_id" is mapped to the Sybase table "Audit_log", because there's another Sybase table "AUDIT_LOG" with the same name, 
so the table is renamed in PostgreSQL.
*/
CREATE TABLE audit_log_no_pat_id (
	hospital_code varchar(6) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	ws_id varchar(16) NOT NULL,
	login_id varchar(24) NOT NULL,
	func_id int4 NOT NULL,
	action_type varchar(2) NOT NULL,
	action_string varchar(80) NULL,
	hkid varchar(24) NULL,
	case_no varchar(24) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XIE1Audit_log" ON audit_log_no_pat_id USING btree (hospital_code, system_datetime, ws_id);
CREATE INDEX "XIE2Audit_log" ON audit_log_no_pat_id USING btree (hospital_code, hkid);
CREATE INDEX "XIE3Audit_log" ON audit_log_no_pat_id USING btree (hospital_code, case_no);

ALTER TABLE audit_log_no_pat_id OWNER TO "HPI_SCHEMA_OWNER_ROLE";
