-- ipas_user_management_log definition

-- Drop table

-- DROP TABLE ipas_user_management_log;

CREATE TABLE ipas_user_management_log (
	hospital varchar(6) NOT NULL,
	masked_hkid varchar(24) NULL,
	login_id varchar(16) NULL,
	"action" varchar(100) NOT NULL,
	input_message_1 varchar(510) NULL,
	input_message_2 varchar(510) NULL,
	success varchar(2) NOT NULL,
	error_message varchar(510) NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(16) NOT NULL,
	update_project varchar(200) NOT NULL
);
CREATE UNIQUE INDEX ipas_user_management_log_idx ON ipas_user_management_log USING btree (update_datetime, hospital, masked_hkid);




ALTER TABLE ipas_user_management_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
