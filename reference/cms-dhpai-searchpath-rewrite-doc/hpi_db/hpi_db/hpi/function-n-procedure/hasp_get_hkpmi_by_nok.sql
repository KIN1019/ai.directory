-- DROP PROCEDURE hasp_get_hkpmi_by_nok(inout int4, in varchar, in varchar, in varchar, in int4, in varchar);

CREATE OR REPLACE PROCEDURE hasp_get_hkpmi_by_nok(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_nok_hkid character varying, IN par_nok_name character varying, IN par_authority_code integer, IN par_by character varying)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code as input parm for HPI by ML on 19990814 */
/* --- 2= major nok hkid, 3 = major nok name --- */
DECLARE
var_hkpmi_srvr VARCHAR(255);
    var_prg_name VARCHAR(60);
    var_error_code INTEGER;
    var_hkpmi_down_flag VARCHAR(1);
    var_rpc_call VARCHAR(800);
    var_local_hosp VARCHAR(3);
    sql$rowcount BIGINT;
    var_return_code int;
BEGIN
    /* @hosp_code      VARCHAR(3) */
    
    /* add hosp code for HPI by ML on 19990814 */
SELECT
    Text_value
INTO var_hkpmi_srvr
FROM Hospital_control
WHERE Type = 'hkpmi_server' AND Hospital_code = par_hosp_code;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

IF sql$rowcount <> 1 THEN
        pas_return_code := 200035;
        RETURN;
END IF;
    /*
    select @hosp_code = Hospital_code from Hospital
    
    if @@rowcount <> 1
       return 200036
    */
    /* ----------20120105 Check HKPMI down Flag-------------------- */
SELECT
    'N'
INTO var_hkpmi_down_flag;
SELECT
    Hospital_code
INTO var_local_hosp
FROM Hospital;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

IF sql$rowcount <> 1 THEN
        pas_return_code := 200036;
        RETURN;
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
/* --exec cpi..cpi_get_rpc_server 'HKPMI_READ_ONLY_SVR', @hkpmi_srvr	output */
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
    /* ---select @prg_name = rtrim(@hkpmi_srvr) + ...hkpmi_get_hkpmi_by_nok */
--    SELECT
--        CONCAT(RTRIM(var_hkpmi_srvr), '.hkpmi..hkpmi_get_hkpmi_by_nok')
--        INTO var_prg_name;
--       
--       
begin
SELECT 'hkpmi_get_hkpmi_by_nok'
INTO var_prg_name; /* ---Default DB =download for HKPMI2 !!! */
SELECT concat(schema_name,'.', var_prg_name)
INTO var_rpc_call
from hkpmi_control; /* ---Default DB =download for HKPMI2 !!! */

SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;

begin
        perform public.dblink_connect('hkpmi_srvr'::text, var_hkpmi_srvr);
select * from public.dblink('hkpmi_srvr'::text,'call '
    || var_rpc_call || '('
    || case when par_nok_hkid is null then 'null::character varying' else concat('''', par_nok_hkid, '''::character varying') end || ','
    || case when par_nok_name is null then 'null::character varying' else concat('''', par_nok_name, '''::character varying') end || ','
    || case when par_authority_code is null then '0' else 0 end || ','
    || case when par_by is null then 'null::character varying' else concat('''', par_by, '''::character varying') end || ','
    || case when par_hosp_code is null then 'null::character varying' else concat('''', par_hosp_code, '''::character varying') end
    || ');'::text)
                  as t1(var_error_code integer);
perform public.dblink_disconnect('hkpmi_srvr'::text);
exception
	        when others then
	        perform public.dblink_disconnect('hkpmi_srvr'::text);

end;
		       
    /* ---- Default DB =download for HKPMI2 !!! */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling on
    */
    
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @error_code = @prg_name @nok_hkid,  @nok_name,
                          @authority_code, @by, @hosp_code
    */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling off
    */
    IF var_error_code <> 0 THEN
        pas_return_code := 200037;
        RETURN;
END IF;
end;
    /* return 201001 */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_hkpmi_by_nok" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
