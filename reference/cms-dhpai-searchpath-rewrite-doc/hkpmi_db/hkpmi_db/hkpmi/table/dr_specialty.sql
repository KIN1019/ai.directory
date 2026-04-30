-- hkpmi.dr_specialty definition

-- Drop table

-- DROP TABLE hkpmi.dr_specialty;

CREATE TABLE hkpmi.dr_specialty (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	description varchar(60) NOT NULL,
	"location" varchar(8) NOT NULL,
	imis_code varchar(6) NOT NULL,
	from_age varchar(16) NOT NULL,
	to_age varchar(16) NOT NULL,
	sex varchar(2) NOT NULL,
	security_count varchar(16) NOT NULL,
	active_status varchar(2) NOT NULL,
	effective_date varchar(16) NOT NULL,
	user_define varchar(2) NOT NULL,
	treatment_flag varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "dr_spec_XPK" ON hkpmi.dr_specialty USING btree (hospital_code, specialty_code, effective_date);
CREATE INDEX dr_spec_idx ON hkpmi.dr_specialty USING btree (hospital_code, imis_code);




ALTER TABLE hkpmi.dr_specialty OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
