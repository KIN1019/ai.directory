-- ws_information definition

-- Drop table

-- DROP TABLE ws_information;

CREATE TABLE ws_information (
	hospital_code varchar(6) NOT NULL,
	ws_id varchar(96) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	active_status varchar(2) NOT NULL,
	term_id varchar(96) NOT NULL,
	server_name varchar(96) NULL,
	database_name varchar(96) NULL,
	unhkid_prefix varchar(4) NULL,
	unhkid_min varchar(12) NULL,
	unhkid_max varchar(12) NULL,
	ae_min varchar(12) NULL,
	ae_max varchar(12) NULL,
	hn_min varchar(12) NULL,
	hn_max varchar(12) NULL,
	mini_label_min varchar(20) NULL,
	mini_label_max varchar(20) NULL,
	unhkid_next varchar(12) NULL,
	ae_next varchar(12) NULL,
	hn_next varchar(12) NULL,
	mini_label_next varchar(20) NULL,
	registration_year varchar(4) NULL,
	online_version varchar(96) NULL,
	downtime_version varchar(96) NULL,
	online_datetime timestamp(6) NULL,
	downtime_datetime timestamp(6) NULL,
	online_size int4 NULL,
	downtime_size int4 NULL,
	enable_web_version varchar(2) NULL,
	control_pc varchar(2) NULL,
	exit_only varchar(2) NULL,
	use_proxy_url varchar(20) NULL,
	use_usb_receipt_printer varchar(100) NULL,
	use_ccp varchar(20) NULL,
	use_pas_agent varchar(20) NULL,
	no_of_ip_label int4 NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ws_info_index ON ws_information USING btree (hospital_code, ws_id, effective_datetime);




ALTER TABLE ws_information OWNER TO "HPI_SCHEMA_OWNER_ROLE";
