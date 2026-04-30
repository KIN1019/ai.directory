-- payment_by_status definition

-- Drop table

-- DROP TABLE payment_by_status;

CREATE TABLE payment_by_status (
	case_type varchar(2) NOT NULL,
	pay_code varchar(6) NOT NULL,
	from_age int4 NULL,
	to_age int4 NULL,
	effective_date timestamp(6) NOT NULL,
	expiry_date timestamp(6) NULL,
	payment_amount int4 NOT NULL,
	waiver_enable varchar(2) NULL,
	no_charge_indicator varchar(10) NULL,
	update_dtm timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	partial_payment varchar(2) NULL
);
CREATE UNIQUE INDEX payment_by_status_idx ON payment_by_status USING btree (case_type, pay_code, from_age, effective_date);




ALTER TABLE payment_by_status OWNER TO "HPI_SCHEMA_OWNER_ROLE";
