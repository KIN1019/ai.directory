-- hkpmi_uid_table definition

-- Drop table

-- DROP FOREIGN TABLE hkpmi_uid_table;

CREATE FOREIGN TABLE hkpmi_uid_table (
	uid_hkid varchar(24) NOT NULL,
	link_hkid varchar(24) NOT NULL,
	link_status varchar(4) NOT NULL,
	create_dtm timestamp NOT NULL,
	create_hospital varchar(6) NOT NULL,
	create_user varchar(24) NOT NULL,
	create_system varchar(10) NOT NULL,
	update_dtm timestamp NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_user varchar(24) NOT NULL,
	update_system varchar(10) NOT NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'hkpmi_uid_table');

ALTER TABLE hkpmi_uid_table OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
