-- cpi_suspend_upload_log definition

-- Drop table

-- DROP TABLE cpi_suspend_upload_log;

CREATE TABLE cpi_suspend_upload_log (
	hospital_code varchar(6) NOT NULL,
	transaction_datetime timestamp(6) NOT NULL,
	transaction_type varchar(6) NOT NULL,
	hkid varchar(24) NULL,
	patient_key varchar(16) NULL,
	case_no varchar(24) NULL,
	old_hkid varchar(24) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_suspend_upload_log_idx ON cpi_suspend_upload_log USING btree (hospital_code, transaction_datetime);




ALTER TABLE cpi_suspend_upload_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
