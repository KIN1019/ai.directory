-- cubicle definition

-- Drop table

-- DROP TABLE cubicle;

CREATE TABLE cubicle (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	cubicle_no varchar(8) NOT NULL,
	effective_date timestamp(6) NOT NULL,
	active_status varchar(2) NULL,
	description varchar(96) NULL,
	isolation_facilities varchar(4) NULL,
	project_category varchar(4) NULL,
	care_category varchar(2) NULL,
	sex varchar(2) NULL,
	treatment_location varchar(8) NULL,
	update_datetime timestamp(6) NULL,
	update_by varchar(24) NULL,
	source_system varchar(10) NULL,
	patient_category varchar(10) NULL,
	cubicle_service varchar(6) NULL,
	official_bed int4 NULL,
	day_bed int4 NULL,
	--isolation_status varchar(20) NULL,
	facility_type varchar(2) NULL,
	ante_room varchar(2) NULL,
	ensuite_toilet varchar(2) NULL
);
CREATE UNIQUE INDEX cubicle_index ON cubicle USING btree (cubicle_no, hospital_code, ward_code, effective_date);




ALTER TABLE cubicle OWNER TO "HPI_SCHEMA_OWNER_ROLE";
