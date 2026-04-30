-- pas_func_whitelist definition

-- Drop table

-- DROP TABLE pas_func_whitelist;

CREATE TABLE pas_func_whitelist (
	hosp_code varchar(8) NOT NULL,
	user_id varchar(100) NOT NULL,
	whitelist_type varchar(200) NOT NULL,
	whitelist_group varchar(200) NOT NULL,
	control_value varchar(2) NOT NULL,
	last_updated_by varchar(100) NOT NULL,
	last_update_datetime timestamp(6) NOT NULL,
	CONSTRAINT pas_func_whitelist_pk PRIMARY KEY (hosp_code, user_id, whitelist_type, whitelist_group) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE pas_func_whitelist OWNER TO "HPI_SCHEMA_OWNER_ROLE";
