-- log_type definition

-- Drop table

-- DROP TABLE log_type;

CREATE TABLE log_type (
	"type" varchar(6) NOT NULL,
	description varchar(80) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "LOGTYPE_IDX1" ON log_type USING btree (type);




ALTER TABLE log_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
