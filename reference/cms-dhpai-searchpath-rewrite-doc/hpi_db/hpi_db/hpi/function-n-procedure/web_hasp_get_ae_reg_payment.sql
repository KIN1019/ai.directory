-- DROP FUNCTION web_hasp_get_ae_reg_payment(varchar, timestamp, timestamp, varchar);

CREATE OR REPLACE FUNCTION web_hasp_get_ae_reg_payment(par_hosp_code character varying, par_from_dtm timestamp without time zone, par_to_dtm timestamp without time zone, par_input_pay_ind character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
p_refcur refcursor;
    var_case VARCHAR(12);
    var_pay_ind VARCHAR(1);
    var_receipt_no VARCHAR(12);
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_payment_amount INTEGER;
    var_payment_means VARCHAR(5);
    var_paid_amount INTEGER;
    var_no_charge_indicator VARCHAR(5);
    var_waiver_no VARCHAR(24);
    var_transaction_type VARCHAR(1);
    var_update_by VARCHAR(12);
    var_workstation_id VARCHAR(12);
    var_source_system VARCHAR(5);
    var_nep_add_key_1 VARCHAR(20);
    var_nep_add_key_2 VARCHAR(20);
    csr CURSOR FOR
SELECT
    case_no, pay_ind, receipt_no, transaction_datetime, payment_amount, payment_means, paid_amount, no_charge_indicator, waiver_no, update_by, workstation_id, source_system, nep_add_key_1, nep_add_key_2
FROM t$ae_reg_table;
sql$rowcount BIGINT;
begin
drop table IF EXISTS t$ae_reg_table;
CREATE TEMPORARY TABLE t$ae_reg_table
    (case_no VARCHAR(12),
        reg_dtm TIMESTAMP WITHOUT TIME ZONE,
        pay_code VARCHAR(3),
        pay_ind VARCHAR(1) DEFAULT NULL NULL,
        receipt_no VARCHAR(12) DEFAULT NULL NULL,
        transaction_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL NULL,
        payment_amount INTEGER DEFAULT NULL NULL,
        payment_means VARCHAR(5) DEFAULT NULL NULL,
        paid_amount INTEGER DEFAULT NULL NULL,
        no_charge_indicator VARCHAR(5) DEFAULT NULL NULL,
        waiver_no VARCHAR(24) DEFAULT NULL NULL,
        update_by VARCHAR(12) DEFAULT NULL NULL,
        workstation_id VARCHAR(12) DEFAULT NULL NULL,
        source_system VARCHAR(5) DEFAULT NULL NULL,
        nep_add_key_1 VARCHAR(20) DEFAULT NULL NULL,
        nep_add_key_2 VARCHAR(20) DEFAULT NULL NULL);
CREATE UNIQUE INDEX ae_reg_index ON t$ae_reg_table
    (case_no);
INSERT INTO t$ae_reg_table (case_no, reg_dtm, pay_code)
SELECT
    t.Case_no, Transaction_datetime, Pay_code
FROM Transaction_log AS t, ADT_Case AS c
WHERE Transaction_datetime >= par_from_dtm AND Transaction_datetime < 1 * INTERVAL '1 minute' + par_to_dtm::TIMESTAMP AND Transaction_type = '300' AND Cancel_flag IS NULL AND t.Case_no = c.Case_no AND t.Hospital_code = par_hosp_code AND c.Hospital_code = par_hosp_code;
OPEN csr;
FETCH csr INTO var_case, var_pay_ind, var_receipt_no, var_transaction_datetime, var_payment_amount, var_payment_means, var_paid_amount, var_no_charge_indicator, var_waiver_no, var_update_by, var_workstation_id, var_source_system, var_nep_add_key_1, var_nep_add_key_2;

WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
--         SELECT
--             transaction_type, receipt_no, transaction_datetime, payment_amount, payment_means, paid_amount, no_charge_indicator, waiver_no, update_by, workstation_id, source_system, nep_add_key_1, nep_add_key_2
--             INTO var_transaction_type, var_receipt_no, var_transaction_datetime, var_payment_amount, var_payment_means, var_paid_amount, var_no_charge_indicator, var_waiver_no, var_update_by, var_workstation_id, var_source_system, var_nep_add_key_1, var_nep_add_key_2
--             FROM (SELECT
--                 transaction_type, receipt_no, transaction_datetime, payment_amount, payment_means, paid_amount, no_charge_indicator, waiver_no, update_by, workstation_id, source_system, nep_add_key_1, nep_add_key_2, hospital_code, case_no
--                 FROM payment_detail) AS ungrouped_query
--             INNER JOIN (SELECT
--                 hospital_code, case_no, MAX(transaction_datetime) AS max_1
--                 FROM payment_detail
--                 WHERE hospital_code = par_hosp_code AND case_no = var_case
--                 GROUP BY hospital_code, case_no) AS grouped_query
--                 ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
--             WHERE transaction_datetime = max_1;
SELECT
    transaction_type, receipt_no, transaction_datetime, payment_amount, payment_means, paid_amount, no_charge_indicator, waiver_no, update_by, workstation_id, source_system, nep_add_key_1, nep_add_key_2
INTO var_transaction_type, var_receipt_no, var_transaction_datetime, var_payment_amount, var_payment_means, var_paid_amount, var_no_charge_indicator, var_waiver_no, var_update_by, var_workstation_id, var_source_system, var_nep_add_key_1, var_nep_add_key_2
FROM payment_detail AS pd
         INNER JOIN (SELECT
                         hospital_code, case_no, MAX(transaction_datetime) AS max_1
                     FROM payment_detail
                     WHERE hospital_code = par_hosp_code AND case_no = var_case
                     GROUP BY hospital_code, case_no) AS grouped_query
                    ON (pd.hospital_code = grouped_query.hospital_code OR (pd.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
WHERE transaction_datetime = max_1;
GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

IF sql$rowcount = 0 OR var_transaction_type IS NULL OR var_transaction_type = 'C' THEN
SELECT
    'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
INTO var_pay_ind, var_transaction_type, var_receipt_no, var_transaction_datetime, var_payment_amount, var_payment_means, var_paid_amount, var_no_charge_indicator, var_waiver_no, var_update_by, var_workstation_id, var_source_system, var_nep_add_key_1, var_nep_add_key_2;
ELSE
SELECT
    'Y'
INTO var_pay_ind;
END IF;

        IF par_input_pay_ind = var_pay_ind OR par_input_pay_ind = '%' THEN
UPDATE t$ae_reg_table
SET pay_ind = var_pay_ind, receipt_no = var_receipt_no, transaction_datetime = var_transaction_datetime, payment_amount = var_payment_amount, payment_means = var_payment_means, paid_amount = var_paid_amount, no_charge_indicator = var_no_charge_indicator, waiver_no = var_waiver_no, update_by = var_update_by, workstation_id = var_workstation_id, source_system = var_source_system, nep_add_key_1 = var_nep_add_key_1, nep_add_key_2 = var_nep_add_key_2
WHERE CURRENT OF csr;
END IF;
FETCH csr INTO var_case, var_pay_ind, var_receipt_no, var_transaction_datetime, var_payment_amount, var_payment_means, var_paid_amount, var_no_charge_indicator, var_waiver_no, var_update_by, var_workstation_id, var_source_system, var_nep_add_key_1, var_nep_add_key_2;
END LOOP;
CLOSE csr;
/* Adaptive Server has expanded all '*' elements in the following statement */
OPEN p_refcur FOR
SELECT
    t$ae_reg_table.case_no, t$ae_reg_table.reg_dtm, t$ae_reg_table.pay_code, t$ae_reg_table.pay_ind, t$ae_reg_table.receipt_no, t$ae_reg_table.transaction_datetime, t$ae_reg_table.payment_amount, t$ae_reg_table.payment_means, t$ae_reg_table.paid_amount, t$ae_reg_table.no_charge_indicator, t$ae_reg_table.waiver_no, t$ae_reg_table.update_by, t$ae_reg_table.workstation_id, t$ae_reg_table.source_system, t$ae_reg_table.nep_add_key_1, t$ae_reg_table.nep_add_key_2
FROM t$ae_reg_table
WHERE pay_ind LIKE par_input_pay_ind;
/*

DROP TABLE IF EXISTS t$ae_reg_table;
*/
/*

Temporary table must be removed before end of the function.
*/
RETURN NEXT p_refcur;
END;
$function$
;

;ALTER FUNCTION "web_hasp_get_ae_reg_payment" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
