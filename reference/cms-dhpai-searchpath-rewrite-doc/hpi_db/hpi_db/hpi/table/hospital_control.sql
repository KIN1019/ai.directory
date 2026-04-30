-- hospital_control definition

-- Drop table

-- DROP TABLE hospital_control;

CREATE TABLE hospital_control (
	hospital_code varchar(6) NOT NULL,
	"type" varchar(60) NOT NULL,
	text_value varchar(510) DEFAULT repeat(' '::text, 255) NOT NULL,
	num_value int4 DEFAULT 0 NOT NULL,
	user_defined varchar(2) NOT NULL,
	default_value varchar(510) DEFAULT repeat(' '::text, 255) NOT NULL,
	description varchar(510) DEFAULT repeat(' '::text, 255) NOT NULL,
	remarks varchar(510) DEFAULT repeat(' '::text, 255) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKHospital_control" ON hospital_control USING btree (hospital_code, type);




ALTER TABLE hospital_control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
