-- system_permit definition

-- Drop table

-- DROP FOREIGN TABLE system_permit;

CREATE FOREIGN TABLE system_permit (
	source_system varchar(10) NOT NULL,
	func_name varchar(90) NOT NULL,
	update_by varchar(16) NOT NULL,
	system_dtm timestamp NOT NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'system_permit');

ALTER TABLE system_permit OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
