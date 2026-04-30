-- ward_list definition

-- Drop table

-- DROP TABLE ward_list;

CREATE TABLE ward_list (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	ward_code varchar(8) NOT NULL,
	bed_no varchar(10) NULL,
	specialty_code varchar(8) NOT NULL,
	row_update_datetime timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XIE1Ward_list" ON ward_list USING btree (hospital_code, case_no);
CREATE INDEX "XPKWard_list" ON ward_list USING btree (hospital_code, ward_code, bed_no);
CREATE INDEX cpi_ward_list_specialty_idx ON ward_list USING btree (hospital_code, specialty_code);



ALTER TABLE ward_list OWNER TO "HPI_SCHEMA_OWNER_ROLE";
