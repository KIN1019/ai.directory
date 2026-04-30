-- hkpmi.hkpmi_bed_history definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_bed_history;

CREATE TABLE hkpmi.hkpmi_bed_history (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	cubicle_no varchar(8) NOT NULL,
	bed_no varchar(10) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	active_status varchar(2) NULL,
	bed_type varchar(2) NULL,
	bed_category varchar(10) NULL,
	specialty_code varchar(8) NULL,
	in_service_specialty varchar(8) NULL,
	row_no int4 NULL,
	col_no int4 NULL,
	update_datetime timestamp(6) NULL,
	update_by varchar(24) NULL,
	source_system varchar(10) NULL,
	ciwl_indicator varchar(2) NULL,
	isolation_bed varchar(2) NULL,
	bed_ready varchar(2) NULL,
	physical_bed_no varchar(10) NULL
);
CREATE UNIQUE INDEX hkpmi_bed_history_index ON hkpmi.hkpmi_bed_history USING btree (bed_no, hospital_code, ward_code, cubicle_no, effective_datetime);
CREATE INDEX hkpmi_bed_history_index2 ON hkpmi.hkpmi_bed_history USING btree (hospital_code, ward_code);




ALTER TABLE hkpmi.hkpmi_bed_history OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
