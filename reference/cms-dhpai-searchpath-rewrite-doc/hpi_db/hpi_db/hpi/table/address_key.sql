-- address_key definition

-- Drop table

-- DROP TABLE address_key;

CREATE TABLE address_key (
	record_id int4 NOT NULL,
	long_key varchar(48) NULL,
	short_key varchar(14) NULL,
	soundex_key varchar(16) NULL,
	record_type varchar(2) NULL,
	region varchar(4) NULL,
	last_update_datetime timestamp(6) NULL,
	id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX address_key_indx ON address_key USING btree (record_id);
CREATE INDEX address_key_indx1 ON address_key USING btree (long_key, region);
CREATE INDEX address_key_indx2 ON address_key USING btree (short_key, region);
CREATE INDEX address_key_indx3 ON address_key USING btree (soundex_key, region);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX address_key_ui ON address_key USING btree (record_id, long_key,short_key, soundex_key, record_type, region);
CREATE UNIQUE INDEX address_key_ui ON address_key USING btree (id);

ALTER TABLE address_key OWNER TO "HPI_SCHEMA_OWNER_ROLE";