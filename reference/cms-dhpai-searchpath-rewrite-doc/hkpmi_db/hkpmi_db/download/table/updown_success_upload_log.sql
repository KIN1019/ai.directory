-- updown_success_upload_log definition

-- Drop table

-- DROP TABLE updown_success_upload_log;

CREATE TABLE updown_success_upload_log (
	hospital_code varchar(6) NOT NULL,
	transaction_datetime timestamp(6) NOT NULL,
	hkid varchar(24) NULL,
	patient_key varchar(16) NULL
);
CREATE UNIQUE INDEX updown_success_upload_log_idx ON updown_success_upload_log USING btree (hospital_code, transaction_datetime);



ALTER TABLE updown_success_upload_log OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";