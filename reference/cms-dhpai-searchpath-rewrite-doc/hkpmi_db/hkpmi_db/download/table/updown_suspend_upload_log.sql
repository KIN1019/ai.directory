-- updown_suspend_upload_log definition

-- Drop table

-- DROP TABLE updown_suspend_upload_log;

CREATE TABLE updown_suspend_upload_log (
	hospital_code varchar(6) NOT NULL,
	transaction_datetime timestamp(6) NOT NULL,
	transaction_type varchar(6) NOT NULL,
	hkid varchar(24) NULL,
	patient_key varchar(16) NULL,
	case_no varchar(24) NULL,
	old_hkid varchar(24) NULL
);
CREATE UNIQUE INDEX updown_suspend_upload_log_idx ON updown_suspend_upload_log USING btree (hospital_code, transaction_datetime);




ALTER TABLE updown_suspend_upload_log OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
