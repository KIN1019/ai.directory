-- district definition

-- Drop table

-- DROP TABLE district;

CREATE TABLE district (
	district_code varchar(10) NOT NULL,
	district_name varchar(30) NOT NULL,
	district_board varchar(30) NULL,
	district_area varchar(2) NULL,
	district_chi varchar(60) NULL,
	district_board_chi varchar(60) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX district_idx ON district USING btree (district_code);




ALTER TABLE district OWNER TO "HPI_SCHEMA_OWNER_ROLE";
