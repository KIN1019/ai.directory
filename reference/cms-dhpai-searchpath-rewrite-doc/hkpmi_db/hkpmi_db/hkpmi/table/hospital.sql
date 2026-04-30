-- hkpmi.hospital definition

-- Drop table

-- DROP TABLE hkpmi.hospital;

CREATE TABLE hkpmi.hospital (
	hospital_code varchar(6) NOT NULL,
	hospital_name varchar(180) NOT NULL,
	chinese_name varchar(120) NULL,
	short_name varchar(40) NULL,
	cluster_hospital varchar(2) NOT NULL,
	shift_factor int4 NOT NULL,
	byte_value_1 int4 NULL,
	byte_value_2 int4 NULL,
	byte_value_3 int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKhospital" ON hkpmi.hospital USING btree (hospital_code);




ALTER TABLE hkpmi.hospital OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
