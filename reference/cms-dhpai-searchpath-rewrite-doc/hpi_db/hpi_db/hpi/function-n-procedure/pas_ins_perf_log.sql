-- DROP PROCEDURE pas_ins_perf_log(inout int4, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE pas_ins_perf_log(INOUT pas_return_code integer, IN par_hospital_cde character varying, IN par_monitor_sys character varying, IN par_monitor_type character varying, IN par_input_type character varying, IN par_func_id integer, IN par_txn_type character varying, IN par_user_id character varying, IN par_term_id character varying, IN par_start_dtm timestamp without time zone, IN par_end_dtm timestamp without time zone, IN par_rpc_server character varying, IN par_sp_name character varying, IN par_sp_rtn_code integer, IN par_input_parm1 character varying, IN par_input_parm2 character varying, IN par_input_misc_parm character varying, IN par_output_parm1 character varying, IN par_output_parm2 character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_system_dtm;

    BEGIN
        IF EXISTS (SELECT
            1
            FROM pas_monitor
            WHERE monitor_sys = par_monitor_sys AND monitor_type = par_monitor_type AND monitor_dtm < timestamp_convert(localtimestamp) AND monitor_dtm < '21000101') THEN
            BEGIN
                INSERT INTO pas_sys_perf_log (system_dtm, hosp_code, monitor_sys, input_type, func_id, txn_type, user_id, term_id, start_dtm, end_dtm, rpc_server, sp_name, sp_rtn_code, input_parm1, input_parm2, input_misc_parm, output_parm1, output_parm2, monitor_type)
                VALUES (var_system_dtm, par_hospital_cde, par_monitor_sys, par_input_type, par_func_id, par_txn_type, par_user_id, par_term_id, par_start_dtm, par_end_dtm, par_rpc_server, par_sp_name, par_sp_rtn_code, par_input_parm1, par_input_parm2, par_input_misc_parm, par_output_parm1, par_output_parm2, par_monitor_type);
            END;
        END IF;
        pas_return_code := 0;
        RETURN;
        EXCEPTION
            WHEN others THEN
                pas_return_code := 1;
                RETURN;
    END;
END;
$procedure$
;

;ALTER PROCEDURE "pas_ins_perf_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
