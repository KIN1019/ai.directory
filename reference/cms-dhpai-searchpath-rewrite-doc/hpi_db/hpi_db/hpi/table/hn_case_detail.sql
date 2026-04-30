-- hn_case_detail definition

-- Drop table

-- DROP TABLE hn_case_detail;

CREATE TABLE hn_case_detail (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	internal_icd9_code varchar(8) NULL,
	external_icd9_code varchar(8) NULL,
	pp_code varchar(16) NULL,
	eh_code varchar(16) NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKHN_case_detail" PRIMARY KEY (hospital_code, case_no) DEFERRABLE INITIALLY DEFERRED
);

ALTER TABLE hn_case_detail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
