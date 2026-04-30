-- bed_allocation definition

-- Drop table

-- DROP TABLE bed_allocation;

CREATE TABLE bed_allocation (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	original_specialty varchar(8) NOT NULL,
	effective_date timestamp(6) NOT NULL,
	official_bed int4 NOT NULL,
	day_bed int4 NOT NULL,
	isolation_bed int4 NOT NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	isolation_day int4 NULL

	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX bed_allocation_index ON bed_allocation USING btree (hospital_code, ward_code, specialty_code, original_specialty, effective_date);




ALTER TABLE bed_allocation OWNER TO "HPI_SCHEMA_OWNER_ROLE";
