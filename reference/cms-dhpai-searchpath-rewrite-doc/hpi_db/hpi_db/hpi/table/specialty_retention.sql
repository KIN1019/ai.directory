-- specialty_retention definition

-- Drop table

-- DROP TABLE specialty_retention;

CREATE TABLE specialty_retention (
	hospital_code varchar(6) NOT NULL,
	eis_specialty varchar(6) NOT NULL,
	retention_period int4 NOT NULL,
	age int4 NULL,
	death_indicator varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX specialty_retention_index ON specialty_retention USING btree (hospital_code, eis_specialty);




ALTER TABLE specialty_retention OWNER TO "HPI_SCHEMA_OWNER_ROLE";
