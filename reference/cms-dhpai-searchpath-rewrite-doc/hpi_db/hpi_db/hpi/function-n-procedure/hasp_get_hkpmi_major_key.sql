CREATE OR REPLACE PROCEDURE hasp_get_hkpmi_major_key(INOUT pas_return_code int, IN par_input_hosp VARCHAR, IN par_hkid VARCHAR, INOUT par_prk VARCHAR, INOUT par_name VARCHAR, INOUT par_sex VARCHAR, INOUT par_dob TIMESTAMP WITHOUT TIME ZONE, INOUT par_exact_dob VARCHAR, INOUT par_ccc_1 VARCHAR, INOUT par_ccc_2 VARCHAR, INOUT par_ccc_3 VARCHAR, INOUT par_ccc_4 VARCHAR, INOUT par_ccc_5 VARCHAR, INOUT par_ccc_6 VARCHAR, INOUT par_update_by VARCHAR, INOUT par_src_system VARCHAR, INOUT par_update_dtm TIMESTAMP WITHOUT TIME ZONE, INOUT par_hosp_code VARCHAR)
AS 
$BODY$
/* --- put hospital_code as input parm by WL on 26 July 1999 -- */
/* --- for HPI --- */
DECLARE
    var_return_code INTEGER;
    var_error INTEGER;
    var_error_detail VARCHAR(255);
    var_error_msg VARCHAR(255);
    var_rpc_call VARCHAR(60);
    var_hkpmi_srvr VARCHAR(255);
    var_pgm_name VARCHAR(60);
    var_hkpmi_down_flag VARCHAR(2);
    var_local_hosp VARCHAR(3);
    sql$rowcount BIGINT;
    var_db_sql text;
    var_err_msg text;
BEGIN
    /* --- Modified by WL on 22 July 1999 for HPI --- */
    SELECT
        text_value
        INTO var_hkpmi_srvr
        FROM hospital_control
        WHERE "type" = 'hkpmi_server' AND hospital_code = par_input_hosp;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        BEGIN
            pas_return_code := 200016;
            RETURN;
        END;
    END IF;
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
            pas_return_code := 200016;
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
    /* ---select @rpc_call = rtrim(@hkpmi_srvr) + "..." + rtrim(@pgm_name) */
    /* ---Default DB =download for HKPMI2 !!! */

    pas_return_code := 0;


    SELECT concat(schema_name,'.hkpmi_get_major_key')  
    INTO var_rpc_call
    from hkpmi_control;
    CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);
    IF var_hkpmi_srvr IS NULL THEN
        BEGIN
            pas_return_code := 200016;
            RETURN;
        END;
    END IF;
    
    var_db_sql := 'select * from ' || var_rpc_call || '(0,'
        || case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end || ','
        || case when par_prk is null then 'null::varchar' else concat('''', par_prk, '''::varchar') end || ','
        || case when par_name is null then 'null::varchar' else concat('''', par_name, '''::varchar') end || ','
        || case when par_sex is null then 'null::varchar' else concat('''', par_sex, '''::varchar') end || ','
        || case when par_sex is null then 'null::varchar' else concat('''', par_sex, '''::varchar') end || ','
        || case when par_dob is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_dob, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
        || case when par_exact_dob is null then 'null::varchar' else concat('''', par_exact_dob, '''::varchar') end || ','
        || case when par_ccc_1 is null then 'null::varchar' else concat('''', par_ccc_1, '''::varchar') end || ','
        || case when par_ccc_2 is null then 'null::varchar' else concat('''', par_ccc_2, '''::varchar') end || ','
        || case when par_ccc_3 is null then 'null::varchar' else concat('''', par_ccc_3, '''::varchar') end || ','
        || case when par_ccc_4 is null then 'null::varchar' else concat('''', par_ccc_4, '''::varchar') end || ','
        || case when par_ccc_5 is null then 'null::varchar' else concat('''', par_ccc_5, '''::varchar') end || ','
        || case when par_ccc_6 is null then 'null::varchar' else concat('''', par_ccc_6, '''::varchar') end || ','
        || case when par_update_by is null then 'null::varchar' else concat('''', par_update_by, '''::varchar') end || ','
        || case when par_src_system is null then 'null::varchar' else concat('''', par_src_system, '''::varchar') end || ','
        || case when par_update_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_update_dtm, '''::varTIMESTAMP WITHOUT TIME ZONEchar') end || ','
        || case when par_hosp_code is null then 'null::varchar' else concat('''', par_hosp_code, '''::varchar') end || ');';
    raise notice 'db_sql: %', var_db_sql;
    perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
    SET search_path TO hpi, public;
    BEGIN
        select * from dblink('HKPMI_SERVER', var_db_sql) as t1(pas_return_code integer,
            par_prk character varying,
            par_name character varying,
            par_sex character varying,
            par_dob timestamp without time zone,
            par_exact_dob character varying,
            par_ccc_1 character varying,
            par_ccc_2 character varying,
            par_ccc_3 character varying,
            par_ccc_4 character varying,
            par_ccc_5 character varying,
            par_ccc_6 character varying,
            par_update_by character varying,
            par_src_system character varying,
            par_update_dtm timestamp without time zone,
            par_hosp_code character varying,
            par_document_flag character varying);
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
END;
$BODY$
LANGUAGE plpgsql;


;ALTER PROCEDURE "hasp_get_hkpmi_major_key" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
