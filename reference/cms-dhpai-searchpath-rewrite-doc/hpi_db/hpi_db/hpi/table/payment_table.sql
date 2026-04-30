-- payment_table definition

-- Drop table

-- DROP TABLE payment_table;

CREATE TABLE payment_table (
	payment_means varchar(10) NOT NULL,
	description varchar(160) NOT NULL,
	deferred_payment varchar(2) NULL,
	short_description varchar(160) NULL,
	display_order int4 NULL,
	default_value varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX payment_table_idx ON payment_table USING btree (payment_means);




ALTER TABLE payment_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
