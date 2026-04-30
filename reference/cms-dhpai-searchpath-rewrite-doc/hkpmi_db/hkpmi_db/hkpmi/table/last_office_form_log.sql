-- hkpmi.last_office_form_log definition

-- Drop table

-- DROP TABLE hkpmi.last_office_form_log;

CREATE TABLE hkpmi.last_office_form_log (
	hospital_code varchar(6) NOT NULL,
	issue_datetime timestamp(6) NOT NULL,
	action_type varchar(2) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_name varchar(96) NOT NULL,
	cccode1 varchar(10) NULL,
	cccode2 varchar(10) NULL,
	cccode3 varchar(10) NULL,
	cccode4 varchar(10) NULL,
	cccode5 varchar(10) NULL,
	cccode6 varchar(10) NULL,
	sex varchar(2) NOT NULL,
	dob timestamp(6) NULL,
	death_datetime timestamp(6) NULL,
	exact_dob_flag varchar(2) NOT NULL,
	last_case_no varchar(24) NULL,
	last_hospital_code varchar(6) NULL,
	last_ward_code varchar(8) NULL,
	body_category varchar(2) NULL,
	source_system varchar(16) NULL,
	update_by varchar(24) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	workstation_id varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	parent_hospital varchar(6) NOT NULL,
	filler bpchar(128) NULL
);
CREATE INDEX last_office_form_log_idx1 ON hkpmi.last_office_form_log USING btree (last_case_no, last_hospital_code);
CREATE UNIQUE INDEX last_office_form_log_index ON hkpmi.last_office_form_log USING btree (hkid, issue_datetime, action_type);




ALTER TABLE hkpmi.last_office_form_log OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
