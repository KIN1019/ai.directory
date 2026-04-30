-- ward_location definition

-- Drop table

-- DROP TABLE ward_location;

CREATE TABLE ward_location (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	location_code varchar(8) NULL,
	active_status varchar(2) NOT NULL,
	effective_date timestamp(6) NOT NULL,
	location_desc varchar(100) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ward_location_index ON ward_location USING btree (hospital_code, ward_code, effective_date);




ALTER TABLE ward_location OWNER TO "HPI_SCHEMA_OWNER_ROLE";
