-- hospital definition

-- Drop table

-- DROP FOREIGN TABLE hospital;

CREATE FOREIGN TABLE hospital (
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
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'hospital');

ALTER TABLE hospital OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
