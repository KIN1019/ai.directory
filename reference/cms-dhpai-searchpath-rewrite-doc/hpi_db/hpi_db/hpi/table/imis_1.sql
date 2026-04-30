-- imis_1 definition

-- Drop table

-- DROP TABLE imis_1;

CREATE TABLE imis_1 (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(6) NOT NULL,
	stat_date varchar(12) NOT NULL,
	inpatient_discharge varchar(24) NOT NULL,
	inpatient_death varchar(24) NOT NULL,
	daypatient_discharge varchar(24) NOT NULL,
	daypatient_death varchar(24) NOT NULL,
	available_bed_day varchar(24) NOT NULL,
	occupied_bed_day varchar(24) NOT NULL,
	excess_bed_day varchar(24) NOT NULL,
	discharge_to_conv_bed varchar(24) NOT NULL,
	discharge_to_acute_bed varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT imis_1_pk PRIMARY KEY (hospital_code, specialty_code, stat_date) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE imis_1 OWNER TO "HPI_SCHEMA_OWNER_ROLE";
