-- cpi_octopus_blacklist definition

-- Drop table

-- DROP TABLE cpi_octopus_blacklist;

CREATE TABLE cpi_octopus_blacklist (
	system_datetime timestamp(6) NOT NULL,
	blacklist_data bytea NULL,
	blacklist_name varchar(96) NULL,
	blacklist_summ bytea NULL,
	eod_data bytea NULL,
	eod_name varchar(96) NULL,
	eod_summ bytea NULL,
	cchs_data bytea NULL,
	cchs_name varchar(96) NULL,
	cchs_summ bytea NULL,
	firm_data bytea NULL,
	firm_name varchar(96) NULL,
	firm_summ bytea NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_octopus_blacklist_idx ON cpi_octopus_blacklist USING btree (system_datetime);




ALTER TABLE cpi_octopus_blacklist OWNER TO "HPI_SCHEMA_OWNER_ROLE";
