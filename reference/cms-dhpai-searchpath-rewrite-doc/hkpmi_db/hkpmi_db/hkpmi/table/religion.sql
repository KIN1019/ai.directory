-- hkpmi.religion definition

-- Drop table

-- DROP TABLE hkpmi.religion;

CREATE TABLE hkpmi.religion (
	religion_code varchar(6) NOT NULL,
	religion_description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKreligion" ON hkpmi.religion USING btree (religion_code);




ALTER TABLE hkpmi.religion OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
