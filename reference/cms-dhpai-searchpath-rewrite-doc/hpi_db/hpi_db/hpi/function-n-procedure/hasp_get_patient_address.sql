-- DROP PROCEDURE hpi.hasp_get_patient_address(inout int4, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hasp_get_patient_address(INOUT pas_return_code integer DEFAULT NULL::integer, IN par_hkid character varying DEFAULT NULL::character varying, IN par_address_type character varying DEFAULT 'C'::character varying, INOUT par_building character varying DEFAULT NULL::character varying, INOUT par_room character varying DEFAULT NULL::character varying, INOUT par_floor character varying DEFAULT NULL::character varying, INOUT par_block character varying DEFAULT NULL::character varying, INOUT par_district_code character varying DEFAULT NULL::character varying, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --- use hkid for update, prk may diff. between CPI/PMI */
/* --default = 'C' : */
DECLARE
var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error_msg VARCHAR(255);
    sql$rowcount BIGINT;
    var_hkpmi_srvr TEXT;
    var_rtn_code int;
    var_db_sql TEXT;
    var_pgm VARCHAR(80);
    var_hkpmi_down_flag VARCHAR(1);
    var_local_hosp VARCHAR(3);
    var_rpc_call VARCHAR(800);
    var_err_msg VARCHAR(800);
begin
<<return_error>>
begin

--	    CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);

SELECT concat(schema_name,'.hkpmi_get_patient_address')
INTO var_rpc_call
from hkpmi_control;

SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;

IF var_hkpmi_srvr IS NULL THEN
BEGIN
	            var_retcode := 200016;
	            RETURN;
END;
END IF;

begin

		SET search_path TO hkpmi, public;

	       perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
	--               exec @retcode = @rpc_call @hkid,@address_type,@building out ,@room out,@floor out,@block out,@district_code out,
	--        				@return_code out,@return_message out

	   	 var_db_sql := 'call ' || var_rpc_call || '('
		    || case when var_retcode is null then '0' else 0 end || ','
	        || case when par_hkid is null then 'null::bpchar' else concat('''', par_hkid, '''::bpchar') end || ','
	        || case when par_address_type is null then 'null::bpchar' else concat('''', par_address_type, '''::bpchar') end || ','
	        || case when par_building is null then 'null::varchar' else concat('''', par_building, '''::varchar') end || ','
	        || case when par_room is null then 'null::bpchar' else concat('''', par_room, '''::bpchar') end || ','
	        || case when par_floor is null then 'null::bpchar' else concat('''', par_floor, '''::bpchar') end || ','
	        || case when par_block is null then 'null::bpchar' else concat('''', par_block, '''::bpchar') end || ','
	        || case when par_district_code is null then 'null::bpchar' else concat('''', par_district_code, '''::bpchar') end || ','
	        || case when par_return_code is null then '0' else 0 end || ','
		        || case when par_return_message is null then 'null::varchar' else concat('''', par_return_message, '''::varchar') end || ');';
				    raise notice '%', var_db_sql;

select * from dblink('HKPMI_SERVER', var_db_sql)  as t1(
                                                        pas_return_code integer,
                                                        par_building character varying,
                                                        par_room bpchar,
                                                        par_floor bpchar,
                                                        par_block bpchar,
                                                        par_district_code bpchar,
                                                        par_return_code integer,
                                                        par_return_message character varying
    )
    into
						    pas_return_code,
						    par_building,
						    par_room,
						    par_floor,
						    par_block,
						    par_district_code,
						    par_return_code,
						    par_return_message;

perform public.dblink_disconnect('HKPMI_SERVER'::text);
EXCEPTION
	        WHEN others THEN
BEGIN
				perform public.dblink_disconnect('HKPMI_SERVER'::text);
	                GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
	                raise notice 'call % error: %', var_rpc_call, var_err_msg;
	                var_retcode := 201001;
END;


end;

	         IF var_retcode <> 0 THEN
BEGIN
	                /* ----select @err_msg = 'Call hkpmi_set_patient_address Failed !' */
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
    par_return_code
INTO var_rtn_code;
SELECT
    par_return_message
INTO var_err_msg;
/*
[3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
set cis_rpc_handling off
*/
<<return_normal>>
BEGIN
	            /*
	            [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
	            set transactional_rpc off
	            */
SELECT
    0
INTO par_return_code;
SELECT
    NULL
INTO par_return_message;
pas_return_code := 0;
	            RETURN;
END;
		SET search_path TO hpi, public;
END;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling off
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
    set transactional_rpc off
    */

SELECT
    var_rtn_code
INTO par_return_code;
SELECT
    var_err_msg
INTO par_return_message;
pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_patient_address" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
