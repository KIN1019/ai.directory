-- user_action_code_list definition

-- Drop table

-- DROP TABLE user_action_code_list;

CREATE TABLE user_action_code_list (
	action_code_type varchar(10) NOT NULL,
	action_code varchar(6) NOT NULL,
	short_description varchar(510) NULL,
	description varchar(510) NULL,
	chinese_description varchar(510) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX user_action_code_list_index ON user_action_code_list USING btree (action_code_type, action_code);




ALTER TABLE user_action_code_list OWNER TO "HPI_SCHEMA_OWNER_ROLE";
