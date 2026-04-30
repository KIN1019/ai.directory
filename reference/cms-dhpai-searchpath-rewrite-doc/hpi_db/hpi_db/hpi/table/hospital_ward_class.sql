-- hospital_ward_class definition

-- Drop table

-- DROP TABLE hospital_ward_class;

CREATE TABLE hospital_ward_class (
	hospital_cde varchar(6) NOT NULL,
	ward_cde varchar(8) NOT NULL,
	ward_class varchar(2) NOT NULL,
	ward_desc varchar(60) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ward_class_idx1 ON hospital_ward_class USING btree (hospital_cde, ward_cde, ward_class);




ALTER TABLE hospital_ward_class OWNER TO "HPI_SCHEMA_OWNER_ROLE";
