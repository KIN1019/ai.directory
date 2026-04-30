-- hkpmi.address_detail2 definition

-- Drop table

-- DROP TABLE hkpmi.address_detail2;

CREATE TABLE hkpmi.address_detail2 (
	record_id int4 NOT NULL,
	police_key int4 NULL,
	external_key varchar(40) NULL,
	csu_id varchar(38) NULL,
	geo_x int4 NULL,
	geo_y int4 NULL,
	category varchar(20) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX address_detail2_idx ON hkpmi.address_detail2 USING btree (record_id);




ALTER TABLE hkpmi.address_detail2 OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
