-- DROP FUNCTION hpi.hasp_get_data(varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_get_data(par_hosp_code character varying, par_hkid character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	 p_refcur refcursor;
     var_retcode INTEGER;
     var_error INTEGER;
     var_hkpmi_srvr VARCHAR(255);
    /* @hosp_code      VARCHAR(3) */
    /* @gateway_id     VARCHAR(8), */
    /* @cics_id        VARCHAR(8), */
    /* @cics_pgm_id    VARCHAR(8), */
     var_rpc_call VARCHAR(120);
     var_pgm_name VARCHAR(60);
     var_hkpmi_down_flag VARCHAR(1);
     var_local_hosp VARCHAR(3);
     sql$rowcount BIGINT;
     var_return_code int;
     var_db_sql text;
     var_err_msg text;
     var_case_no character varying;
     var_adt1 text;
     var_adt2 text;
     var_adt3 text;
     var_adt4 text;
     var_destination_code character varying;
     var_last_specialty_code character varying;
     var_last_ward_code character varying;
BEGIN
    /*
    select @gateway_id = Gateway_ID,
           @cics_id    = CICS_ID,
           @hosp_code  = Hospital_code
    from Hospital
    */
    /* add hosp code for HPI by ML on 06.08.1999 */
    SELECT
        text_value
        INTO var_hkpmi_srvr
        FROM hospital_control
        WHERE type = 'hkpmi_server' AND hospital_code = par_hosp_code;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        BEGIN
            var_retcode := 200016;
            RETURN;
        END;
    END IF;
    /* ----------20120105 Check HKPMI down Flag-------------------- */
    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        Hospital_code
        INTO var_local_hosp
        FROM Hospital;
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
            /* ---exec cpi..cpi_get_rpc_server 'HKPMI_READ_ONLY_SVR', @hkpmi_srvr	output ---- CPI */
            CALL cpi_get_rpc_server('HKPMI_READ_ONLY_SVR', var_hkpmi_srvr, var_return_code);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    var_retcode := 200016;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* ------------------------------------------------ */

    /* ----select @rpc_call = rtrim(@hkpmi_srvr) + ... + rtrim(@pgm_name) */
    /* --- updated for  exec HA_HKPMI_SP2_SB.hkpmi..hkpmi_r_case_list ---- */
--    SELECT
--        CONCAT(RTRIM(var_hkpmi_srvr), '.hkpmi..', RTRIM(var_pgm_name))
--        INTO var_rpc_call;
   
       CREATE TEMP TABLE temp_results (
        var_local_hosp character varying,
        var_case_no character varying,
        var_adt1 text,
        var_adt2 text,
        var_adt3 text,
        var_adt4 text,
        var_destination_code character varying,
        var_last_specialty_code character varying,
        var_last_ward_code character varying
    ) ON COMMIT DROP;
   
     begin
	       
	    SELECT concat(schema_name,'.hkpmi_r_case_list')  
	    INTO var_rpc_call
	    from hkpmi_control;
	   
	    CALL cpi_get_rpc_server(var_retcode, 'HKPMI_SERVER', var_hkpmi_srvr);
	    IF var_hkpmi_srvr IS NULL THEN
	        BEGIN
	            var_retcode := 200016;
	            RETURN;
	        END;
	    END IF;
				   
	       begin
		       
	    	   perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
	       
	           var_db_sql := 'select * from ' || var_rpc_call || '('
	      		  || case when par_hkid is null then 'null::bpchar' else concat('''', par_hkid, '''::bpchar') end || ');';
			    raise notice '%', var_db_sql;
			   
	           INSERT INTO temp_results
		           select * from dblink('HKPMI_SERVER', var_db_sql)  as t1(var_local_hosp character varying,
			            var_case_no character varying,
			             var_adt1 text,
			             var_adt2 text,
			             var_adt3 text,
			             var_adt4 text,
			             var_destination_code character varying,
			             var_last_specialty_code character varying,
			             var_last_ward_code character varying); 
--	                 into var_local_hosp, var_case_no, var_adt1, var_adt2, var_adt3, var_adt4, var_destination_code, var_last_specialty_code, var_last_ward_code;
	
				perform public.dblink_disconnect('HKPMI_SERVER'::text);
		        EXCEPTION
			        WHEN others THEN
			            BEGIN
						perform public.dblink_disconnect('HKPMI_SERVER'::text);
			                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
			                raise notice 'call % error: %', var_rpc_call, var_err_msg;
			                var_retcode := 201001;
	           		    END;
	           end;

    IF var_retcode != 0 THEN
        BEGIN
            var_retcode := 201001;
            RETURN;
        END;
    END IF;
   
   OPEN p_refcur for select * from temp_results;
   end;
  
            
          --		select * from public.dblink('hkpmi_srvr'::text,'call '
--			    || var_rpc_call || '('
--                ||case when par_hkid is null then 'null::character varying' else concat('''', par_hkid, '''::character varying') end
--			    || ');'::text)
    /* select @hkid = ltrim(@hkid) + space(12 - VARCHAR_length(ltrim(@hkid))) */
    /*
    if @required_data = 'C'
    begin
       select @cics_pgm_id = IC10RCAS
       exec @retcode = @rpc_call @hosp_code, @cics_pgm_id, @hkid, @security_code
    end
    else
    begin
       select @cics_pgm_id = IC10RPMI
       exec @retcode = @rpc_call @hosp_code, @cics_pgm_id, @hkid
    end
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling on
    */
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @retcode = @rpc_call @hkid
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling off
    */
    /*
    If VARCHAR_length(rtrim(@hkid)) < 9
    begin
    	select @hkid =   + @hkid
       select @hkid = substring(@hkid,1,12)
    end
    */
RETURN NEXT p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_get_data" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
