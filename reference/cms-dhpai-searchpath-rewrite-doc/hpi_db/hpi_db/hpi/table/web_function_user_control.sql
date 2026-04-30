-- web_function_user_control definition

-- Drop table

-- DROP TABLE web_function_user_control;

CREATE TABLE web_function_user_control (
	hospital_code varchar(6) NOT NULL,
	func_id int4 NOT NULL,
	user_id varchar(24) NOT NULL,
	update_by varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	computer_name varchar(40) NULL
);
CREATE UNIQUE INDEX idx_web_function_user_control ON web_function_user_control USING btree (hospital_code, func_id, user_id, computer_name);




ALTER TABLE web_function_user_control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
