-- imis_2 definition

-- Drop table

-- DROP TABLE imis_2;

CREATE TABLE imis_2 (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(6) NOT NULL,
	stat_date varchar(12) NOT NULL,
	mortality_rate_24 varchar(24) NOT NULL,
	unplanned_readm_28 varchar(24) NOT NULL,
	transfer_out varchar(24) NOT NULL,
	adm_thru_ae varchar(24) NOT NULL,
	ae_day_adm varchar(24) NOT NULL,
	postneonatal_death varchar(24) NOT NULL,
	available_day_bed varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT imis_2_pk PRIMARY KEY (hospital_code, specialty_code, stat_date) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE imis_2 OWNER TO "HPI_SCHEMA_OWNER_ROLE";
