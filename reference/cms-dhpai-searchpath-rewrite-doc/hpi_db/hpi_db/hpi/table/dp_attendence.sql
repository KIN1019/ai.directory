-- dp_attendence definition

-- Drop table

-- DROP TABLE dp_attendence;

CREATE TABLE dp_attendence (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	attent_datetime timestamp(6) NOT NULL,
	leave_datetime timestamp(6) NULL,
	system_datetime timestamp(6) NOT NULL,
	user_id varchar(16) NOT NULL,
	row_update_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKDP" PRIMARY KEY (hospital_code, case_no, attent_datetime) DEFERRABLE INITIALLY DEFERRED
);



ALTER TABLE dp_attendence OWNER TO "HPI_SCHEMA_OWNER_ROLE";
