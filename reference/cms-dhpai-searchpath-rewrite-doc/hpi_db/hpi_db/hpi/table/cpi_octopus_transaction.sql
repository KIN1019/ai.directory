-- cpi_octopus_transaction definition

-- Drop table

-- DROP TABLE cpi_octopus_transaction;

CREATE TABLE cpi_octopus_transaction (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	transaction_datetime timestamp(6) NOT NULL,
	term_id varchar(40) NULL,
	card_no varchar(40) NULL,
	paid_amount int4 NULL,
	remain_balance numeric(10, 2) NULL,
	update_by varchar(24) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	usage_data varchar(64) NULL,
	transaction_status varchar(2) NULL,
	error_code int4 NULL,
	last_add_value_date timestamp(6) NULL,
	last_add_value_type varchar(4) NULL,
	last_add_value_device_id varchar(12) NULL,
	octopus_type int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_octopus_trans_idx ON cpi_octopus_transaction USING btree (case_no, hospital_code, transaction_datetime);
CREATE UNIQUE INDEX cpi_octopus_transaction_idx ON cpi_octopus_transaction USING btree (hospital_code, transaction_datetime);




ALTER TABLE cpi_octopus_transaction OWNER TO "HPI_SCHEMA_OWNER_ROLE";
