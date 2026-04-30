-- DROP PROCEDURE hkpmi.ehr_pas_me_polling(inout int4, in varchar, in timestamp, in timestamp, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_pas_me_polling(INOUT pas_return_code integer, IN par_poll_mode character varying DEFAULT 'A'::character varying, IN par_poll_dtm_in timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_poll_start_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_poll_stop_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_debug_mode character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    /* -------------------------------------------------------- */
    /* --	poll_mode = A, Auto Mode (i.e update ehr_event_conf) */
    /* --	poll_mode = B, Bulk Mode (without update ehr_event_conf) */
    /* ----------------------------------------------------------- */
    /* polling on <hkpmi.move_episode_indicator.update_dtm> -- */
    /* Generate HCP <ADT_A47> event & sent out through <ehr_event_out> */
    /* NOT polling on ehr_patient_list ('WHD','DDR','NID','MID') */
    /* Allowed Backdate Polling Period : 2 days only : To prevent Out-date PAS ME TXN will be triggered to check ---- */
    /* Allowed Time-Range polling Period : 7 days range ME txn records */
    /* Allowed latest ME txn record polled : 1 mins on/before current system_dtm */
    
    /* -------------------------------------------------------- */
    /* 20140919 : Create A28 to ePR if MES changed to VAL -- */
    /* 20141020 : backdate allowed 7 Days */
    /* 20141118 */
    /* 20150921 :@cur_evt_ack_ehr (1-4) */
    /* 20161118 : handle for new flag 'MIC','MIE','MIM','MIU','MIP' */
    /* 20170918 : */
    /* 20180115 : Disable As MI Series Enhancement suspendsion  -- */
    /* 20191023 : Add RIS Support */
    
    /* -------------------------------------------------------- */
    /* move_episode_indicator --- */
    var_me_hosp_code VARCHAR(3);
    var_me_case_no VARCHAR(12);
    var_me_crt_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_me_from_pky VARCHAR(8);
    var_me_to_pky VARCHAR(8);
    var_me_crt_user VARCHAR(12);
    var_me_crt_sys VARCHAR(5);
    var_me_move_status VARCHAR(1);
    var_me_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_me_upd_user VARCHAR(12);
    var_me_upd_sys VARCHAR(5);
    /* ehr_patient_list  ----------- */
    var_from_ehr_no VARCHAR(12);
    var_from_ehr_start_date VARCHAR(8);
    var_from_ehr_end_date VARCHAR(8);
    var_from_ehr_flag VARCHAR(3);
    var_from_ehr_flag_prev VARCHAR(3);
    var_from_new_ehr_flag VARCHAR(3);
    var_from_ehr_hkic VARCHAR(12);
    var_from_ehr_doc_type VARCHAR(6);
    var_from_ehr_doc_no VARCHAR(30);
    var_from_ehr_sex VARCHAR(1);
    var_from_ehr_full_name VARCHAR(100);
    var_from_ehr_surname VARCHAR(40);
    var_from_ehr_givenname VARCHAR(40);
    var_from_ehr_dob VARCHAR(8);
    var_from_ehr_exact_dob VARCHAR(4);
    /* ------------------------------- */
    var_from_ehr_pas_hkic VARCHAR(12);
    var_from_ehr_pas_pky VARCHAR(8);
    var_from_ehr_pas_doc_type VARCHAR(6);
    var_from_ehr_pas_doc_no VARCHAR(30);
    var_from_evt_ack VARCHAR(1);
    var_to_ehr_no VARCHAR(12);
    var_to_ehr_start_date VARCHAR(8);
    var_to_ehr_end_date VARCHAR(8);
    var_to_ehr_flag VARCHAR(3);
    var_to_ehr_flag_prev VARCHAR(3);
    var_to_new_ehr_flag VARCHAR(3);
    var_to_ehr_hkic VARCHAR(12);
    var_to_ehr_doc_type VARCHAR(6);
    var_to_ehr_doc_no VARCHAR(30);
    var_to_ehr_sex VARCHAR(1);
    var_to_ehr_full_name VARCHAR(100);
    var_to_ehr_surname VARCHAR(40);
    var_to_ehr_givenname VARCHAR(40);
    var_to_ehr_dob VARCHAR(8);
    var_to_ehr_exact_dob VARCHAR(4);
    /* --------------------------- */
    var_to_ehr_pas_hkic VARCHAR(12);
    var_to_ehr_pas_pky VARCHAR(8);
    var_to_ehr_pas_doc_type VARCHAR(6);
    var_to_ehr_pas_doc_no VARCHAR(30);
    var_to_evt_ack VARCHAR(1);
    /* ehr_patient_list ----------- */
    var_cur_ehr_no VARCHAR(12);
    var_cur_ehr_start_date VARCHAR(8);
    var_cur_ehr_end_date VARCHAR(8);
    var_cur_ehr_flag VARCHAR(3);
    var_cur_ehr_flag_prev VARCHAR(3);
    var_cur_org_ehr_flag VARCHAR(3);
    var_cur_new_ehr_flag VARCHAR(3);
    var_cur_ehr_hkic VARCHAR(12);
    var_cur_ehr_doc_type VARCHAR(6);
    var_cur_ehr_doc_no VARCHAR(30);
    var_cur_ehr_sex VARCHAR(1);
    var_cur_ehr_full_name VARCHAR(100);
    var_cur_ehr_surname VARCHAR(40);
    var_cur_ehr_givenname VARCHAR(40);
    var_cur_ehr_dob VARCHAR(8);
    var_cur_ehr_exact_dob VARCHAR(4);
    /* ------------------------ */
    var_cur_ehr_pas_hkic VARCHAR(12);
    var_cur_ehr_pas_pky VARCHAR(8);
    var_cur_ehr_pas_doc_type VARCHAR(6);
    var_cur_ehr_pas_doc_no VARCHAR(30);
    var_cur_evt_ack VARCHAR(1);
    var_cur_evt_ack_ehr VARCHAR(1);
    var_row_cnt INTEGER;
    var_max_poll_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Used to set polling period */
    var_max_poll_dtm_allowed TIMESTAMP WITHOUT TIME ZONE;
    /* Used to limit the Upper Bound of polling period */
    var_polled_last_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Used to update ehr_event_conf.last_poll_dtm */
    var_last_polled_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_begin_tran VARCHAR(1);
    var_me_flag VARCHAR(1);
    var_pas_msg_no VARCHAR(20);
    var_pas_msg_no_out VARCHAR(20);
    /* (pas_msg_no_out = pas_msg_no + 'E/P') to address the UniqueKey of ehr_event_out : Clear ME may create A45 + A28 Evt to Ehr/ePr/ --- */
    var_error_msg VARCHAR(255);
    var_record_str VARCHAR(255);
    var_debug_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_debug_str VARCHAR(255);
    var_failure_code INTEGER;
    var_stop_poll VARCHAR(1);
    var_run_flag VARCHAR(1);
    var_rtn_err_code INTEGER;
    var_epr_evt_ack_status VARCHAR(1);
    var_ehr_evt_ack_status VARCHAR(1);
    var_evt_code VARCHAR(15);
    var_evt_ack VARCHAR(1);
    var_upd_by VARCHAR(12);
    var_upd_sys VARCHAR(12);
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_cur_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_from_ehr_txn_flag VARCHAR(1);
    var_to_ehr_txn_flag VARCHAR(1);
    var_from_pky_handled VARCHAR(1);
    var_to_pky_handled VARCHAR(1);
    var_txn_type VARCHAR(3);
    sql$rowcount BIGINT;
    pas_me_txn_csr CURSOR FOR
    SELECT
        hospital_code, case_no, create_dtm, from_patient_key, to_patient_key, create_user, create_system, move_status, update_dtm, update_user, update_system
        FROM move_episode_indicator
        WHERE update_dtm >= par_poll_start_dtm AND update_dtm < par_poll_stop_dtm AND move_status IN ('O', 'C', 'M')
        /* 'S' will not gen A45 to eHR */
        ORDER BY update_dtm NULLS FIRST
    /* Latest system_dtm will be used as last_poll_dtm to update ehr_event_conf.last_poll_dtm */
    ;
BEGIN
    /* ------------------------------ */
    /* Processing ehr patient record (From_PKY or To_PKY)---- */
    
    /* -------------------------------- */
    /* init for System Parm  ----- */
    
    /* ---------------------------------------------- */
    SELECT
        'EHR_POLL_ME', 'PAS_POLL'
        INTO var_upd_by, var_upd_sys;
    SELECT
        NULL
        INTO var_polled_last_sys_dtm;
    SELECT
        'ADT_A45'
        INTO var_evt_code;
    /* ---- 2nd/3rd... Ack.. */
    
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

    IF par_poll_mode = 'B' AND DATE_PART('days', par_poll_stop_dtm::TIMESTAMP, par_poll_start_dtm::TIMESTAMP) > 30 THEN
        BEGIN
            RAISE EXCEPTION '%', format('[EXIT]Invalid poll[B Mode] period(over 30 day) FROM [%s] to [%s]', par_poll_start_dtm, par_poll_stop_dtm) USING ERRCODE := '500018';
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
                WHERE config_id = 4 AND system_id = 'PAS_POLL';
        END;
    END IF;

    IF par_poll_dtm_in IS NULL THEN
        SELECT
            '20140501'
            INTO par_poll_dtm_in;
    END IF;
    /* start dtm of ehr/pas interfaces */
    
    /* ------------------------------------- */
    /* while (@stop_poll = 'N') */
    
    /* -------------------------------------- */
    IF par_debug_mode = 'Y' THEN
        RAISE NOTICE '[<WHILE Loop:  poll_dtm_in =[%] and poll_mode[%] ', par_poll_dtm_in, par_poll_mode;
    END IF;
    /* Non-Stop --- */
    SELECT
        'N'
        INTO var_stop_poll;

    WHILE (var_stop_poll = 'N') LOOP
        /* init for ehr_event record ----- */
        SELECT
            'N'
            INTO var_stop_poll;
        SELECT
            'N'
            INTO var_run_flag;
        SELECT
            localtimestamp
            INTO var_upd_dtm;
        SELECT
            'N'
            INTO var_begin_tran;
        SELECT
            0
            INTO var_failure_code;
        /* ------------------------------------------------------ */
        /* <Step.1> Check <run_flag> with <last_polled_dtm> */
        
        /* --------------------------------------------------- */
        SELECT
            COALESCE(last_poll_dtm, '20140501'), run_flag
            INTO var_last_polled_dtm, var_run_flag
            FROM ehr_event_conf
            WHERE config_id = 4 AND system_id = 'PAS_POLL';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_cnt := sql$rowcount;

        IF (var_row_cnt = 0) THEN
            BEGIN
                RAISE NOTICE '[EXIT]ehr_pas_me_polling : missing the ehr_event_conf.config_id.3 = [%]', var_row_cnt;
                EXIT;
            END;
        END IF;

        IF var_run_flag != 'Y' THEN
            BEGIN
                RAISE NOTICE '[EXIT]ehr_pas_me_polling : the ehr_event_conf.run_flag = [%]', var_run_flag;
                EXIT
                /* Exit Polling for Non-AutoMode polling--- */
                ;
            END;
        END IF;
        /* --------------- */
        SELECT
            localtimestamp
            INTO var_cur_sys_dtm;
        /* ------------------------------------------------------------- */
        /* Allowed latest ME txn record polled : 1 mins on/before current system_dtm */
        
        /* ------------------------------------------------------------- */
        SELECT
            - 1 * INTERVAL '1 minute' + var_cur_sys_dtm::TIMESTAMP
            INTO var_max_poll_dtm_allowed;
        /* ----------------------------------------------------------------- */
        /* Allowed Time-Range polling Period : 7 days range ME txn records */
        
        /* ----------------------------------------------------------------- */
        SELECT
            7 * INTERVAL '1 day' + var_last_polled_dtm::TIMESTAMP
            INTO var_max_poll_dtm;

        IF var_max_poll_dtm > var_max_poll_dtm_allowed THEN
            SELECT
                var_max_poll_dtm_allowed
                INTO var_max_poll_dtm;
        END IF;

        IF par_poll_mode = 'A' THEN
            /* AutoMode -- */
            BEGIN
                SELECT
                    var_last_polled_dtm
                    INTO par_poll_start_dtm;
                SELECT
                    var_max_poll_dtm
                    INTO par_poll_stop_dtm;
            END;
        END IF;
        /* ----------------------------------------------------------------- */
        /* Allowed Backdate Polling Period : 2 days only : To prevent Out-date PAS ME TXN will be triggered to check ---- */
        
        /* ----------------------------------------------------------------- */
        IF 24 * DATE_PART('days', var_cur_sys_dtm::TIMESTAMP - par_poll_start_dtm::TIMESTAMP) + DATE_PART('hours', var_cur_sys_dtm::TIMESTAMP - par_poll_start_dtm::TIMESTAMP) > 168 THEN
            /* 7Day */
            BEGIN
                RAISE EXCEPTION '%', format('[EXIT]Invalid poll period FROM [%s] to [%s] : Exceed 48 Hrs ago', par_poll_start_dtm, par_poll_stop_dtm) USING ERRCODE := '500018';
                pas_return_code := - 4;
                RETURN;
            END;
        END IF;
        /* ------------------------------------------------------ */
        /* <Step.2> Check un-handled move_episode_indicator record */
        
        /* ------------------------------------------------------ */
        
        /* -------------------------------------- */
        /* init for polling record --- */
        
        /* -------------------------------------- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_me_hosp_code, var_me_case_no, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_move_status, var_me_upd_dtm, var_me_upd_user, var_me_upd_sys;
        /* -------------------- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_from_ehr_no, var_from_ehr_flag, var_from_ehr_flag_prev, var_from_ehr_sex, var_from_ehr_full_name, var_from_ehr_dob, var_from_ehr_exact_dob, var_from_ehr_surname, var_from_ehr_givenname, var_from_ehr_doc_type, var_from_ehr_doc_no, var_from_ehr_hkic, var_from_ehr_start_date, var_from_ehr_end_date, var_from_evt_ack;
        SELECT
            NULL, NULL, NULL, NULL
            INTO var_from_ehr_pas_hkic, var_from_ehr_pas_pky, var_from_ehr_pas_doc_type, var_from_ehr_pas_doc_no;
        /* --------------- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_to_ehr_no, var_to_ehr_flag, var_to_ehr_flag_prev, var_to_ehr_sex, var_to_ehr_full_name, var_to_ehr_dob, var_to_ehr_exact_dob, var_to_ehr_surname, var_to_ehr_givenname, var_to_ehr_doc_type, var_to_ehr_doc_no, var_to_ehr_hkic, var_to_ehr_start_date, var_to_ehr_end_date, var_to_evt_ack;
        SELECT
            NULL, NULL, NULL, NULL
            INTO var_to_ehr_pas_hkic, var_to_ehr_pas_pky, var_to_ehr_pas_doc_type, var_to_ehr_pas_doc_no;
        /* --------------- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_cur_ehr_no, var_cur_ehr_flag, var_cur_ehr_flag_prev, var_cur_org_ehr_flag, var_cur_ehr_sex, var_cur_ehr_full_name, var_cur_ehr_dob, var_cur_ehr_exact_dob, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_cur_ehr_hkic, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_evt_ack, var_cur_evt_ack_ehr;
        SELECT
            NULL, NULL, NULL, NULL
            INTO var_cur_ehr_pas_hkic, var_cur_ehr_pas_pky, var_cur_ehr_pas_doc_type, var_cur_ehr_pas_doc_no;
        /* -------------------- */
        SELECT
            'N', NULL, 0, NULL, NULL, NULL, NULL
            INTO var_me_flag, var_evt_ack, var_rtn_err_code, var_pas_msg_no, var_record_str, var_debug_str, var_pas_msg_no_out;

        IF par_debug_mode = 'Y' THEN
            BEGIN
                RAISE NOTICE '----------------- cur_sys_dtm[%] ---------------------------------', var_cur_sys_dtm;
                RAISE NOTICE 'Polling period  : FROM =[%] TO [%] with RUN_FLAG=[%] and  polled_last_sys_dtm[%]', par_poll_start_dtm, par_poll_stop_dtm, var_run_flag, var_polled_last_sys_dtm;
                RAISE NOTICE '-----------------------------------------------------------------------------------------------';
            END;
        END IF;
        /* -------------------------------------------------- */
        OPEN pas_me_txn_csr;
        FETCH pas_me_txn_csr INTO var_me_hosp_code, var_me_case_no, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_move_status, var_me_upd_dtm, var_me_upd_user, var_me_upd_sys;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            <<fetch_next_cursor_reord>>
            BEGIN
                IF par_debug_mode = 'Y' THEN
                    RAISE NOTICE 'OPEN pas_me_txn_csr';
                END IF;
                SELECT
                    var_me_upd_dtm
                    INTO var_polled_last_sys_dtm;
                /* will be used to update ehr_event_conf.last_poll_dtm */
                
                /* --------------------------------------------------------- */
                /* move_episode_indicator Unique Key : <hospital_code + case_no + create_dtm  > */
                /* To ensure NO duplication polling records ! ---- */
                
                /* --------------------------------------------------------- */
                IF EXISTS (SELECT
                    *
                    FROM ehr_event_txn
                    WHERE evt_txn_dtm = var_me_upd_dtm AND upd_hosp = var_me_hosp_code AND pas_case = var_me_case_no AND evt_log_type = 'M') THEN
                    /* --- M: txn created by move_episode_indictor */
                    BEGIN
                        /* ------------------------------- */
                        /* This PAS ME TXN record already handled ! -- */
                        
                        /* ------------------------------- */
                        PERFORM pg_sleep(0);
                        /* To prevent High CPU caused by any infinite loop reason --- */
                        EXIT fetch_next_cursor_reord;
                    END;
                END IF;
                /* ------------------------------------------------------------- */
                /* <Step.2.1>  Check from_pky with eHR participant records -- */
                
                /* ------------------------------------------------------------- */
                SELECT
                    ehr_number, ehr_hkic, ehr_start_date, ehr_end_date, ehr_doc_type, ehr_doc_no, ehr_flag, ehr_flag_prev, ehr_sex, ehr_full_name, ehr_surname, ehr_givenname, ehr_dob, ehr_exact_dob,
                    /* -------------------------- */
                    pas_hkic, pas_pky, pas_doc_type, pas_doc_no, evt_ack
                    INTO var_from_ehr_no, var_from_ehr_hkic, var_from_ehr_start_date, var_from_ehr_end_date, var_from_ehr_doc_type, var_from_ehr_doc_no, var_from_ehr_flag, var_from_ehr_flag_prev, var_from_ehr_sex, var_from_ehr_full_name, var_from_ehr_surname, var_from_ehr_givenname, var_from_ehr_dob, var_from_ehr_exact_dob, var_from_ehr_pas_hkic, var_from_ehr_pas_pky, var_from_ehr_pas_doc_type, var_from_ehr_pas_doc_no, var_from_evt_ack
                    FROM ehr_patient_list
                    WHERE pas_pky = var_me_from_pky AND ehr_flag IN ('MES', 'VAL', 'MKC', 'MKD', 'MKE', 'MKM', 'MKP', 'MKU', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP') AND
                    /* 20161118: handle for new flag MIC/MIE/MIM/MIU/MIP */
                    /* and ehr_flag in ('MES','VAL','MKC','MKD','MKE','MKM','MKP','MKU')  -- NOT need to handle for these WHD/DDR/NID/MID patient -- */
                    COALESCE(upd_dtm, '20140501') <= var_me_upd_dtm
                    /* ONLY allow to process the PAS_TXN which update_after ehr_patient_list.upd_dtm, to prevent update by OLD pas_txn ! */
                    ORDER BY sys_dtm DESC NULLS FIRST;
                /* to retrieve the latest EHR records for Same HKID who may register with different ehr_number ! */
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_row_cnt := sql$rowcount;

                IF var_row_cnt > 0 AND var_from_ehr_pas_pky IS NOT NULL THEN
                    SELECT
                        'Y'
                        INTO var_from_ehr_txn_flag;
                ELSE
                    SELECT
                        'N'
                        INTO var_from_ehr_txn_flag;
                END IF;
                /* ------------------------------------------------------------- */
                /* <Step.2.2>  Check to_pky with eHR participant records -- */
                
                /* ------------------------------------------------------------- */
                SELECT
                    ehr_number, ehr_hkic, ehr_start_date, ehr_end_date, ehr_doc_type, ehr_doc_no, ehr_flag_prev, ehr_flag, ehr_sex, ehr_full_name, ehr_surname, ehr_givenname, ehr_dob, ehr_exact_dob,
                    /* -------------------------- */
                    pas_hkic, pas_pky, pas_doc_type, pas_doc_no, evt_ack
                    INTO var_to_ehr_no, var_to_ehr_hkic, var_to_ehr_start_date, var_to_ehr_end_date, var_to_ehr_doc_type, var_to_ehr_doc_no, var_to_ehr_flag_prev, var_to_ehr_flag, var_to_ehr_sex, var_to_ehr_full_name, var_to_ehr_surname, var_to_ehr_givenname, var_to_ehr_dob, var_to_ehr_exact_dob, var_to_ehr_pas_hkic, var_to_ehr_pas_pky, var_to_ehr_pas_doc_type, var_to_ehr_pas_doc_no, var_to_evt_ack
                    FROM ehr_patient_list
                    WHERE pas_pky = var_me_to_pky AND ehr_flag IN ('MES', 'VAL', 'MKC', 'MKD', 'MKE', 'MKM', 'MKP', 'MKU', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP') AND
                    /* 20161118: handle for new flag MIC/MIE/MIM/MIU/MIP */
                    /* and ehr_flag in ('MES','VAL','MKC','MKD','MKE','MKM','MKP','MKU') ---NOT need to handle for these WHD/DDR/NID/MID patient -- */
                    COALESCE(upd_dtm, '20140501') <= var_me_upd_dtm
                    /* ONLY allow to process the PAS_TXN which update_after ehr_patient_list.upd_dtm, to prevent update by OLD pas_txn ! */
                    ORDER BY sys_dtm DESC NULLS FIRST;
                /* to retrieve the latest EHR records for Same HKID who may register with different ehr_number ! */
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_row_cnt := sql$rowcount;
                /* --set rowcount 0 */
                IF var_row_cnt > 0 AND var_to_ehr_pas_pky IS NOT NULL THEN
                    SELECT
                        'Y'
                        INTO var_to_ehr_txn_flag;
                ELSE
                    SELECT
                        'N'
                        INTO var_to_ehr_txn_flag;
                END IF;
                /* ------------------------------------------------------------------------------------ */
                SELECT
                    CONCAT('debug_str : from_ehr_txn_flag =', var_from_ehr_txn_flag, ' to_ehr_txn_flag=', var_to_ehr_txn_flag)
                    INTO var_debug_str;

                IF par_debug_mode = 'Y' THEN
                    RAISE NOTICE '%', var_debug_str;
                END IF;
                /* ------------------------------------- */
                /* Check Both From_Pky and To_Pky in eHR patient list or not */
                
                /* ------------------------------------- */
                SELECT
                    'N', 'N'
                    INTO var_from_pky_handled, var_to_pky_handled;

                <<chk_from_to>>
                LOOP
                    <<upd_ehr_lst>>
                    BEGIN
                        /* ---------------------------------------- */
                        /* MES/MKM and MKC/MKU/MKE/MKP flag ---- */
                        
                        /* ----------------------------------------- */
                        /* Init ---- */
                        SELECT
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                            INTO var_cur_ehr_no, var_cur_ehr_flag, var_cur_ehr_flag_prev, var_cur_org_ehr_flag, var_cur_ehr_sex, var_cur_ehr_full_name, var_cur_ehr_dob, var_cur_ehr_exact_dob, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_cur_ehr_hkic, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_evt_ack, var_cur_ehr_pas_pky, var_cur_ehr_pas_hkic, var_cur_evt_ack_ehr;
                        /* ----------------------------------------------------- */
                        /* <Step.3.1>  Check from_pky in ehr_patient_list  -- */
                        
                        /* ----------------------------------------------------- */
                        IF var_from_ehr_txn_flag = 'Y' AND var_from_pky_handled = 'N' THEN
                            BEGIN
                                SELECT
                                    'Y'
                                    INTO var_from_pky_handled;
                                SELECT
                                    var_from_ehr_no, var_from_ehr_hkic, var_from_ehr_start_date, var_from_ehr_end_date, var_from_ehr_surname, var_from_ehr_givenname, var_from_ehr_full_name, var_from_ehr_sex, var_from_ehr_dob, var_from_ehr_exact_dob, var_from_ehr_doc_type, var_from_ehr_doc_no, var_from_ehr_flag, var_from_ehr_pas_pky, var_from_ehr_pas_hkic, var_from_ehr_pas_doc_type, var_from_ehr_pas_doc_no
                                    INTO var_cur_ehr_no, var_cur_ehr_hkic, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_full_name, var_cur_ehr_sex, var_cur_ehr_dob, var_cur_ehr_exact_dob, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_cur_org_ehr_flag, var_cur_ehr_pas_pky, var_cur_ehr_pas_hkic, var_cur_ehr_pas_doc_type, var_cur_ehr_pas_doc_no;
                                SELECT
                                    localtimestamp
                                    INTO var_cur_sys_dtm;
                                SELECT
                                    var_cur_sys_dtm
                                    INTO var_upd_dtm;
                                /* ---------------------------------------------- */
                                /* NID/MID/DDR already excluded from the ME TXN polling */
                                
                                /* -------------------------------- */
                                IF var_me_move_status = 'O' THEN
                                    BEGIN
                                        SELECT
                                            'P'
                                            INTO var_cur_evt_ack;
                                        /* 'ME' in-process */

                                        IF var_from_ehr_flag = 'VAL' THEN
                                            SELECT
                                                'MES', '4'
                                                INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                        ELSE
                                            IF var_from_ehr_flag LIKE 'MK%' THEN
                                                SELECT
                                                    'MKM', '3'
                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                            /* --else if @from_ehr_flag like 'MI%'  select @cur_new_ehr_flag ='MIM',@cur_evt_ack_ehr = '2'  -- 20161118 : MIM for all MI? patient -- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                            ELSE
                                                SELECT
                                                    var_cur_org_ehr_flag, var_from_evt_ack
                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                            END IF;
                                        END IF
                                        /* if 'MES' ehr_patient ME again after enrollment --- */
                                        ;
                                    END;
                                ELSE
                                    IF var_me_move_status IN ('M') THEN
                                        /* M: Patient Merged */
                                        BEGIN
                                            SELECT
                                                'C'
                                                INTO var_cur_evt_ack;
                                            /* 'ME' record cleared */

                                            IF var_from_ehr_flag = 'MES' THEN
                                                SELECT
                                                    'VAL', '1'
                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                            ELSE
                                                IF var_from_ehr_flag = 'MKM' THEN
                                                    SELECT
                                                        var_from_ehr_flag_prev, '3'
                                                        INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                /* --else if @from_ehr_flag ='MIM'  select @cur_new_ehr_flag =@from_ehr_flag_prev,@cur_evt_ack_ehr = '2'           -- 20161118 : Restore privious MI?-- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                                ELSE
                                                    SELECT
                                                        var_cur_org_ehr_flag, var_from_evt_ack
                                                        INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                END IF;
                                            END IF /* ---NO change for 'MK%' */;
                                        END;
                                    ELSE
                                        IF var_me_move_status IN ('C') THEN
                                            /* C: DVR completed */
                                            BEGIN
                                                /* Check No other ME records with O status for @cur_ehr_pas_pky  ---- */
                                                IF NOT EXISTS (SELECT
                                                    *
                                                    FROM move_episode_indicator
                                                    WHERE (from_patient_key = var_cur_ehr_pas_pky OR to_patient_key = var_cur_ehr_pas_pky) AND move_status = 'O') THEN
                                                    BEGIN
                                                        SELECT
                                                            'C'
                                                            INTO var_cur_evt_ack;
                                                        /* 'ME' record cleared */

                                                        IF var_from_ehr_flag = 'MES' THEN
                                                            SELECT
                                                                'VAL', '1'
                                                                INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                        ELSE
                                                            IF var_from_ehr_flag = 'MKM' THEN
                                                                SELECT
                                                                    var_from_ehr_flag_prev, '3'
                                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                            END IF;
                                                        END IF;
                                                        /* --else if @from_ehr_flag ='MIM'  select @cur_new_ehr_flag =@from_ehr_flag_prev,@cur_evt_ack_ehr = '2'           -- 20161118 : Restore privious MI?-- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                                        /* --else 						   select @cur_new_ehr_flag = @cur_org_ehr_flag,@cur_evt_ack_ehr = @from_evt_ack   -- NO change for 'MK%'  -- 20190520 : BugFix -- */
                                                    END;
                                                ELSE
                                                    BEGIN
                                                        /* 20190520 : BugFix to << Skip >> this ME Txn (As this participant still have O-outstanding ME records !!! -- */
                                                        /* select @cur_evt_ack = 'C'		-- 'ME' record cleared */
                                                        SELECT
                                                            var_cur_org_ehr_flag, var_from_evt_ack
                                                            INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr
                                                        /* NO change */
                                                        ;
                                                    END;
                                                END IF;
                                            END;
                                        END IF;
                                    END IF;
                                END IF;
                                SELECT
                                    CONCAT('[CHK_FROM_TO.From_pky]: cur_ehr_no = ', var_cur_ehr_no, 'cur_ehr_pas_pky=', var_cur_ehr_pas_pky, ' cur_new_ehr_flag =', var_cur_new_ehr_flag, ' from_ehr_flag =', var_from_ehr_flag)
                                    INTO var_debug_str;

                                IF par_debug_mode = 'Y' THEN
                                    RAISE NOTICE '%', var_debug_str;
                                END IF;
                                EXIT upd_ehr_lst;
                            END;
                        END IF;
                        /* --------------------------------------------------- */
                        /* <Step.3.2>  Check to_pky in ehr_patient_list  -- */
                        
                        /* --------------------------------------------------- */
                        IF var_to_ehr_txn_flag = 'Y' AND var_to_pky_handled = 'N' THEN
                            BEGIN
                                SELECT
                                    'Y'
                                    INTO var_to_pky_handled;
                                SELECT
                                    var_to_ehr_no, var_to_ehr_hkic, var_to_ehr_start_date, var_to_ehr_end_date, var_to_ehr_surname, var_to_ehr_givenname, var_to_ehr_full_name, var_to_ehr_sex, var_to_ehr_dob, var_to_ehr_exact_dob, var_to_ehr_doc_type, var_to_ehr_doc_no, var_to_ehr_flag, var_to_ehr_pas_pky, var_to_ehr_pas_hkic, var_to_ehr_pas_doc_type, var_to_ehr_pas_doc_no
                                    INTO var_cur_ehr_no, var_cur_ehr_hkic, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_full_name, var_cur_ehr_sex, var_cur_ehr_dob, var_cur_ehr_exact_dob, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_cur_org_ehr_flag, var_cur_ehr_pas_pky, var_cur_ehr_pas_hkic, var_cur_ehr_pas_doc_type, var_cur_ehr_pas_doc_no;
                                SELECT
                                    localtimestamp
                                    INTO var_cur_sys_dtm;
                                SELECT
                                    var_cur_sys_dtm
                                    INTO var_upd_dtm;
                                /* ---------------------------------------------- */
                                IF var_me_move_status = 'O' THEN
                                    BEGIN
                                        SELECT
                                            'P'
                                            INTO var_cur_evt_ack; /* ---'ME' in-process */

                                        IF var_to_ehr_flag = 'VAL' THEN
                                            SELECT
                                                'MES', '4'
                                                INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                        ELSE
                                            IF var_to_ehr_flag LIKE 'MK%' THEN
                                                SELECT
                                                    'MKM', '3'
                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                            /* --else if @to_ehr_flag like 'MI%'  select @cur_new_ehr_flag ='MIM',@cur_evt_ack_ehr = '2'  -- 20161118 : MIM for all MI? patient -- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                            ELSE
                                                SELECT
                                                    var_cur_org_ehr_flag, var_to_evt_ack
                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                            END IF;
                                        END IF;
                                    END;
                                ELSE
                                    IF var_me_move_status IN ('M') THEN
                                        /* M: Patient Merged */
                                        BEGIN
                                            SELECT
                                                'C'
                                                INTO var_cur_evt_ack;
                                            /* 'ME' record cleared */

                                            IF var_to_ehr_flag = 'MES' THEN
                                                SELECT
                                                    'VAL', '1'
                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                            ELSE
                                                IF var_to_ehr_flag = 'MKM' THEN
                                                    SELECT
                                                        var_to_ehr_flag_prev, '3'
                                                        INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                /* --else if @to_ehr_flag ='MIM'  select @cur_new_ehr_flag =@to_ehr_flag_prev,@cur_evt_ack_ehr = '2'          -- 20161118 : Restore privious MI?-- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                                ELSE
                                                    SELECT
                                                        var_cur_org_ehr_flag, var_to_evt_ack
                                                        INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                END IF;
                                            END IF
                                            /* NO change for 'MK%' */
                                            ;
                                        END;
                                    ELSE
                                        IF var_me_move_status IN ('C') THEN
                                            /* C: DVR completed */
                                            BEGIN
                                                /* Check No other ME records with O status for @cur_ehr_pas_pky  ---- */
                                                IF NOT EXISTS (SELECT
                                                    *
                                                    FROM move_episode_indicator
                                                    WHERE (from_patient_key = var_cur_ehr_pas_pky OR to_patient_key = var_cur_ehr_pas_pky) AND move_status = 'O') THEN
                                                    BEGIN
                                                        SELECT
                                                            'C'
                                                            INTO var_cur_evt_ack;
                                                        /* 'ME' record cleared */

                                                        IF var_to_ehr_flag = 'MES' THEN
                                                            SELECT
                                                                'VAL', '1'
                                                                INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                        ELSE
                                                            IF var_to_ehr_flag = 'MKM' THEN
                                                                SELECT
                                                                    var_to_ehr_flag_prev, '3'
                                                                    INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr;
                                                            END IF;
                                                        END IF;
                                                        /* --else if @to_ehr_flag ='MIM'  select @cur_new_ehr_flag =@to_ehr_flag_prev,@cur_evt_ack_ehr = '2'           -- 20161118 : Restore privious MI?-- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                                        /* --else 						 select @cur_new_ehr_flag = @cur_org_ehr_flag,@cur_evt_ack_ehr = @to_evt_ack  -- NO change for 'MK%'  -- 20190520 : BugFix -- */
                                                    END;
                                                ELSE
                                                    BEGIN
                                                        /* 20190520 : BugFix to << Skip >> this ME Txn (As this participant still have O-outstanding ME records !!! -- */
                                                        /* --select @cur_evt_ack = 'C'		-- 'ME' record cleared */
                                                        SELECT
                                                            var_cur_org_ehr_flag, var_to_evt_ack
                                                            INTO var_cur_new_ehr_flag, var_cur_evt_ack_ehr
                                                        /* NO change */
                                                        ;
                                                    END;
                                                END IF;
                                            END;
                                        END IF;
                                    END IF;
                                END IF;
                                SELECT
                                    CONCAT('[CHK_FROM_TO.To_pky]: cur_ehr_no = ', var_cur_ehr_no, 'cur_ehr_pas_pky=', var_cur_ehr_pas_pky, ' cur_new_ehr_flag =', var_cur_new_ehr_flag, ' to_ehr_flag =', var_to_ehr_flag)
                                    INTO var_debug_str;

                                IF par_debug_mode = 'Y' THEN
                                    RAISE NOTICE '%', var_debug_str;
                                END IF;
                                EXIT upd_ehr_lst;
                            END;
                        END IF;
                        /* ---------------------------------- */
                        /* BOTH From_pky/To_pky handled -- */
                        
                        /* ---------------------------------- */
                        PERFORM pg_sleep(0);
                        /* To prevent High CPU caused by any infinite loop reason --- */
                        EXIT fetch_next_cursor_reord;
                        /* --------------------------------------------------- */
                        /* <Step.4>  Update ehr_patient_list  -- */
                        
                        /* -------------------------------------------------------------------------------- */
                        /* No Ack needed if No change on eHR_flag and NO ehr_event_txn records        -- */
                        /* 1.) Clear ME flag with 'C' and the patient still have other 'O' ME records -- */
                        /* 2.) clear ME falg with 'C' from 'S', no ACK as well...                     -- */
                        
                        /* -------------------------------------------------------------------------------- */
                    END;

                    <<upd_record_status>>
                    BEGIN
                        <<notify_ack>>
                        BEGIN
                            IF par_debug_mode = 'Y' THEN
                                RAISE NOTICE '[UPD_EHR_LST]';
                            END IF;

                            IF COALESCE(var_cur_new_ehr_flag, 'NULL') <> COALESCE(var_cur_org_ehr_flag, 'NULL') THEN
                                BEGIN
                                    /* BEGIN TRAN here ...-------- */
                                    SELECT
                                        localtimestamp
                                        INTO var_cur_sys_dtm;
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
                                    /* update ehr_patient_list */

                                    BEGIN
                                        UPDATE ehr_patient_list
                                        SET ehr_flag = var_cur_new_ehr_flag, evt_ack = var_cur_evt_ack_ehr, /* --P/C  ---20150921 : 1-4 only */
                                        /* Update for ehr_pas_xxx ----------- */
                                        upd_by = var_upd_by, upd_hosp = var_me_hosp_code, upd_sys = var_upd_sys, upd_dtm = var_upd_dtm, sys_dtm = var_cur_sys_dtm
                                            WHERE ehr_number = var_cur_ehr_no;
                                        var_rtn_err_code := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                var_rtn_err_code := 1;
                                    END;

                                    IF var_rtn_err_code != 0 THEN
                                        BEGIN
                                            RAISE NOTICE 'Update ehr_patient_list with ERROR code : %', var_rtn_err_code;
                                            SELECT
                                                5
                                                INTO var_failure_code; /* ---system failed -SKIP Record */
                                            SELECT
                                                500023
                                                INTO var_rtn_err_code; /* ---Error Handling the EHR record-SKIP */
                                            EXIT upd_record_status;
                                        END;
                                    END IF;
                                    /* Ack.generation to ehr_event_out to EHR/EPR */
                                    EXIT notify_ack;
                                END;
                            END IF;
                            EXIT upd_record_status;
                            /* --------------------------------------------------- */
                            /* <Step.5>  Acknowledgement and ehr_txn records -- */
                            
                            /* --------------------------------------------------- */
                        END;

                        IF par_debug_mode = 'Y' THEN
                            RAISE NOTICE '[NOTIFY_ACK]';
                        END IF;
                        SELECT
                            localtimestamp
                            INTO var_cur_sys_dtm;
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
                        /* pas_msg_no will generated for EVENT_OUT ONLY...msg_no is UniqueKey for EVENT_OUT msg no like: [1404101448-PKY] */
                        SELECT
                            CONCAT(RIGHT(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), 6), SUBSTRING(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), 1, 2), SUBSTRING(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), 4, 2), + '-', LTRIM(RTRIM(var_cur_ehr_pas_pky)))
                            INTO var_pas_msg_no;
                        /* ------------------------------------------- */
                        /* <Step.5.1>  Ack to eHR with A45 Event -- */
                        
                        /* ------------------------------------------- */
                        SELECT
                            CONCAT(RTRIM(var_pas_msg_no), 'E')
                            INTO var_pas_msg_no_out;
                        /* msg_no is UniqueKey */

                        BEGIN
                            INSERT INTO ehr_event_out (msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_doc_type, ehr_doc_no, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, pas_hkic, pas_doc_type, pas_doc_no, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, sys_dtm)
                            VALUES (var_pas_msg_no_out, var_evt_code, var_me_upd_dtm, var_cur_ehr_no, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_ehr_hkic, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_full_name, var_cur_ehr_sex, var_cur_ehr_dob, var_cur_ehr_exact_dob,
                            /* --@cur_ehr_pas_hkic,@cur_ehr_pas_doc_type,@cur_ehr_pas_doc_no,  -- 20180227 : PatientMerge ==> cur_ehr_pas_hkic is BLANK and eHR side Could not handled */
                            var_cur_ehr_hkic, var_cur_ehr_doc_type, var_cur_ehr_pas_doc_no, var_cur_evt_ack, 'I', 'X', 'X', var_upd_by, var_upd_sys, var_cur_sys_dtm);
                            var_rtn_err_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_rtn_err_code := 1;
                        END;

                        IF var_rtn_err_code != 0 THEN
                            BEGIN
                                RAISE NOTICE 'Insert ehr_event_out with ERROR code : %', var_rtn_err_code;
                                SELECT
                                    5
                                    INTO var_failure_code;
                                /* system failed -SKIP Record */
                                SELECT
                                    500023
                                    INTO var_rtn_err_code;
                                /* Error Handling the EHR record-SKIP */
                                EXIT upd_record_status;
                            END;
                        END IF;
                        /* --------------------------------------------------------------------------------------------------- */
                        /* <Step.5.2> Ack to ePR with A28 Event, For MES(during A28)->VAL, need to inform ePR asap to DM -- */
                        
                        /* --------------------------------------------------------------------------------------------------- */
                        IF (var_cur_evt_ack = 'C' AND var_cur_new_ehr_flag = 'VAL') THEN
                            BEGIN
                                SELECT
                                    CONCAT(RTRIM(var_pas_msg_no), 'P')
                                    INTO var_pas_msg_no_out;
                                /* msg_no is UniqueKey */

                                BEGIN
                                    INSERT INTO ehr_event_out (msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_doc_type, ehr_doc_no, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, sys_dtm)
                                    VALUES (var_pas_msg_no_out, 'ADT_A28', var_me_upd_dtm, var_cur_ehr_no, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_ehr_hkic, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_full_name, var_cur_ehr_sex, var_cur_ehr_dob, var_cur_ehr_exact_dob, /* 'C' */ var_cur_evt_ack_ehr, 'X', 'I', 'I', var_upd_by, var_upd_sys, var_cur_sys_dtm);
                                    var_rtn_err_code := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            var_rtn_err_code := 1;
                                END;

                                IF var_rtn_err_code != 0 THEN
                                    BEGIN
                                        RAISE NOTICE 'Insert ehr_event_out with ERROR code : %', var_rtn_err_code;
                                        SELECT
                                            5
                                            INTO var_failure_code;
                                        /* system failed -SKIP Record */
                                        SELECT
                                            500023
                                            INTO var_rtn_err_code;
                                        /* Error Handling the EHR record-SKIP */
                                        EXIT upd_record_status;
                                    END;
                                END IF;
                            END;
                        END IF;
                        /* --------------------------------------------------------------------------------------------------- */
                        /* <Step.5.3>: ehr_event_txn will be generated for NOT matched Records as well --BUT EPR SHOULD NOT process this event */
                        /* evt_txn_dtm + evt_msg_no is Unique Key of ehr_event_txn -- */
                        
                        /* --------------------------------------------------------------------------------------------------- */
                        IF var_cur_evt_ack = 'C' THEN
                            SELECT
                                'MEC'
                                INTO var_txn_type;
                        ELSE
                            SELECT
                                'MEP'
                                INTO var_txn_type;
                        END IF;

                        BEGIN
                            INSERT INTO ehr_event_txn (evt_txn_dtm, evt_txn_type, evt_code, evt_log_type, evt_msg_no, evt_ack, ehr_flag, old_ehr_flag, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hosp, pas_hkic, pas_pky, pas_case, pas_doc_type, pas_doc_no, upd_by, upd_hosp, upd_sys, sys_dtm)
                            VALUES (var_me_upd_dtm, var_txn_type, var_evt_code, 'M', var_pas_msg_no, var_cur_evt_ack, var_cur_new_ehr_flag, var_cur_org_ehr_flag, var_cur_ehr_no, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_ehr_hkic, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_full_name, var_cur_ehr_sex, var_cur_ehr_dob, var_cur_ehr_exact_dob, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_me_hosp_code, var_cur_ehr_pas_hkic, var_cur_ehr_pas_pky, var_me_case_no, var_cur_ehr_pas_doc_type, var_cur_ehr_pas_doc_no, var_me_upd_user, var_me_hosp_code, var_me_upd_sys, var_cur_sys_dtm);
                            var_rtn_err_code := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_rtn_err_code := 1;
                        END;

                        IF var_rtn_err_code != 0 THEN
                            BEGIN
                                RAISE NOTICE 'Insert ehr_event_txn with ERROR code : %', var_rtn_err_code;
                                SELECT
                                    5
                                    INTO var_failure_code;
                                /* system failed -SKIP Record */
                                SELECT
                                    500023
                                    INTO var_rtn_err_code;
                                /* Error Handling the EHR record-SKIP */
                                EXIT upd_record_status;
                            END;
                        END IF;
                        EXIT upd_record_status;
                        /* ----------------------------------------------- */
                        /* <Step.6>. Update the handled Event Status -- */
                        
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
                        /* select @error = @@error */
                        /* the error code  is start from 500000 for PAS EHR interfaces job */
                        /* 1205 is deadlock	; 2601 is deplicate key, it may return by inserting transaction_log */

                        IF var_rtn_err_code != 0 AND var_rtn_err_code < 500000 AND var_rtn_err_code != 1205 AND var_rtn_err_code != 2601 THEN
                            BEGIN
                                RAISE NOTICE 'STOP POLLING due with ERROR code : %', var_rtn_err_code;
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
                            CONCAT('PAS ME TXN=>', var_me_hosp_code, '/', var_me_case_no, '/', var_me_move_status, '/', LTRIM(RTRIM(var_cur_ehr_pas_hkic)), '/', var_cur_ehr_pas_pky, '/', to_char(var_me_upd_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ' ', to_char(var_me_upd_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), '/', 'From_flag[', var_from_ehr_txn_flag, ']To_flag[', var_to_ehr_txn_flag, ']', LTRIM(RTRIM(var_evt_code)), '/', var_txn_type, '/', var_cur_new_ehr_flag, '/', var_evt_ack, '/', var_cur_org_ehr_flag, '/', var_pas_msg_no, '/', 'EHR_PMI=>', var_cur_ehr_no, '/', LTRIM(RTRIM(var_cur_ehr_hkic)), '/', LTRIM(RTRIM(var_cur_ehr_doc_type)), '/', LTRIM(RTRIM(var_cur_ehr_doc_no)), '/', CAST (var_rtn_err_code AS VARCHAR(8)))
                            INTO var_record_str;
                        /* ----------------------------------------------- */
                        /* <Step.6.1>. Update the handled Event Status -- */
                        
                        /* ----------------------------------------------- */
                        /* if @poll_mode = 'A'	 AND @failure_code = 0 ----- Auto-Polling Mode --- */
                        IF par_poll_mode = 'A' AND (var_failure_code = 0 OR var_failure_code = 5) THEN
                            /* ----- Auto-Polling Mode --- */
                            BEGIN
                                RAISE NOTICE '-->[UPD_RECORD_STATUS]UPDATE ehr_event_conf.last_poll_dtm=[%]------', var_polled_last_sys_dtm;
                                UPDATE ehr_event_conf
                                SET last_poll_dtm = var_polled_last_sys_dtm
                                    WHERE config_id = 4 AND system_id = 'PAS_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
                                /* --- To prevent any Reset Time-Marker */
                                ;
                            END;
                        END IF;
                        /* ----------------------------------- */
                        IF var_rtn_err_code > 500000 THEN
                            /* --- error msg# > 500000 for ehr/pas interfaces */
                            SELECT
                                CONCAT('Failed with rtn_err_code[ ', CAST (var_rtn_err_code AS VARCHAR(8)), ']')
                                INTO var_error_msg;
                        END IF;
                        /* ---------------------------------- */
                        /* <Step.6.2>. printing the log -- */
                        
                        /* ---------------------------------- */
                        RAISE NOTICE '[%]', var_record_str;
                        /* ----------------------------------------------- */
                        /* <Step 7>. Handle for Next Record */
                        
                        /* ----------------------------------------------- */
                    END;

                    IF var_failure_code = 1 THEN
                        RAISE NOTICE '---  Update ehr_event_conf failure!!! ---';
                    /* --else if @failure_code = 2	print '---  Update ehr_polling_exp  failure!!! ---' */
                    /* --else if @failure_code = 3	print '---  Update suspend_upload_log failure!!! ---' */
                    ELSE
                        IF var_failure_code = 4 THEN
                            RAISE NOTICE '--- System  failure!!! ---';
                        ELSE
                            IF var_failure_code = 5 THEN
                                RAISE NOTICE '--- System  failure!!![5] SKIP the Record---';
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
                            /* --print 'EXIT: system failure ' */
                            /* --BREAK		---- EXIT */
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
                    EXIT chk_from_to;
                    /* ---------------------------------------------------------- */
                    IF par_debug_mode = 'Y' THEN
                        RAISE NOTICE '[NEXT_RECORD] with Prev Record: faillure_code<%>begin_tan<%> ', var_failure_code, var_begin_tran;
                    END IF;
                    /* -------------------------------------------------- */
                    /* Need to check both from_pky and to_pky for ME txn -- */
                    
                    /* --------------------------------------------------- */
                    PERFORM pg_sleep(0);
                    /* --- To prevent High CPU caused by any infinite loop reason --- */
                    CONTINUE chk_from_to;
                END LOOP;
                /* ----------------------------------- */
                /* NEXT_RECORD */
                
                /* ----------------------------------- */
                /* init for polling record --- */
                
                /* ------------------------------------ */
            END;

            IF par_debug_mode = 'Y' THEN
                RAISE NOTICE 'FETCH_NEXT_CURSOR_REORD:';
            END IF;
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_me_hosp_code, var_me_case_no, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_move_status, var_me_upd_dtm, var_me_upd_user, var_me_upd_sys;
            /* -------------------- */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_from_ehr_no, var_from_ehr_flag, var_from_ehr_flag_prev, var_from_ehr_sex, var_from_ehr_full_name, var_from_ehr_dob, var_from_ehr_exact_dob, var_from_ehr_surname, var_from_ehr_givenname, var_from_ehr_doc_type, var_from_ehr_doc_no, var_from_ehr_hkic, var_from_ehr_start_date, var_from_ehr_end_date, var_from_evt_ack;
            SELECT
                NULL, NULL
                INTO var_from_ehr_pas_hkic, var_from_ehr_pas_pky;
            /* --------------- */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_to_ehr_no, var_to_ehr_flag, var_to_ehr_flag_prev, var_to_ehr_sex, var_to_ehr_full_name, var_to_ehr_dob, var_to_ehr_exact_dob, var_to_ehr_surname, var_to_ehr_givenname, var_to_ehr_doc_type, var_to_ehr_doc_no, var_to_ehr_hkic, var_to_ehr_start_date, var_to_ehr_end_date, var_to_evt_ack;
            SELECT
                NULL, NULL
                INTO var_to_ehr_pas_hkic, var_to_ehr_pas_pky;
            /* --------------- */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_cur_ehr_no, var_cur_ehr_flag, var_cur_ehr_flag_prev, var_cur_org_ehr_flag, var_cur_ehr_sex, var_cur_ehr_full_name, var_cur_ehr_dob, var_cur_ehr_exact_dob, var_cur_ehr_surname, var_cur_ehr_givenname, var_cur_ehr_doc_type, var_cur_ehr_doc_no, var_cur_ehr_hkic, var_cur_ehr_start_date, var_cur_ehr_end_date, var_cur_evt_ack;
            SELECT
                NULL, NULL
                INTO var_cur_ehr_pas_hkic, var_cur_ehr_pas_pky;
            /* -------------------- */
            SELECT
                'N', NULL, 0, NULL, NULL, NULL, NULL
                INTO var_me_flag, var_evt_ack, var_rtn_err_code, var_pas_msg_no, var_record_str, var_debug_str, var_pas_msg_no_out;
            /* --------------------------------------------------------- */
            FETCH pas_me_txn_csr INTO var_me_hosp_code, var_me_case_no, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_move_status, var_me_upd_dtm, var_me_upd_user, var_me_upd_sys;
        END LOOP;
        CLOSE pas_me_txn_csr;
        /* -------------------------------------- */
        /* The polling_period @poll_start_dtm to @poll_stop_dtm completed -- */
        
        /* -------------------------------------- */
        /* Last event in polled : NO Record during polling period --> set polled_last_sys_dtm as poll_stop_dtm  --- */
        /* if @polled_last_sys_dtm is null */
        SELECT
            par_poll_stop_dtm
            INTO var_polled_last_sys_dtm;

        IF par_poll_mode = 'A' AND (var_failure_code = 0 OR var_failure_code = 5) THEN
            /* Auto-Polling Mode --- */
            BEGIN
                /* --print '-->[NEXT_RECORD]UPDATE ehr_event_conf.last_poll_dtm=[%1!] with failure_code[%2!]------',@polled_last_sys_dtm,@failure_code */
                UPDATE ehr_event_conf
                SET last_poll_dtm = var_polled_last_sys_dtm
                    WHERE config_id = 4 AND system_id = 'PAS_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
                /* --- To prevent any Reset Time-Marker */
                ;
            END;
        END IF;

        IF par_debug_mode = 'Y' THEN
            RAISE NOTICE '[NEXT_BATCH_RECORD] with Prev polling period From [%] To [%] and polled_last_sys_dtm[%] ', par_poll_start_dtm, par_poll_stop_dtm, var_polled_last_sys_dtm;
        END IF;

        IF par_poll_mode = 'A' AND (var_failure_code = 0 OR var_failure_code = 5) THEN
            /* Auto-Polling Mode: Sleep and repoll again --- */
            BEGIN
                PERFORM pg_sleep(30);
                CONTINUE
                /* --- Go <Step.1> */
                ;
            END;
        END IF;
        EXIT
        /* --- For non auto-polling mode */
        ;
    END LOOP;
    /* -------------------------------------- */
    /* ----END of -- while (@stop_poll = 'N') */
    
    /* -------------------------------------- */
    IF par_debug_mode = 'Y' THEN
        RAISE NOTICE '[EXIT] END of WHILE-LOOP';
    END IF;
    /* ---------------------------------------------------------------------------------- */
    /* After handling the records                  ------------ */
    /* -> Update last poll_dtm records for NEXT polling time marker  --- */
    
    /* ---------------------------------------------------------- */
    IF par_poll_mode = 'A' AND (var_failure_code = 0 OR var_failure_code = 5) THEN
        /* Auto-Polling Mode --- */
        BEGIN
            /* --print '-->[EXIT]UPDATE ehr_event_conf.last_poll_dtm=[%1!] with failure_code[%2!]------',@polled_last_sys_dtm,@failure_code */
            UPDATE ehr_event_conf
            SET last_poll_dtm = var_polled_last_sys_dtm
                WHERE config_id = 4 AND system_id = 'PAS_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
            /* --- To prevent any Reset Time-Marker */
            ;
        END;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "ehr_pas_me_polling" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";