-- pbrc_os_overriding_log definition

-- Drop table

-- DROP TABLE pbrc_os_overriding_log;

CREATE TABLE pbrc_os_overriding_log (
	hospital_code varchar(6) NOT NULL,
	txn_type varchar(6) NULL,
	hkid varchar(24) NOT NULL,
	case_no varchar(24) NOT NULL,
	adm_dtm timestamp(6) NULL,
	pay_code varchar(6) NULL,
	source_ind varchar(2) NULL,
	source_code varchar(6) NULL,
	ward_code varchar(8) NULL,
	ward_class varchar(2) NULL,
	spec_code varchar(8) NULL,
	eis_code varchar(6) NULL,
	os_amt numeric(19, 4) NULL,
	overriding_reason varchar(510) NULL,
	action_code_type varchar(10) NULL,
	action_code varchar(6) NULL,
	term_id varchar(24) NULL,
	update_by varchar(24) NULL,
	update_dtm timestamp(6) NOT NULL,
	source_system varchar(16) NULL,
	remark varchar(510) NULL
);
CREATE INDEX pbrc_os_overriding_log_idx2 ON pbrc_os_overriding_log USING btree (hospital_code, update_dtm);
CREATE UNIQUE INDEX pbrc_os_overriding_log_index ON pbrc_os_overriding_log USING btree (hospital_code, hkid, case_no, update_dtm);




ALTER TABLE pbrc_os_overriding_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
