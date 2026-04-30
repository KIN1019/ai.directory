-- DROP PROCEDURE hpi.hasp_get_hkpmi_tph_report(inout int4, in varchar, in timestamp, in timestamp);

CREATE OR REPLACE PROCEDURE hasp_get_hkpmi_tph_report(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
var_hkpmi_srvr VARCHAR(255);
    var_pgm_name VARCHAR(40);
    var_rpc_call VARCHAR(40);
    var_ret_code INTEGER;
    sql$rowcount BIGINT;
BEGIN
--    SELECT
--        Text_value
--        INTO var_hkpmi_srvr
--        FROM Hospital_control
--        WHERE Type = 'hkpmi_server';
--    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;

--    IF sql$rowcount <> 1 THEN
--        return_code := 200016;
--        RETURN;
--    END IF;
/*
[3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
set cis_rpc_handling on
*/


begin
SELECT 'hkpmi_get_tph_report'
INTO var_pgm_name; /* ---Default DB =download for HKPMI2 !!! */
SELECT concat(schema_name,'.', var_pgm_name)
INTO var_rpc_call
from hkpmi_control; /* ---Default DB =download for HKPMI2 !!! */


begin
        perform public.dblink_connect('hkpmi_srvr'::text, var_hkpmi_srvr);
select * from public.dblink('hkpmi_srvr'::text,'call '
    || var_rpc_call || '('
    || case when par_hosp_code is null then 'null::character varying' else concat('''', par_hosp_code, '''::character varying') end || ','
    || case when par_from_date is null then 'null::timestamp without time zone' else concat('''', par_from_date, '''::timestamp without time zone') end || ','
    || case when par_to_date is null then 'null::timestamp without time zone' else concat('''', par_to_date, '''::timestamp without time zone') end
    ||
                                               ');'::text)
                  as t1(var_retcode integer);
perform public.dblink_disconnect('hkpmi_srvr'::text);
exception
	        when others then
	        perform public.dblink_disconnect('hkpmi_srvr'::text);
end;

    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @ret_code = @rpc_call @hosp_code, @from_date, @to_date
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling off
    */
    IF var_ret_code <> 0 THEN
        pas_return_code := 200010;
        RETURN;
END IF;
end;
    pas_return_code := 0;
    RETURN;

END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_hkpmi_tph_report" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
