-- religion definition

-- Drop table

-- DROP TABLE religion;

CREATE TABLE religion (
	religion_code varchar(6) NOT NULL,
	religion_description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX religion_idx ON religion USING btree (religion_code);




ALTER TABLE religion OWNER TO "HPI_SCHEMA_OWNER_ROLE";
