-- external_service_config definition

-- Drop table

-- DROP TABLE external_service_config;

CREATE TABLE external_service_config (
	project varchar(40) NOT NULL,
	service varchar(60) NOT NULL,
	config_key varchar(200) NOT NULL,
	config_value varchar(2000) NOT NULL,
	custom varchar(600) NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(40) NOT NULL
);
CREATE UNIQUE INDEX external_service_config_idx ON external_service_config USING btree (project, service, config_key);




ALTER TABLE external_service_config OWNER TO "HPI_SCHEMA_OWNER_ROLE";
