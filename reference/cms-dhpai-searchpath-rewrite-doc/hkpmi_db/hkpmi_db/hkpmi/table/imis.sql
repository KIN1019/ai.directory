-- hkpmi.imis definition

-- Drop table

-- DROP TABLE hkpmi.imis;

CREATE TABLE hkpmi.imis (
	imis_code varchar(6) NOT NULL,
	description varchar(48) NULL,
	eis_code varchar(6) NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKIMIS" PRIMARY KEY (imis_code)
);




ALTER TABLE hkpmi.imis OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
