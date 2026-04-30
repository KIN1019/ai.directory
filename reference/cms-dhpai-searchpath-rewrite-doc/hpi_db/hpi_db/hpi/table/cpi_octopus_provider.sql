-- cpi_octopus_provider definition

-- Drop table

-- DROP TABLE cpi_octopus_provider;

CREATE TABLE cpi_octopus_provider (
	sp_id int4 NOT NULL,
	sp_english_name varchar(510) NULL,
	sp_english_short_name varchar(20) NULL,
	sp_chinese_name varchar(20) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_octopus_provider_idx ON cpi_octopus_provider USING btree (sp_id);




ALTER TABLE cpi_octopus_provider OWNER TO "HPI_SCHEMA_OWNER_ROLE";
