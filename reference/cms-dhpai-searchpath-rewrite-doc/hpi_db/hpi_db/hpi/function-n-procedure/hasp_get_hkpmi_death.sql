-- DROP PROCEDURE hpi.hasp_get_hkpmi_death(inout int4, in varchar, in timestamp, in timestamp, in int4, in int4, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_hkpmi_death(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, IN par_from_age integer, IN par_to_age integer, IN par_sex character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hkpmi_srvr VARCHAR(255);
    var_pgm_name VARCHAR(40);
    var_rpc_call VARCHAR(200);
    var_ret_code INTEGER;
    sql$rowcount BIGINT;
    var_db_sql text;
    var_err_msg text;
    p_refcur refcursor;
BEGIN
    pas_return_code := 0;

    SELECT concat(schema_name,'.hkpmi_get_death')  
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
        || case when par_hosp_code is null then 'null::varchar' else concat('''', par_hosp_code, '''::varchar') end || ','
        || case when par_from_date is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_from_date, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
        || case when par_to_date is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', par_to_date, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
        || case when par_from_age is null then 'null::INTEGER' else concat('''', par_from_age, '''::INTEGER') end || ','
        || case when par_to_age is null then 'null::INTEGER' else concat('''', par_to_age, '''::INTEGER') end || ','
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
                pas_return_code := 200010;
            END;
    END;
    perform dblink_disconnect('HKPMI_SERVER');
    RETURN;
END;
$procedure$;

;ALTER PROCEDURE "hasp_get_hkpmi_death" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
