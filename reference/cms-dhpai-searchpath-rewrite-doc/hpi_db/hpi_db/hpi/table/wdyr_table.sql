-- wdyr_table definition

-- Drop table

-- DROP TABLE wdyr_table;

CREATE TABLE wdyr_table (
	wdyr_out varchar(188) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX wdyr_table_ui ON wdyr_table USING btree (wdyr_out);
CREATE UNIQUE INDEX wdyr_table_ui ON wdyr_table USING btree (record_id);

ALTER TABLE wdyr_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
