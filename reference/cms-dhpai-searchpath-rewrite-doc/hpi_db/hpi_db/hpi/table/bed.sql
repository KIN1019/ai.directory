-- bed definition

-- Drop table

-- DROP TABLE bed;

CREATE TABLE bed (
	hospital_code varchar(6) NOT NULL,
	ward_code varchar(8) NOT NULL,
	bed_no varchar(10) NOT NULL,
	bed_type varchar(2) NOT NULL,
	"class" varchar(2) NOT NULL,
	status varchar(2) NOT NULL,
	remarks varchar(160) NULL,
	row_update_datetime timestamp(6) NULL,
	active_date timestamp(6) NULL,
	inactive_date timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKBed" PRIMARY KEY (hospital_code, ward_code, bed_no) DEFERRABLE INITIALLY DEFERRED
);



ALTER TABLE bed OWNER TO "HPI_SCHEMA_OWNER_ROLE";
