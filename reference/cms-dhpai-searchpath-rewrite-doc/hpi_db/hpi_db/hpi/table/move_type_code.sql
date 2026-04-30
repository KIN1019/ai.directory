-- move_type_code definition

-- Drop table

-- DROP TABLE move_type_code;

CREATE TABLE move_type_code (
	move_code varchar(2) NOT NULL,
	move_desc varchar(28) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKMove_type_code" ON move_type_code USING btree (move_code);




ALTER TABLE move_type_code OWNER TO "HPI_SCHEMA_OWNER_ROLE";
