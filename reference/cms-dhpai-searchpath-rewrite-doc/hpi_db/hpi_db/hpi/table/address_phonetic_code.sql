-- address_phonetic_code definition

-- Drop table

-- DROP TABLE address_phonetic_code;

CREATE TABLE address_phonetic_code (
	phonetic_char varchar(2) NOT NULL,
	phonetic_code varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX phonetic_code_indx ON address_phonetic_code USING btree (phonetic_char);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX address_phonetic_code_ui ON address_phonetic_code USING btree (phonetic_char,phonetic_code);
CREATE UNIQUE INDEX address_phonetic_code_ui ON address_phonetic_code USING btree (record_id);

ALTER TABLE address_phonetic_code OWNER TO "HPI_SCHEMA_OWNER_ROLE";
