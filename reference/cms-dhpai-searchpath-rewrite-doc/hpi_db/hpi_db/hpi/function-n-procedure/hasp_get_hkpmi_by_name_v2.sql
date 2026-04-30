-- DROP PROCEDURE hpi.hasp_get_hkpmi_by_name_v2(inout int4, in varchar, in varchar, in varchar, in timestamp, in timestamp, in int4);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_hkpmi_by_name_v2(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_name character varying, IN par_sex character varying, IN par_from_dob timestamp without time zone, IN par_to_dob timestamp without time zone, IN par_authority_code integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hkpmi_srvr VARCHAR(255);
    var_retcode INTEGER;
    var_rpc_call VARCHAR(200);
    var_pgm_name VARCHAR(100);
    var_hkpmi_down_flag VARCHAR(2);
    var_local_hosp VARCHAR(3);
    var_return_code int;
    var_db_sql text;
    var_err_msg text;
    p_refcur refcursor;
BEGIN
    /* @hosp_code      char(3) */
    
    /* ----------20120105 Check HKPMI down Flag-------------------- */
    pas_return_code := 0;
    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        hospital_code
        INTO var_local_hosp
        FROM hospital_config;
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
                    pas_return_code := 200016;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* ------------------------------------------------ */
    /* *** CIS RPC HKPMI  ** */
    /* ---Default DB =download for HKPMI2 !!! */

    SELECT concat(schema_name,'.hkpmi_get_hkpmi_by_name_v2')  
    INTO var_rpc_call
    from hkpmi_control;
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
                pas_return_code := 200037;
            END;
    END;
    perform dblink_disconnect('HKPMI_SERVER');
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_hkpmi_by_name_v2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
