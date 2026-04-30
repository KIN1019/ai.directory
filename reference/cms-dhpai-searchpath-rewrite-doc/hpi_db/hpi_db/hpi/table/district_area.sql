-- district_area definition

-- Drop table

-- DROP TABLE district_area;

CREATE TABLE district_area (
	area_code varchar(2) NOT NULL,
	area_name varchar(100) NOT NULL,
	area_chi varchar(100) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX district_area_idx ON district_area USING btree (area_code);




ALTER TABLE district_area OWNER TO "HPI_SCHEMA_OWNER_ROLE";
