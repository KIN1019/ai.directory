-- DROP PROCEDURE hpi.hasp_get_pp_opt_out_info(inout int4, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_pp_opt_out_info(INOUT pas_return_code integer, IN par_hkid character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rtn_code INTEGER;
    var_hkpmi_srvr VARCHAR(255);
    var_retcode INTEGER;
    var_rpc_call VARCHAR(200);
    var_pgm_name VARCHAR(100);
    var_return_code int;
    var_db_sql text;
    var_err_msg text;
    p_refcur refcursor;
BEGIN
    <<return_error>>
    BEGIN
        /* --- CHECK HKPMI Alive --- */
        SELECT
            NULL
            INTO var_hkpmi_srvr;
        /* ---exec cpi..cpi_get_rpc_server 'HKPMI_SERVER',@hkpmi_srvr output */
        CALL cpi_get_rpc_server(var_return_code, 'HKPMI_SERVER', var_hkpmi_srvr, null); /* ---HPI Ver */

        IF var_hkpmi_srvr IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                EXIT return_error;
            END;
        END IF;

        /*/* ---set transactional_rpc on */
        SELECT concat(schema_name,'.hkpmi_get_pp_opt_out_info')  
        INTO var_rpc_call
        from hkpmi_control;

        /* --- 7223, the login may be kill or existed abnormally. */


        var_db_sql := 'select * from ' || var_rpc_call || '('
            || case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end || ') as t1(refcursor)';
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
                    SELECT
                        -2
                        INTO var_rtn_code;
                    perform dblink_disconnect('HKPMI_SERVER');
                    EXIT return_error;
                END;
        END;
        perform dblink_disconnect('HKPMI_SERVER');*/

       	-- replace_dblink_by_fdw
       	OPEN p_refcur FOR 
       	SELECT * FROM hkpmi.hkpmi_get_pp_opt_out_info(par_hkid);
	   	SET search_path TO hpi,public;
	   
        /* ---	set transactional_rpc on */
        pas_return_code := 0;
        RETURN;

        <<return_normal>>
        BEGIN
        END;
    END;

    /* ---	set transactional_rpc on */
    pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_pp_opt_out_info" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
