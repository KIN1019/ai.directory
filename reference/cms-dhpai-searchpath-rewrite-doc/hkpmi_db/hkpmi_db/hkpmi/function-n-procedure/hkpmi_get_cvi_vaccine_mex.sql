-- DROP FUNCTION hkpmi.hkpmi_get_cvi_vaccine_mex(varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_cvi_vaccine_mex(par_patient_key character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_status VARCHAR(40);
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    SELECT
        status, update_datetime
        INTO var_status, var_update_datetime
        FROM hkpmi_patient_cvi_record
        WHERE patient_key = par_patient_key;
    OPEN p_refcur FOR
    SELECT
        mex_indicator, issue_by_inst_english_name, issue_by_inst_chinese_name, "issue_by_RMP_english_name", "issue_by_RMP_chinese_name",
        /* issue_date, */
        to_char(issue_date::TIMESTAMP WITHOUT TIME ZONE,'DD-Mon-YYYY') AS issue_date_str,
        /* valid_till_date, */
        to_char(valid_till_date::TIMESTAMP WITHOUT TIME ZONE,'DD-Mon-YYYY')AS valid_till_date_str, upload_src_system
        FROM hkpmi_patient_cvi_mex
        WHERE patient_key = par_patient_key AND var_status IS NOT NULL AND update_datetime >= var_update_datetime;
	return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_cvi_vaccine_mex" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

