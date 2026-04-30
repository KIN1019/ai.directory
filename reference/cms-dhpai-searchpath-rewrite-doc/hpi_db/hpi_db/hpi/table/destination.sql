-- destination definition

-- Drop table

-- DROP TABLE destination;

CREATE TABLE destination (
	destination_code varchar(6) NOT NULL,
	description varchar(200) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX destination_idx ON destination USING btree (destination_code);




ALTER TABLE destination OWNER TO "HPI_SCHEMA_OWNER_ROLE";
