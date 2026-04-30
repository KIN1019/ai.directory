-- available_function definition

-- Drop table

-- DROP TABLE available_function;

CREATE TABLE available_function (
	available_function_name varchar(20) NOT NULL,
	available_function_value varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "AVAILABLE_FUNCTION_IDX1" ON available_function USING btree (available_function_name);




ALTER TABLE available_function OWNER TO "HPI_SCHEMA_OWNER_ROLE";
