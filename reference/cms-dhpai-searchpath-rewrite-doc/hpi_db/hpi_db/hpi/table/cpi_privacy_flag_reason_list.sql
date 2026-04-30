-- cpi_privacy_flag_reason_list definition

-- Drop table

-- DROP TABLE cpi_privacy_flag_reason_list;

CREATE TABLE cpi_privacy_flag_reason_list (
	reason_code varchar(6) NOT NULL,
	"type" varchar(60) NOT NULL,
	reason varchar(510) NOT NULL,
	description varchar(510) NULL,
	remark varchar(510) NULL,
	active varchar(2) NOT NULL,
	effective_datetime timestamp(6) NOT NULL,
	seq_no varchar(24) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX cpi_privacyflag_reasonlist_uci ON cpi_privacy_flag_reason_list USING btree (reason_code);




ALTER TABLE cpi_privacy_flag_reason_list OWNER TO "HPI_SCHEMA_OWNER_ROLE";
