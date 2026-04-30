-- lab_code definition

-- Drop table

-- DROP TABLE lab_code;

CREATE TABLE lab_code (
	lab_cde varchar(4) NOT NULL,
	lab_name varchar(20) NOT NULL,
	lab_delphic_code varchar(4) NOT NULL,
	front_end_order int2 NOT NULL,
	front_end_desc varchar(30) NOT NULL,
	lab_enable varchar(2) NOT NULL,
	lab_rept_title varchar(100) NOT NULL,
	lab_footer_abbr varchar(2) NULL,
	lab_scr_dump varchar(2) NOT NULL,
	lab_type varchar(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "LAB_CODE_IDX1" ON lab_code USING btree (lab_cde);




ALTER TABLE lab_code OWNER TO "HPI_SCHEMA_OWNER_ROLE";
