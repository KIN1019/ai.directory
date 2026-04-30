-- hkpmi.ehr_code_table definition

-- Drop table

-- DROP TABLE hkpmi.ehr_code_table;

CREATE TABLE hkpmi.ehr_code_table (
	code_type varchar(40) NOT NULL,
	code_name varchar(40) NOT NULL,
	code_field varchar(40) NOT NULL,
	code_field_short_desc varchar(120) NOT NULL,
	code_field_full_desc varchar(510) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPK_ehr_code_table" ON hkpmi.ehr_code_table USING btree (code_type, code_name, code_field);




ALTER TABLE hkpmi.ehr_code_table OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
