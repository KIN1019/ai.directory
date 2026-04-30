-- imis_3 definition

-- Drop table

-- DROP TABLE imis_3;

CREATE TABLE imis_3 (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(6) NOT NULL,
	stat_date varchar(12) NOT NULL,
	age_0_to_4 varchar(24) NOT NULL,
	age_5_to_9 varchar(24) NOT NULL,
	age_10_to_14 varchar(24) NOT NULL,
	age_15_to_19 varchar(24) NOT NULL,
	age_20_to_24 varchar(24) NOT NULL,
	age_25_to_29 varchar(24) NOT NULL,
	age_30_to_34 varchar(24) NOT NULL,
	age_35_to_39 varchar(24) NOT NULL,
	age_40_to_44 varchar(24) NOT NULL,
	age_45_to_49 varchar(24) NOT NULL,
	age_50_to_54 varchar(24) NOT NULL,
	age_55_to_59 varchar(24) NOT NULL,
	age_60_to_64 varchar(24) NOT NULL,
	age_65_to_69 varchar(24) NOT NULL,
	age_70_to_74 varchar(24) NOT NULL,
	age_75_to_79 varchar(24) NOT NULL,
	age_80_to_84 varchar(24) NOT NULL,
	age_85_and_over varchar(24) NOT NULL,
	age_unknown varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT imis_3_pk PRIMARY KEY (hospital_code, specialty_code, stat_date) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE imis_3 OWNER TO "HPI_SCHEMA_OWNER_ROLE";
