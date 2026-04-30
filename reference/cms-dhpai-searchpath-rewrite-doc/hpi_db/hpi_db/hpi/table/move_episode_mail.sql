-- move_episode_mail definition

-- Drop table

-- DROP TABLE move_episode_mail;

CREATE TABLE move_episode_mail (
	hospital_code varchar(6) NOT NULL,
	email_address varchar(510) NULL,
	serial_number int4 NOT NULL,
	case_no varchar(24) NULL,
	from_hkid varchar(24) NULL,
	to_hkid varchar(24) NULL,
	move_dtm timestamp(6) NULL,
	source_system varchar(10) NULL,
	user_id varchar(24) NULL,
	me_status varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX move_episode_mail_idx ON move_episode_mail USING btree (hospital_code, case_no, move_dtm);
CREATE INDEX move_episode_mail_idx2 ON move_episode_mail USING btree (serial_number);




ALTER TABLE move_episode_mail OWNER TO "HPI_SCHEMA_OWNER_ROLE";
