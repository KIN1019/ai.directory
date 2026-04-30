-- DROP PROCEDURE hasp_get_linked_move(inout int4, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_linked_move(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_report_from_date timestamp without time zone, IN par_report_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_case      VARCHAR(12);
    var_move_dtm  TIMESTAMP WITHOUT TIME ZONE;
    var_hkid      VARCHAR(12);
    var_prev_hosp VARCHAR(3);
    var_prev_case VARCHAR(12);
    var_old_hkid  VARCHAR(12);
BEGIN
    DROP TABLE IF EXISTS t$temp_move;
    CREATE TEMPORARY TABLE t$temp_move
    (
        case_no           VARCHAR(12),
        move_datetime     TIMESTAMP WITHOUT TIME ZONE,
        from_hkid         VARCHAR(12),
        to_hkid           VARCHAR(12),
        previous_hospital VARCHAR(3),
        previous_case     VARCHAR(12)
    );
    CREATE UNIQUE INDEX temp_move_index1 ON t$temp_move
        (case_no, move_datetime);

    -- Set default dates if not provided
    IF par_report_from_date IS NULL THEN
        IF par_report_to_date IS NULL THEN
            par_report_from_date := CURRENT_DATE - INTERVAL '1 day';
        ELSE
            par_report_from_date := par_report_to_date;
        END IF;
    END IF;

    IF par_report_to_date IS NULL THEN
        par_report_to_date := par_report_from_date + INTERVAL '1 day';
    ELSE
        par_report_to_date := par_report_to_date + INTERVAL '1 day';
    END IF;

    -- Cursor to process case key changes
    FOR var_case, var_move_dtm ,var_hkid IN
        SELECT ck.case_no, ck.system_datetime, ck.old_hkid
        FROM case_key_changed ck
        WHERE ck.system_datetime >= par_report_from_date
          AND ck.system_datetime < par_report_to_date
          AND ck.hospital_code = par_hospital_code
        LOOP
            SELECT lc.previous_hospital, lc.previous_case
            INTO var_prev_hosp, var_prev_case
            FROM linked_case lc
            WHERE lc.hospital_code = par_hospital_code
              AND lc.case_no = var_case;

            IF FOUND THEN
                SELECT ck.old_hkid
                INTO var_old_hkid
                FROM case_key_changed ck
                WHERE ck.case_no = var_case
                  AND ck.system_datetime = (SELECT MAX(ck2.system_datetime)
                                            FROM case_key_changed ck2
                                            WHERE ck2.case_no = var_case
                                              AND ck2.system_datetime < var_move_dtm);

                IF FOUND THEN
                    INSERT INTO t$temp_move (case_no, move_datetime, from_hkid, to_hkid,
                                             previous_hospital, previous_case)
                    VALUES (var_case, var_move_dtm, var_old_hkid, var_hkid,
                            var_prev_hosp, var_prev_case);
                END IF;
            END IF;
        END LOOP;

    CLUSTER t$temp_move USING temp_move_index1;
    
    -- Return results
    OPEN p_refcur FOR
        SELECT case_no,
               move_datetime,
               from_hkid,
               to_hkid,
               previous_hospital,
               previous_case
        FROM t$temp_move;

    -- Set return code
    pas_return_code := 0;

    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_linked_move" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
