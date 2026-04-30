-- dt_bedlist_ws definition

-- Drop table

-- DROP TABLE dt_bedlist_ws;

CREATE TABLE dt_bedlist_ws (
	ws_code varchar(10) NOT NULL,
	bedlist varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX dt_bedlist_ws_idx ON dt_bedlist_ws USING btree (ws_code);




ALTER TABLE dt_bedlist_ws OWNER TO "HPI_SCHEMA_OWNER_ROLE";
