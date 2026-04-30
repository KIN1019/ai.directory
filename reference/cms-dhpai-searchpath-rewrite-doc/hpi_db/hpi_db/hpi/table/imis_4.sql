-- imis_4 definition

-- Drop table

-- DROP TABLE imis_4;

CREATE TABLE imis_4 (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(6) NOT NULL,
	stat_date varchar(12) NOT NULL,
	transfer_out varchar(24) NOT NULL,
	length_of_stay varchar(24) NOT NULL,
	transfer_within_specialty varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT imis_4_pk PRIMARY KEY (hospital_code, specialty_code, stat_date) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE imis_4 OWNER TO "HPI_SCHEMA_OWNER_ROLE";
