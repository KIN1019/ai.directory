-- hago_designated_user definition

-- Drop table

-- DROP TABLE hago_designated_user;

CREATE TABLE hago_designated_user (
	hospital_code varchar(6) NOT NULL,
	user_id varchar(16) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NOT NULL
);
CREATE UNIQUE INDEX hago_designated_user_idx ON hago_designated_user USING btree (hospital_code, user_id);


ALTER TABLE hago_designated_user OWNER TO "HPI_SCHEMA_OWNER_ROLE";
