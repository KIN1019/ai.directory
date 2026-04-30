-- DROP FUNCTION hasp_pseudo_update_rate(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hasp_pseudo_update_rate(par_hosp_code character varying, par_input_from_date timestamp without time zone, par_input_to_date timestamp without time zone)
 RETURNS TABLE(hkid character varying, case_no character varying, pay_code character varying, doc_no character varying, new_hkid character varying, new_pay_code character varying, new_doc_no character varying, system_dtm timestamp without time zone, type character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code        INTEGER;
    var_result_str_value_1 VARCHAR(128);
    var_result_str_value_2 VARCHAR(128);
    var_result_str_value_3 VARCHAR(128);
    var_result_str_value_4 VARCHAR(128);
    var_result_dtm_value_1 TIMESTAMP;
    var_result_dtm_value_2 TIMESTAMP;
    var_result_dtm_value_3 TIMESTAMP;
    var_cancel_dtm         TIMESTAMP;
    var_tx_dtm             TIMESTAMP;
    var_hkid               VARCHAR(12);
    var_paycode            VARCHAR(3);
    var_case_no            VARCHAR(12);
    var_doc_no             VARCHAR(12);
    var_dob                TIMESTAMP;
    var_age_char           VARCHAR(5);
    var_adm_dtm            TIMESTAMP;
    var_new_hkid           VARCHAR(12);
    var_new_paycode        VARCHAR(3);
    var_new_doc_no         VARCHAR(12);
    var_age_flag           VARCHAR(1);
    var_tx_type            VARCHAR(3);
    var_sys_dtm            TIMESTAMP;
    var_system_dtm         TIMESTAMP;
BEGIN
    -- Adjust end date
    par_input_to_date := par_input_to_date + INTERVAL '1 day';

    -- Create temporary table for pseudo admissions
    CREATE TEMP TABLE t$tmp_pseudo_adm (
                                           hkid         VARCHAR(12),
                                           case_no      VARCHAR(12),
                                           pay_code     VARCHAR(3),
                                           doc_no       VARCHAR(12),
                                           new_hkid     VARCHAR(12),
                                           new_pay_code VARCHAR(3),
                                           new_doc_no   VARCHAR(12),
                                           system_dtm   TIMESTAMP,
                                           type         VARCHAR(1));

    -- Temporary table for admissions
    CREATE TEMP TABLE t$tmp_adm AS
    SELECT
        tl.case_no,
        tl.system_datetime
    FROM
        transaction_log tl
    WHERE
          tl.transaction_datetime >= par_input_from_date
      AND tl.transaction_datetime < par_input_to_date
      AND tl.transaction_type = '100'
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code;

    FOR var_case_no, var_sys_dtm IN
        SELECT
            ta.case_no,
            ta.system_datetime
        FROM
            t$tmp_adm ta
    LOOP
        SELECT
            el.hkid,
            el.pay_code,
            el.other_document_no,
            el.dob,
            el.system_datetime,
            el.admission_datetime
        -- INTO var_hkid, var_paycode, var_doc_no, var_dob, var_system_dtm, var_adm_dtm
        INTO var_result_str_value_1,var_result_str_value_2,var_result_str_value_3,var_result_dtm_value_1,var_result_dtm_value_2,var_result_dtm_value_3
        FROM
            event_log el
        WHERE
              el.type = '100'
          AND el.system_datetime = var_sys_dtm
          AND el.hospital_code = par_hosp_code
          AND el.case_no = var_case_no
        LIMIT 1;

        IF FOUND
        THEN
            var_hkid := var_result_str_value_1;
            var_paycode := var_result_str_value_2;
            var_doc_no := var_result_str_value_3;
            var_dob := var_result_dtm_value_1;
            var_system_dtm := var_result_dtm_value_2;
            var_adm_dtm := var_result_dtm_value_3;
        ELSE
            -- Check for previous transactions
            IF EXISTS (SELECT
                           1
                       FROM
                           transaction_log tl
                       WHERE
                             tl.case_no = var_case_no
                         AND tl.cancel_flag IS NOT NULL
                         AND tl.transaction_type = '100'
                         AND tl.hospital_code = par_hosp_code
                         AND tl.system_datetime < var_sys_dtm)
            THEN
                SELECT
                    tl.system_datetime
                -- INTO var_cancel_dtm
                INTO var_result_dtm_value_1
                FROM
                    transaction_log tl
                WHERE
                      tl.case_no = var_case_no
                  AND tl.cancel_flag IS NULL
                  AND tl.transaction_type = '201'
                  AND tl.hospital_code = par_hosp_code
                  AND tl.system_datetime >= (SELECT
                                                 MIN(tl2.system_datetime)
                                             FROM
                                                 transaction_log tl2
                                             WHERE
                                                   tl2.case_no = var_case_no
                                               AND tl2.cancel_flag IS NOT NULL
                                               AND tl2.transaction_type = '100'
                                               AND tl2.hospital_code = par_hosp_code
                                               AND tl2.system_datetime < var_sys_dtm)
                  AND tl.system_datetime < var_sys_dtm
                ORDER BY tl.system_datetime ASC
                LIMIT 1;
                IF FOUND
                THEN
                    var_cancel_dtm := var_result_dtm_value_1;
                END IF;

                SELECT
                    MIN(tl.transaction_datetime)
                -- INTO var_tx_dtm
                INTO var_result_dtm_value_1
                FROM
                    transaction_log tl
                WHERE
                      tl.case_no = var_case_no
                  AND tl.cancel_flag IS NULL
                  AND tl.system_datetime > var_cancel_dtm
                  AND tl.system_datetime <= var_sys_dtm
                  AND tl.hospital_code = par_hosp_code;
                IF FOUND
                THEN
                    var_tx_dtm := var_result_dtm_value_1;
                END IF;

                IF var_cancel_dtm > var_tx_dtm
                THEN
                    var_tx_dtm := var_cancel_dtm;
                END IF;
            ELSE
                SELECT
                    MIN(tl.transaction_datetime)
                -- INTO var_tx_dtm
                INTO var_result_dtm_value_1
                FROM
                    transaction_log tl
                WHERE
                      tl.case_no = var_case_no
                  AND tl.cancel_flag IS NULL
                  AND tl.system_datetime <= var_sys_dtm
                  AND tl.hospital_code = par_hosp_code;
                IF FOUND
                THEN
                    var_tx_dtm := var_result_dtm_value_1;
                END IF;
            END IF;

            SELECT
                el.hkid,
                el.pay_code,
                el.other_document_no,
                el.dob,
                el.system_datetime,
                el.admission_datetime
            -- INTO var_hkid, var_paycode, var_doc_no, var_dob, var_system_dtm, var_adm_dtm
            INTO var_result_str_value_1,var_result_str_value_2,var_result_str_value_3,var_result_dtm_value_1,var_result_dtm_value_2,var_result_str_value_4
            FROM
                event_log el
            WHERE
                  el.type = '100'
              AND el.system_datetime >= var_tx_dtm
              AND el.system_datetime <= var_sys_dtm + INTERVAL '1 second'
              AND el.case_no = var_case_no
              AND el.hospital_code = par_hosp_code
            LIMIT 1;

            IF NOT FOUND
            THEN
                CONTINUE;
            ELSE
                var_hkid := var_result_str_value_1;
                var_paycode := var_result_str_value_2;
                var_doc_no := var_result_str_value_3;
                var_dob := var_result_dtm_value_1;
                var_system_dtm := var_result_dtm_value_2;
                var_adm_dtm := var_result_str_value_4;
            END IF;
        END IF;

        var_age_flag := 'N';

        IF var_hkid LIKE 'U%' AND (var_paycode = 'NEP' OR var_paycode = 'NE9') AND COALESCE(var_doc_no, '') = ''
        THEN
            IF var_dob IS NOT NULL
            THEN
                -- Placeholder for age calculation
                CALL hasp_cal_age(var_return_code, var_dob, var_adm_dtm, var_age_char);

                IF RIGHT(var_age_char, 1) <> 'y' AND
                   DATE_PART('day', var_adm_dtm ::date::timestamp - var_dob::date::timestamp) < 42
                THEN
                    var_age_flag := 'Y';
                END IF;
            END IF;

            IF var_age_flag = 'N' OR var_dob IS NULL
            THEN
                SELECT
                    ct.hkid,
                    ct.patient_type,
                    ct.other_document_no,
                    ct.transaction_datetime,
                    ct.transaction_type
                -- INTO var_new_hkid, var_new_paycode, var_new_doc_no, var_system_dtm, var_tx_type
                INTO var_result_str_value_1,var_result_str_value_2,var_result_str_value_3,var_result_dtm_value_1,var_result_str_value_4
                FROM
                    cpi_transaction ct
                WHERE
                      ct.hospital_code = par_hosp_code
                  AND ct.transaction_datetime >= var_system_dtm
                  AND ct.transaction_datetime <= var_system_dtm + INTERVAL '14 days'
                  AND (
                          (ct.transaction_type = '121' AND ct.case_no = var_case_no AND
                           COALESCE(ct.patient_type, '') <> COALESCE(var_paycode, ''))
                              OR (ct.transaction_type = '040' AND ct.old_hkid = var_hkid AND
                                  COALESCE(ct.hkid, '') <> COALESCE(var_hkid, ''))
                              OR (ct.transaction_type IN ('100', '300') AND
                                  COALESCE(ct.other_document_no, '') <> COALESCE(var_doc_no, '') AND ct.hkid = var_hkid)
                              OR (ct.old_hkid = var_hkid AND ct.transaction_type IN ('030', '031', '020') AND
                                  (COALESCE(ct.hkid, '') <> COALESCE(var_hkid, '') OR
                                   COALESCE(ct.other_document_no, '') <> COALESCE(var_doc_no, '')))
                          )
                ORDER BY ct.transaction_datetime ASC
                LIMIT 1;

                IF FOUND
                THEN
                    var_new_hkid := var_result_str_value_1;
                    var_new_paycode := var_result_str_value_2;
                    var_new_doc_no := var_result_str_value_3;
                    var_system_dtm := var_result_dtm_value_1;
                    var_tx_type := var_result_str_value_4;
                    IF var_hkid = var_new_hkid
                    THEN
                        var_new_hkid := NULL;
                    END IF;
                    IF var_paycode = var_new_paycode
                    THEN
                        var_new_paycode := NULL;
                    END IF;
                    IF var_doc_no = var_new_doc_no
                    THEN
                        var_new_doc_no := NULL;
                    END IF;

                    IF var_tx_type = '100' OR var_tx_type = '300'
                    THEN
                        var_new_paycode := NULL;
                    END IF;

                    INSERT INTO t$tmp_pseudo_adm
                    VALUES (var_hkid, var_case_no, var_paycode, var_doc_no, var_new_hkid, var_new_paycode,
                            var_new_doc_no, var_system_dtm, 'U');
                ELSE
                    INSERT INTO t$tmp_pseudo_adm
                        (hkid, case_no, pay_code, doc_no, system_dtm, type)
                    VALUES (var_hkid, var_case_no, var_paycode, var_doc_no, var_system_dtm, 'A');
                END IF;
            END IF;
        END IF;
    END LOOP;

    -- Return results
    RETURN QUERY
        SELECT
            t.hkid,
            t.case_no,
            t.pay_code,
            t.doc_no,
            t.new_hkid,
            t.new_pay_code,
            t.new_doc_no,
            t.system_dtm,
            t.type
        FROM
            t$tmp_pseudo_adm t
        ORDER BY t.hkid, t.system_dtm;

    -- Clean up temporary tables
    DROP TABLE IF EXISTS t$tmp_pseudo_adm;
    DROP TABLE IF EXISTS t$tmp_adm;
END;
$function$
;


;ALTER FUNCTION "hasp_pseudo_update_rate" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
