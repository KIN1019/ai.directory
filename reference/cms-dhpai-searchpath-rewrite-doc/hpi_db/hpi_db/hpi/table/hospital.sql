-- hospital definition

-- Drop table

-- DROP TABLE hospital;

CREATE TABLE hospital (
	hospital_code varchar(6) NOT NULL,
	hospital_name varchar(180) NOT NULL,
	chinese_name varchar(120) NULL,
	address varchar(60) NOT NULL,
	source_code varchar(4) NOT NULL,
	short_name varchar(40) NULL,
	cluster_hospital varchar(2) NOT NULL,
	next_available_ae_no int4 NOT NULL,
	next_available_hn_no int4 NOT NULL,
	shift_factor int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX hospital_idx ON hospital USING btree (hospital_code);




ALTER TABLE hospital OWNER TO "HPI_SCHEMA_OWNER_ROLE";
