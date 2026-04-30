-- isolation_case_code_table definition

-- Drop table

-- DROP TABLE isolation_case_code_table;

CREATE TABLE isolation_case_code_table (
	iso_type varchar(100) NOT NULL,
	iso_code varchar(4) NOT NULL,
	code_description varchar(510) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKisolation_case_code_table" ON isolation_case_code_table USING btree (iso_type, iso_code);




ALTER TABLE isolation_case_code_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
