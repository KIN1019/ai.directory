-- hkpmi.new_born definition

-- Drop table

-- DROP TABLE hkpmi.new_born;

CREATE TABLE hkpmi.new_born (
	mother_patient_key varchar(16) NOT NULL,
	new_born_patient_key varchar(16) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	mother_case_no varchar(24) NOT NULL,
	birth_order int4 NOT NULL,
	pregnancy_number int4 NOT NULL,
	create_by varchar(24) NOT NULL,
	create_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX new_born_idx1 ON hkpmi.new_born USING btree (mother_patient_key, new_born_patient_key, hospital_code);
CREATE UNIQUE INDEX new_born_idx2 ON hkpmi.new_born USING btree (new_born_patient_key, mother_patient_key, hospital_code);




ALTER TABLE hkpmi.new_born OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
