CREATE OR REPLACE FUNCTION pass_hkpmi_get_patient_status(IN par_list1 VARCHAR, IN par_list2 VARCHAR DEFAULT null, IN par_list3 VARCHAR DEFAULT null, IN par_list4 VARCHAR DEFAULT null, IN par_list5 VARCHAR DEFAULT null, IN par_list6 VARCHAR DEFAULT null, IN par_list7 VARCHAR DEFAULT null, IN par_list8 VARCHAR DEFAULT null, IN par_list9 VARCHAR DEFAULT null, IN par_list10 VARCHAR DEFAULT null, IN par_list11 VARCHAR DEFAULT null, IN par_list12 VARCHAR DEFAULT null, IN par_list13 VARCHAR DEFAULT null, IN par_list14 VARCHAR DEFAULT null, IN par_list15 VARCHAR DEFAULT null, IN par_list16 VARCHAR DEFAULT null, IN par_list17 VARCHAR DEFAULT null, IN par_list18 VARCHAR DEFAULT null, IN par_list19 VARCHAR DEFAULT null, IN par_list20 VARCHAR DEFAULT null)
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
    var_row_id VARCHAR(19);
    var_active_ip_case INTEGER;
    var_discharge_case INTEGER;
    csr_tmp CURSOR FOR
    SELECT DISTINCT
        hkid, hospital_code, exclude_case_no, ref_date, row_id
        FROM t$temp_result
        WHERE death IS NULL;
    csr CURSOR FOR
    SELECT
        hkid, hospital_code, exclude_case_no, ref_date, row_id
        FROM t$temp_cur_table;

    p_refcur refcursor;
BEGIN
    CREATE TEMPORARY TABLE t$temp_result
    (hkid VARCHAR(12),
        death VARCHAR(1) NULL,
        in_patient VARCHAR(1) NULL,
        discharged_case_found VARCHAR(1) NULL,
        hospital_code VARCHAR(3) NULL,
        exclude_case_no VARCHAR(12) NULL,
        ref_date VARCHAR(14) NULL,
        row_id VARCHAR(19) NULL);
    CREATE TEMPORARY TABLE t$temp_cur_table
    (hkid VARCHAR(12),
        hospital_code VARCHAR(3) NULL,
        exclude_case_no VARCHAR(12) NULL,
        ref_date VARCHAR(14) NULL,
        row_id VARCHAR(19) NULL);
    /* process @list1 */
    SELECT
        STRPOS(par_list1, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list1, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list1 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list1;
        SELECT
            STRPOS(par_list1, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list1
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list2 */
    SELECT
        STRPOS(par_list2, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list2, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list2 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list2;
        SELECT
            STRPOS(par_list2, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list2
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list3 */
    SELECT
        STRPOS(par_list3, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list3, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list3 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list3;
        SELECT
            STRPOS(par_list3, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list3
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list4 */
    SELECT
        STRPOS(par_list4, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list4, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list4 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list4;
        SELECT
            STRPOS(par_list4, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list4
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list5 */
    SELECT
        STRPOS(par_list5, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list5, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list5 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list5;
        SELECT
            STRPOS(par_list5, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list5
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list6 */
    SELECT
        STRPOS(par_list6, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list6, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list6 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list6;
        SELECT
            STRPOS(par_list6, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list6
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list7 */
    SELECT
        STRPOS(par_list7, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list7, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list7 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list7;
        SELECT
            STRPOS(par_list7, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list7
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list8 */
    SELECT
        STRPOS(par_list8, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list8, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list8 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list8;
        SELECT
            STRPOS(par_list8, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list8
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list9 */
    SELECT
        STRPOS(par_list9, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list9, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list9 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list9;
        SELECT
            STRPOS(par_list9, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list9
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list10 */
    SELECT
        STRPOS(par_list10, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list10, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list10 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list10;
        SELECT
            STRPOS(par_list10, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list10
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list11 */
    SELECT
        STRPOS(par_list11, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list11, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list11 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list11;
        SELECT
            STRPOS(par_list11, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list11
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list12 */
    SELECT
        STRPOS(par_list12, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list12, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list12 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list12;
        SELECT
            STRPOS(par_list12, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list12
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list13 */
    SELECT
        STRPOS(par_list13, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list13, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list13 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list13;
        SELECT
            STRPOS(par_list13, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list13
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list14 */
    SELECT
        STRPOS(par_list14, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list14, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list14 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list14;
        SELECT
            STRPOS(par_list14, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list14
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list15 */
    SELECT
        STRPOS(par_list15, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list15, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list15 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list15;
        SELECT
            STRPOS(par_list15, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list15
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list16 */
    SELECT
        STRPOS(par_list16, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list16, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list16 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list16;
        SELECT
            STRPOS(par_list16, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list16
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list17 */
    SELECT
        STRPOS(par_list17, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list17, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list17 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list17;
        SELECT
            STRPOS(par_list17, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list17
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list18 */
    SELECT
        STRPOS(par_list18, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list18, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list18 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list18;
        SELECT
            STRPOS(par_list18, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list18
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list19 */
    SELECT
        STRPOS(par_list19, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list19, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list19 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list19;
        SELECT
            STRPOS(par_list19, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list19
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* process @list20 */
    SELECT
        STRPOS(par_list20, ',')
        INTO var_comma;

    WHILE var_comma <> 0 LOOP
        SELECT
            LEFT(par_list20, var_comma - 1)
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
                        INTO var_row_id;
                ELSE
                    SELECT
                        NULL
                        INTO var_row_id;
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
                        INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                        VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                    END;
                ELSE
                    BEGIN
                        INSERT INTO t$temp_result (hkid, ref_date, row_id)
                        VALUES (var_hkid, var_ref_date, var_row_id);
                    END;
                END IF;
            END;
        END IF;
        SELECT
            OVERLAY(par_list20 PLACING NULL FROM 1 FOR var_comma)
            INTO par_list20;
        SELECT
            STRPOS(par_list20, ',')
            INTO var_comma;
    END LOOP;
    SELECT
        par_list20
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
                    INTO var_row_id;
            ELSE
                SELECT
                    NULL
                    INTO var_row_id;
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
                    INSERT INTO t$temp_result (hkid, hospital_code, exclude_case_no, ref_date, row_id)
                    VALUES (var_hkid, var_hospital, var_case_no, var_ref_date, var_row_id);
                END;
            ELSE
                BEGIN
                    INSERT INTO t$temp_result (hkid, ref_date, row_id)
                    VALUES (var_hkid, var_ref_date, var_row_id);
                END;
            END IF;
        END;
    END IF;
    /* --update death indicator */
    UPDATE t$temp_result AS r
    SET death = 'Y'
    FROM patient AS p
        WHERE p.hkid = r.hkid AND p.death_indicator IS NOT NULL AND p.death_date IS NOT NULL;
    OPEN csr_tmp;
    FETCH csr_tmp INTO var_hkid, var_hospital, var_exclude_case, var_ref_date, var_row_id;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        INSERT INTO t$temp_cur_table (hkid, hospital_code, exclude_case_no, ref_date, row_id)
        VALUES (var_hkid, var_hospital, var_exclude_case, var_ref_date, var_row_id);
        FETCH csr_tmp INTO var_hkid, var_hospital, var_exclude_case, var_ref_date, var_row_id;
    END LOOP;
    SELECT
        0
        INTO var_active_ip_case;
    SELECT
        0
        INTO var_discharge_case;
    OPEN csr;
    FETCH csr INTO var_hkid, var_hospital, var_exclude_case, var_ref_date, var_row_id;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            COUNT(1)
            INTO var_active_ip_case
            FROM pmi_case AS c, patient AS p
            WHERE c.patient_key = p.patient_key AND c.case_type = 'I' AND c.discharge_code IS NULL AND c.discharge_dtm IS NULL AND p.hkid = var_hkid;

        IF var_active_ip_case > 0 THEN
            BEGIN
                UPDATE t$temp_result
                SET in_patient = 'Y'
                    WHERE hkid = var_hkid;
            END;
        ELSE
            BEGIN
                IF var_hospital IS NOT NULL AND var_exclude_case IS NOT NULL THEN
                    BEGIN
                        SELECT
                            COUNT(1)
                            INTO var_discharge_case
                            FROM pmi_case AS c, patient AS p
                            WHERE c.patient_key = p.patient_key AND c.discharge_code IS NOT NULL AND c.discharge_dtm >= var_ref_date::TIMESTAMP WITHOUT TIME ZONE AND c.case_type IN ('I', 'A') AND p.hkid = var_hkid AND NOT (c.hospital_code = var_hospital AND c.case_no = var_exclude_case);
                    END;
                ELSE
                    BEGIN
                        SELECT
                            COUNT(1)
                            INTO var_discharge_case
                            FROM pmi_case AS c, patient AS p
                            WHERE c.patient_key = p.patient_key AND c.discharge_code IS NOT NULL AND c.discharge_dtm >= var_ref_date::TIMESTAMP WITHOUT TIME ZONE AND c.case_type IN ('I', 'A') AND p.hkid = var_hkid;
                    END;
                END IF;

                IF var_discharge_case > 0 THEN
                    BEGIN
                        UPDATE t$temp_result
                        SET discharged_case_found = 'Y'
                            WHERE hkid = var_hkid AND row_id = var_row_id;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            0
            INTO var_active_ip_case;
        SELECT
            0
            INTO var_discharge_case;
        SELECT
            NULL
            INTO var_hkid;
        SELECT
            NULL
            INTO var_hospital;
        SELECT
            NULL
            INTO var_exclude_case;
        SELECT
            NULL
            INTO var_ref_date;
        SELECT
            NULL
            INTO var_row_id;
        FETCH csr INTO var_hkid, var_hospital, var_exclude_case, var_ref_date, var_row_id;
    END LOOP;
    CLOSE csr_tmp;
    CLOSE csr;
    UPDATE t$temp_result
    SET death = 'N'
        WHERE death IS NULL;
    UPDATE t$temp_result
    SET in_patient = 'N'
        WHERE in_patient IS NULL;
    UPDATE t$temp_result
    SET discharged_case_found = 'N'
        WHERE discharged_case_found IS NULL;
    OPEN p_refcur FOR
    SELECT
        RTRIM(hkid), death, in_patient, discharged_case_found, row_id
        FROM t$temp_result;
    return next p_refcur;
    RETURN;
    DROP TABLE t$temp_result;
    DROP TABLE t$temp_cur_table;
    /*
    
    DROP TABLE IF EXISTS t$temp_result;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$temp_cur_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_get_patient_status" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
