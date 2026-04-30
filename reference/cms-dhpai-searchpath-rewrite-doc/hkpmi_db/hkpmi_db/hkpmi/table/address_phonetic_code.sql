-- hkpmi.address_phonetic_code definition

-- Drop table

-- DROP TABLE hkpmi.address_phonetic_code;

CREATE TABLE hkpmi.address_phonetic_code (
	phonetic_char varchar(2) NOT NULL,
	phonetic_code varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX phonetic_code_indx ON hkpmi.address_phonetic_code USING btree (phonetic_char);




ALTER TABLE hkpmi.address_phonetic_code OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
