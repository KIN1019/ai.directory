-- DROP PROCEDURE download.hkpmi_check_hkid(inout int4, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE download.hkpmi_check_hkid(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_host_hkid VARCHAR(24);
    var_pmi_data VARCHAR(510);
    var_nok_data VARCHAR(510);
    var_mf_patient_key VARCHAR(16);
    var_return_code INTEGER;
    var_rpc_name VARCHAR(16);
    var_gateway_id VARCHAR(16);
    var_cics_id VARCHAR(16);
    var_gateway_cics VARCHAR(38);
BEGIN
    SELECT
        REPEAT(' ', 255)
        INTO var_pmi_data;
    SELECT
        REPEAT(' ', 255)
        INTO var_nok_data;
    SELECT
        'IC10GPMI'
        INTO var_rpc_name;
    SELECT
        RTRIM(LTRIM(par_hkid))
        INTO var_host_hkid;
    SELECT
        SUBSTRING(CONCAT(var_host_hkid, REPEAT(' ', 12)), 1, 12)
        INTO var_host_hkid;
    SELECT
        gateway_id, adt_cics_id
        INTO var_gateway_id, var_cics_id
        FROM upload_control
        WHERE hospital_code = par_hospital_code;
    SELECT
        CONCAT(RTRIM(var_gateway_id), '...', RTRIM(var_cics_id))
        INTO var_gateway_cics;
    /* call rpc to get the pmi data from host */
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @return_code = @gateway_cics @hospital_code, @rpc_name,
                           @host_hkid,'E',@pmi_data output,@nok_data
    */
    IF var_return_code = 0 THEN
        pas_return_code := 0;
        RETURN;
    ELSE
        pas_return_code := 1;
        RETURN;
    END IF;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_check_hkid" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";