-- transaction_log_control definition

-- Drop table

-- DROP TABLE transaction_log_control;

CREATE TABLE transaction_log_control (
	system_dtm timestamp NOT NULL,
	tran_key int4 NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX transaction_log_control_uidx ON transaction_log_control USING btree (tran_key, system_dtm);

ALTER TABLE transaction_log_control OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
