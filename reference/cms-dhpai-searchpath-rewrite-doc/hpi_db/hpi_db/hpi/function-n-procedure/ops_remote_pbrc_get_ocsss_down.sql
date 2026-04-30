CREATE OR REPLACE PROCEDURE ops_remote_pbrc_get_ocsss_down(INOUT pas_return_code int, INOUT par_hospital VARCHAR, IN par_get_type VARCHAR, IN par_case_no VARCHAR, INOUT par_appt_seq INTEGER DEFAULT -1, INOUT par_receipt_no INTEGER DEFAULT -1, INOUT par_original_paycode VARCHAR DEFAULT '', INOUT par_charging_amount NUMERIC DEFAULT -1, INOUT par_pay_amount NUMERIC DEFAULT -1, INOUT par_ocsss_recheck_time TIMESTAMP WITHOUT TIME ZONE DEFAULT '19000101', INOUT par_ocsss_recheck_result VARCHAR DEFAULT '', INOUT par_ocsss_recheck_paycode VARCHAR DEFAULT '', INOUT par_return_code INTEGER DEFAULT 0, INOUT par_return_message VARCHAR DEFAULT '')
AS 
$BODY$
/* --@ocsss_recheck_time	varchar(17) output, */
/* ---- init ----- */
BEGIN
    SELECT
        hospital_code
        INTO par_hospital
        FROM hospital;
    SELECT
        - 1, - 1, - 1, - 1
        INTO par_appt_seq, par_receipt_no, par_charging_amount, par_pay_amount;
    SELECT
        NULL, NULL, NULL, NULL
        INTO par_original_paycode, par_ocsss_recheck_time, par_ocsss_recheck_result, par_ocsss_recheck_paycode;
    SELECT
        - 1, NULL
        INTO par_return_code, par_return_message;
    /* ----------------------------------------------- */
    IF EXISTS (SELECT
        0
        FROM ocsss_temp_paycode_recheck
        /* ---- Key (case_no, hospital) */
        WHERE hospital = par_hospital AND case_no = par_case_no) THEN
        BEGIN
            SELECT
                original_paycode,
                CASE
                    WHEN ocsss_recheck_time IS NULL THEN transaction_datetime
                /* --else ocsss_recheck_time */
                /* ---then */
                /* --		convert(VARCHAR(8), transaction_datetime, 112) + */
                /* substring(convert(VARCHAR(8), transaction_datetime, 108), 1, 2) + */
                
                /* --		substring(convert(VARCHAR(8), transaction_datetime, 108), 4, 2) + */
                /* substring(convert(VARCHAR(8), transaction_datetime, 108), 7, 2) + */
                /* substring(convert(varchar(30),transaction_datetime, 109), 22, 3) */
                
                /* --- */
                    ELSE CONCAT(SUBSTRING(ocsss_recheck_time, 1, 8), ' ', SUBSTRING(ocsss_recheck_time, 9, 2), ':', SUBSTRING(ocsss_recheck_time, 11, 2), ':', SUBSTRING(ocsss_recheck_time, 13, 2), '.', SUBSTRING(ocsss_recheck_time, 15, 2))
                END, COALESCE(ocsss_recheck_result, ''), result_paycode
                INTO par_original_paycode, par_ocsss_recheck_time, par_ocsss_recheck_result, par_ocsss_recheck_paycode
                FROM ocsss_temp_paycode_recheck /* ---Unique Key (transaction_datetime, hospital, case_no) */
                WHERE hospital = par_hospital AND case_no = par_case_no
                ORDER BY transaction_datetime DESC NULLS FIRST limit 1;
            SELECT
                'OCSSS recheck record found'
                INTO par_return_message;
            SELECT
                0
                INTO par_return_code;
        END;
    ELSE
        BEGIN
            SELECT
                - 1
                INTO par_return_code;
            SELECT
                'No OCSSS recheck record found'
                INTO par_return_message;
        END;
    END IF;
    pas_return_code := par_return_code;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;