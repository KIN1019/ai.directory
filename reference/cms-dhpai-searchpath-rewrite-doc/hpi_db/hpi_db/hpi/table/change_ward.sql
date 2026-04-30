-- change_ward definition

-- Drop table

-- DROP TABLE change_ward;

CREATE TABLE change_ward (
	ws_code varchar(10) NOT NULL,
	change_ns_code varchar(10) NOT NULL,
	default_ns_flag varchar(2) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "CHGWARD_IDX1" ON change_ward USING btree (ws_code, change_ns_code);




ALTER TABLE change_ward OWNER TO "HPI_SCHEMA_OWNER_ROLE";
