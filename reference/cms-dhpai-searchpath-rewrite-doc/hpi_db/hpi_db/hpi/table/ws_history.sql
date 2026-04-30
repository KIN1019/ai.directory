-- ws_history definition

-- Drop table

-- DROP TABLE ws_history;

CREATE TABLE ws_history (
	hospital_code varchar(6) NOT NULL,
	ws_id varchar(96) NOT NULL,
	system_datetime timestamp(6) NOT NULL,
	error_code int4 NOT NULL,
	term_id varchar(96) NOT NULL,
	user_id varchar(96) NULL,
	registration_year varchar(4) NULL,
	unhkid_prefix varchar(4) NULL,
	unhkid_next varchar(12) NULL,
	ae_next varchar(12) NULL,
	hn_next varchar(12) NULL,
	mini_label_next varchar(20) NULL,
	action_code varchar(12) NULL,
	old_registration_year varchar(4) NULL,
	old_unhkid_prefix varchar(4) NULL,
	old_unhkid_min varchar(12) NULL,
	old_unhkid_max varchar(12) NULL,
	old_ae_min varchar(12) NULL,
	old_ae_max varchar(12) NULL,
	old_hn_min varchar(12) NULL,
	old_hn_max varchar(12) NULL,
	old_mini_label_min varchar(20) NULL,
	old_mini_label_max varchar(20) NULL,
	old_unhkid_next varchar(12) NULL,
	old_ae_next varchar(12) NULL,
	old_hn_next varchar(12) NULL,
	old_mini_label_next varchar(20) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX ws_history_index ON ws_history USING btree (system_datetime, hospital_code, ws_id);




ALTER TABLE ws_history OWNER TO "HPI_SCHEMA_OWNER_ROLE";
