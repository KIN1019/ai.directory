-- pas_appl_control definition

-- Drop table

-- DROP TABLE pas_appl_control;

CREATE TABLE pas_appl_control (
	hospital_code varchar(6) NOT NULL,
	appl_name varchar(24) NOT NULL,
	appl_ctl_type varchar(60) NOT NULL,
	appl_ctl_text_value varchar(510) NULL,
	appl_ctl_text_value_default varchar(510) NULL,
	appl_ctl_num_value int4 NULL,
	appl_ctl_num_value_default int4 NULL,
	appl_ctl_user_define varchar(2) NULL,
	appl_ctl_desc varchar(510) NULL,
	server_an varchar(40) NULL,
	db_name varchar(40) NULL,
	local_server_name varchar(40) NULL,
	update_by varchar(24) NOT NULL,
	update_sys varchar(24) NOT NULL,
	update_dtm timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX pas_appl_control_pky ON pas_appl_control USING btree (hospital_code, appl_name, appl_ctl_type);




ALTER TABLE pas_appl_control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
