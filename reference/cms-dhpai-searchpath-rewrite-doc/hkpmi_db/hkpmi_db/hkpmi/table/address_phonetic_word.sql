-- hkpmi.address_phonetic_word definition

-- Drop table

-- DROP TABLE hkpmi.address_phonetic_word;

CREATE TABLE hkpmi.address_phonetic_word (
	non_standard varchar(20) NOT NULL,
	standard varchar(20) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX phonetic_word_indx ON hkpmi.address_phonetic_word USING btree (non_standard);




ALTER TABLE hkpmi.address_phonetic_word OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
