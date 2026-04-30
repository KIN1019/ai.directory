-- bed_location_type definition

-- Drop table

-- DROP TABLE bed_location_type;

CREATE TABLE bed_location_type (
	bed_location varchar(4) NULL,
	description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX bed_location_index ON bed_location_type USING btree (bed_location);




ALTER TABLE bed_location_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
