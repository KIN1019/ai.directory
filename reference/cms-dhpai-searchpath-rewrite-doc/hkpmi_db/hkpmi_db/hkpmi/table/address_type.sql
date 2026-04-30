-- hkpmi.address_type definition

-- Drop table

-- DROP TABLE hkpmi.address_type;

CREATE TABLE hkpmi.address_type (
	full_name varchar(32) NOT NULL,
	abbreviation varchar(8) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX address_type_indx ON hkpmi.address_type USING btree (full_name,abbreviation);




ALTER TABLE hkpmi.address_type OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
