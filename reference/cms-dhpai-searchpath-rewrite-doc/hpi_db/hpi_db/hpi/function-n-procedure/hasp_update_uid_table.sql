-- DROP FUNCTION hasp_update_uid_table(varchar, varchar, varchar, varchar, varchar, timestamp, varchar, varchar, varchar, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_update_uid_table(par_action character varying, par_hosp_code character varying, par_uid_hkid character varying, par_link_hkid character varying, par_link_status character varying DEFAULT NULL::character varying, par_create_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, par_create_hospital character varying DEFAULT NULL::character varying, par_create_user character varying DEFAULT NULL::character varying, par_create_system character varying DEFAULT NULL::character varying, par_update_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, par_update_hospital character varying DEFAULT NULL::character varying, par_update_user character varying DEFAULT NULL::character varying, par_update_system character varying DEFAULT NULL::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	 p_refcur refcursor;
	 var_refcur refcursor;
/* --fo EU only */
/* for EU/EL ,10=uid found,11=link_id found */
	var_error_msg VARCHAR(255);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_raiserror_msg VARCHAR(255);
    var_rpc_call VARCHAR(100);
    var_pgm_name VARCHAR(50);
    var_rpc_rtn_code INTEGER;
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_cnt INTEGER;
    var_exit_flag VARCHAR(1);
    var_success_flag VARCHAR(01);
    var_retcode INTEGER;
    var_db_sql text;
    var_err_msg text;
    var_return_code int;
    var_ret_code int;
    var_hkpmi_srvr VARCHAR(255);
    var_return_hkid bpchar;
    var_return_msg VARCHAR(255);
BEGIN
	SELECT
	    'Y'
	INTO var_success_flag;

	SELECT
	    0, 0, NULL, NULL
	INTO var_rpc_rtn_code, var_error, var_error_msg, var_raiserror_msg;
	/* ----------- basic rules checking --------- */
	
	IF par_action NOT IN ('U', 'CU', 'CL', 'EU', 'EL') THEN /* ---'AL' will called by hkpmi_admission directly ... */
	
		BEGIN
			SELECT
			    - 2
			INTO var_return_code;
			SELECT
			    'Invalid Action Type !'
			INTO var_return_msg;
			var_return_code := - 2;
			            RETURN;
		END;
	END IF;
	
    IF par_hosp_code = NULL OR (par_uid_hkid = NULL AND par_link_hkid = NULL) THEN
		BEGIN
			SELECT
			    - 3
			INTO var_return_code;
			SELECT
			    'Hosp / Uid / Link HKID NULL !'
			INTO var_return_msg;
			var_return_code := - 3;
			            RETURN;
		END;
	END IF;
	    /*
	    20081229 SL : directly update hkpmi_uid_table instead of cpi_upload temporary
	    ------------------------------------------------------------------
	    --------A). using cpi_upload for Update operation-------------------
	    --------------------------------------------------------------------
	    if @action ='U'
	    begin
	
	       exec @retcode = cpi_insert_uid_tran  @hosp_code,'265',@uid_hkid,@link_hkid,@link_status,
	    				@update_dtm,@update_hospital,@update_user, @update_system,@return_code output,@return_msg output
	
	       if @retcode <0
	       begin
	    	  select @return_code = @retcode
	    		select @return_msg = 'call cpi_insert_uid_tran error !'
	    	  return @retcode
	       end
	    	select @return_code =0
	    	return 0
	    end
	    else
	    ---------------------------------------------------------------------
	    --- B). Direct accessing hkpmi_uid_table for Check/Enq UID List -----
	    ---------------------------------------------------------------------
	    begin
	    */
	    /* --- CHECK HKPMI Alive --- */
	SELECT
	    NULL
	INTO var_hkpmi_srvr;
	/* ---exec cpi..cpi_get_rpc_server 'HKPMI_SERVER',@hkpmi_srvr output */
	--    CALL cpi_get_rpc_server('HKPMI_SERVER', var_hkpmi_srvr, var_return_code); /* ---HPI Ver */
	
	SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;
	
	IF var_hkpmi_srvr IS NULL THEN
		BEGIN
			SELECT
			    - 5
			INTO var_return_code;
			SELECT
			    'HKPMI server Down !'
			INTO var_return_msg;
			var_return_code := - 5;
			            RETURN;
		END;
	END IF;
	    /* --------------RPC to HKPMI -------------- */
	
	BEGIN
	       /*perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
		        RAISE NOTICE 'dblink connection established';
	
	SELECT '.hkpmi_update_uid_table'
	INTO var_pgm_name; /* ---Default DB =download for HKPMI2 !!! */
	SELECT
	    concat(schema_name, var_pgm_name)
	INTO var_rpc_call
	FROM hkpmi_control;
	
	begin
	   		 var_db_sql := 'call ' || var_rpc_call || '('
			    || case when var_return_code is null then '0' else 0 end  || ','
			    || case when par_action is null then 'null::bpchar' else concat('''', par_action, '''::bpchar') end || ','
			    || case when par_hosp_code is null then 'null::bpchar' else concat('''',par_hosp_code, '''::bpchar') end || ','
			    || case when par_uid_hkid is null then 'null::bpchar' else concat('''', par_uid_hkid, '''::bpchar') end || ','
			    || case when par_link_hkid is null then 'null::bpchar' else concat('''', par_link_hkid, '''::bpchar') end || ','
			    || case when par_link_status is null then 'null::bpchar' else concat('''', par_link_status, '''::bpchar') end || ','
			    || case when par_create_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_create_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			    || case when par_create_hospital is null then 'null::bpchar' else concat('''', par_create_hospital, '''::bpchar') end || ','
			    || case when par_create_user is null then 'null::bpchar' else concat('''', par_create_user, '''::bpchar') end || ','
			    || case when par_create_system is null then 'null::bpchar' else concat('''', par_create_system, '''::bpchar') end || ','
			    || case when par_update_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_update_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			    || case when par_update_hospital is null then 'null::bpchar' else concat('''', par_update_hospital, '''::bpchar') end || ','
			    || case when par_update_user is null then 'null::bpchar' else concat('''', par_update_user, '''::bpchar') end || ','
			    || case when par_update_system is null then 'null::bpchar' else concat('''', par_update_system, '''::bpchar') end || ','
			    || case when var_return_hkid is null then 'null::bpchar' else concat('''', var_return_hkid, '''::bpchar') end || ','
			    || case when var_return_code is null then '0' else 0 end || ','
			    || case when var_return_msg is null then 'null::character varying'  else concat('''', var_return_msg, '''::character varying') end || ');';
				    raise notice '%', var_db_sql;
		begin
			SELECT * FROM dblink('HKPMI_SERVER', var_db_sql) AS t1(
			    var_return_code integer,
			    var_return_hkid bpchar,
			    var_ret_code integer,
			    var_return_msg character varying, 
			    var_refcur refcursor
			) into  var_return_code, var_return_hkid, var_ret_code, var_return_msg, p_refcur;
			
	        raise notice 'var_return_code % p_refcur: %', var_return_code, p_refcur;
	       
        perform public.dblink_disconnect('HKPMI_SERVER'::text);
                                         
		exception WHEN others THEN
			begin
				perform public.dblink_disconnect('HKPMI_SERVER'::text);
                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
                raise notice 'call % error: %', var_rpc_call, var_err_msg;
                var_return_code := 201001;
			END;
		END;
	END;*/
		
		-- replace_dblink_by_fdw	                    
        CALL hkpmi.hkpmi_update_uid_table(var_return_code, par_action, par_hosp_code, par_uid_hkid, 
        par_link_hkid, par_link_status, par_create_dtm, par_create_hospital, par_create_user, 
        par_create_system, par_update_dtm, par_update_hospital, par_update_user, par_update_system,
        var_return_hkid, var_return_code, var_return_msg, p_refcur);
       	raise notice 'var_return_code % p_refcur: %', var_return_code, p_refcur;
       	SET search_path TO hpi,public;
	
	END;
	
--	    /* --- 7223, the login may be kill or existed abnormally. */
--	    IF var_rpc_rtn_code = 7223 THEN
--	        /* --- retry once again */
--	
--	        /*
--	        [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
--	        exec @rpc_rtn_code = @rpc_call
--	        				@action, @hosp_code,
--	        				@uid_hkid,@link_hkid,@link_status,
--	        				@create_dtm,@create_hospital,@create_user,@create_system,
--	        				@update_dtm,@update_hospital,@update_user,@update_system,
--	        				@return_hkid output,@return_code output,@return_msg output
--	        */
--	BEGIN
--	END;
--	END IF;

--    CLOSE p_refcur;

RETURN NEXT p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_update_uid_table" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
