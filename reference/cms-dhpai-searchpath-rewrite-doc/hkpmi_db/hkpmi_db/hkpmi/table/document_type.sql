-- hkpmi.document_type definition

-- Drop table

-- DROP TABLE hkpmi.document_type;

CREATE TABLE hkpmi.document_type (
	document_type varchar(10) NOT NULL,
	document_code varchar(2) NOT NULL,
	description varchar(510) NOT NULL,
	chinese_description varchar(510) NOT NULL,
	hkid_type varchar(2) NULL,
	pay_code int4 NULL,
	function_used varchar(2) NULL,
	short_description varchar(510) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX document_type_idx ON hkpmi.document_type USING btree (document_type);
CREATE UNIQUE INDEX document_type_idx2 ON hkpmi.document_type USING btree (document_code);




ALTER TABLE hkpmi.document_type OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
