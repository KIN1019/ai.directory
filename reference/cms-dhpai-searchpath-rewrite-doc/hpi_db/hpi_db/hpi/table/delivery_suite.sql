-- delivery_suite definition

-- Drop table

-- DROP TABLE delivery_suite;

CREATE TABLE delivery_suite (
	ds_code varchar(8) NOT NULL,
	ds_specialty_code varchar(8) NOT NULL,
	ds_ns_code varchar(8) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "DS_IDX1" ON delivery_suite USING btree (ds_code, ds_specialty_code, ds_ns_code);




ALTER TABLE delivery_suite OWNER TO "HPI_SCHEMA_OWNER_ROLE";
