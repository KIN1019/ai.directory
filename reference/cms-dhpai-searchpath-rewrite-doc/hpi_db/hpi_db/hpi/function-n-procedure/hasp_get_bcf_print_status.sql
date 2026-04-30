-- DROP PROCEDURE hasp_get_bcf_print_status(inout int4, in varchar, in varchar, inout varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hasp_get_bcf_print_status(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, INOUT par_status_code character varying, INOUT par_return_code integer, INOUT par_error_message character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
var_hkpmi_srvr VARCHAR(255);
    var_prg_name VARCHAR(60);
    var_pgm_name VARCHAR(60);
    var_rpc_call VARCHAR(800);
    var_retcode INTEGER;
    var_return_code int;
    var_db_sql text;
   var_err_msg text;
BEGIN

SELECT
    0, 0
INTO par_Return_code, var_retcode;
SELECT
    NULL, NULL
INTO par_Error_message, var_hkpmi_srvr;

CALL cpi_get_rpc_server(var_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);

IF var_hkpmi_srvr IS NOT NULL THEN

begin
SELECT concat(schema_name,'.hkpmi_get_bcf_print_status')
INTO var_rpc_call
from hkpmi_control;
CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);

SET search_path TO hkpmi, public;
		     var_db_sql := 'call '
					    || var_rpc_call || '('
					    || case when var_retcode is null then '0' else 0 end || ','
					    || case when par_hospital_code is null then 'null::character varying' else concat('''', par_hospital_code, '''::character varying') end || ','
					    || case when par_hkid is null then 'null::character varying' else concat('''', par_hkid, '''::character varying') end || ','
					    || case when par_status_code is null then 'null::character varying' else concat('''', par_status_code, '''::character varying') end || ','
					    || case when par_return_code is null then '0' else 0 end || ','
					    || case when par_error_message is null then 'null::character varying' else concat('''', par_error_message, '''::character varying') end || ');';
		    raise notice 'db_sql: %', var_db_sql;
		    perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);

begin
select * from dblink('HKPMI_SERVER', var_db_sql) as t1(var_retcode integer, par_status_code character,
                                                       par_return_code integer, par_error_message character varying)
    into var_retcode, par_status_code, par_return_code, par_error_message;

EXCEPTION
				        WHEN others THEN
BEGIN
				                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
				                raise notice 'call % error: %', var_rpc_call, var_err_msg;
				                pas_return_code := 201001;
END;
END;
		    perform dblink_disconnect('HKPMI_SERVER');
			       
		    SET search_path TO hpi, public;
		   
			        IF var_retcode != 0 THEN
BEGIN
SELECT
    'Cannot check printing status in HKPMI'
INTO par_Error_message;
SELECT
    var_retcode
INTO par_Return_code;
END;
END IF;
		            pas_return_code := var_retcode;
		            RETURN;
       
            /*
            [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
            set cis_rpc_handling on
            */
            /*
            [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
            exec @retcode = @prg_name @Hospital_code, @HKID,
            		@Status_code output, @Return_code output, @Error_message output
            */
            /*
            [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
            set cis_rpc_handling off
            */
            /* Fail to call HKPMI */

END;
ELSE
BEGIN
            /* HKPMI not available */
SELECT
    'Cannot check printing status in HKPMI'
INTO par_Error_message;
SELECT
    - 2
INTO par_Return_code;
pas_return_code := par_Return_code;
            RETURN;
END;
END IF;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_bcf_print_status" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
