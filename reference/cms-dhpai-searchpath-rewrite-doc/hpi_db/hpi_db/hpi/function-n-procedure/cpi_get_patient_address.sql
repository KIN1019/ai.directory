-- DROP PROCEDURE cpi_get_patient_address(inout int4, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_get_patient_address(INOUT pas_return_code integer DEFAULT NULL::integer, IN par_hkid character varying DEFAULT NULL::character varying, IN par_address_type character varying DEFAULT 'C'::character varying, INOUT par_building character varying DEFAULT NULL::character varying, INOUT par_room character varying DEFAULT NULL::character varying, INOUT par_floor character varying DEFAULT NULL::character varying, INOUT par_block character varying DEFAULT NULL::character varying, INOUT par_district_code character varying DEFAULT NULL::character varying, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --- use hkid for update, prk may diff. between CPI/PMI */ 
/* --default = 'C' : */
DECLARE
    var_rtn_code INTEGER;
    var_err_msg VARCHAR(255);
    var_hkpmi_srvr VARCHAR(30);
    var_retcode INTEGER;
    var_rpc_call VARCHAR(100);
    var_pgm_name VARCHAR(50);
    var_return_code int;
BEGIN
    <<return_error>>
    BEGIN
        /* --- CHECK HKPMI Alive --- */
        SELECT
            NULL
            INTO var_hkpmi_srvr;
        CALL cpi_get_rpc_server('HKPMI_SERVER', var_hkpmi_srvr, var_return_code);

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
        /*
        [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
        set cis_rpc_handling on
        */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
        set transactional_rpc on
        */
        SELECT
            'hkpmi_get_patient_address'
            INTO var_pgm_name;
        SELECT
            CONCAT(LTRIM(RTRIM(var_hkpmi_srvr)), '.hkpmi.dbo.', LTRIM(RTRIM(var_pgm_name)))
            INTO var_rpc_call;
        /*
        [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
        exec @retcode = @rpc_call @hkid,@address_type,@building out ,@room out,@floor out,@block out,@district_code out,
        				@return_code out,@return_message out
        */
        /* --- 7223, the login may be kill or existed abnormally. */
        IF var_retcode = 7223 THEN
            /* --- retry once again */
            
            /*
            [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
            exec @retcode = @rpc_call @hkid,@address_type,@building out ,@room out,@floor out,@block out,@district_code out,
            				@return_code out,@return_message out
            */
            BEGIN
            END;
        END IF;

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

;ALTER PROCEDURE "cpi_get_patient_address" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
