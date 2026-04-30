-- mras_table definition

-- Drop table

-- DROP TABLE mras_table;

CREATE TABLE mras_table (
	string1 varchar(344) NOT NULL,
	string2 varchar(440) NOT NULL,
	string3 varchar(416) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX mras_table_ui ON mras_table USING btree (string1, string2, string3);
CREATE UNIQUE INDEX mras_table_ui ON mras_table USING btree (record_id);

ALTER TABLE mras_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
