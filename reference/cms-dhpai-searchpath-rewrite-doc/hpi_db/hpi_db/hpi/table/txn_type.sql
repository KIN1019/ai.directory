-- txn_type definition

-- Drop table

-- DROP TABLE txn_type;

CREATE TABLE txn_type (
	txn_type varchar(6) NOT NULL,
	description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX txn_type_idx ON txn_type USING btree (txn_type);




ALTER TABLE txn_type OWNER TO "HPI_SCHEMA_OWNER_ROLE";
