-- op_trans_log definition

-- Drop table

-- DROP TABLE op_trans_log;

CREATE TABLE op_trans_log (
	op_trans_sys_datetime timestamp(6) NOT NULL,
	op_trans_function_type varchar(2) NOT NULL,
	op_trans_ns_code varchar(8) NOT NULL,
	op_trans_staff_id varchar(16) NOT NULL,
	op_trans_app_datetime timestamp(6) NOT NULL,
	op_trans_app_type varchar(2) NOT NULL,
	op_trans_remark varchar(40) NULL,
	op_trans_priority_num int4 NULL,
	op_trans_opd_clinic varchar(16) NOT NULL,
	op_trans_op_num varchar(24) NULL,
	op_trans_op_hkid varchar(24) NOT NULL,
	op_trans_op_name varchar(96) NULL,
	op_trans_status varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "OP_TRANS_LOG_IDX1" ON op_trans_log USING btree (op_trans_sys_datetime);
CREATE INDEX "OP_TRANS_LOG_IDX2" ON op_trans_log USING btree (op_trans_op_hkid, op_trans_opd_clinic, op_trans_app_datetime);




ALTER TABLE op_trans_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
