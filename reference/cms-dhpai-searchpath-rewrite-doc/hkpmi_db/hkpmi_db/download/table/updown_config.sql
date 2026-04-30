-- updown_config definition

-- Drop table

-- DROP TABLE updown_config;

CREATE TABLE updown_config (
	config_key varchar(100) NOT NULL,
	config_value varchar(100) NOT NULL,
	description varchar(200) NULL,
	last_update_time timestamp(6) NULL
);

CREATE UNIQUE INDEX updown_config_idx ON updown_config USING btree (config_key);



ALTER TABLE updown_config OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";

INSERT INTO updown_config
(config_key, config_value, description, last_update_time)
VALUES('mq_enabled', 'Y', 'Y for mq,N for API', NOW());