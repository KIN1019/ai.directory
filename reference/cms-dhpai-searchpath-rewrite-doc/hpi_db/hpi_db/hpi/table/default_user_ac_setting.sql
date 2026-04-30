-- default_user_ac_setting definition

-- Drop table

-- DROP TABLE default_user_ac_setting;

CREATE TABLE default_user_ac_setting (
	hospital_code varchar(6) NOT NULL,
	setting_code varchar(60) NOT NULL,
	group_id varchar(20) NOT NULL,
	effective_date timestamp(6) NULL,
	expiration_date timestamp(6) NULL,
	system_authority int4 NULL,
	user_authority int4 NULL,
	create_datetime timestamp(6) NOT NULL,
	update_datetime timestamp(6) NOT NULL
);
CREATE UNIQUE INDEX default_user_ac_setting_idx ON default_user_ac_setting USING btree (hospital_code, setting_code);




ALTER TABLE default_user_ac_setting OWNER TO "HPI_SCHEMA_OWNER_ROLE";
