-- lab_rep_footer definition

-- Drop table

-- DROP TABLE lab_rep_footer;

CREATE TABLE lab_rep_footer (
	hosp_code varchar(10) NOT NULL,
	footer_desc varchar(160) NOT NULL,
	bold_face varchar(2) NOT NULL,
	srn_footer varchar(160) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "LAB_REP_FOOTER_IDX1" ON lab_rep_footer USING btree (hosp_code);




ALTER TABLE lab_rep_footer OWNER TO "HPI_SCHEMA_OWNER_ROLE";
