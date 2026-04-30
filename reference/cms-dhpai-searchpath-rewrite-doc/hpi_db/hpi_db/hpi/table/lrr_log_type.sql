-- lrr_log_type definition

-- Drop table

-- DROP TABLE lrr_log_type;

CREATE TABLE lrr_log_type (
	"type" varchar(6) NOT NULL,
	description varchar(80) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "LRR_LOGTYPE_IDX1" ON lrr_log_type USING btree (type);




ALTER TABLE lrr_log_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
