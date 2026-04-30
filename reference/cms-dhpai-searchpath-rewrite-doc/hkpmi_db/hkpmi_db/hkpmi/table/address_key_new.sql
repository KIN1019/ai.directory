-- hkpmi.address_key_new definition

-- Drop table

-- DROP TABLE hkpmi.address_key_new;

CREATE TABLE hkpmi.address_key_new (
	record_id int4 NOT NULL,
	long_key varchar(48) NULL,
	short_key varchar(14) NULL,
	soundex_key varchar(16) NULL,
	record_type varchar(2) NULL,
	region varchar(4) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX address_key_new_indx ON hkpmi.address_key_new USING btree (record_id);
CREATE INDEX address_key_new_indx1 ON hkpmi.address_key_new USING btree (long_key, region);
CREATE INDEX address_key_new_indx2 ON hkpmi.address_key_new USING btree (short_key, region);
CREATE INDEX address_key_new_indx3 ON hkpmi.address_key_new USING btree (soundex_key, region);
CREATE UNIQUE INDEX address_key_new_pky ON hkpmi.address_key_new USING btree (record_id, long_key, short_key, soundex_key, record_type, region);




ALTER TABLE hkpmi.address_key_new OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
