-- user_profile definition

-- Drop table

-- DROP TABLE user_profile;

CREATE TABLE user_profile (
	user_id varchar(16) NOT NULL,
	group_id varchar(20) NOT NULL,
	"password" varchar(32) NOT NULL,
	department varchar(20) NULL,
	"name" varchar(96) NOT NULL,
	authority_code int4 NOT NULL,
	expiration_date timestamp(6) NULL,
	effective_date timestamp(6) NOT NULL,
	rank_code varchar(6) NOT NULL,
	menu varchar(2) NULL,
	dt_security_code int4 NULL,
	hospital_code varchar(6) NOT NULL,
	hkid varchar(24) NULL,
	user_title varchar(20) NULL,
	dt_enable_flag varchar(2) NULL,
	dt_effective_date timestamp(6) NULL,
	dt_expiration_date timestamp(6) NULL,
	password_expiration_date timestamp(6) NULL,
	password_retry_count int4 NULL,
	cuid_flag varchar(2) NULL,
	email varchar(510) NULL,
	encrypted_pswd varchar(200) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "XIE1User_profile" ON user_profile USING btree (hospital_code, user_id);
CREATE INDEX "XPKUser_profile" ON user_profile USING btree (hospital_code, name);




ALTER TABLE user_profile OWNER TO "HPI_SCHEMA_OWNER_ROLE";
