-- hkpmi_linked_case definition

-- Drop table

-- DROP FOREIGN TABLE hkpmi_linked_case;

CREATE FOREIGN TABLE hkpmi_linked_case (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	previous_hospital varchar(6) NOT NULL,
	previous_case varchar(24) NOT NULL,
	create_by varchar(24) NOT NULL,
	create_dtm timestamp NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp NOT NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'hkpmi_linked_case');

ALTER TABLE hkpmi_linked_case OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
