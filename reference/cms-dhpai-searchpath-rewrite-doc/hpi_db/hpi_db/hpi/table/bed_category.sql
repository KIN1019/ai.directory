-- bed_category definition

-- Drop table

-- DROP TABLE bed_category;

CREATE TABLE bed_category (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	bed_no varchar(10) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	bed_category varchar(10) NULL,
	update_by varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	bed_service varchar(6) NULL,
	bed_location varchar(4) NULL,
	bed_type varchar(2) NULL,
	isolation_facilities varchar(4) NULL,
	funded_bed varchar(4) NULL,
	cubicle_no varchar(8) NULL,
	original_capacity varchar(4) NULL
	
	-- Remove "last_update_datetime" as there already exists "update_dtm"
	--last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX bed_category_idx ON bed_category USING btree (hospital_code, ward_code, bed_no, effective_datetime);




ALTER TABLE bed_category OWNER TO "HPI_SCHEMA_OWNER_ROLE";
