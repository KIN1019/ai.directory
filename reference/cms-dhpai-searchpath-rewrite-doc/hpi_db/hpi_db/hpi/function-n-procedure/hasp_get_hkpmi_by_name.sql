-- DROP PROCEDURE hpi.hasp_get_hkpmi_by_name(inout int4, in varchar, in varchar, in varchar, in timestamp, in timestamp, in int4);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_hkpmi_by_name(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_name character varying, IN par_sex character varying, IN par_from_dob timestamp without time zone, IN par_to_dob timestamp without time zone, IN par_authority_code integer)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code as input parm for HPI by ML on 14.08.1999 */
DECLARE
    var_hkpmi_srvr VARCHAR(255);
    var_rpc_call VARCHAR(120);
    var_error_code INTEGER;
    var_hkpmi_down_flag VARCHAR(2);
    var_local_hosp VARCHAR(6);
    sql$rowcount BIGINT;
    var_return_code int;
    var_db_sql text;
    var_err_msg text;
    p_refcur refcursor;
BEGIN
    /* @hosp_code      char(3) */
    
    /* remark as hosp_code become input parm */
    
    /* add hosp code for HPI by ML on 14.08.1999 */
	pas_return_code := 0;
    SELECT
        text_value
        INTO var_hkpmi_srvr
        FROM hospital_control
        WHERE "type" = 'hkpmi_server' AND hospital_code = par_hosp_code;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount <> 1 THEN
        pas_return_code := 200035;
        RETURN;
    END IF;
    /* remarked to get hosp_code from input parm */
    /*
    select @hosp_code = Hospital_code from Hospital
    
    if @@rowcount <> 1
       return 200036
    */
    /* ----------20120105 Check HKPMI down Flag-------------------- */
    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        hospital_code
        INTO var_local_hosp
        FROM hospital_config;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount <> 1 THEN
        pas_return_code := 200036;
        RETURN;
    END IF;
    SELECT
        appl_ctl_text_value
        INTO var_hkpmi_down_flag
        FROM pas_appl_control
        WHERE hospital_code = var_local_hosp AND appl_name = 'IPAS' AND appl_ctl_type = 'HKPMI_SP1_DOWN';

    IF var_hkpmi_down_flag = 'Y' THEN
        BEGIN
            SELECT
                NULL
                INTO var_hkpmi_srvr;
            /* --exec cpi..cpi_get_rpc_server 'HKPMI_READ_ONLY_SVR', @hkpmi_srvr	output */
            CALL cpi_get_rpc_server('HKPMI_READ_ONLY_SVR', var_hkpmi_srvr, var_return_code);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    pas_return_code := 200035;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* ------------------------------------------------ */
    /* ---select @prg_name = rtrim(@hkpmi_srvr) + "...hkpmi_get_hkpmi_by_name" */
    SELECT concat(schema_name,'.hkpmi_get_hkpmi_by_name')  
    INTO var_rpc_call
    from hkpmi_control;
         /* ---Default DB =download for HKPMI2 !!! */
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @error_code = @rpc_call @name, @sex, @from_dob, @to_dob,
                          @authority_code, @hosp_code
    */

    CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);
    IF var_hkpmi_srvr IS NULL THEN
        BEGIN
            pas_return_code := 200016;
            RETURN;
        END;
    END IF;
    
    var_db_sql := 'select * from ' || var_rpc_call || '('
        || case when par_name is null then 'null::varchar' else concat('''', par_name, '''::varchar') end || ','
        || case when par_sex is null then 'null::varchar' else concat('''', par_sex, '''::varchar') end || ','
        || case when par_from_dob is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_from_dob, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
        || case when par_to_dob is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_to_dob, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
        || case when par_authority_code is null then 'null::INTEGER' else concat('''', par_authority_code, '''::INTEGER') end || ','
        || case when par_hosp_code is null then 'null::varchar' else concat('''', par_sex, '''::varchar') end || ');';
    raise notice 'db_sql: %', var_db_sql;
    perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
    SET search_path TO hpi, public;
    BEGIN
        select * from dblink('HKPMI_SERVER', var_db_sql) as t1(p refcursor) into p_refcur;
        EXCEPTION
        WHEN others THEN
            BEGIN
                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
                raise notice 'call % error: %', var_rpc_call, var_err_msg;
                pas_return_code := 201001;
            END;
    END;
    perform dblink_disconnect('HKPMI_SERVER');

    RETURN;
    /* return 201001 */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_hkpmi_by_name" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
