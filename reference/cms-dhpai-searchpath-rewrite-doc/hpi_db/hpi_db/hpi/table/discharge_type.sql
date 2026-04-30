-- discharge_type definition

-- Drop table

-- DROP TABLE discharge_type;

CREATE TABLE discharge_type (
	discharge_code varchar(2) NOT NULL,
	description varchar(80) NOT NULL,
	short_description varchar(10) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX discharge_type_idx ON discharge_type USING btree (discharge_code);




ALTER TABLE discharge_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
