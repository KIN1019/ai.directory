-- ipas_whats_new_message_dtl definition

-- Drop table

-- DROP TABLE ipas_whats_new_message_dtl;

CREATE TABLE ipas_whats_new_message_dtl (
	message_id varchar(20) NOT NULL,
	hospital varchar(6) NOT NULL,
	message_line int4 NOT NULL,
	message_content varchar(510) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX idx_ipas_whats_new_message_dtl ON ipas_whats_new_message_dtl USING btree (message_id, message_line, hospital);




ALTER TABLE ipas_whats_new_message_dtl OWNER TO "HPI_SCHEMA_OWNER_ROLE";
