-- DROP PROCEDURE hkpmi.ehr_event_polling(inout int4, in varchar, in timestamp, in timestamp, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_event_polling(INOUT pas_return_code integer, IN par_poll_mode character varying DEFAULT 'A'::character varying, IN par_poll_dtm_in timestamp without time zone DEFAULT '2014-05-01 00:00:00'::timestamp without time zone, IN par_poll_start_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_poll_stop_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_debug_mode character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_rtn_err_code INTEGER;
    var_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tran_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_begin_tran VARCHAR(1);
    var_row_cnt INTEGER;
    var_error_msg VARCHAR(255);
    var_failure_code INTEGER;
    /* --------------------------- */
    var_stop_poll VARCHAR(1);
    /* ----------------------- */
    var_evt_code VARCHAR(15);
    var_ack_evt_code VARCHAR(15);
    var_evt_crt_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_evt_crt_by VARCHAR(12);
    var_evt_crt_sys VARCHAR(12);
    var_evt_status VARCHAR(1);
    var_evt_final_status VARCHAR(1);
    var_evt_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_ehr_flag VARCHAR(3);
    var_old_ehr_flag VARCHAR(3);
    var_evt_txn_type VARCHAR(3);
    var_evt_ack VARCHAR(1);
    /* ------------------- */
    var_ehr_msg_no VARCHAR(20);
    var_ehr_txn_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_ehr_no VARCHAR(12);
    var_ehr_start_date VARCHAR(8);
    var_ehr_end_date VARCHAR(8);
    var_ehr_hkic VARCHAR(12);
    var_ehr_surname VARCHAR(40);
    var_ehr_givenname VARCHAR(40);
    var_ehr_full_name VARCHAR(100);
    var_ehr_sex VARCHAR(1);
    var_ehr_dob VARCHAR(8);
    var_ehr_exact_dob VARCHAR(4);
    var_ehr_doc_type VARCHAR(6);
    var_ehr_doc_no VARCHAR(30);
    var_ehr_death_date VARCHAR(8);
    var_ehr_death_time VARCHAR(10);
    var_ehr_exact_death VARCHAR(4);
    var_ehr_death_ind VARCHAR(4);
    /* ------------------------------ */
    var_old_ehr_hkic VARCHAR(12);
    var_old_ehr_surname VARCHAR(40);
    var_old_ehr_givenname VARCHAR(40);
    var_old_ehr_full_name VARCHAR(100);
    var_old_ehr_sex VARCHAR(1);
    var_old_ehr_dob VARCHAR(8);
    var_old_ehr_exact_dob VARCHAR(4);
    var_old_ehr_doc_type VARCHAR(6);
    var_old_ehr_doc_no VARCHAR(30);
    /* -------------------------- */
    var_pas_hkic VARCHAR(12);
    var_pas_pky VARCHAR(8);
    var_pas_surname VARCHAR(48);
    var_pas_givenname VARCHAR(48);
    var_pas_full_name VARCHAR(100);
    var_pas_sex VARCHAR(1);
    var_pas_dob VARCHAR(8);
    var_pas_exact_dob VARCHAR(4);
    var_pas_doc_type VARCHAR(6);
    var_pas_doc_code VARCHAR(1);
    var_pas_doc_no VARCHAR(30);
    var_pas_death_date VARCHAR(8);
    var_pas_death_time VARCHAR(10);
    var_pas_exact_death VARCHAR(4);
    var_pas_death_ind VARCHAR(4);
    /* --------------------- */
    var_ehr_doc_code VARCHAR(1);
    var_ehr_doc_code_2 VARCHAR(1);
    /* for BC/BN/BE or AR/AE/AN */
    var_ehr_doc_code_3 VARCHAR(1);
    /* ----- */
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upd_by VARCHAR(12);
    var_upd_sys VARCHAR(12);
    var_cur_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* ------- */
    var_record_str VARCHAR(255);
    var_pas_exact_dob_ehr VARCHAR(4);
    var_pas_dob_year VARCHAR(4);
    var_pas_dob_month VARCHAR(2);
    var_pas_dob_day VARCHAR(2);
    var_ehr_dob_year VARCHAR(4);
    var_ehr_dob_month VARCHAR(2);
    var_ehr_dob_day VARCHAR(2);
    var_cur_ehr_flag VARCHAR(3);
    var_cur_ehr_flag_prev VARCHAR(3);
    var_me_flag VARCHAR(1);
    var_evt_ack_status_epr VARCHAR(1);
    var_evt_ack_status_ehr VARCHAR(1);
    var_evt_ack_status_ris VARCHAR(1);
    var_debug_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_name_post_integer INTEGER;
    /* --@pas_name_to_chk  varchar(100),	-- reformat pas_full_name for checking by taking out : <space> <,> from name */
    /* --@ehr_name_to_chk  varchar(100),	-- reformat pas_full_name for checking by taking out : <space> <,> from name */
    var_pas_name_to_chk VARCHAR(48);
    /* reformat pas_full_name for checking by taking out : <space> <,> from name  and chk the first 48Chars ONLY */
    var_ehr_name_to_chk VARCHAR(48);
    /* reformat pas_full_name for checking by taking out : <space> <,> from name  and chk the first 48Chars ONLY */
    var_char_len_to_chk INTEGER;
    /* Check first 48 chars ONly -- */
    var_tmp_char VARCHAR(1);
    var_char_len INTEGER;
    var_last_polled_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Last polled txn */
    var_max_poll_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Used to set polling period */
    var_max_poll_dtm_allowed TIMESTAMP WITHOUT TIME ZONE;
    /* Used to limit the Upper Bound of polling period */
    var_polled_last_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Used to update ehr_event_conf.last_poll_dtm */
    var_run_flag VARCHAR(1);
    var_ins_ehr_surname VARCHAR(40);
    var_ins_ehr_givenname VARCHAR(40);
    var_ins_ehr_full_name VARCHAR(100);
    var_ins_ehr_sex VARCHAR(1);
    var_ins_ehr_dob VARCHAR(8);
    var_ins_ehr_exact_dob VARCHAR(4);
    var_ins_ehr_death_date VARCHAR(8);
    var_ins_ehr_death_time VARCHAR(10);
    var_ins_ehr_exact_death VARCHAR(4);
    var_ins_ehr_death_ind VARCHAR(4);
    var_ehr_conf_code VARCHAR(20);
    var_ehr_conf_value VARCHAR(20);
    var_ehr_ppi_ind VARCHAR(1);
    var_ehr_non_ha_ind VARCHAR(1);
    var_ehr_ppi_ind_org VARCHAR(1);
    var_ehr_non_ha_ind_org VARCHAR(1);
    var_ehr_ppi_ind_upd VARCHAR(1);
    var_ehr_crt_dtm TIMESTAMP WITHOUT TIME ZONE;
    "var_DUMMY_EHR_NO" VARCHAR(12);
    var_doc_pair_participant VARCHAR(1);
    var_ehr_smart_id VARCHAR(20);
    sql$rowcount BIGINT;
BEGIN
    /* ------------------------------------------------------------------------ */
    /* poll_mode = A, Auto Mode (i.e update ehr_event_conf.last_poll_dtm) -- */
    /* poll_mode = B, Bulk Mode (without update ehr_event_conf)           -- */
    
    /* ------------------------------------------------------------------------ */
    /* Allowed Backdate Polling Period : 7 day/180 day                    -- */
    /* Allowed Time-Range polling Period : 60 mins                        -- */
    /* The <ehr_event_in> records created by:<EHR_RCV_WS>/<PAS_POLL.ehr_pas_txn_polling> KNOCK_DOOR scenario */
    
    /* ------------------------------------------------------------------------------- */
    /* 20140710 : temp disable notify ePR for A47 Events      -- */
    /* 20140919 : trim space for name checking and chk the first 48Chars ONLY  -- */
    /* 20141204 : To fix SAME Txn DTM for same patient issue  but different result : <E00030-474501 / E00030-474500> : order by txn_dtm + msg_no */
    /* 20150212 : 2nd phase : ehr_ppi_ind/ehr_non_ha_ind */
    /* 20150521 : DUMMY Events :<029438615304> NO Ack need to eHR as well */
    /* 20160225 : BugFix for A47 marked as MKC (should be MKD if A28 marked MKD); Insert ehr_patient_list with @ehr_ppi_ind_default */
    /* 20160313 : select @ehr_ppi_ind_default ='Y' ----ON/After 13-Mar16 */
    /* 20160618 : remove "-" from name checking and mark ehr_flag ='MKC' instead 'NID' if A47 received on Identify */
    /* 20160708 : Bug-fix for re-join enrollment without ppi_ehr_ind = NULL if participant enrolled before 13-Mar-2016 : need to consider ADT_A28 triggered by 'Knock-door', but PPI paient !! */
    /* 20161012 : Bug-fix for 20160708 ver */
    /* 20161118 : New MIC/MIE/MIM for A47 on change HKID which TO_HKID NOT found in HA-PMI */
    /* 20170918 : delete the records for [ehr_pin_change_list] which records created by [MIU/MIP/MIM] if any event triggered by eHR-side (i.e will marked as MIC/MIE/MIM) */
    /* 20171115 : ehr_smart_id - this filed Should be included for A28/A47, will be handled as ehr-name flow-- */
    /* 20180115 : Disable As MI Series Enhancement suspendsion  ------------------------ */
    /* 20210913 :BackDate allowed period to 1.5 Years (540 Day) as request from eHR side/EH4 -- */
    /* 20231027 : To align eHR : Use 'Letter' (a-z A-Z) and 'Number' (0-9) for data matching (Remove all other characters except 'Letter' and 'Number' before data matching) */
    
    /* ------------------------------------------------------------------------------------ */
    
    /* -------------------- */
    /* 20150212 -- */
    
    /* --------------------------- */
    /* init for System Parm  -- */
    
    /* --------------------------- */
    SELECT
        '029438615304'
        INTO "var_DUMMY_EHR_NO";
    /* 20130519 */
    SELECT
        'EHR_POLL_EVT', 'EHR_POLL'
        INTO var_upd_by, var_upd_sys;
    SELECT
        48
        INTO var_char_len_to_chk;
    /* Check first 48 chars ONly -- */
    SELECT
        NULL
        INTO var_polled_last_sys_dtm;
    /* ---------------------------------------------- */
    IF par_poll_mode NOT IN ('B', 'A') THEN /* A - Auto, B - Bulk */
        BEGIN
            RAISE EXCEPTION '%', format('[EXIT]Poll Mode[%s] should either A or B', par_poll_mode) USING ERRCODE := '500017';
            pas_return_code := - 1;
            RETURN;
        END;
    END IF;

    IF par_poll_mode = 'B' AND (par_poll_start_dtm IS NULL OR par_poll_stop_dtm IS NULL OR par_poll_stop_dtm <= par_poll_start_dtm) THEN
        BEGIN
            RAISE EXCEPTION '%', format('[EXIT]Invalid poll[B Mode] period FROM [%s] to [%s]', par_poll_start_dtm, par_poll_stop_dtm) USING ERRCODE := '500018';
            pas_return_code := - 2;
            RETURN;
        END;
    END IF;
    /* --if @poll_mode ='B' AND DATEDIFF(DAY, @poll_start_dtm, @poll_stop_dtm) > 7 */
    IF par_poll_mode = 'B' AND DATE_PART('days', par_poll_stop_dtm::TIMESTAMP, par_poll_start_dtm::TIMESTAMP) > 540 THEN
        /* ----- 20210913 :BackDate allowed period to 1.5 Years as request from eHR side/EH4 -- */
        BEGIN
            RAISE EXCEPTION '%', format('[EXIT]Invalid poll[B Mode] period(over 7 day) FROM [%s] to [%s]', par_poll_start_dtm, par_poll_stop_dtm) USING ERRCODE := '500018';
            pas_return_code := - 3;
            RETURN;
        END;
    END IF;
    /* Auto-Mode ---------------------- */

    IF par_poll_mode = 'A' THEN
        BEGIN
            SELECT
                COALESCE(last_poll_dtm, '20140501')
                INTO par_poll_dtm_in
                FROM ehr_event_conf
                WHERE config_id = 1 AND system_id = 'EHR_POLL';
        END;
    END IF;

    IF par_poll_dtm_in IS NULL THEN
        SELECT
            '20140501'
            INTO par_poll_dtm_in;
    END IF;
    /* start dtm of ehr/pas interfaces */
    
    /* ------------------------------- */
    /* while (@stop_poll = 'N')  -- */
    
    /* ------------------------------- */
    IF par_debug_mode = 'Y' THEN
        RAISE NOTICE '[<WHILE Loop:  poll_dtm_in =[%] and poll_mode[%]', par_poll_dtm_in, par_poll_mode;
    END IF;
    SELECT
        'N'
        INTO var_stop_poll;

    WHILE (var_stop_poll = 'N') LOOP
        <<upd_record_status>>
        BEGIN
            <<notify_ack>>
            BEGIN
                <<upd_ehr_lst>>
                BEGIN
                    /* init for ehr_event record  -- */
                    SELECT
                        NULL, NULL, NULL, NULL, localtimestamp
                        INTO var_ehr_txn_dtm, var_ehr_msg_no, var_evt_code, var_evt_crt_sys, var_debug_dtm;
                    SELECT
                        'I', 'N', 'N', 0, NULL
                        INTO var_evt_final_status, var_begin_tran, var_me_flag, var_failure_code, var_doc_pair_participant;
                    /* init for polling record -- */
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_pas_name_to_chk, var_ehr_name_to_chk, var_tmp_char, var_char_len, var_ehr_doc_code, var_ehr_doc_code_2, var_ehr_doc_code_3;
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_cur_ehr_flag, var_cur_ehr_flag_prev, var_ehr_flag, var_old_ehr_flag, var_evt_ack, var_evt_ack_status_epr, var_evt_ack_status_ehr, var_evt_ack_status_ris;
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, 'Y', NULL
                        INTO var_ehr_conf_code, var_ehr_conf_value, var_ehr_ppi_ind, var_ehr_non_ha_ind, var_ehr_ppi_ind_org, var_ehr_non_ha_ind_org, var_ehr_ppi_ind_upd, var_ehr_smart_id;
                    /* ---------------------------------------------------------------------- */
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_pas_hkic, var_pas_pky, var_pas_death_ind, var_pas_death_date, var_pas_full_name, var_pas_surname, var_pas_givenname, var_pas_sex, var_pas_dob, var_pas_exact_dob, var_pas_exact_dob_ehr, var_pas_doc_code, var_pas_doc_type, var_pas_doc_no, var_pas_death_date, var_pas_death_time, var_pas_exact_death, var_pas_death_ind;
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_ins_ehr_surname, var_ins_ehr_givenname, var_ins_ehr_full_name, var_ins_ehr_sex, var_ins_ehr_dob, var_ins_ehr_exact_dob, var_ins_ehr_death_date, var_ins_ehr_death_time, var_ins_ehr_exact_death, var_ins_ehr_death_ind;
                    /* ------------------------------------------------------ */
                    /* <Step.1> Check <run_flag> with <last_polled_dtm> -- */
                    
                    /* ------------------------------------------------------ */
                    SELECT
                        COALESCE(last_poll_dtm, '20140501'), COALESCE(run_flag, 'N')
                        INTO var_last_polled_dtm, var_run_flag
                        FROM ehr_event_conf
                        WHERE config_id = 1 AND system_id = 'EHR_POLL';
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_row_cnt := sql$rowcount;

                    IF (var_row_cnt = 0) THEN
                        BEGIN
                            RAISE NOTICE '[EXIT]ehr_event_polling : missing the ehr_event_conf.config_id.1 = [%]', var_row_cnt;
                            EXIT;
                        END;
                    END IF;

                    IF var_run_flag != 'Y' THEN
                        BEGIN
                            RAISE NOTICE '[EXIT]ehr_event_polling : the ehr_event_conf.run_flag = [%]', var_run_flag;
                            EXIT
                            /* Exit Polling for Non-AutoMode polling--- */
                            ;
                        END;
                    END IF;
                    /* --------------- */
                    SELECT
                        localtimestamp
                        INTO var_cur_sys_dtm;
                    SELECT
                        - 30 * INTERVAL '1 second' + var_cur_sys_dtm::TIMESTAMP
                        INTO var_max_poll_dtm_allowed;
                    /* -------------------------------------------------- */
                    /* Allowed Time-Range polling Period : 60 Mins  -- */
                    
                    /* -------------------------------------------------- */
                    SELECT
                        60 * INTERVAL '1 minute' + var_last_polled_dtm::TIMESTAMP
                        INTO var_max_poll_dtm;

                    IF var_max_poll_dtm > var_max_poll_dtm_allowed THEN
                        SELECT
                            var_max_poll_dtm_allowed
                            INTO var_max_poll_dtm;
                    END IF;

                    IF par_poll_mode = 'A' THEN
                        /* AutoMode -- */
                        BEGIN
                            /* --select @poll_start_dtm = dateadd(dd,-7,@last_polled_dtm)  -- 20140527 to prevent missing records due to evt_txn_dtm < sys_dtm */
                            /* --select @poll_start_dtm = dateadd(dd,-180,@last_polled_dtm)  -- 20140527 to prevent missing records due to evt_txn_dtm < sys_dtm */
                            SELECT
                                - 540 * INTERVAL '1 day' + var_last_polled_dtm::TIMESTAMP
                                INTO par_poll_start_dtm;
                            /* 20210913 :BackDate allowed period to 1.5 Years as request from eHR side/EH4 -- */
                            SELECT
                                var_max_poll_dtm
                                INTO par_poll_stop_dtm;
                        END;
                    END IF;
                    /* --------------------------------------------------------------------------------------------------- */
                    /* <Step.2> Check un-handled in-coming events and Handling one by one records : <set rowcount 1> -- */
                    
                    /* --------------------------------------------------------------------------------------------------- */
                    SELECT
                        localtimestamp
                        INTO var_upd_dtm;
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 1
                    */
                    SELECT
                        txn_dtm, msg_no, evt_code, evt_crt_by, evt_crt_sys
                        INTO var_ehr_txn_dtm, var_ehr_msg_no, var_evt_code, var_evt_crt_by, var_evt_crt_sys
                        FROM ehr_event_in
                        WHERE evt_status = 'I' AND
                        /* using index XIE_ehr_event_in (evt_status,txn_dtm) */
                        txn_dtm >= par_poll_start_dtm AND txn_dtm <= par_poll_stop_dtm
                        ORDER BY txn_dtm NULLS FIRST, msg_no NULLS FIRST;
                    /* 20141204 -- */
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_row_cnt := sql$rowcount;
                    SELECT
                        COALESCE(var_ehr_txn_dtm, par_poll_stop_dtm)
                        INTO var_polled_last_sys_dtm;
                    /* Last polled eHR event txn dtm ---- */
                    
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 0
                    */
                    IF par_debug_mode = 'Y' THEN
                        BEGIN
                            RAISE NOTICE '----------------- cur_sys_dtm[%] ---------------------------------', var_cur_sys_dtm;
                            RAISE NOTICE '-->Polling period  : FROM =[%] TO [%] with RUN_FLAG=[%]', par_poll_start_dtm, par_poll_stop_dtm, var_run_flag;
                            RAISE NOTICE '-->Polling RowCount: [%] with last_polled_dtm[%] and polled_last_sys_dtm[%]', var_row_cnt, var_last_polled_dtm, var_polled_last_sys_dtm;
                            RAISE NOTICE '-----------------------------------------------------------------------------------------------';
                        END;
                    END IF;
                    /* -------------------------------------------------------- */
                    /* <Step 2.1>:  <NO EHR EVENT TXN> during the Period> -- */
                    
                    /* -------------------------------------------------------- */
                    IF var_row_cnt = 0 THEN
                        BEGIN
                            /* ---------------------------------------------------------------- */
                            /* Update last poll_dtm records for NEXT polling time marker  -- */
                            
                            /* ---------------------------------------------------------------- */
                            IF par_poll_mode = 'A' THEN
                                /* Auto-Polling Mode --- */
                                BEGIN
                                    UPDATE ehr_event_conf
                                    SET last_poll_dtm = var_polled_last_sys_dtm
                                        WHERE config_id = 1 AND system_id = 'EHR_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501');
                                    /* To prevent any Reset Time-Marker */
                                    PERFORM pg_sleep(30);
                                    CONTINUE
                                    /* Go <Step.1> */
                                    ;
                                END;
                            ELSE
                                BEGIN
                                    RAISE NOTICE '[EXIT]ehr_event_polling[%] : NO record From [%] To [%]', par_poll_mode, par_poll_start_dtm, par_poll_stop_dtm;
                                    EXIT
                                    /* Exit Polling for Non-AutoMode polling--- */
                                    ;
                                END;
                            END IF;
                        END;
                    END IF;
                    /* init -- */

                    IF RTRIM(LTRIM(var_ehr_msg_no)) = NULL OR (RTRIM(LTRIM(var_ehr_msg_no)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_msg_no;
                    END IF;

                    IF RTRIM(LTRIM(var_evt_code)) = NULL OR (RTRIM(LTRIM(var_evt_code)) = '') THEN
                        SELECT
                            NULL
                            INTO var_evt_code;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_txn_dtm)) = NULL OR (RTRIM(LTRIM(var_ehr_txn_dtm)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_txn_dtm;
                    END IF;
                    /* -------------------------------------------------------------------------------------------------------- */
                    /* <Step 2.2:Validation for the Event> : NOT EHR_WS event to handle --> PASS (should not be happend)  -- */
                    
                    /* -------------------------------------------------------------------------------------------------------- */
                    /* 2.2.1: Functional information --- */
                    IF var_ehr_msg_no IS NULL OR var_evt_code IS NULL OR var_ehr_txn_dtm IS NULL THEN
                        BEGIN
                            SELECT
                                500006
                                INTO var_rtn_err_code;
                            /* invalid Functional information */
                            SELECT
                                'E'
                                INTO var_evt_final_status;
                            EXIT upd_record_status;
                        END;
                    END IF;
                    /* 2.2.2: Source System --- */

                    IF (var_evt_crt_sys NOT IN ('EHR_RCV_WS', 'PAS_POLL', 'EHR_EXG_WS')) THEN
                        BEGIN
                            SELECT
                                500019
                                INTO var_rtn_err_code;
                            /* invalid Functional information */
                            SELECT
                                'K'
                                INTO var_evt_final_status;
                            EXIT upd_record_status;
                        END;
                    END IF;

                    IF par_debug_mode = 'Y' THEN
                        RAISE NOTICE '[2.3.1] evt_code[%] ehr_msg_no[%] ehr_txn_dtm[%] evt_crt_sys[%]', var_evt_code, var_ehr_msg_no, var_ehr_txn_dtm, var_evt_crt_sys;
                    END IF;
                    /* ------------------------------------------------------- */
                    /* <Step 2.3.1: Retrieve the Event Record >          -- */
                    
                    /* ------------------------------------------------------- */
                    
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 1
                    */
                    SELECT
                        ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, ehr_death_date, ehr_death_time, ehr_exact_death, ehr_death_ind, old_ehr_hkic, old_ehr_surname, old_ehr_givenname, old_ehr_full_name, old_ehr_sex, old_ehr_dob, old_ehr_exact_dob, old_ehr_doc_type, old_ehr_doc_no, sys_dtm,
                        /* 20150212 -- */
                        ehr_conf_code, ehr_conf_value, ehr_smart_id
                        INTO var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_doc_type, var_ehr_doc_no, var_ehr_death_date, var_ehr_death_time, var_ehr_exact_death, var_ehr_death_ind, var_old_ehr_hkic, var_old_ehr_surname, var_old_ehr_givenname, var_old_ehr_full_name, var_old_ehr_sex, var_old_ehr_dob, var_old_ehr_exact_dob, var_old_ehr_doc_type, var_old_ehr_doc_no, var_evt_sys_dtm, var_ehr_conf_code, var_ehr_conf_value, var_ehr_smart_id
                        /* 20171115 */
                        FROM ehr_event_in
                        WHERE txn_dtm = var_ehr_txn_dtm AND msg_no = var_ehr_msg_no;
                    /* msg_no unique key for update */
                    
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 0
                    */
                    
                    /* --------------------------------------------------------------------------- */
                    /* <Step 2.3.2: init/convert the EHR data for PAS Data matching process> -- */
                    
                    /* --------------------------------------------------------------------------- */
                    IF RTRIM(LTRIM(var_ehr_no)) = NULL OR (RTRIM(LTRIM(var_ehr_no)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_no;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_start_date)) = NULL OR (RTRIM(LTRIM(var_ehr_start_date)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_start_date;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_end_date)) = NULL OR (RTRIM(LTRIM(var_ehr_end_date)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_end_date;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_hkic)) = NULL OR (RTRIM(LTRIM(var_ehr_hkic)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_hkic;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_surname)) = NULL OR (RTRIM(LTRIM(var_ehr_surname)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_surname;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_givenname)) = NULL OR (RTRIM(LTRIM(var_ehr_givenname)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_givenname;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_full_name)) = NULL OR (RTRIM(LTRIM(var_ehr_full_name)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_full_name;
                    END IF;
                    /* ---------------------------------------------------------------------------------------------------- */
                    IF RTRIM(LTRIM(var_ehr_sex)) = NULL OR (RTRIM(LTRIM(var_ehr_sex)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_sex;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_dob)) = NULL OR (RTRIM(LTRIM(var_ehr_dob)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_dob;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_exact_dob)) = NULL OR (RTRIM(LTRIM(var_ehr_exact_dob)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_exact_dob;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_doc_type)) = NULL OR (RTRIM(LTRIM(var_ehr_doc_type)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_doc_type;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_doc_no)) = NULL OR (RTRIM(LTRIM(var_ehr_doc_no)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_doc_no;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_death_date)) = NULL OR (RTRIM(LTRIM(var_ehr_death_date)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_death_date;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_death_time)) = NULL OR (RTRIM(LTRIM(var_ehr_death_time)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_death_time;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_exact_death)) = NULL OR (RTRIM(LTRIM(var_ehr_exact_death)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_exact_death;
                    END IF;

                    IF RTRIM(LTRIM(var_ehr_death_ind)) = NULL OR (RTRIM(LTRIM(var_ehr_death_ind)) = '') THEN
                        SELECT
                            NULL
                            INTO var_ehr_death_ind;
                    END IF;
                    /* ------------------------------------------------------------------------------------------------------- */
                    IF RTRIM(LTRIM(var_old_ehr_hkic)) = NULL OR (RTRIM(LTRIM(var_old_ehr_hkic)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_hkic;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_surname)) = NULL OR (RTRIM(LTRIM(var_old_ehr_surname)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_surname;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_givenname)) = NULL OR (RTRIM(LTRIM(var_old_ehr_givenname)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_givenname;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_full_name)) = NULL OR (RTRIM(LTRIM(var_old_ehr_full_name)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_full_name;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_sex)) = NULL OR (RTRIM(LTRIM(var_old_ehr_sex)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_sex;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_dob)) = NULL OR (RTRIM(LTRIM(var_old_ehr_dob)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_dob;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_exact_dob)) = NULL OR (RTRIM(LTRIM(var_old_ehr_exact_dob)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_exact_dob;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_doc_type)) = NULL OR (RTRIM(LTRIM(var_old_ehr_doc_type)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_doc_type;
                    END IF;

                    IF RTRIM(LTRIM(var_old_ehr_doc_no)) = NULL OR (RTRIM(LTRIM(var_old_ehr_doc_no)) = '') THEN
                        SELECT
                            NULL
                            INTO var_old_ehr_doc_no;
                    END IF;
                    /* 20150126 -- */

                    IF LTRIM(RTRIM(var_ehr_conf_code)) = NULL OR LTRIM(RTRIM(var_ehr_conf_code)) = '' THEN
                        SELECT
                            NULL
                            INTO var_ehr_conf_code;
                    END IF;

                    IF LTRIM(RTRIM(var_ehr_conf_value)) = NULL OR LTRIM(RTRIM(var_ehr_conf_value)) = '' THEN
                        SELECT
                            NULL
                            INTO var_ehr_conf_value;
                    END IF;

                    IF LTRIM(RTRIM(var_ehr_smart_id)) = NULL OR LTRIM(RTRIM(var_ehr_smart_id)) = '' THEN
                        SELECT
                            NULL
                            INTO var_ehr_smart_id;
                    END IF;

                    IF par_debug_mode = 'Y' THEN
                        RAISE NOTICE '[2.3.2] ehr_no[%] ehr_hkic[%] ehr_doc_type[%] ehr_doc_no[%]', var_ehr_no, var_ehr_hkic, var_ehr_doc_type, var_ehr_doc_no;
                    END IF;
                    /* --------------------------------------------------- */
                    /* <Step 2.3.3: Validation on the Event Record > -- */
                    
                    /* --------------------------------------------------- */
                    /* <2.3.3.1: Paricipant Identity> --- */
                    IF var_ehr_no IS NULL OR CHAR_LENGTH(var_ehr_no) <> 12 OR var_ehr_full_name IS NULL OR var_ehr_dob IS NULL OR var_ehr_exact_dob IS NULL OR var_ehr_sex IS NULL OR (var_ehr_hkic IS NULL AND (var_ehr_doc_type IS NULL OR var_ehr_doc_no IS NULL)) THEN
                        BEGIN
                            SELECT
                                500005
                                INTO var_rtn_err_code;
                            /* invalid Participant identity */
                            SELECT
                                'E'
                                INTO var_evt_final_status;
                            EXIT upd_record_status;
                        END;
                    END IF;
                    /* <2.3.3.2: Functional information> --- */

                    IF var_ehr_msg_no IS NULL OR var_evt_code IS NULL OR var_ehr_txn_dtm IS NULL THEN
                        BEGIN
                            SELECT
                                500006
                                INTO var_rtn_err_code;
                            /* invalid Functional information */
                            SELECT
                                'E'
                                INTO var_evt_final_status;
                            EXIT upd_record_status;
                        END;
                    END IF;
                    /* <2.3.3.3 : HL7 Event Type >--- */

                    IF (var_evt_crt_sys = 'EHR_RCV_WS' AND var_evt_code NOT IN ('ADT_A08', 'ADT_A28', 'ADT_A47', 'ADT_A29', 'EXG_EHR_PAS')) OR (var_evt_crt_sys = 'PAS_POLL ' AND var_evt_code NOT IN ('ADT_A28')) THEN
                        /* 'Knock-door':A28 Event by EHR_QRY_WS and triggered by PAS_POLL txn -- */
                        BEGIN
                            SELECT
                                500007
                                INTO var_rtn_err_code;
                            /* invalid HL7 Event Type */
                            SELECT
                                'E'
                                INTO var_evt_final_status;
                            EXIT upd_record_status;
                        END;
                    END IF;
                    /* --------------------------------------------------------------------------- */
                    /* <Step 2.3.4: Event Validation passed and Data-Reformat for next step  -- */
                    
                    /* --------------------------------------------------------------------------- */
                    IF var_evt_code = 'ADT_A08' THEN
                        SELECT
                            'DDR'
                            INTO var_evt_txn_type;
                    ELSE
                        IF var_evt_code = 'ADT_A28' THEN
                            SELECT
                                'ENT'
                                INTO var_evt_txn_type;
                        ELSE
                            IF var_evt_code = 'ADT_A29' THEN
                                SELECT
                                    'WHD'
                                    INTO var_evt_txn_type;
                            ELSE
                                IF var_evt_code = 'ADT_A47' THEN
                                    SELECT
                                        'MKC'
                                        INTO var_evt_txn_type;
                                ELSE
                                    IF var_evt_code = 'EXG_EHR_PAS' THEN
                                        SELECT
                                            'EXG'
                                            INTO var_evt_txn_type;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                    /* 20150126 */
                    
                    /* ------------------------------------------------------------------------------- */
                    /* Reformat ehr_full_name for checking by taking out : <space> <,> <-> chk first 48Chars ONLY -- */
                    
                    /* ------------------------------------------------------------------------------- */
                    SELECT
                        NULL, NULL
                        INTO var_ehr_name_to_chk, var_tmp_char;
                    SELECT
                        1
                        INTO var_name_post_integer;
                    SELECT
                        CHAR_LENGTH(RTRIM(var_ehr_full_name))
                        INTO var_char_len;

                    WHILE (var_name_post_integer <= COALESCE(var_char_len, 0) AND var_ehr_full_name != NULL AND var_name_post_integer <= var_char_len_to_chk) LOOP
                        /* To prevent any possibility of infinite-loop and check first 48 Chars ONLY) --- */
                        SELECT
                            SUBSTRING(var_ehr_full_name, var_name_post_integer, 1)
                            INTO var_tmp_char;
                        /* if (@tmp_char != " " and @tmp_char != "," and @tmp_char != "-" and @tmp_char != "." ) 	select @ehr_name_to_chk = @ehr_name_to_chk + @tmp_char */

                        IF (var_tmp_char LIKE '[0-9]' OR UPPER(var_tmp_char) LIKE '[A-Z]') THEN
                            SELECT
                                CONCAT(var_ehr_name_to_chk, var_tmp_char)
                                INTO var_ehr_name_to_chk;
                        END IF;
                        SELECT
                            var_name_post_integer + 1
                            INTO var_name_post_integer;
                    END LOOP;
                    /* --------------------------------------------------------- */
                    /* 3.0  Common Validation       ------------------------- */
                    
                    /* --------------------------------------------------------- */
                    /* <Step 3.0.1: Find HA-PMI HKIC to retrive local EMR> -- */
                    
                    /* --------------------------------------------------------- */
                    IF var_ehr_hkic IS NOT NULL THEN
                        BEGIN
                            SELECT
                                var_ehr_hkic
                                INTO var_pas_hkic;
                            SELECT
                                'N'
                                INTO var_doc_pair_participant
                            /* Non Doc.Pair eHR participant */
                            ;
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                'Y'
                                INTO var_doc_pair_participant;
                            /* Doc.Pair eHR participant */
                            SELECT
                                document_code
                                INTO var_ehr_doc_code
                                FROM document_type
                                WHERE document_type = var_ehr_doc_type::VARCHAR;
                            /* if @ehr_doc_code is null */
                            /* --	select @ehr_doc_code ='%'		-- if document type no found, search pas_hkic by ehr_doc_no only is acceptable ??? */
                            
                            /* ------------------------------------------ */
                            /* EHR/PAS Doc type mapping -- */
                            /* 1. AR --> AR(2)/AE(O)/AN(P) -- */
                            /* 2. BC --> BC(3)/BE(Q)/BN(R) -- */
                            
                            /* ---------------------------------------- */
                            IF var_ehr_doc_code = '2' THEN
                                SELECT
                                    'O', 'P'
                                    INTO var_ehr_doc_code_2, var_ehr_doc_code_3;
                            END IF;

                            IF var_ehr_doc_code = '3' THEN
                                SELECT
                                    'Q', 'R'
                                    INTO var_ehr_doc_code_2, var_ehr_doc_code_3;
                            END IF;
                            SELECT
                                hkid
                                INTO var_pas_hkic
                                FROM patient
                                WHERE other_doc_no = var_ehr_doc_no AND (SUBSTRING(filler, 1, 1) = var_ehr_doc_code OR
                                /* document_flag = substring(patient.filler,1,1) -- */
                                SUBSTRING(filler, 1, 1) = var_ehr_doc_code_2 OR SUBSTRING(filler, 1, 1) = var_ehr_doc_code_3);
                            /* one-to-one mapping only <Oct-2013 PAS/EHR meeting> --- */
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_row_cnt := sql$rowcount;

                            IF var_row_cnt != 1 THEN
                                SELECT
                                    NULL
                                    INTO var_pas_hkic;
                            END IF;
                        END;
                    END IF;
                    /* ------------------------------------------- */
                    /* <Step 3.0.2: Retrieve HA-PMI records> -- */
                    
                    /* ------------------------------------------- */
                    SELECT
                        patient_key, death_indicator, to_char(death_date::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), patient_name, sex, to_char(dob::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), exact_dob_flag, SUBSTRING(filler, 1, 1), other_doc_no
                        INTO var_pas_pky, var_pas_death_ind, var_pas_death_date, var_pas_full_name, var_pas_sex, var_pas_dob, var_pas_exact_dob, var_pas_doc_code, var_pas_doc_no
                        FROM patient
                        WHERE hkid = var_pas_hkic;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_row_cnt := sql$rowcount;
                    /* ----------------------------------------------- */
                    /* <Step 3.0.3> : eHR participant not found  -- */
                    
                    /* ----------------------------------------------- */
                    /* 1. <ADT_A28> : Update as NID              -- */
                    /* 2. <ADT_A47> : Update as MIC/MIM/MIE      -- */
                    
                    /* ----------------------------------------------- */
                    IF var_evt_code IN ('ADT_A28') AND (var_pas_pky IS NULL OR var_row_cnt = 0) THEN
                        BEGIN
                            SELECT
                                NULL, NULL, NULL, 'NID', '2',
                                /* ACK - Patient NOT found */
                                'S'
                                INTO var_pas_pky, var_pas_doc_type, var_pas_doc_no, var_ehr_flag, var_evt_ack, var_evt_final_status;
                            /* DM completed */
                            EXIT upd_ehr_lst;
                        END;
                    END IF;
                    /* --------------------------------------------------------------------------------------- */
                    /* 20161118 : eHR change HKID in A47 and TO_HKID Not Found in HA-PMI --> MIC         -- */
                    
                    /* --------------------------------------------------------------------------------------- */
                    /* 1.1 Prev status VAL/MKC        -->MIC and keep Prev HA-PMI Pdemo => DataUPload    -- */
                    /* 1.2 Prev status other than VAL -->MIE and keep Prev HA-PMI Pdemo => No DataUPload -- */
                    
                    /* --------------------------------------------------------------------------------------- */
                    IF var_evt_code IN ('ADT_A47') AND (var_pas_pky IS NULL OR var_row_cnt = 0) THEN
                        BEGIN
                            /*
                            -- 20180115 : Disable As MI Series Enhancement suspendsion  -----------------------------
                             SELECT 	@cur_ehr_flag = ehr_flag
                             FROM ehr_patient_list
                             WHERE ehr_number = @ehr_no	-- If NOT found =>UPD_EHR_LIST->select @rtn_err_code = 500023 (Error Handling the EHR record-SKIP(U status)
                             ----------------------------------------------------------------
                             if @cur_ehr_flag in ('VAL','MKC')	   select @ehr_flag='MIC' -- Identity changed but history MK matched
                             else if @cur_ehr_flag in ('MES','MKM') select @ehr_flag='MIM' -- Identity changed with OutstandingMoveEpisode(O status)
                             else                                   select @ehr_flag='MIE' -- Identify changed but NOT matched
                            ------------------------------------------------------------------------------
                             Keep Previous HA-PMI Pdemo :ePR still need these info to DataUpload (MIC)  --
                            ------------------------------------------------------------------------------
                            select
                            	-- @pas_pky =null,
                            	-- @pas_doc_type=null,
                            	-- @pas_doc_no =null,
                            	@evt_ack ='2',           -- ACK - Patient NOT found
                            	@evt_final_status = 'S'	 -- DM completed
                            -- 20180115 : END -----------------------------------------------------------
                            */
                            SELECT
                                NULL, NULL, NULL, 'NID', '2',
                                /* ACK - Patient NOT found */
                                'S'
                                INTO var_pas_pky, var_pas_doc_type, var_pas_doc_no, var_ehr_flag, var_evt_ack, var_evt_final_status;
                            /* DM completed */
                            EXIT upd_ehr_lst;
                        END;
                    END IF;
                    /* ------------------------------------------------------------------------------ */
                    IF par_debug_mode = 'Y' THEN
                        RAISE NOTICE '[<Step 3.0.3: Retrieve local EMR> <%>] - ehr_hkic[%] pas_hkic[%] pas_pky[%]', var_debug_dtm, var_ehr_hkic, var_pas_hkic, var_pas_pky;
                    END IF;
                    /* ------------------------------------------------------------------------------ */
                    /* <Step 3.0.4> : eHR participant found  - Data/Code conversion between PAS/EHR dataset code tables -- */
                    
                    /* ------------------------------------------------------------------------------ */
                    IF var_pas_pky IS NOT NULL THEN
                        BEGIN
                            /* Surname/full_name -- */
                            SELECT
                                STRPOS(var_pas_full_name, ',')
                                INTO var_name_post_integer;
                            SELECT
                                LTRIM(RTRIM(LEFT(var_pas_full_name, var_name_post_integer - 1)))
                                INTO var_pas_surname;
                            SELECT
                                LTRIM(RTRIM(RIGHT(var_pas_full_name, LENGTH(var_pas_full_name) - var_name_post_integer)))
                                INTO var_pas_givenname;
                            /* ------------------------------------------------------------------------- */
                            /* Reformat pas_full_name for checking by taking out : <space> <,> <-> -- */
                            
                            /* ------------------------------------------------------------------------- */
                            SELECT
                                NULL, NULL
                                INTO var_pas_name_to_chk, var_tmp_char;
                            SELECT
                                1
                                INTO var_name_post_integer;
                            SELECT
                                CHAR_LENGTH(RTRIM(var_pas_full_name))
                                INTO var_char_len;

                            WHILE (var_name_post_integer <= COALESCE(var_char_len, 0) AND var_pas_full_name != NULL AND var_name_post_integer <= var_char_len_to_chk) LOOP
                                /* To prevent any possibility of infinite-loop and check first 48 Chars ONLY -- */
                                SELECT
                                    SUBSTRING(var_pas_full_name, var_name_post_integer, 1)
                                    INTO var_tmp_char;
                                /* if (@tmp_char != " " and @tmp_char != "," and @tmp_char != "-" and @tmp_char != "." ) 	select @pas_name_to_chk = @pas_name_to_chk + @tmp_char */

                                IF (var_tmp_char LIKE '[0-9]' OR UPPER(var_tmp_char) LIKE '[A-Z]') THEN
                                    SELECT
                                        CONCAT(var_pas_name_to_chk, var_tmp_char)
                                        INTO var_pas_name_to_chk;
                                END IF;
                                SELECT
                                    var_name_post_integer + 1
                                    INTO var_name_post_integer;
                            END LOOP;
                            /* Exact DOB flag -- */

                            IF var_pas_exact_dob = 'Y' THEN
                                SELECT
                                    'EDMY'
                                    INTO var_pas_exact_dob_ehr;
                            ELSE
                                SELECT
                                    'EY'
                                    INTO var_pas_exact_dob_ehr;
                            END IF;
                            /* NO EMY patient for HA-PMI records ! -- */
                            SELECT
                                SUBSTRING(var_pas_dob, 1, 4)
                                INTO var_pas_dob_year;
                            SELECT
                                SUBSTRING(var_pas_dob, 5, 2)
                                INTO var_pas_dob_month;
                            SELECT
                                SUBSTRING(var_pas_dob, 7, 2)
                                INTO var_pas_dob_day;
                            SELECT
                                SUBSTRING(var_ehr_dob, 1, 4)
                                INTO var_ehr_dob_year;
                            SELECT
                                SUBSTRING(var_ehr_dob, 5, 2)
                                INTO var_ehr_dob_month;
                            SELECT
                                SUBSTRING(var_ehr_dob, 7, 2)
                                INTO var_ehr_dob_day;
                            SELECT
                                document_type
                                INTO var_pas_doc_type
                                FROM document_type
                                WHERE document_code = var_pas_doc_code;
                        END;
                    END IF;
                    /* ------------------------------------------------ */
                    /* <Step 3.1>  ADT_A28  - New Enrolment       -- */
                    
                    /* ------------------------------------------------ */
                    /* Purpose: */
                    /* To uniquely and accurately identify the eHR participant */
                    /* Rules: */
                    /* Mandatory a)<ehr enrolment start date> */
                    /* Validation on PIN /Functional Info/HL7 Event Type passed in <2.3.3.1>/<2.3.3.2>/<2.3.3.3> */
                    /* Actions: */
                    /* a)Match participant with local data */
                    /* b)Store eHR number in local EMR system */
                    /* c)Upload all participant clincial data FROM local EMR to eHR  through [PAS->EPR notification] */
                    
                    /* ------------------------------------------------------- */
                    IF var_evt_crt_sys IN ('EHR_RCV_WS', 'PAS_POLL') AND var_evt_code = 'ADT_A28' THEN
                        BEGIN
                            SELECT
                                'ENT', localtimestamp
                                INTO var_evt_txn_type, var_cur_sys_dtm;
                            /* 3.1.1: Validation */
                            
                            /* ------------------------------------------------------------------------------ */
                            /* 20161118 : ehr_start_date will be NULL for <Knock-door> A28 on orginal PPI participant like :<'557111210289' on 27Oct2016> */
                            
                            /* ------------------------------------------------------------------------------- */
                            /* if @ehr_start_date is null */
                            /* begin */
                            /* --	select @rtn_err_code = 500002   -- invalid start dtm */
                            
                            /* --	select @evt_final_status = 'E' */
                            
                            /* --	GOTO UPD_RECORD_STATUS */
                            /* end */
                            
                            /* ------------------------------------------------------- */
                            IF par_debug_mode = 'Y' THEN
                                BEGIN
                                    RAISE NOTICE '[3.1_A28] ehr_name_to_chk[%] ehr_sex[%] ehr_dob[%] ehr_exact_dob[%]', var_ehr_name_to_chk, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob;
                                    RAISE NOTICE '[3.1_A28] pas_name_to_chk[%] pas_sex[%] pas_dob[%] pas_exact_dob[%]', var_pas_name_to_chk, var_pas_sex, var_pas_dob, var_pas_exact_dob_ehr;
                                END;
                            END IF;
                            /* ------------------------------------------------------- */
                            /* <Step 3.1.2. ---DataMaching ....>--- */
                            
                            /* ------------------------------------------------------- */
                            IF EXISTS (SELECT
                                *
                                FROM move_episode_indicator
                                WHERE (from_patient_key = var_pas_pky OR to_patient_key = var_pas_pky) AND move_status = 'O') THEN
                                SELECT
                                    'Y'
                                    INTO var_me_flag;
                            END IF;

                            IF var_ehr_sex <> var_pas_sex OR var_ehr_name_to_chk <> var_pas_name_to_chk OR (var_ehr_exact_dob = 'EDMY' AND var_ehr_dob <> var_pas_dob) OR (var_ehr_exact_dob = 'EY' AND var_ehr_dob_year <> var_pas_dob_year) OR (var_ehr_exact_dob = 'EMY' AND var_ehr_dob_year <> var_pas_dob_year) THEN
                                BEGIN
                                    /* ---------MK NOT matched-------------- */
                                    IF var_me_flag = 'Y' THEN
                                        SELECT
                                            'MKM', '3'
                                            INTO var_ehr_flag, var_evt_ack;
                                    /* 3.1.2.1 (MKM) :Major Keys Not matched with ME */
                                    ELSE
                                        SELECT
                                            'MKD', '3'
                                            INTO var_ehr_flag, var_evt_ack;
                                    END IF
                                    /* 3.1.2.2 (MKD) :Major Keys Not matched without ME */
                                    ;
                                END;
                            ELSE
                                /* ---------MK Matched-------------- */
                                BEGIN
                                    IF var_me_flag = 'Y' THEN
                                        SELECT
                                            'MES', '4'
                                            INTO var_ehr_flag, var_evt_ack;
                                    /* 3.1.2.3 (MES) :Major Keys matched With ME */
                                    ELSE
                                        SELECT
                                            'VAL', '1'
                                            INTO var_ehr_flag, var_evt_ack;
                                    END IF
                                    /* 3.1.2.4 (VAL) :Major Keys matched without ME */
                                    ;
                                END;
                            END IF;
                            SELECT
                                'S'
                                INTO var_evt_final_status;
                            /* DM completed */
                            EXIT upd_ehr_lst;
                        END;
                    END IF;
                    /* -------------------------------------------- */
                    /* <Step 3.2>  ADT_A29  - Withdraw EHR    -- */
                    
                    /* -------------------------------------------- */
                    /* Purpose: */
                    /* Immediate action for withdraw to protect the security of paticipant's ehr records */
                    /* Rules: */
                    /* Mandatory a)<ehr enrolment END date> */
                    /* Validation on PIN /Functional Info(msg#,evt_code,txn dtm)/HL7 Event Type passed in <2.3.3.1>/<2.3.3.2>/<2.3.3.3> */
                    /* Actions: */
                    /* a)Match participant with local data */
                    /* b)Mark eHR deregistration date and status in local EMR system */
                    /* c)Stop to send any data, including backdate data to ehr after deregistration date Through [PAS->EPR notification] */
                    
                    /* ------------------------------------------------------- */
                    IF var_evt_crt_sys = 'EHR_RCV_WS' AND var_evt_code = 'ADT_A29' THEN
                        BEGIN
                            SELECT
                                'WHD', localtimestamp
                                INTO var_evt_txn_type, var_cur_sys_dtm;
                            /* 3.2.1) - Validation */

                            IF var_ehr_end_date IS NULL THEN
                                BEGIN
                                    SELECT
                                        500013
                                        INTO var_rtn_err_code; /* ---invalid end dtm */
                                    SELECT
                                        'E'
                                        INTO var_evt_final_status;
                                    EXIT upd_record_status;
                                END;
                            END IF;

                            IF par_debug_mode = 'Y' THEN
                                BEGIN
                                    RAISE NOTICE '[3.2_A29] ehr_name_to_chk[%] ehr_sex[%] ehr_dob[%] ehr_exact_dob[%]', var_ehr_name_to_chk, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob;
                                    RAISE NOTICE '[3.2_A29] pas_name_to_chk[%] pas_sex[%] pas_dob[%] pas_exact_dob[%]', var_pas_name_to_chk, var_pas_sex, var_pas_dob, var_pas_exact_dob_ehr;
                                END;
                            END IF;
                            /* 3.2.1   --- ehr patient found (without MK checking) */

                            IF EXISTS (SELECT
                                1
                                FROM ehr_patient_list
                                WHERE ehr_number = var_ehr_no) THEN
                                SELECT
                                    '1'
                                    INTO var_evt_ack; /* ----Patient Found (without MK checking) */
                            ELSE
                                SELECT
                                    '2'
                                    INTO var_evt_ack;
                            END IF; /* ---Patient NOT found */
                            SELECT
                                'WHD', 'S'
                                INTO var_ehr_flag, var_evt_final_status; /* ---DM completed */
                            /* BEGIN TRAN here ...-------- */
                            
                            /* --if @@trancount = 0 */
                            BEGIN
                                /*
                                [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                                begin tran
                                */
                                SELECT
                                    'Y'
                                    INTO var_begin_tran;
                            END;
                            /* eHR patient Found (without MK checking)--> update as 'WHD'  -- */

                            IF var_evt_ack = '1' THEN
                                BEGIN
                                    BEGIN
                                        UPDATE ehr_patient_list
                                        SET ehr_flag = var_ehr_flag, evt_ack = var_evt_ack, ehr_end_date = var_ehr_end_date,
                                        /* END Date */
                                        upd_by = var_upd_by, upd_sys = var_upd_sys, upd_dtm = var_upd_dtm, sys_dtm = var_cur_sys_dtm
                                            WHERE ehr_number = var_ehr_no;
                                        var_rtn_err_code := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                var_rtn_err_code := 1;
                                    END;

                                    IF var_rtn_err_code != 0 THEN
                                        BEGIN
                                            SELECT
                                                5
                                                INTO var_failure_code;
                                            /* system failed -SKIP Record */
                                            SELECT
                                                500023
                                                INTO var_rtn_err_code;
                                            /* Error Handling the EHR record-SKIP */
                                            SELECT
                                                'U'
                                                INTO var_evt_final_status;
                                            EXIT upd_record_status;
                                        END;
                                    END IF;
                                END;
                            END IF;
                            EXIT notify_ack
                            /* Ack.generation to <ehr_event_out> to EHR/EPR	and create <ehr_event_txn> record -- */
                            ;
                        END;
                    END IF;
                    /* --------------------------------------------------------- */
                    /* <Step 3.3>  ADT_A08 - Update Participant Death Data -- */
                    
                    /* --------------------------------------------------------- */
                    /* Purpose: */
                    /* To uniquely and accurately identify the eHR participant and <<update death date>> */
                    /* Data Component : Participant Identity and Death date info. */
                    /* Rules: */
                    /* Mandatory a)<Date of Death> and <Exact date of deat indicator> */
                    /* Validation on PIN /Functional Info/HL7 Event Type passed in <2.3.3.1>/<2.3.3.2>/<2.3.3.3> */
                    /* Actions: */
                    /* a) Update the EHR participatns's death status <eHR patient List/eHR Exp List also ?> */
                    /* b) stop uploading deceased paticipants' clinicial data to eHR */
                    
                    /* ------------------------------------------------------- */
                    IF var_evt_crt_sys = 'EHR_RCV_WS' AND var_evt_code = 'ADT_A08' THEN
                        BEGIN
                            SELECT
                                'DDR', localtimestamp
                                INTO var_evt_txn_type, var_cur_sys_dtm;
                            /* 3.3.1) - Validation */

                            IF var_ehr_death_date IS NULL OR var_ehr_exact_death IS NULL THEN
                                BEGIN
                                    SELECT
                                        500014
                                        INTO var_rtn_err_code;
                                    /* invalid Death dtm */
                                    SELECT
                                        'E'
                                        INTO var_evt_final_status;
                                    EXIT upd_record_status;
                                END;
                            END IF;

                            IF par_debug_mode = 'Y' THEN
                                BEGIN
                                    RAISE NOTICE '[3.3_A08] ehr_name_to_chk[%] ehr_sex[%] ehr_dob[%] ehr_exact_dob[%]', var_ehr_name_to_chk, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob;
                                    RAISE NOTICE '[3.3_A08] pas_name_to_chk[%] pas_sex[%] pas_dob[%] pas_exact_dob[%]', var_pas_name_to_chk, var_pas_sex, var_pas_dob, var_pas_exact_dob_ehr;
                                END;
                            END IF;
                            /* 3.3.1   --- ehr patient found without MK Checking */

                            IF EXISTS (SELECT
                                1
                                FROM ehr_patient_list
                                WHERE ehr_number = var_ehr_no) THEN
                                SELECT
                                    '1'
                                    INTO var_evt_ack;
                            /* ehr patient found (without MK checking) */
                            ELSE
                                SELECT
                                    '2'
                                    INTO var_evt_ack;
                            END IF;
                            /* ehr patient NOT found */
                            SELECT
                                'DDR', 'S'
                                INTO var_ehr_flag, var_evt_final_status;
                            /* DM completed */
                            /* BEGIN TRAN here ...-------- */
                            
                            /* --if @@trancount = 0 */
                            BEGIN
                                /*
                                [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                                begin tran
                                */
                                SELECT
                                    'Y'
                                    INTO var_begin_tran;
                            END;
                            /* eHR patient Found (without MK checking)--> update as 'DDR'  -- */

                            IF var_evt_ack = '1' THEN
                                BEGIN
                                    BEGIN
                                        UPDATE ehr_patient_list
                                        SET ehr_flag = var_ehr_flag,
                                        /* Dead patient */
                                        evt_ack = var_evt_ack,
                                        /* --------Death info -------------- */
                                        ehr_death_date = var_ehr_death_date, ehr_death_time = var_ehr_death_time, ehr_exact_death = var_ehr_exact_death, ehr_death_ind = var_ehr_death_ind,
                                        /* --------------------------------- */
                                        upd_by = var_upd_by, upd_sys = var_upd_sys, upd_dtm = var_upd_dtm, sys_dtm = var_cur_sys_dtm
                                            WHERE ehr_number = var_ehr_no;
                                        var_rtn_err_code := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                var_rtn_err_code := 1;
                                    END;

                                    IF var_rtn_err_code != 0 THEN
                                        BEGIN
                                            SELECT
                                                5
                                                INTO var_failure_code;
                                            /* system failed -SKIP Record */
                                            SELECT
                                                500023
                                                INTO var_rtn_err_code;
                                            /* Error Handling the EHR record-SKIP */
                                            SELECT
                                                'U'
                                                INTO var_evt_final_status;
                                            EXIT upd_record_status;
                                        END;
                                    END IF;
                                END;
                            END IF;
                            EXIT notify_ack
                            /* Ack.generation to <ehr_event_out> to EHR/EPR	and create <ehr_event_txn> record -- */
                            ;
                        END;
                    END IF;
                    /* ---------------------------------------------------------------------------------- */
                    /* <Step 3.4> ADT_A47 - Upd Participant Major Keys (Include HKID/Doc.Pair)      -- */
                    
                    /* ---------------------------------------------------------------------------------- */
                    /* 1. if new HKID/Doc.pair <NOT FOUND>, handled in <Step 3.0.3> => MIU/MIE/MIM  -- */
                    /* 2. if new HKID/Doc.pair <FOUND>,     handling here ...                       -- */
                    
                    /* ---------------------------------------------------------------------------------- */
                    /* Purpose: */
                    /* To uniquely and accurately identify the eHR participant and <<update participant major keys>> */
                    /* Data Component : Participant Identity (both Old/New set data) - <PID>=New / <MRG>=Old */
                    /* Rules: */
                    /* Mandatory a)<Date of Death> and <Exact date of deat indicator> */
                    /* Validation on PIN /Functional Info/HL7 Event Type passed in <2.3.3.1>/<2.3.3.2>/<2.3.3.3> */
                    /* Actions: */
                    /* a) Flag the HCP PMI (ehr_patient_list) for this MKC */
                    
                    /* --		a2). and insert new record in <eHR Exp List ?> */
                    /* b) stop uploading deceased paticipants' clinicial data to eHR */
                    /* c) Alert the HCP Frontline users when the paticipant returns to HCP */
                    /* Note:  5 possible eHR_Flag: MKC/MKE/MKM/MES/VAL for ADT_A47 */
                    
                    /* ------------------------------------------------------- */
                    IF var_evt_crt_sys = 'EHR_RCV_WS' AND var_evt_code = 'ADT_A47' THEN
                        BEGIN
                            SELECT
                                'MKC', localtimestamp
                                INTO var_evt_txn_type, var_cur_sys_dtm;
                            /* Major Key Change (include HKID) */
                            /* 3.4.1) - Validation */

                            IF var_ehr_full_name IS NULL OR
                            /* OR @old_ehr_full_name is null  -- optional for full_name */
                            var_ehr_dob IS NULL OR
                            /* OR @old_ehr_dob is null */
                            var_ehr_sex IS NULL OR
                            /* OR @old_ehr_sex is null */
                            var_ehr_exact_dob IS NULL THEN
                                /* OR @old_ehr_exact_dob is null */
                                BEGIN
                                    SELECT
                                        500005
                                        INTO var_rtn_err_code;
                                    /* invalid PIN */
                                    SELECT
                                        'E'
                                        INTO var_evt_final_status;
                                    EXIT upd_record_status;
                                END;
                            END IF;

                            IF par_debug_mode = 'Y' THEN
                                BEGIN
                                    RAISE NOTICE '[3.4_A47] ehr_name_to_chk[%] ehr_sex[%] ehr_dob[%] ehr_exact_dob[%]', var_ehr_name_to_chk, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob;
                                    RAISE NOTICE '[3.4_A47] old_ehr_full_name[%] old_ehr_sex[%] old_ehr_dob[%] old_exact_dob[%]', var_old_ehr_full_name, var_old_ehr_sex, var_old_ehr_dob, var_old_ehr_exact_dob;
                                END;
                            END IF;
                            SELECT
                                ehr_flag, ehr_flag_prev, ehr_flag
                                INTO var_cur_ehr_flag, var_cur_ehr_flag_prev, var_old_ehr_flag
                                FROM ehr_patient_list
                                WHERE ehr_number = var_ehr_no;
                            /* ------------------------------ */
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_row_cnt := sql$rowcount;
                            /* ------------------------------------------------ */
                            /* 3.4.1  ehr patient found */
                            
                            /* ------------------------------------------------ */
                            IF var_row_cnt = 1 THEN
                                BEGIN
                                    /* 20140728 : A47 Should not be happend for WHD/DDR ehr patient -- */
                                    IF var_cur_ehr_flag IN ('WHD', 'DDR') THEN
                                        BEGIN
                                            SELECT
                                                500025
                                                INTO var_rtn_err_code;
                                            /* Invalid A47 MKC event for WHD/DDR patient -- */
                                            SELECT
                                                'E'
                                                INTO var_evt_final_status;
                                            EXIT upd_record_status;
                                        END;
                                    END IF;

                                    IF EXISTS (SELECT
                                        *
                                        FROM move_episode_indicator
                                        WHERE (from_patient_key = var_pas_pky OR to_patient_key = var_pas_pky) AND move_status = 'O') THEN
                                        SELECT
                                            'Y'
                                            INTO var_me_flag;
                                    END IF;
                                    /* MK matching -- */

                                    IF var_ehr_sex <> var_pas_sex OR var_ehr_name_to_chk <> var_pas_name_to_chk OR (var_ehr_exact_dob = 'EDMY' AND var_ehr_dob <> var_pas_dob) OR (var_ehr_exact_dob = 'EY' AND var_ehr_dob_year <> var_pas_dob_year) OR (var_ehr_exact_dob = 'EMY' AND var_ehr_dob_year <> var_pas_dob_year) THEN
                                        BEGIN
                                            /* MK NOT matched  -- */
                                            SELECT
                                                '3'
                                                INTO var_evt_ack;

                                            IF var_me_flag = 'Y' THEN
                                                SELECT
                                                    'MKM'
                                                    INTO var_ehr_flag;
                                            /* Major Keys Not matched with ME */
                                            ELSE
                                                BEGIN
                                                    IF var_cur_ehr_flag IN ('MKP', 'MKU') OR (var_cur_ehr_flag = 'MKM' AND var_cur_ehr_flag_prev IN ('MKP', 'MKU')) THEN /* ---MK changed by HA before.. */
                                                        SELECT
                                                            'MKE'
                                                            INTO var_ehr_flag; /* --(MKE) :MK Changed by HA-PAS_TXN/eHR before and last update by eHR */
                                                    ELSE
                                                        /* 20160225:MKC should be marked for enrollment with 'VAL' ONLY;Should not be marked if enrollment with 'MKD' --> will caused DataUpload Rejection -- */
                                                        BEGIN
                                                            IF var_cur_ehr_flag = 'VAL' THEN
                                                                SELECT
                                                                    'MKC'
                                                                    INTO var_ehr_flag; /* --(MKC) :MK Changed by eHR only */
                                                            ELSE
                                                                SELECT
                                                                    'MKD'
                                                                    INTO var_ehr_flag;
                                                            END IF;
                                                        END;
                                                    END IF;
                                                    /* 20160225 --- */
                                                END;
                                            END IF;
                                        END;
                                    ELSE
                                        /* MK Matched  -- */
                                        BEGIN
                                            IF var_me_flag = 'Y' THEN
                                                SELECT
                                                    'MES', '4'
                                                    INTO var_ehr_flag, var_evt_ack;
                                            /* 3.1.2.3 (MES):MK matched With ME */
                                            ELSE
                                                SELECT
                                                    'VAL', '1'
                                                    INTO var_ehr_flag, var_evt_ack;
                                            END IF
                                            /* 3.1.2.4 (VAL):MK matched without ME */
                                            ;
                                        END;
                                    END IF;
                                END;
                            ELSE
                                /* ----------------------------------------------------------------------- */
                                /* 3.4.2  ehr patient NOT in ehr_patient_list : UPD_EHR_LIST->select @rtn_err_code = 500023 (Error Handling the EHR record-SKIP(U status) */
                                
                                /* ----------------------------------------------------------------------- */
                                BEGIN
                                    SELECT
                                        'NID', '2'
                                        INTO var_ehr_flag, var_evt_ack
                                    /* Patient NOT found */
                                    ;
                                END;
                            END IF;
                            SELECT
                                'S'
                                INTO var_evt_final_status; /* ---DM completed */
                            EXIT upd_ehr_lst;
                        END;
                    END IF;
                    /* ---------------------------------------------------------------- */
                    /* <Step 3.5> EXG_EHR_PAS  - 20150126 for ppi_ind/non_ha_ind  -- */
                    
                    /* ---------------------------------------------------------------- */
                    /* 2.1 NON-HA DATA INDICATOR */
                    /* Purpose: */
                    /* In order to facilitate HA request, eHR will generate an indicator to indicate the eHR participant having non-HA clinical data uploaded in eHR. */
                    /* 2.2	PPI PATIENT CONVERTED TO HCR */
                    /* Purpose: */
                    /* In order to facilitate HA request, eHR will generate an indicator to indicate the PPI patient opted to register as a Healthcare recipients (HCR). */
                    
                    /* ------------------------------------------------------- */
                    IF var_evt_crt_sys = 'EHR_EXG_WS' AND var_evt_code = 'EXG_EHR_PAS' THEN
                        BEGIN
                            SELECT
                                'EXG'
                                INTO var_evt_txn_type;
                            SELECT
                                localtimestamp
                                INTO var_cur_sys_dtm;
                            /* 3.5.1) - Validation */

                            IF var_ehr_no IS NULL OR var_ehr_conf_code IS NULL THEN
                                /* --OR @ehr_conf_value is null */
                                BEGIN
                                    SELECT
                                        500005
                                        INTO var_rtn_err_code;
                                    /* invalid PIN */
                                    SELECT
                                        'E'
                                        INTO var_evt_final_status;
                                    EXIT upd_record_status;
                                END;
                            END IF;
                            SELECT
                                ehr_ppi_ind, ehr_non_ha_ind
                                INTO var_ehr_ppi_ind_org, var_ehr_non_ha_ind_org
                                FROM ehr_patient_list
                                WHERE ehr_number = var_ehr_no;
                            /* ------------------------------ */
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_row_cnt := sql$rowcount;

                            IF LTRIM(RTRIM(var_ehr_ppi_ind_org)) = '' THEN
                                SELECT
                                    NULL
                                    INTO var_ehr_ppi_ind_org;
                            END IF;

                            IF LTRIM(RTRIM(var_ehr_non_ha_ind_org)) = '' THEN
                                SELECT
                                    NULL
                                    INTO var_ehr_non_ha_ind_org;
                            END IF;

                            IF par_debug_mode = 'Y' THEN
                                RAISE NOTICE '[3.5_EXG] ehr_number[%] ehr_conf_code[%] ehr_conf_value[%] ehr_ppi_ind_org[%] ehr_non_ha_ind_org[%]', var_ehr_no, var_ehr_conf_code, var_ehr_conf_value, var_ehr_ppi_ind_org, var_ehr_non_ha_ind_org;
                            END IF;
                            /* ------------------------------------------------ */
                            /* 3.5.1  ehr patient found */
                            
                            /* ------------------------------------------------ */
                            IF var_row_cnt <> 1 THEN
                                BEGIN
                                    SELECT
                                        500027
                                        INTO var_rtn_err_code;
                                    /* NO eHR participant Found */
                                    SELECT
                                        'H'
                                        INTO var_evt_final_status;
                                    /* event handled without matched-record */
                                    EXIT upd_record_status;
                                END;
                            END IF;
                            SELECT
                                'S'
                                INTO var_evt_final_status;
                            /* DM completed */
                            EXIT upd_ehr_lst;
                        END;
                    END IF;
                    /* ---------------------------------------------------------------- */
                    /* <Step 3.6> UPD_EHR_LIST                                    -- */
                    
                    /* ---------------------------------------------------------------- */
                    /* 3.6.1 :<ADT_A47>     -HKID/Doc.Pair CHanged but TO_HKID/Doc.Pair NOT found in HA-PMI, MIC/MIM/MIE and keep orginal ehr_pas_xxx info */
                    /* 3.6.2 :<ADT_A47>     -TO_HKID/To_DocPair found in HA-PMI */
                    /* 3.6.3 :<ADT_A28>     -ehr_ppi_ind ='Y' for new enrollment on/after 13-Mar16 */
                    /* 3.6.4 :<EXG_EHR_PAS> -ehr_ppi_ind/ehr_non_ha_ind */
                    
                    /* ---------------------------------------------------------------- */
                END;

                IF par_debug_mode = 'Y' THEN
                    RAISE NOTICE '[UPD_EHR_LST]';
                END IF;
                SELECT
                    var_ehr_txn_dtm, localtimestamp
                    INTO var_evt_crt_dtm, var_cur_sys_dtm;
                /* ----------------------------------------------------------- */
                /* eHR MK NOT allowed to store in HA-PMI for NID patient -- */
                /* but need to ACK ehr with the eHR MK                   -- */
                
                /* ---------------------------------------------------------- */
                IF var_ehr_flag = 'NID' THEN
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_ins_ehr_surname, var_ins_ehr_givenname, var_ins_ehr_full_name, var_ins_ehr_sex, var_ins_ehr_dob, var_ins_ehr_exact_dob, var_ins_ehr_death_date, var_ins_ehr_death_time, var_ins_ehr_exact_death, var_ins_ehr_death_ind;
                /* @ins_ehr_smart_id = null */
                ELSE
                    /* Latest eHR Patient Demo -- */
                    SELECT
                        var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_death_date, var_ehr_death_time, var_ehr_exact_death, var_ehr_death_ind
                        INTO var_ins_ehr_surname, var_ins_ehr_givenname, var_ins_ehr_full_name, var_ins_ehr_sex, var_ins_ehr_dob, var_ins_ehr_exact_dob, var_ins_ehr_death_date, var_ins_ehr_death_time, var_ins_ehr_exact_death, var_ins_ehr_death_ind;
                END IF;
                /* ----------------------------------------- */
                /* BEGIN TRAN here ...-------- */
                
                /* --if @@trancount = 0 */
                BEGIN
                    /*
                    [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                    begin tran
                    */
                    SELECT
                        'Y'
                        INTO var_begin_tran;
                END;
                /* -------------------------------------------------------------------------------- */
                /* 3.6.1: ADT_A47 on Change HKID/Doc.Pair but TO_HKID/Doc.Pair NOT found in HA-PMI */
                
                /* --------------------------------------------------------------------------------- */
                /*
                -- 20180115 : Disable As MI Series Enhancement suspendsion  ------------------------
                if @evt_code='ADT_A47' and @ehr_flag in ('MIC','MIE','MIM')
                begin
                update ehr_patient_list set
                		ehr_hkic     = @ehr_hkic,
                		ehr_doc_type = @ehr_doc_type,
                		ehr_doc_no   = @ehr_doc_no,
                		-- Update eHR-Part with Latest eHR-Patient Demo, NULL if NID Patient --
                		ehr_surname     = @ins_ehr_surname,
                		ehr_givenname   = @ins_ehr_givenname,
                		ehr_full_name   = @ins_ehr_full_name,
                		ehr_sex         = @ins_ehr_sex,
                		ehr_dob         = @ins_ehr_dob,
                		ehr_exact_dob   = @ins_ehr_exact_dob,
                		ehr_death_date  = @ins_ehr_death_date,
                		ehr_death_time  = @ins_ehr_death_time,
                		ehr_exact_death = @ins_ehr_exact_death,
                		ehr_death_ind   = @ins_ehr_death_ind,
                		ehr_smart_id    = @ehr_smart_id,         -- 20171115
                		---------------------------------------------------------------------------------
                		-- 20140705:update pas info which latest dataMatching Snapshot info as well    --
                		---------------------------------------------------------------------------------
                		-- 20161118: Maintain the previous Matched(VAL) PAS-PatientDemo AND TO_HKID/Doc.Pair will not be used (No such record in HA-PMI)
                		---------------------------------------------------------------------------------
                		--pas_hkic = @pas_hkic,
                		--pas_pky = @pas_pky,
                		--pas_surname = @pas_surname,
                		--pas_givenname = @pas_givenname,
                		--pas_full_name = @pas_full_name,
                		--pas_sex = @pas_sex,
                		--pas_dob = @pas_dob,
                		--pas_exact_dob = @pas_exact_dob_ehr,
                		--pas_doc_type =@pas_doc_type,
                		--pas_doc_no = @pas_doc_no,
                		----------------------------
                		ehr_flag = @ehr_flag,
                		evt_ack = @evt_ack,
                		upd_by	= @upd_by,
                		upd_sys	= @upd_sys,
                		upd_dtm = @cur_sys_dtm,
                		sys_dtm	= @cur_sys_dtm
                	WHERE ehr_number = @ehr_no
                
                	select @rtn_err_code = @@error
                	if @rtn_err_code != 0
                	begin
                		select @failure_code  = 5		-- system failed -SKIP Record
                		select @rtn_err_code = 500023	-- Error Handling the EHR record-SKIP
                		select @evt_final_status = 'U'
                		GOTO UPD_RECORD_STATUS
                	end
                
                	GOTO NOTIFY_ACK               -- Ack.generation to ehr_event_out to EHR/EPR
                end
                -- 20180115 : END --
                */
                
                /* ------------------------------------------------------ */
                /* 3.6.2: ADT_A47 and TO_HKID/To_DocPair found in HA-PMI */
                
                /* ------------------------------------------------------ */
                /* if @evt_code='ADT_A47' and @ehr_flag not in ('MIC','MIE','MIM') -- disable on 20180115 -- */
                IF var_evt_code = 'ADT_A47' THEN
                    BEGIN
                        BEGIN
                            UPDATE ehr_patient_list
                            SET ehr_hkic = var_ehr_hkic, ehr_doc_type = var_ehr_doc_type, ehr_doc_no = var_ehr_doc_no,
                            /* Update eHR-Part with Latest eHR-Patient Demo, NULL if NID Patient -- */
                            ehr_surname = var_ins_ehr_surname, ehr_givenname = var_ins_ehr_givenname, ehr_full_name = var_ins_ehr_full_name, ehr_sex = var_ins_ehr_sex, ehr_dob = var_ins_ehr_dob, ehr_exact_dob = var_ins_ehr_exact_dob, ehr_death_date = var_ins_ehr_death_date, ehr_death_time = var_ins_ehr_death_time, ehr_exact_death = var_ins_ehr_exact_death, ehr_death_ind = var_ins_ehr_death_ind, ehr_smart_id = var_ehr_smart_id,
                            /* 20171115 */
                            
                            /* ------------------------------------------------------------------------------ */
                            /* 20140705:update pas info which latest dataMatching Snapshot info as well -- */
                            
                            /* ------------------------------------------------------------------------------ */
                            pas_hkic = var_pas_hkic, pas_pky = var_pas_pky, pas_surname = var_pas_surname, pas_givenname = var_pas_givenname, pas_full_name = var_pas_full_name, pas_sex = var_pas_sex, pas_dob = var_pas_dob, pas_exact_dob = var_pas_exact_dob_ehr, pas_doc_type = var_pas_doc_type, pas_doc_no = var_pas_doc_no,
                            /* ---------------------------- */
                            ehr_flag = var_ehr_flag, evt_ack = var_evt_ack, upd_by = var_upd_by, upd_sys = var_upd_sys, upd_dtm = var_cur_sys_dtm, sys_dtm = var_cur_sys_dtm
                                WHERE ehr_number = var_ehr_no;
                            var_rtn_err_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_rtn_err_code := 1;
                        END;

                        IF var_rtn_err_code != 0 THEN
                            BEGIN
                                SELECT
                                    5
                                    INTO var_failure_code;
                                /* system failed -SKIP Record */
                                SELECT
                                    500023
                                    INTO var_rtn_err_code;
                                /* Error Handling the EHR record-SKIP */
                                SELECT
                                    'U'
                                    INTO var_evt_final_status;
                                EXIT upd_record_status;
                            END;
                        END IF;
                        EXIT notify_ack
                        /* Ack.generation to ehr_event_out to EHR/EPR */
                        ;
                    END;
                END IF;
                /* --------------------------------------- */
                /* 3.6.3: ADT_A28 */
                
                /* --------------------------------------- */
                IF var_evt_code = 'ADT_A28' THEN
                    BEGIN
                        IF EXISTS (SELECT
                            *
                            FROM ehr_patient_list
                            WHERE ehr_number = var_ehr_no) THEN
                            /* For ReJoin ehr */
                            BEGIN
                                /* --------------------------------------------------------------------------------------------------------------- */
                                /* 20161012 : Bugfix for 20160708 version : use orginal ehr_ppi_ind to update ehr_patient_list, NOT default as 'Y' for A28 Event Triggered by 'Knock-door'  --- */
                                
                                /* --------------------------------------------------------------------------------------------------------------- */
                                SELECT
                                    'Y'
                                    INTO var_ehr_ppi_ind_upd;

                                IF var_ehr_msg_no LIKE '%Q' THEN
                                    /* A28 Events created by <knock dorr> with msg_no ending with <Q> and detail in <ehr_pas_txn_polling> */
                                    BEGIN
                                        SELECT
                                            ehr_ppi_ind, crt_dtm
                                            INTO var_ehr_ppi_ind_upd, var_ehr_crt_dtm
                                            FROM ehr_patient_list
                                            WHERE ehr_number = var_ehr_no;

                                        IF var_ehr_crt_dtm >= '20160313' THEN
                                            SELECT
                                                'Y'
                                                INTO var_ehr_ppi_ind_upd;
                                        END IF
                                        /* ppi_ind='Y' for all A28 after 13mar16 */
                                        ;
                                    END;
                                END IF;
                                /* --------------------------------------------------------------------------------------------------------------- */
                                BEGIN
                                    UPDATE ehr_patient_list
                                    SET ehr_hkic = var_ehr_hkic, ehr_start_date = var_ehr_start_date,
                                    /* for ReJoin with new start_date */
                                    ehr_end_date = var_ehr_end_date, ehr_doc_type = var_ehr_doc_type, ehr_doc_no = var_ehr_doc_no,
                                    /* Update eHR-Part with Latest eHR-Patient Demo, NULL if NID Patient -- */
                                    ehr_surname = var_ins_ehr_surname, ehr_givenname = var_ins_ehr_givenname, ehr_full_name = var_ins_ehr_full_name, ehr_sex = var_ins_ehr_sex, ehr_dob = var_ins_ehr_dob, ehr_exact_dob = var_ins_ehr_exact_dob, ehr_death_date = var_ins_ehr_death_date, ehr_death_time = var_ins_ehr_death_time, ehr_exact_death = var_ins_ehr_exact_death, ehr_death_ind = var_ins_ehr_death_ind, ehr_smart_id = var_ehr_smart_id,
                                    /* 20171115 */
                                    
                                    /* ----------------------------------------- */
                                    pas_hkic = var_pas_hkic, pas_pky = var_pas_pky, pas_surname = var_pas_surname, pas_givenname = var_pas_givenname, pas_full_name = var_pas_full_name, pas_sex = var_pas_sex, pas_dob = var_pas_dob, pas_exact_dob = var_pas_exact_dob_ehr, pas_doc_type = var_pas_doc_type, pas_doc_no = var_pas_doc_no,
                                    /* ---------------------------- */
                                    ehr_flag = var_ehr_flag, evt_ack = var_evt_ack, upd_by = var_upd_by, upd_sys = var_upd_sys, upd_dtm = var_cur_sys_dtm, sys_dtm = var_cur_sys_dtm,
                                    /* ehr_ppi_ind = 'Y' 	-- 20160708 : For ReEnrollment participant after 13-Mar16. but produce other issue : Y for NID before 13Mar16 but register in HA after 13Mar16 */
                                    ehr_ppi_ind = var_ehr_ppi_ind_upd
                                        /* default =Y */
                                        WHERE ehr_number = var_ehr_no;
                                    var_rtn_err_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            var_rtn_err_code := 1;
                                END;
                            END;
                        ELSE
                            BEGIN
                                BEGIN
                                    INSERT INTO ehr_patient_list (ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_doc_type, ehr_doc_no, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_death_date, ehr_death_time, ehr_exact_death, ehr_death_ind, pas_hkic, pas_pky, pas_doc_type, pas_doc_no, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, /* pas_death_date, pas_death_time,pas_death_ind, */ ehr_flag, evt_ack, crt_dtm, crt_by, crt_sys, sys_dtm, ehr_ppi_ind, ehr_smart_id)
                                    VALUES (var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_doc_type, var_ehr_doc_no, var_ins_ehr_surname, var_ins_ehr_givenname, var_ins_ehr_full_name, var_ins_ehr_sex, var_ins_ehr_dob, var_ins_ehr_exact_dob, var_ins_ehr_death_date, var_ins_ehr_death_time, var_ins_ehr_exact_death, var_ins_ehr_death_ind, var_pas_hkic, var_pas_pky, var_pas_doc_type, var_pas_doc_no, var_pas_surname, var_pas_givenname, var_pas_full_name, var_pas_sex, var_pas_dob, var_pas_exact_dob_ehr, /* @pas_death_date, @pas_death_time,@pas_death_ind, */ var_ehr_flag, var_evt_ack, var_evt_crt_dtm, var_evt_crt_by, var_evt_crt_sys, var_cur_sys_dtm, 'Y', var_ehr_smart_id);
                                    var_rtn_err_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            var_rtn_err_code := 1;
                                END;
                            END;
                        END IF;

                        IF var_rtn_err_code != 0 THEN
                            BEGIN
                                SELECT
                                    5
                                    INTO var_failure_code;
                                /* system failed -SKIP Record */
                                SELECT
                                    500023
                                    INTO var_rtn_err_code;
                                /* Error Handling the EHR record-SKIP */
                                SELECT
                                    'U'
                                    INTO var_evt_final_status;
                                EXIT upd_record_status;
                            END;
                        END IF;
                        EXIT notify_ack
                        /* Ack.generation to ehr_event_out to EHR/EPR */
                        ;
                    END;
                END IF;
                /* ----------------------------------------- */
                /* 3.6.4:  ehr_ppi_ind/ehr_non_ha_ind  -- */
                
                /* ----------------------------------------- */
                /* SHOULD NOT be trigger Data-Matching Event ? */
                /* 1. because NO OLD ehr data provided for the Update ! ---- */
                /* 2. produce <duplicated DM> which majorkey already matched !-- */
                /* 3. it is not the offical <major key update A47 Event> -- */
                
                /* --------------------------------------- */
                IF var_evt_code = 'EXG_EHR_PAS' AND var_evt_crt_sys = 'EHR_EXG_WS' THEN
                    BEGIN
                        /* eHR CONF_CODE/CONF_VALUE -- */
                        IF var_ehr_conf_code = 'PPI_TO_EHR' THEN
                            SELECT
                                LTRIM(RTRIM(var_ehr_conf_value))
                                INTO var_ehr_ppi_ind;
                        ELSE
                            IF var_ehr_conf_code = 'NON_HA_DATA' THEN
                                SELECT
                                    LTRIM(RTRIM(var_ehr_conf_value))
                                    INTO var_ehr_non_ha_ind;
                            END IF;
                        END IF;
                        /* To void over-write the original value with NULL !!--- */

                        IF (var_ehr_ppi_ind IS NULL) OR (LTRIM(RTRIM(var_ehr_non_ha_ind)) = '') THEN
                            SELECT
                                var_ehr_ppi_ind_org
                                INTO var_ehr_ppi_ind;
                        END IF;

                        IF (var_ehr_non_ha_ind IS NULL) OR (LTRIM(RTRIM(var_ehr_non_ha_ind)) = '') THEN
                            SELECT
                                var_ehr_non_ha_ind_org
                                INTO var_ehr_non_ha_ind;
                        END IF;
                        /* Need to update --- */

                        IF (var_ehr_ppi_ind != var_ehr_ppi_ind_org) OR (var_ehr_non_ha_ind != var_ehr_non_ha_ind_org) THEN
                            BEGIN
                                BEGIN
                                    UPDATE ehr_patient_list
                                    SET ehr_ppi_ind = var_ehr_ppi_ind, ehr_non_ha_ind = var_ehr_non_ha_ind, upd_by = var_upd_by, upd_sys = var_upd_sys, upd_dtm = var_cur_sys_dtm, sys_dtm = var_cur_sys_dtm
                                        WHERE ehr_number = var_ehr_no;
                                    var_rtn_err_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            var_rtn_err_code := 1;
                                END;

                                IF var_rtn_err_code != 0 THEN
                                    BEGIN
                                        SELECT
                                            5
                                            INTO var_failure_code;
                                        /* system failed -SKIP Record */
                                        SELECT
                                            500023
                                            INTO var_rtn_err_code;
                                        /* Error Handling the EHR record-SKIP */
                                        SELECT
                                            'U'
                                            INTO var_evt_final_status;
                                        EXIT upd_record_status;
                                    END;
                                END IF;
                            END;
                        END IF;
                        EXIT notify_ack
                        /* Ack.generation to ehr_event_out to EHR/EPR */
                        ;
                    END;
                END IF;
                /* ----------------------------------------------- */
                /* <Step 4> Acknowledgement and ehr_txn records */
                /* 20150126 : Notification will be generated for eHR/ePR !!! need to confirm with HI */
                
                /* ----------------------------------------------- */
            END;

            IF par_debug_mode = 'Y' THEN
                RAISE NOTICE '[NOTIFY_ACK]';
            END IF;
            /* --if @@trancount = 0 */
            BEGIN
                /*
                [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                begin tran
                */
                SELECT
                    'Y'
                    INTO var_begin_tran;
            END;
            /* ----------------------------------------- */
            /* 4.1: create <ehr_event_txn> record  -- */
            
            /* ----------------------------------------- */
            SELECT
                var_ehr_txn_dtm, localtimestamp
                INTO var_evt_crt_dtm, var_cur_sys_dtm;
            /* --------------------------------------------------- */
            /* ehr_event_txn will be generated for NOT matched Records as well --BUT EPR SHOULD NOT process this event */
            
            /* --------------------------------------------------- */
            BEGIN
                INSERT INTO ehr_event_txn (evt_txn_dtm, evt_txn_type, evt_code, evt_log_type, evt_msg_no, evt_ack, ehr_flag, old_ehr_flag, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, ehr_death_date, ehr_death_time, ehr_exact_death, ehr_death_ind, old_ehr_hkic, old_ehr_surname, old_ehr_givenname, old_ehr_full_name, old_ehr_sex, old_ehr_dob, old_ehr_exact_dob, old_ehr_doc_type, old_ehr_doc_no, pas_hkic, pas_pky, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, upd_by, upd_sys, sys_dtm, ehr_ppi_ind, ehr_non_ha_ind, old_ehr_ppi_ind, old_ehr_non_ha_ind, ehr_smart_id)
                VALUES (var_ehr_txn_dtm, var_evt_txn_type, var_evt_code, 'I', var_ehr_msg_no, var_evt_ack, var_ehr_flag, var_old_ehr_flag, var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_doc_type, var_ehr_doc_no, var_ehr_death_date, var_ehr_death_time, var_ehr_exact_death, var_ehr_death_ind, var_old_ehr_hkic, var_old_ehr_surname, var_old_ehr_givenname, var_old_ehr_full_name, var_old_ehr_sex, var_old_ehr_dob, var_old_ehr_exact_dob, var_old_ehr_doc_type, var_old_ehr_doc_no, var_pas_hkic, var_pas_pky, var_pas_surname, var_pas_givenname, var_pas_full_name, var_pas_sex, var_pas_dob, var_pas_exact_dob_ehr, var_pas_doc_type, var_pas_doc_no, var_upd_by, var_upd_sys, var_cur_sys_dtm, var_ehr_ppi_ind, var_ehr_non_ha_ind, var_ehr_ppi_ind_org, var_ehr_non_ha_ind_org, var_ehr_smart_id);
                var_rtn_err_code := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_rtn_err_code := 1;
            END;

            IF var_rtn_err_code != 0 THEN
                BEGIN
                    SELECT
                        5
                        INTO var_failure_code;
                    /* system failed -SKIP Record */
                    SELECT
                        500023
                        INTO var_rtn_err_code;
                    /* Error Handling the EHR record-SKIP */
                    SELECT
                        'U'
                        INTO var_evt_final_status;
                    EXIT upd_record_status;
                END;
            END IF;
            /* ------------------------------------------------ */
            /* 4.2: ACK generation and TXN record created -- */
            
            /* ----------------------------------------------- */
            /* once eHR received ack.code 1 (MK matched) from HA, eHR will ignore all further Ack code received from HA */
            
            /* ----------------------------------------- */
            IF var_evt_code IN ('ADT_A28', 'ADT_A47') THEN
                BEGIN
                    /* 4.2.1). <eHR ACK> -- */
                    SELECT
                        'I'
                        INTO var_evt_ack_status_ehr;
                    /* 4.2.2). <ePR ACK> -- */

                    IF (var_evt_ack = '1' AND var_ehr_no <> "var_DUMMY_EHR_NO") THEN
                        SELECT
                            'I'
                            INTO var_evt_ack_status_epr;
                    ELSE
                        SELECT
                            'X'
                            INTO var_evt_ack_status_epr;
                    END IF;
                    /* 4.2.3). <Ris ACK> -- */

                    IF (var_evt_ack = '1' AND var_ehr_no <> "var_DUMMY_EHR_NO") THEN
                        SELECT
                            'I'
                            INTO var_evt_ack_status_ris;
                    ELSE
                        SELECT
                            'X'
                            INTO var_evt_ack_status_ris;
                    END IF;
                    /* -------------------------------------------- */
                    /* 20140527 : for A47 MKC from eHR, PAS will reply with A28 with 1-4 Ack code (confirmed with CE)--- */
                    SELECT
                        'ADT_A28'
                        INTO var_ack_evt_code;
                    /* -------------------------------------------- */
                    IF var_ehr_no = "var_DUMMY_EHR_NO" THEN
                        BEGIN
                            SELECT
                                'X'
                                INTO var_evt_ack_status_ehr;
                            SELECT
                                'X'
                                INTO var_evt_ack_status_epr;
                            SELECT
                                'X'
                                INTO var_evt_ack_status_ris;
                        END;
                    END IF;

                    IF var_ack_evt_code = 'ADT_A28' THEN
                        BEGIN
                            BEGIN
                                INSERT INTO ehr_event_out (msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_doc_type, ehr_doc_no, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, sys_dtm)
                                VALUES (var_ehr_msg_no, var_ack_evt_code, var_ehr_txn_dtm, var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_doc_type, var_ehr_doc_no, var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_evt_ack, var_evt_ack_status_ehr, var_evt_ack_status_epr, var_evt_ack_status_ris, var_evt_crt_by, var_evt_crt_sys, var_cur_sys_dtm);
                                var_rtn_err_code := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_rtn_err_code := 1;
                            END;

                            IF var_rtn_err_code != 0 THEN
                                BEGIN
                                    SELECT
                                        5
                                        INTO var_failure_code;
                                    /* system failed -SKIP Record */
                                    SELECT
                                        500023
                                        INTO var_rtn_err_code;
                                    /* Error Handling the EHR record-SKIP */
                                    SELECT
                                        'U'
                                        INTO var_evt_final_status;
                                    EXIT upd_record_status;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            /*
            -- 20180115 : Disable As MI Series Enhancement suspendsion  ------------------------
            ---------------------------------------------------------
            -- 4.3: delete the records for [ehr_pin_change_list] --
            ---------------------------------------------------------
            -- 1. [ehr_pin_change_list] : List on the IdentifyChange Patient (triggered by HA before) --> for HA ReminderMsg ONLY
            -- 2. The patient already remindered/Knock-door in eHR-side, No need to remind again
            -- 3. delete the records from this ehr_pin_change_list directly
            -- 4. Apply for A28/A47/A08/A29 ONLY
            -- 5: NOT apply for EXG_EHR_PAS event
            ---------------------------------------
            if @evt_code in ('ADT_A28','ADT_A47','ADT_A08','ADT_A29') and @evt_code !='EXG_EHR_PAS'
            begin
            	if exists (select * FROM ehr_pin_change_list WHERE ehr_number = @ehr_no)
            	begin
            		delete from ehr_pin_change_list where ehr_number = @ehr_no
            	end
            	-- possible issue: to_hkic already registered as other eHR# --> need to remind what ??
            	-- if exists (select * FROM ehr_pin_change_list WHERE to_hkid = @ehr_hkic)
            	-- begin
            	--	delete from ehr_pin_change_list where to_hkid = @ehr_hkic
            	--end
            end
            -- 20180115 : END -------------------------------
            */
            EXIT upd_record_status;
            /* ----------------------------------------------- */
            /* <Step 5>. Update the handled Event Status -- */
            
            /* ----------------------------------------------- */
        END;

        <<next_record>>
        BEGIN
            SELECT
                localtimestamp
                INTO var_cur_sys_dtm;

            IF par_debug_mode = 'Y' THEN
                RAISE NOTICE '[UPD_RECORD_STATUS]';
            END IF;
            /* --if @@trancount = 0 */
            BEGIN
                /*
                [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
                begin tran
                */
                SELECT
                    'Y'
                    INTO var_begin_tran;
            END;
            /* ---------------------------------------------- */
            /* system error occurred, stop POLL job --- */
            /* the error code  is start FROM 500000 for PAS EHR interfaces job */
            /* 1205 is deadlock	; 2601 is duplicate key, */
            
            /* ---------------------------------------------- */
            IF var_rtn_err_code != 0 AND var_rtn_err_code < 500000 AND var_rtn_err_code != 1205 AND var_rtn_err_code != 2601 THEN
                BEGIN
                    RAISE NOTICE 'ERROR code : %', var_rtn_err_code;
                    SELECT
                        4
                        INTO var_failure_code;
                    SELECT
                        'Y'
                        INTO var_stop_poll;
                    EXIT next_record;
                END;
            END IF;
            /* --------------------------------------------------------------- */
            /* handling record string for log/print */
            
            /* ----------------------------------------------------------- */
            SELECT
                CONCAT(var_ehr_flag, '/', var_evt_ack, '/', LTRIM(RTRIM(var_evt_code)), '/', LTRIM(RTRIM(var_ehr_msg_no)), '/', to_char(var_ehr_txn_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '/', to_char(var_ehr_txn_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), ']eHR[', var_ehr_no, '/', LTRIM(RTRIM(var_ehr_hkic)), '/', LTRIM(RTRIM(var_ehr_doc_type)), ':', LTRIM(RTRIM(var_ehr_doc_no)), '/', var_ehr_name_to_chk, '/', var_ehr_sex, '/', var_ehr_dob, '/', var_ehr_exact_dob, ']PAS[', LTRIM(RTRIM(var_pas_hkic)), '/', LTRIM(RTRIM(var_pas_doc_type)), ':', LTRIM(RTRIM(var_pas_doc_no)), '/', var_pas_name_to_chk, '/', var_pas_sex, '/', var_pas_dob, '/', var_pas_exact_dob_ehr, ']', CAST (var_rtn_err_code AS VARCHAR(8)))
                INTO var_record_str;
            /* ----------------------------------- */
            /* 5.1  update the status */
            
            /* ----------------------------------- */
            
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 1
            */
            UPDATE ehr_event_in
            SET evt_status = var_evt_final_status, evt_upd_by = var_upd_by, evt_upd_sys = var_upd_sys, evt_upd_dtm = var_upd_dtm
                WHERE txn_dtm = var_ehr_txn_dtm AND msg_no = var_ehr_msg_no AND
                /* msg_no unique key for update */
                evt_status = 'I';
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount != 1 THEN
                BEGIN
                    SELECT
                        1
                        INTO var_failure_code;
                    SELECT
                        'Y'
                        INTO var_stop_poll;
                    EXIT next_record;
                END;
            END IF;
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 0
            */
            /* Last event in polled --- */
            IF par_poll_mode = 'A' AND var_failure_code = 0 THEN
                /* ----- Auto-Polling Mode --- */
                BEGIN
                    RAISE NOTICE '-->UPDATE ehr_event_conf.last_poll_dtm=[%]------', var_polled_last_sys_dtm;
                    UPDATE ehr_event_conf
                    SET last_poll_dtm = var_polled_last_sys_dtm
                        WHERE config_id = 1 AND system_id = 'EHR_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
                    /* --- To prevent any Reset Time-Marker */
                    ;
                END;
            END IF;

            IF var_rtn_err_code > 500000 THEN
                /* --- error msg# > 500000 for ehr/pas interfaces */
                SELECT
                    CONCAT('Failed with rtn_err_code[ ', CAST (var_rtn_err_code AS VARCHAR(8)), ']')
                    INTO var_error_msg;
            END IF;
            /* ----------------------------------- */
            /* 5.2  printing the log */
            
            /* ----------------------------------- */
            RAISE NOTICE 'Event[%]-rtn_err_code[%] - [%]', var_evt_final_status, var_rtn_err_code, var_record_str;
            /* ----------------------------------------------- */
            /* <Step 6>. Handle for Next Record */
            
            /* ----------------------------------------------- */
        END;

        IF var_failure_code = 1 THEN
            RAISE NOTICE '---  Update ehr_event_in failure[1]!!! ---';
        ELSE
            IF var_failure_code = 2 THEN
                RAISE NOTICE '---  Update ehr_event_conf  failure[2]!!! ---';
            ELSE
                IF var_failure_code = 4 THEN
                    RAISE NOTICE '--- System  failure!!![4] ---';
                ELSE
                    IF var_failure_code = 5 THEN
                        RAISE NOTICE '--- System  failure!!![5] SKIP the Record---';
                    END IF;
                END IF;
            END IF;
        END IF;
        /* ---------------------------------------------------------- */
        /* Current Record Process completed & COMMIT or ROLLBACK --- */
        
        /* ----------------------------------------------------------- */
        IF var_failure_code > 0 AND var_begin_tran = 'Y' THEN
            BEGIN
                --ROLLBACK;
                raise exception '';
                RAISE NOTICE '---Record ROLLBACK--';
            END;
        ELSE
            IF var_failure_code = 0 AND var_begin_tran = 'Y' THEN
                BEGIN
                    /*
                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                    COMMIT
                    */
                    RAISE NOTICE '---Record COMMIT--';
                END;
            END IF;
        END IF;
        /* -------------------------------------------- */
        /* 20140703 - -SKIP the ehr records with evt_status U-- */
        
        /* -------------------------------------------- */
        IF var_failure_code = 5 THEN
            BEGIN
                /* ------------------------------- */
                /* SKIPT this ehr RECORDS --- */
                
                /* ----------------------------------- */
                
                /*
                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                set rowcount 1
                */
                UPDATE ehr_event_in
                SET evt_status = var_evt_final_status, evt_upd_by = var_upd_by, evt_upd_sys = var_upd_sys, evt_upd_dtm = var_upd_dtm
                    WHERE txn_dtm = var_ehr_txn_dtm AND msg_no = var_ehr_msg_no AND /* ---msg_no unique key for update */ evt_status = 'I';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 1 THEN
                    BEGIN
                        SELECT
                            1
                            INTO var_failure_code;
                        SELECT
                            'Y'
                            INTO var_stop_poll; /* ----STOP POLLING */
                        RAISE NOTICE '---update ehr_event_in.evt_status(U) Failed--';
                    END;
                END IF;
                /* ------------------ */
                /*
                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                set rowcount 0
                */
            END;
        END IF;
        /* ---------------------------------------- */
        IF par_debug_mode = 'Y' THEN
            RAISE NOTICE '[NEXT_RECORD] with Prev Record: faillure_code<%>begin_tan<%> ', var_failure_code, var_begin_tran;
        END IF;
        PERFORM pg_sleep(0) /* ---To protect any unforeseen infinite loop.. */;
    END LOOP;
    /* ---- loop until server is shutdown */
    
    /* -------------------------------------- */
    /* END of -- while (@stop_poll = 'N') */
    
    /* -------------------------------------- */
    IF par_debug_mode = 'Y' THEN
        RAISE NOTICE '[EXIT] END of WHILE-LOOP';
    END IF;
    /* ---------------------------------------------------------- */
    /* ---After handling the records                  ------------ */
    /* --> Update last poll_dtm records for NEXT polling time marker  --- */
    /* ---------------------------------------------------------- */
    IF par_poll_mode = 'A' AND var_failure_code = 0 THEN
        /* ----- Auto-Polling Mode --- */
        BEGIN
            RAISE NOTICE '-->UPDATE ehr_event_conf.last_poll_dtm=[%]------', var_polled_last_sys_dtm;
            UPDATE ehr_event_conf
            SET last_poll_dtm = var_polled_last_sys_dtm
                WHERE config_id = 1 AND system_id = 'EHR_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
            /* --- To prevent any Reset Time-Marker */
            ;
        END;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "ehr_event_polling" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";