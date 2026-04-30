CREATE TABLE hkpmi.dh_document_type (
	document_type varchar(10) NOT NULL,
	description varchar(510) NULL,
	short_description varchar(510) NULL,
	chinese_description varchar(510) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX dh_document_type_idx ON hkpmi.dh_document_type USING btree (document_type);



ALTER TABLE hkpmi.dh_document_type OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
