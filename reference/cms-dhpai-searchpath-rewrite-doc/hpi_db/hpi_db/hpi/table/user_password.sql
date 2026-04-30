-- user_password definition

-- Drop table

-- DROP TABLE user_password;

CREATE TABLE user_password (
	hospital_code varchar(6) NOT NULL,
	user_id varchar(16) NOT NULL,
	"password" varchar(140) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	last_updated_by varchar(16) NOT NULL,
	last_update_status varchar(100) NOT NULL
);
CREATE UNIQUE INDEX "XIE1User_password" ON user_password USING btree (hospital_code, user_id, update_datetime);
CREATE INDEX "XPKUser_password" ON user_password USING btree (user_id);




ALTER TABLE user_password OWNER TO "HPI_SCHEMA_OWNER_ROLE";
