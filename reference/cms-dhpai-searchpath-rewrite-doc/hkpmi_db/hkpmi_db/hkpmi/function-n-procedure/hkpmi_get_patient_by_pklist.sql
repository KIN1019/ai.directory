-- DROP FUNCTION hkpmi_get_patient_by_pklist(varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi_get_patient_by_pklist(par_pk_list1 character varying, par_pk_list2 character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
    
DECLARE
    var_string VARCHAR(255);
    var_pos INTEGER;
    var_piece VARCHAR(50);
    var_count INTEGER;
    var_max_loop_count INTEGER;
    var_loop_count INTEGER;
   	p_refcur refcursor;
begin
	 drop table if exists t$temp_patient_key;
    CREATE TEMPORARY TABLE t$temp_patient_key
    (patient_key VARCHAR(16) NULL);
    SELECT
        50, 0
        INTO var_max_loop_count, var_loop_count;
    SELECT
        par_pk_list1
        INTO var_string;
    var_pos := STRPOS(var_string, ',');
    raise notice 'var_pos:%',var_pos;
    WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
        var_piece := LEFT(var_string, var_pos - 1);
        INSERT INTO t$temp_patient_key
        SELECT
            var_piece;
        var_string := OVERLAY(var_string PLACING '' FROM 1 FOR var_pos);
        var_pos := STRPOS(var_string, ',');
        SELECT
            var_loop_count + 1
            INTO var_loop_count;
    END LOOP;
    INSERT INTO t$temp_patient_key
    SELECT
        var_string;

    IF par_pk_list2 is not NULL AND par_pk_list2 != '' THEN
        BEGIN
            SELECT
                par_pk_list2
                INTO var_string;
            var_pos := STRPOS(var_string, ',');
            SELECT
                0
                INTO var_loop_count;

            WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
                var_piece := LEFT(var_string, var_pos - 1);
                INSERT INTO t$temp_patient_key
                SELECT
                    var_piece;
                var_string := OVERLAY(var_string PLACING '' FROM 1 FOR var_pos);
                var_pos := STRPOS(var_string, ',');
                SELECT
                    var_loop_count + 1
                    INTO var_loop_count;
            END LOOP;
            INSERT INTO t$temp_patient_key
            SELECT
                var_string;
        END;
    END IF;
    SELECT
        COUNT(*)
        INTO var_count
        FROM t$temp_patient_key;

    IF var_count > var_max_loop_count THEN
        BEGIN
            RAISE EXCEPTION '%', format('Maximum number of Patient Key input is 50, your input (number of Patient Key input: %s) is exceeding the range!', var_count) USING ERRCODE = '99999';
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        p.patient_key, p.religion, p.hkid, p.patient_name, p.sex, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, p.chi_name, p.dob, p.exact_dob_flag, p.marital_status, p.race, p.other_doc_no, p.building, p.room, p.floor, p.block, p.district, p.phone1, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.death_indicator, p.death_date, p.death_diagnosis, p.death_external_cause, p.patient_type, p.pcs_count, p.access_code, p.update_hospital, p.source_system, p.update_by, p.source_system_dtm, p.system_dtm, p.row_update_datetime, p.filler, c1.unicode_int AS unicode_int1, c2.unicode_int AS unicode_int2, c3.unicode_int AS unicode_int3, c4.unicode_int AS unicode_int4, c5.unicode_int AS unicode_int5, c6.unicode_int AS unicode_int6
        FROM patient AS p
        INNER JOIN t$temp_patient_key AS t
            ON p.patient_key = t.patient_key
        LEFT JOIN ccc_unicode AS c1
            ON c1.ccc_head = SUBSTRING(p.cccode1, 1, 4) AND c1.ccc_tail = SUBSTRING(p.cccode1, 5, 1)
        LEFT JOIN ccc_unicode AS c2
            ON c2.ccc_head = SUBSTRING(p.cccode2, 1, 4) AND c2.ccc_tail = SUBSTRING(p.cccode2, 5, 1)
        LEFT JOIN ccc_unicode AS c3
            ON c3.ccc_head = SUBSTRING(p.cccode3, 1, 4) AND c3.ccc_tail = SUBSTRING(p.cccode3, 5, 1)
        LEFT JOIN ccc_unicode AS c4
            ON c4.ccc_head = SUBSTRING(p.cccode4, 1, 4) AND c4.ccc_tail = SUBSTRING(p.cccode4, 5, 1)
        LEFT JOIN ccc_unicode AS c5
            ON c5.ccc_head = SUBSTRING(p.cccode5, 1, 4) AND c5.ccc_tail = SUBSTRING(p.cccode5, 5, 1)
        LEFT JOIN ccc_unicode AS c6
            ON c6.ccc_head = SUBSTRING(p.cccode6, 1, 4) AND c6.ccc_tail = SUBSTRING(p.cccode6, 5, 1);
--    DROP TABLE t$temp_patient_key;
	return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$temp_patient_key;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "hkpmi_get_patient_by_pklist" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
