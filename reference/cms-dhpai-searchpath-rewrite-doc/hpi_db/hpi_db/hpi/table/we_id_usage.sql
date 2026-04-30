-- we_id_usage definition

-- Drop table

-- DROP TABLE we_id_usage;

CREATE TABLE we_id_usage (
	station_id int2 NOT NULL,
	used_flag varchar(2) NOT NULL,
	id_enabled varchar(2) NOT NULL,
	last_start_time timestamp(6) NOT NULL,
	last_used_time timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);

--Sybase DDL (PROD Jul-2025 snapshot): exec sp_primarykey 'tkohpi_db.dbo.WE_ID_USAGE', 'STATION_ID'
ALTER TABLE we_id_usage ADD PRIMARY KEY (station_id);

--No need to create unique index on all columns as below for NineData CDC, because there is primary key created above
--CREATE UNIQUE INDEX we_id_usage_PK ON we_id_usage USING btree (station_id, used_flag, id_enabled, last_start_time, last_used_time);

ALTER TABLE we_id_usage OWNER TO "HPI_SCHEMA_OWNER_ROLE";
