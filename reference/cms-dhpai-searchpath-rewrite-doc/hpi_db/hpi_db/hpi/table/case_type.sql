-- case_type definition

-- Drop table

-- DROP TABLE case_type;

CREATE TABLE case_type (
	case_type varchar(6) NOT NULL,
	description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX case_type_idx ON case_type USING btree (case_type);




ALTER TABLE case_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
