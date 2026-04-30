-- DROP FUNCTION hpi.hasp_get_epmi(varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_get_epmi(par_hosp_code character varying, par_hkid character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$

/* ---- put hospital_code as input parm by WL on 26 July 1999 -- */
/* --- for HPI --- */

/* @security_code		int, */

/* @required_data		char(01), */

/* @data_type			char(01) */
DECLARE
	 p_refcur refcursor;
    var_retcode INTEGER;
    var_error INTEGER;
    /* @gateway_id			char(8), */
    /* @cics_id				char(8), */
    /* @cics_pgm_id		char(8), */
    var_rpc_call VARCHAR(60);
    /* @t_hkid				char(12), */
    /* @pmi_data			char(255), */
    /* @nok_data			char(255) */
    var_hkpmi_srvr VARCHAR(255);
    var_pgm_name VARCHAR(60);
    var_hkpmi_down_flag VARCHAR(2);
    var_local_hosp VARCHAR(6);
    sql$rowcount BIGINT;
    var_return_code int;
    var_patient_name VARCHAR(100);
    var_db_sql text;
    var_err_msg text;
BEGIN
    /*
    select @gateway_id = Gateway_ID,
    	@cics_id    = CICS_ID,
    	@hosp_code  = Hospital_code
    from Hospital
    */
    /*
    if @@rowcount != 1
    begin
    	return 200016
    end
    */
    /* --- Modified by WL on 22 July 1999 for HPI --- */
    SELECT
        text_value
        INTO var_hkpmi_srvr
        FROM hospital_control
        WHERE "type" = 'hkpmi_server' AND "hospital_code" = par_hosp_code;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        BEGIN
            var_retcode := 200016;
            RETURN;
        END;
    END IF;
        
   CREATE TEMP TABLE temp_results (
     patient_name character varying, 
				sex character varying, 
				cccode1 character varying, 
				cccode2 character varying, 
				cccode3 character varying, 
				cccode4 character varying, 
				cccode5 character varying, 
				cccode6 character varying, 
				dob timestamp without time zone, 
				exact_dob_flag character varying, 
				marital_status character varying, 
				race character varying, 
				other_doc_no character varying, 
				mrn character varying, 
				building character varying, 
				room character varying, 
				floor character varying, 
				block character varying, 
				district character varying, 
				religion character varying, 
				phone1 character varying, 
				death_indicator character varying, 
				patient_key character varying, 
				nok_name character varying, 
				hkid character varying, 
				building_1 character varying, 
				room_1 character varying, 
				floor_1 character varying, 
				block_1 character varying, 
				district_1 character varying, 
				phone1_1 character varying, 
				mobile_phone character varying, 
				sms_language character varying, 
				relationship character varying, 
				access_code integer, 
				chi_name character varying, 
				phone2 character varying, 
				address_indicator character varying, 
				mobile_phone_1 character varying, 
				sms_language_1 character varying, 
				death_date timestamp without time zone, 
				death_diagnosis character varying, 
				death_external_cause character varying, 
				patient_type character varying, 
				pcs_count integer, phone2_1 character varying, 
				address_indicator_1 character varying, 
				death_source_ind character varying, 
				hkic_symbol text
    ) ON COMMIT DROP;
    
	          
    /* -- Remark by WL on 22 July 1999 for HPI, as hospital_code --- */
    /* -- become input parm -- */
    
    /*
    select @hosp_code = Hospital_code
    from Hospital
    
    if @@rowcount != 1
    begin
    	return 200016
    end
    */
    
    /* select @cics_pgm_id = "IC10GPMI" */
    
    /* select @rpc_call = rtrim(@gateway_id) + "..." + rtrim(@cics_id) */
    
    /* select @t_hkid = ltrim(@hkid) + space(12 - char_length(ltrim(@hkid))) */
    
    /* exec @retcode = @rpc_call @hosp_code, @cics_pgm_id, @t_hkid, "R", @pmi_data output, @nok_data output */
    
    /* ----------20120105 Check HKPMI down Flag-------------------- */
    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        hospital_code
        INTO var_local_hosp
        FROM hospital_config;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        BEGIN
            var_retcode := 200016;
            RETURN;
        END;
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
            /* ---exec cpi..cpi_get_rpc_server 'HKPMI_READ_ONLY_SVR', @hkpmi_srvr	output */
            CALL cpi_get_rpc_server(null, 'HKPMI_READ_ONLY_SVR', var_hkpmi_srvr, var_return_code);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    var_retcode := 200016;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* ------------------------------------------------ */
    /*SELECT
        'hkpmi_r_pmi_result_1'
        INTO var_pgm_name; /* GL 19981115 */
    /* ---select @rpc_call = rtrim(@hkpmi_srvr) + "..." + rtrim(@pgm_name) */
    SELECT concat(schema_name,'.', var_pgm_name)  
    INTO var_rpc_call
    from hkpmi_control; /* ---Default DB =download for HKPMI2 !!! */
    -- execute format('select * from %I.%I(%L, %L, %L, %L, %L)', var_rpc_database, var_rpc_name, par_hkid, par_hosp_code, 'N', 'ADT', 'ADT')
    
    CALL cpi_get_rpc_server(var_retcode, 'HKPMI_SERVER', var_hkpmi_srvr);
    IF var_hkpmi_srvr IS NULL THEN
        BEGIN
            var_retcode := 200016;
            RETURN;
        END;
    END IF;
    
    var_db_sql := 'select * from ' || var_rpc_call || '('
        || case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end || ','
        || case when par_hosp_code is null then 'null::varchar' else concat('''', par_hosp_code, '''::varchar') end || ','
        ||'''N'',''ADT'',''ADT'');';
	raise notice 'var_db_sql=%',var_db_sql;

    perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
    
    begin
	     INSERT INTO temp_results
           select * from dblink('HKPMI_SERVER', var_db_sql)  
			 as t1(patient_name character varying, 
				sex character varying, 
				cccode1 character varying, 
				cccode2 character varying, 
				cccode3 character varying, 
				cccode4 character varying, 
				cccode5 character varying, 
				cccode6 character varying, 
				dob timestamp without time zone, 
				exact_dob_flag character varying, 
				marital_status character varying, 
				race character varying, 
				other_doc_no character varying, 
				mrn character varying, 
				building character varying, 
				room character varying, 
				floor character varying, 
				block character varying, 
				district character varying, 
				religion character varying, 
				phone1 character varying, 
				death_indicator character varying, 
				patient_key character varying, 
				nok_name character varying, 
				hkid character varying, 
				building_1 character varying, 
				room_1 character varying, 
				floor_1 character varying, 
				block_1 character varying, 
				district_1 character varying, 
				phone1_1 character varying, 
				mobile_phone character varying, 
				sms_language character varying, 
				relationship character varying, 
				access_code integer, 
				chi_name character varying, 
				phone2 character varying, 
				address_indicator character varying, 
				mobile_phone_1 character varying, 
				sms_language_1 character varying, 
				death_date timestamp without time zone, 
				death_diagnosis character varying, 
				death_external_cause character varying, 
				patient_type character varying, 
				pcs_count integer, phone2_1 character varying, 
				address_indicator_1 character varying, 
				death_source_ind character varying, 
				hkic_symbol text);
        EXCEPTION
        WHEN others then
            BEGIN
                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
                raise notice 'call % error: %', var_rpc_call, var_err_msg;
                var_retcode := 201001;
            END;
    END;
    perform dblink_disconnect('HKPMI_SERVER');*/
   
	-- replace_dblink_by_fdw	 
	INSERT INTO temp_results
	SELECT * FROM hkpmi.hkpmi_r_pmi_result_1(par_hkid,par_hosp_code,'N'::varchar,'ADT'::varchar,'ADT'::varchar);
	SET search_path TO hpi,public;

   OPEN p_refcur for select * from temp_results;
  
RETURN NEXT p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_get_epmi" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
