-- DROP FUNCTION hkpmi.hkpmi_get_hkpmi_by_name(varchar, varchar, timestamp, timestamp, int4, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_hkpmi_by_name(par_name character varying, par_sex character varying, par_from_dob timestamp without time zone, par_to_dob timestamp without time zone, par_authority_code integer, par_hosp_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
@name = name input from screen
@sex  = M, F, U / MU / FU / U
@from_dob, @to_dob  = if user has input age, place into from_dob, to_dob
                      else place null
*/
DECLARE
    var_temp_int INTEGER;
    p_refcur refcursor;
    var_return_code INTEGER;
BEGIN
    SET search_path TO hkpmi, public;
    SELECT
        CONCAT(RTRIM(par_name), '%'), CONCAT('[', RTRIM(par_sex), ']')
        INTO par_name, par_sex;
    CALL hkpmi_get_int_by_bit(var_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
    SELECT
        par_authority_code & var_temp_int
        INTO par_authority_code;

    IF par_from_dob IS NULL THEN
        OPEN p_refcur FOR
        SELECT
            p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1
            FROM patient AS p
            LEFT OUTER JOIN patient_hospital_data AS h
                ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
            WHERE p.patient_name LIKE par_name AND p.sex SIMILAR TO par_sex AND (p.access_code & par_authority_code) > 0
            limit 200;
        RETURN NEXT p_refcur;
    ELSE
        OPEN p_refcur FOR
        SELECT
            p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1
            FROM patient AS p
            LEFT OUTER JOIN patient_hospital_data AS h
                ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
            WHERE p.patient_name LIKE par_name AND p.sex SIMILAR TO par_sex AND p.dob >= par_from_dob AND p.dob <= par_to_dob AND (p.access_code & par_authority_code) > 0
            limit 200;
        RETURN NEXT p_refcur;
    END IF;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_hkpmi_by_name" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

