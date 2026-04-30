-- cpi_movement definition

-- Drop table

-- DROP TABLE cpi_movement;

CREATE TABLE cpi_movement (
	hospital_code varchar(6) NOT NULL,
	case_no varchar(24) NOT NULL,
	movement_count int4 NOT NULL,
	ward_code varchar(8) NULL,
	bed_no varchar(10) NULL,
	specialty varchar(8) NOT NULL,
	ward_class varchar(2) NULL,
	movement_type varchar(2) NOT NULL,
	movement_dtm timestamp(6) NOT NULL,
	treatment_location varchar(8) NULL,
	update_dtm timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL,
	doctor_code varchar(16) NULL,

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL,

	CONSTRAINT "XPKcpi_movement" PRIMARY KEY (hospital_code, case_no, movement_count) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE cpi_movement OWNER TO "HPI_SCHEMA_OWNER_ROLE";
