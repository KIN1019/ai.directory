-- icd9_table definition

-- Drop table

-- DROP TABLE icd9_table;

CREATE TABLE icd9_table (
	icd9_code varchar(8) NOT NULL,
	description varchar(510) NOT NULL,
	invalid_sex varchar(2) NULL,
	start_age int2 NULL,
	end_age int2 NULL,
	exact_birthday varchar(2) NULL,
	invalid_discharge_code varchar(2) NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKICD9_table" PRIMARY KEY (icd9_code)
);




ALTER TABLE icd9_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
