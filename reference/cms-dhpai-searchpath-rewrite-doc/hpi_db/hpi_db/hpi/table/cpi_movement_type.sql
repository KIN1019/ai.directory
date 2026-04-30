-- cpi_movement_type definition

-- Drop table

-- DROP TABLE cpi_movement_type;

CREATE TABLE cpi_movement_type (
	move_code varchar(2) NOT NULL,
	move_desc varchar(28) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XPKcpi_movement_type" ON cpi_movement_type USING btree (move_code);




ALTER TABLE cpi_movement_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
