-- acex_table definition

-- Drop table

-- DROP TABLE IF EXISTS adt_case_adtdb_trigger_error_log;

/*
This "middle" table is created for CPI to HPI schema consolidation, and does not need CDC configuration.
*/
CREATE TABLE adt_case_adtdb_trigger_error_log (
	id bigserial NOT NULL,
	message jsonb NULL,
	create_time timestamp NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT trigger_error_log_pk PRIMARY KEY (id)
);
CREATE INDEX trigger_error_log_create_time_idx ON adt_case_adtdb_trigger_error_log USING btree (create_time);


ALTER TABLE adt_case_adtdb_trigger_error_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
