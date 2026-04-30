-- bed_history_trans definition

-- Drop table

-- DROP TABLE bed_history_trans;

CREATE TABLE bed_history_trans (
	host varchar(60) NOT NULL,
	seq int4 NOT NULL,
	exec_datetime timestamp(6) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NULL,
	cubicle_no varchar(8) NULL,
	bed_no varchar(10) NULL,
	effective_datetime timestamp(6) NULL,
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
	old_ward varchar(8) NULL,
	old_cubicle varchar(8) NULL,
	old_bed varchar(10) NULL,
	old_effective timestamp(6) NULL,
	bed_ready varchar(2) NULL,
	physical_bed_no varchar(10) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX bed_history_trans_idx ON bed_history_trans USING btree (hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, exec_datetime, host);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX bed_history_trans_ui ON bed_history_trans USING btree (host,seq,exec_datetime,hospital_code, ward_code, cubicle_no, bed_no, effective_datetime,active_status,bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator,isolation_bed,old_ward, old_cubicle, old_bed, old_effective, bed_ready, physical_bed_no);
CREATE UNIQUE INDEX bed_history_trans_ui ON bed_history_trans USING btree (record_id);

ALTER TABLE bed_history_trans OWNER TO "HPI_SCHEMA_OWNER_ROLE";