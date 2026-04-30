-- hkpmi.discharge_type definition

-- Drop table

-- DROP TABLE hkpmi.discharge_type;

CREATE TABLE hkpmi.discharge_type (
	discharge_code varchar(2) NOT NULL,
	description varchar(80) NOT NULL,
	short_description varchar(10) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKdischarge_type" ON hkpmi.discharge_type USING btree (discharge_code);




ALTER TABLE hkpmi.discharge_type OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
