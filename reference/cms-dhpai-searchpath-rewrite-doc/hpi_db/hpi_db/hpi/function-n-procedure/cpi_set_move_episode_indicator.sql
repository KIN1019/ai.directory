-- DROP PROCEDURE cpi_set_move_episode_indicator(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_set_move_episode_indicator(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_create_dtm timestamp without time zone, IN par_from_patient_key character varying, IN par_to_patient_key character varying, IN par_create_user character varying, IN par_create_system character varying, IN par_move_status character varying, IN par_update_user character varying, IN par_update_system character varying, IN par_info_source_code character varying, IN par_reason_code character varying, IN par_other_reason character varying, INOUT par_return_message character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rtn_code INTEGER;
    var_err_msg VARCHAR(255);
    var_hkpmi_srvr VARCHAR(300);
    var_retcode INTEGER;
    var_rpc_call VARCHAR(400);
    var_pgm_name VARCHAR(50);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_return_code INTEGER;
    dblink_sql text;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_update_dtm;
        /*
        if @@trancount = 0
        	begin
        		select @err_msg = 'The stored procedure should be called within a transaction!'
        		select @rtn_code = 20000
        		goto return_error
        	end
        */
        raise notice 'par_update_system=%',par_update_system;
        IF par_update_system NOT IN ('ADT', 'OPAS', 'CMS') THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                SELECT
                    'Incorrect source system!'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        /* --- CHECK HKPMI Alive --- */
        SELECT
            NULL
            INTO var_hkpmi_srvr;
        CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr,null);
		raise notice 'var_hkpmi_srvr=%',var_hkpmi_srvr;
        IF var_hkpmi_srvr IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                SELECT
                    'HKPMI server down!'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        /*
        set cis_rpc_handling on
        */
        /*
        set transactional_rpc on
        */

        SELECT
      		concat(schema_name,'.hkpmi_set_move_episode_indicator')  
		INTO var_rpc_call
		from hkpmi_control;
        /*
        exec @retcode = @rpc_call @hospital_code,@case_no,@create_dtm,@from_patient_key,@to_patient_key,@create_user,@create_system,
        			@move_status,@update_dtm,@update_user,@update_system,@info_source_code,@reason_code,@other_reason,
        			@return_message output
        */
        begin
        raise notice 'do their vae_rpc_call=%',var_rpc_call;
       		perform public.dblink_connect('hkpmi_srvr'::text, var_hkpmi_srvr);
               dblink_sql := 'call ' 
			|| var_rpc_call || '('
            || case when var_retcode is null then 0 else var_retcode end || ','
            || case when par_hospital_code is null then 'null::bpchar' else concat('''', par_hospital_code, '''::bpchar') end || ','
			|| case when par_case_no is null then 'null::bpchar' else concat('''', par_case_no, '''::bpchar') end || ','
			|| case when par_create_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_create_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when par_from_patient_key is null then 'null::bpchar' else concat('''', par_from_patient_key, '''::bpchar') end || ','
			|| case when par_to_patient_key is null then 'null::bpchar' else concat('''', par_to_patient_key, '''::bpchar') end || ','
			|| case when par_create_user is null then 'null::bpchar' else concat('''', par_create_user, '''::bpchar') end || ','
			|| case when par_create_system is null then 'null::bpchar' else concat('''', par_create_system, '''::bpchar') end || ','
			|| case when par_move_status is null then 'null::bpchar' else concat('''', par_move_status, '''::bpchar') end || ','
			|| case when var_update_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_update_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when par_update_user is null then 'null::bpchar' else concat('''', par_update_user, '''::bpchar') end || ','
			|| case when par_update_system is null then 'null::bpchar' else concat('''', par_update_system, '''::bpchar') end || ','
			
			|| case when par_info_source_code is null then 'null::bpchar' else concat('''', par_info_source_code, '''::bpchar') end || ','
			|| case when par_reason_code is null then 'null::bpchar' else concat('''', par_reason_code, '''::bpchar') end || ','
			|| case when par_other_reason is null then 'null::bpchar' else concat('''', par_other_reason, '''::bpchar') end || ','
			|| case when par_return_message is null then 'null::varchar' else concat('''', par_return_message, '''::varchar') end ||');';
			raise notice 'dblink_sql=%',dblink_sql;
			 select * from public.dblink('hkpmi_srvr'::text,dblink_sql::text)
			as t1(var_retcode int,par_return_message varchar) into var_retcode,par_return_message;
				raise notice 'var_retcode1=%',var_retcode;

			
        /* --- 7223, session may be killed or existed abnormally. */
        IF var_retcode = 7223 THEN
            /* --- retry once again */
            
            /*
            exec @retcode = @rpc_call @hospital_code,@case_no,@create_dtm,@from_patient_key,@to_patient_key,@create_user,@create_system,
            				@move_status,@update_dtm,@update_user,@update_system,@info_source_code,@reason_code,@other_reason,
            				@return_message output
            */
             
            begin
	            select * from public.dblink('hkpmi_srvr'::text,dblink_sql::text)
			as t1(var_retcode int,par_return_message varchar) into var_retcode,par_return_message;
            END;
        END IF;
		raise notice 'var_retcode2=%',var_retcode;

		perform public.dblink_disconnect('hkpmi_srvr'::text);
raise notice 'var_retcode3=%',var_retcode;

			exception
				when others then
						RAISE NOTICE 'erro:%', SQLERRM; 
						perform public.dblink_disconnect('hkpmi_srvr'::text);  
/*set search_path to hpi;	*/
						raise notice 'var_retcode4=%',var_retcode;
		end;
							raise notice 'var_retcode5=%',var_retcode;

        IF var_retcode <> 0 THEN
            BEGIN
                SELECT
                    par_return_message
                    INTO var_err_msg;
                SELECT
                    var_retcode
                    INTO var_rtn_code;
                EXIT return_error;
            END;
        END IF;
        SELECT
            var_return_code
            INTO var_rtn_code;
        SELECT
            par_return_message
            INTO var_err_msg;
        /*
        set cis_rpc_handling off
        */
        <<return_normal>>
        BEGIN
            /*
            set transactional_rpc off
            */
            SELECT
                0
                INTO var_return_code;
            SELECT
                NULL
                INTO par_return_message;
            pas_return_code := 0;
            RETURN;
        END;
    END;
    /*
    set cis_rpc_handling off
    */
    /*
    set transactional_rpc off
    */
    SELECT
        var_rtn_code
        INTO var_return_code;
    SELECT
        var_err_msg
        INTO par_return_message;
    pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_set_move_episode_indicator" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
