-- bed_service_type definition

-- Drop table

-- DROP TABLE bed_service_type;

CREATE TABLE bed_service_type (
	bed_service varchar(6) NULL,
	description varchar(160) NOT NULL,
	status varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX bed_service_index ON bed_service_type USING btree (bed_service);




ALTER TABLE bed_service_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
