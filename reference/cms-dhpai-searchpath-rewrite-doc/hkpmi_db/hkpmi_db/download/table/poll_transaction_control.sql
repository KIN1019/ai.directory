-- poll_transaction_control definition

-- Drop table

-- DROP TABLE poll_transaction_control;

CREATE TABLE poll_transaction_control (
	hospital_code varchar(6) NOT NULL,
	max_record_count int4 NOT NULL,
	last_download_dtm timestamp NOT NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX "XPKpoll" ON poll_transaction_control USING btree (hospital_code);

ALTER TABLE poll_transaction_control OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
