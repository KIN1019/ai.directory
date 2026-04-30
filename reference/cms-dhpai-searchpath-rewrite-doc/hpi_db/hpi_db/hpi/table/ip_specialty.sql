-- ip_specialty definition

-- Drop table

-- DROP TABLE ip_specialty;

CREATE TABLE ip_specialty (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	description varchar(30) NOT NULL,
	treatment_location varchar(8) NULL,
	imis_code varchar(6) NOT NULL,
	from_age int4 NULL,
	to_age int4 NULL,
	sex varchar(2) NULL,
	security_count int4 NOT NULL,
	active_status varchar(2) NULL,
	effective_date timestamp(6) NOT NULL,
	user_define varchar(2) NOT NULL,
	treatment_flag varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ip_specialty_idx ON ip_specialty USING btree (hospital_code, specialty_code, effective_date);




ALTER TABLE ip_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
