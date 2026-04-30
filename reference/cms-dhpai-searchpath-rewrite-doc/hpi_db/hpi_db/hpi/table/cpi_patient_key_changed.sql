-- cpi_patient_key_changed definition

-- Drop table

-- DROP TABLE cpi_patient_key_changed;

CREATE TABLE cpi_patient_key_changed (
	patient_key varchar(16) NOT NULL,
	hkid varchar(24) NOT NULL,
	patient_name varchar(96) NOT NULL,
	sex varchar(2) NOT NULL,
	cccode1 varchar(10) NULL,
	cccode2 varchar(10) NULL,
	cccode3 varchar(10) NULL,
	cccode4 varchar(10) NULL,
	cccode5 varchar(10) NULL,
	cccode6 varchar(10) NULL,
	chi_name varchar(24) NULL,
	dob timestamp(6) NULL,
	original_hkid varchar(24) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_patient_kc_hkid_idx ON cpi_patient_key_changed USING btree (hkid);
CREATE UNIQUE INDEX cpi_patient_kc_idx ON cpi_patient_key_changed USING btree (patient_key, original_hkid, update_dtm);
CREATE INDEX cpi_patient_kc_name_idx ON cpi_patient_key_changed USING btree (patient_name);
CREATE INDEX cpi_patient_kc_updtm_idx ON cpi_patient_key_changed USING btree (update_dtm);

ALTER TABLE cpi_patient_key_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
