-- hkpmi.destination definition

-- Drop table

-- DROP TABLE hkpmi.destination;

CREATE TABLE hkpmi.destination (
	destination_code varchar(6) NOT NULL,
	description varchar(200) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKdestination" ON hkpmi.destination USING btree (destination_code);




ALTER TABLE hkpmi.destination OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
