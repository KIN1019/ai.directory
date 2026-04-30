-- DROP PROCEDURE hpi.hasp_update_pp_opt_out(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, inout int4, inout varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_update_pp_opt_out(INOUT pas_return_code integer, IN par_hkid character varying, IN par_req_type character varying, IN par_effective_dtm timestamp without time zone, IN par_req_hkid character varying, IN par_req_name character varying, IN par_req_sex character varying, IN par_req_phone character varying, IN par_req_nok character varying, IN par_req_address character varying, IN par_req_dtm timestamp without time zone, IN par_upd_by character varying, INOUT par_rtn_code integer, INOUT par_rtn_msg character varying DEFAULT NULL::character varying, IN par_mode character varying DEFAULT 'U'::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --- use HKID for update, prk may diff. between CPI/PMI */ 
/* ----/'U' update, 'C' Check only */
DECLARE
    var_upd_hosp VARCHAR(6);
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* @rtn_code int, */
    var_hkpmi_srvr VARCHAR(255);
    var_retcode INTEGER;
    var_rpc_call VARCHAR(200);
    var_pgm_name VARCHAR(100);
    var_return_code int;
    var_db_sql text;
    var_err_msg text;
BEGIN
    <<return_error>>
    BEGIN
        /* --- CHECK HKPMI Alive --- */
        SELECT
            NULL
            INTO var_hkpmi_srvr;
        /* ---exec cpi..cpi_get_rpc_server 'HKPMI_SERVER',@hkpmi_srvr output */
        CALL cpi_get_rpc_server(var_return_code, 'HKPMI_SERVER', var_hkpmi_srvr); /* ---HPI Ver */

        IF var_hkpmi_srvr IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO par_rtn_code;
                SELECT
                    'HKPMI server Down !'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        /* --- rules checking --- */

        IF par_req_type NOT IN ('A', 'D') THEN
            BEGIN
                SELECT
                    - 2
                    INTO par_rtn_code;
                SELECT
                    'Incorrect request type!'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        /* --- requester is the patient --- */

        IF par_req_hkid = par_hkid THEN /* or @req_hkid is null */
            BEGIN
                SELECT
                    NULL, NULL, NULL, NULL, NULL, NULL
                    INTO par_req_hkid, par_req_name, par_req_sex, par_req_phone, par_req_nok, par_req_address;
            END;
        END IF;
        /*
        ---check NON nullabl field ---
        if @req_hkid is not null
        begin
        
        	select @req_name = ltrim(rtrim(@req_name))
        	if (@req_name is null) or @req_name=''
        	begin
        		select @rtn_code = -3
        		select @err_msg = 'Requester name cannot be empty !'
        		goto return_error
        	end
        
        	if @req_sex NOT in ('M','F')
        	begin
        		select @rtn_code = -4
        		select @err_msg = 'Incorrect sex type !'
        		goto return_error
        	end
        
        	---if NOT exists (select * from cpi..nok_relation where nok_relation_code = @req_nok)
        	if NOT exists (select * from nok_relation where nok_relation_code = @req_nok)  ---HPI Ver
        	begin
        		select @rtn_code = -5
        		select @err_msg = 'Incorrect relationship !'
        		goto return_error
        	end
        
        end
        */
        SELECT
            hospital_code
            INTO var_upd_hosp
            FROM hospital;
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_upd_dtm;
        SELECT
            NULL
            INTO par_rtn_msg;

        /*SELECT concat(schema_name,'.hkpmi_update_pp_opt_out')  
        INTO var_rpc_call
        from hkpmi_control;

        var_db_sql := 'call ' || var_rpc_call || '(0,'
            || case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end || ','
            || case when par_req_type is null then 'null::varchar' else concat('''', par_req_type, '''::varchar') end || ','
            || case when par_effective_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_effective_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
            || case when par_req_hkid is null then 'null::varchar' else concat('''', par_req_hkid, '''::varchar') end || ','
            || case when par_req_name is null then 'null::varchar' else concat('''', par_req_name, '''::varchar') end || ','
            || case when par_req_sex is null then 'null::varchar' else concat('''', par_req_sex, '''::varchar') end || ','
            || case when par_req_phone is null then 'null::varchar' else concat('''', par_req_phone, '''::varchar') end || ','
            || case when par_req_nok is null then 'null::varchar' else concat('''', par_req_nok, '''::varchar') end || ','
            || case when par_req_address is null then 'null::varchar' else concat('''', par_req_address, '''::varchar') end || ','
            || case when par_req_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_req_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
            || case when var_upd_hosp is null then 'null::varchar' else concat('''', var_upd_hosp, '''::varchar') end || ','
            || case when par_upd_by is null then 'null::varchar' else concat('''', par_upd_by, '''::varchar') end || ','
            || case when var_upd_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_upd_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
            || case when par_rtn_msg is null then 'null::varchar' else concat('''', par_rtn_msg, '''::varchar') end || ','
            || case when par_mode is null then 'null::varchar' else concat('''', par_mode, '''::varchar') end || ')';
        raise notice 'db_sql: %', var_db_sql;
        perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
        SET search_path TO hpi, public;
        BEGIN
            select * from dblink('HKPMI_SERVER', var_db_sql) as t1(pas_return_code int, par_rtn_msg VARCHAR) into var_retcode, par_rtn_msg;
            EXCEPTION
            WHEN others THEN
                BEGIN
                    GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
                    raise notice 'call % error: %', var_rpc_call, var_err_msg;
                    
                    perform dblink_disconnect('HKPMI_SERVER');
                    EXIT return_error;
                END;
        END;
        perform dblink_disconnect('HKPMI_SERVER');*/
           
       	-- replace_dblink_by_fdw	                    
        CALL hkpmi.hkpmi_update_pp_opt_out(var_retcode ,par_hkid, par_req_type, 
       					par_effective_dtm, par_req_hkid,par_req_name,par_req_sex,
       				par_req_phone,par_req_nok,par_req_address,par_req_dtm,var_upd_hosp,
       			par_upd_by,var_upd_dtm,par_rtn_msg,par_mode);
       	SET search_path TO hpi,public;

        IF var_retcode <> 0 THEN
            BEGIN
                /* ---select @err_msg = 'Call hkpmi_update_pp_opt_out Failed !' */
                SELECT
                    par_rtn_msg
                    INTO var_err_msg;
                SELECT
                    var_retcode
                    INTO par_rtn_code;
                EXIT return_error;
            END;
        END IF;

        SELECT
            NULL
            INTO par_rtn_msg;
        pas_return_code := 0;
        RETURN;

        <<return_normal>>
        BEGIN
        END;
    END;

    SELECT
        var_err_msg
        INTO par_rtn_msg;
    pas_return_code := par_rtn_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_update_pp_opt_out" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
