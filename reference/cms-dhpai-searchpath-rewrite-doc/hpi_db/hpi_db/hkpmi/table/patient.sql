-- patient definition

-- Drop table

-- DROP FOREIGN TABLE patient;

CREATE FOREIGN TABLE patient (
	patient_key varchar(16) NOT NULL,
	religion varchar(6) NULL,
	hkid varchar(24) NOT NULL,
	patient_name varchar(96) NOT NULL,
	sex varchar(2) NOT NULL,
	cccode1 varchar(10) NULL,
	cccode2 varchar(10) NULL,
	cccode3 varchar(10) NULL,
	cccode4 varchar(10) NULL,
	cccode5 varchar(10) NULL,
	cccode6 varchar(10) NULL,
	chi_name varchar(24) NULL,
	dob timestamp NULL,
	exact_dob_flag varchar(2) NOT NULL,
	marital_status varchar(2) NOT NULL,
	race varchar(4) NOT NULL,
	other_doc_no varchar(24) NULL,
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
	death_indicator varchar(8) NULL,
	death_date timestamp NULL,
	death_diagnosis varchar(8) NULL,
	death_external_cause varchar(8) NULL,
	patient_type varchar(6) NULL,
	pcs_count int4 NULL,
	access_code int4 NOT NULL,
	update_hospital varchar(6) NOT NULL,
	source_system varchar(10) NOT NULL,
	update_by varchar(16) NOT NULL,
	source_system_dtm timestamp NOT NULL,
	system_dtm timestamp NOT NULL,
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	filler varchar(30) NULL,
	last_update_datetime timestamp(6) NULL
)
SERVER remote_hkpmi_server
OPTIONS (schema_name 'hkpmi', table_name 'patient');

ALTER TABLE patient OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
