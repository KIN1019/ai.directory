-- no_charge_table definition

-- Drop table

-- DROP TABLE no_charge_table;

CREATE TABLE no_charge_table (
	no_charge_indicator varchar(10) NOT NULL,
	description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX no_charge_table_idx ON no_charge_table USING btree (no_charge_indicator);




ALTER TABLE no_charge_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
