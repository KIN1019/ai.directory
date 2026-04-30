-- hk_specialty definition

-- Drop table

-- DROP TABLE hk_specialty;

CREATE TABLE hk_specialty (
	specialty_code varchar(8) NOT NULL,
	description varchar(60) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX hk_specialty_idx ON hk_specialty USING btree (specialty_code);




ALTER TABLE hk_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
