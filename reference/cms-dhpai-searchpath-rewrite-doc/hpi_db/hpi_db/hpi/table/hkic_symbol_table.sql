-- hkic_symbol_table definition

-- Drop table

-- DROP TABLE hkic_symbol_table;

CREATE TABLE hkic_symbol_table (
	hkic_symbol varchar(2) NOT NULL,
	hkic_symbol_type varchar(10) NOT NULL,
	short_description varchar(510) NOT NULL,
	full_description varchar(510) NOT NULL,
	sort_order int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX hkic_symbol_table_idx ON hkic_symbol_table USING btree (hkic_symbol);




ALTER TABLE hkic_symbol_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
