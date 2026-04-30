-- DROP FUNCTION hkpmi.hkpmi_get_pp_opt_out_info(bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_pp_opt_out_info("par_HKID" varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_prk VARCHAR(8);
    var_rtn_code INTEGER;
    var_err_msg VARCHAR(255);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SET search_path TO hkpmi, public;
        SELECT
            patient_key
            INTO var_prk
            FROM patient
            WHERE hkid = "par_HKID";
        /* ---NO Patient -- */
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount <> 1 THEN /* ----@@rowcount = 0 */
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                SELECT
                    'NO Patient found !'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        /* ---Retrieve all pp_opt_out records ---- */
        OPEN p_refcur FOR
        SELECT
            effective_datetime, request_type, request_hkid, request_name, request_sex, request_phone, request_relationship, request_address, request_datetime, update_hospital, update_by, update_datetime
            FROM pp_opt_out
            WHERE patient_key = var_prk
            ORDER BY effective_datetime DESC NULLS FIRST;
	    
        return next p_refcur;
        /*
        --- NO pp_opt_out_info records -----
        if @@rowcount = 0
        begin
        	select @pp_opt_status = 'N'
        	goto return_normal
        end
        */
        
        /* ---		select @rtn_msg =null */
        RETURN;
    END;
    /* ---		select @rtn_msg = @err_msg */
    RETURN;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_pp_opt_out_info" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

