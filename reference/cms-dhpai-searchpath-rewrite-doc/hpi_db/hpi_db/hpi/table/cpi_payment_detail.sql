-- cpi_payment_detail definition

-- Drop table

-- DROP TABLE cpi_payment_detail;

CREATE TABLE cpi_payment_detail (
	transaction_datetime timestamp(6) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NULL,
	case_type varchar(2) NULL,
	receipt_no varchar(24) NULL,
	admission_dtm timestamp(6) NULL,
	pay_code varchar(6) NULL,
	payment_means varchar(10) NULL,
	waiver_no varchar(48) NULL,
	waiver_type varchar(2) NULL,
	waiver_issue_party varchar(8) NULL,
	waiver_eff_date timestamp(6) NULL,
	waiver_exp_date timestamp(6) NULL,
	no_charge_indicator varchar(10) NULL,
	payment_amount int4 NULL,
	paid_amount int4 NULL,
	transaction_type varchar(2) NOT NULL,
	remark varchar(96) NULL,
	update_by varchar(24) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	source_system varchar(16) NOT NULL,
	nep_search_key varchar(40) NULL,
	nep_add_key_1 varchar(40) NULL,
	nep_add_key_2 varchar(40) NULL,
	new_waiver_type varchar(4) NULL,
	upd_sys varchar(20) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_payment_detail_case_idx ON cpi_payment_detail USING btree (case_no, hospital_code, transaction_datetime);
CREATE UNIQUE INDEX cpi_payment_detail_idx ON cpi_payment_detail USING btree (hospital_code, transaction_datetime);
CREATE INDEX cpi_payment_detail_case_idx2 ON cpi_payment_detail USING btree (hospital_code, case_no);




ALTER TABLE cpi_payment_detail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
