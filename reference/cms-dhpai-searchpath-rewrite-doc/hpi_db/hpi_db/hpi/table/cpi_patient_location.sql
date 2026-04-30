-- cpi_patient_location definition

-- Drop table

-- DROP TABLE cpi_patient_location;

CREATE TABLE cpi_patient_location (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	patient_key varchar(16) NOT NULL,
	patient_name varchar(96) NOT NULL,
	name_soundex varchar(8) NOT NULL,
	name_phonetic varchar(96) NOT NULL,
	sex varchar(2) NOT NULL,
	dob timestamp(6) NULL,
	chinese_name varchar(24) NULL,
	phone1 varchar(20) NULL,
	phone2 varchar(20) NULL,
	mobile_phone varchar(20) NULL,
	row_update_datetime timestamp(6) NULL,
	cccode1 varchar(10) NULL,
	cccode2 varchar(10) NULL,
	cccode3 varchar(10) NULL,
	cccode4 varchar(10) NULL,
	cccode5 varchar(10) NULL,
	cccode6 varchar(10) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_patient_loc_ccc ON cpi_patient_location USING btree (cccode1, cccode2, cccode3);
CREATE INDEX cpi_patient_loc_hphone_idx ON cpi_patient_location USING btree (phone1);
CREATE INDEX cpi_patient_loc_key_idx ON cpi_patient_location USING btree (patient_name, sex, dob);
CREATE INDEX cpi_patient_loc_nphonetic_idx ON cpi_patient_location USING btree (name_phonetic);
CREATE INDEX cpi_patient_loc_nsoundex_idx ON cpi_patient_location USING btree (name_soundex);
CREATE INDEX cpi_patient_loc_ophone1_idx ON cpi_patient_location USING btree (phone2);
CREATE INDEX cpi_patient_loc_ophone2_idx ON cpi_patient_location USING btree (mobile_phone);
CREATE UNIQUE INDEX cpi_patient_location_idx ON cpi_patient_location USING btree (hospital_code, case_no);



ALTER TABLE cpi_patient_location OWNER TO "HPI_SCHEMA_OWNER_ROLE";
