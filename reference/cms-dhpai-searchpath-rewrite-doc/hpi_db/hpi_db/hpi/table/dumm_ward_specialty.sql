-- dumm_ward_specialty definition

-- Drop table

-- DROP TABLE dumm_ward_specialty;

CREATE TABLE dumm_ward_specialty (
	hospital_code varchar(6) NOT NULL,
	"type" varchar(8) NOT NULL,
	code varchar(8) NOT NULL,
	create_by varchar(16) NOT NULL,
	create_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT dumm_ward_specialty_pk PRIMARY KEY (hospital_code, type, code) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE dumm_ward_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
