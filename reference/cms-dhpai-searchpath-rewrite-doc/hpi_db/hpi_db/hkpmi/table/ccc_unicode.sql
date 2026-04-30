-- ccc_unicode definition

-- Drop table

-- DROP FOREIGN TABLE ccc_unicode;

CREATE FOREIGN TABLE ccc_unicode (
	ccc_head varchar(8) NOT NULL,
	ccc_tail varchar(2) NOT NULL,
	phonetic_text varchar(12) NULL,
	unicode_int int4 NULL,
	unicode_char varchar(4) NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'ccc_unicode');

ALTER TABLE ccc_unicode OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
