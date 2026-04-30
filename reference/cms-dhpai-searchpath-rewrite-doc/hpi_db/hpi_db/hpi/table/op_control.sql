-- op_control definition

-- Drop table

-- DROP TABLE op_control;

CREATE TABLE op_control (
	hosp_code varchar(6) NOT NULL,
	hosp_name varchar(100) NULL,
	hosp_cname varchar(120) NULL,
	opd_clinic_cname varchar(120) NULL,
	op_server_name varchar(40) NULL,
	op_server_up varchar(2) NULL,
	op_res_bk varchar(2) NULL,
	op_res_sp varchar(2) NULL,
	op_xsp_bk varchar(2) NULL,
	pre_adm varchar(2) NULL,
	opsyb varchar(2) NULL,
	opopt_prt varchar(4) NULL,
	nr_ae_qta varchar(2) NULL,
	nr_wrd_qta varchar(2) NULL,
	op_sub_def varchar(2) NULL,
	op_prt_slip varchar(40) NULL,
	op_db_name varchar(100) NOT NULL,
	op_enq_his_period int4 NULL,
	op_enq_fut_period int4 NULL,
	op_book_period int4 NULL,
	opd_2nd_clinic_cname varchar(120) NULL,
	op_new_prt_funt varchar(2) NULL,
	last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX "OP_CONTROL_IDX1" ON op_control USING btree (hosp_code);




ALTER TABLE op_control OWNER TO "HPI_SCHEMA_OWNER_ROLE";
