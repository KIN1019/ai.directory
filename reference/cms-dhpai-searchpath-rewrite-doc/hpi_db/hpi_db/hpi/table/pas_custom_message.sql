-- pas_custom_message definition

-- Drop table

-- DROP TABLE pas_custom_message;

CREATE TABLE pas_custom_message (
	hosp_code varchar(8) NOT NULL,
	project_code varchar(8) NOT NULL,
	message_code varchar(100) NOT NULL,
	message_header varchar(200) NOT NULL,
	message_description varchar(510) NOT NULL,
	message_cause varchar(510) NOT NULL,
	message_action varchar(510) NOT NULL,
	message_others varchar(510) NOT NULL,
	last_update_datetime timestamp(6) NOT NULL,
	CONSTRAINT pas_custom_message_pk PRIMARY KEY (hosp_code, project_code, message_code) DEFERRABLE INITIALLY DEFERRED
);




ALTER TABLE pas_custom_message OWNER TO "HPI_SCHEMA_OWNER_ROLE";
