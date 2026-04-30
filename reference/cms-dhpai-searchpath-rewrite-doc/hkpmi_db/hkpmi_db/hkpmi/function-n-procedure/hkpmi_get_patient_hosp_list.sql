-- DROP FUNCTION hkpmi.hkpmi_get_patient_hosp_list(bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_patient_hosp_list(par_hkid varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_error INTEGER;
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_patient_key VARCHAR(8);
    var_hosp_code VARCHAR(3);
    var_check VARCHAR(1);
    sql$rowcount BIGINT;
BEGIN
    /* check patient */
    SELECT
        patient_key
        INTO var_patient_key
        FROM patient
        WHERE hkid = par_hkid;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        BEGIN
            RAISE EXCEPTION USING ERRCODE := '200012';
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        h.hospital_code
        FROM hospital AS h, patient_detail_1 AS p
        WHERE p.patient_key = var_patient_key AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0)
    UNION
    SELECT DISTINCT
        hospital_code
        FROM pmi_case
        WHERE patient_key = var_patient_key;
return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_patient_hosp_list" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

