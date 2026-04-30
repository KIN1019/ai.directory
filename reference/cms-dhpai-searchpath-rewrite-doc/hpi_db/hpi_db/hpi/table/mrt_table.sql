-- mrt_table definition

-- Drop table

-- DROP TABLE mrt_table;

CREATE TABLE mrt_table (
	hospital_code varchar(6) NOT NULL,
	specialty_code varchar(8) NOT NULL,
	destination_code varchar(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKMRT_table" ON mrt_table USING btree (hospital_code, specialty_code, destination_code);




ALTER TABLE mrt_table OWNER TO "HPI_SCHEMA_OWNER_ROLE";
