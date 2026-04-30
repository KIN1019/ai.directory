-- hkpmi_patient_cvi_dose_info definition

-- Drop table

-- DROP TABLE hkpmi_patient_cvi_dose_info;

CREATE TABLE hkpmi_patient_cvi_dose_info (
	source_system varchar(10) NOT NULL,
	patient_key varchar(16) NOT NULL,
	vac_record_key varchar(60) NOT NULL,
	dose_order varchar(60) NOT NULL,
	vaccine_brand varchar(100) NOT NULL,
	dose_date timestamp NOT NULL,
	vac_center varchar(100) NULL,
	vac_admin_premises varchar(400) NULL,
	paper_name_eng varchar(400) NULL,
	vaccine_trade_name_eng varchar(400) NULL,
	paper_name_chi varchar(510) NULL,
	create_datetime timestamp NOT NULL,
	update_datetime timestamp NOT NULL
);

CREATE UNIQUE INDEX hkpmi_patient_cvi_dose_idx ON hkpmi_patient_cvi_dose_info USING btree (patient_key, vac_record_key, vaccine_brand, dose_date, dose_order);
CREATE INDEX hkpmi_patient_cvi_record_pk_do_idx ON hkpmi_patient_cvi_dose_info USING btree (patient_key);

ALTER TABLE hkpmi_patient_cvi_dose_info OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
