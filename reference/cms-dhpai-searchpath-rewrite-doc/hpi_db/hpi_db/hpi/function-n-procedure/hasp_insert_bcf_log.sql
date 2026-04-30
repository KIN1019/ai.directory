-- DROP PROCEDURE hasp_insert_bcf_log(inout int4, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, inout varchar, inout int4, inout varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_insert_bcf_log(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_body_category character varying, IN par_mortuary_id integer, IN par_user_id character varying, IN par_user_hospital character varying, IN par_workstation_id character varying, IN par_source_system character varying, INOUT par_status_code character varying, INOUT par_return_code integer, INOUT par_error_message character varying, IN par_lof_hkid character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rpc_string  TEXT;
    var_rowcount    INTEGER;
    var_error       INTEGER;
    var_today       TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_srvr  VARCHAR(128);
    var_prg_name    VARCHAR(128);
    var_rpc_call    VARCHAR(255);
    var_retcode     INTEGER;
    var_return_code INTEGER;
    sql$rowcount    BIGINT;
BEGIN
    <<error>>
    BEGIN
        SELECT 0
        INTO par_Return_code;
        SELECT NULL
        INTO par_Error_message;

        IF par_HKID IS NULL
        THEN
            BEGIN
                SELECT 'HKID should be provided'
                INTO par_Error_message;
                EXIT error;
            END;
        END IF;

        IF par_Hospital_code IS NULL OR par_Body_category IS NULL OR par_Mortuary_ID IS NULL OR
           par_User_ID IS NULL OR par_User_hospital IS NULL OR par_Workstation_ID IS NULL OR
           par_Source_system IS NULL
        THEN
            BEGIN
                SELECT 'Data cannot be null'
                INTO par_Error_message;
                EXIT error;
            END;
        END IF;

        par_Body_category := safe_substring(par_Body_category,1,1);

        IF NOT EXISTS (SELECT mortuary_id
                       FROM
                           hospital_mortuary
                       WHERE mortuary_id = par_Mortuary_ID)
        THEN
            BEGIN
                SELECT 'Mortuary ID not exist'
                INTO par_Error_message;
                EXIT error;
            END;
        END IF;
/*         20080417 Remark checking since some patients are retrieved from HKPMI

        if @HKID is not null
        begin
        	select 1
        	from PMI_wo_MRN
        	where HKID = @HKID

        	select @rowcount = @@rowcount, @error = @@error
        	if @error != 0 or @rowcount != 1
        	begin
        		select @Error_message = HKID not found
        		select @pas_return_code = @error
        		goto error
        	end
        end

         Check print status before insert the log
         ---exec cpi..cpi_get_rpc_server 'HKPMI_SERVER', @hkpmi_srvr output */
        /*CALL cpi_get_rpc_server(var_return_code,'HKPMI_SERVER',var_hkpmi_srvr); /* ---HPI Version */

        RAISE NOTICE '%',var_hkpmi_srvr;
        IF var_hkpmi_srvr IS NOT NULL
        THEN
            BEGIN
                var_prg_name := '.hkpmi_get_bcf_print_status';

                SELECT
                    concat(schema_name,var_prg_name)
                INTO var_prg_name
                from hkpmi_control;

                BEGIN
                    PERFORM public.dblink_connect('rpc_server'::TEXT,var_hkpmi_srvr);
                    var_rpc_string := 'call '
                            || var_prg_name || '('
                            || CASE WHEN var_retcode IS NULL THEN 0 ELSE 0 END || ','
                            || CASE WHEN par_Hospital_code IS NULL THEN 'null::bpchar' ELSE CONCAT('''',par_Hospital_code,'''::bpchar') END || ','
                            || CASE WHEN par_HKID IS NULL THEN 'null::bpchar' ELSE CONCAT('''',par_HKID,'''::bpchar') END || ','
                            || CASE WHEN par_Status_code IS NULL THEN 'null::bpchar' ELSE CONCAT('''',par_Status_code,'''::bpchar') END || ','
                            || CASE WHEN par_Return_code IS NULL THEN 0 ELSE 0 END || ','
                            || CASE WHEN par_Error_message IS NULL THEN 'null::varchar' ELSE CONCAT('''',par_Error_message,'''::varchar') END
                            || ');'::TEXT;
                    raise notice 'var_rpc_string => [%]',var_rpc_string;
                    SELECT *
                    FROM
                        public.dblink('rpc_server'::TEXT,var_rpc_string)
                            AS t1(var_retcode INT,par_Status_code bpchar,par_Return_code bpchar,
                                  par_Error_message VARCHAR)
                    INTO
                        var_retcode,par_Status_code,par_Return_code,par_Error_message;
                    PERFORM public.dblink_disconnect('rpc_server'::TEXT);
                exception
                    when others then
                    perform public.dblink_disconnect('rpc_server'::TEXT);
                end;

                IF var_retcode != 0
                THEN
                    BEGIN
                        /* Fail to call HKPMI */
                        SELECT 'Cannot check printing status in HKPMI'
                        INTO par_Error_message;
                        EXIT error;
                    END;
                END IF;
            END ;
        ELSE
            BEGIN
                /* HKPMI not available */
                SELECT 'Cannot check printing status in HKPMI, printing is rejected'
                INTO par_Error_message;
                EXIT ERROR;
            END;
        END IF;

        SET SEARCH_PATH TO HPI;*/
       
		-- replace_dblink_by_fdw
       	CALL hkpmi.hkpmi_get_bcf_print_status(var_retcode, par_Hospital_code, par_HKID, par_Status_code, par_Return_code, par_Error_message);
       	SET search_path TO hpi,public;
       	IF var_retcode != 0
        THEN
            BEGIN
                /* Fail to call HKPMI */
                SELECT 'Cannot check printing status in HKPMI'
                INTO par_Error_message;
                EXIT error;
            END;
        END IF;
       	
        SELECT timestamp_convert(LOCALTIMESTAMP)
        INTO var_today;

        INSERT INTO bcf_log (hospital_code,hkid,lof_hkid,system_datetime,body_category,mortuary_id,
                             update_by,update_hospital,workstation_id,source_system,update_datetime)
        VALUES (par_Hospital_code,par_HKID,par_lof_hkid,var_today,par_Body_category,par_Mortuary_ID,
                par_User_ID,par_User_hospital,par_Workstation_ID,par_Source_system,var_today);
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_error != 0 OR var_rowcount != 1
        THEN
            BEGIN
                SELECT 'Fail to update bcf_log'
                INTO par_Error_message;
                SELECT var_error
                INTO par_Return_code;
                EXIT ERROR;
            END;
        END IF;
    END;

    IF par_Error_message IS NOT NULL
    THEN
        BEGIN
            IF par_Return_code = 0
            THEN
                SELECT - 1
                INTO par_Return_code;
            END IF;
            pas_return_code := - 1;
            RETURN;
        END;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_insert_bcf_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
