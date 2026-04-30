-- transaction_log definition

-- Drop table

-- DROP TABLE transaction_log;

CREATE TABLE transaction_log (
	system_dtm timestamp NOT NULL,
	hospital_code varchar(6) NOT NULL,
	"type" varchar(6) NOT NULL,
	adm_dtm timestamp NULL,
	hkid varchar(24) NULL,
	patient_key varchar(16) NULL,
	patient_name varchar(96) NULL,
	sex varchar(2) NULL,
	dob timestamp NULL,
	exact_dob_flag varchar(2) NULL,
	cccode1 varchar(10) NULL,
	cccode2 varchar(10) NULL,
	cccode3 varchar(10) NULL,
	cccode4 varchar(10) NULL,
	cccode5 varchar(10) NULL,
	cccode6 varchar(10) NULL,
	chi_name varchar(24) NULL,
	marital_status varchar(2) NULL,
	race varchar(4) NULL,
	other_doc_no varchar(24) NULL,
	mrn varchar(16) NULL,
	building varchar(94) NULL,
	room varchar(10) NULL,
	floor varchar(4) NULL,
	block varchar(4) NULL,
	district varchar(10) NULL,
	religion varchar(6) NULL,
	phone1 varchar(20) NULL,
	phone2 varchar(20) NULL,
	address_indicator varchar(8) NULL,
	mobile_phone varchar(20) NULL,
	sms_language varchar(8) NULL,
	death_indicator varchar(8) NULL,
	death_date timestamp NULL,
	death_external_cause varchar(8) NULL,
	death_diagnosis varchar(8) NULL,
	pcs_count int4 NULL,
	priority int4 NULL,
	major_nok varchar(2) NULL,
	nok_name varchar(96) NULL,
	nok_hkid varchar(24) NULL,
	nok_relationship varchar(4) NULL,
	nok_building varchar(94) NULL,
	nok_room varchar(10) NULL,
	nok_floor varchar(4) NULL,
	nok_block varchar(4) NULL,
	nok_district varchar(10) NULL,
	nok_phone1 varchar(20) NULL,
	nok_phone2 varchar(20) NULL,
	nok_address_indicator varchar(8) NULL,
	nok_mobile_phone varchar(20) NULL,
	nok_sms_language varchar(8) NULL,
	case_no varchar(24) NULL,
	source_indicator varchar(2) NULL,
	source_code varchar(6) NULL,
	patient_type varchar(6) NULL,
	discharge_code varchar(2) NULL,
	destination_code varchar(10) NULL,
	case_type varchar(2) NULL,
	security_count int4 NULL,
	case_access_code int4 NULL,
	pmi_access_code int4 NULL,
	ambulance_no varchar(8) NULL,
	police_case varchar(2) NULL,
	labour_case varchar(2) NULL,
	ae_case_type varchar(2) NULL,
	dba varchar(2) NULL,
	ward_code varchar(8) NULL,
	specialty_code varchar(8) NULL,
	bed_no varchar(10) NULL,
	ward_class varchar(2) NULL,
	old_patient_key varchar(16) NULL,
	old_patient_name varchar(96) NULL,
	old_hkid varchar(24) NULL,
	old_sex varchar(2) NULL,
	old_dob timestamp NULL,
	old_ward_class varchar(2) NULL,
	old_ward_code varchar(8) NULL,
	old_specialty_code varchar(8) NULL,
	old_bed_no varchar(10) NULL,
	pp_code varchar(16) NULL,
	update_by varchar(24) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	source_system varchar(10) NOT NULL,
	source_system_dtm timestamp NOT NULL,
	upload_status varchar(2) NOT NULL,
	filler varchar(30) NULL, --filler length is aligned with Sybase, no double
	row_update_datetime timestamp(6) DEFAULT CURRENT_TIMESTAMP NULL,
	doctor_code varchar(16) NULL,
	mrt_indicator varchar(2) NULL,
	transfer_dtm timestamp NULL,
	discharge_dtm timestamp NULL,
	last_update_datetime timestamp(6) NULL
)PARTITION BY RANGE (system_dtm);

CREATE UNIQUE INDEX "XPKtransaction_log" ON transaction_log USING btree (hospital_code, system_dtm);
CREATE UNIQUE INDEX "XAK1transaction_log" ON transaction_log USING btree (system_dtm, hospital_code);
CREATE INDEX "XIE1transaction_log" ON transaction_log USING btree (upload_status, system_dtm);

-- Create new index on hospital_code, case_no, system_dtm as requested by AEIS Sing to poll this table in PG to replace Sybase table replication (20-Aug-2025 Max's email)
CREATE INDEX "transaction_log_idx2" ON transaction_log USING btree (hospital_code, case_no, system_dtm);
-- Create new index on patient_key as discussed for future usage in CMS
CREATE INDEX "transaction_log_idx3" ON transaction_log USING btree (patient_key, system_dtm);

-- Partition this big table with 300 million records in PRD as requested by Charis, Jennifer and Rainey (16-Aug-2025 Jeffery's email)
-- However, RCDB would have plan to archive data regularly and keep recent 2 years data online, so there should be no need to do partition
CREATE TABLE transaction_log_default PARTITION OF transaction_log DEFAULT;
CREATE TABLE transaction_log_2023 PARTITION OF transaction_log FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE transaction_log_2024 PARTITION OF transaction_log FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE transaction_log_2025 PARTITION OF transaction_log FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE transaction_log_2026 PARTITION OF transaction_log FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE transaction_log_2027 PARTITION OF transaction_log FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
CREATE TABLE transaction_log_2028 PARTITION OF transaction_log FOR VALUES FROM ('2028-01-01') TO ('2029-01-01');

ALTER TABLE transaction_log OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
