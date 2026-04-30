-- adt_case_adtdb definition

-- Drop table

-- DROP TABLE IF EXISTS adt_case_adtdb;

/*
This "middle" table is created for CPI to HPI schema consolidation, and needs CDC configuration.
*/
CREATE TABLE adt_case_adtdb (
    hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	admission_datetime timestamp NOT NULL,
	source_indicator varchar(2) NULL,
	source_code varchar(6) NULL,
	district_code varchar(10) NULL,
	pay_code varchar(6) NOT NULL,
	discharge_code varchar(2) NULL,
	discharge_datetime timestamp NULL,
	destination_code varchar(6) NULL,
	case_type varchar(2) NOT NULL,
	active_indicator varchar(2) NOT NULL,
	movement_count int4 NOT NULL,
	security_count int4 NOT NULL,
	access_code int4 DEFAULT 0 NOT NULL,
	system_datetime timestamp NOT NULL,
	user_id varchar(16) NOT NULL,
	"timestamp" timestamp NULL,
	t_prk varchar(16) NOT NULL,
	mrt_indicator varchar(2) NULL,
	last_update_datetime timestamp(6) NULL,

	CONSTRAINT XPKCase PRIMARY KEY (hospital_code,case_no)
);

CREATE INDEX XIE1Case ON adt_case_adtdb (active_indicator);
CREATE INDEX XIE2Case ON adt_case_adtdb (t_prk);

ALTER TABLE adt_case_adtdb OWNER TO "HPI_SCHEMA_OWNER_ROLE";
