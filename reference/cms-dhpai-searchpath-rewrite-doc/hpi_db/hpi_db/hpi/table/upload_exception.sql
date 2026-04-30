-- upload_exception definition

-- Drop table

-- DROP TABLE upload_exception;

CREATE TABLE upload_exception (
	hospital_code varchar(6) NOT NULL,
	transaction_datetime timestamp(6) NOT NULL,
	error_detail varchar(510) NOT NULL,
	record1 varchar(510) NULL,
	record2 varchar(510) NULL,
	record3 varchar(510) NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX upload_exception_idx ON upload_exception USING btree (hospital_code, transaction_datetime, update_datetime);




ALTER TABLE upload_exception OWNER TO "HPI_SCHEMA_OWNER_ROLE";
