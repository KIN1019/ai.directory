-- race definition

-- Drop table

-- DROP TABLE race;

CREATE TABLE race (
	race_code varchar(4) NOT NULL,
	race_description varchar(40) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX race_idx ON race USING btree (race_code);




ALTER TABLE race OWNER TO "HPI_SCHEMA_OWNER_ROLE";
