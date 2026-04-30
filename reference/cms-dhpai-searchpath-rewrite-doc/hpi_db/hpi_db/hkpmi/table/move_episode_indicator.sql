-- move_episode_indicator definition

-- Drop table

-- DROP FOREIGN TABLE move_episode_indicator;

CREATE FOREIGN TABLE move_episode_indicator (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	from_patient_key varchar(16) NULL,
	to_patient_key varchar(16) NULL,
	create_user varchar(24) NULL,
	create_system varchar(10) NULL,
	move_status varchar(2) NULL,
	update_dtm timestamp(6) NULL,
	update_user varchar(24) NULL,
	update_system varchar(10) NULL,
	info_source_code varchar(2) NULL,
	reason_code varchar(2) NULL,
	other_reason varchar(510) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'move_episode_indicator');

ALTER TABLE move_episode_indicator OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";