-- hkpmi.sms_language_table definition

-- Drop table

-- DROP TABLE hkpmi.sms_language_table;

CREATE TABLE hkpmi.sms_language_table (
	sms_language_code varchar(8) NOT NULL,
	sms_language varchar(16) NOT NULL,
	description varchar(60) NOT NULL,
	short_description varchar(20) NOT NULL,
	seq_order int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX sms_language_table_idx ON hkpmi.sms_language_table USING btree (sms_language_code);




ALTER TABLE hkpmi.sms_language_table OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
