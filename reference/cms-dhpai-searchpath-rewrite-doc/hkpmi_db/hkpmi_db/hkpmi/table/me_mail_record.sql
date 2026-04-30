-- hkpmi.me_mail_record definition

-- Drop table

-- DROP TABLE hkpmi.me_mail_record;

CREATE TABLE hkpmi.me_mail_record (
	me_hosp varchar(6) NOT NULL,
	me_case varchar(24) NOT NULL,
	me_crt_dtm timestamp(6) NOT NULL,
	me_from_hkid varchar(24) NULL,
	me_to_hkid varchar(24) NULL,
	me_crt_user varchar(24) NULL,
	me_crt_sys varchar(24) NULL,
	me_status varchar(2) NULL,
	me_info_code varchar(2) NULL,
	me_reason_code varchar(2) NULL,
	me_reason_oth varchar(510) NULL,
	mail_status varchar(2) NOT NULL,
	mail_upd_dtm timestamp(6) NULL,
	mail_serial_no int4 NOT NULL,
	mail_addr varchar(256) NULL,
	ehr_mail_status varchar(2) NOT NULL,
	ehr_mail_upd_dtm timestamp(6) NULL,
	ehr_mail_serial_no int4 NULL,
	ehr_mail_addr varchar(256) NULL,
	ehr_mail_flag varchar(2) NOT NULL,
	ehr_from_ehr_no varchar(24) NULL,
	ehr_to_ehr_no varchar(24) NULL,
	mail_crt_date varchar(16) NULL,
	sys_dtm timestamp(6) NOT NULL,
	me_upd_status varchar(2) NULL,
	me_upd_user varchar(24) NULL,
	me_upd_dtm timestamp(6) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE INDEX me_mail_record_idx ON hkpmi.me_mail_record USING btree (me_hosp, mail_serial_no);
CREATE INDEX me_mail_record_idx2 ON hkpmi.me_mail_record USING btree (me_hosp, ehr_mail_serial_no);
CREATE UNIQUE INDEX me_mail_record_pky ON hkpmi.me_mail_record USING btree (mail_crt_date, me_hosp, me_case, me_crt_dtm);



ALTER TABLE hkpmi.me_mail_record OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
