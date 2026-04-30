-- convert_bed definition

-- Drop table

-- DROP TABLE convert_bed;

CREATE TABLE convert_bed (
	hosp_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	cubicle_no varchar(8) NOT NULL,
	bed_no varchar(10) NOT NULL,
	bed_type varchar(2) NOT NULL,
	spec_code varchar(8) NULL,
	iso varchar(4) NULL,
	care varchar(2) NULL,
	service varchar(6) NULL,
	project varchar(4) NULL,
	patient_category varchar(4) NULL,
	active_status varchar(2) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX convert_bed_index ON convert_bed USING btree (hosp_code, ward_code, cubicle_no, bed_no, effective_datetime);




ALTER TABLE convert_bed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
