-- ocsss_random_log definition

-- Drop table

-- DROP TABLE ocsss_random_log;

CREATE TABLE ocsss_random_log (
	log_datetime timestamp(6) NOT NULL,
	hosp_code varchar(6) NOT NULL,
	workstation_id varchar(40) NOT NULL,
	user_id varchar(24) NOT NULL,
	application_id int4 NOT NULL,
	function_id int4 NOT NULL,
	operation_id int4 NOT NULL,
	source_system varchar(10) NULL,
	hkid varchar(24) NOT NULL,
	last_doc_code varchar(2) NULL,
	last_hkic varchar(2) NULL,
	new_doc_code varchar(2) NULL,
	new_hkic varchar(2) NULL,
	random_check varchar(2) NULL,
	appt_seq int4 NULL,
	magic_number varchar(8) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX idx_ocsss_random_log ON ocsss_random_log USING btree (log_datetime, hosp_code, hkid);




ALTER TABLE ocsss_random_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
