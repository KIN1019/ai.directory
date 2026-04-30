-- patient_detail_1 definition

-- Drop table

-- DROP FOREIGN TABLE patient_detail_1;

CREATE FOREIGN TABLE patient_detail_1 (
	patient_key varchar(16) NOT NULL,
	hosp_byte_1 int4 NOT NULL,
	hosp_byte_2 int4 NOT NULL,
	hosp_byte_3 int4 NOT NULL,
	update_by varchar(16) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	source_system varchar(10) NOT NULL,
	system_dtm timestamp NOT NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'patient_detail_1');

ALTER TABLE patient_detail_1 OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
