-- diagnosis definition

-- Drop table

-- DROP TABLE diagnosis;

CREATE TABLE diagnosis (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	diagnosis_type varchar(4) NOT NULL,
	diagnosis_text varchar(200) NULL,
	system_datetime timestamp(6) NOT NULL,
	user_id varchar(16) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKDiagnosis" PRIMARY KEY (hospital_code, case_no, diagnosis_type) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE diagnosis OWNER TO "HPI_SCHEMA_OWNER_ROLE";
