-- work_station definition

-- Drop table

-- DROP TABLE work_station;

CREATE TABLE work_station (
	ws_code varchar(10) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "WS_IDX1" ON work_station USING btree (ws_code);




ALTER TABLE work_station OWNER TO "HPI_SCHEMA_OWNER_ROLE";
