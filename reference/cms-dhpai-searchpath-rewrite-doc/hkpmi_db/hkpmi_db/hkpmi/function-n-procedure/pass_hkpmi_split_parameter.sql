CREATE OR REPLACE FUNCTION pass_hkpmi_split_parameter(IN par_list VARCHAR)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_piece VARCHAR(255);
    var_semicolon INTEGER;
    var_at INTEGER;
    var_bar INTEGER;
    var_number INTEGER;
    var_comma INTEGER;
    var_case_length INTEGER;
    var_hkid VARCHAR(12);
    var_hospital VARCHAR(3);
    var_case_no VARCHAR(12);
    var_exclude_case VARCHAR(12);
    var_ref_date VARCHAR(14);
    var_ref_no VARCHAR(19);

    p_refcur refcursor;
BEGIN
    DROP TABLE IF EXISTS t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (hkid VARCHAR(12),
        hospital_code VARCHAR(3) NULL,
        exclude_case_no VARCHAR(12) NULL,
        ref_date VARCHAR(14) NULL,
        ref_no VARCHAR(19) NULL);
    SELECT
        STRPOS(par_list, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list, var_comma - 1)
            INTO var_piece;

        IF var_piece IS NOT NULL THEN
            BEGIN
                SELECT
                    STRPOS(var_piece, '|')
                    INTO var_bar;
                SELECT
                    STRPOS(var_piece, ';')
                    INTO var_semicolon;
                SELECT
                    STRPOS(var_piece, '@')
                    INTO var_at;
                SELECT
                    STRPOS(var_piece, '#')
                    INTO var_number;
                SELECT
                    RIGHT(CONCAT(REPEAT(' ', 9), SUBSTRING(var_piece, 1, var_bar - 1)), 9)
                    INTO var_hkid;
                SELECT
                    SUBSTRING(var_piece, var_bar + 1, 14)
                    INTO var_ref_date;

                IF var_number <> 0 THEN
                    SELECT
                        SUBSTRING(var_piece, var_number + 1, var_comma - var_number - 1)
                        INTO var_ref_no;
                ELSE
                    SELECT
                        NULL
                        INTO var_ref_no;
                END IF;

                IF var_semicolon <> 0 THEN
                    BEGIN
                        IF var_number <> 0 THEN
                            SELECT
                                var_number - var_at - 1
                                INTO var_case_length;
                        ELSE
                            SELECT
                                var_comma - var_at - 1
                                INTO var_case_length;
                        END IF;
                        SELECT
                            SUBSTRING(var_piece, var_semicolon + 1, var_at - var_semicolon - 1)
                            INTO var_hospital;
                        SELECT
                            RIGHT(CONCAT(REPEAT(' ', 12), SUBSTRING(var_piece, var_at + 1, var_case_length)), 12)
                            INTO var_case_no;
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, ref_no)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_ref_no);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, ref_no)
                        VALUES (var_hkid, var_ref_date, var_ref_no);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list PLACING NULL FROM 1 FOR var_comma)
            INTO par_list;
        SELECT
            STRPOS(par_list, ',')
            INTO var_comma;
    END LOOP;

    IF par_list IS NOT NULL THEN
        BEGIN
            SELECT
                par_list
                INTO var_piece;

            IF var_piece IS NOT NULL THEN
                BEGIN
                    SELECT
                        LENGTH(var_piece) + 1
                        INTO var_comma;
                    SELECT
                        STRPOS(var_piece, '|')
                        INTO var_bar;
                    SELECT
                        STRPOS(var_piece, ';')
                        INTO var_semicolon;
                    SELECT
                        STRPOS(var_piece, '@')
                        INTO var_at;
                    SELECT
                        STRPOS(var_piece, '#')
                        INTO var_number;
                    SELECT
                        RIGHT(CONCAT(REPEAT(' ', 9), SUBSTRING(var_piece, 1, var_bar - 1)), 9)
                        INTO var_hkid;
                    SELECT
                        SUBSTRING(var_piece, var_bar + 1, 14)
                        INTO var_ref_date;

                    IF var_number <> 0 THEN
                        SELECT
                            SUBSTRING(var_piece, var_number + 1, var_comma - var_number - 1)
                            INTO var_ref_no;
                    ELSE
                        SELECT
                            NULL
                            INTO var_ref_no;
                    END IF;

                    IF var_semicolon <> 0 THEN
                        BEGIN
                            IF var_number <> 0 THEN
                                SELECT
                                    var_number - var_at - 1
                                    INTO var_case_length;
                            ELSE
                                SELECT
                                    var_comma - var_at - 1
                                    INTO var_case_length;
                            END IF;
                            SELECT
                                SUBSTRING(var_piece, var_semicolon + 1, var_at - var_semicolon - 1)
                                INTO var_hospital;
                            SELECT
                                RIGHT(CONCAT(REPEAT(' ', 12), SUBSTRING(var_piece, var_at + 1, var_case_length)), 12)
                                INTO var_case_no;
                            INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, ref_no)
                            VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_ref_no);
                        END;
                    ELSE
                        BEGIN
                            INSERT INTO t$temp_result (hkid, ref_date, ref_no)
                            VALUES (var_hkid, var_ref_date, var_ref_no);
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
    SELECT
        t$temp_result.hkid, t$temp_result.hospital_code, t$temp_result.exclude_case_no, t$temp_result.ref_date, t$temp_result.ref_no
        FROM t$temp_result;
    return next p_refcur;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_result;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "pass_hkpmi_split_parameter" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
