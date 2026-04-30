-- cpi_case_key_changed definition

-- Drop table

-- DROP TABLE cpi_case_key_changed;

CREATE TABLE cpi_case_key_changed (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	hkid varchar(24) NOT NULL,
	admission_dtm timestamp(6) NULL,
	patient_type varchar(6) NULL,
	discharge_code varchar(2) NULL,
	discharge_dtm timestamp(6) NULL,
	destination_code varchar(6) NULL,
	last_specialty varchar(8) NULL,
	last_sub_specialty varchar(8) NULL,
	last_ward_code varchar(8) NULL,
	last_ward_class varchar(2) NULL,
	last_bed_no varchar(10) NULL,
	status_code varchar(4) NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NULL

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_case_kc_idx ON cpi_case_key_changed USING btree (case_no, hospital_code, update_dtm);



ALTER TABLE cpi_case_key_changed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
