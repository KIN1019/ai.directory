-- ward_class definition

-- Drop table

-- DROP TABLE ward_class;

CREATE TABLE ward_class (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	ward_class varchar(2) NOT NULL,
	open_date timestamp(6) NOT NULL,
	close_date timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ward_class_idx ON ward_class USING btree (hospital_code, ward_code, ward_class);




ALTER TABLE ward_class OWNER TO "HPI_SCHEMA_OWNER_ROLE";
