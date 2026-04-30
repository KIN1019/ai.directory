-- DROP PROCEDURE pbpu_cpi_pat_addr_upd(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE pbpu_cpi_pat_addr_upd(INOUT pas_return_code integer, IN par_hkid character varying, IN par_address_type character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_hospital_code character varying, IN par_source_system character varying, IN par_user_id character varying, INOUT par_return_code integer, INOUT par_return_message character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
****************************************************
* Procedure : pbpu_cpi_pat_addr_upd
* Description : Call IPAS stored procedure cpi_set_patient_address
* Input :
*   Variable               Type        Description
*   --------               ----        -----------
*
* Raiserror :
*   Code  Message
*   ----  -------
*   0	  Success
*   1	  Error
*
*   Date 	Who             Action
*   -----	----            ------
*   20061011	Winnie Chan	Initial Version
*****************************************************
*/
DECLARE
var_retcode INTEGER;
    var_rtn_code INTEGER;
    var_err_msg VARCHAR(255);
    var_hkpmi_srvr VARCHAR(200);
    var_rpc_call VARCHAR(100);
    var_pgm_name VARCHAR(50);
    var_return_code int;
   var_db_sql text;
BEGIN
<<return_error>>
BEGIN
        IF par_source_system NOT IN ('ADT', 'OPAS', 'OPAS2', 'PBRC') THEN
BEGIN
SELECT
    - 1
INTO var_rtn_code;
SELECT
    'Incorrect Source System !'
INTO var_err_msg;
EXIT return_error;
END;
END IF;
       
        /* --- CHECK HKPMI Alive --- */
SELECT
    NULL
INTO var_hkpmi_srvr;


CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);

SELECT concat(schema_name,'.hkpmi_set_patient_address')
INTO var_rpc_call
from hkpmi_control;

IF var_hkpmi_srvr IS NULL THEN
BEGIN
SELECT
    - 1
INTO var_rtn_code;
SELECT
    'HKPMI server Down !'
INTO var_err_msg;
EXIT return_error;
END;
END IF;

begin   
	      	   
		SET search_path TO hkpmi, public;

	       perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
	--               exec @retcode = @rpc_call @hkid,@address_type,@building out ,@room out,@floor out,@block out,@district_code out,
	--        				@return_code out,@return_message out

	   	 var_db_sql := 'call ' || var_rpc_call || '('
		   || case when var_rtn_code is null then '0' else 0 end || ','
					|| case when par_hkid is null then 'null::bpchar' else concat('''', par_hkid, '''::bpchar') end || ','
					|| case when par_address_type is null then 'null::bpchar' else concat('''', par_address_type, '''::bpchar') end || ','
					|| case when par_building is null then 'null::varchar' else concat('''', par_building, '''::varchar') end || ','
                    || case when par_room is null then 'null::bpchar' else concat('''', par_room, '''::bpchar') end || ','
                    || case when par_floor is null then 'null::bpchar' else concat('''', par_floor, '''::bpchar') end || ','
                    || case when par_block is null then 'null::bpchar' else concat('''', par_block, '''::bpchar') end || ','
                    || case when par_district_code is null then 'null::bpchar' else concat('''', par_district_code, '''::bpchar') end || ','
                    || case when par_hospital_code is null then 'null::bpchar' else concat('''', par_hospital_code, '''::bpchar') end || ','
                    || case when par_source_system is null then 'null::bpchar' else concat('''', par_source_system, '''::bpchar') end || ','
                    || case when par_user_id is null then 'null::bpchar' else concat('''', par_user_id, '''::bpchar') end || ','
                    || case when par_return_code is null then '0' else 0 end || ','
                    || case when par_return_message is null then 'null::varchar' else concat('''', par_return_message, '''::varchar') end || ');';
				    raise notice '%', var_db_sql;
				   	
				   
				   raise notice 'par_hospital_code: %', par_hospital_code;

select * from dblink('HKPMI_SERVER', var_db_sql)  as t1(
                                                        pas_return_code integer,
                                                        par_return_code integer,
                                                        par_return_message character varying
    )
    into
						    pas_return_code,
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
                /* ---select @err_msg = 'Call hkpmi_set_patient_address Failed !' */
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

<<return_normal>>
BEGIN

SELECT
    0
INTO par_return_code;
SELECT
    NULL
INTO par_return_message;
pas_return_code := 0;
            RETURN;
END;
END;
SELECT
    var_rtn_code
INTO par_return_code;
SELECT
    var_err_msg
INTO par_return_message;
pas_return_code := var_rtn_code;
    RETURN;
end;
$procedure$
;

;ALTER PROCEDURE "pbpu_cpi_pat_addr_upd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
