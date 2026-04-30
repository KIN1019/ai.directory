-- hkpmi.other_source definition

-- Drop table

-- DROP TABLE hkpmi.other_source;

CREATE TABLE hkpmi.other_source (
	source_code varchar(6) NOT NULL,
	source_name varchar(180) NOT NULL,
	chinese_name varchar(120) NULL,
	short_name varchar(40) NULL,
	cluster_source varchar(2) NULL,
	shift_factor int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKosource" ON hkpmi.other_source USING btree (source_code);




ALTER TABLE hkpmi.other_source OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
