-- address_phonetic_word definition

-- Drop table

-- DROP TABLE address_phonetic_word;

CREATE TABLE address_phonetic_word (
	non_standard varchar(20) NOT NULL,
	standard varchar(20) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX phonetic_word_indx ON address_phonetic_word USING btree (non_standard);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX address_phonetic_word_ui ON address_phonetic_word USING btree (non_standard,standard);
CREATE UNIQUE INDEX address_phonetic_word_ui ON address_phonetic_word USING btree (record_id);

ALTER TABLE address_phonetic_word OWNER TO "HPI_SCHEMA_OWNER_ROLE";
