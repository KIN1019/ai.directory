-- suspend_upload_log definition

-- Drop table

-- DROP TABLE suspend_upload_log;

CREATE TABLE suspend_upload_log (
	hospital_code varchar(6) NOT NULL,
	transaction_dtm timestamp NOT NULL,
	"type" varchar(6) NOT NULL,
	hkid varchar(24) NULL,
	patient_key varchar(16) NULL,
	case_no varchar(24) NULL,
	old_hkid varchar(24) NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX suspend_upload_log_idx ON suspend_upload_log USING btree (hospital_code, transaction_dtm);

ALTER TABLE suspend_upload_log OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
