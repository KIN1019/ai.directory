-- document_type definition

-- Drop table

-- DROP FOREIGN TABLE document_type;

CREATE FOREIGN TABLE document_type (
	document_type varchar(10) NOT NULL,
	document_code varchar(2) NOT NULL,
	description varchar(510) NOT NULL,
	chinese_description varchar(510) NOT NULL,
	hkid_type varchar(2) NULL,
	pay_code int4 NULL,
	function_used varchar(2) NULL,
	short_description varchar(510) NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'document_type');

ALTER TABLE document_type OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
