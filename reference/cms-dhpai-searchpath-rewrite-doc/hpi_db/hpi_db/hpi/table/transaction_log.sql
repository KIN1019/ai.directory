-- transaction_log definition

-- Drop table

-- DROP TABLE transaction_log;

CREATE TABLE transaction_log (
	hospital_code varchar(6) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	from_ward_code varchar(8) NULL,
	from_treatment_location varchar(8) NULL,
	from_class varchar(2) NULL,
	from_bed varchar(10) NULL,
	from_specialty_code varchar(8) NULL,
	to_ward_code varchar(8) NULL,
	to_treatment_location varchar(8) NULL,
	to_class varchar(2) NULL,
	to_bed varchar(10) NULL,
	to_specialty_code varchar(8) NULL,
	transaction_datetime timestamp(6) NOT NULL,
	transaction_type varchar(6) NOT NULL,
	post_datetime timestamp(6) NULL,
	user_id varchar(16) NOT NULL,
	post_flag varchar(2) NULL,
	cancel_flag varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX "XIE1Transaction_Log" ON transaction_log USING btree (hospital_code, case_no);
CREATE UNIQUE INDEX "XIE2Transaction_Log" ON transaction_log USING btree (hospital_code, transaction_datetime, system_datetime, transaction_type);
CREATE UNIQUE INDEX "XPKTransaction_Log" ON transaction_log USING btree (hospital_code, system_datetime, transaction_type, transaction_datetime);

ALTER TABLE transaction_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
