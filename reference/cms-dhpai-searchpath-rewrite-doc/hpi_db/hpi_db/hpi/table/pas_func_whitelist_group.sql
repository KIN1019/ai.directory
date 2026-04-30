-- pas_func_whitelist_group definition

-- Drop table

-- DROP TABLE pas_func_whitelist_group;

CREATE TABLE pas_func_whitelist_group (
	hosp_code varchar(8) NOT NULL,
	whitelist_group varchar(200) NOT NULL,
	func_id int4 NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT pas_func_whitelist_group_pk PRIMARY KEY (hosp_code, whitelist_group, func_id) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE pas_func_whitelist_group OWNER TO "HPI_SCHEMA_OWNER_ROLE";
