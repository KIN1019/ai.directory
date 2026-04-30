-- hkpmi.me_mail_conf definition

-- Drop table

-- DROP TABLE hkpmi.me_mail_conf;

CREATE TABLE hkpmi.me_mail_conf (
	hosp_code varchar(6) NOT NULL,
	mail_addr varchar(256) NULL,
	mail_last_serial int4 NOT NULL,
	mail_last_sent_dtm timestamp(6) NULL,
	mail_last_upd_by varchar(24) NULL,
	ehr_mail_addr varchar(256) NULL,
	ehr_mail_last_serial int4 NOT NULL,
	ehr_mail_last_sent_dtm timestamp(6) NULL,
	ehr_mail_last_upd_by varchar(24) NULL,
	last_poll_dtm timestamp(6) NULL,
	sys_dtm timestamp(6) NOT NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX me_mail_conf_pky ON hkpmi.me_mail_conf USING btree (hosp_code);



ALTER TABLE hkpmi.me_mail_conf OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
