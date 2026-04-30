-- bed_change_log definition

-- Drop table

-- DROP TABLE bed_change_log;

CREATE TABLE bed_change_log (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	cubicle_no varchar(8) NOT NULL,
	bed_no varchar(10) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	active_status varchar(2) NULL,
	isolation_facilities varchar(4) NULL,
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
	old_active_status varchar(2) NULL,
	old_isolation_facilities varchar(4) NULL,
	old_bed_type varchar(2) NULL,
	old_bed_category varchar(10) NULL,
	old_specialty_code varchar(8) NULL,
	old_in_service_specialty varchar(8) NULL,
	old_row_no int4 NULL,
	old_col_no int4 NULL,
	old_update_datetime timestamp(6) NULL,
	old_update_by varchar(24) NULL,
	old_source_system varchar(10) NULL,
	old_ciwl_indicator varchar(2) NULL,
	old_isolation_bed varchar(2) NULL,
	old_bed_ready varchar(2) NULL,
	remark varchar(8) NULL,
	"action" varchar(2) NULL,
	sent varchar(2) NULL
);
CREATE INDEX "bed_change_log_IDX1" ON bed_change_log USING btree (old_update_datetime);
CREATE UNIQUE INDEX "bed_change_log_XPK" ON bed_change_log USING btree (hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, update_datetime, "action");


ALTER TABLE bed_change_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
