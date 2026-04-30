-- "control" definition

-- Drop table

-- DROP TABLE "control";

CREATE TABLE "control" (
	control_name varchar(20) NOT NULL,
	control_value varchar(70) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "CONTROL_IDX1" ON control USING btree (control_name);




ALTER TABLE control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
