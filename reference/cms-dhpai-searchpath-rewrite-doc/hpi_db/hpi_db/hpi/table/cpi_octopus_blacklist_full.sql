-- cpi_octopus_blacklist_full definition

-- Drop table

-- DROP TABLE cpi_octopus_blacklist_full;

CREATE TABLE cpi_octopus_blacklist_full (
	system_datetime timestamp(6) NOT NULL,
	seq int4 NOT NULL,
	file_name varchar(96) NULL,
	file_data bytea NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_octopus_blacklist_full_idx ON cpi_octopus_blacklist_full USING btree (system_datetime, seq);




ALTER TABLE cpi_octopus_blacklist_full OWNER TO "HPI_SCHEMA_OWNER_ROLE";
