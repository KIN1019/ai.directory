-- isolation_facilities_type definition

-- Drop table

-- DROP TABLE isolation_facilities_type;

CREATE TABLE isolation_facilities_type (
	isolation_facilities varchar(4) NULL,
	description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX isolation_facilities_index ON isolation_facilities_type USING btree (isolation_facilities);




ALTER TABLE isolation_facilities_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
