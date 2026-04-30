-- op_specialty definition

-- Drop table

-- DROP TABLE op_specialty;

CREATE TABLE op_specialty (
	specialty_code varchar(8) NOT NULL,
	hospital_code varchar(6) NOT NULL,
	spec_desc varchar(60) NOT NULL,
	imis_specialty varchar(8) NOT NULL,
	phone varchar(20) NOT NULL,
	exclusive_group int2 NOT NULL,
	status varchar(2) NOT NULL,
	"type" varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX op_specialty_idx ON op_specialty USING btree (specialty_code, hospital_code);




ALTER TABLE op_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
