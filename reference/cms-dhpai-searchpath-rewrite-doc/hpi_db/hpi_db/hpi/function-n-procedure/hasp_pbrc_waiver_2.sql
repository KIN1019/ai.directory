-- DROP PROCEDURE hpi.hasp_pbrc_waiver_2(inout int4, in bpchar, in bpchar, in bpchar, inout bpchar, inout bpchar, inout bpchar, inout timestamp, inout timestamp, in bpchar, inout int4, inout varchar, inout numeric, in bpchar, in timestamp, inout numeric, inout bpchar, inout bpchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_pbrc_waiver_2(INOUT pas_return_code integer, IN par_hosp_code character, IN par_hkid character, IN par_transaction_type character, INOUT par_waiver_no character, INOUT par_waiver_type character, INOUT par_waiver_issue_party character, INOUT par_waiver_eff_date timestamp without time zone, INOUT par_waiver_exp_date timestamp without time zone, IN par_update_by character, INOUT par_return_code integer, INOUT par_pbrc_msg character varying, INOUT par_waiver_percent numeric, IN par_case_type character DEFAULT 'AE'::bpchar, IN par_service_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_paid_amount numeric DEFAULT NULL::numeric, INOUT par_new_waiver_type character DEFAULT NULL::bpchar, INOUT par_upd_sys character DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_server_name VARCHAR(20);
    var_prog_name VARCHAR(60);
    /* --@update_dtm datetime, @source_system VARCHAR(5), @update_hosp VARCHAR(3), */
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_source_system VARCHAR(10);
    var_update_hosp VARCHAR(3);
    var_pbrc_ret_code INTEGER;
    var_update_reason VARCHAR(20);
    var_pbrc_enable VARCHAR(1);
    var_percentage DOUBLE PRECISION;
    var_eis_service VARCHAR(4);
    var_gopc_type VARCHAR(1);
    var_in_cssa_cust_k INTEGER;
    var_in_cssa_case_k INTEGER;
    var_cssa_cust_key INTEGER;
    var_cssa_case_key INTEGER;
    sql$rowcount BIGINT;
    var_input_parm1 VARCHAR(255);
    var_output_parm1 VARCHAR(255);
    var_start_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_end_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_return_code int;
    
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_gopc_type, var_in_cssa_cust_k, var_in_cssa_case_k, var_cssa_cust_key, var_cssa_case_key;
        SELECT
            ' '
            INTO var_eis_service;
        SELECT
            Text_value
            INTO var_pbrc_enable
            FROM Hospital_control
            WHERE Type = 'PBRC_WAIVER_ENABLE';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            SELECT
                'N'
                INTO var_pbrc_enable;
        END IF;

        IF var_pbrc_enable = 'N' THEN
            BEGIN
                SELECT
                    - 1, NULL, NULL, NULL, NULL, NULL
                    INTO par_return_code, par_waiver_no, par_waiver_eff_date, par_waiver_exp_date, par_waiver_type, par_waiver_issue_party;
                raise exception '';
            END;
        END IF;

        IF par_waiver_issue_party <> 'MSW' THEN
            SELECT
                'PA'
                INTO par_waiver_issue_party;
        END IF;

        IF par_transaction_type = 'I' THEN
            BEGIN
                SELECT
                    Text_value
                    INTO var_server_name
                    FROM Hospital_control
                    WHERE Type = 'PBRC_INQ_WAIVER';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    SELECT
                        NULL
                        INTO var_server_name;
                END IF;
            END;
        ELSE
            BEGIN
                SELECT
                    Text_value
                    INTO var_server_name
                    FROM Hospital_control
                    WHERE Type = 'PBRC_UPD_WAIVER';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    SELECT
                        NULL
                        INTO var_server_name;
                END IF;
            END;
        END IF;

        IF var_server_name IS NULL THEN
            BEGIN
                SELECT
                    Text_value
                    INTO var_server_name
                    FROM Hospital_control
                    WHERE Type = 'PBRC_DEF_WAIVER';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* -------------------------------------------------------------------- */
        /* --- 2013-02-08 Eddie Add Performance Log */
        
        /* -------------------------------------------------------------------- */
        
        /*
        [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
        set cis_rpc_handling on
        */
        
        /*
        [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
        set transactional_rpc on
        */
        IF par_transaction_type = 'I' THEN
            BEGIN
                /*
                if @waiver_issue_party = 'PA'
                begin
                	select @prog_name = rtrim(@server_name) + '...proc_s_cssa_waiver'
                	exec @return_code = @prog_name @hkid, @waiver_no out,
                		@waiver_eff_date out, @waiver_exp_date out, @update_reason out,
                		@update_by out, @update_hosp out, @source_system out,
                		@update_dtm out, @pbrc_ret_code out, @pbrc_msg out
                end
                else
                begin
                */
                /* ---select @prog_name = rtrim(@server_name) + '...proc_s_central_waiver_2' */
                SELECT
                    CONCAT(RTRIM(var_server_name), '...proc_s_central_waiver_4')
                    INTO var_prog_name;
                /* -------------------------------------------------------------------- */
                /* --- 2013-02-08 Eddie Add Performance Log */
                SELECT
                    CONCAT(var_prog_name, '/', par_hosp_code, '/', par_hkid, '/', par_waiver_issue_party, '/', par_case_type, '/', var_eis_service, '/',to_char(par_service_dtm::TIMESTAMP WITHOUT TIME ZONE,'YYYYMMDD'), ' ', to_char(par_service_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS'), '/', var_gopc_type, '/', var_in_cssa_cust_k::varchar, '/', var_in_cssa_case_k::varchar)
                    INTO var_input_parm1;
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO var_start_dtm;
                /* ------------------------------ */
                /* ---20130514 */
                /* ----- exec pas_ins_perf_log @hosp_code, 'PBRC', 'PBRC_WAIVE', 'I', null, @transaction_type, @update_by, null, @start_dtm, null, */
                /* ---      @server_name, 'hasp_pbrc_waiver_2', null, @input_parm1, null, null, null, null */
                
                /* -------------------------------------------------------------------- */
                
				
			    RAISE NOTICE 'Executing dblink1: var prog_name%',var_prog_name;
                /*
                [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
                exec @return_code = @prog_name @hkid, @waiver_issue_party, @case_type,
                				@eis_service, @service_dtm,@gopc_type,@in_cssa_cust_k,@in_cssa_case_k,
                				@waiver_no out, @waiver_eff_date out, @waiver_exp_date out,
                				@percentage out, @paid_amount out, @update_reason out,
                				@update_by out, @update_hosp out, @source_system out,
                				@update_dtm out, @pbrc_ret_code out, @pbrc_msg out,@cssa_cust_key out,@cssa_case_key out,
                				@new_waiver_type out
                */
                
                /* -------------------------------------------------------------------- */
                /* --- 2013-02-08 Eddie Add Performance Log */
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO var_end_dtm;
                SELECT
                    CONCAT(par_waiver_no, '/', to_char(par_waiver_eff_date::TIMESTAMP WITHOUT TIME ZONE,'YYYYMMDD'), ' ', to_char(par_waiver_eff_date::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS'), '/', to_char(par_waiver_exp_date::TIMESTAMP WITHOUT TIME ZONE,'YYYYMMDD'), ' ', to_char(par_waiver_exp_date::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS'), '/', CAST (var_percentage AS VARCHAR(8)), '/', CAST (par_paid_amount AS VARCHAR(15)), '/', var_update_reason, '/', par_update_by, '/', var_update_hosp, '/', var_source_system, '/', to_char(var_update_dtm::TIMESTAMP WITHOUT TIME ZONE,'YYYYMMDD'), ' ', to_char(var_update_dtm::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS'), '/', CAST (var_pbrc_ret_code AS VARCHAR(8)), '/', par_pbrc_msg, '/', var_cssa_cust_key::varchar, '/', var_cssa_case_key::varchar, + '/', par_new_waiver_type)
                    INTO var_output_parm1;
                CALL pas_ins_perf_log(var_return_code,par_hosp_code, 'PBRC', 'PBRC_WAIVE', 'O', NULL, par_transaction_type, par_update_by, NULL, var_start_dtm, var_end_dtm, var_server_name, 'hasp_pbrc_waiver_2', par_return_code, var_input_parm1, NULL, NULL, var_output_parm1, NULL );
               
                /* -------------------------------------------------------------------- */
                SELECT
                    var_percentage
                    INTO par_waiver_percent;
                SELECT
                    var_source_system
                    INTO par_upd_sys;
                /* end */
            END;
        ELSE
            BEGIN
                SELECT
                    timestamp_convert(localtimestamp), 'ADT', par_hosp_code, ''
                    INTO var_update_dtm, var_source_system, var_update_hosp, var_update_reason;
                /*
                if @waiver_issue_party = 'PA'
                begin
                	select @prog_name = rtrim(@server_name) + '...proc_u_cssa_waiver'
                	exec @return_code = @prog_name @hkid, @waiver_no,
                		@waiver_eff_date, @waiver_exp_date, @update_reason,
                		@update_by, @update_hosp, @source_system,
                		@pbrc_ret_code out, @pbrc_msg out
                end
                else
                begin
                */
                SELECT
                    par_waiver_percent
                    INTO var_percentage;
                SELECT
                    CONCAT(RTRIM(var_server_name), '...proc_u_central_waiver_2')
                    INTO var_prog_name;
                /* ---20131119 --- */
                IF par_new_waiver_type IS NULL OR LTRIM(RTRIM(par_new_waiver_type)) = '' THEN
                    SELECT
                        'M2'
                        INTO par_new_waiver_type;
                END IF;
                /* -------------------------------------------------------------------- */
                /* --- 2013-02-08 Eddie Add Performance Log */
                SELECT
                    CONCAT(var_prog_name, '/', par_hosp_code, '/', par_hkid, '/', par_waiver_no, '/', par_waiver_issue_party, '/', par_case_type, '/', var_eis_service, '/', CAST (var_percentage AS VARCHAR(8)), '/', CAST (par_paid_amount AS VARCHAR(15)), '/', to_char(par_waiver_eff_date::TIMESTAMP WITHOUT TIME ZONE,'YYYYMMDD'), ' ', to_char(par_waiver_eff_date::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS'), '/', to_char(par_waiver_exp_date::TIMESTAMP WITHOUT TIME ZONE,'YYYYMMDD'), ' ', to_char(par_waiver_exp_date::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS'), '/', var_update_reason, '/', par_update_by, '/', var_update_hosp, '/', var_source_system, '/', par_new_waiver_type)
                    INTO var_input_parm1;
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO var_start_dtm;
                /* -------------- */
                
                /* ----20130514 */
                
                /* ---exec pas_ins_perf_log @hosp_code, 'PBRC', 'PBRC_WAIVE', 'I', null, @transaction_type, @update_by, null, @start_dtm, null, */
                /* ----      @server_name, 'hasp_pbrc_waiver_2', null, @input_parm1, null, null, null, null */
                
                /* -------------------------------------------------------------------- */
                RAISE NOTICE 'Executing dblink2: var prog_name%',var_prog_name;

                /*
                [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
                exec @return_code = @prog_name @hkid, @waiver_no,
                				@waiver_issue_party, @case_type, @eis_service, @percentage,
                				@paid_amount, @waiver_eff_date, @waiver_exp_date, @update_reason,
                				@update_by, @update_hosp, @source_system,
                				@pbrc_ret_code out, @pbrc_msg out,
                				@new_waiver_type
                */
                
                /* end */
                
                /* -------------------------------------------------------------------- */
                /* --- 2013-02-08 Eddie Add Performance Log */
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO var_end_dtm;
                SELECT
                    CONCAT(CAST (var_pbrc_ret_code AS VARCHAR(8)), '/', par_pbrc_msg, par_new_waiver_type)
                    INTO var_output_parm1;
                CALL pas_ins_perf_log(var_return_code,par_hosp_code, 'PBRC', 'PBRC_WAIVE', 'O', NULL, par_transaction_type, par_update_by, NULL, var_start_dtm, var_end_dtm, var_server_name, 'hasp_pbrc_waiver_2', par_return_code, var_input_parm1, NULL, NULL, var_output_parm1, NULL);
                /* -------------------------------------------------------------------- */
            END;
        END IF;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
        set cis_rpc_handling off
        */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
        set transactional_rpc off
        */
        IF par_return_code <> 0 THEN
            BEGIN
                /* --		select @return_code = -1 */
                raise exception '';
            END;
        END IF;

        IF var_pbrc_ret_code <> 0 THEN
            BEGIN
                SELECT
                    var_pbrc_ret_code
                    INTO par_return_code;
                raise exception '';
            END;
        END IF;
        SELECT
            0
            INTO par_return_code;
    END;
    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_pbrc_waiver_2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";