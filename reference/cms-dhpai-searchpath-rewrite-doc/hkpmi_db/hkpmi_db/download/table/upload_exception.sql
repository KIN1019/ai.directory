-- upload_exception definition

-- Drop table

-- DROP TABLE upload_exception;

CREATE TABLE upload_exception (
	hospital_code varchar(6) NOT NULL,
	transaction_dtm timestamp NOT NULL,
	error_detail varchar(510) NOT NULL,
	record1 varchar(510) NULL,
	record2 varchar(510) NULL,
	record3 varchar(510) NULL,
	update_dtm timestamp NOT NULL

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX upload_exception_idx ON upload_exception USING btree (hospital_code, transaction_dtm, update_dtm);

ALTER TABLE upload_exception OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
