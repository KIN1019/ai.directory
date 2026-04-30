-- DROP PROCEDURE hasp_get_linked_case(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4);

CREATE OR REPLACE PROCEDURE hasp_get_linked_case(INOUT pas_return_code integer, IN par_hkid character varying, IN par_previous_hospital character varying, IN par_previous_case character varying, IN par_linked_hospital character varying, IN par_linked_case character varying, IN par_return_result character varying, INOUT par_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hkpmi_srvr text;
    var_hkpmi_srvr_char VARCHAR(300);
    var_pgm VARCHAR(80);
    var_return INTEGER;
    var_hkpmi_down_flag VARCHAR(10);
    var_local_hosp VARCHAR(30);
    var_rpc_call VARCHAR(800);
BEGIN
    <<error_return>>
    begin
        /* ----------20120105 Check HKPMI down Flag-------------------- */
        SELECT
            'N'
            INTO var_hkpmi_down_flag;
        SELECT
            Hospital_code
            INTO var_local_hosp
            FROM Hospital;
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
                CALL cpi_get_rpc_server(par_server_type=>'HKPMI_READ_ONLY_SVR', par_rpc_server=>var_hkpmi_srvr_char, pas_return_code => pas_return_code);
                select var_hkpmi_srvr_char into var_hkpmi_srvr;
                IF var_hkpmi_srvr IS NULL THEN
                    begin
	                    SELECT 200016 INTO pas_return_code;
                        RETURN;
                    END;
                END IF;
            END;
        ELSE
            /* ------------------------------------------------ */
            BEGIN
                CALL cpi_get_rpc_server(par_server_type=>'HKPMI_SERVER', par_rpc_server=>var_hkpmi_srvr_char, pas_return_code => pas_return_code);
               select var_hkpmi_srvr_char into var_hkpmi_srvr;
                IF var_hkpmi_srvr IS NULL THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO var_return;
                        EXIT error_return;
                    END;
                END IF;
            END;
        END IF;
        /* ------------------------------------------------ */
        /* --select @pgm = rtrim(@hkpmi_srvr) + '...hkpmi_get_linked_case' */
        /*SELECT '.hkpmi_get_linked_case'
            INTO var_pgm; /* ---Default DB =download for HKPMI2 !!! */

        perform public.dblink_connect('hkpmi'::text, var_hkpmi_srvr);
        
        SELECT
      	concat(schema_name,var_pgm)  
		INTO var_rpc_call
		from hkpmi_control;
	
       BEGIN  

        select * from public.dblink('hkpmi'::text,'call ' 
	|| var_rpc_call || '(' 
	|| case when var_return is null then 0 else 0 end || ','
	|| case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end || ','
	|| case when par_previous_hospital is null then 'null::varchar' else concat('''', par_previous_hospital, '''::varchar') end || ','
	|| case when par_previous_case is null then 'null::varchar' else concat('''', par_previous_case, '''::varchar') end || ','
	|| case when par_linked_hospital is null then 'null::varchar' else concat('''', par_linked_hospital, '''::varchar') end || ','
	|| case when par_linked_case is null then 'null::varchar' else concat('''', par_linked_case, '''::varchar') end || ','
	|| case when par_return_result is null then 'null::varchar' else concat('''', par_return_result, '''::varchar') end ||');'::text)
            as t1(var_return INTEGER) into var_return;
           RAISE NOTICE 'par_previous_case=> [%],var_return => [%]',par_previous_case,var_return;
            perform public.dblink_disconnect('hkpmi'::text);
        exception
            when others then
            perform public.dblink_disconnect('hkpmi'::text);
        end;
       	SET SEARCH_PATH TO hpi;*/
       	-- replace_dblink_by_fdw
       	CALL hkpmi.hkpmi_get_linked_case(var_return, par_hkid, par_previous_hospital, par_previous_case, 
       	par_linked_hospital, par_linked_case, par_return_result) ;
       	RAISE NOTICE 'par_previous_case=> [%],var_return => [%]',par_previous_case,var_return;
       	SET search_path TO hpi,public;

        SELECT var_return INTO par_return_code;
        SELECT var_return INTO pas_return_code;
        RETURN;
    END;
    SELECT var_return INTO par_return_code;
    SELECT var_return INTO pas_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_linked_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
