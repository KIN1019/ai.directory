-- eis_subx definition

-- Drop table

-- DROP TABLE eis_subx;

CREATE TABLE eis_subx (
	eis_string varchar(68) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX eis_subx_ui ON eis_subx USING btree (eis_string);
CREATE UNIQUE INDEX eis_subx_ui ON eis_subx USING btree (record_id);

ALTER TABLE eis_subx OWNER TO "HPI_SCHEMA_OWNER_ROLE";
