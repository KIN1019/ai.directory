-- nok definition

-- Drop table

-- DROP FOREIGN TABLE nok;

CREATE FOREIGN TABLE nok (
	patient_key varchar(16) NOT NULL,
	priority int2 NOT NULL,
	major_nok varchar(2) NOT NULL,
	hkid varchar(24) NULL,
	relationship varchar(4) NOT NULL,
	nok_name varchar(96) NOT NULL,
	building varchar(94) NULL,
	room varchar(10) NULL,
	floor varchar(4) NULL,
	block varchar(4) NULL,
	district varchar(10) NULL,
	phone1 varchar(20) NULL,
	phone2 varchar(20) NULL,
	address_indicator varchar(8) NULL,
	mobile_phone varchar(20) NULL,
	sms_language varchar(8) NULL,
	update_hospital varchar(6) NOT NULL,
	update_by varchar(16) NOT NULL,
	source_system_dtm timestamp NOT NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'nok');

ALTER TABLE nok OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
