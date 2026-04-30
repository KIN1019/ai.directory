-- hospital_config definition

-- Drop table

-- DROP TABLE hospital_config;

CREATE TABLE hospital_config (
	hospital_code varchar(6) NOT NULL,
	provider_id varchar(6) NOT NULL,
	"name" varchar(180) NOT NULL,
	address varchar(60) NOT NULL,
	source_code varchar(4) NOT NULL,
	short_name varchar(40) NOT NULL,
	next_available_ae_no int4 NOT NULL,
	next_available_hn_no int4 NOT NULL,
	shift_factor int4 NOT NULL,
	ae_print_format varchar(16) NOT NULL,
	set_of_ae_label int2 NOT NULL,
	hn_print_format varchar(16) NOT NULL,
	set_of_hn_label int2 NOT NULL,
	no_of_full_hn_label int2 NOT NULL,
	no_of_partial_hn_label int2 NOT NULL,
	no_of_bar_code_hn_label int2 NOT NULL,
	additional_bar_code_label int2 NOT NULL,
	mrts_interface varchar(2) NOT NULL,
	lpi_interface varchar(2) NOT NULL,
	dt_interface varchar(2) NOT NULL,
	gateway_id varchar(16) NOT NULL,
	cics_id varchar(16) NOT NULL,
	upload_download_status varchar(2) NOT NULL,
	pbrc_server_name varchar(16) NOT NULL,
	last_download_key varchar(40) NOT NULL,
	sna_connection_status varchar(2) NOT NULL,
	row_update_datetime timestamp(6) NULL,
	next_available_dp_no int4 NOT NULL,
	last_reported_date timestamp(6) NOT NULL,
	statistics_start_date timestamp(6) NOT NULL,
	un_hkid_prefix varchar(4) NOT NULL,
	un_next_hkid varchar(12) NOT NULL,
	un_max_hkid varchar(12) NOT NULL,
	diagnosis_flag varchar(2) NOT NULL,
	scis_server varchar(40) NULL,
	pp_flag varchar(2) NULL,
	no_of_full_ae_label int2 NULL,
	no_of_bar_code_ae_label int2 NULL,
	additional_bar_code_label_1 int2 NOT NULL,
	no_of_add_bar_code_ae_label int2 NULL,
	no_of_label_for_med_cert int2 NOT NULL,
	last_download_system_datetime timestamp(6) NULL,
	dnl_server_name varchar(40) NULL,
	delay_time int4 NULL,
	priority_hn_full int2 NULL,
	priority_hn_partial int2 NULL,
	priority_hn_barcode int2 NULL,
	priority_hn_without_hkid int2 NULL,
	priority_hn_med_cert int2 NULL,
	priority_ae_full int2 NULL,
	priority_ae_barcode int2 NULL,
	priority_ae_without_hkid int2 NULL,
	priority_ae_med_cert int2 NULL,
	no_of_specimen_label int2 NULL,
	priority_specimen_label int2 NULL,
	min_online_number int4 NULL,
	max_online_number int4 NULL,
	min_disaster_number int4 NULL,
	max_disaster_number int4 NULL,
	min_downtime_number int4 NULL,
	max_downtime_number int4 NULL,
	next_available_ae_receipt int8 NULL,
	no_of_document_label int2 DEFAULT 0 NULL,
	priority_document_label int2 DEFAULT 7 NULL,
	no_of_name_hn_label int2 DEFAULT 0 NULL,
	priority_name_hn_label int2 DEFAULT 8 NULL,
	no_of_name_ae_label int2 DEFAULT 0 NULL,
	priority_name_ae_label int2 DEFAULT 5 NULL,
	no_of_case_hn_label int2 DEFAULT 0 NULL,
	priority_case_hn_label int2 DEFAULT 9 NULL,
	last_update_datetime timestamp(6) NULL,

	-- Below deferred setting on PK is useless in IPAS. It was added due to the conversion done by the earliest SCT tool.
	-- Remove it otherwise after setting logical replication, update/delete would fail on this table with error below:
	-- 	SQL Error [55000]: ERROR: cannot update table "hospital_config" because it does not have a replica identity and publishes updates
	-- (Xulu email on 5-Sep-2025)
	CONSTRAINT "XPKHospital" PRIMARY KEY (hospital_code) /* DEFERRABLE INITIALLY DEFERRED */
);



ALTER TABLE hospital_config OWNER TO "HPI_SCHEMA_OWNER_ROLE";
