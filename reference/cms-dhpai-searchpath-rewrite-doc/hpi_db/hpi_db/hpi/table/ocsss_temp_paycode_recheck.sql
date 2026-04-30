-- ocsss_temp_paycode_recheck definition

-- Drop table

-- DROP TABLE ocsss_temp_paycode_recheck;

CREATE TABLE ocsss_temp_paycode_recheck (
	transaction_datetime timestamp(6) NOT NULL,
	hospital varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	appt_seq int4 NOT NULL,
	receipt_no int4 NOT NULL,
	original_paycode varchar(6) NOT NULL,
	charging_amount numeric(19, 4) NOT NULL,
	pay_amount numeric(19, 4) NOT NULL,
	hkid varchar(24) NOT NULL,
	hkic_symbol varchar(2) NULL,
	last_document_type varchar(10) NULL,
	ocsss_recheck_time varchar(34) NULL,
	ocsss_recheck_result varchar(2) NULL,
	pas_recheck_return_code int4 NULL,
	pas_recheck_return_msg varchar(510) NULL,
	result_paycode varchar(6) NULL,
	result_generic_status varchar(6) NULL,
	result_pay_amount numeric(19, 4) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX idx_ocsss_t_paycode_recheck ON ocsss_temp_paycode_recheck USING btree (transaction_datetime, hospital, case_no);
CREATE INDEX idx_ocsss_t_paycode_recheck1 ON ocsss_temp_paycode_recheck USING btree (case_no, hospital);




ALTER TABLE ocsss_temp_paycode_recheck OWNER TO "HPI_SCHEMA_OWNER_ROLE";
