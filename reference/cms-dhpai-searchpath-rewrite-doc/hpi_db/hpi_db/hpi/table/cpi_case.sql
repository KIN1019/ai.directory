-- cpi_case definition

-- Drop table

-- DROP TABLE cpi_case;

CREATE TABLE cpi_case (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	patient_key varchar(16) NOT NULL,
	case_type varchar(2) NOT NULL,
	admission_dtm timestamp(6) NOT NULL,
	source_indicator varchar(2) NULL,
	source_code varchar(6) NULL,
	patient_type varchar(6) NOT NULL,
	discharge_code varchar(2) NULL,
	discharge_dtm timestamp(6) NULL,
	destination_code varchar(6) NULL,
	last_specialty varchar(8) NULL,
	last_sub_specialty varchar(8) NULL,
	last_ward_code varchar(8) NULL,
	last_ward_class varchar(2) NULL,
	last_bed_no varchar(10) NULL,
	pp_code varchar(16) NULL,
	access_code int4 NULL,
	status_code varchar(4) NOT NULL,
	create_by varchar(24) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	row_update_datetime timestamp(6) NULL,
	movement_count int4 NOT NULL,
	district_code varchar(10) NULL,
	mrt_indicator varchar(2) NULL,
	document_flag varchar(2) NULL

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);
CREATE INDEX cpi_case_discharge_code ON cpi_case USING btree (last_ward_code, discharge_code, case_type);
CREATE INDEX cpi_case_discharge_dtm ON cpi_case USING btree (discharge_dtm, last_ward_code);
CREATE INDEX cpi_case_discharge_specialty ON cpi_case USING btree (discharge_dtm, last_specialty, last_sub_specialty);
CREATE UNIQUE INDEX cpi_case_idx ON cpi_case USING btree (case_no, hospital_code);
CREATE INDEX cpi_case_patient_idx ON cpi_case USING btree (patient_key);



ALTER TABLE cpi_case OWNER TO "HPI_SCHEMA_OWNER_ROLE";
