-- mother_baby_case definition

-- Drop table

-- DROP TABLE mother_baby_case;

CREATE TABLE mother_baby_case (
	mother_hospital_code varchar(6) NOT NULL,
	mother_case_no varchar(24) NOT NULL,
	baby_hospital_code varchar(6) NOT NULL,
	baby_case_no varchar(24) NULL,
	birth_order int4 NOT NULL,
	pregnancy_number int4 NOT NULL,
	birth_place varchar(2) NULL,
	birth_location varchar(6) NULL,
	mother_hospital_2 varchar(6) NULL,
	mother_case_2 varchar(24) NULL,
	mother_hospital_hn varchar(6) NULL,
	mother_case_hn varchar(24) NULL,
	baby_hospital_2 varchar(6) NULL,
	baby_case_2 varchar(24) NULL,
	baby_hospital_hn varchar(6) NULL,
	baby_case_hn varchar(24) NULL,
	create_by varchar(24) NOT NULL,
	create_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	active_status varchar(2) NULL
);
CREATE UNIQUE INDEX mother_baby_case_idx ON mother_baby_case USING btree (mother_hospital_code, mother_case_no, baby_hospital_code, baby_case_no);
CREATE UNIQUE INDEX mother_baby_case_idx2 ON mother_baby_case USING btree (baby_hospital_code, baby_case_no, mother_hospital_code, mother_case_no);
CREATE INDEX mother_baby_case_idx3 ON mother_baby_case USING btree (mother_hospital_2, mother_case_2);
CREATE INDEX mother_baby_case_idx4 ON mother_baby_case USING btree (mother_hospital_hn, mother_case_hn);
CREATE INDEX mother_baby_case_idx5 ON mother_baby_case USING btree (baby_hospital_2, baby_case_2);
CREATE INDEX mother_baby_case_idx6 ON mother_baby_case USING btree (baby_hospital_hn, baby_case_hn);




ALTER TABLE mother_baby_case OWNER TO "HPI_SCHEMA_OWNER_ROLE";
