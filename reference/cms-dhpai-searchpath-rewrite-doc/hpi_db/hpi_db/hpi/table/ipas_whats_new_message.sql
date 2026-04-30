-- ipas_whats_new_message definition

-- Drop table

-- DROP TABLE ipas_whats_new_message;

CREATE TABLE ipas_whats_new_message (
	message_id varchar(20) NOT NULL,
	hospital varchar(6) NOT NULL,
	message_type varchar(12) NOT NULL,
	message_header varchar(200) NOT NULL,
	message_start_date timestamp(6) NOT NULL,
	message_expiry_date timestamp(6) NULL,
	message_new_period int4 NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX idx_ipas_whats_new_message ON ipas_whats_new_message USING btree (message_id, hospital);
CREATE INDEX idx_ipas_whats_new_message_1 ON ipas_whats_new_message USING btree (message_start_date);




ALTER TABLE ipas_whats_new_message OWNER TO "HPI_SCHEMA_OWNER_ROLE";
