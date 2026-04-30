-- move_episode_notification definition

-- Drop table

-- DROP TABLE move_episode_notification;

CREATE TABLE move_episode_notification (
	hospital_code varchar(6) NOT NULL,
	email_address varchar(510) NULL,
	last_sent_case varchar(24) NULL,
	last_sent_create_dtm timestamp(6) NULL,
	update_dtm timestamp(6) NULL,
	serial_number int4 NULL,
	last_sent_serial_number int4 NULL
);
CREATE UNIQUE INDEX move_episode_idx ON move_episode_notification USING btree (hospital_code);




ALTER TABLE move_episode_notification OWNER TO "HPI_SCHEMA_OWNER_ROLE";
