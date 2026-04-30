-- hkpmi.hkpmi_eis definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_eis;

CREATE TABLE hkpmi.hkpmi_eis (
	eis_code varchar(6) NOT NULL,
	description varchar(48) NOT NULL,
	eis_specialty varchar(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX hkpmi_eis_index ON hkpmi.hkpmi_eis USING btree (eis_code);




ALTER TABLE hkpmi.hkpmi_eis OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
