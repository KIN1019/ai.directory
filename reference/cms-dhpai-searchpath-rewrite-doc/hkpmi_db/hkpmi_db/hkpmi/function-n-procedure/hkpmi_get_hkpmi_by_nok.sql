-- DROP FUNCTION hkpmi.hkpmi_get_hkpmi_by_nok(bpchar, bpchar, int4, bpchar, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_hkpmi_by_nok(par_nok_hkid varchar, par_nok_name varchar, par_authority_code integer, par_by varchar, par_hosp_code varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_temp_int INTEGER;
    pas_return_code INTEGER;
BEGIN
    CALL hkpmi_get_int_by_bit(pas_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
    SELECT
        par_authority_code & var_temp_int
        INTO par_authority_code;

    IF par_by = '3' THEN
        SELECT
            CONCAT(RTRIM(par_nok_name), '%')
            INTO par_nok_name;
    END IF;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 200 clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount  200
    */
    IF par_by = '2' THEN
        /* --- by major nok hkid ----- */
        OPEN p_refcur FOR
        SELECT
            p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1
            FROM nok AS n, patient AS p
            LEFT OUTER JOIN patient_hospital_data AS h
                ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
            WHERE n.hkid = par_nok_hkid AND n.major_nok = 'Y' AND n.patient_key = p.patient_key AND (p.access_code & par_authority_code) > 0
            LIMIT 200;
	    return next p_refcur;
    ELSE
        /* ----- by major nok name ---- */
        OPEN p_refcur FOR
        SELECT
            p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1
            FROM nok AS n, patient AS p
            LEFT OUTER JOIN patient_hospital_data AS h
                ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
            WHERE n.nok_name LIKE par_nok_name AND n.major_nok = 'Y' AND n.patient_key = p.patient_key AND (p.access_code & par_authority_code) > 0
            LIMIT 200;
	    return next p_refcur;
    END IF;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount 0
    */

    RETURN;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_hkpmi_by_nok" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

