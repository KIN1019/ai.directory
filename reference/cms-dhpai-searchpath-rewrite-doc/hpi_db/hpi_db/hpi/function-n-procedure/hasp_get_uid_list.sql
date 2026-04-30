-- DROP FUNCTION hpi.hasp_get_uid_list(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hpi.hasp_get_uid_list(hosp_code character varying, from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, to_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS TABLE(rec_type character varying, hkid character varying, uid character varying, patient_name character varying, link_status character varying, create_dtm timestamp without time zone, create_hosp character varying, create_user character varying, update_dtm timestamp without time zone, update_hosp character varying, update_user character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    hkpmi_srvr      VARCHAR(255);
    rpc_call        TEXT;
    func_name       TEXT;
BEGIN

    CALL cpi_get_rpc_server(var_return_code, 'HKPMI_SERVER', hkpmi_srvr, NULL);
    --RAISE NOTICE 'hkpmi_srvr => [%]',hkpmi_srvr;

    -- Check if server info is available
    IF hkpmi_srvr IS NULL THEN
        RAISE EXCEPTION 'HKPMI server connection info is missing!';
    END IF;

    /*SELECT CONCAT(schema_name, '.hkpmi_get_uid_list')
    INTO func_name
    FROM hkpmi_control;

    -- RPC to HKPMI using dblink
    rpc_call := FORMAT(
            'SELECT * FROM public.dblink(%L, $$SELECT * FROM %s(%L, %L, %L)$$) AS t(
                rec_type VARCHAR(80),
                hkid VARCHAR(12),
                uid VARCHAR(12),
                patient_name VARCHAR(48),
                link_status VARCHAR(2),
                create_dtm TIMESTAMP,
                create_hosp VARCHAR(3),
                create_user VARCHAR(12),
                update_dtm TIMESTAMP,
                update_hosp VARCHAR(3),
                update_user VARCHAR(12)
            )',
            hkpmi_srvr, func_name, hosp_code, from_date, to_date
                );

    --RAISE NOTICE 'rpc_call => [%]',rpc_call;*/

   	-- replace_dblink_by_fdw	                    
    RETURN QUERY 
    SELECT * FROM hkpmi.hkpmi_get_uid_list(hosp_code,from_date,to_date);
	SET search_path TO hpi,public;
    RETURN;
END;
$function$
;

;ALTER FUNCTION "hasp_get_uid_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
