-- DROP FUNCTION hkpmi.hkpmi_get_case_by_hkid(varchar, varchar, timestamp, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_case_by_hkid(par_hkid character varying, par_hosp_list character varying, par_adm_dt timestamp without time zone DEFAULT NULL::timestamp without time zone, par_case_type character varying DEFAULT NULL::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_string VARCHAR(255);
    var_pos INTEGER;
    var_piece VARCHAR(50);
    var_max_loop_count INTEGER;
    var_loop_count INTEGER;
BEGIN
    DROP TABLE IF EXISTS t$temp_hospital_code;
    CREATE TEMPORARY TABLE t$temp_hospital_code
    ("hospital_code" VARCHAR(3) NULL);
    SELECT
        64, 0
        INTO var_max_loop_count, var_loop_count;
    SELECT
        par_hosp_list
        INTO var_string;
    var_pos := STRPOS(var_string, ',');

    WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
        var_piece := LEFT(var_string, var_pos - 1);
        INSERT INTO t$temp_hospital_code
        SELECT
            LTRIM(var_piece);
        var_string := OVERLAY(var_string PLACING NULL FROM 1 FOR var_pos);
        var_pos := STRPOS(var_string, ',');
        SELECT
            var_loop_count + 1
            INTO var_loop_count;
    END LOOP;
    INSERT INTO t$temp_hospital_code
    SELECT
        LTRIM(var_string);
    OPEN p_refcur FOR
    SELECT
        c.hospital_code, c.case_no, c.last_specialty_code, c.adm_dtm, c.discharge_dtm
        FROM patient AS p, pmi_case AS c, t$temp_hospital_code AS h
        WHERE p.hkid = par_hkid AND p.patient_key = c.patient_key AND (c.hospital_code = h."hospital_code" OR par_hosp_list = '') AND (c.adm_dtm > par_adm_dt OR par_adm_dt is NULL) AND (c.case_type = par_case_type OR par_case_type is NULL);
	return next p_refcur;    
    /*
    
    DROP TABLE IF EXISTS t$temp_hospital_code;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "hkpmi_get_case_by_hkid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
