-- hkpmi.ccc_unicode definition

-- Drop table

-- DROP TABLE hkpmi.ccc_unicode;

CREATE TABLE hkpmi.ccc_unicode (
	ccc_head varchar(8) NOT NULL,
	ccc_tail varchar(2) NOT NULL,
	phonetic_text varchar(12) NULL,
	unicode_int int4 NULL,
	unicode_char varchar(4) NULL,
	last_update_datetime timestamp(6) NULL
);

CREATE UNIQUE INDEX "ccc_unicode_ui" ON hkpmi.ccc_unicode USING btree (ccc_head, ccc_tail);
CREATE INDEX "ccc_unicode_idx" ON hkpmi.ccc_unicode USING btree (unicode_char);

ALTER TABLE hkpmi.ccc_unicode OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
