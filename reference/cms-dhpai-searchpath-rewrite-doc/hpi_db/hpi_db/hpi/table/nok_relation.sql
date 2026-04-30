-- nok_relation definition

-- Drop table

-- DROP TABLE nok_relation;

CREATE TABLE nok_relation (
	nok_relation_code varchar(4) NOT NULL,
	description varchar(160) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX nok_relation_idx ON nok_relation USING btree (nok_relation_code);




ALTER TABLE nok_relation OWNER TO "HPI_SCHEMA_OWNER_ROLE";
