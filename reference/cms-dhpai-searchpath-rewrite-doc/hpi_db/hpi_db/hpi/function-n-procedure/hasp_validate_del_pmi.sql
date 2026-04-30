-- DROP PROCEDURE hasp_validate_del_pmi(inout int4, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_validate_del_pmi(INOUT pas_return_code integer, IN par_input_hkid character varying, IN par_input_hosp_code character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_retcode INTEGER;
    var_error INTEGER;
    var_rpc_call text;
    var_hkpmi_srvr text;
    var_rowcount INTEGER;
    var_case_count INTEGER;
    var_document_flag VARCHAR(1);
    var_local_name VARCHAR(48);
    var_local_sex VARCHAR(1);
    var_local_dob TIMESTAMP WITHOUT TIME ZONE;
    var_local_ccc1 VARCHAR(5);
    var_local_ccc2 VARCHAR(5);
    var_local_ccc3 VARCHAR(5);
    var_local_ccc4 VARCHAR(5);
    var_local_ccc5 VARCHAR(5);
    var_local_ccc6 VARCHAR(5);
    var_hkpmi_name VARCHAR(48);
    var_hkpmi_sex VARCHAR(1);
    var_hkpmi_dob TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_ccc1 VARCHAR(5);
    var_hkpmi_ccc2 VARCHAR(5);
    var_hkpmi_ccc3 VARCHAR(5);
    var_hkpmi_ccc4 VARCHAR(5);
    var_hkpmi_ccc5 VARCHAR(5);
    var_hkpmi_ccc6 VARCHAR(5);
    var_hkpmi_patient_key VARCHAR(8);
    var_hkpmi_exact_dob VARCHAR(1);
    var_hkpmi_update_by VARCHAR(8);
    var_hkpmi_source_system VARCHAR(5);
    var_hkpmi_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_upd_hosp VARCHAR(3);
    sql$rowcount BIGINT;
    v_message text;
    dblink_sql text;
    var_hkpmi_down_flag VARCHAR(1);
BEGIN
    SET search_path TO hpi, public; 
    raise notice '[hasp_validate_del_pmi] begin';
    /* -- select HKPMI server name -- */
    SELECT
        hkpmi_server
        INTO var_hkpmi_srvr
        FROM hkpmi_control;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    raise notice '[hasp_validate_del_pmi] var_hkpmi_srvr=%',var_hkpmi_srvr;
    IF sql$rowcount != 1 THEN
        BEGIN
            /* print "Fail to retrieve Gateway information! Retrieve PMI record is rejected!" */
            var_retcode := 14001;
            RETURN;
        END;
    END IF;


    /* ----------20120105 Check HKPMI down Flag-------------------- */
    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        appl_ctl_text_value
        INTO var_hkpmi_down_flag
        FROM pas_appl_control
        WHERE hospital_code = par_input_hosp_code AND appl_name = 'IPAS' AND appl_ctl_type = 'HKPMI_SP1_DOWN';

    IF var_hkpmi_down_flag = 'Y' THEN
        BEGIN
            SELECT
                NULL
                INTO var_hkpmi_srvr;
            CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_READ_ONLY_SVR', var_hkpmi_srvr);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    var_retcode := 14002;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* ------------------------------------------------ */

    /* -- select local PMI demo -- */
    SELECT
        Name, Sex, DOB, CCC_1, CCC_2, CCC_3, CCC_4, CCC_5, CCC_6
        INTO var_local_name, var_local_sex, var_local_dob, var_local_ccc1, var_local_ccc2, var_local_ccc3, var_local_ccc4, var_local_ccc5, var_local_ccc6
        FROM PMI
        WHERE HKID = par_input_hkid;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    BEGIN
        var_rowcount := sql$rowcount;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF (var_error <> 0 OR var_rowcount <> 1) THEN
        BEGIN
            SELECT
                29999
                INTO var_retcode;
            RAISE EXCEPTION '% ', 'Local-PMI not found, PMI delete rejected' USING ERRCODE := var_retcode;
            RETURN;
        END;
    END IF;
    /* -- check Major Key agains HKPMI--- */
    /*SELECT
        concat(schema_name,'.hkpmi_get_major_key')  
    INTO var_rpc_call
    from hkpmi_control;
    
    raise notice '[hasp_validate_del_pmi] var_rpc_call=%',var_rpc_call;
    perform public.dblink_connect('rpc_name'::text, var_hkpmi_srvr);
    dblink_sql := 'call ' || /*var_rpc_call*/ var_rpc_call || '('
                || case when var_retcode is null then 0 else var_retcode end || ','
                || case when par_input_hkid is null then 'null::varchar' else concat('''', par_input_hkid, '''::varchar') end || ','
                || case when var_hkpmi_patient_key is null then 'null::varchar' else concat('''', var_hkpmi_patient_key, '''::varchar') end || ','
                || case when var_hkpmi_name is null then 'null::varchar' else concat('''', var_hkpmi_name, '''::varchar') end || ','
                || case when var_hkpmi_sex is null then 'null::varchar' else concat('''', var_hkpmi_sex, '''::varchar') end || ','
                || case when var_hkpmi_dob is null then 'null::timestamp without time zone' else concat('''', to_char(var_hkpmi_dob,'YYYY-MM-DD HH24:MI:SS'), '''::timestamp without time zone') end || ','
                || case when var_hkpmi_exact_dob is null then 'null::varchar' else concat('''', var_hkpmi_exact_dob, '''::varchar') end || ','
                || case when var_hkpmi_ccc1 is null then 'null::varchar' else concat('''', var_hkpmi_ccc1, '''::varchar') end || ','
                || case when var_hkpmi_ccc2 is null then 'null::varchar' else concat('''', var_hkpmi_ccc2, '''::varchar') end || ','
                || case when var_hkpmi_ccc3 is null then 'null::varchar' else concat('''', var_hkpmi_ccc3, '''::varchar') end || ','
                || case when var_hkpmi_ccc4 is null then 'null::varchar' else concat('''', var_hkpmi_ccc4, '''::varchar') end || ','
                || case when var_hkpmi_ccc5 is null then 'null::varchar' else concat('''', var_hkpmi_ccc5, '''::varchar') end || ','
                || case when var_hkpmi_ccc6 is null then 'null::varchar' else concat('''', var_hkpmi_ccc6, '''::varchar') end || ','
                || case when var_hkpmi_update_by is null then 'null::varchar' else concat('''', var_hkpmi_update_by, '''::varchar') end || ','
                || case when var_hkpmi_source_system is null then 'null::varchar' else concat('''', var_hkpmi_source_system, '''::varchar') end || ','
                || case when var_hkpmi_upd_dtm is null then 'null::timestamp without time zone' else concat('''', to_char(var_hkpmi_upd_dtm,'YYYY-MM-DD HH24:MI:SS'), '''::timestamp without time zone') end || ','
                || case when var_hkpmi_upd_hosp is null then 'null::varchar' else concat('''', var_hkpmi_upd_hosp, '''::varchar') end || ','
                || case when var_document_flag is null then 'null::varchar' else concat('''', var_document_flag, '''::varchar') end || ');';
                raise notice '%',dblink_sql;
        select * from public.dblink('rpc_name'::text,dblink_sql::text)
        as t1(var_return_code INTEGER,par_prk varchar,par_name varchar,par_sex varchar,par_dob timestamp without time zone,par_exact_dob  varchar,par_ccc_1 varchar,par_ccc_2 varchar,par_ccc_3 varchar,par_ccc_4 varchar,par_ccc_5 varchar,par_ccc_6 varchar
        ,par_update_by varchar,par_src_system varchar,par_update_dtm timestamp without time zone,par_hosp_code varchar,par_document_flag varchar) into
        var_retcode ,var_hkpmi_patient_key ,var_hkpmi_name ,var_hkpmi_sex ,var_hkpmi_dob  ,var_hkpmi_exact_dob ,var_hkpmi_ccc1 ,var_hkpmi_ccc2 ,var_hkpmi_ccc3 ,var_hkpmi_ccc4 ,var_hkpmi_ccc5 ,var_hkpmi_ccc6 
        ,var_hkpmi_update_by ,var_hkpmi_source_system ,var_hkpmi_upd_dtm ,var_hkpmi_upd_hosp ,var_document_flag;
    perform public.dblink_disconnect('rpc_name'::text);
    raise notice '[hasp_validate_del_pmi] var_retcode=%, var_hkpmi_sex=%',var_retcode, var_hkpmi_sex;
    BEGIN
        exception
            when others then
                        GET STACKED DIAGNOSTICS  v_message = MESSAGE_TEXT;
                        RAISE NOTICE 'Error: %', v_message;
                    perform public.dblink_disconnect('rpc_name'::text);
    END;*/
   
   	-- replace_dblink_by_fdw	
 	CALL hkpmi.hkpmi_get_major_key(var_retcode, par_input_hkid, var_hkpmi_patient_key, var_hkpmi_name, var_hkpmi_sex, var_hkpmi_dob, 
 	var_hkpmi_exact_dob, var_hkpmi_ccc1, var_hkpmi_ccc2, var_hkpmi_ccc3, var_hkpmi_ccc4, var_hkpmi_ccc5, var_hkpmi_ccc6, 
 	var_hkpmi_update_by, var_hkpmi_source_system, var_hkpmi_upd_dtm, var_hkpmi_upd_hosp, var_document_flag);
 	SET search_path TO hpi,public;
   
    IF var_retcode != 0 THEN
        BEGIN
            SELECT
                29999
                INTO var_retcode;
            RAISE EXCEPTION '% ', 'PMI not found in HKPMI, PMI delete rejected' USING ERRCODE := var_retcode;
            RETURN;
        END;
    END IF;

    IF var_local_ccc1 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_local_ccc1;
    END IF;

    IF var_local_ccc2 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_local_ccc2;
    END IF;

    IF var_local_ccc3 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_local_ccc3;
    END IF;

    IF var_local_ccc4 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_local_ccc4;
    END IF;

    IF var_local_ccc5 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_local_ccc5;
    END IF;

    IF var_local_ccc6 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_local_ccc6;
    END IF;

    IF var_hkpmi_ccc1 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_hkpmi_ccc1;
    END IF;

    IF var_hkpmi_ccc2 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_hkpmi_ccc2;
    END IF;

    IF var_hkpmi_ccc3 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_hkpmi_ccc3;
    END IF;

    IF var_hkpmi_ccc4 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_hkpmi_ccc4;
    END IF;

    IF var_hkpmi_ccc5 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_hkpmi_ccc5;
    END IF;

    IF var_hkpmi_ccc6 = REPEAT(' ', 1) THEN
        SELECT
            NULL
            INTO var_hkpmi_ccc6;
    END IF;
    /* -- compare major key --- */

    IF var_local_name <> var_hkpmi_name OR var_local_sex <> var_hkpmi_sex OR var_local_dob <> var_hkpmi_dob OR var_local_ccc1 <> var_hkpmi_ccc1 OR var_local_ccc2 <> var_hkpmi_ccc2 OR var_local_ccc3 <> var_hkpmi_ccc3 OR var_local_ccc4 <> var_hkpmi_ccc4 OR var_local_ccc5 <> var_hkpmi_ccc5 OR var_local_ccc6 <> var_hkpmi_ccc6 THEN
        BEGIN
            SELECT
                29999
                INTO var_retcode;
            RAISE EXCEPTION '% ', 'Major Key not match between local and HKPMI, PMI delete rejected' USING ERRCODE := var_retcode;
            RETURN;
        END;
    END IF;
    /* -- check any case exist -- */
   /* SELECT
        concat(schema_name,'.hkpmi_r_case_count')  
    INTO var_rpc_call
    from hkpmi_control;

    perform public.dblink_connect('rpc_name'::text, var_hkpmi_srvr);
    dblink_sql := 'call ' || /*var_rpc_call*/ var_rpc_call || '('
                || case when var_retcode is null then 0 else var_retcode end || ','
                || case when par_input_hkid is null then 'null::varchar' else concat('''', par_input_hkid, '''::varchar') end || ','
                || case when var_case_count is null then 0 else var_case_count end || ');';
                raise notice '%',dblink_sql;
        select * from public.dblink('rpc_name'::text,dblink_sql::text)
        as t1(pas_return_code INTEGER, par_case_out INTEGER) into var_retcode, var_case_count;
    perform public.dblink_disconnect('rpc_name'::text);

    raise notice '[hasp_validate_del_pmi] var_retcode=%, var_case_count=%',var_retcode, var_case_count;
    BEGIN
        exception
            when others then
                        GET STACKED DIAGNOSTICS  v_message = MESSAGE_TEXT;
                        RAISE NOTICE 'Error: %', v_message;
                    perform public.dblink_disconnect('rpc_name'::text);
    END;*/
   
   	-- replace_dblink_by_fdw
   	CALL hkpmi.hkpmi_r_case_count(var_retcode, par_input_hkid, var_case_count);
   	SET search_path TO hpi,public;

    IF (var_retcode != 0) THEN
        BEGIN
            SELECT
                29999
                INTO var_retcode;
            RAISE EXCEPTION '% ', 'Fail to get Patient cases, PMI delete rejected' USING ERRCODE := var_retcode;
            RETURN;
        END;
    END IF;

    IF (var_case_count > 0) THEN
        BEGIN
            SELECT
                29999
                INTO var_retcode;
            RAISE EXCEPTION '% ', 'Patient has cases, PMI delete rejected' USING ERRCODE := var_retcode;
            RETURN;
        END;
    END IF;
    /* --- extract local cases, afraid case not upload -- */
    
    /* --	if exists ( select * */
    
    /* --					from Case_view */
    
    /* --					where Hospital_code = @input_hosp_code and */
    
    /* --						HKID = @input_hkid) */
    IF EXISTS (SELECT
        *
        FROM cpi_case AS c, cpi_patient AS p
        WHERE p.hkid = par_input_hkid AND p.patient_key = c.patient_key AND c.status_code <> 'CC') THEN
        BEGIN
            SELECT
                29999
                INTO var_retcode;
            RAISE EXCEPTION '% ', 'Patient has cases, PMI delete rejected' USING ERRCODE := var_retcode;
            RETURN;
        END;
    END IF;

/*
exception
    when others then
        GET STACKED DIAGNOSTICS  v_message = MESSAGE_TEXT;
        RAISE NOTICE 'Error: %', v_message;
        --perform public.dblink_disconnect('rpc_name'::text);
        IF (var_retcode = 0) THEN
            var_retcode := -1;
        ELSE
            RAISE EXCEPTION 'Error: %', v_message;
        END IF;*/
            
    
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_validate_del_pmi" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
