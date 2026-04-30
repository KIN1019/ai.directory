-- daily_spec_summary definition

-- Drop table

-- DROP TABLE daily_spec_summary;

CREATE TABLE daily_spec_summary (
	hospital_code varchar(6) NOT NULL,
	report_date timestamp(6) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	admission_thru_ae int4 NOT NULL,
	admission int4 NOT NULL,
	ae_day int4 NOT NULL,
	patient_remain int4 NOT NULL,
	bdo int4 NOT NULL,
	vbd int4 NOT NULL,
	bda int4 NOT NULL,
	ebd int4 NOT NULL,
	day_discharge int4 NOT NULL,
	day_death int4 NOT NULL,
	ip_discharge int4 NOT NULL,
	ip_death int4 NOT NULL,
	day_bed int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX daily_spec_summary_index ON daily_spec_summary USING btree (hospital_code, report_date, specialty_code);




ALTER TABLE daily_spec_summary OWNER TO "HPI_SCHEMA_OWNER_ROLE";
