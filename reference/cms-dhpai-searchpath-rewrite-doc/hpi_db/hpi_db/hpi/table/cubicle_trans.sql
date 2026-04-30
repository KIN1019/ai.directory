-- cubicle_trans definition

-- Drop table

-- DROP TABLE cubicle_trans;

CREATE TABLE cubicle_trans (
	host varchar(60) NOT NULL,
	seq int4 NOT NULL,
	exec_datetime timestamp(6) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NULL,
	cubicle_no varchar(8) NULL,
	effective_date timestamp(6) NULL,
	active_status varchar(2) NULL,
	description varchar(96) NULL,
	isolation_facilities varchar(6) NULL,
	project_category varchar(4) NULL,
	care_category varchar(2) NULL,
	sex varchar(2) NULL,
	treatment_location varchar(8) NULL,
	update_by varchar(24) NULL,
	update_datetime timestamp(6) NULL,
	source_system varchar(10) NULL,
	patient_category varchar(10) NULL,
	cubicle_service varchar(6) NULL,
	official_bed int4 NULL,
	day_bed int4 NULL,
	old_ward varchar(8) NULL,
	old_cubicle varchar(8) NULL,
	old_effective timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX cubicle_trans_idx ON cubicle_trans USING btree (hospital_code, ward_code, cubicle_no, effective_date, exec_datetime, host);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX cubicle_trans_ui ON cubicle_trans USING btree (host, seq, exec_datetime, hospital_code, ward_code, cubicle_no, effective_date, active_status, description, isolation_facilities, project_category, care_category, sex, treatment_location, update_by, update_datetime, source_system,patient_category,cubicle_service,official_bed, day_bed, old_ward, old_cubicle, old_effective);
CREATE UNIQUE INDEX cubicle_trans_ui ON cubicle_trans USING btree (record_id);

ALTER TABLE cubicle_trans OWNER TO "HPI_SCHEMA_OWNER_ROLE";