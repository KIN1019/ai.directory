-- DROP PROCEDURE hpi.hasp_pbrc_check_deposit_v2(inout int4, in int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, inout numeric, inout int4, inout varchar, in varchar, in varchar, inout int4, inout varchar, inout varchar, inout int4);

CREATE OR REPLACE PROCEDURE hpi.hasp_pbrc_check_deposit_v2(INOUT pas_return_code integer, IN par_txn_type integer, IN par_hosp_code character varying, IN par_hkid character varying, IN par_adm_dtm timestamp without time zone, IN par_pay_code character varying, IN par_source_ind character varying, IN par_source_code character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_spec_code character varying, INOUT par_return_code integer, INOUT par_pbrc_os_amt numeric, INOUT par_pbrc_action_cde integer, INOUT par_pbrc_action_msg character varying, IN par_user_id character varying, IN par_term_id character varying, INOUT par_pbl_action_type integer, INOUT par_pbl_action_msg character varying, INOUT par_pbl_msg_title character varying, INOUT par_pbl_msg_default integer)
 LANGUAGE plpgsql
AS $procedure$
/* --- to select correct entry for Specialty */ 
/* ---defined as decimal in PBL */
/* --- PBRC return varchar(200) */
/* ---- 1=Y/N MsgBox ;2 =  Reject MsgBox ; 3 = Proceed without any MsgBox ; 4 = OK MsgBox */
DECLARE
    var_server_name VARCHAR(20);
    var_prog_name VARCHAR(60);
    var_pbrc_enable VARCHAR(1);
    var_rtn INTEGER;
    var_pbrc_rtn_code VARCHAR(10);
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_calling_sys VARCHAR(2);
    var_charge_code VARCHAR(2);
    var_specialty VARCHAR(4);
    var_eis_service VARCHAR(4);
    var_eis_specialty VARCHAR(4);
    var_eis_sub_spec VARCHAR(10);
    sql$rowcount BIGINT;
    var_input_parm1 VARCHAR(255);
    var_output_parm1 VARCHAR(255);
    var_start_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_end_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_txn_type_char VARCHAR(3);
BEGIN
    <<return_error>>
    BEGIN
        <<return_skip>>
        BEGIN
            SELECT
                NULL
                INTO par_pbrc_os_amt;
            SELECT
                NULL
                INTO par_pbrc_action_cde;
            SELECT
                NULL
                INTO par_pbrc_action_msg;
            SELECT
                ''
                INTO par_pbl_action_msg;
            /* APPLY to In-Patient & AE ONLY */
            IF par_txn_type <> 10 AND par_txn_type <> 30 THEN
                /* --- 10 = in-patient adm / 30 AE */
                EXIT return_skip;
            END IF;
            SELECT
                Text_value
                INTO var_pbrc_enable
                FROM Hospital_control
                WHERE Type = 'PBRC_OS_CHK_ENABLE';
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
			
            IF sql$rowcount = 0 THEN
                SELECT
                    'N'
                    INTO var_pbrc_enable;
            END IF;

            IF var_pbrc_enable = 'N' THEN
                EXIT return_skip;
            END IF;
            SELECT
                Text_value
                INTO var_server_name
                FROM Hospital_control
                WHERE Type = 'PBRC_OS_CHK_SERVER';
--               PBRC_ALL_SD7
            /* --- PBRC_ALL_SP14 */
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                EXIT return_error;
            END IF;
            /*
            --------------- --------------- ------ ---- ----- -----------
            @hospital_cde   char   3 NULL  NULL    1
            @hkid           char   12 NULL  NULL    2
            @pay_cde        char   3 NULL  NULL    3
            @calling_sys    char   2 NULL  NULL    4  @ward_class     char   1 NULL  NULL    5
            @source_ind     char   1 NULL  NULL    6
            @source_cde     char   3 NULL  NULL    7
            @eis_service    char   4 NULL  NULL    8
            @eis_specialty  char   4 NULL  NULL    9 EIS specialty of both IPAS/OPAS system
            @eis_sub_spec   char   10 NULL  NULL   10 EIS sub-specialty of OPAS system
            @charge_code      char   2 NULL  NULL    11 --pay_means  For OPAS system ; @user_id        varchar 8 NULL  NULL   12
            @os_amt         money   8 NULL  NULL   13 output
            @action_cde     int     4 NULL  NULL   14 output
            @return_message varchar  255 NULL  NULL  15 output
            */
            IF par_adm_dtm = NULL THEN
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO par_adm_dtm;
            END IF;
            SELECT
                IMIS_code
                INTO var_eis_specialty
                FROM (SELECT
                    IMIS_code, Specialty_code, Effective_date
                    FROM Specialty) AS ungrouped_query
                INNER JOIN (SELECT
                    Specialty_code, MAX(Effective_date) AS max_1
                    FROM Specialty
                    WHERE Specialty_code = par_spec_code AND Effective_date <= par_adm_dtm
                    GROUP BY Specialty_code) AS grouped_query
                    ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                WHERE Effective_date = max_1;

            IF par_txn_type = 10 THEN
                SELECT
                    'IP'
                    INTO var_calling_sys;
            END IF;

            IF par_txn_type = 30 THEN
                SELECT
                    'AE'
                    INTO var_calling_sys;
            END IF;
            SELECT
                'NI'
                INTO var_charge_code;
            SELECT
                NULL
                INTO var_eis_service; /* ---no eis_service in IPAS */
            SELECT
                NULL
                INTO var_eis_sub_spec;
            /* --- sub_specialty for OPAS case Only ? */
            SELECT
                	'public.proc_no_nonemergency_check'
                INTO var_prog_name;
            /* -------------------------------------------------------------------- */
            /* --- 2013-01-09 Eddie Add Performance Log */
            SELECT
                CONCAT(var_prog_name, '/', par_hosp_code, '/', par_hkid, '/', par_pay_code, '/', var_calling_sys, '/', par_ward_class, '/', par_source_ind, '/', par_source_code, '/', var_eis_service, '/', var_eis_specialty, '/', var_eis_sub_spec, '/', var_charge_code, '/', par_user_id)
                INTO var_input_parm1;
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_start_dtm;
            SELECT
                CAST (par_txn_type AS CHAR(3))
                INTO var_txn_type_char;
            /* ------------------------- */
            /* ---20130514--------- */
            /* ---  exec pas_ins_perf_log @hosp_code, 'PBRC', 'PBRC_OS', 'I', null, @txn_type_char, @user_id, @term_id, @start_dtm, null, */
            /* ---     @server_name, 'hasp_pbrc_check_deposit_v2', null, @input_parm1, null, null, null, null */
            /* -------------------------------------------------------------------- */
            /* --- RPC PBRC  --- */
            
            /*
            [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
            set cis_rpc_handling on
            */
            perform public.dblink_connect('PBRC_OS_CHK_SERVER'::text,var_server_name);
           	select * from public.dblink('PBRC_OS_CHK_SERVER','call '||var_prog_name || '('
|| case when par_return_code is null then 'null::INTEGER' else 0 end || ','
|| case when par_hosp_code is null then 'null::bpchar' else concat('''', par_hosp_code, '''::bpchar') end || ','
|| case when par_hkid is null then 'null::bpchar' else concat('''', par_hkid, '''::bpchar') end || ','
|| case when par_pay_code is null then 'null::bpchar' else concat('''', par_pay_code, '''::bpchar') end || ','
|| case when var_calling_sys is null then 'null::bpchar' else concat('''', var_calling_sys, '''::bpchar') end || ','
|| case when par_ward_class is null then 'null::bpchar' else concat('''', par_ward_class, '''::bpchar') end || ','
|| case when par_source_ind is null then 'null::bpchar' else concat('''', par_source_ind, '''::bpchar') end || ','
|| case when par_source_code is null then 'null::bpchar' else concat('''', par_source_code, '''::bpchar') end || ','
|| case when var_eis_service is null then 'null::bpchar' else concat('''', var_eis_service, '''::bpchar') end || ','
|| case when var_eis_specialty is null then 'null::bpchar' else concat('''', var_eis_specialty, '''::bpchar') end || ','
|| case when var_eis_sub_spec is null then 'null::bpchar' else concat('''', var_eis_sub_spec, '''::bpchar') end || ','
|| case when var_charge_code is null then 'null::bpchar' else concat('''', var_charge_code, '''::bpchar') end || ','
|| case when par_user_id is null then 'null::bpchar' else concat('''', par_user_id, '''::bpchar') end || ','
|| case when par_pbrc_os_amt is null then 'null::bpchar' else concat('''', par_pbrc_os_amt, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
|| case when par_pbrc_action_cde is null then 'null::bpchar' else concat(par_pbrc_action_cde, '::INTEGER') end || ','
|| case when par_pbrc_action_msg is null then 'null::bpchar' else concat('''', par_pbrc_action_msg, '''::bpchar') end || ');')
as t1(par_return_code INTEGER,par_pbrc_os_amt TIMESTAMP WITHOUT TIME zone,par_pbrc_action_cde INTEGER,par_pbrc_action_msg VARCHAR)
into par_return_code,par_pbrc_os_amt,par_pbrc_action_cde,par_pbrc_action_msg;
			
            /* --- 7223, the login may be kill or existed abnormally. */
            IF par_return_code = 7223 THEN
                /* --- retry once again */
                begin
	                perform public.dblink_connect('PBRC_OS_CHK_SERVER'::text,var_server_name);
           	select * from public.dblink('PBRC_OS_CHK_SERVER','call '||var_prog_name || '('
|| case when par_return_code is null then 'null::INTEGER' else 0 end || ','
|| case when par_hosp_code is null then 'null::bpchar' else concat('''', par_hosp_code, '''::bpchar') end || ','
|| case when par_hkid is null then 'null::bpchar' else concat('''', par_hkid, '''::bpchar') end || ','
|| case when par_pay_code is null then 'null::bpchar' else concat('''', par_pay_code, '''::bpchar') end || ','
|| case when var_calling_sys is null then 'null::bpchar' else concat('''', var_calling_sys, '''::bpchar') end || ','
|| case when par_ward_class is null then 'null::bpchar' else concat('''', par_ward_class, '''::bpchar') end || ','
|| case when par_source_ind is null then 'null::bpchar' else concat('''', par_source_ind, '''::bpchar') end || ','
|| case when par_source_code is null then 'null::bpchar' else concat('''', par_source_code, '''::bpchar') end || ','
|| case when var_eis_service is null then 'null::bpchar' else concat('''', var_eis_service, '''::bpchar') end || ','
|| case when var_eis_specialty is null then 'null::bpchar' else concat('''', var_eis_specialty, '''::bpchar') end || ','
|| case when var_eis_sub_spec is null then 'null::bpchar' else concat('''', var_eis_sub_spec, '''::bpchar') end || ','
|| case when var_charge_code is null then 'null::bpchar' else concat('''', var_charge_code, '''::bpchar') end || ','
|| case when par_user_id is null then 'null::bpchar' else concat('''', par_user_id, '''::bpchar') end || ','
|| case when par_pbrc_os_amt is null then 'null::bpchar' else concat('''', par_pbrc_os_amt, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
|| case when par_pbrc_action_cde is null then 'null::bpchar' else concat(par_pbrc_action_cde, '::INTEGER') end || ','
|| case when par_pbrc_action_msg is null then 'null::bpchar' else concat('''', par_pbrc_action_msg, '''::bpchar') end || ');')
as t1(par_return_code INTEGER,par_pbrc_os_amt TIMESTAMP WITHOUT TIME zone,par_pbrc_action_cde INTEGER,par_pbrc_action_msg VARCHAR)
into par_return_code,par_pbrc_os_amt,par_pbrc_action_cde,par_pbrc_action_msg;

                END;
            END IF;
            /*
            [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
            set cis_rpc_handling off
            */
           	perform public.dblink_disconnect('PBRC_OS_CHK_SERVER'::text);
           	exception
            when others then
            perform public.dblink_disconnect('PBRC_OS_CHK_SERVER'::text);
        
            /* -------------------------------------------------------------------- */
            /* --- 2013-01-09 Eddie Add Performance Log */
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_end_dtm;
            SELECT
                CONCAT(CAST (par_pbrc_os_amt AS CHAR(15)), '/', CAST (par_pbrc_action_cde AS CHAR(8)), '/', par_pbrc_action_msg)
                INTO var_output_parm1;
            CALL pas_ins_perf_log(pas_return_code, par_hosp_code, 'PBRC', 'PBRC_OS', 'O', NULL, var_txn_type_char, par_user_id, par_term_id, var_start_dtm, var_end_dtm, var_server_name, 'hasp_pbrc_check_deposit_v2', par_return_code, var_input_parm1, NULL, NULL, var_output_parm1, NULL);
            /* -------------------------------------------------------------------- */
            /* --- RPC failed --- */

            IF par_return_code <> 0 THEN
                EXIT return_error;
            END IF;
            /* --- return with PBRC values --- */
            /* pbrc_action_code : 0 = OK ; 1 = Warnning ; 2 =Blocking */
            
            /* ------------------------------------------------------------------------------------------------ */
            /* --- 20130427 to prevent the in-proper return from PBRC -->  refuse Emergency AE admission -- */
            IF par_pbrc_action_cde = 2 AND (par_source_ind = '3' AND par_txn_type = 10) THEN /* ---skip O/S for AE admission ---20130427 */
                EXIT return_skip;
            END IF;
            /* ------------------------------------------------------------------------------------------------ */
            IF par_pbrc_action_cde = 0 THEN
                BEGIN
                    pas_return_code := 0;
                    RETURN;
                END;
            END IF;
            /* --- Warning =>  Info / OK MsgBox */

            IF par_pbrc_action_cde = 1 THEN
                BEGIN
                    SELECT
                        4
                        INTO par_pbl_action_type;
                    /* ---- 4= OK MsgBox ; */
                    SELECT
                        'Information from PBRC'
                        INTO par_pbl_msg_title;
                END;
            END IF;
            /* ---- BlOCKing for HN/AE Case if  pbrc_action_cde = 2 */
            /* ---  => Prompt "YES/NO" MsgBox :  IPAS user to override or NOT */

            IF par_pbrc_action_cde = 2 THEN
                BEGIN
                    SELECT
                        1
                        INTO par_pbl_action_type;
                    /* ---- 1=Y/N MsgBox ; */
                    SELECT
                        'Registration is Blocked'
                        INTO par_pbl_msg_title;
                    SELECT
                        2
                        INTO par_pbl_msg_default; /* --Default ='No' */
                    SELECT
                        'Please click "Yes"  to release blocking or click "No" to return to registration screen.'
                        INTO par_pbl_action_msg;
                    /* ----select @pbl_action_msg='Please click "Yes" to release blocking (document proof is required) or click "No" to return to registration screen.' */
                END;
            END IF;
            /*
            select @pbl_action_type = 2  ---- 2 =  Reject MsgBox ;
            select @pbl_action_type = 3  ---- 3 = Proceed without any MsgBox
            */
            pas_return_code := par_return_code;
            RETURN;
            /* --- skip PBRC checking --- */
        END;
        SELECT
            NULL, NULL, NULL, NULL, ''
            INTO par_pbrc_os_amt, par_pbrc_action_cde, par_pbrc_action_msg, par_pbl_action_type, par_pbl_action_msg;
        SELECT
            1
            INTO par_return_code;
        pas_return_code := 1;
        RETURN;
        /* ---PBRC checking error --- */
    END;
    SELECT
        NULL, NULL, NULL, NULL, ''
        INTO par_pbrc_os_amt, par_pbrc_action_cde, par_pbrc_action_msg, par_pbl_action_type, par_pbl_action_msg;
    SELECT
        - 1
        INTO par_return_code;
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_pbrc_check_deposit_v2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
