-- pas_name_search_log definition

-- Drop table

-- DROP TABLE pas_name_search_log;

CREATE TABLE pas_name_search_log (
	hosp_code varchar(8) NOT NULL,
	user_id varchar(100) NOT NULL,
	func_id int4 NOT NULL,
	search_type varchar(100) NOT NULL,
	search_key varchar(510) NULL,
	hkid varchar(24) NULL,
	patient_key varchar(16) NULL,
	search_datetime timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT pas_name_search_log_pk PRIMARY KEY (hosp_code, user_id, search_datetime) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE pas_name_search_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
