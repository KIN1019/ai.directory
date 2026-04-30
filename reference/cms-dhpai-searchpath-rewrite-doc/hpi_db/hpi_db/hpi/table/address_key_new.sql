-- address_key_new definition

-- Drop table

-- DROP TABLE address_key_new;

CREATE TABLE address_key_new (
	record_id int4 NOT NULL,
	long_key varchar(48) NULL,
	short_key varchar(14) NULL,
	soundex_key varchar(16) NULL,
	record_type varchar(2) NULL,
	region varchar(4) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX address_key_new_indx ON address_key_new USING btree (record_id);
CREATE INDEX address_key_new_indx1 ON address_key_new USING btree (long_key, region);
CREATE INDEX address_key_new_indx2 ON address_key_new USING btree (short_key, region);
CREATE INDEX address_key_new_indx3 ON address_key_new USING btree (soundex_key, region);
CREATE UNIQUE INDEX address_key_new_pky ON address_key_new USING btree (record_id, long_key, short_key, soundex_key, record_type, region);


ALTER TABLE address_key_new OWNER TO "HPI_SCHEMA_OWNER_ROLE";
