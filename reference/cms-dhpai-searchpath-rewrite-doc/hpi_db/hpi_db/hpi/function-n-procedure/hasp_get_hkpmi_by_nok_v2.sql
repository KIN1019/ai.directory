-- DROP PROCEDURE hpi.hasp_get_hkpmi_by_nok_v2(inout int4, in varchar, in varchar, in varchar, in int4, in varchar);

CREATE OR REPLACE PROCEDURE hasp_get_hkpmi_by_nok_v2(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_nok_hkid character varying, IN par_nok_name character varying, IN par_authority_code integer, IN par_by character varying)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code as input parm for HPI by ML on 19990814 */
/* --- 2= major nok hkid, 3 = major nok name --- */
DECLARE
    var_retcode INTEGER;
    var_pgm_name VARCHAR(50);
    var_return_code int;
    var_hkpmi_srvr VARCHAR(255);
    var_error_code INTEGER;
    var_hkpmi_down_flag VARCHAR(1);
    var_rpc_call VARCHAR(800);
    var_local_hosp VARCHAR(3);
    sql$rowcount BIGINT;
BEGIN
    /* --- CHECK HKPMI Alive --- */
    SELECT
        NULL
        INTO var_hkpmi_srvr;
--    CALL cpi_get_rpc_server('HKPMI_SERVER', var_hkpmi_srvr, var_return_code);
	SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;

    IF var_hkpmi_srvr IS NULL THEN
        pas_return_code := 200035;
        RETURN;
    END IF;
    /* *** CIS RPC HKPMI  ** */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling on
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
    set transactional_rpc on
    */

            begin
               SELECT 'hkpmi_get_hkpmi_by_nok_v2'
            INTO var_pgm_name; /* ---Default DB =download for HKPMI2 !!! */
		 SELECT concat(schema_name,'.', var_pgm_name)
		    INTO var_rpc_call
		    from hkpmi_control; /* ---Default DB =download for HKPMI2 !!! */


       begin
        perform public.dblink_connect('hkpmi_srvr'::text, var_hkpmi_srvr);
		select * from public.dblink('hkpmi_srvr'::text,'call '
			    || var_rpc_call || '('
			    || case when par_nok_hkid is null then 'null::character varying' else concat('''', par_nok_hkid, '''::character varying') end || ','
			    || case when par_nok_name is null then 'null::character varying' else concat('''', par_nok_name, '''::character varying') end || ','
			    || case when par_authority_code is null then '0' else 0 end || ','
			    || case when par_by is null then 'null::character varying' else concat('''', par_by, '''::character varying') end || ','
			    || case when par_hosp_code is null then 'null::character varying' else concat('''', par_hosp_code, '''::character varying') end
			    || ');'::text)
			    as t1(var_retcode integer);
			perform public.dblink_disconnect('hkpmi_srvr'::text);
	         exception
	        when others then
	        perform public.dblink_disconnect('hkpmi_srvr'::text);
		        end;
       
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @retcode = @rpc_call   @nok_hkid,  @nok_name,@authority_code, @by, @hosp_code
    */
    /* --- 7223, the login may be kill or existed abnormally. */
    IF var_retcode = 7223 THEN
        /* --- retry once again */
         begin
        perform public.dblink_connect('hkpmi_srvr'::text, var_hkpmi_srvr);
		select * from public.dblink('hkpmi_srvr'::text,'call '
			    || var_rpc_call || '('
			    || case when par_nok_hkid is null then 'null::character varying' else concat('''', par_nok_hkid, '''::character varying') end || ','
			    || case when par_nok_name is null then 'null::character varying' else concat('''', par_nok_name, '''::character varying') end || ','
			    || case when par_authority_code is null then '0' else 0 end || ','
			    || case when par_by is null then 'null::character varying' else concat('''', par_by, '''::character varying') end || ','
			    || case when par_hosp_code is null then 'null::character varying' else concat('''', par_hosp_code, '''::character varying') end
			    || ');'::text)
			    as t1(var_retcode integer);
			perform public.dblink_disconnect('hkpmi_srvr'::text);
	         exception
	        when others then
	        perform public.dblink_disconnect('hkpmi_srvr'::text);
		        end;
        /*
        [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
        exec @retcode = @rpc_call @nok_hkid,  @nok_name,@authority_code, @by, @hosp_code
        */
        BEGIN
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
    IF var_retcode <> 0 THEN
        pas_return_code := 200037;
        RETURN;
    END IF;
   end;
    /* return 201001 */
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_hkpmi_by_nok_v2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
