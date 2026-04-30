-- dt_transaction_type definition

-- Drop table

-- DROP TABLE dt_transaction_type;

CREATE TABLE dt_transaction_type (
	adt_code varchar(6) NOT NULL,
	dt_code varchar(2) NOT NULL,
	description varchar(160) NULL,
	dt_cancellation_code varchar(2) NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX "XPKDT_transaction_type" ON dt_transaction_type USING btree (adt_code);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX "dt_transaction_type_ui" ON dt_transaction_type USING btree (adt_code,dt_code,description,dt_cancellation_code);
CREATE UNIQUE INDEX dt_transaction_type_ui ON dt_transaction_type USING btree (record_id);

ALTER TABLE dt_transaction_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
