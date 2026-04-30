-- bcf_log definition

-- Drop table

-- DROP FOREIGN TABLE bcf_log;

CREATE FOREIGN TABLE bcf_log (
	hospital_code varchar(6) NOT NULL,
	hkid varchar(24) NOT NULL,
	system_datetime timestamp NOT NULL,
	body_category varchar(2) NOT NULL,
	mortuary_id int4 NOT NULL,
	update_by varchar(24) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	source_system varchar(10) NOT NULL,
	update_datetime timestamp NOT NULL,
	lof_hkid varchar(24) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'bcf_log');

ALTER TABLE bcf_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
