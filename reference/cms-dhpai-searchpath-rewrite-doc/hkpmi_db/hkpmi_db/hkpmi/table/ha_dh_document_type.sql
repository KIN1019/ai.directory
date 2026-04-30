CREATE TABLE hkpmi.ha_dh_document_type (
	ha_document_type varchar(10) NOT NULL,
	dh_default_document_type varchar(10) NOT NULL,
	dh_pseudoid_document_type varchar(10) NULL,
	effective_datetime timestamp NOT NULL,
	create_by varchar(24) NOT NULL,
	create_datetime timestamp NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ha_dh_document_type_idx ON hkpmi.ha_dh_document_type USING btree (ha_document_type, effective_datetime);



ALTER TABLE hkpmi.ha_dh_document_type OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
