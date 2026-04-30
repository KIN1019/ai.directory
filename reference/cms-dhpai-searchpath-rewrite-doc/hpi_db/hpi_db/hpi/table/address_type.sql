-- address_type definition

-- Drop table

-- DROP TABLE address_type;

CREATE TABLE address_type (
	full_name varchar(32) NOT NULL,
	abbreviation varchar(8) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX address_type_indx ON address_type USING btree (full_name);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX address_type_ui ON address_type USING btree (full_name,abbreviation);
CREATE UNIQUE INDEX address_type_ui ON address_type USING btree (record_id);

ALTER TABLE address_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
