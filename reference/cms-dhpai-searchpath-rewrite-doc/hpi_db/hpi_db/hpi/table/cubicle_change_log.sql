-- cubicle_change_log definition

-- Drop table

-- DROP TABLE cubicle_change_log;

CREATE TABLE cubicle_change_log (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	cubicle_no varchar(8) NOT NULL,
	effective_date timestamp(6) NOT NULL,
	active_status varchar(2) NULL,
	description varchar(96) NULL,
	isolation_facilities varchar(4) NULL,
	project_category varchar(2) NULL,
	sex varchar(2) NULL,
	treatment_location varchar(8) NULL,
	update_datetime timestamp(6) NULL,
	update_by varchar(24) NULL,
	source_system varchar(10) NULL,
	patient_category varchar(10) NULL,
	cubicle_service varchar(6) NULL,
	official_bed int4 NULL,
	day_bed int4 NULL,
	facility_type varchar(4) NULL,
	ante_room varchar(2) NULL,
	ensuite_toilet varchar(2) NULL,
	old_active_status varchar(2) NULL,
	old_description varchar(96) NULL,
	old_isolation_facilities varchar(4) NULL,
	old_project_category varchar(2) NULL,
	old_sex varchar(2) NULL,
	old_treatment_location varchar(8) NULL,
	old_update_datetime timestamp(6) NULL,
	old_update_by varchar(24) NULL,
	old_source_system varchar(10) NULL,
	old_patient_category varchar(10) NULL,
	old_cubicle_service varchar(6) NULL,
	old_official_bed int4 NULL,
	old_day_bed int4 NULL,
	old_facility_type varchar(4) NULL,
	old_ante_room varchar(2) NULL,
	old_ensuite_toilet varchar(2) NULL,
	"action" varchar(2) NULL,
	sent varchar(2) NULL
);
CREATE INDEX "cubicle_change_log_IDX1" ON cubicle_change_log USING btree (old_update_datetime);
CREATE UNIQUE INDEX "cubicle_change_log_XPK" ON cubicle_change_log USING btree (hospital_code, ward_code, cubicle_no, effective_date, update_datetime, "action");

ALTER TABLE cubicle_change_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
