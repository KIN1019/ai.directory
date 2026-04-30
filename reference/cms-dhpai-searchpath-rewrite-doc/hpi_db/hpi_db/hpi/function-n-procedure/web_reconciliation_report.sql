CREATE OR REPLACE PROCEDURE web_reconciliation_report(INOUT pas_return_code integer,
                                                      IN par_hosp_code VARCHAR,
                                                      IN par_report_type VARCHAR,
                                                      IN par_sort_order VARCHAR,
                                                      IN par_report_date TIMESTAMP WITHOUT TIME ZONE,
                                                      IN par_select_id VARCHAR DEFAULT '%',
                                                      INOUT p_refcur refcursor DEFAULT NULL)
    LANGUAGE plpgsql
AS
$procedure$
DECLARE
    result_date_value TIMESTAMP WITHOUT TIME ZONE;
    var_start_date    TIMESTAMP WITHOUT TIME ZONE;
    var_end_date      TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount      BIGINT;
BEGIN
    IF par_report_type IN ('T', 'R') THEN
        BEGIN
            SELECT par_report_date
            INTO var_end_date;
            SELECT MAX(transaction_datetime)
            INTO var_start_date
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime < var_end_date
              AND transaction_type IN ('E', 'R');
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF NOT FOUND THEN
                var_start_date := NULL;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT to_char(var_end_date, 'YYYYMMDD') INTO var_end_date;

            SELECT transaction_datetime
            INTO result_date_value
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= par_report_date
              AND transaction_datetime < INTERVAL '1 day' + par_report_date
              AND transaction_type = 'E';
            IF FOUND THEN
                var_end_date := result_date_value;
            END IF;

            SELECT MAX(transaction_datetime)
            INTO var_start_date
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime < var_end_date
              AND transaction_type = 'E';
        END;
    END IF;

    IF var_start_date IS NULL THEN
        SELECT MIN(transaction_datetime)
        -- INTO var_start_date
        INTO result_date_value
        FROM payment_detail
        WHERE hospital_code = par_hosp_code;
        IF FOUND THEN
            var_start_date := result_date_value;
        END IF;
    END IF;

    DROP TABLE IF EXISTS t$temp_reconciliation_report;
    CREATE TEMPORARY TABLE t$temp_reconciliation_report
    (
        hospital_code        VARCHAR(6),
        case_no              VARCHAR(24),
        admission_dtm        TIMESTAMP,
        transaction_type     VARCHAR(2),
        transaction_datetime TIMESTAMP,
        payment_means        VARCHAR(10),
        payment_amount       INTEGER,
        no_charge_indicator  VARCHAR(10),
        waiver_no            VARCHAR(48),
        paid_amount          INTEGER,
        update_by            VARCHAR(24),
        workstation_id       VARCHAR(24),
        pay_code             VARCHAR(6),
        nep_add_key_1        VARCHAR(20),
        nep_add_key_2        VARCHAR(20)
    );

    IF par_sort_order = 'U' THEN
        BEGIN
            INSERT INTO t$temp_reconciliation_report(hospital_code, case_no, admission_dtm, transaction_type,
                                                     transaction_datetime, payment_means, payment_amount,
                                                     no_charge_indicator, waiver_no,
                                                     paid_amount, update_by, workstation_id, pay_code, nep_add_key_1,
                                                     nep_add_key_2)
            SELECT hospital_code,
                   case_no,
                   admission_dtm,
                   transaction_type,
                   transaction_datetime,
                   payment_means,
                   payment_amount,
                   no_charge_indicator,
                   waiver_no,
                   paid_amount,
                   update_by,
                   workstation_id,
                   pay_code,
                   nep_add_key_1,
                   nep_add_key_2
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= var_start_date
              AND transaction_datetime < var_end_date
              AND transaction_type = 'P'
              AND source_system = 'ADT'
              AND update_by LIKE par_select_id
            UNION
            SELECT hospital_code,
                   case_no,
                   admission_dtm,
                   transaction_type,
                   transaction_datetime,
                   payment_means,
                   payment_amount * - 1,
                   no_charge_indicator,
                   waiver_no,
                   paid_amount * - 1,
                   update_by,
                   workstation_id,
                   pay_code,
                   nep_add_key_1,
                   nep_add_key_2
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= var_start_date
              AND transaction_datetime < var_end_date
              AND transaction_type = 'C'
              AND source_system = 'ADT'
              AND update_by LIKE par_select_id
            ORDER BY update_by NULLS FIRST, transaction_datetime NULLS FIRST;
        END;
    ELSE
        BEGIN
            INSERT INTO t$temp_reconciliation_report(hospital_code, case_no, admission_dtm, transaction_type,
                                                     transaction_datetime, payment_means, payment_amount,
                                                     no_charge_indicator, waiver_no,
                                                     paid_amount, update_by, workstation_id, pay_code, nep_add_key_1,
                                                     nep_add_key_2)
            SELECT hospital_code,
                   case_no,
                   admission_dtm,
                   transaction_type,
                   transaction_datetime,
                   payment_means,
                   payment_amount,
                   no_charge_indicator,
                   waiver_no,
                   paid_amount,
                   update_by,
                   workstation_id,
                   pay_code,
                   nep_add_key_1,
                   nep_add_key_2
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= var_start_date
              AND transaction_datetime < var_end_date
              AND transaction_type = 'P'
              AND source_system = 'ADT'
              AND workstation_id LIKE par_select_id
            UNION
            SELECT hospital_code,
                   case_no,
                   admission_dtm,
                   transaction_type,
                   transaction_datetime,
                   payment_means,
                   payment_amount * - 1,
                   no_charge_indicator,
                   waiver_no,
                   paid_amount * - 1,
                   update_by,
                   workstation_id,
                   pay_code,
                   nep_add_key_1,
                   nep_add_key_2
            FROM payment_detail
            WHERE hospital_code = par_hosp_code
              AND transaction_datetime >= var_start_date
              AND transaction_datetime < var_end_date
              AND transaction_type = 'C'
              AND source_system = 'ADT'
              AND workstation_id LIKE par_select_id
            ORDER BY workstation_id NULLS FIRST, transaction_datetime NULLS FIRST;
        END;
    END IF;

    IF par_sort_order = 'U' THEN
        open p_refcur for
            select *
            from t$temp_reconciliation_report
            ORDER BY update_by NULLS FIRST, transaction_datetime NULLS FIRST;
    ELSE
        open p_refcur for
            select *
            from t$temp_reconciliation_report
            ORDER BY workstation_id NULLS FIRST, transaction_datetime NULLS FIRST;
    END IF;

    pas_return_code := 0;
END;
$procedure$;


;ALTER PROCEDURE "web_reconciliation_report" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
