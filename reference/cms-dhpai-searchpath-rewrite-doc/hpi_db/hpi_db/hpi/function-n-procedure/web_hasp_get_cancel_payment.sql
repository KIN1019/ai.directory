-- DROP PROCEDURE hpi.web_hasp_get_cancel_payment(inout int4, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_get_cancel_payment(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_report_type character varying, IN par_start_date timestamp without time zone, IN par_end_date timestamp without time zone, IN par_sort_by character varying, IN par_select_id character varying DEFAULT '%'::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_report_date TIMESTAMP;
BEGIN
    IF par_report_type = 'E' THEN
        SELECT TO_DATE(TO_CHAR(par_end_date, 'YYYYMMDD'), 'YYYYMMDD')
        INTO var_report_date;

        SELECT MAX(transaction_datetime)
        INTO par_end_date
        FROM payment_detail
        WHERE hospital_code = par_hosp_code
          AND transaction_datetime >= par_end_date
          AND transaction_datetime < par_end_date + INTERVAL '1 day'
          AND transaction_type = 'E';

        SELECT TO_DATE(TO_CHAR(par_start_date, 'YYYYMMDD'), 'YYYYMMDD')
        INTO var_report_date;

        SELECT MAX(transaction_datetime)
        INTO par_start_date
        FROM payment_detail
        WHERE hospital_code = par_hosp_code
          AND transaction_datetime < var_report_date
          AND transaction_type = 'E';

        IF par_start_date IS NULL THEN
            SELECT MIN(transaction_datetime)
            INTO par_start_date
            FROM payment_detail
            WHERE hospital_code = par_hosp_code;
        END IF;
    ELSIF par_report_type IN ('T', 'R') THEN
        var_report_date := par_start_date;

        SELECT MAX(transaction_datetime)
        INTO par_start_date
        FROM payment_detail
        WHERE hospital_code = par_hosp_code
          AND transaction_datetime < par_start_date
          AND transaction_type IN ('R', 'E');

        IF par_start_date IS NULL THEN
            SELECT MIN(transaction_datetime)
            INTO par_start_date
            FROM payment_detail
            WHERE hospital_code = par_hosp_code;
        END IF;
    END IF;

    DROP TABLE IF EXISTS t$temp_cancel_payment;
    CREATE TEMPORARY TABLE t$temp_cancel_payment
    (
        transaction_datetime TIMESTAMP WITHOUT TIME ZONE,
        case_no              VARCHAR(24),
        admission_dtm        TIMESTAMP WITHOUT TIME ZONE,
        pay_code             VARCHAR(6),
        payment_means        VARCHAR(10),
        waiver_no            VARCHAR(48),
        no_charge_indicator  VARCHAR(10),
        payment_amount       int4,
        paid_amount          int4,
        update_by            VARCHAR(24),
        workstation_id       VARCHAR(24),
        remark               VARCHAR(96),
        nep_add_key_1        VARCHAR(40),
        nep_add_key_2        VARCHAR(40)
    );

    IF par_sort_by = 'U' THEN
        INSERT INTO t$temp_cancel_payment(transaction_datetime, case_no, admission_dtm, pay_code, payment_means,
                                          waiver_no, no_charge_indicator, payment_amount, paid_amount, update_by,
                                          workstation_id, remark, nep_add_key_1, nep_add_key_2)
        SELECT pd.transaction_datetime,
               pd.case_no,
               pd.admission_dtm,
               pd.pay_code,
               pd.payment_means,
               pd.waiver_no,
               pd.no_charge_indicator,
               pd.payment_amount,
               pd.paid_amount,
               pd.update_by,
               pd.workstation_id,
               pd.remark,
               pd.nep_add_key_1,
               pd.nep_add_key_2
        FROM payment_detail pd
        WHERE pd.hospital_code = par_hosp_code
          AND pd.transaction_datetime >= par_start_date
          AND pd.transaction_datetime < par_end_date
          AND pd.transaction_type = 'C'
          AND pd.source_system = 'ADT'
          AND pd.update_by LIKE par_select_id
        ORDER BY pd.update_by, pd.transaction_datetime;
    ELSE
        INSERT INTO t$temp_cancel_payment(transaction_datetime, case_no, admission_dtm, pay_code, payment_means,
                                          waiver_no, no_charge_indicator, payment_amount, paid_amount, update_by,
                                          workstation_id, remark, nep_add_key_1, nep_add_key_2)
        SELECT pd.transaction_datetime,
               pd.case_no,
               pd.admission_dtm,
               pd.pay_code,
               pd.payment_means,
               pd.waiver_no,
               pd.no_charge_indicator,
               pd.payment_amount,
               pd.paid_amount,
               pd.update_by,
               pd.workstation_id,
               pd.remark,
               pd.nep_add_key_1,
               pd.nep_add_key_2
        FROM payment_detail pd
        WHERE pd.hospital_code = par_hosp_code
          AND pd.transaction_datetime >= par_start_date
          AND pd.transaction_datetime < par_end_date
          AND pd.transaction_type = 'C'
          AND pd.source_system = 'ADT'
          AND pd.workstation_id LIKE par_select_id
        ORDER BY pd.workstation_id, pd.transaction_datetime;
    END IF;

    IF par_sort_by = 'U' THEN
        OPEN p_refcur FOR
            SELECT *
            FROM t$temp_cancel_payment
            ORDER BY update_by NULLS FIRST, transaction_datetime NULLS FIRST;
    ELSE
        OPEN p_refcur FOR
            SELECT *
            FROM t$temp_cancel_payment
            ORDER BY workstation_id NULLS FIRST, transaction_datetime NULLS FIRST;
    END IF;

    pas_return_code := 0;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_get_cancel_payment" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
