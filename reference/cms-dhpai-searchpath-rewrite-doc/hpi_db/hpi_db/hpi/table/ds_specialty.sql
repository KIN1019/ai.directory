-- ds_specialty definition

-- Drop table

-- DROP TABLE ds_specialty;

CREATE TABLE ds_specialty (
	ds_specialty_code varchar(8) NOT NULL,
	ds_dept_name varchar(8) NOT NULL,
	ds_page int2 NOT NULL,
	ds_description varchar(120) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "DS_SPECIALTY_IDX1" ON ds_specialty USING btree (ds_specialty_code);




ALTER TABLE ds_specialty OWNER TO "HPI_SCHEMA_OWNER_ROLE";
