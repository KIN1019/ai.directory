-- ward definition

-- Drop table

-- DROP TABLE ward;

CREATE TABLE ward (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	description varchar(60) NOT NULL,
	treatment_location varchar(8) NULL,
	"location" varchar(40) NULL,
	active_status varchar(2) NULL,
	effective_date timestamp(6) NOT NULL,
	user_define varchar(2) NOT NULL,
	care_category varchar(2) NULL,
	default_specialty varchar(8) NULL,
	wristband_no int4 NULL,
	isolation_type varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ward_idx ON ward USING btree (hospital_code, ward_code, effective_date);




ALTER TABLE ward OWNER TO "HPI_SCHEMA_OWNER_ROLE";
