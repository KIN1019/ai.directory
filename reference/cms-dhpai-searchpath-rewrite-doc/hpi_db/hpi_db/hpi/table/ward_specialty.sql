-- ward_specialty definition

-- Drop table

-- DROP TABLE ward_specialty;

CREATE TABLE ward_specialty (
	hospital_code varchar(6) NOT NULL,
	effective_date timestamp(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	official_bed int4 NOT NULL,
	day_bed int4 NOT NULL,
	close_date timestamp(6) NULL,
	system_datetime timestamp(6) NOT NULL,
	user_id varchar(16) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKWard_Specialty" PRIMARY KEY (hospital_code, effective_date, ward_code, specialty_code) DEFERRABLE INITIALLY DEFERRED
);
CREATE UNIQUE INDEX "XIE1Ward_Specialty" ON ward_specialty USING btree (hospital_code, ward_code, specialty_code, effective_date);




ALTER TABLE ward_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
