-- DROP PROCEDURE gopd_get_quota_worksheet(inout int4, in bpchar, in bpchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE gopd_get_quota_worksheet(INOUT pas_return_code integer, IN par_hospital character, IN par_institute character, IN par_from_datetime timestamp without time zone, IN par_to_datetime timestamp without time zone, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* 2009-06-04 Leung SMR20017400 Handle Multi * Group in the same institute */
/* 2004-10-19 HK Fong SMR20013618 - Debug the GOPC quota worksheet when overall quota is zero */
/* 2003-11-10 HK Fong SMR20012589 - GOPC Enhancement - Print the Worksheet of Quota Setting */
DECLARE
    var_row_total INTEGER;
    var_session_start_time TIMESTAMP WITHOUT TIME ZONE;
    var_session_end_time TIMESTAMP WITHOUT TIME ZONE;
    var_session_am_pm_time TIMESTAMP WITHOUT TIME ZONE;
    var_session_evening_time TIMESTAMP WITHOUT TIME ZONE;
    var_specialty VARCHAR(4);
    var_sub_specialty_group VARCHAR(3);
    var_sub_specialty VARCHAR(4);
    var_slot_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_sub_specialty VARCHAR(4);
    var_row_count INTEGER;
    var_current_session INTEGER;
    var_normal_remain INTEGER;
    var_force_remain INTEGER;
    var_batch_remain INTEGER;
    var_start_seq INTEGER;
    var_end_seq INTEGER;
    var_current_seq INTEGER;
    var_cancel_count INTEGER;
    var_output_content VARCHAR(60);
    var_running_index INTEGER;
    var_last_seq_no INTEGER;
    var_quota_seq_no VARCHAR(4);
    var_quota_booked VARCHAR(1);
    var_gopd_quota_type VARCHAR(1);
    var_overall_quota INTEGER;
    gopd_get_session$refcur_1 refcursor;
    sql$rowcount BIGINT;
    var_enable_mobile_quota VARCHAR(1);
BEGIN
    /* 2004-10-19 HK Fong SMR20013618 - Start */
    /* 2004-10-19 HK Fong SMR20013618 - End */
    CALL gopd_get_session(pas_return_code => pas_return_code, par_hospital => par_hospital, par_institute => par_institute, par_session => var_current_session, par_session_start_time => var_session_start_time, par_session_end_time => var_session_end_time, par_session_am_pm_time => var_session_am_pm_time, par_session_evening_time => var_session_evening_time, par_select_output => 'N', p_refcur => gopd_get_session$refcur_1);
    CLOSE gopd_get_session$refcur_1;
    SELECT
        CONCAT('19000101 ', TO_CHAR(session_am_pm_time::time, 'HH24:MI:SS')), CONCAT('19000101 ', TO_CHAR(session_evening_time::time, 'HH24:MI:SS'))
        INTO var_session_am_pm_time, var_session_evening_time;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 1
    */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 1
    */
    SELECT
        specialty, SUBSTRING(sub_specialty, 2, 3)
        INTO var_specialty, var_sub_specialty_group
        FROM gopd_booking
        WHERE hospital = par_hospital AND institute = par_institute AND sub_specialty like '*%' AND COALESCE(primary_group, '') <> 'N' limit 1; /* 2009-06-04 Leung SMR20017400 */
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 0
    */
	DROP TABLE IF EXISTS t$temp_slot;
    CREATE TEMPORARY TABLE t$temp_slot
    (sub_specialty VARCHAR(4),
        slot_datetime TIMESTAMP WITHOUT TIME ZONE,
        gopd_session INTEGER NULL);
    INSERT INTO t$temp_slot
    SELECT
        b.sub_specialty, c.start_datetime, NULL
        FROM sub_specialty_group_detail AS b, slot AS c
        WHERE b.specialty = var_specialty AND b.code = var_sub_specialty_group AND c.specialty = b.specialty AND c.sub_specialty = b.sub_specialty AND c.start_datetime >= par_from_datetime AND c.start_datetime < par_to_datetime
        ORDER BY 1 NULLS FIRST, 2 NULLS FIRST;
	DROP TABLE IF EXISTS t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (slot_datetime TIMESTAMP WITHOUT TIME ZONE,
        sub_specialty VARCHAR(4),
        gopd_session INTEGER NULL,
        seq_no VARCHAR(4),
        case_type VARCHAR(1),
        quota_type VARCHAR(1),
        gopd_quota_type VARCHAR(1),
        booked VARCHAR(1));
    INSERT INTO t$temp_result
    SELECT
        a.slot_datetime, a.sub_specialty, NULL, a.priority, a.case_type, a.book_type, ' ', 'Y'
        FROM appointment AS a, t$temp_slot AS b
        WHERE a.sub_specialty = b.sub_specialty AND a.specialty = var_specialty AND a.slot_datetime = b.slot_datetime AND a.status = 'A';
    UPDATE t$temp_result
    SET quota_type = 'N'
        WHERE quota_type = 'w' OR quota_type = 'W';
    /* 2003-11-27 HK Fong - Start */
    /* handle reuse sequence no. */
    INSERT INTO t$temp_result
    SELECT
        a.slot_datetime, a.sub_specialty, NULL, a.priority, a.case_type, '-', ' ', 'N'
        FROM cancel_seq_no AS a, t$temp_slot AS b
        WHERE a.sub_specialty = b.sub_specialty AND a.specialty = var_specialty AND a.slot_datetime = b.slot_datetime
        ORDER BY 1 NULLS FIRST, 2 NULLS FIRST, 4 NULLS FIRST;
    /* 2003-11-27 HK Fong - End */
    SELECT
        1
        INTO var_row_count;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 1
    */
    WHILE (var_row_count > 0) LOOP
        SELECT
            sub_specialty, slot_datetime
            INTO var_sub_specialty, var_slot_datetime
            FROM t$temp_slot;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;

        IF var_row_count = 0 THEN
            CONTINUE;
        END IF;
        /* 2004-10-19 HK Fong SMR20013618 - Start */
        SELECT
            slot_quota
            INTO var_overall_quota
            FROM slot
            WHERE specialty = var_specialty AND sub_specialty = var_sub_specialty AND start_datetime = var_slot_datetime;

        IF var_overall_quota < 0 THEN
            SELECT
                0
                INTO var_overall_quota;
        END IF;
        /* 2004-10-19 HK Fong SMR20013618 - End */
        SELECT
            sub_normal_quota - sub_normal_book, sub_force_quota - sub_force_book, sub_batch_quota - sub_batch_book, sub_seq_start, sub_seq_end, sub_seq
            INTO var_normal_remain, var_force_remain, var_batch_remain, var_start_seq, var_end_seq, var_current_seq
            FROM slot
            WHERE specialty = var_specialty AND sub_specialty = var_sub_specialty AND start_datetime = var_slot_datetime AND sub_seq_start > 0 AND sub_seq_end > 0;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;

        IF var_row_count > 0 THEN
            BEGIN
                /* handle cancel and reused seq. */
                SELECT
                    COUNT(*)
                    INTO var_cancel_count
                    FROM t$temp_result
                    WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'S' AND quota_type = '-';
                /* 2004-10-19 HK Fong SMR20013618 - Start */
                IF var_normal_remain < 0 THEN
                    SELECT
                        0
                        INTO var_normal_remain;
                END IF;

                IF var_force_remain < 0 THEN
                    SELECT
                        0
                        INTO var_force_remain;
                END IF;

                IF var_batch_remain < 0 THEN
                    SELECT
                        0
                        INTO var_batch_remain;
                END IF;

                IF var_overall_quota < var_batch_remain THEN
                    SELECT
                        var_overall_quota, 0
                        INTO var_batch_remain, var_overall_quota;
                ELSE
                    SELECT
                        var_overall_quota - var_batch_remain
                        INTO var_overall_quota;
                END IF;

                IF var_overall_quota < var_force_remain THEN
                    SELECT
                        var_overall_quota, 0
                        INTO var_force_remain, var_overall_quota;
                ELSE
                    SELECT
                        var_overall_quota - var_force_remain
                        INTO var_overall_quota;
                END IF;

                IF var_overall_quota < var_normal_remain THEN
                    SELECT
                        var_overall_quota, 0
                        INTO var_normal_remain, var_overall_quota;
                ELSE
                    SELECT
                        var_overall_quota - var_normal_remain
                        INTO var_overall_quota;
                END IF;
                /* 2004-10-19 HK Fong SMR20013618 - End */
                /* Batch-in */
                IF var_cancel_count > 0 AND var_batch_remain > 0 THEN
                    BEGIN
                        IF var_cancel_count > var_batch_remain THEN
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @batch_remain clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @batch_remain
                                */
                                SELECT
                                    var_cancel_count - var_batch_remain, 0
                                    INTO var_cancel_count, var_batch_remain;
                            END;
                        ELSE
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @cancel_count clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @cancel_count
                                */
                                SELECT
                                    var_batch_remain - var_cancel_count, 0
                                    INTO var_batch_remain, var_cancel_count;
                            END;
                        END IF;
                        UPDATE t$temp_result
                        SET quota_type = 'B'
                            WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'S' AND quota_type = '-';
                    END;
                END IF;
                /* Force */
                IF var_cancel_count > 0 AND var_force_remain > 0 THEN
                    BEGIN
                        IF var_cancel_count > var_force_remain THEN
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @force_remain clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @force_remain
                                */
                                SELECT
                                    var_cancel_count - var_force_remain, 0
                                    INTO var_cancel_count, var_force_remain;
                            END;
                        ELSE
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @cancel_count clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @cancel_count
                                */
                                SELECT
                                    var_force_remain - var_cancel_count, 0
                                    INTO var_force_remain, var_cancel_count;
                            END;
                        END IF;
                        UPDATE t$temp_result
                        SET quota_type = 'F'
                            WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'S' AND quota_type = '-';
                    END;
                END IF;
                /* Normal */
                IF var_cancel_count > 0 AND var_normal_remain > 0 THEN
                    BEGIN
                        IF var_cancel_count > var_normal_remain THEN
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @normal_remain clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @normal_remain
                                */
                                SELECT
                                    var_cancel_count - var_normal_remain, 0
                                    INTO var_cancel_count, var_normal_remain;
                            END;
                        ELSE
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @cancel_count clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @cancel_count
                                */
                                SELECT
                                    var_normal_remain - var_cancel_count, 0
                                    INTO var_normal_remain, var_cancel_count;
                            END;
                        END IF;
                        UPDATE t$temp_result
                        SET quota_type = 'N'
                            WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'S' AND quota_type = '-';
                    END;
                END IF;
            END;
        END IF;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
        SET ROWCOUNT 1
        */
        IF var_row_count > 0 AND var_current_seq < var_end_seq THEN
            BEGIN
                IF var_current_seq < var_start_seq THEN
                    SELECT
                        var_start_seq
                        INTO var_current_seq;
                ELSE
                    SELECT
                        var_current_seq + 1
                        INTO var_current_seq;
                END IF;

                IF var_end_seq - (var_current_seq + var_normal_remain + var_force_remain + var_batch_remain) >= 100 THEN
                    SELECT
                        var_current_seq + var_normal_remain + var_force_remain + var_batch_remain
                        INTO var_end_seq;
                END IF;

                IF (var_batch_remain > 0 AND var_end_seq >= var_current_seq) THEN
                    BEGIN
                        IF var_batch_remain > (var_end_seq - var_current_seq + 1) THEN
                            SELECT
                                var_end_seq - var_current_seq + 1
                                INTO var_batch_remain;
                        END IF;

                        WHILE (var_batch_remain > 0) LOOP
                            INSERT INTO t$temp_result
                            VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                            CASE CAST (var_current_seq AS VARCHAR(4))
                                WHEN '' THEN ' '
                                ELSE CAST (var_current_seq AS VARCHAR(4))
                            END)), 1, 4)), 'S', 'B', ' ', 'N');
                            SELECT
                                var_batch_remain - 1, var_current_seq + 1
                                INTO var_batch_remain, var_current_seq;
                        END LOOP;
                    END;
                END IF;

                IF (var_force_remain > 0 AND var_end_seq >= var_current_seq) THEN
                    BEGIN
                        IF var_force_remain > (var_end_seq - var_current_seq + 1) THEN
                            SELECT
                                var_end_seq - var_current_seq + 1
                                INTO var_force_remain;
                        END IF;

                        WHILE (var_force_remain > 0) LOOP
                            INSERT INTO t$temp_result
                            VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                            CASE CAST (var_current_seq AS VARCHAR(4))
                                WHEN '' THEN ' '
                                ELSE CAST (var_current_seq AS VARCHAR(4))
                            END)), 1, 4)), 'S', 'F', ' ', 'N');
                            SELECT
                                var_force_remain - 1, var_current_seq + 1
                                INTO var_force_remain, var_current_seq;
                        END LOOP;
                    END;
                END IF;

                IF (var_normal_remain > 0 AND var_end_seq >= var_current_seq) THEN
                    BEGIN
                        IF var_normal_remain > (var_end_seq - var_current_seq + 1) THEN
                            SELECT
                                var_end_seq - var_current_seq + 1
                                INTO var_normal_remain;
                        END IF;

                        WHILE (var_normal_remain > 0) LOOP
                            INSERT INTO t$temp_result
                            VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                            CASE CAST (var_current_seq AS VARCHAR(4))
                                WHEN '' THEN ' '
                                ELSE CAST (var_current_seq AS VARCHAR(4))
                            END)), 1, 4)), 'S', 'N', ' ', 'N');
                            SELECT
                                var_normal_remain - 1, var_current_seq + 1
                                INTO var_normal_remain, var_current_seq;
                        END LOOP;
                    END;
                END IF;

                WHILE (var_end_seq >= var_current_seq) LOOP
                    INSERT INTO t$temp_result
                    VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                    CASE CAST (var_current_seq AS VARCHAR(4))
                        WHEN '' THEN ' '
                        ELSE CAST (var_current_seq AS VARCHAR(4))
                    END)), 1, 4)), 'R', ' ', 'R', 'N');
                    SELECT
                        var_current_seq + 1
                        INTO var_current_seq;
                END LOOP;
            END;
        END IF;
        SELECT
            new_normal_quota - new_normal_book, new_force_quota - new_force_book, new_batch_quota - new_batch_book, new_seq_start, new_seq_end, new_seq
            INTO var_normal_remain, var_force_remain, var_batch_remain, var_start_seq, var_end_seq, var_current_seq
            FROM slot
            WHERE specialty = var_specialty AND sub_specialty = var_sub_specialty AND start_datetime = var_slot_datetime AND new_seq_start > 0 AND new_seq_end > 0;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;

        IF var_row_count > 0 THEN
            BEGIN
                SELECT
                    COUNT(*)
                    INTO var_cancel_count
                    FROM t$temp_result
                    WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'N' AND quota_type = '-';
                /* 2004-10-19 HK Fong SMR20013618 - Start */
                IF var_normal_remain < 0 THEN
                    SELECT
                        0
                        INTO var_normal_remain;
                END IF;

                IF var_force_remain < 0 THEN
                    SELECT
                        0
                        INTO var_force_remain;
                END IF;

                IF var_batch_remain < 0 THEN
                    SELECT
                        0
                        INTO var_batch_remain;
                END IF;

                IF var_overall_quota < 0 THEN
                    SELECT
                        0
                        INTO var_overall_quota;
                END IF;

                IF var_overall_quota < var_batch_remain THEN
                    SELECT
                        var_overall_quota, 0
                        INTO var_batch_remain, var_overall_quota;
                ELSE
                    SELECT
                        var_overall_quota - var_batch_remain
                        INTO var_overall_quota;
                END IF;

                IF var_overall_quota < var_force_remain THEN
                    SELECT
                        var_overall_quota, 0
                        INTO var_force_remain, var_overall_quota;
                ELSE
                    SELECT
                        var_overall_quota - var_force_remain
                        INTO var_overall_quota;
                END IF;

                IF var_overall_quota < var_normal_remain THEN
                    SELECT
                        var_overall_quota, 0
                        INTO var_normal_remain, var_overall_quota;
                ELSE
                    SELECT
                        var_overall_quota - var_normal_remain
                        INTO var_overall_quota;
                END IF;
                /* 2004-10-19 HK Fong SMR20013618 - End */
                /* handle cancel and reused seq. */
                /* Batch-in */
                IF var_cancel_count > 0 AND var_batch_remain > 0 THEN
                    BEGIN
                        IF var_cancel_count > var_batch_remain THEN
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @batch_remain clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @batch_remain
                                */
                                SELECT
                                    var_cancel_count - var_batch_remain, 0
                                    INTO var_cancel_count, var_batch_remain;
                            END;
                        ELSE
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @cancel_count clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @cancel_count
                                */
                                SELECT
                                    var_batch_remain - var_cancel_count, 0
                                    INTO var_batch_remain, var_cancel_count;
                            END;
                        END IF;
                        UPDATE t$temp_result
                        SET quota_type = 'B'
                            WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'N' AND quota_type = '-';
                    END;
                END IF;
                /* Force */
                IF var_cancel_count > 0 AND var_force_remain > 0 THEN
                    BEGIN
                        IF var_cancel_count > var_force_remain THEN
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @force_remain clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @force_remain
                                */
                                SELECT
                                    var_cancel_count - var_force_remain, 0
                                    INTO var_cancel_count, var_force_remain;
                            END;
                        ELSE
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @cancel_count clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @cancel_count
                                */
                                SELECT
                                    var_force_remain - var_cancel_count, 0
                                    INTO var_force_remain, var_cancel_count;
                            END;
                        END IF;
                        UPDATE t$temp_result
                        SET quota_type = 'F'
                            WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'N' AND quota_type = '-';
                    END;
                END IF;
                /* Normal */
                IF var_cancel_count > 0 AND var_normal_remain > 0 THEN
                    BEGIN
                        IF var_cancel_count > var_normal_remain THEN
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @normal_remain clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @normal_remain
                                */
                                SELECT
                                    var_cancel_count - var_normal_remain, 0
                                    INTO var_cancel_count, var_normal_remain;
                            END;
                        ELSE
                            BEGIN
                                /*
                                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @cancel_count clause of SET statement is not supported. Perform a manual conversion.]
                                SET ROWCOUNT @cancel_count
                                */
                                SELECT
                                    var_normal_remain - var_cancel_count, 0
                                    INTO var_normal_remain, var_cancel_count;
                            END;
                        END IF;
                        UPDATE t$temp_result
                        SET quota_type = 'N'
                            WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND case_type = 'N' AND quota_type = '-';
                    END;
                END IF;
            END;
        END IF;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
        SET ROWCOUNT 1
        */
        IF var_row_count > 0 AND var_current_seq < var_end_seq THEN
            BEGIN
                IF var_current_seq < var_start_seq THEN
                    SELECT
                        var_start_seq
                        INTO var_current_seq;
                ELSE
                    SELECT
                        var_current_seq + 1
                        INTO var_current_seq;
                END IF;

                IF var_end_seq - (var_current_seq + var_normal_remain + var_force_remain + var_batch_remain) >= 100 THEN
                    SELECT
                        var_current_seq + var_normal_remain + var_force_remain + var_batch_remain
                        INTO var_end_seq;
                END IF;

                IF (var_batch_remain > 0 AND var_end_seq >= var_current_seq) THEN
                    BEGIN
                        IF var_batch_remain > (var_end_seq - var_current_seq + 1) THEN
                            SELECT
                                var_end_seq - var_current_seq + 1
                                INTO var_batch_remain;
                        END IF;

                        WHILE (var_batch_remain > 0) LOOP
                            INSERT INTO t$temp_result
                            VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                            CASE CAST (var_current_seq AS VARCHAR(4))
                                WHEN '' THEN ' '
                                ELSE CAST (var_current_seq AS VARCHAR(4))
                            END)), 1, 4)), 'N', 'B', ' ', 'N');
                            SELECT
                                var_batch_remain - 1, var_current_seq + 1
                                INTO var_batch_remain, var_current_seq;
                        END LOOP;
                    END;
                END IF;

                IF (var_force_remain > 0 AND var_end_seq >= var_current_seq) THEN
                    BEGIN
                        IF var_force_remain > (var_end_seq - var_current_seq + 1) THEN
                            SELECT
                                var_end_seq - var_current_seq + 1
                                INTO var_force_remain;
                        END IF;

                        WHILE (var_force_remain > 0) LOOP
                            INSERT INTO t$temp_result
                            VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                            CASE CAST (var_current_seq AS VARCHAR(4))
                                WHEN '' THEN ' '
                                ELSE CAST (var_current_seq AS VARCHAR(4))
                            END)), 1, 4)), 'N', 'F', ' ', 'N');
                            SELECT
                                var_force_remain - 1, var_current_seq + 1
                                INTO var_force_remain, var_current_seq;
                        END LOOP;
                    END;
                END IF;

                IF (var_normal_remain > 0 AND var_end_seq >= var_current_seq) THEN
                    BEGIN
                        IF var_normal_remain > (var_end_seq - var_current_seq + 1) THEN
                            SELECT
                                var_end_seq - var_current_seq + 1
                                INTO var_normal_remain;
                        END IF;

                        WHILE (var_normal_remain > 0) LOOP
                            INSERT INTO t$temp_result
                            VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                            CASE CAST (var_current_seq AS VARCHAR(4))
                                WHEN '' THEN ' '
                                ELSE CAST (var_current_seq AS VARCHAR(4))
                            END)), 1, 4)), 'N', 'N', ' ', 'N');
                            SELECT
                                var_normal_remain - 1, var_current_seq + 1
                                INTO var_normal_remain, var_current_seq;
                        END LOOP;
                    END;
                END IF;

                WHILE (var_end_seq >= var_current_seq) LOOP
                    INSERT INTO t$temp_result
                    VALUES (var_slot_datetime, var_sub_specialty, NULL, REVERSE(SUBSTRING(REVERSE(CONCAT('0000',
                    CASE CAST (var_current_seq AS VARCHAR(4))
                        WHEN '' THEN ' '
                        ELSE CAST (var_current_seq AS VARCHAR(4))
                    END)), 1, 4)), 'R', ' ', 'R', 'N');
                    SELECT
                        var_current_seq + 1
                        INTO var_current_seq;
                END LOOP;
            END;
        END IF;
        DELETE FROM t$temp_slot
            WHERE slot_datetime = var_slot_datetime AND sub_specialty = var_sub_specialty;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;
    END LOOP;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 0
    */
	UPDATE t$temp_result
	   SET gopd_session = 1,
		   slot_datetime = to_char(slot_datetime, 'YYYY.MM.DD')
	WHERE CONCAT('1900-01-01 ', to_char(slot_datetime, 'HH24:MI:SS'))::timestamp < var_session_am_pm_time;
    
	UPDATE t$temp_result
	   SET gopd_session = 3,
		   slot_datetime = to_char(slot_datetime, 'YYYY.MM.DD')
	WHERE CONCAT('1900-01-01 ', to_char(slot_datetime, 'HH24:MI:SS'))::timestamp >= var_session_evening_time;
	
    
    UPDATE t$temp_result
    SET gopd_session = 2, slot_datetime = to_char(slot_datetime, 'YYYY.MM.DD')
        WHERE gopd_session IS NULL;
		
    SELECT
        COALESCE(enable_mobile_quota, 'N')
        INTO var_enable_mobile_quota
        FROM gopd_system
        WHERE institute = par_institute;
    UPDATE t$temp_result
    SET gopd_quota_type = 'E'
        WHERE quota_type = 'F';
    UPDATE t$temp_result
    SET gopd_quota_type = 'F'
        WHERE case_type = 'S' AND quota_type = 'N';
    UPDATE t$temp_result
    SET gopd_quota_type = 'W'
        WHERE case_type = 'N' AND quota_type = 'N';
    UPDATE t$temp_result
    SET gopd_quota_type = 'G'
        WHERE quota_type = 'B';

    IF var_enable_mobile_quota = 'Y' THEN
        BEGIN
            UPDATE t$temp_result
            SET gopd_quota_type = 'W'
                WHERE case_type = 'S' AND quota_type = 'B';
        END;
    END IF;
    UPDATE t$temp_result
    SET gopd_quota_type = 'R'
        WHERE quota_type = '-';
    DELETE FROM t$temp_slot;
	
	INSERT INTO t$temp_slot (sub_specialty, slot_datetime, gopd_session)
	SELECT DISTINCT sub_specialty, slot_datetime, gopd_session
	  FROM t$temp_result
	 ORDER BY slot_datetime, gopd_session, sub_specialty;

    /*
    [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
    INSERT INTO #temp_slot
    SELECT DISTINCT sub_specialty, slot_datetime, gopd_session
      FROM #temp_result
     ORDER BY 2, 3, 1
    */
	DROP TABLE IF EXISTS t$temp_res1;
    CREATE TEMPORARY TABLE t$temp_res1
    (slot_datetime TIMESTAMP WITHOUT TIME ZONE,
        gopd_session INTEGER,
        sub_specialty VARCHAR(4),
        output_content VARCHAR(60));
    SELECT
        1
        INTO var_row_count;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
    SET ROWCOUNT 1
    */
    WHILE (var_row_count > 0) LOOP
        SELECT
            sub_specialty, slot_datetime, gopd_session
            INTO var_sub_specialty, var_slot_datetime, var_current_session
            FROM t$temp_slot
            ORDER BY slot_datetime NULLS FIRST, gopd_session NULLS FIRST, sub_specialty NULLS FIRST;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;

        IF var_row_count = 0 THEN
            CONTINUE;
        END IF;
        SELECT
            '', 0, 0
            INTO var_output_content, var_running_index, var_last_seq_no;

        WHILE (var_row_count > 0) LOOP
            SELECT
                seq_no, booked, gopd_quota_type
                INTO var_quota_seq_no, var_quota_booked, var_gopd_quota_type
                FROM t$temp_result
                WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND gopd_session = var_current_session AND CAST (seq_no AS INTEGER) > var_last_seq_no
                ORDER BY seq_no NULLS FIRST;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_row_count := sql$rowcount;

            IF var_row_count > 0 THEN
                SELECT
                    var_running_index + 1, CAST (var_quota_seq_no AS INTEGER), CONCAT(RTRIM(LTRIM(var_output_content)), var_quota_seq_no, var_gopd_quota_type, var_quota_booked)
                    INTO var_running_index, var_last_seq_no, var_output_content;
            END IF;

            IF (var_running_index >= 10 OR var_row_count = 0) AND var_output_content <> '' THEN
                BEGIN
                    INSERT INTO t$temp_res1
                    VALUES (var_slot_datetime, var_current_session, var_sub_specialty, var_output_content);
                    SELECT
                        0, ''
                        INTO var_running_index, var_output_content;
                    /*
                    
                    DROP TABLE IF EXISTS t$temp_slot;
                    */
                    /*
                    
                    Temporary table must be removed before end of the function.
                    */
                    /*
                    
                    DROP TABLE IF EXISTS t$temp_result;
                    */
                    /*
                    
                    Temporary table must be removed before end of the function.
                    */
                    /*
                    
                    DROP TABLE IF EXISTS t$temp_res1;
                    */
                    /*
                    
                    Temporary table must be removed before end of the function.
                    */
                END;
            END IF;
        END LOOP;
        DELETE FROM t$temp_slot
            WHERE sub_specialty = var_sub_specialty AND slot_datetime = var_slot_datetime AND gopd_session = var_current_session;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;
    END LOOP;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    SET	ROWCOUNT 0
    */
    OPEN p_refcur FOR
    SELECT
        slot_datetime, gopd_session, sub_specialty, SUBSTRING(output_content, 1, 6), SUBSTRING(output_content, 7, 6), SUBSTRING(output_content, 13, 6), SUBSTRING(output_content, 19, 6), SUBSTRING(output_content, 25, 6), SUBSTRING(output_content, 31, 6), SUBSTRING(output_content, 37, 6), SUBSTRING(output_content, 43, 6), SUBSTRING(output_content, 49, 6), SUBSTRING(output_content, 55, 6)
        FROM t$temp_res1;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "gopd_get_quota_worksheet" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
