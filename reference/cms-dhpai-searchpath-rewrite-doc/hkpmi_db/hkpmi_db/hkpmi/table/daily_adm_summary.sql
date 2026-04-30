-- hkpmi.daily_adm_summary definition

-- Drop table

-- DROP TABLE hkpmi.daily_adm_summary;

CREATE TABLE hkpmi.daily_adm_summary (
	hospital_code varchar(6) NOT NULL,
	report_date timestamp(6) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	age_group int4 NOT NULL,
	ae_attendance int4 NOT NULL,
	ae_admission int4 NOT NULL,
	admission int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX daily_adm_summary_uidx ON hkpmi.daily_adm_summary USING btree (hospital_code, report_date, specialty_code, age_group);




ALTER TABLE hkpmi.daily_adm_summary OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
