-- DROP PROCEDURE hpi.hasp_get_payment_summary(inout int4, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_payment_summary(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_report_type character varying, IN par_start_date timestamp without time zone, IN par_end_date timestamp without time zone, IN par_sort_by character varying, IN par_user_id character varying DEFAULT '%'::character varying, IN par_term_id character varying DEFAULT '%'::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_report_date TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    IF par_report_type = 'E' THEN
        BEGIN

            var_report_date := TO_DATE(TO_CHAR(par_end_date, 'YYYYMMDD'), 'YYYYMMDD');
            SELECT MAX(transaction_datetime)
            INTO par_end_date
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= var_report_date
              AND transaction_datetime < 1 * INTERVAL '1 day' + var_report_date::TIMESTAMP
              AND transaction_type = 'E';

            var_report_date := TO_DATE(TO_CHAR(par_start_date, 'YYYYMMDD'), 'YYYYMMDD');
            SELECT MAX(transaction_datetime)
            INTO par_start_date
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime <= var_report_date
              AND transaction_type = 'E';

            IF par_start_date IS NULL THEN
                SELECT MIN(transaction_datetime)
                INTO par_start_date
                FROM payment_detail
                WHERE hospital_code = par_hosp_code;
            END IF;
        END;
    END IF;

    IF par_report_type IN ('T', 'R') THEN
        BEGIN
            SELECT par_start_date
            INTO var_report_date;

            SELECT MAX(transaction_datetime)
            INTO par_start_date
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime < var_report_date
              AND transaction_type IN ('R', 'E');

            IF par_start_date IS NULL THEN
                SELECT MIN(transaction_datetime)
                INTO par_start_date
                FROM payment_detail
                WHERE hospital_code = par_hosp_code
                  AND transaction_datetime < var_report_date;
            END IF;
        END;
    END IF;

    DROP TABLE IF EXISTS t$temp_payment_summary;
    CREATE TEMPORARY TABLE t$temp_payment_summary
    (
        pay_code         VARCHAR(12),
        payment_means    VARCHAR(20),
        transaction_type VARCHAR(4),
        paid_amount_sum  INTEGER,
        count            INTEGER
    );

    IF par_sort_by = 'C' THEN
        BEGIN
            INSERT INTO t$temp_payment_summary(pay_code, payment_means, transaction_type, paid_amount_sum, count)
            SELECT pay_code,
                   payment_means,
                   transaction_type,
                   SUM(paid_amount),
                   COUNT(*)
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= par_start_date
              AND transaction_datetime < par_end_date
              AND transaction_type = 'P'
              AND source_system = 'ADT'
              AND update_by LIKE par_user_id
              AND workstation_id LIKE par_term_id
            GROUP BY pay_code, payment_means, transaction_type
            UNION
            SELECT pay_code,
                   payment_means,
                   transaction_type,
                   SUM(paid_amount) * -1,
                   COUNT(*)
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= par_start_date
              AND transaction_datetime < par_end_date
              AND transaction_type = 'C'
              AND source_system = 'ADT'
              AND update_by LIKE par_user_id
              AND workstation_id LIKE par_term_id
            GROUP BY pay_code, payment_means, transaction_type
            ORDER BY pay_code, payment_means, transaction_type;
        END;
    ELSE
        INSERT INTO t$temp_payment_summary(payment_means, pay_code, transaction_type, paid_amount_sum, count)
        SELECT payment_means,
               pay_code,
               transaction_type,
               SUM(paid_amount),
               COUNT(*)
        FROM payment_detail
        WHERE hospital_code = par_hosp_code
          AND transaction_datetime >= par_start_date
          AND transaction_datetime < par_end_date
          AND transaction_type = 'P'
          AND source_system = 'ADT'
          AND update_by LIKE par_user_id
          AND workstation_id LIKE par_term_id
        GROUP BY payment_means, pay_code, transaction_type
        UNION
        SELECT payment_means,
               pay_code,
               transaction_type,
               SUM(paid_amount) * -1,
               COUNT(*)
        FROM payment_detail
        WHERE hospital_code = par_hosp_code
          AND transaction_datetime >= par_start_date
          AND transaction_datetime < par_end_date
          AND transaction_type = 'C'
          AND source_system = 'ADT'
          AND update_by LIKE par_user_id
          AND workstation_id LIKE par_term_id
        GROUP BY payment_means, pay_code, transaction_type
        ORDER BY payment_means, pay_code, transaction_type;
    END IF;

    IF par_sort_by = 'C' THEN
        OPEN p_refcur FOR
            SELECT pay_code, payment_means, transaction_type, paid_amount_sum, count
            FROM t$temp_payment_summary
            ORDER BY pay_code NULLS FIRST, payment_means NULLS FIRST, transaction_type NULLS FIRST;
    ELSE
        OPEN p_refcur FOR
            SELECT payment_means, pay_code, transaction_type, paid_amount_sum, count
            FROM t$temp_payment_summary
            ORDER BY payment_means NULLS FIRST, pay_code NULLS FIRST, transaction_type NULLS FIRST;
    END IF;
    pas_return_code := 0;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_payment_summary" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
