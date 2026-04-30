-- bed_category_type definition

-- Drop table

-- DROP TABLE bed_category_type;

CREATE TABLE bed_category_type (
	bed_category varchar(10) NOT NULL,
	bed_type varchar(2) NULL,
	description varchar(96) NOT NULL,
	short_description varchar(96) NULL,
	treatment_location varchar(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX bed_category_type_idx ON bed_category_type USING btree (bed_category);




ALTER TABLE bed_category_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
