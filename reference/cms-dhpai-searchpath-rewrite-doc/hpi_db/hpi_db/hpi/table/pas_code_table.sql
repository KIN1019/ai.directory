-- pas_code_table definition

-- Drop table

-- DROP TABLE pas_code_table;

CREATE TABLE pas_code_table (
	code_type varchar(40) NOT NULL,
	code_name varchar(40) NOT NULL,
	code_field varchar(40) NULL,
	code_text_1 varchar(160) NULL,
	code_text_2 varchar(160) NULL,
	code_text_3 varchar(160) NULL,
	code_int int4 NULL,
	code_desc varchar(510) NULL,
	code_hosp varchar(6) NULL,
	code_dtm timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPK_pas_code_table" ON pas_code_table USING btree (code_type, code_name, code_field, code_text_1, code_text_2, code_text_3, code_int, code_hosp);




ALTER TABLE pas_code_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
