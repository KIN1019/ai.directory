-- DROP FUNCTION hkpmi_get_patient_by_caselist(varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi_get_patient_by_caselist(par_case_list1 character varying, par_case_list2 character varying, par_case_list3 character varying, par_case_list4 character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_string VARCHAR(255);
    var_pos INTEGER;
    var_piece VARCHAR(50);
    var_count INTEGER;
    var_hosppos INTEGER;
    var_hospcode VARCHAR(3);
    var_caseno VARCHAR(12);
    var_max_loop_count INTEGER;
    var_loop_count INTEGER;
   	p_refcur refcursor;
begin
	drop table if exists t$temp_case;
    CREATE TEMPORARY TABLE t$temp_case
    ("hospital_code" CHAR(3) NULL,
        "case_no" CHAR(12) NULL,
        "patient_key" CHAR(8) NULL);
    SELECT
        50, 0
        INTO var_max_loop_count, var_loop_count;
    SELECT
        par_case_list1
        INTO var_string;
    var_pos := STRPOS(var_string, ',');

    WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
        var_piece := LEFT(var_string, var_pos - 1);
        var_hosppos := STRPOS(var_piece, '|');
        var_hospcode := LEFT(var_piece, var_hosppos - 1);
        var_caseno := OVERLAY(var_piece PLACING '' FROM 1 FOR var_hosppos);
        INSERT INTO t$temp_case (hospital_code, case_no)
        VALUES (var_hospcode, var_caseno);
        var_string := OVERLAY(var_string PLACING '' FROM 1 FOR var_pos);
        var_pos := STRPOS(var_string, ',');
        SELECT
            var_loop_count + 1
            INTO var_loop_count;
    END LOOP;
    var_hosppos := STRPOS(var_string, '|');
    var_hospcode := LEFT(var_string, var_hosppos - 1);
    var_caseno := OVERLAY(var_string PLACING '' FROM 1 FOR var_hosppos);
    INSERT INTO t$temp_case (hospital_code, case_no)
    VALUES (var_hospcode, var_caseno);

    IF par_case_list2 is not NULL AND par_case_list2 != '' THEN
        BEGIN
            SELECT
                par_case_list2
                INTO var_string;
            var_pos := STRPOS(var_string, ',');
            SELECT
                0
                INTO var_loop_count;

            WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
                var_piece := LEFT(var_string, var_pos - 1);
                var_hosppos := STRPOS(var_piece, '|');
                var_hospcode := LEFT(var_piece, var_hosppos - 1);
                var_caseno := OVERLAY(var_piece PLACING '' FROM 1 FOR var_hosppos);
                INSERT INTO t$temp_case (hospital_code, case_no)
                VALUES (var_hospcode, var_caseno);
                var_string := OVERLAY(var_string PLACING '' FROM 1 FOR var_pos);
                var_pos := STRPOS(var_string, ',');
                SELECT
                    var_loop_count + 1
                    INTO var_loop_count;
            END LOOP;
            var_hosppos := STRPOS(var_string, '|');
            var_hospcode := LEFT(var_string, var_hosppos - 1);
            var_caseno := OVERLAY(var_string PLACING '' FROM 1 FOR var_hosppos);
            INSERT INTO t$temp_case (hospital_code, case_no)
            VALUES (var_hospcode, var_caseno);
        END;
    END IF;

    IF par_case_list3 is not NULL AND par_case_list3 != '' THEN
        BEGIN
            SELECT
                par_case_list3
                INTO var_string;
            var_pos := STRPOS(var_string, ',');
            SELECT
                0
                INTO var_loop_count;

            WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
                var_piece := LEFT(var_string, var_pos - 1);
                var_hosppos := STRPOS(var_piece, '|');
                var_hospcode := LEFT(var_piece, var_hosppos - 1);
                var_caseno := OVERLAY(var_piece PLACING '' FROM 1 FOR var_hosppos);
                INSERT INTO t$temp_case (hospital_code, case_no)
                VALUES (var_hospcode, var_caseno);
                var_string := OVERLAY(var_string PLACING '' FROM 1 FOR var_pos);
                var_pos := STRPOS(var_string, ',');
                SELECT
                    var_loop_count + 1
                    INTO var_loop_count;
            END LOOP;
            var_hosppos := STRPOS(var_string, '|');
            var_hospcode := LEFT(var_string, var_hosppos - 1);
            var_caseno := OVERLAY(var_string PLACING '' FROM 1 FOR var_hosppos);
            INSERT INTO t$temp_case (hospital_code, case_no)
            VALUES (var_hospcode, var_caseno);
        END;
    END IF;

    IF par_case_list4 is not NULL AND par_case_list4 != '' THEN
        BEGIN
            SELECT
                par_case_list4
                INTO var_string;
            var_pos := STRPOS(var_string, ',');
            SELECT
                0
                INTO var_loop_count;

            WHILE var_pos <> 0 AND (var_loop_count < var_max_loop_count) LOOP
                var_piece := LEFT(var_string, var_pos - 1);
                var_hosppos := STRPOS(var_piece, '|');
                var_hospcode := LEFT(var_piece, var_hosppos - 1);
                var_caseno := OVERLAY(var_piece PLACING '' FROM 1 FOR var_hosppos);
                INSERT INTO t$temp_case (hospital_code, case_no)
                VALUES (var_hospcode, var_caseno);
                var_string := OVERLAY(var_string PLACING '' FROM 1 FOR var_pos);
                var_pos := STRPOS(var_string, ',');
                SELECT
                    var_loop_count + 1
                    INTO var_loop_count;
            END LOOP;
            var_hosppos := STRPOS(var_string, '|');
            var_hospcode := LEFT(var_string, var_hosppos - 1);
            var_caseno := OVERLAY(var_string PLACING '' FROM 1 FOR var_hosppos);
            INSERT INTO t$temp_case (hospital_code, case_no)
            VALUES (var_hospcode, var_caseno);
        END;
    END IF;
    SELECT
        COUNT(*)
        INTO var_count
        FROM t$temp_case;

    IF var_count > var_max_loop_count THEN
        BEGIN
            RAISE EXCEPTION '%', format('Maximum number of Case input is 50, your input (number of Case input: %s) is exceeding the range!', var_count) USING ERRCODE := '99999';
        END;
    END IF;
    /* --update patient key */
    UPDATE t$temp_case AS t
    SET "patient_key" = c.patient_key
    FROM pmi_case AS c
        WHERE c.hospital_code = t."hospital_code" AND c.case_no = t."case_no";
    OPEN p_refcur FOR
    SELECT
        p.patient_key, p.religion, p.hkid, p.patient_name, p.sex, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, p.chi_name, p.dob, p.exact_dob_flag, p.marital_status, p.race, p.other_doc_no, p.building, p.room, p.floor, p.block, p.district, p.phone1, p.phone2, p.address_indicator, p.mobile_phone, p.sms_language, p.death_indicator, p.death_date, p.death_diagnosis, p.death_external_cause, p.patient_type, p.pcs_count, p.access_code, p.update_hospital, p.source_system, p.update_by, p.source_system_dtm, p.system_dtm, p.row_update_datetime, p.filler, c1.unicode_int AS unicode_int1, c2.unicode_int AS unicode_int2, c3.unicode_int AS unicode_int3, c4.unicode_int AS unicode_int4, c5.unicode_int AS unicode_int5, c6.unicode_int AS unicode_int6, t."hospital_code", t."case_no"
        FROM patient AS p
        INNER JOIN t$temp_case AS t
            ON p.patient_key = t."patient_key"
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
     return next p_refcur;
--    DROP TABLE t$temp_case;
    /*
    
    DROP TABLE IF EXISTS t$temp_case;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "hkpmi_get_patient_by_caselist" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
