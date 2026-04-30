-- pas_sys_perf_log definition

-- Drop table

-- DROP TABLE pas_sys_perf_log;

CREATE TABLE pas_sys_perf_log (
	system_dtm timestamp(6) NOT NULL,
	hosp_code varchar(6) NOT NULL,
	monitor_sys varchar(24) NOT NULL,
	input_type varchar(6) NOT NULL,
	func_id int4 NULL,
	txn_type varchar(6) NULL,
	user_id varchar(24) NULL,
	term_id varchar(30) NULL,
	start_dtm timestamp(6) NULL,
	end_dtm timestamp(6) NULL,
	rpc_server varchar(50) NULL,
	sp_name varchar(100) NULL,
	sp_rtn_code int4 NULL,
	input_parm1 varchar(510) NULL,
	input_parm2 varchar(510) NULL,
	input_misc_parm varchar(510) NULL,
	output_parm1 varchar(510) NULL,
	output_parm2 varchar(510) NULL,
	monitor_type varchar(20) NULL,
	last_update_datetime timestamp(6) NULL,
	record_id int4 NOT NULL --identity column updated by sequence for CDC
);

CREATE INDEX "XPKpas_sys_perf_log" ON pas_sys_perf_log USING btree (system_dtm, monitor_type);

-- Such index was created in both Sybase & PG for NineData CDC (Refer to IPAS-955)
--CREATE UNIQUE INDEX "pas_sys_perf_log_ui" ON pas_sys_perf_log USING btree (system_dtm, hosp_code, monitor_sys, input_type, func_id, txn_type,user_id, term_id, start_dtm, end_dtm, rpc_server, sp_name, sp_rtn_code, input_parm1, input_parm2, input_misc_parm, output_parm1, output_parm2,monitor_type);
CREATE UNIQUE INDEX "pas_sys_perf_log_ui" ON pas_sys_perf_log USING btree (record_id);

ALTER TABLE pas_sys_perf_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
