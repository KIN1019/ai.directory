-- borrowers definition

-- Drop table

-- DROP TABLE borrowers;

CREATE TABLE borrowers (
	borrowers_id varchar(30) NOT NULL,
	hospital_cde varchar(6) NOT NULL,
	borrower_type varchar(2) NOT NULL,
	borrower_title varchar(20) NOT NULL,
	borrower_name varchar(80) NULL,
	ward_code varchar(8) NOT NULL,
	specialty varchar(8) NULL,
	borrower_status varchar(6) NOT NULL,
	first_rmd_period int4 NOT NULL,
	second_rmd_period int4 NOT NULL,
	section_head varchar(30) NULL,
	tel_no varchar(24) NULL,
	cut_off_date timestamp(6) NULL,
	def_reason varchar(6) NULL,
	row_update_datetime timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "BORROWERS_IDX1" ON borrowers USING btree (borrowers_id, hospital_cde);



ALTER TABLE borrowers OWNER TO "HPI_SCHEMA_OWNER_ROLE";
