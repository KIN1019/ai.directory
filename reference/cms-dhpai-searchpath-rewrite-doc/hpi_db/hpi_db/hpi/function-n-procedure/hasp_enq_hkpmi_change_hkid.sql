-- DROP PROCEDURE hasp_enq_hkpmi_change_hkid(inout int4, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_enq_hkpmi_change_hkid(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_hkid character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_hkpmi_down_flag VARCHAR(20);
    var_hkpmi_srvr TEXT;
    var_rpc_call VARCHAR(60);
    dblink_sql TEXT;
    v_message text;
    sql$rowcount BIGINT;
BEGIN
    SET search_path TO hpi, public; 

    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        appl_ctl_text_value
        INTO var_hkpmi_down_flag
        FROM pas_appl_control
        WHERE hospital_code = par_hosp_code AND appl_name = 'IPAS' AND appl_ctl_type = 'HKPMI_SP1_DOWN';

    IF var_hkpmi_down_flag = 'Y' THEN
        BEGIN
            SELECT
                NULL
                INTO var_hkpmi_srvr;
            CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_READ_ONLY_SVR', var_hkpmi_srvr);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    pas_return_code := 14002;
                    RETURN;
                END;
            END IF;
        END;
    END IF;

    /*SELECT
      concat(schema_name,'.hkpmi_get_hkpmi_change_hkid')  
    INTO var_rpc_call
    from hkpmi_control;
    
    begin
        -- raise notice '%',var_hkpmi_srvr;   
        perform public.dblink_connect('PMI'::text, var_hkpmi_srvr);
        exception
            when others then
                perform public.dblink_disconnect('PMI'::text);
                perform public.dblink_connect('PMI'::text, var_hkpmi_srvr);
    end;

    dblink_sql := 'select * from ' 
                    || var_rpc_call || '('
                    || case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end ||');';
    raise notice '%',dblink_sql;*/
   
   	
	/*OPEN p_refcur for 
        with result_table as(select * from public.dblink('PMI'::text, dblink_sql::text) 
        as t1(hkid VARCHAR, patient_name VARCHAR, sex VARCHAR, dob TIMESTAMP WITHOUT TIME ZONE, 
        hospital_code VARCHAR, update_by VARCHAR, system_dtm TIMESTAMP WITHOUT TIME ZONE, id INTEGER))
   	select * from result_table;*/
   
   	--replace dblink by fdw
   	OPEN p_refcur for 
        select * from hkpmi.hkpmi_get_hkpmi_change_hkid(par_hkid);
       
	SET search_path TO hpi, public; 

    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_enq_hkpmi_change_hkid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
