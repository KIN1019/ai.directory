-- DROP PROCEDURE hkpmi.hkpmi_hago_get_vaccine_mex(inout int4, in bpchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_get_vaccine_mex(INOUT pas_return_code integer, IN par_hkid varchar, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_patient_key VARCHAR(16);
    var_code INTEGER;
    var_status VARCHAR(20);
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_valid_flag VARCHAR(1);
    var_return_code int;
BEGIN
    CALL cpi_pq_validate_hkid(var_return_code, par_hkid, var_valid_flag);

    IF var_valid_flag = 'N' THEN
        BEGIN
            SELECT
                2905, 'Invalid HKID'
                INTO var_code, var_status;
            pas_return_code := 2905;
            RETURN;
        END;
    END IF;
    /* HKID not exist */
    SELECT
        patient_key
        INTO var_patient_key
        /* --,@death_indicator = death_indicator */
        /* --,@death_date = death_date */
        FROM patient
        WHERE hkid = par_hkid;

    IF var_patient_key IS NULL THEN
        BEGIN
            SELECT
                2907, 'HKID Not Found'
                INTO var_code, var_status;
            pas_return_code := 2907;
            RETURN;
        END;
    END IF;
    SELECT
        status, update_datetime
        INTO var_status, var_update_datetime
        FROM hkpmi_patient_cvi_record
        WHERE patient_key = var_patient_key::VARCHAR;
    OPEN p_refcur FOR
    SELECT
        mex_indicator, issue_by_inst_english_name,
        /* --issue_by_inst_chinese_name, */
        issue_by_RMP_english_name,
        /* --issue_by_RMP_chinese_name, */
        /* issue_date, */
        TO_CHAR(issue_date, 'DD-Mon-YYYY') as issue_date_str,
        /* --STR_REPLACE(CONVERT(varchar, issue_date, 106),' ','-') as issue_date_str, */
        /* valid_till_date, */
        TO_CHAR(valid_till_date, 'DD-Mon-YYYY') as valid_till_date_str,
        /* --STR_REPLACE(CONVERT(varchar, valid_till_date, 106),' ','-') as valid_till_date_str, */
        upload_src_system
        FROM hkpmi_patient_cvi_mex
        WHERE patient_key = var_patient_key::VARCHAR AND var_status IS NOT NULL AND update_datetime >= var_update_datetime;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_get_vaccine_mex" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

