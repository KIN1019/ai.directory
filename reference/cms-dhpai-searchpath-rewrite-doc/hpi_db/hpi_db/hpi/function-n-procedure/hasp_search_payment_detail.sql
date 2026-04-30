-- DROP PROCEDURE hpi.hasp_search_payment_detail(inout int4, in varchar, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout timestamp, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout timestamp, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_search_payment_detail(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_case_no character varying, INOUT par_hkid character varying, INOUT par_patient_name character varying, INOUT par_chi_name character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob_flag character varying, INOUT par_pay_code character varying, INOUT par_adm_dtm timestamp without time zone, INOUT par_payment_amount integer, INOUT par_payment_means character varying, INOUT par_waiver_no character varying, INOUT par_waiver_type character varying, INOUT par_waiver_issue_party character varying, INOUT par_waiver_eff_date timestamp without time zone, INOUT par_waiver_exp_date timestamp without time zone, INOUT par_no_charge_indicator character varying, INOUT par_paid_amount integer, INOUT par_transaction_type character varying, INOUT par_remark character varying, INOUT par_receipt_no character varying, INOUT par_card_id character varying, INOUT par_octopus_system_dtm timestamp without time zone, INOUT par_device_id character varying, INOUT par_schi_name character varying DEFAULT 'N'::bpchar, INOUT par_nep_search_key character varying DEFAULT NULL::bpchar, INOUT par_nep_add_key_1 character varying DEFAULT NULL::bpchar, INOUT par_nep_add_key_2 character varying DEFAULT NULL::bpchar, INOUT par_new_waiver_type character varying DEFAULT NULL::bpchar, INOUT par_upd_sys character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
/* 2006-08-30 Added by HK Fong SMR20015696 */ /* 20070910 SL */
DECLARE
    var_cnt                  INTEGER;
    var_error                INTEGER;
    var_ccc_1                VARCHAR(10);
    var_ccc_2                VARCHAR(10);
    var_ccc_3                VARCHAR(10);
    var_ccc_4                VARCHAR(10);
    var_ccc_5                VARCHAR(10);
    var_ccc_6                VARCHAR(10);
    var_tmp_phonetic         VARCHAR(96);
    var_temp_pay_code        CHAR(3);
    var_temp_adm_dtm         TIMESTAMP WITHOUT TIME ZONE;
    var_source_system        CHAR(08);
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_is_schi_name         VARCHAR(2);
    var_return_code          int;
BEGIN /* 2006-09-19 Added by HK Fong SMR20015696 */
    /* init */
    SELECT 0
    INTO var_cnt;
    SELECT 0
    INTO var_error;
    SELECT NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL
    INTO par_hkid, par_patient_name, par_chi_name, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, par_sex, par_dob, par_exact_dob_flag, par_pay_code, par_adm_dtm, par_payment_amount, par_payment_means, par_waiver_no, par_waiver_type, par_waiver_issue_party, par_waiver_eff_date, par_waiver_exp_date, par_no_charge_indicator, par_paid_amount, par_transaction_type, par_remark, var_tmp_phonetic, var_temp_pay_code, var_temp_adm_dtm, par_receipt_no, var_source_system, par_nep_search_key, par_nep_add_key_1, par_nep_add_key_2, par_new_waiver_type, par_upd_sys;
    /* Get PMI & case's Paycode, adm_dtm info */
    SELECT p.HKID,
           p.Name,
           p.CCC_1,
           p.CCC_2,
           p.CCC_3,
           p.CCC_4,
           p.CCC_5,
           p.CCC_6,
           p.Sex,
           p.DOB,
           p.Exact_DOB_flag,
           c.Pay_code,
           c.Admission_datetime
    INTO par_hkid, par_patient_name, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, par_sex, par_dob, par_exact_dob_flag, par_pay_code, par_adm_dtm
    FROM Case_view AS c,
         PMI AS p
    WHERE c.Case_no = par_case_no
      AND c.HKID = p.HKID;
    /* Get chinese name from ccc_unicode table */
    CALL cpi_get_phonetic_chin_name /* ---HPI ver. */
    /* ---exec	cpi..cpi_get_phonetic_chin_name */(var_return_code, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6,
                                                     var_tmp_phonetic, par_chi_name);
    /* 2006-09-19 Added by HK Fong SMR20015696 - Start */
    IF COALESCE(par_chi_name, '') <> '' THEN
        BEGIN
            CALL hasp_check_schi_name(pas_return_code=>pas_return_code,par_ccc1 => var_ccc_1,
                                                   par_ccc2 => var_ccc_2,
                                                   par_ccc3 => var_ccc_3,
                                                   par_ccc4 => var_ccc_4,
                                                   par_ccc5 => var_ccc_5,
                                                   par_ccc6 => var_ccc_6,
                                                   par_is_schi_name => var_is_schi_name);

            IF var_is_schi_name = 'Y' THEN
                SELECT par_chi_name
                INTO par_schi_name;
            ELSE
                SELECT ''
                INTO par_schi_name;
            END IF;
        END;
    ELSE
        SELECT ''
        INTO par_schi_name;
    END IF;
    /* 2006-09-19 Added by HK Fong SMR20015696 - End */
    /* Get AE payment info */
    SELECT COUNT(*)
    INTO var_cnt
    FROM payment_detail
    WHERE case_no = par_case_no
      AND hospital_code = par_hosp_code;

    IF var_cnt = 0 THEN /* No record found in payment_detail, return PMI ,Case_view paycode & adm_dtm info ONLY, AE Payment detail = NULL */
        BEGIN
            pas_return_code := - 1;
            RETURN;
        END;
    ELSE
        BEGIN
            /* AE payment record found */
            SELECT pay_code,
                   admission_dtm,
                   payment_amount,
                   payment_means,
                   waiver_no,
                   waiver_type,
                   waiver_issue_party,
                   waiver_eff_date,
                   waiver_exp_date,
                   no_charge_indicator,
                   paid_amount,
                   transaction_type,
                   remark,
                   receipt_no,
                   source_system,
                   transaction_datetime,
                   nep_search_key,
                   nep_add_key_1,
                   nep_add_key_2,
                   new_waiver_type,
                   upd_sys
            INTO var_temp_pay_code, var_temp_adm_dtm, par_payment_amount, par_payment_means, par_waiver_no, par_waiver_type, par_waiver_issue_party, par_waiver_eff_date, par_waiver_exp_date, par_no_charge_indicator, par_paid_amount, par_transaction_type, par_remark, par_receipt_no, var_source_system, var_transaction_datetime, par_nep_search_key, par_nep_add_key_1, par_nep_add_key_2, par_new_waiver_type, par_upd_sys
            FROM payment_detail
            WHERE case_no = par_case_no
              AND hospital_code = par_hosp_code
              AND
                transaction_datetime = /* ----Handle for Multi-records of same case */ (SELECT MAX(transaction_datetime)
                                                                                        FROM payment_detail
                                                                                        WHERE case_no = par_case_no
                                                                                          AND hospital_code = par_hosp_code);
            /* Get Octopus Card ID if Payment Means is OC */
            IF par_payment_means = 'OC' THEN
                SELECT card_no,
                       term_id,
                       transaction_datetime
                INTO par_card_id, par_device_id, par_octopus_system_dtm
                FROM octopus_transaction
                WHERE hospital_code = par_hosp_code
                  AND case_no = par_case_no
                  AND transaction_datetime = (SELECT MAX(transaction_datetime)
                                              FROM octopus_transaction
                                              WHERE hospital_code = par_hosp_code
                                                AND case_no = par_case_no);
            END IF;
            /* if Payment cancelled, Return PMI ,Case_view's paycode & adm_dtm info ONLY, AE Payment detail = NULL */
            IF par_transaction_type = 'C' THEN
                BEGIN
                    SELECT NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           NULL
                    INTO par_payment_amount, par_payment_means, par_waiver_no, par_waiver_type, par_waiver_issue_party, par_waiver_eff_date, par_waiver_exp_date, par_no_charge_indicator, par_paid_amount, par_remark, par_receipt_no;
                    pas_return_code := - 2;
                    RETURN;
                END;
            ELSE
                /* transaction_type !=cancelled */
                BEGIN
                    /* transaction_type != Cancelled => pay_code/adm_dtm retrieved from cpi_payment_detail */
                    SELECT var_temp_pay_code,
                           var_temp_adm_dtm
                    INTO par_pay_code, par_adm_dtm;

                    IF var_source_system = 'PBRC' THEN
                        pas_return_code := 1;
                        RETURN;
                    ELSE
                        pas_return_code := 0;
                        RETURN;
                    END IF /* normal return */;
                END;
            END IF;
        END;
    END IF /* end of if @cnt=0 */;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_search_payment_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";