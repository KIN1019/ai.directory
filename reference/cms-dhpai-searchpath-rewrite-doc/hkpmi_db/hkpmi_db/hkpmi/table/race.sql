-- hkpmi.race definition

-- Drop table

-- DROP TABLE hkpmi.race;

CREATE TABLE hkpmi.race (
	race_code varchar(4) NOT NULL,
	race_description varchar(40) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKrace" ON hkpmi.race USING btree (race_code);




ALTER TABLE hkpmi.race OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
