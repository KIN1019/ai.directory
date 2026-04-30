-- eh_transaction definition

-- Drop table

-- DROP TABLE eh_transaction;

CREATE TABLE eh_transaction (
	hospital_code varchar(6) NOT NULL,
	transaction_datetime timestamp(6) NOT NULL,
	transaction_type varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	ward_code varchar(8) NOT NULL,
	spec_code varchar(8) NOT NULL,
	eh_code varchar(16) NOT NULL,
	eh_cgat varchar(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX eh_transaction_index ON eh_transaction USING btree (hospital_code, transaction_datetime, transaction_type, case_no);




ALTER TABLE eh_transaction OWNER TO "HPI_SCHEMA_OWNER_ROLE";
