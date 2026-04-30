-- bed_allocation_trans definition

-- Drop table

-- DROP TABLE bed_allocation_trans;

CREATE TABLE bed_allocation_trans (
	host varchar(60) NOT NULL,
	seq int4 NOT NULL,
	exec_datetime timestamp(6) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NULL,
	specialty_code varchar(8) NULL,
	original_specialty varchar(8) NULL,
	effective_date timestamp(6) NULL,
	official_bed int4 NULL,
	day_bed int4 NULL,
	isolation_bed int4 NULL,
	isolation_day int4 NULL,
	update_by varchar(24) NULL,
	update_dtm timestamp(6) NULL,
	old_ward varchar(8) NULL,
	old_specialty varchar(8) NULL,
	old_original varchar(8) NULL,
	old_effective timestamp(6) NULL,

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL,

	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX bed_allocation_trans_idx ON bed_allocation_trans USING btree (hospital_code, ward_code, specialty_code, effective_date, exec_datetime, host);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX bed_allocation_trans_ui ON bed_allocation_trans USING btree (host,seq,exec_datetime,hospital_code, ward_code, specialty_code, original_specialty, effective_date, official_bed,day_bed, isolation_bed,isolation_day,update_by, update_dtm,old_ward,old_specialty,old_original,old_effective);
CREATE UNIQUE INDEX bed_allocation_trans_ui ON bed_allocation_trans USING btree (record_id);

ALTER TABLE bed_allocation_trans OWNER TO "HPI_SCHEMA_OWNER_ROLE";