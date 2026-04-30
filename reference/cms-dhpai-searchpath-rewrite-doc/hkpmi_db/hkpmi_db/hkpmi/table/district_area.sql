-- hkpmi.district_area definition

-- Drop table

-- DROP TABLE hkpmi.district_area;

CREATE TABLE hkpmi.district_area (
	area_code varchar(2) NOT NULL,
	area_name varchar(100) NOT NULL,
	area_chi varchar(100) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX district_area_idx ON hkpmi.district_area USING btree (area_code);




ALTER TABLE hkpmi.district_area OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
