-- user_group definition

-- Drop table

-- DROP TABLE user_group;

CREATE TABLE user_group (
	hospital_code varchar(6) NOT NULL,
	group_id varchar(20) NOT NULL,
	group_description varchar(80) NULL,
	last_update_datetime timestamp(6) NULL,
	CONSTRAINT "XPKUser_Group" PRIMARY KEY (hospital_code, group_id) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE user_group OWNER TO "HPI_SCHEMA_OWNER_ROLE";
