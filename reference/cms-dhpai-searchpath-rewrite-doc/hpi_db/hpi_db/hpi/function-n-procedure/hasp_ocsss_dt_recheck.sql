-- DROP PROCEDURE hpi.hasp_ocsss_dt_recheck(timestamp, timestamp, varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_ocsss_dt_recheck(IN par_input_start_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_input_end_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_input_case_no character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_start_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_end_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_tran_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tran_type VARCHAR(6);
    var_case_no VARCHAR(24);
    var_doc_flag VARCHAR(2);
    var_pky VARCHAR(16);
    var_claimed_hkid VARCHAR(24);
    var_claimed_hkid_symbol VARCHAR(2);
    var_cur_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_ocsss_request_dtm VARCHAR(17);
    var_ocsss_result VARCHAR(2);
    var_original_pay_code VARCHAR(6);
    var_original_hkid VARCHAR(24);
    /* --- For PsudoID UID-flow */
    var_print_message VARCHAR(255);
    var_check_pay_code VARCHAR(6);
    /* --- UID/EP1/NE9 only for TEP/TNE */
    var_case_type VARCHAR(2);
    var_upd_txn_type VARCHAR(6); /* ---'121'/'341' only */
    var_org_case_pay_code VARCHAR(6);
    var_hosp_code VARCHAR(6);
    var_txn_type INTEGER;
    /* -----Input parm for OCSSS chk ---- */
    /* ---- 10 / 30 only ... */
    var_in_pay_code VARCHAR(6);
    var_in_doc_type VARCHAR(4);
    var_in_hkid VARCHAR(24);
    var_in_hkic_symbol VARCHAR(2);
    var_in_ref_hkid VARCHAR(24);
    var_user_id VARCHAR(24);
    var_term_id VARCHAR(30);
    /* ----output parm for Front-end handling  ----- */
    var_out_pay_code VARCHAR(6);
    var_out_msg VARCHAR(255);
    var_out_msg_popup VARCHAR(2);
    var_out_rtn_code INTEGER;
    var_ad_hoc_chk_flag VARCHAR(2);
    var_return_status INTEGER;
    var_ae_admission_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_ae_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ae_receipt_no VARCHAR(24);
    var_ae_pay_code VARCHAR(6);
    var_ae_payment_amount INTEGER;
    var_ae_no_charge_indicator VARCHAR(10);
    var_ae_payment_means VARCHAR(10);
    var_ae_waiver_no VARCHAR(40);
    var_ae_waiver_type VARCHAR(2);
    var_ae_waiver_issue_party VARCHAR(2);
    var_ae_waiver_eff_date TIMESTAMP WITHOUT TIME ZONE;
    var_ae_waiver_exp_date TIMESTAMP WITHOUT TIME ZONE;
    var_ae_paid_amount INTEGER;
    var_ae_update_by VARCHAR(24);
    var_ae_workstation_id VARCHAR(24);
    var_ae_source_system VARCHAR(16);
    var_ae_err_msg VARCHAR(80);
    var_ae_new_waiver_type VARCHAR(4);
    var_ae_upd_sys VARCHAR(20);
    tran_csr CURSOR FOR
    SELECT
        tx.Transaction_datetime, tx.Transaction_type, tx.Case_no, ca.patient_type, ca.document_flag, ca.patient_key
        FROM Transaction_log AS tx, cpi_case AS ca
        /* --where  Transaction_datetime >= @start_datetime---- CPI ---- */
        WHERE tx.Hospital_code = var_hosp_code AND /* ---HPI -- */ tx.Transaction_datetime >= var_start_datetime AND tx.Transaction_datetime <= var_end_datetime AND tx.Transaction_type IN ('100', '300') AND /* ---Only for AE/HN */ tx.Cancel_flag IS NULL AND /* ----Ignore the cancelled case */ tx.Case_no = ca.case_no AND ca.patient_type IN ('TEP', 'TNE') AND ca.status_code != 'CC' AND
        /* --- Active Case Only */
        tx.Case_no LIKE par_input_case_no;
    var_return_code int;
BEGIN
    /* ----------------------------------------------------- */
    /* --------for exec cpi_search_payment_detail----------- */
    /* --------------------------------------------------------------------- */
    IF par_input_case_no IS NOT NULL OR par_input_start_dtm IS NOT NULL OR par_input_end_dtm IS NOT NULL THEN
        SELECT
            'Y'
            INTO var_ad_hoc_chk_flag;
    ELSE
        SELECT
            'N'
            INTO var_ad_hoc_chk_flag;
    END IF;
    /* --------------------------------------------------------------------- */
    /* --init value-- */
    SELECT
        Hospital_code
        INTO var_hosp_code
        FROM Hospital;
    SELECT
        'PAS_RECHK'
        INTO var_user_id; /* --'RECHECK'		---Same userid as OPAS rechk job-- */
    SELECT
        'IPAS_DT_RCHK'
        INTO var_term_id;
    SELECT
        timestamp_convert(localtimestamp)
        INTO var_end_datetime;

    IF par_input_case_no IS NULL THEN
        SELECT
            '%'
            INTO par_input_case_no;
    END IF;

    IF (par_input_start_dtm IS NOT NULL AND par_input_end_dtm IS NOT NULL) THEN
        BEGIN
            SELECT
                par_input_start_dtm
                INTO var_start_datetime;
            SELECT
                par_input_end_dtm
                INTO var_end_datetime;
        END;
    ELSE
        BEGIN
            IF EXISTS (SELECT
                0
                FROM ocsss_temp_paycode_check_log
                WHERE hospital = var_hosp_code) THEN
                BEGIN
                    SELECT
                        (SELECT
                            MAX(COALESCE(end_datetime, start_datetime))
                            FROM ocsss_temp_paycode_check_log)
                        INTO var_start_datetime;
                END;
            ELSE
                BEGIN
                    SELECT
                        to_char(var_end_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                        INTO var_start_datetime;
                    /* ---select @start_datetime = dateadd(mi, -15, @end_datetime) */
                END;
            END IF;
        END;
    END IF;
    /* ---------------------------------------------------- */
    SELECT
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        INTO var_tran_dtm, var_tran_type, var_case_no, var_claimed_hkid, var_claimed_hkid_symbol, var_ocsss_result, var_ocsss_request_dtm, var_original_pay_code, var_original_hkid, var_upd_txn_type, var_org_case_pay_code;
    SELECT
        NULL, NULL, NULL, NULL, NULL, NULL, NULL
        INTO var_doc_flag, var_in_pay_code, var_in_doc_type, var_in_hkid, var_in_hkic_symbol, var_in_ref_hkid, var_pky;
    OPEN tran_csr;
    FETCH tran_csr INTO var_tran_dtm, var_tran_type, var_case_no, var_org_case_pay_code, var_doc_flag, var_pky;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        /* ---20131205 -- */
        IF var_org_case_pay_code IN ('TEP', 'TNE') THEN
            BEGIN
                /* --print %1!%2!%3!%4!,@hosp_code,@tran_dtm,@tran_type,@case_no */
                IF var_tran_type = '100' THEN
                    BEGIN
                        SELECT
                            10
                            INTO var_txn_type;
                        SELECT
                            'I'
                            INTO var_case_type;
                        SELECT
                            '121'
                            INTO var_upd_txn_type
                        /* ---- update Admission */
                        ;
                    END;
                ELSE
                    IF var_tran_type = '300' THEN
                        BEGIN
                            SELECT
                                30
                                INTO var_txn_type;
                            SELECT
                                'A'
                                INTO var_case_type;
                            SELECT
                                '341'
                                INTO var_upd_txn_type
                            /* ---- update A&E */
                            ;
                        END;
                    END IF;
                END IF;
                SELECT
                    var_org_case_pay_code
                    INTO var_in_pay_code;
                SELECT
                    var_org_case_pay_code
                    INTO var_original_pay_code;
                /* --------------------------------------------------------- */
                /* ----- Found the TEP/TNE for the Active AE/HN cases ---- */
                /* How to check TEP genereted by UID flow ? -- */
                
                /* --------------------------------------------------------- */
                
                /* --if @@rowcount =1 AND @in_pay_code in ('TEP','TNE') */
                
                /* --BEGIN */
                SELECT
                    document_type
                    INTO var_in_doc_type
                    FROM document_type
                    WHERE document_code = var_doc_flag;
                /* -------------------------------- */
                /* --A) Pseudo-ID (UID-flow) with TEP -- */
                /* -------------------------------- */
                IF var_in_doc_type = 'NC' THEN
                    BEGIN
                        SELECT
                            hkid,
                            /* ----- UID Case's Pseudo-ID */
                            other_doc_no
                            INTO var_original_hkid, var_claimed_hkid
                            /* ----- Claimed HKID = other_doc_no for UID patient */
                            
                            /* ---from cpi..cpi_patient  ---CPI --- */
                            FROM cpi_patient /* ---HPI--- */
                            WHERE patient_key = var_pky;
                        SELECT
                            hkic_symbol
                            INTO var_claimed_hkid_symbol
                            /* ----- Claimed HKID SYmbol */
                            
                            /* ---from cpi..cpi_patient  ---CPI--- */
                            FROM cpi_patient /* ---HPI--- */
                            WHERE hkid = var_claimed_hkid; /* ---Claimed HKID */
                        /* ------------------------------------------------- */
                        /* ----Input parm to recheck UID downtime record ---- */
                        /* ------------------------------------------------- */
                        SELECT
                            'UID', 'NC', var_claimed_hkid, var_claimed_hkid_symbol, var_claimed_hkid
                            INTO var_in_pay_code, var_in_doc_type, var_in_hkid, var_in_hkic_symbol, var_in_ref_hkid;
                    END;
                ELSE
                    /* -------------------------------- */
                    /* --B) HKID with TEP/TNE -- */
                    /* -------------------------------- */
                    BEGIN
                        SELECT
                            hkid, hkic_symbol
                            INTO var_in_hkid, var_in_hkic_symbol
                            /* ---@in_ref_hkid = other_doc_no */
                            /* --from cpi..cpi_patient  ---CPI--- */
                            FROM cpi_patient /* ---HPI--- */
                            WHERE patient_key = var_pky;
                        SELECT
                            var_in_hkid
                            INTO var_original_hkid;
                    END;
                END IF;
                /* ------------------------------------------------- */
                /* --- Call hasp_pbrc_chk_ocsss to recheck  --- */
                
                /* ------------------------------------------------- */
                SELECT
                    'Problem in PayCode - '
                    INTO var_print_message;
                SELECT
                    CONCAT(var_print_message, var_hosp_code, ', ', RTRIM(var_original_hkid), ', ', LTRIM(RTRIM(var_case_no)), ', adm_dtm[', to_char(var_tran_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '] ', var_original_pay_code, ', ', var_in_doc_type, ', ', var_in_hkic_symbol, ', ', LTRIM(RTRIM(COALESCE(var_in_ref_hkid, ''))), ',OCSSS_RESULT[', COALESCE(var_ocsss_result, ''), '], ', 'OUT_PAY_CODE[', COALESCE(var_out_pay_code, ''), ']')
                    INTO var_print_message;
                RAISE NOTICE '%', var_print_message;
                /* ------------------------------------------------ */
                /* TEP: pass EP1 for OCSSS check, if EP1 return call cpi_update_adm_registration to udpate AE/HN paycode - NOTE: system as 'PBRC' for special logic */
                /* TNE: pass NE9 for OCSSS check, if NE9 return call cpi_update_adm_registration to udpate AE/HN paycode - NOTE: system as 'PBRC' for special logic */
                /* --- if EP1 check with NE9 OR NE9 check with EP1, NO thing change for the case -- */
                
                /* ------------------------------------------------ */
                IF var_in_pay_code = 'TEP' THEN
                    SELECT
                        'EP1'
                        INTO var_check_pay_code;
                END IF;

                IF var_in_pay_code = 'TNE' THEN
                    SELECT
                        'NE9'
                        INTO var_check_pay_code;
                END IF;

                IF var_in_pay_code = 'UID' THEN
                    SELECT
                        'UID'
                        INTO var_check_pay_code;
                END IF;
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO var_cur_dtm;
                CALL hasp_pbrc_chk_ocsss(var_return_code, var_hosp_code, var_txn_type, var_check_pay_code, var_in_doc_type, var_in_hkid, var_in_hkic_symbol, var_in_ref_hkid, var_user_id, var_term_id, var_out_pay_code, var_out_msg, var_out_msg_popup, var_out_rtn_code);
                /* ------------------------------------------------- */
                /* --- Got the OCSSS checking result to insert recheck log   --- */
                
                /* ------------------------------------------------- */
                SELECT
                    ocsss_result, ocsss_request_datetime
                    INTO var_ocsss_result, var_ocsss_request_dtm
                    FROM ocsss_performance_log
                    /* Unique Key : start_call_datetime, hkid, update_by */
                    WHERE start_call_datetime >= var_cur_dtm AND hkid = var_in_hkid AND update_by = var_user_id; /* ---select @user_id='PAS-RECHK' */
                /* ------------------------------------------------- */
                /* --- insert recheck log   --- */
                
                /* ------------------------------------------------- */
                INSERT INTO ocsss_temp_paycode_recheck (transaction_datetime, hospital, case_no, appt_seq, receipt_no, original_paycode, charging_amount, pay_amount, hkid, hkic_symbol, last_document_type, ocsss_recheck_time, ocsss_recheck_result, pas_recheck_return_code, pas_recheck_return_msg, result_paycode, result_generic_status, result_pay_amount)
                VALUES (var_cur_dtm, var_hosp_code, var_case_no, -1, -1, var_original_pay_code, -1, -1, var_original_hkid, var_in_hkic_symbol, var_in_doc_type, /* ---use PseudoID for the Log and claimedHKID hkic symbol */ var_ocsss_request_dtm, var_ocsss_result, var_out_rtn_code, var_out_msg, var_out_pay_code, NULL, NULL);
                /* --------------------------- */
                /* --- TO DO : Begin ---- refer as PBRC : pbpu_cpi_upd_adm_reg -- */
                
                /* ---------------------------- */
                IF var_out_rtn_code = 0 THEN
                    BEGIN
                        /* check OCSSS return */
                        /* -------------------------------------------------------------------- */
                        /* --- A). TEP/TNE checked with EP1/NE9 returned  --> call cpi_update_adm_registration */
                        
                        /* -------------------------------------------------------------------- */
                        IF ((var_check_pay_code = var_out_pay_code) OR (var_check_pay_code = 'UID' AND var_out_pay_code = 'EP1')) AND var_out_pay_code IN ('EP1', 'NE9') THEN
                            /* --- Only allow to udpate EP1/NE9 */
                            BEGIN
                                CALL cpi_search_payment_detail(var_return_code, var_hosp_code, var_case_no,
                                /* --exec cpi..cpi_search_payment_detail @hosp_code,@case_no, */
                                /* ------------------------------- */
                                var_ae_admission_dtm, var_ae_transaction_datetime, var_ae_receipt_no, var_ae_pay_code, var_ae_payment_amount, var_ae_no_charge_indicator, var_ae_payment_means, var_ae_waiver_no, var_ae_waiver_type, var_ae_waiver_issue_party, var_ae_waiver_eff_date, var_ae_waiver_exp_date, var_ae_paid_amount, var_ae_update_by, var_ae_workstation_id, var_ae_source_system, var_ae_err_msg, var_ae_new_waiver_type, var_ae_upd_sys);
                                
                                /*
                                [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                                begin transaction
                                */
                                IF var_ae_transaction_datetime IS NOT NULL THEN
                                    BEGIN
                                        /* --update cpi..cpi_payment_detail 	---Unique key : hospital_code, transaction_datetime */
                                        UPDATE cpi_payment_detail /* ---HPI -- */
                                        SET pay_code = var_out_pay_code
                                            WHERE hospital_code = var_hosp_code AND transaction_datetime = var_ae_transaction_datetime AND case_no = var_case_no AND pay_code IN ('TEP', 'TNE');
                                    END;
                                END IF;
                                CALL cpi_update_adm_registration(var_return_status, var_hosp_code, var_case_no, var_original_hkid, /* ----case's HKID */ NULL, /* --adm dtm */ NULL, /* --source_ind */ NULL, /* --source_code */ var_out_pay_code, /* -----> Update the AE/HN pay code from TEP/TNE to EP1/NE9 */ NULL, /* --disch_code */ NULL, /* --dsch dtm */ NULL, /* --dest_code */ NULL, /* --ambulance_no */ NULL, /* --polce_case */ NULL, /* --labour_case */ NULL, /* --ae_case_type */ NULL,
                                /* dba_flag */
                                NULL, /* --folow_upd_dtm */ NULL, /* --ward_code */ NULL, /* --ward_class */ NULL, /* --bed_no */ NULL, /* --spec_code */ NULL, /* --sub_spec */ NULL, /* --pp_code */ var_case_type,
                                /* I/A only */
                                var_upd_txn_type, /* --txn_type  (121/341 only) */ 'P', /* --update type : WILL not update cpi_movment info except update_dtm */ var_cur_dtm, /* --txn dtm */ 'PAS_RECHK', /* ---@user_id */ 'PBRC', NULL, /* --document_flag */ NULL, /* ---eh_code */ NULL, /* ---source_hosp_code */ NULL);
                                /* --source_case_no */

                                IF var_return_status = 0 THEN
                                    BEGIN
                                        /*
                                        [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                                        commit transaction
                                        */
                                        SELECT
                                            'Reset the AE/HN adm record with OCSSS confirmed pay code [Success]- '
                                            INTO var_print_message;
                                    END;
                                ELSE
                                    BEGIN
                                        --ROLLBACK;
                                        raise exception 'Reset the AE/HN adm record with OCSSS confirmed pay code [Failed]- ';
                                        SELECT
                                            'Reset the AE/HN adm record with OCSSS confirmed pay code [Failed]- '
                                            INTO var_print_message;
                                    END;
                                END IF;
                                SELECT
                                    CONCAT(var_print_message, var_hosp_code, ', ', RTRIM(var_original_hkid), ', ', LTRIM(RTRIM(var_case_no)), ', adm_dtm[', to_char(var_tran_dtm::TIMESTAMP WITHOUT TIME ZONE, 'yyyy-mm-dd hh:mm:ss.sss'), '] ', var_original_pay_code, ', ', var_in_doc_type, ', ', var_in_hkic_symbol, ', ', LTRIM(RTRIM(COALESCE(var_in_ref_hkid, ''))), ',OCSSS_RESULT[', COALESCE(var_ocsss_result, ''), '], ', 'OUT_PAY_CODE[', COALESCE(var_out_pay_code, ''), ']')
                                    INTO var_print_message;
                                RAISE NOTICE '%', var_print_message;
                            END;
                        /* --- TEP checked with EP1 returned or TNE checked with NE9 returned */
                        
                        /* ---------------------------------------------------- */
                        
                        /* -----B) NON-Matched EP/NEP for TEP/TNE paycode */
                        
                        /* ---------------------------------------------------- */
                        ELSE
                            /* ----- NON-Matched EP/NEP for TEP/TNE paycode */
                            BEGIN
                                SELECT
                                    'OCSSS recheck with deviation or downtime - '
                                    INTO var_print_message;
                                SELECT
                                    CONCAT(var_print_message, var_hosp_code, ', ', RTRIM(var_original_hkid), ', ', LTRIM(RTRIM(var_case_no)), ', adm_dtm[', to_char(var_tran_dtm::TIMESTAMP WITHOUT TIME ZONE, 'yyyy-mm-dd hh:mm:ss.sss'), '] ', var_original_pay_code, ', ', var_in_doc_type, ', ', var_in_hkic_symbol, ', ', LTRIM(RTRIM(COALESCE(var_in_ref_hkid, ''))), ',OCSSS_RESULT[', COALESCE(var_ocsss_result, ''), '], ', 'OUT_PAY_CODE[', COALESCE(var_out_pay_code, ''), ']')
                                    INTO var_print_message;
                                RAISE NOTICE '%', var_print_message;
                            END;
                        END IF;
                    END; /* ---if @out_rtn_code = 0 */
                /* ---------------------------------------------------- */
                /* ---- C). Call ocsss failed again ----- */
                
                /* ---------------------------------------------------- */
                ELSE
                    BEGIN
                        SELECT
                            'OCSSS recheck error - '
                            INTO var_print_message;
                        SELECT
                            CONCAT(var_print_message, var_hosp_code, ', ', RTRIM(var_original_hkid), ', ', LTRIM(RTRIM(var_case_no)), ', adm_dtm[', to_char(var_tran_dtm::TIMESTAMP WITHOUT TIME ZONE, 'yyyy-mm-dd hh:mm:ss.sss'), '] ', var_original_pay_code, ', ', var_in_doc_type, ', ', var_in_hkic_symbol, ', ', LTRIM(RTRIM(COALESCE(var_in_ref_hkid, ''))), ',OCSSS_RESULT[', COALESCE(var_ocsss_result, ''), '], ', 'OUT_PAY_CODE[', COALESCE(var_out_pay_code, ''), ']')
                            INTO var_print_message;
                        RAISE NOTICE '%', var_print_message;
                    END;
                END IF /* ---if @out_rtn_code = 0 call ocss_check OK */;
                /* --------------------------- */
                /* --- TO DO : END  ---- */
                
                /* ---------------------------- */
                /* --End  ----- END : Found the TEP/TNE for the Active AE/HN cases ---- */
                
                /* --END   ---if @@rowcount =1 AND @in_pay_code in ('TEP','TNE') */
            END;
        END IF; /* ---20131205 --	if @org_case_pay_code in ('TEP','TNE') */
        /* ---- Next Record ------ */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_tran_dtm, var_tran_type, var_case_no, var_claimed_hkid, var_claimed_hkid_symbol, var_ocsss_result, var_ocsss_request_dtm, var_original_pay_code, var_original_hkid, var_upd_txn_type, var_org_case_pay_code;
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_doc_flag, var_in_pay_code, var_in_doc_type, var_in_hkid, var_in_hkic_symbol, var_in_ref_hkid, var_pky;
        FETCH tran_csr INTO var_tran_dtm, var_tran_type, var_case_no, var_org_case_pay_code, var_doc_flag, var_pky;
    END LOOP;
    CLOSE tran_csr;
    /* ----------------------------------- */
    IF var_ad_hoc_chk_flag = 'N' THEN
        BEGIN
            INSERT INTO ocsss_temp_paycode_check_log (hospital, start_datetime, end_datetime)
            VALUES (var_hosp_code, var_start_datetime, var_end_datetime);
        END;
    END IF;
END;
/* ----------------------------------- */
$procedure$
;
