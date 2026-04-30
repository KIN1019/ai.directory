CREATE OR REPLACE PROCEDURE opas_get_cuid_by_hkid(INOUT pas_return_code int, IN par_server_name VARCHAR, IN par_hkid VARCHAR, INOUT par_cuid_exist VARCHAR, INOUT par_cuid VARCHAR, INOUT par_raiserror_text VARCHAR)
AS 
$BODY$
DECLARE
    var_rpc_call VARCHAR(60);
    var_return_code INTEGER;
    var_result INTEGER;
BEGIN
    /* RPC to CUID & return code defined by CUID team */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    SET cis_rpc_handling ON
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
    SET transactional_rpc ON
    */ /* ----begran tran ... */
    SELECT
        CONCAT(RTRIM(par_server_name), '.proc_cuid_get_cuid_byhkid')
        INTO var_rpc_call;
		
	perform public.dblink_connect('rpc_server'::text, var_rpc_call);
	select * from public.dblink('rpc_server'::text, 'call proc_cuid_get_cuid_byhkid'
	|| '('
	|| case when par_hkid is null then 'null::bpchar' else concat('''', par_hkid, '''::bpchar') end || ','
	|| case when par_cuid_exist is null then 'null::bpchar' else concat('''', par_cuid_exist, '''::bpchar') end || ','
	|| case when par_cuid is null then 'null::bpchar' else concat('''', par_cuid, '''::bpchar') end || ','
	|| case when par_raiserror_text is null then 'null::bpchar' else concat('''', par_raiserror_text, '''::bpchar') end || ','
	|| case when var_result is null then 0 else var_result end || ','
	|| case when var_return_code is null then 0 else var_return_code end || ')'::text)
	as t1(par_cuid_exist, par_cuid, par_raiserror_text, var_return_code) 
	into par_cuid_exist, par_cuid, par_raiserror_text, var_return_code;
	
	perform public.dblink_disconnect('rpc_server'::text);
	exception 
		when others THEN
			perform public.dblink_disconnect('rpc_server'::text);

    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    SET cis_rpc_handling OFF
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
    SET transactional_rpc OFF
    */
    <<return_null>>
    BEGIN
    END;
END;
$BODY$
LANGUAGE plpgsql;