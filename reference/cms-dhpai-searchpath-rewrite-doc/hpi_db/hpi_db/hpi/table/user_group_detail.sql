-- user_group_detail definition

-- Drop table

-- DROP TABLE user_group_detail;

CREATE TABLE user_group_detail (
	hospital_code varchar(6) NOT NULL,
	group_id varchar(20) NOT NULL,
	func_option int4 NOT NULL,
	func_id int4 NOT NULL,
	func_col int4 NOT NULL,
	func_row int4 NOT NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKUser_group_detail" PRIMARY KEY (hospital_code, group_id, func_option) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE user_group_detail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
