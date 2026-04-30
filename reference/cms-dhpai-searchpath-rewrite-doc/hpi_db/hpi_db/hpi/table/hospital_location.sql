-- hospital_location definition

-- Drop table

-- DROP TABLE hospital_location;

CREATE TABLE hospital_location (
	hospital_code varchar(6) NOT NULL,
	location_code varchar(8) NOT NULL,
	active_status varchar(2) NOT NULL,
	effective_date timestamp(6) NOT NULL,
	description varchar(510) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX hospital_location_index ON hospital_location USING btree (hospital_code, location_code, effective_date);




ALTER TABLE hospital_location OWNER TO "HPI_SCHEMA_OWNER_ROLE";
