-- DROP PROCEDURE hkpmi.ehr_pas_txn_polling(inout int4, in varchar, in timestamp, in timestamp, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_pas_txn_polling(INOUT pas_return_code integer, IN par_poll_mode character varying DEFAULT 'A'::character varying, IN par_poll_dtm_in timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_poll_start_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_poll_stop_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_debug_mode character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    /* ---------------------------------------------- */
    /* 1). <HA-PMI Txn> Var : [transaction_log] -- */
    
    /* ---------------------------------------------- */
    var_txn_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_txn_hosp VARCHAR(3);
    var_txn_type VARCHAR(3);
    var_txn_hkid VARCHAR(12);
    var_txn_pky VARCHAR(8);
    var_txn_name VARCHAR(48);
    var_txn_sex VARCHAR(1);
    var_txn_dob TIMESTAMP WITHOUT TIME ZONE;
    var_txn_dob_str VARCHAR(8);
    var_txn_exact_dob VARCHAR(1);
    "var_txn_exact_dob_EDMY" VARCHAR(4);
    /* Re-format as EDMY like ehr_patient_list */
    var_txn_dob_year VARCHAR(4);
    var_txn_dob_month VARCHAR(2);
    var_txn_dob_day VARCHAR(2);
    /* --@txn_death_ind VARCHAR(4), */
    /* --@txn_death_date datetime, */
    var_txn_old_pky VARCHAR(08);
    var_txn_old_hkid VARCHAR(12);
    var_txn_old_name VARCHAR(48);
    var_txn_old_sex VARCHAR(1);
    var_txn_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_txn_upd_by VARCHAR(12);
    var_txn_src_sys VARCHAR(12); /* --char(5) */
    var_txn_doc_code VARCHAR(1);
    var_txn_doc_type VARCHAR(6);
    var_txn_doc_no VARCHAR(30);
    /* ------------------------ */
    var_txn_surname VARCHAR(48);
    var_txn_givenname VARCHAR(48);
    var_txn_case VARCHAR(12);
    var_txn_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* ---------------------------------------------------- */
    /* 2). <eHR Patient List> Var: [ehr_patient_list] -- */
    
    /* ---------------------------------------------------- */
    var_ehr_no VARCHAR(12);
    var_ehr_start_date VARCHAR(8);
    var_ehr_end_date VARCHAR(8);
    var_ehr_flag VARCHAR(3);
    var_ehr_flag_prev VARCHAR(3);
    var_ehr_flag_new VARCHAR(3);
    var_ehr_hkic VARCHAR(12);
    var_ehr_doc_type VARCHAR(6);
    var_ehr_doc_no VARCHAR(30);
    var_ehr_sex VARCHAR(1);
    var_ehr_full_name VARCHAR(100);
    var_ehr_surname VARCHAR(40);
    var_ehr_givenname VARCHAR(40);
    var_ehr_dob VARCHAR(8);
    var_ehr_exact_dob VARCHAR(4);
    var_ehr_dob_year VARCHAR(4);
    var_ehr_dob_month VARCHAR(2);
    var_ehr_dob_day VARCHAR(2);
    /* ---------------------------- */
    var_ehr_pas_hkic VARCHAR(12);
    var_ehr_pas_pky VARCHAR(8);
    var_ehr_pas_surname VARCHAR(48);
    var_ehr_pas_givenname VARCHAR(48);
    var_ehr_pas_full_name VARCHAR(100);
    var_ehr_pas_sex VARCHAR(1);
    var_ehr_pas_dob VARCHAR(8);
    var_ehr_pas_exact_dob VARCHAR(4);
    var_ehr_pas_doc_type VARCHAR(6);
    var_ehr_pas_doc_no VARCHAR(30);
    /* ------------------------------ */
    var_pas_death_date VARCHAR(8);
    var_pas_death_time VARCHAR(10);
    var_pas_exact_death VARCHAR(4);
    var_pas_death_ind VARCHAR(4);
    /* ------------------------------ */
    var_ehr_ppi_ind VARCHAR(1);
    var_ehr_non_ha_ind VARCHAR(1);
    var_ehr_smart_id VARCHAR(20);
    /* ------------------------------------------------------- */
    /* 3). <Polling Job Control> Var : [ehr_event_conf] -- */
    
    /* ------------------------------------------------------- */
    var_max_poll_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Used to set polling period */
    var_max_poll_dtm_allowed TIMESTAMP WITHOUT TIME ZONE;
    /* Used to limit the Upper Bound of polling period */
    var_last_polled_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Used to Start Searching base on previous [ehr_event_conf.last_poll_dtm] */
    var_polled_last_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Used to update [ehr_event_conf.last_poll_dtm] */
    var_run_flag VARCHAR(1);
    /* Y/N */
    var_stop_poll VARCHAR(1);
    /* ---------------------------------- */
    /* 4). Error/Exception Handling -- */
    
    /* ---------------------------------- */
    var_begin_tran VARCHAR(1);
    var_row_cnt INTEGER;
    var_error_msg VARCHAR(255);
    var_record_str VARCHAR(255);
    var_failure_code INTEGER;
    var_rtn_err_code INTEGER;
    var_rtn_code INTEGER;
    var_rtn_msg VARCHAR(255);
    var_debug_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* -------------------------------- */
    /* 5). <Data-Processing> Var/Flag -- */
    
    /* -------------------------------- */
    var_poll_hkid VARCHAR(12);
    var_poll_pky VARCHAR(12);
    /* ----------------------------------- */
    var_pas_name_to_chk VARCHAR(48);
    /* reformat pas_full_name for checking by taking out : <space> <,> from name  and chk the first 48Chars ONLY */
    var_ehr_name_to_chk VARCHAR(48);
    /* --@pas_name_to_chk  varchar(100),	-- reformat pas_full_name for checking by taking out : <space> <,> from name */
    /* --@ehr_name_to_chk  varchar(100),	-- reformat pas_full_name for checking by taking out : <space> <,> from name */
    /* reformat pas_full_name for checking by taking out : <space> <,> from name  and chk the first 48Chars ONLY */
    var_name_post_integer INTEGER;
    var_char_len_to_chk INTEGER;
    /* Check first 48 chars ONly -- */
    var_tmp_char VARCHAR(1);
    var_char_len INTEGER;
    var_txn_doc_type_chk VARCHAR(6);
    var_to_hkid VARCHAR(12);
    var_to_pky VARCHAR(12);
    var_to_hkid_ehr_no VARCHAR(12);
    var_to_hkid_ehr_found VARCHAR(1);
    /* Y/N : TO_HKID with NID/MI? found in ehr_patient_list */
    var_to_hkid_knock_door VARCHAR(1);
    /* ------------------------------------------ */
    /* Y/N */
    var_old_pas_hkic VARCHAR(12);
    var_old_pas_pky VARCHAR(8);
    var_old_pas_doc_type VARCHAR(6);
    var_old_pas_doc_no VARCHAR(30);
    /* ------------------------------------------- */
    var_me_flag VARCHAR(1);
    /* Y/N */
    var_ehr_txn_flag VARCHAR(1);
    /* Y/N */
    var_poll_hkid_ehr_handled VARCHAR(1);
    /* Y/N */
    var_doc_pair_participant VARCHAR(1);
    /* Y/N */
    var_doc_pair_changed VARCHAR(1);
    /* Y/N */
    var_knock_door_triggered VARCHAR(1);
    /* ---------------------------------------------- */
    /* 6). <Result/Output> Var -- */
    
    /* ---------------------------------------------- */
    var_pas_msg_no_prefix VARCHAR(19);
    /* [yymmddhhmm-PKY-] */
    var_pas_msg_no VARCHAR(20);
    /* @pas_msg_no_prefix + "Q-KnockDoor/T-030 with ack/K-030/M-020;031" */
    var_evt_code VARCHAR(15);
    var_ack_notify_flag VARCHAR(1);
    /* Y/N */
    var_evt_ack VARCHAR(1);
    /* 1/2/3/4 */
    var_epr_evt_ack_status VARCHAR(1);
    /* I/X */
    var_ehr_evt_ack_status VARCHAR(1);
    /* I/X */
    var_ris_evt_ack_status VARCHAR(1);
    var_cur_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upd_by VARCHAR(12);
    var_upd_sys VARCHAR(12);
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* ------------------------------------- */
    "var_DUMMY_EHR_NO" VARCHAR(12);
    "var_SIT_flag" VARCHAR(1);
    sql$rowcount BIGINT;
    pas_txn_csr CURSOR FOR
    SELECT
        system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, old_hkid, old_patient_key, update_by, source_system, SUBSTRING(filler, 1, 1), other_doc_no, old_patient_name, old_sex, old_dob, case_no, discharge_dtm
        FROM download_dbo.transaction_log
        WHERE system_dtm >= par_poll_start_dtm AND system_dtm < par_poll_stop_dtm AND hospital_code = update_hospital AND
        /* ignore the txn generated by upload process */
        type IN ('010', '100', '300', '030', '020', '031' /* ,'131','331','211','351' */)
        /* 20170919 : exclude HA-PMI Death Txn */
        ORDER BY system_dtm NULLS FIRST
    /* Latest system_dtm will be used as last_poll_dtm to update <ehr_event_conf.last_poll_dtm> */
    ;
    ehr_write_event_in$refcur_1 refcursor;
BEGIN
    /* ----------------------------------------------------------- */
    /* --	poll_mode = A, Auto Mode (i.e update ehr_event_conf): extract PAS_TXN record polling use : XPKtransaction_log index */
    /* --	poll_mode = B, Bulk Mode (without update ehr_event_conf) */
    /* Usage : <ehr_pas_txn_polling 'B',null,'20170816 10:00','20170816 10:04','Y'>   -- SIT -- */
    /* 1. <update ehr_patient_list set upd_dtm='20170815 15:45',sys_dtm=getdate(),ehr_flag='VAL' where ehr_number='504402972500'> */
    /* 2. <delete from ehr_event_txn where evt_txn_dtm > '20170816 10:00' and evt_txn_dtm <'20170816 10:04' and evt_log_type ='T' and ehr_number='504402972500'> */
    
    /* ------------------------------------------------------------------------------------------------------------- */
    /* Allowed Backdate Polling Period : 1 day only : To prevent Out-date PAS TXN will be triggered to check ---- */
    /* Allowed Time-Range polling Period : 30 mins transaction_log records */
    /* Allowed latest transaction_log record polled : 1 mins on/before transaction_log_control.system_dtm */
    /* No need to handle DDR/WHD patient --- */
    
    /* ------------------------------------------------------------------------------------------------------------- */
    /* POll for '010','100','300','030','020','031','131','331','211','351' only */
    
    /* ----------------------------------------------------------- */
    /* 20140919 : trim space for name checking */
    /* 20141007 : for NID patient with eHR DocPair without HKIC */
    /* 20141013 : same handling for MID/NID - <PAS support to eHR - Internal Progress Meeting 13 Oct 2014> */
    /* 20141016 : for PRD deployment: SELECT @max_poll_dtm_allowed = DATEADD(SECOND, -60, system_dtm) FROM download..transaction_log_control */
    /* for HI-UAT polling: select @max_poll_dtm_allowed = DATEADD(SECOND, -10, @cur_sys_dtm) ---disalbed on/after 17-Oct2014 */
    /* 20141017 : bugfix */
    /* 20150211 : New HA A47 Event to eHR -- */
    /* 20150319 : DUMMY Events :<029438615304> */
    /* 20150609 : remove <ehr_event_outold_pas_xxx> */
    /* 20150703 : [HCP A47} for ehr participant ONLY (ehr_ppi_ind=N) */
    /* 20150723 : 031/020 for NewBorn */
    /* 20150724 : A47 to eHR event NOT enable in Production Now */
    /* 20150730 : BugFix for HCP_A47 flag :SKIP to gen ehr_event_txn records */
    /* 20150824 : <ehr_ppi_ind=Y> --> eHR patient */
    /* 20160109 : 1.bug-fix to handle MKC on NAME/HKID at same time (i.e both 030/031 txn generated)  - ehr_patient_list.upd_dtm will use @txn_sys_dtm instead getdate() -- */
    /* 2.SKIP to create ehr_event_out if @to_hkid_knock_door='Y' : To avoid A47 without ehr-pdemo issues */
    
    /* ------------------------------------- */
    /* 20160218 : Doc.Pair updated in '030' txn : new doc.pair existing in ehr_patient_list.ehr_doc_type/doc_no with NID ==> KnockDoor for DataMatching */
    /* 20160229 : Doc.par updated in '030' txn : for Doc.Pair Matching patient @doc_pair_participant (i.e ehr_hkic is NULL), if PAS doc.pair changed & Don't matched ehr doc.pair ==> De-Link them from VAL to MKU/NID ? */
    /* 20160313 : @HCP_A47_flag='Y' */
    /* 20160805 : remove "-" from name checking and remove HCP_A47_flag */
    /* 20161118 : <020/031/030> - FROM_HKID/FROM_DOC_PAIR : New MIU/MIP/MIM for Change/Merge HKID/Doc.Pair */
    /* : <020/031/030> - TO_HKID/TO_DOC_PAIR  : Knock-door for TO_HKID if TO_HKID in (NID/MID, MIC/MIE/MIU/MIP/MIM) status */
    /* 20170918  : <020/031> - FROM_HKID : New MIU/MIP/MIM for Change/Merge HKID   -- Ignore the IdentityChane for Doc.Pair participant */
    /* 20171115  : ehr_smart_id */
    /* 20180115 : Disable As MI Series Enhancement suspendsion  ------------------------ */
    /* To fix : If pas.doc_pair changed and not matched to ehr.doc_pair        ==> MKU/MKP (i.e lastest changed by HA-PAS) */
    /* : If pas.doc_pair changed and     matched to ehr.doc_pair again  ==> NIL action taken [Step.3.4] */
    /* 20191023 : Add RIS Support */
    /* 20171115 */
    /* Y/N */
    /* Y/N */
    /* I/X */
    
    /* ----------------------------------- */
    /* Y/N */
    
    /* ---------------------------------------------- */
    /* init for System Parm                     -- */
    
    /* ---------------------------------------------- */
    SELECT
        '029438615304', 'N', 'EHR_POLL_TXN', 'PAS_POLL', 48,
        /* Check first 48 chars ONly -- */
        NULL
        INTO "var_DUMMY_EHR_NO", "var_SIT_flag", var_upd_by, var_upd_sys, var_char_len_to_chk, var_polled_last_sys_dtm;
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

    IF par_poll_mode = 'B' AND DATE_PART('days', par_poll_stop_dtm::TIMESTAMP, par_poll_start_dtm::TIMESTAMP) > 1 THEN
        BEGIN
            RAISE EXCEPTION '%', format('[EXIT]Invalid poll[B Mode] period(over 1 day) FROM [%s] to [%s]', par_poll_start_dtm, par_poll_stop_dtm) USING ERRCODE := '500018';
            pas_return_code := - 3;
            RETURN;
        END;
    END IF;
    /* Auto-Mode -- */

    IF par_poll_mode = 'A' THEN
        BEGIN
            SELECT
                COALESCE(last_poll_dtm, '20140501')
                INTO par_poll_dtm_in
                FROM ehr_event_conf
                WHERE config_id = 3 AND system_id = 'PAS_POLL';
        END;
    END IF;

    IF par_poll_dtm_in IS NULL THEN
        SELECT
            '20140501'
            INTO par_poll_dtm_in;
    END IF;
    /* --- start dtm of ehr/pas interfaces */
    
    /* -------------------------------------- */
    IF par_debug_mode = 'Y' THEN
        RAISE NOTICE '[<WHILE Loop:  poll_dtm_in =[%] and poll_mode[%] ', par_poll_dtm_in, par_poll_mode;
    END IF;
    /* ----------------------- */
    /* Non-Stop polling -- */
    
    /* ----------------------- */
    SELECT
        'N'
        INTO var_stop_poll;

    WHILE (var_stop_poll = 'N') LOOP
        /* init for ehr_event record -- */
        SELECT
            'N'
            INTO var_stop_poll;
        SELECT
            'N'
            INTO var_run_flag;
        SELECT
            'N'
            INTO var_begin_tran;
        SELECT
            0
            INTO var_failure_code;
        SELECT
            localtimestamp
            INTO var_cur_sys_dtm;
        /* ------------------------------------------------------ */
        /* <Step.1> Check <run_flag> with <last_polled_dtm> */
        
        /* ------------------------------------------------------ */
        SELECT
            COALESCE(last_poll_dtm, '20140501'), COALESCE(run_flag, 'N')
            INTO var_last_polled_dtm, var_run_flag
            FROM ehr_event_conf
            WHERE config_id = 3 AND system_id = 'PAS_POLL';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_cnt := sql$rowcount;

        IF (var_row_cnt = 0) THEN
            BEGIN
                RAISE NOTICE '[EXIT]ehr_pas_txn_polling : missing the ehr_event_conf.config_id.3 = [%]', var_row_cnt;
                EXIT;
            END;
        END IF;

        IF var_run_flag != 'Y' THEN
            BEGIN
                RAISE NOTICE '[EXIT]ehr_pas_txn_polling : the ehr_event_conf.run_flag = [%]', var_run_flag;
                EXIT /* ---Exit Polling for Non-AutoMode polling--- */;
            END;
        END IF;
        /* ------------------------------------------------------------- */
        /* Allowed latest transaction_log record polled : 1 mins on/before transaction_log_control.system_dtm */
        
        /* ------------------------------------------------------------- */
        SELECT
            - 60 * INTERVAL '1 second' + system_dtm::TIMESTAMP
            INTO var_max_poll_dtm_allowed
            FROM download_dbo.transaction_log_control;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount != 1 THEN
            BEGIN
                RAISE EXCEPTION '[EXIT] Record of transaction_log_control not equal to 1' USING ERRCODE := '999999';
                pas_return_code := 100;
                RETURN;
            END;
        END IF;
        /* ------------------------------------------- */
        /* !!! FOR SIT ONLY !!! --- */
        
        /* ------------------------------------------- */
        -- SELECT
        --     'Y'
        --     INTO "var_SIT_flag";
        /* ------------------------------------------- */
        /* --if @SIT_flag ='Y'   select @max_poll_dtm_allowed = DATEADD(SECOND, -120, @cur_sys_dtm) */
        IF "var_SIT_flag" = 'Y' THEN
            SELECT
                - 60 * INTERVAL '1 second' + var_cur_sys_dtm::TIMESTAMP
                INTO var_max_poll_dtm_allowed;
        END IF;
        /* ------------------------------------------------------------------------- */
        /* Allowed Time-Range polling Period : 30 mins transaction_log records -- */
        
        /* ------------------------------------------------------------------------- */
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
                SELECT
                    var_last_polled_dtm
                    INTO par_poll_start_dtm;
                SELECT
                    var_max_poll_dtm
                    INTO par_poll_stop_dtm;
            END;
        END IF;
        /* ------------------------------------------------------------------------------------------------------------- */
        /* Allowed Backdate Polling Period : 100 day only : To prevent Out-date PAS TXN will be triggered to check -- */
        
        /* ------------------------------------------------------------------------------------------------------------- */
        IF 24 * DATE_PART('days', var_cur_sys_dtm::TIMESTAMP - par_poll_start_dtm::TIMESTAMP) + DATE_PART('hours', var_cur_sys_dtm::TIMESTAMP - par_poll_start_dtm::TIMESTAMP) > 2400 THEN
            BEGIN
                RAISE EXCEPTION '%', format('[EXIT]Invalid poll[B Mode] period FROM [%s] to [%s]', par_poll_start_dtm, par_poll_stop_dtm) USING ERRCODE := '500018';
                pas_return_code := - 4;
                RETURN;
            END;
        END IF;
        /* ------------------------------------------------------------------------------------- */
        /* <Step.2> Check any <download..transaction_log> record need to be further handle -- */
        
        /* ------------------------------------------------------------------------------------- */
        
        /* --------------------------------- */
        /* init for the polling record -- */
        
        /* --------------------------------- */
        /* 1). <HA-PMI Txn> Var : [transaction_log] -- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_txn_sys_dtm, var_txn_hosp, var_txn_type, var_txn_name, var_txn_sex, var_txn_dob, var_txn_dob_str, var_txn_exact_dob, "var_txn_exact_dob_EDMY";
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_txn_hkid, var_txn_pky, var_txn_case, var_txn_upd_by, var_txn_src_sys, var_txn_doc_code, var_txn_doc_type, var_txn_doc_no, var_txn_discharge_dtm;
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_txn_old_hkid, var_txn_old_pky, var_txn_old_name, var_txn_old_sex, var_txn_old_dob;
        /* 2). <eHR Patient List> Var: [ehr_patient_list] -- */
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_doc_type, var_ehr_doc_no, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_surname, var_ehr_givenname, var_ehr_full_name;
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_ehr_pas_hkic, var_ehr_pas_pky, var_ehr_pas_doc_type, var_ehr_pas_doc_no, var_ehr_pas_sex, var_ehr_pas_dob, var_ehr_pas_exact_dob, var_ehr_pas_surname, var_ehr_pas_givenname, var_ehr_pas_full_name;
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_ehr_flag, var_ehr_flag_prev, var_ehr_flag_new, var_ehr_ppi_ind, var_ehr_non_ha_ind, var_ehr_smart_id;
        /* 3). <Data-Processing> Var -- */
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_poll_hkid, var_poll_pky, var_to_hkid, var_to_pky, var_to_hkid_ehr_no;
        SELECT
            NULL, NULL, NULL, NULL
            INTO var_old_pas_hkic, var_old_pas_pky, var_old_pas_doc_type, var_old_pas_doc_no;
        SELECT
            NULL, NULL, NULL, NULL, NULL, NULL
            INTO var_txn_dob_year, var_txn_dob_month, var_txn_dob_day, var_ehr_dob_year, var_ehr_dob_month, var_ehr_dob_day;
        SELECT
            NULL, NULL, NULL, NULL, NULL
            INTO var_pas_name_to_chk, var_ehr_name_to_chk, var_tmp_char, var_char_len, var_txn_doc_type_chk;
        SELECT
            NULL, NULL, NULL, NULL
            INTO var_pas_death_date, var_pas_death_time, var_pas_exact_death, var_pas_death_ind;
        /* 4). <Result/Output> Var -- */
        SELECT
            NULL, NULL, 0, 0, NULL
            INTO var_evt_ack, var_pas_msg_no, var_rtn_err_code, var_row_cnt, var_record_str;
        /* 5). <Polling Job Control Flag> Var -- */
        SELECT
            NULL, NULL, NULL
            INTO var_ack_notify_flag, var_doc_pair_participant, var_doc_pair_changed;
        SELECT
            'N', 'N', 'N', 'N', 'N', 'N'
            INTO var_ehr_txn_flag, var_me_flag, var_poll_hkid_ehr_handled, var_to_hkid_ehr_found, var_to_hkid_knock_door, var_knock_door_triggered;
        /* -------------------------------------------------------------------------------------------------------------------- */
        IF par_debug_mode = 'Y' THEN
            BEGIN
                RAISE NOTICE '----------------- cur_sys_dtm[%] ----------------------', var_cur_sys_dtm;
                RAISE NOTICE 'Polling period  : FROM =[%] TO [%] with RUN_FLAG=[%] and  polled_last_sys_dtm[%]', par_poll_start_dtm, par_poll_stop_dtm, var_run_flag, var_polled_last_sys_dtm;
                RAISE NOTICE '------------------------------------------------------------------------------------';
            END;
        END IF;
        /* -------------------------------------------------- */
        OPEN pas_txn_csr;
        FETCH pas_txn_csr INTO var_txn_sys_dtm, var_txn_hosp, var_txn_type, var_txn_hkid, var_txn_pky, var_txn_name, var_txn_sex, var_txn_dob, var_txn_exact_dob, var_txn_old_hkid, var_txn_old_pky, var_txn_upd_by, var_txn_src_sys, var_txn_doc_code, var_txn_doc_no, var_txn_old_name, var_txn_old_sex, var_txn_old_dob, var_txn_case, var_txn_discharge_dtm;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            <<fetch_next_cursor_reord>>
            BEGIN
                IF par_debug_mode = 'Y' THEN
                    RAISE NOTICE '[Step.2.0] pas_txn_csr fetch-record[%.%.%.%]', var_txn_sys_dtm, var_txn_type, var_txn_hkid, var_txn_old_hkid;
                END IF;
                SELECT
                    var_txn_sys_dtm
                    INTO var_polled_last_sys_dtm;
                /* will be used to update <ehr_event_conf.last_poll_dtm> */
                
                /* -------------------------------------------------------------------------------------------------------------- */
                /* <transaction_log> Unique Key : <system_dtm + hospital_code > : To ensure NO duplicated polling records ! -- */
                
                /* -------------------------------------------------------------------------------------------------------------- */
                IF EXISTS (SELECT
                    *
                    FROM ehr_event_txn
                    WHERE evt_txn_dtm = var_txn_sys_dtm AND upd_hosp = var_txn_hosp AND evt_log_type = 'T') THEN
                    /* 'T': txn created by transaction_log */
                    BEGIN
                        IF par_debug_mode = 'Y' THEN
                            RAISE NOTICE '[Step.2.0] pas_txn_csr fetch-record already Handled[ehr_event_txn] ! [%.%.%.%]', var_txn_sys_dtm, var_txn_type, var_txn_hkid, var_txn_old_hkid;
                        END IF;
                        /* ------------------------------------------- */
                        /* This PAS TXN record already handled ! -- */
                        
                        /* ------------------------------------------- */
                        PERFORM pg_sleep(0);
                        /* To prevent High CPU caused by any infinite loop reason -- */
                        EXIT fetch_next_cursor_reord;
                    END;
                END IF;
                /* --------------------------------------------- */
                SELECT
                    document_type
                    INTO var_txn_doc_type
                    FROM document_type
                    WHERE document_code = var_txn_doc_code;
                /* ------------------------------------------ */
                /* EHR/PAS Doc type mapping -- */
                /* 1. AR --> AR(2)/AE(O)/AN(P) -- */
                /* 2. BC --> BC(3)/BE(Q)/BN(R) -- */
                
                /* ---------------------------------------- */
                SELECT
                    var_txn_doc_type
                    INTO var_txn_doc_type_chk;

                IF var_txn_doc_type IN ('AR', 'AE', 'AN') THEN
                    SELECT
                        'AR'
                        INTO var_txn_doc_type_chk;
                END IF;

                IF var_txn_doc_type IN ('BC', 'BE', 'BN') THEN
                    SELECT
                        'BC'
                        INTO var_txn_doc_type_chk;
                END IF;
                /* ------------------------------------------------------------------------------------------------- */
                /* [Step 2.1]. Format the TXN HKID :check with <ehr_patient_list> to determine further action take or NOT */
                
                /* ------------------------------------------------------------------------------------------------- */
                /* [2.1.1] :<@poll_hkid> */
                /* [2.1.2] :<@to_hkid/@to_hkid_ehr_no> if 020/031 with NID/MI? */
                
                /* ------------------------------------------------------------------------------------------------- */
                IF var_txn_type IN ('100', '300', '010', '030', '131', '331', '211', '351') THEN
                    BEGIN
                        SELECT
                            var_txn_hkid, var_txn_pky
                            INTO var_poll_hkid, var_poll_pky;
                    END;
                END IF;

                IF var_txn_type IN ('020', '031') THEN
                    BEGIN
                        SELECT
                            var_txn_old_hkid, var_txn_old_pky
                            INTO var_old_pas_hkic, var_old_pas_pky;
                        /* ------------------------------------------------------------------------------------------ */
                        /* 1). Check FROM_HKID in ehr_patient_list --> set to 'MIU/MIP/MKM' flag (MID obsolete) -- */
                        
                        /* ------------------------------------------------------------------------------------------ */
                        SELECT
                            var_txn_old_hkid, var_txn_old_pky
                            INTO var_poll_hkid, var_poll_pky;
                        /* --------------------------------------------------------------------------------------- */
                        /* 2). Check TO_HKID in ehr_patient_list with NID/MI?  --> need to <Knock eHR door>  -- */
                        
                        /* --------------------------------------------------------------------------------------- */
                        SELECT
                            var_txn_hkid, var_txn_pky
                            INTO var_to_hkid, var_to_pky;
                        /*
                        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                        set rowcount 1
                        */
                        SELECT
                            ehr_number
                            INTO var_to_hkid_ehr_no
                            FROM ehr_patient_list
                            WHERE (ehr_hkic = var_to_hkid OR (ehr_doc_no = COALESCE(var_txn_doc_no, 'NULL') AND ehr_doc_type = COALESCE(var_txn_doc_type_chk, 'NULL'))) AND
                            /* 20171115 : check ehr doc.pair as well */
                            ehr_flag IN ('NID', 'MID', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP') AND
                            /* 20161118: new MIC/MIE/MIM/MIU/MIP */
                            COALESCE(upd_dtm, '20140501') <= var_txn_sys_dtm AND
                            /* To prevent update by OLD pas_txn ! */
                            COALESCE(ehr_start_date, '20140501') <= to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AND COALESCE(ehr_end_date, '20990101') >= to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AND ehr_number <> "var_DUMMY_EHR_NO"
                            /* 20150319 */
                            ORDER BY sys_dtm DESC NULLS FIRST;
                        /* to retrieve the latest EHR records for Same HKID who may register with different ehr_number ! */
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_row_cnt := sql$rowcount;

                        IF var_row_cnt > 0 THEN
                            SELECT
                                'Y'
                                INTO var_to_hkid_ehr_found;
                        END IF;
                        /*
                        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                        set rowcount 0
                        */
                    END;
                END IF;
                /* ------------------------------------------------------------------------------------------------------------- */
                /* [Step 2.2] check <poll_hkid> need to be further process or not                                          -- */
                /* <2.2.1>if txn_hkid = pas_hkic with 'MIC/MIE/MIM/MIU/MIP'  => Not need to handle                         -- */
                /* <2.2.2>if txn_hkid = ehr_hkic or txn.Doc.pair = ehr.Doc.Pair with 'MIC/MIE/MIM/MIU/MIP'  => KNOCK_DOOR  -- */
                /* <2.2.3>if 030 and ehr_hkic is null ==> Doc.pair participant then check doc.pair changed or NOT          -- */
                
                /* ------------------------------------------------------------------------------------------------------------- */
                /* !!! Multi-Records WILL be Found if same pas_hkic with different ehr_number (i.e with different ehr_start/end_date) */
                
                /* --------------------------------------------------------------------------------------------------------- */
                
                /*
                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                set rowcount 1
                */
                SELECT
                    ehr_number, ehr_hkic, ehr_start_date, ehr_end_date, ehr_doc_type, ehr_doc_no, ehr_flag, ehr_flag_prev, ehr_sex, ehr_full_name, ehr_surname, ehr_givenname, ehr_dob, ehr_exact_dob, ehr_ppi_ind, ehr_non_ha_ind, ehr_smart_id,
                    /* --------------------------------- */
                    pas_hkic, pas_pky, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no
                    INTO var_ehr_no, var_ehr_hkic, var_ehr_start_date, var_ehr_end_date, var_ehr_doc_type, var_ehr_doc_no, var_ehr_flag, var_ehr_flag_prev, var_ehr_sex, var_ehr_full_name, var_ehr_surname, var_ehr_givenname, var_ehr_dob, var_ehr_exact_dob, var_ehr_ppi_ind, var_ehr_non_ha_ind, var_ehr_smart_id, var_ehr_pas_hkic, var_ehr_pas_pky, var_ehr_pas_surname, var_ehr_pas_givenname, var_ehr_pas_full_name, var_ehr_pas_sex, var_ehr_pas_dob, var_ehr_pas_exact_dob, var_ehr_pas_doc_type, var_ehr_pas_doc_no
                    FROM ehr_patient_list
                    WHERE
                    /* ---------------------------------------------------------------------------------------------------------------- */
                    /* --	<2.2.1> TXN related to eHR participant AND Exlude "Identiry Change Patient" (i.e Patient Should NOT exist in HA-PMI -- */
                    /* ---------------------------------------------------------------------------------------------------------------- */
                    ((pas_hkic = var_poll_hkid /* and ehr_flag not in ('MIC','MIE','MIM','MIU','MIP') */) OR
                    /* ---------------------------------------------------------------------------------------------------------------- */
                    /* <2.2.2> TXN related to 'Knock-door' for New-Registered Patient through "010/100/300/030"(i.e upd Doc.Pair)  -- */
                    
                    /* ---------------------------------------------------------------------------------------------------------------- */
                    /* or ( --pas_hkic is null         -- 20161118 : pas_hkic still exist for MI? ==> ignore to check pas_hkic is null  -- 20180227 : TableScan !! */
                    (pas_hkic IS NULL AND (ehr_hkic = var_poll_hkid OR (ehr_doc_no = COALESCE(var_txn_doc_no, 'NULL') AND ehr_doc_type = COALESCE(var_txn_doc_type_chk, 'NULL'))) AND
                    /* To skip the change on NULL ehr_doc_no */
                    ehr_flag IN ('NID', 'MID', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP') AND var_txn_type IN ('100', '300', '010', '030'))
                    /* 20160202: to handle 030 upd doc.pair as well */
                    ) AND
                    /* ---------------------------------------------------------------------------------------------------------------- */
                    ehr_flag NOT IN ('WHD', 'DDR') AND
                    /* ByPass for WHD/DDR ehr_patient -- */
                    COALESCE(upd_dtm, '20140501') <= var_txn_sys_dtm AND
                    /* ONLY allow to process the PAS_TXN which update_after ehr_patient_list.upd_dtm, to prevent update by OLD pas_txn ! */
                    COALESCE(ehr_start_date, '20140501') <= to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AND COALESCE(ehr_end_date, '20990101') >= to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AND ehr_number <> "var_DUMMY_EHR_NO"
                    /* 20150319 */
                    ORDER BY sys_dtm DESC NULLS FIRST;
                /* To retrieve the latest EHR records for Same HKID who may register with different ehr_number ! */
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_row_cnt := sql$rowcount;
                /*
                [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                set rowcount 0
                */
                IF var_row_cnt > 0 THEN
                    BEGIN
                        SELECT
                            'Y'
                            INTO var_ehr_txn_flag;
                        /* --------------------------------------------------------- */
                        /* <2.2.3> TXN related to Doc.Pair participant or NOT  -- */
                        
                        /* --------------------------------------------------------- */
                        /* 20160229 :030 on Doc.Pair Change (ignore DOc.TYpe change during 100& 300) -- */
                        /* Jul-2016: @doc_pair_participant VALID/in-use for 030 only */
                        
                        /* --------------------------------------------------------- */
                        IF var_ehr_hkic IS NULL AND (var_ehr_doc_type IS NOT NULL AND var_ehr_doc_no IS NOT NULL) AND var_txn_type = '030' THEN
                            BEGIN
                                SELECT
                                    'Y'
                                    INTO var_doc_pair_participant;

                                IF (var_txn_doc_type <> var_ehr_pas_doc_type OR var_txn_doc_no <> var_ehr_pas_doc_no) THEN
                                    BEGIN
                                        SELECT
                                            'Y'
                                            INTO var_doc_pair_changed;
                                    END;
                                END IF;
                            END;
                        END IF;

                        IF par_debug_mode = 'Y' THEN
                            RAISE NOTICE '[Step.2.2].Found eHR -> txn[%].txn_hkid[%].txn_old_hkid[%] => poll_hkid[%].txn_doc[%.%].ehr_no[%].doc_pair_participant[%].doc_pair_changed[%].to_hkid[%0!].to_ehr[%1!]', var_txn_type, var_txn_hkid, var_txn_old_hkid, var_poll_hkid, var_txn_doc_no, var_txn_doc_type_chk, var_ehr_no, var_doc_pair_participant, var_doc_pair_changed, var_to_hkid_ehr_no, var_to_hkid;
                        END IF;
                    END;
                END IF;
                /* --------------------------------------------------------------------------- */
                /* [Step 2.3] check <@to_hkid/@to_hkid_ehr_no> need to be further process or not if 020/031 -- */
                
                /* --------------------------------------------------------------------------- */
                /* BEGIN: 20150723  -- */
                /* 1. FROM_HKID not in ehr_patient_list */
                /* 2. Check TO_HKID  in ehr_patient_list or NOT for NID/MID <knock ehr door>  -- */
                /* ??? 3. need to handle  FROM_HKID in ehr_patient_list and TO_HKID as 'NID/MID' ?? -- */
                /* 20161118: both From/To HKID need to handle for 020/031 ==> pay attn to <ehr_pdemo part> */
                
                /* ----------------------------------------------------------------------------- */
                IF var_ehr_txn_flag != 'Y' AND var_txn_type IN ('020', '031') AND var_to_hkid_ehr_found = 'Y' THEN
                    BEGIN
                        /* ------------------------------------------------------------------------------------ */
                        /* 20161118 "knock-door" for TO_HKID if NID/MID/MIC/MIU/MIM/MIE/MIP and No further action -- */
                        
                        /* ------------------------------------------------------------------------------------ */
                        SELECT
                            var_to_hkid, var_to_pky
                            INTO var_poll_hkid, var_poll_pky;
                        /* TO_HKID as processing PIN */
                        
                        /*
                        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                        set rowcount 1
                        */
                        SELECT
                            ehr_number, ehr_hkic, ehr_start_date, ehr_end_date, ehr_doc_type, ehr_doc_no, ehr_flag, ehr_flag_prev, ehr_sex, ehr_full_name, ehr_surname, ehr_givenname, ehr_dob, ehr_exact_dob, ehr_ppi_ind, ehr_non_ha_ind, ehr_smart_id,
                            /* -------------------------------- */
                            pas_hkic, pas_pky, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no
                            INTO var_ehr_no, var_ehr_hkic, var_ehr_start_date, var_ehr_end_date, var_ehr_doc_type, var_ehr_doc_no, var_ehr_flag, var_ehr_flag_prev, var_ehr_sex, var_ehr_full_name, var_ehr_surname, var_ehr_givenname, var_ehr_dob, var_ehr_exact_dob, var_ehr_ppi_ind, var_ehr_non_ha_ind, var_ehr_smart_id, var_ehr_pas_hkic, var_ehr_pas_pky, var_ehr_pas_surname, var_ehr_pas_givenname, var_ehr_pas_full_name, var_ehr_pas_sex, var_ehr_pas_dob, var_ehr_pas_exact_dob, var_ehr_pas_doc_type, var_ehr_pas_doc_no
                            FROM ehr_patient_list
                            WHERE ehr_number = var_to_hkid_ehr_no AND ehr_flag IN ('NID', 'MID', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP') AND
                            /* KNOCK_DOOR for NID/MI? series ehr_patient -- */
                            COALESCE(upd_dtm, '20140501') <= var_txn_sys_dtm AND
                            /* ONLY allow to process the PAS_TXN which update_after ehr_patient_list.upd_dtm, to prevent update by OLD pas_txn ! */
                            COALESCE(ehr_start_date, '20140501') <= to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AND COALESCE(ehr_end_date, '20990101') >= to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD') AND ehr_number <> "var_DUMMY_EHR_NO";
                        /* 20150319 */
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_row_cnt := sql$rowcount;

                        IF var_row_cnt > 0 THEN
                            BEGIN
                                SELECT
                                    'Y'
                                    INTO var_ehr_txn_flag;
                                SELECT
                                    'Y'
                                    INTO var_to_hkid_knock_door
                                /* 020/031 TO_HKID in ehr_patient_list with NID/MI? -- */
                                ;
                            END;
                        END IF;
                        /*
                        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                        set rowcount 0
                        */
                        IF par_debug_mode = 'Y' THEN
                            RAISE NOTICE '[Step.2.3] Found to_hkid eHR -> txn[%].txn_hkid[%].txn_old_hkid[%] => poll_hkid[%].txn_doc[%.%].ehr_no[%].doc_pair_participant[%].doc_pair_changed[%].to_hkid[%0!].to_ehr[%1!]', var_txn_type, var_txn_hkid, var_txn_old_hkid, var_poll_hkid, var_txn_doc_no, var_txn_doc_type_chk, var_ehr_no, var_doc_pair_participant, var_doc_pair_changed, var_to_hkid_ehr_no, var_to_hkid;
                        END IF;
                    END;
                END IF;
                /* --------------------------------------------------------------- */
                /* NO eHR participant related PAS TXN --> processing next record -- */
                
                /* --------------------------------------------------------------- */
                IF var_ehr_txn_flag != 'Y' THEN
                    BEGIN
                        /* ------------------------------------------------------ */
                        /* Around 6000 Txn/per Hr : 6000 X 100 Ms = 10 Mins -- */
                        
                        /* ------------------------------------------------------ */
                        PERFORM pg_sleep(0);
                        /* To prevent High CPU caused by any infinite loop reason --- */
                        EXIT fetch_next_cursor_reord;
                    END;
                END IF;
                /* ----------------------------------------------------------------- */
                /* [Step.3] : Processing this eHR participant related PAS TXN -- */
                
                /* ----------------------------------------------------------------- */
                IF EXISTS (SELECT
                    *
                    FROM move_episode_indicator
                    WHERE (from_patient_key = var_poll_pky OR to_patient_key = var_poll_pky) AND move_status = 'O') THEN
                    SELECT
                        'Y'
                        INTO var_me_flag;
                END IF;

                IF var_ehr_txn_flag = 'Y' THEN
                    BEGIN
                        <<upd_record_status>>
                        BEGIN
                            <<notify_ack>>
                            BEGIN
                                <<upd_ehr_lst>>
                                BEGIN
                                    /* --------------------------------------------------------- */
                                    /* Exact DOB flag : NO EMY patient for HA-PMI records !-- */
                                    IF var_txn_exact_dob = 'Y' THEN
                                        SELECT
                                            'EDMY'
                                            INTO "var_txn_exact_dob_EDMY";
                                    ELSE
                                        SELECT
                                            'EY'
                                            INTO "var_txn_exact_dob_EDMY";
                                    END IF;
                                    SELECT
                                        to_char(var_txn_dob::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                        INTO var_txn_dob_str;
                                    SELECT
                                        SUBSTRING(var_txn_dob_str, 1, 4)
                                        INTO var_txn_dob_year;
                                    SELECT
                                        SUBSTRING(var_txn_dob_str, 5, 2)
                                        INTO var_txn_dob_month;
                                    SELECT
                                        SUBSTRING(var_txn_dob_str, 7, 2)
                                        INTO var_txn_dob_day;
                                    SELECT
                                        SUBSTRING(var_ehr_dob, 1, 4)
                                        INTO var_ehr_dob_year;
                                    SELECT
                                        SUBSTRING(var_ehr_dob, 5, 2)
                                        INTO var_ehr_dob_month;
                                    SELECT
                                        SUBSTRING(var_ehr_dob, 7, 2)
                                        INTO var_ehr_dob_day;
                                    /* ----------------------------------------------------------------------------------- */
                                    /* 20140918 :reformat ehr_full_name for checking by taking out : <space> <,> <-> -- */
                                    
                                    /* ----------------------------------------------------------------------------------- */
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

                                        IF (var_tmp_char != '' AND var_tmp_char != ',' AND var_tmp_char != '-') THEN
                                            SELECT
                                                CONCAT(var_ehr_name_to_chk, var_tmp_char)
                                                INTO var_ehr_name_to_chk;
                                        END IF;
                                        SELECT
                                            var_name_post_integer + 1
                                            INTO var_name_post_integer;
                                    END LOOP;
                                    /* ------------------------------------------------------------------------------- */
                                    /* 20140918 :reformat txn_name for checking by taking out : <space> <,> <->  -- */
                                    
                                    /* ------------------------------------------------------------------------------- */
                                    SELECT
                                        NULL, NULL
                                        INTO var_pas_name_to_chk, var_tmp_char;
                                    SELECT
                                        1
                                        INTO var_name_post_integer;
                                    SELECT
                                        CHAR_LENGTH(RTRIM(var_txn_name))
                                        INTO var_char_len;

                                    WHILE (var_name_post_integer <= COALESCE(var_char_len, 0) AND var_txn_name != NULL AND var_name_post_integer <= var_char_len_to_chk) LOOP
                                        /* To prevent any possibility of infinite-loop and check first 48 Chars ONLY) --- */
                                        SELECT
                                            SUBSTRING(var_txn_name, var_name_post_integer, 1)
                                            INTO var_tmp_char;

                                        IF (var_tmp_char != '' AND var_tmp_char != ',' AND var_tmp_char != '-') THEN
                                            SELECT
                                                CONCAT(var_pas_name_to_chk, var_tmp_char)
                                                INTO var_pas_name_to_chk;
                                        END IF;
                                        SELECT
                                            var_name_post_integer + 1
                                            INTO var_name_post_integer;
                                    END LOOP;
                                    /* ------------------------------------------ */
                                    /* select @txn_doc_type = document_type */
                                    /* from document_type */
                                    /* where document_code =@txn_doc_code */
                                    
                                    /* ------------------------------------------ */
                                    SELECT
                                        STRPOS(var_txn_name, ',')
                                        INTO var_name_post_integer;
                                    SELECT
                                        LTRIM(RTRIM(LEFT(var_txn_name, var_name_post_integer - 1)))
                                        INTO var_txn_surname;
                                    SELECT
                                        LTRIM(RTRIM(RIGHT(var_txn_name, LENGTH(var_txn_name) - var_name_post_integer)))
                                        INTO var_txn_givenname;
                                    /* ---------------- */
                                    SELECT
                                        CONCAT(var_txn_type, '/', LTRIM(RTRIM(var_poll_hkid)), '/', LTRIM(RTRIM(var_txn_case)), '/', to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ' ', to_char(var_txn_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), '/', ']ME[', var_me_flag, '][', var_ehr_no, '/', LTRIM(RTRIM(var_ehr_hkic)), '/', LTRIM(RTRIM(var_ehr_doc_type)), ':', LTRIM(RTRIM(var_ehr_doc_no)), '/', var_ehr_name_to_chk, '/', var_ehr_sex, '/', var_ehr_dob, '/', var_ehr_exact_dob, ']PAS[', LTRIM(RTRIM(var_ehr_pas_hkic)), '/', LTRIM(RTRIM(var_ehr_pas_doc_type)), ':', LTRIM(RTRIM(var_ehr_pas_doc_no)), '/', var_pas_name_to_chk, '/', var_ehr_pas_sex, '/', var_ehr_pas_dob, '/', LTRIM(RTRIM("var_txn_exact_dob_EDMY")), ']TXN[', LTRIM(RTRIM(var_txn_hkid)), '/', LTRIM(RTRIM(var_txn_doc_type)), ':', LTRIM(RTRIM(var_txn_doc_no)), '/', LTRIM(RTRIM(var_txn_name)), '/', var_txn_sex, '/', var_txn_dob_str, '/', var_txn_exact_dob, '/', 'Old:', LTRIM(RTRIM(var_txn_old_hkid)), '/', LTRIM(RTRIM(var_txn_old_name)), '/', var_txn_old_sex, '/', to_char(var_txn_old_dob::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), '/', var_ehr_pas_exact_dob, '/', to_char(var_txn_discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ']')
                                        INTO var_record_str;
                                    /* ---------------------------------------- */
                                    /* ------------------------------------------------ */
                                    IF par_debug_mode = 'Y' THEN
                                        RAISE NOTICE '[Step.3.0] %', var_record_str;
                                    END IF;
                                    /* ---------------------------------------------------------------- */
                                    /* [Step.3.1] - Scenario.1(of 5):MajorKeyChange(030) in HCP   -- */
                                    
                                    /* ---------------------------------------------------------------- */
                                    /* 1. If the eHR-participant enrolled with MK matched with HA-PMI, ack.code 1 will send to eHR */
                                    
                                    /* --	  After the enrollment, NO further communication/notification to eHR  for Sub-sequence MK change triggered in HA */
                                    /* 2. If the eHR-participant enrolled with MK NOT matched with HA-PMI, ack.code 3 will send to eHR */
                                    
                                    /* --	  After the enrollment, the ack.1 will only send to eHR (by 2nd/3th..ack) for Sub-sequence MK change triggered in HA (i.e NO 2nd/3rdíK99th Ack) AND the MK matched. */
                                    /* If the MK change in HA and MK not matched, NO ack to eHR as well, In one word, after the enrollment, the HA-PMI will notify eHR with Ack.1 only (i.e MK change triggered in HA and MK matched) */
                                    /* Possible Values only : VAL/MES/MKU/MKP/MKM */
                                    
                                    /* ----------------------------------------------------------------------------------------- */
                                    IF var_txn_type = '030' AND var_ehr_flag NOT IN ('DDR', 'WHD', 'NID', 'MID', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP') THEN
                                        BEGIN
                                            SELECT
                                                localtimestamp
                                                INTO var_cur_sys_dtm;
                                            SELECT
                                                var_txn_sys_dtm
                                                INTO var_upd_dtm;
                                            /* 20160108 */
                                            SELECT
                                                'ADT_A28'
                                                INTO var_evt_code;
                                            /* 2nd/3rd... Ack of A28 */
                                            SELECT
                                                'Y'
                                                INTO var_poll_hkid_ehr_handled;
                                            /* <Case.1.1> : Check any PAS_MK changed  -- */

                                            IF var_txn_sex <> COALESCE(var_txn_old_sex, 'NULL') OR var_txn_name <> COALESCE(var_txn_old_name, 'NULL') OR COALESCE(var_txn_dob, '18000101') <> COALESCE(var_txn_old_dob, '18000101') OR
                                            /* -------- 1.1.2 PAS_MK changed compared with ehr_patient_list ------------ */
                                            var_txn_sex <> COALESCE(var_ehr_pas_sex, 'NULL') OR var_txn_name <> COALESCE(var_ehr_pas_full_name, 'NULL') OR
                                            /* --OR convert(char(8),@txn_dob,112)  <> isnull(@ehr_pas_dob,'NULL') */
                                            COALESCE(var_txn_dob_str, 'NULL') <> COALESCE(var_ehr_pas_dob, 'NULL') OR
                                            /* -------------------------------- */
                                            "var_txn_exact_dob_EDMY" <> COALESCE(var_ehr_pas_exact_dob, 'NULL') THEN
                                                /* Exact_dob change compare with ehr_patient_list (i.e NO ol_exact_dob_flag in transaction_log info) */
                                                
                                                /* ------------------------------------------------------------- */
                                                /* MK change in PAX TXN and affect ehr_patietn_list status -- */
                                                
                                                /* ------------------------------------------------------------- */
                                                BEGIN
                                                    /* if @debug_mode ='Y'	Print '[030 PAS_MK Changed] --> %1!',@record_str */
                                                    /* DataMatching with EHR_MK -- */
                                                    IF (var_ehr_sex <> var_txn_sex) OR (var_ehr_name_to_chk <> var_pas_name_to_chk) OR (var_ehr_exact_dob = 'EDMY' AND var_ehr_dob <> COALESCE(var_txn_dob_str, 'NULL')) OR (var_ehr_exact_dob = 'EY' AND var_ehr_dob_year <> var_txn_dob_year) OR (var_ehr_exact_dob = 'EMY' AND var_ehr_dob_year <> var_txn_dob_year) THEN
                                                        BEGIN
                                                            /* ---------MK NOT matched-------------- */
                                                            SELECT
                                                                '3'
                                                                INTO var_evt_ack;

                                                            IF var_me_flag = 'Y' THEN
                                                                SELECT
                                                                    'MKM'
                                                                    INTO var_ehr_flag_new;
                                                            /* if ehr_flag=MKC, then ehr_flag_prev will be MKC but the latest MKC by this PAS txn .... */
                                                            ELSE
                                                                BEGIN
                                                                    IF var_ehr_flag IN ('MKC', 'MKE') THEN
                                                                        SELECT
                                                                            'MKP'
                                                                            INTO var_ehr_flag_new;
                                                                    /* 20140730 : MK changed by ehr before AND last-updated by PAS */
                                                                    ELSE
                                                                        SELECT
                                                                            'MKU'
                                                                            INTO var_ehr_flag_new;
                                                                    END IF
                                                                    /* MK changed by PAS only */
                                                                    ;
                                                                END;
                                                            END IF;
                                                        END;
                                                    ELSE
                                                        /* ---------MK Matched-------------- */
                                                        BEGIN
                                                            IF var_me_flag = 'Y' THEN
                                                                SELECT
                                                                    'MES', '4'
                                                                    INTO var_ehr_flag_new, var_evt_ack;
                                                            /* ACK - Data Not Ready */
                                                            ELSE
                                                                SELECT
                                                                    'VAL', '1'
                                                                    INTO var_ehr_flag_new, var_evt_ack;
                                                            END IF
                                                            /* ACK - MK matched  --> will clear/reset ehr_flag_prev to null in trigger */
                                                            ;
                                                        END;
                                                    END IF;
                                                    /* -------------------------------------------------------------------------- */
                                                    /* 20141020 NO ACK gen if NO change at eHR Flag but write ehr_event_txn -- */
                                                    
                                                    /* -------------------------------------------------------------------------- */
                                                    IF var_ehr_flag_new = var_ehr_flag THEN
                                                        SELECT
                                                            'N'
                                                            INTO var_ack_notify_flag;
                                                    END IF;
                                                    /* ------------------------------------------- */
                                                    /* 20141020 : disable DUE to : if Update EY to EDMY new/old_ehr flag is 'VAL' --- */
                                                    
                                                    /* ----------------------------------------- */
                                                    /* if @ehr_flag_new = @ehr_flag --- SHOULD not be happen */
                                                    /* begin */
                                                    /* --	WAITFOR DELAY '00:00:00:010' 		--- To prevent High CPU caused by any infinite loop reason --- */
                                                    
                                                    /* --	GOTO FETCH_NEXT_CURSOR_REORD */
                                                    /* end */
                                                    
                                                    /* --------------------------------------------------------------------------------------- */
                                                    /* Need to update ehr_flag_prev correctly for MKM updated                           ---- */
                                                    /* <ehr_pas_me_polling> After ME cleared, MKM need to update to ehr_flag_prev correctly--- */
                                                    /* tU_ehr_patient_list will handle the ehr_flag_prev update -- */
                                                    
                                                    /* --------------------------------------------------------------------------------------- */
                                                    IF par_debug_mode = 'Y' THEN
                                                        RAISE NOTICE '[Step.3.1] Scenario 1 --> MajorKeyChange [evt_code=%][%]', var_evt_code, var_record_str;
                                                    END IF;
                                                    EXIT upd_ehr_lst;
                                                END;
                                            END IF /* ------------<Case.1.1> : Check any PAS_MK changed  --------------- */;
                                        END;
                                    END IF;
                                    /* ----END of : IF @txn_type ='030' -- CASE.1[030] : MKC in HCP  ----------------------- */
                                    
                                    /* ----------------------------------------------------------------------------------- */
                                    /* [Step.3.2] - Scenario.2(of 5) : KNOCK_DOOR - @msg_no ending with 'Q'          -- */
                                    
                                    /* ----------------------------------------------------------------------------------- */
                                    
                                    /* --1).<010/100/300> :if HKID with <NID/MID/MIC/MIE/MIM/MIU/MIP> status */
                                    
                                    /* --2).<020/031>     :if TO_HKID with <NID/MID/MIC/MIE/MIM/MIU/MIP> status */
                                    
                                    /* --3).<030>         :if <doc.pair> patient updated as eHR <doc.pair> */
                                    
                                    /* --4).<020>         :if TO_HKID <doc.pair> matched as eHR <doc.pair> */
                                    /* 20161118 : all '030' on Doc.Pair Change related to @doc_pair_participant & matched eHR Doc.Pair */
                                    
                                    /* --------------------------------------------------------------------------------------------------- */
                                    IF (var_txn_type IN ('010', '100', '300') AND var_ehr_flag IN ('NID', 'MID', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP')) OR /* --1).20160202: to handle 010/100/300 */ (var_txn_type IN ('020', '031') AND var_to_hkid_knock_door = 'Y') OR /* --2).20150723: if TO_HKID with NID/MID status-- */ (var_txn_type IN ('030') AND var_doc_pair_participant = 'Y' AND var_doc_pair_changed = 'Y' AND /* --3).20160229: if PAS <doc.pair> updated as eHR <doc.pair> again for 030 */ (var_txn_doc_type_chk = var_ehr_doc_type AND var_txn_doc_no = var_ehr_doc_no) AND var_ehr_flag IN ('NID', 'MID', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP', 'MKU', 'MKP')) OR
                                    /* 20161118 /20181029: To handle MKU/MKP as well */
                                    
                                    /* --AND @ehr_flag not in ('VAL','MES','WHD','DDR')) */
                                    (var_txn_type IN ('020') AND var_doc_pair_participant = 'Y' AND /* --4).20171115 : if TO_HKID <doc.pair> matched as eHR <doc.pair> for 020 */ (var_txn_doc_type_chk = var_ehr_doc_type AND var_txn_doc_no = var_ehr_doc_no) AND var_ehr_flag IN ('NID', 'MID', 'MIC', 'MIE', 'MIM', 'MIU', 'MIP')) THEN
                                        BEGIN
                                            SELECT
                                                localtimestamp
                                                INTO var_cur_sys_dtm;
                                            SELECT
                                                var_txn_sys_dtm
                                                INTO var_upd_dtm;
                                            /* 20160108 */
                                            SELECT
                                                'ADT_A28'
                                                INTO var_evt_code;
                                            /* 2nd/3rd... Ack.. */
                                            SELECT
                                                'X'
                                                INTO var_evt_ack;
                                            /* NO ACK need */
                                            SELECT
                                                'Y'
                                                INTO var_poll_hkid_ehr_handled;
                                            SELECT
                                                'Y'
                                                INTO var_knock_door_triggered;
                                            /* --------------------------------------------------------- */
                                            /* ---pas_msg_no will generated (msg_no is UniqueKey for EVENT_IN) --- */
                                            SELECT
                                                CONCAT(RIGHT(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), 6), SUBSTRING(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), 1, 2), SUBSTRING(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), 4, 2), + '-', LTRIM(RTRIM(var_poll_pky)), 'Q')
                                                INTO var_pas_msg_no;
                                            /* ---------------------------------------------------- */
                                            /* --- Insert New Request with <Q> evt_status for EHR_QRY_WS --- */
                                            
                                            /* ----------------------------------------------------- */
                                            
                                            /* ----BEGIN TRAN here ...-------- */
                                            
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
                                            CALL ehr_write_event_in(var_rtn_code, var_txn_sys_dtm, var_pas_msg_no, var_evt_code, var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic,
                                            /* -------eHR MK -------- */
                                            NULL, /* --@ehr_surname */ NULL, /* --@ehr_givenname */ NULL, /* --@ehr_full_name */ NULL, /* --@ehr_sex */ NULL, /* --@ehr_dob */ NULL, /* --@ehr_exact_dob */ var_ehr_doc_type, var_ehr_doc_no, NULL, /* --@ehr_death_date */ NULL, /* --@ehr_death_time */ NULL, /* --@ehr_exact_death */ NULL, /* --@ehr_death_ind */ NULL, /* --@old_ehr_hkic */ NULL, /* --@old_ehr_surname */ NULL, /* --@old_ehr_givenname */ NULL, /* --@old_ehr_full_name */ NULL, /* --@old_ehr_sex */ NULL, /* --@old_ehr_dob */ NULL, /* --@old_ehr_exact_dob */ NULL, /* --@old_ehr_doc_type */ NULL,
                                            /* @old_ehr_doc_no */
                                            
                                            /* --------HA action status for the event by PAS WS ----------------- */
                                            'Q', /* --@evt_status */ var_upd_by, /* --<EHR_POLL_TXN> @evt_crt_by VARCHAR(12), */ var_upd_sys,
                                            /* <EHR_POLL> @evt_crt_sys VARCHAR(12), */
                                            var_rtn_msg);

                                            IF var_rtn_code != 0 THEN
                                                BEGIN
                                                    RAISE NOTICE 'ehr_write_event_in with ERROR code : [%] - [%]', var_rtn_code, var_rtn_msg;
                                                    SELECT
                                                        5
                                                        INTO var_failure_code; /* ---system failed -SKIP Record */
                                                    SELECT
                                                        500023
                                                        INTO var_rtn_err_code; /* ---Error Handling the EHR record-SKIP */
                                                    EXIT upd_record_status;
                                                END;
                                            END IF;
                                            SELECT
                                                var_rtn_code
                                                INTO var_rtn_err_code;
                                            /* ---- Ack.generation to ehr_event_out to EHR/EPR */

                                            IF par_debug_mode = 'Y' THEN
                                                RAISE NOTICE '[Step.3.2] Scenario 2 --> Knock-door[evt_code=%][%]', var_evt_code, var_record_str;
                                            END IF;
                                            EXIT notify_ack;
                                        END;
                                    END IF;
                                    /* ----------------------------------------------------------------------------------- */
                                    /* [Step.3.3] - Scenario.3(of 5) :[020,031]- FROM_HKID Change/Merge HKID in HCP  -- */
                                    
                                    /* ----------------------------------------------------------------------------------- */
                                    IF var_txn_type IN ('020', '031') THEN
                                        BEGIN
                                            SELECT
                                                localtimestamp
                                                INTO var_cur_sys_dtm;
                                            SELECT
                                                var_txn_sys_dtm
                                                INTO var_upd_dtm;
                                            SELECT
                                                'ADT_A47'
                                                INTO var_evt_code;
                                            /* [HCP] MK change include (HKIC) */
                                            SELECT
                                                '2'
                                                INTO var_evt_ack;
                                            /* 20160109 : this ack will be used in ehr_event_out..evt_ack */
                                            SELECT
                                                'Y'
                                                INTO var_poll_hkid_ehr_handled;
                                            SELECT
                                                'MID'
                                                INTO var_ehr_flag_new;
                                            /* NO validation needed, update as MID directly */
                                            /*
                                            -- 20180115 : Disable As MI Series Enhancement suspendsion  --
                                            --select @ehr_flag_new = 'MID'		-- NO validation needed, update as MID directly
                                            ---------------------------------------------------------------------------------
                                            -- FROM_HKID marked as MKM/MIU/MIP
                                            -- TO_HKID will be trigger Knock-Door
                                            ---------------------------------------------------------------------------------
                                            if @me_flag ='Y'                     select @ehr_flag_new='MIM'  -- ID changed and MoveEpisode Found
                                            else if @ehr_flag in ('MIC','MIE')	 select @ehr_flag_new='MIP'	 -- ID/Doc.Pair changed by ehr before AND last-updated by PAS
                                            else						 	     select @ehr_flag_new='MIU'	 -- ID/Doc.Pair changed by PAS only
                                            ---------------------------------------------------------------------------------
                                            -- 20170919 : create [ehr_pin_change_list] for MIU/MIP/MIM participant WHO Non-exist in HA-PMI any more (as merged/change to other HKID)
                                            -- pas_hkic/pas_pky = to_hkic/to_pky;old_hkid=@ehr_pas_hkic  --
                                            -- possible issue: to_hkic already registered as other eHR# --> need to remind what ??
                                            ---------------------------------------------------------------------------------
                                            insert into ehr_pin_change_list (ehr_number,ehr_start_date,ehr_end_date,ehr_hkic,ehr_doc_type,ehr_doc_no,ehr_full_name,ehr_sex,ehr_dob,
                                            		pas_hkic,pas_pky,pas_doc_type,pas_doc_no,pas_full_name,pas_sex,pas_dob,
                                            		ehr_flag,ehr_ppi_ind,ehr_non_ha_ind,to_hkid,txn_type,txn_dtm,sys_dtm)
                                            values (@ehr_no,@ehr_start_date,@ehr_end_date,@ehr_hkic,@ehr_doc_type,@ehr_doc_no,@ehr_full_name,@ehr_sex,@ehr_dob,
                                            		@ehr_pas_hkic,@ehr_pas_pky,@ehr_pas_doc_type,@ehr_pas_doc_no,@ehr_pas_full_name,@ehr_pas_sex,@ehr_pas_dob,
                                            		@ehr_flag_new, @ehr_ppi_ind,@ehr_non_ha_ind,@to_hkid,@txn_type,@txn_sys_dtm,@cur_sys_dtm)
                                            ---------------------------------------------------------------------------------
                                            */
                                            IF par_debug_mode = 'Y' THEN
                                                RAISE NOTICE '[Step.3.3] Scenario 3 -->  Merge/ChangeHKID[evt_code=%][%]', var_evt_code, var_record_str;
                                            END IF;
                                            EXIT upd_ehr_lst
                                            /* pas_PDEMO will be updated by txn_PDEMO(i.e TO_HKID Pdemo) ;tU_ehr_patient_list handling on MID : to clear all pas_PDEMO .. */
                                            ;
                                        END;
                                    END IF;
                                    /* -------------------------------------------------------------------------------------------------------- */
                                    /* [Step.3.4] - Scenario.4(of 5) :[030] : Change Doc.Pair only in HCP & NOT matched with eHR Doc.Pair -- */
                                    /* 20170919 : Disable as HI reqirement */
                                    
                                    /* -------------------------------------------------------------------------------------------------------- */
                                    IF var_txn_type IN ('030') AND var_doc_pair_participant = 'Y' AND var_doc_pair_changed = 'Y' AND (var_txn_doc_type_chk <> var_ehr_doc_type OR var_txn_doc_no <> var_ehr_doc_no) THEN
                                        BEGIN
                                            SELECT
                                                localtimestamp
                                                INTO var_cur_sys_dtm;
                                            SELECT
                                                var_txn_sys_dtm
                                                INTO var_upd_dtm;
                                            SELECT
                                                'ADT_A47'
                                                INTO var_evt_code;
                                            /* [HCP] MK change include (HKIC) */
                                            /* --select @evt_ack='X'				-- NO ACK need */
                                            SELECT
                                                '2'
                                                INTO var_evt_ack;
                                            /* 20160109 : this ack will be used in ehr_event_out..evt_ack */
                                            SELECT
                                                'Y'
                                                INTO var_poll_hkid_ehr_handled;

                                            IF var_ehr_flag = 'VAL' THEN
                                                /* select @ehr_flag_new = 'MIU'	-- ID/Doc.Pair changed by PAS only  -- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                                SELECT
                                                    'MKU'
                                                    INTO var_ehr_flag_new;
                                            /* MKU for the HA-Update after VAL ONLY / MKC for eHR-update after VAL only */
                                            ELSE
                                                /* select @ehr_flag_new = 'MIP'	-- ID/Doc.Pair changed by ehr before AND last-updated by PAS  -- 20180115 : Disable As MI Series Enhancement suspendsion  -- */
                                                SELECT
                                                    'MKP'
                                                    INTO var_ehr_flag_new;
                                            END IF;
                                            /* NO validation needed, update as MKU directly */
                                            
                                            /* -------------------------------------- */
                                            EXIT upd_ehr_lst;
                                        END;
                                    END IF;
                                    /* -------------------------------------------------------------------------------------------- */
                                    /* [Step.3.5] - Scenario.5(of 5):[131,331,211,351] - discharged to death/cancellation to discharge death -- */
                                    /* 20170919 : Disable as eHR-side will never handle the HA-PMI Death Txn */
                                    
                                    /* ------------------------------------------------------------------------------------------ */
                                    
                                    /* --	IF @txn_type in ('131','331','211','351') AND @ehr_flag NOT in ('NID','MID','DDR','WHD') */
                                    
                                    /* --	BEGIN */
                                    
                                    /* -- */
                                    
                                    /* --		select @cur_sys_dtm =getdate() */
                                    
                                    /* --		select @upd_dtm = @txn_sys_dtm */
                                    
                                    /* -- */
                                    /* --		select @evt_code ='ADT_A08'  		-- Death of EHR participant txn */
                                    
                                    /* --		select @poll_hkid_ehr_handled='Y' */
                                    
                                    /* -- */
                                    
                                    /* --		--@pas_death_date,@pas_death_time,@pas_exact_death,@pas_death_ind) */
                                    /* --		if @txn_type in ('131','331') select @pas_death_ind='Y'	  -- Mark death */
                                    /* --		if @txn_type in ('211','351') select @pas_death_ind='N'	  -- Cancel death */
                                    /* --		select @pas_exact_death ='EDMY'	                          -- Only Exact Date/MM/YYYY in HA for discharge to death txn */
                                    
                                    /* --		select @pas_death_date = convert(char(8),@txn_discharge_dtm,112) */
                                    /* --		select @pas_death_time = substring(convert(char(8), @txn_discharge_dtm, 108), 1, 2)    -- hhmmss.SSS */
                                    /* + substring(convert(char(8), @txn_discharge_dtm, 108), 4, 2) */
                                    /* + substring(convert(char(8),@txn_discharge_dtm, 108), 7, 2) */
                                    /* +'.' + substring(convert(varchar(30), @txn_discharge_dtm, 109), 22, 3) */
                                    
                                    /* --		--------------------------------------------------------------------------------------- */
                                    /* --		-- 20140723 : NO NEED to update ehr_patient_list.ehr_flag and just Notify eHR ONLY -- */
                                    
                                    /* --		--------------------------------------------------------------------------------------- */
                                    
                                    /* --		--select @ehr_flag_new = 'DDR'			----NO validation needed, update as MID directly */
                                    
                                    /* --		--	GOTO UPD_EHR_LST */
                                    
                                    /* --		--------------------------------------------------------------------------------------- */
                                    
                                    /* --		GOTO NOTIFY_ACK */
                                    
                                    /* --	END */
                                    
                                    /* ------------------------------- */
                                    
                                    /* ---@poll_hkid handled -- */
                                    
                                    /* ------------------------------- */
                                    PERFORM pg_sleep(0);
                                    /* To prevent High CPU caused by any infinite loop reason --- */
                                    EXIT fetch_next_cursor_reord;
                                    /* ------------------------------------------------------------------------------------------ */
                                    /* [Step.4]: Update ehr_patient_list.ehr_pas_xxx fields with latest PAS-TXN PMI records -- */
                                    
                                    /* ------------------------------------------------------------------------------------------ */
                                    <<knock_door>>
                                    BEGIN
                                    END;
                                END;

                                IF par_debug_mode = 'Y' THEN
                                    RAISE NOTICE '[Step.4] UPD_EHR_LST -> [%:poll_hkid=%][ehr_flag=%:ehr_flag_new=%]', var_ehr_no, var_poll_hkid, var_ehr_flag, var_ehr_flag_new;
                                END IF;
                                SELECT
                                    localtimestamp
                                    INTO var_cur_sys_dtm;
                                /* ----BEGIN TRAN here ...-------- */
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
                                /* --------------------------------------------- */
                                IF var_poll_hkid_ehr_handled = 'Y' AND EXISTS (SELECT
                                    *
                                    FROM ehr_patient_list
                                    WHERE ehr_number = var_ehr_no) AND COALESCE(var_knock_door_triggered, 'N') != 'Y' THEN
                                    /* 20170919 : Don't update pas_pdemo and Data-Matching will be triggered by knock-door A28  event -- */
                                    BEGIN
                                        BEGIN
                                            UPDATE ehr_patient_list
                                            SET ehr_flag = var_ehr_flag_new, evt_ack = var_evt_ack,
                                            /* -------Update for ehr_pas_xxx ----------- */
                                            pas_full_name = var_txn_name, pas_surname = var_txn_surname, pas_givenname = var_txn_givenname, pas_sex = var_txn_sex,
                                            /* --pas_dob 		= convert(char(8),@txn_dob,112), */
                                            pas_dob = var_txn_dob_str, pas_exact_dob = "var_txn_exact_dob_EDMY", pas_doc_type = var_txn_doc_type, pas_doc_no = var_txn_doc_no,
                                            /* -------------------------------- */
                                            upd_by = var_upd_by, upd_hosp = var_txn_hosp, upd_sys = var_upd_sys, upd_dtm = var_upd_dtm, sys_dtm = var_cur_sys_dtm
                                                WHERE ehr_number = var_ehr_no;
                                            var_rtn_err_code := 0;
                                            EXCEPTION
                                                WHEN OTHERS THEN
                                                    var_rtn_err_code := 1;
                                        END;

                                        IF var_rtn_err_code != 0 THEN
                                            BEGIN
                                                RAISE NOTICE 'Update ehr_patietn_list with ERROR code : %', var_rtn_err_code;
                                                /* --------------------------------------- */
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
                                /* ---- Ack.generation to ehr_event_out to EHR/EPR */
                                EXIT notify_ack;
                                /* ------------------------------------------------------------------------------------------ */
                                /* [Step.5]: Acknowledgement and ehr_txn records */
                                
                                /* ------------------------------------------------------------------------------------------ */
                            END;

                            IF par_debug_mode = 'Y' THEN
                                RAISE NOTICE '[Step.5] NOTIFY_ACK -> [%:poll_hkid=%] ; [%:evt_ack=%]', var_ehr_no, var_poll_hkid, var_evt_code, var_evt_ack;
                            END IF;
                            SELECT
                                localtimestamp
                                INTO var_cur_sys_dtm;
                            /* --------------------------------------------- */
                            /* 1. If the eHR-participant enrolled with MK matched with HA-PMI, ack.code 1 will send to eHR */
                            /* After the enrollment, NO further communication/notification to eHR  for Sub-sequence MK change triggered in HA */
                            /* 2. If the eHR-participant enrolled with MK NOT matched with HA-PMI, ack.code 3 will send to eHR */
                            /* After the enrollment, the ack.1 will only send to eHR (by 2nd/3th..ack) for Sub-sequence MK change triggered in HA (i.e NO 2nd/3rdíK99th Ack) AND the MK matched. */
                            /* If the MK change in HA and MK not matched, NO ack to eHR as well */
                            /* In one word, after the enrollment, the HA-PMI will notify eHR with Ack.1 only (i.e MK change triggered in HA and MK matched) */
                            
                            /* -------------------------------------------------------------- */
                            IF (var_evt_ack = '1' AND var_evt_code = 'ADT_A28' AND var_ehr_no <> "var_DUMMY_EHR_NO") THEN
                                SELECT
                                    'I'
                                    INTO var_ehr_evt_ack_status;
                            /* After the enrollment, the HA-PMI will notify eHR with Ack.1 only for 2nd/3th ack.. (i.e MK change triggered in HA and MK matched) */
                            ELSE
                                SELECT
                                    'X'
                                    INTO var_ehr_evt_ack_status;
                            END IF;
                            /* ---------------------------------------- */
                            IF var_evt_ack = '1' AND var_evt_code = 'ADT_A28' AND var_ehr_no <> "var_DUMMY_EHR_NO" THEN
                                SELECT
                                    'I'
                                    INTO var_epr_evt_ack_status;
                            /* ePR will ONLY upload data to eHR if ehr_flag is íÑVALíª or íÑMKC' or 'MIC' */
                            ELSE
                                SELECT
                                    'X'
                                    INTO var_epr_evt_ack_status;
                            END IF;

                            IF var_evt_ack = '1' AND var_evt_code = 'ADT_A28' AND var_ehr_no <> "var_DUMMY_EHR_NO" THEN
                                SELECT
                                    'I'
                                    INTO var_ris_evt_ack_status;
                            /* RIS will ONLY upload data to eHR if ehr_flag is íÑVALíª or íÑMKC' or 'MIC' */
                            ELSE
                                SELECT
                                    'X'
                                    INTO var_ris_evt_ack_status;
                            END IF;
                            /* -------------------------------------------------------- */
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
                            /* ------------------------------------------------- */
                            /* [Step.5.1]: Acknowledgement - ehr_event_out -- */
                            
                            /* ----------------------------------------------------------------------------------------------- */
                            /* <pas_msg_no> will be generated for EVENT_OUT ONLY...msg_no is UniqueKey for EVENT_OUT -- */
                            
                            /* ------------------------------------------------------------------------------------------- */
                            SELECT
                                CONCAT(RIGHT(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), 6), SUBSTRING(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), 1, 2), SUBSTRING(to_char(var_cur_sys_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS'), 4, 2), + '-', LTRIM(RTRIM(var_poll_pky)))
                                INTO var_pas_msg_no_prefix;
                            /* -------------------------------------------------------------------------------------------- */
                            /* <5.1.1> - <ADT_A28> Ack for <MajorKeyChange> with Data-Matched:@msg_no ending with 'T' -- */
                            
                            /* -------------------------------------------------------------------------------------------- */
                            IF var_ehr_txn_flag = 'Y' AND var_poll_hkid_ehr_handled = 'Y' AND (var_ehr_evt_ack_status = 'I' OR var_epr_evt_ack_status = 'I' OR var_ris_evt_ack_status = 'I') AND COALESCE(var_ack_notify_flag, 'Y') <> 'N' THEN
                                /* 20141020  : Default to gen ACK records Except : ehr_flag NOT change during 030 txn --- */
                                BEGIN
                                    SELECT
                                        CONCAT(var_pas_msg_no_prefix, 'T')
                                        INTO var_pas_msg_no;

                                    BEGIN
                                        INSERT INTO ehr_event_out (msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, sys_dtm, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind)
                                        VALUES (var_pas_msg_no, var_evt_code, var_txn_sys_dtm, var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_doc_type, var_ehr_doc_no, var_evt_ack, var_ehr_evt_ack_status, var_epr_evt_ack_status, var_ris_evt_ack_status, var_upd_by, var_upd_sys, var_cur_sys_dtm, var_pas_death_date, var_pas_death_time, var_pas_exact_death, var_pas_death_ind);
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
                            /* --------------------------------------------------------------------------------------------------------- */
                            /* <030/020/031> : <ADT_A47> of eHR participant will be generated (PPI MKC by cdcpas52#sFTP daily job) -- */
                            
                            /* --------------------------------------------------------------------------------------------------------- */
                            IF var_ehr_txn_flag = 'Y' AND var_poll_hkid_ehr_handled = 'Y' AND var_txn_type IN ('030', '020', '031') THEN
                                BEGIN
                                    /* ---------------------------------------------------------------------------------------------------------------------------- */
                                    /* <5.1.2> - <ADT_A47> event for <MajorKeyChange> of eHR participant:@msg_no ending with 'K' -- */
                                    
                                    /* ---------------------------------------------------------------------------------------------------------------------------- */
                                    IF var_txn_type IN ('030') AND COALESCE(var_ehr_ppi_ind, 'N') = 'Y' AND var_ehr_full_name IS NOT NULL THEN
                                        /* 20160215 : to avoid A47 without ehr-pdemo issues (i.e update Doc.Pair NID-->VAL) */
                                        BEGIN
                                            SELECT
                                                CONCAT(RTRIM(var_pas_msg_no_prefix), 'K')
                                                INTO var_pas_msg_no;
                                            INSERT INTO ehr_event_out (msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no,
                                            /* old_pas_hkic, old_pas_surname, old_pas_givenname, old_pas_full_name, old_pas_sex, old_pas_dob, old_pas_exact_dob,old_pas_doc_type,old_pas_doc_no, */
                                            evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, sys_dtm)
                                            VALUES (var_pas_msg_no, 'ADT_A47', var_txn_sys_dtm, var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_doc_type, var_ehr_doc_no, var_poll_hkid, var_txn_surname, var_txn_givenname, var_txn_name, var_txn_sex, var_txn_dob_str, "var_txn_exact_dob_EDMY", var_txn_doc_type, var_txn_doc_no,
                                            /* @ehr_hkic, @ehr_pas_surname, @ehr_pas_givenname, @ehr_pas_full_name, @ehr_pas_sex, @ehr_pas_dob, @ehr_pas_exact_dob,@ehr_pas_doc_type, @ehr_pas_doc_no, */
                                            var_evt_ack, 'I', 'X', 'X', var_upd_by, var_upd_sys, var_cur_sys_dtm);
                                        END;
                                    END IF;
                                    /* --------------------------------------------------------------------------------------------------------------------------------- */
                                    /* <5.1.3> - <ADT_A47> event for <IdentityChange> of eHR participant : @msg_no ending with 'M' -- */
                                    
                                    /* --------------------------------------------------------------------------------------------------------------------------------- */
                                    BEGIN
                                        IF var_txn_type IN ('020', '031') AND COALESCE(var_ehr_ppi_ind, 'N') = 'Y' AND var_to_hkid_knock_door <> 'Y' THEN
                                            /* 20160108 : to avoid A47 without ehr-pdemo issues */
                                            BEGIN
                                                SELECT
                                                    CONCAT(RTRIM(var_pas_msg_no_prefix), 'M')
                                                    INTO var_pas_msg_no;
                                                INSERT INTO ehr_event_out (msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, sys_dtm)
                                                VALUES (var_pas_msg_no, 'ADT_A47', var_txn_sys_dtm, var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_doc_type, var_ehr_doc_no, var_txn_hkid, var_txn_surname, var_txn_givenname, var_txn_name, var_txn_sex, var_txn_dob_str, "var_txn_exact_dob_EDMY", var_txn_doc_type, var_txn_doc_no, var_evt_ack, 'I', 'X', 'X', var_upd_by, var_upd_sys, var_cur_sys_dtm);
                                            END;
                                        END IF;
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
                            /* if @ehr_txn_flag ='Y' and @poll_hkid_ehr_handled='Y' */

                            IF COALESCE(var_txn_doc_type, 'NULL') <> COALESCE(var_ehr_pas_doc_type, 'NULL') OR COALESCE(var_txn_doc_no, 'NULL') <> COALESCE(var_ehr_pas_doc_no, 'NULL') THEN
                                BEGIN
                                    SELECT
                                        var_ehr_pas_doc_type, var_ehr_pas_doc_no
                                        INTO var_old_pas_doc_type, var_old_pas_doc_no;
                                END;
                            END IF;
                            /* ------------------------------------------------- */
                            /* [Step.5.2]: eHR txn  - ehr_event_txn        -- */
                            
                            /* ------------------------------------------------- */
                            IF var_txn_type IN ('020', '031') THEN
                                SELECT
                                    var_to_hkid, var_to_pky
                                    INTO var_poll_hkid, var_poll_pky;
                            END IF;
                            /* 20161221 */

                            BEGIN
                                INSERT INTO ehr_event_txn (evt_txn_dtm, evt_txn_type, evt_code, evt_log_type, evt_msg_no, evt_ack, ehr_flag, old_ehr_flag, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_pky, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, old_pas_hkic, old_pas_pky, old_pas_doc_type, old_pas_doc_no, old_pas_surname, old_pas_givenname, old_pas_full_name, old_pas_sex, old_pas_dob, old_pas_exact_dob, upd_by, upd_hosp, upd_sys, sys_dtm, pas_case, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind, ehr_ppi_ind, ehr_non_ha_ind, ehr_smart_id)
                                VALUES (var_txn_sys_dtm, var_txn_type, var_evt_code, 'T', var_pas_msg_no, var_evt_ack, var_ehr_flag_new, var_ehr_flag, var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_surname, var_ehr_givenname, var_ehr_full_name, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_doc_type, var_ehr_doc_no, var_poll_hkid, var_poll_pky, /* @txn_hkid,@txn_pky, */ var_txn_surname, var_txn_givenname, var_txn_name, var_txn_sex, var_txn_dob_str, "var_txn_exact_dob_EDMY", var_txn_doc_type, var_txn_doc_no, var_old_pas_hkic, var_old_pas_pky, var_old_pas_doc_type, var_old_pas_doc_no, var_ehr_pas_surname, var_ehr_pas_givenname, var_ehr_pas_full_name, var_ehr_pas_sex, var_ehr_pas_dob, var_ehr_pas_exact_dob,
                                /* --@txn_old_surname, @txn_old_givenname, @txn_old_name, @txn_old_sex, @txn_old_dob, @ehr_pas_exact_dob, */
                                var_txn_upd_by, var_txn_hosp, var_txn_src_sys, var_cur_sys_dtm, var_txn_case, var_pas_death_date, var_pas_death_time, var_pas_exact_death, var_pas_death_ind, var_ehr_ppi_ind, var_ehr_non_ha_ind, var_ehr_smart_id);
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
                            /* -------------------------------------------------------------------------------------------------------- */
                            /* [Step.6] Update the handled Event Status <ehr_event_conf.last_poll_dtm> where system_id='PAS_POLL' -- */
                            
                            /* -------------------------------------------------------------------------------------------------------- */
                            /* the error code  is start from 500000 for PAS EHR interfaces job */
                            /* 1205 is deadlock	; 2601 is deplicate key */
                            
                            /* -------------------------------------------------------------------- */
                        END;

                        <<next_record>>
                        BEGIN
                            SELECT
                                localtimestamp
                                INTO var_cur_sys_dtm;

                            IF par_debug_mode = 'Y' THEN
                                RAISE NOTICE '[Step.6] UPD_RECORD_STATUS -> [rtn_err_code=%:polled_last_sys_dtm=%]', var_rtn_err_code, var_polled_last_sys_dtm;
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
                            /* ------------------------------------------------------------------------------------------------- */
                            /* The err code start from 500000 for PAS EHR interfaces job; 1205-deadlock;2601-deplicate key -- */
                            
                            /* ------------------------------------------------------------------------------------------------- */
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
                            /* ------------------------------------------- */
                            /* handling record string for log/print  -- */
                            
                            /* ------------------------------------------- */
                            SELECT
                                CONCAT(RTRIM(var_record_str), '#', var_ehr_flag_new, '/', var_evt_ack, '/', var_ehr_flag, '/', LTRIM(RTRIM(var_evt_code)), '/', var_pas_msg_no, ':', CAST (var_rtn_err_code AS VARCHAR(8)))
                                INTO var_record_str;
                            /* -------------------------------------------- */
                            /* [Step.6.1]  update the status          -- */
                            
                            /* -------------------------------------------- */
                            IF par_poll_mode = 'A' AND (var_failure_code = 0 OR var_failure_code = 5) THEN
                                /* Auto-Polling Mode --- */
                                BEGIN
                                    /* --print '-->[UPD_RECORD_STATUS]UPDATE ehr_event_conf.last_poll_dtm=[%1!]------',@polled_last_sys_dtm */
                                    UPDATE ehr_event_conf
                                    SET last_poll_dtm = var_polled_last_sys_dtm
                                        WHERE config_id = 3 AND system_id = 'PAS_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
                                    /* To prevent any Reset Time-Marker */
                                    ;
                                END;
                            END IF;

                            IF var_rtn_err_code > 500000 THEN
                                SELECT
                                    CONCAT('Failed with reutnr error_code[ ', CAST (var_rtn_err_code AS VARCHAR(8)), ']')
                                    INTO var_error_msg;
                            END IF;
                            /* ---------------------------------- */
                            /* <6.2>  printing the log      -- */
                            
                            /* ---------------------------------- */
                            RAISE NOTICE '%', var_record_str;
                            /* -------------------------------------- */
                            /* [Step.7] Handle for Next Record  -- */
                            
                            /* -------------------------------------- */
                        END;

                        IF par_debug_mode = 'Y' THEN
                            RAISE NOTICE '[Step.7] NEXT_RECORD -->  with Prev Record: faillure_code<%>begin_tan<%> ', var_failure_code, var_begin_tran;
                        END IF;

                        IF var_failure_code = 1 THEN
                            RAISE NOTICE '---  Update ehr_event_in failure!!! ---';
                        ELSE
                            IF var_failure_code = 2 THEN
                                RAISE NOTICE '---  Update ehr_polling_exp  failure!!! ---';
                            ELSE
                                IF var_failure_code = 3 THEN
                                    RAISE NOTICE '---  Update suspend_upload_log failure!!! ---';
                                ELSE
                                    IF var_failure_code = 4 THEN
                                        RAISE NOTICE '--- System  failure!!! ---';
                                    ELSE
                                        IF var_failure_code = 5 THEN
                                            RAISE NOTICE '--- System  failure!!![5] SKIP the Record---';
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                        /* ----------------------------------------------------------- */
                        /* Current Record Process completed & COMMIT or ROLLBACK -- */
                        
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
                        /* ---------------------------------------------------------- */
                    END;
                END IF;
                /* ------------------------------------ */
                /* END of : if @ehr_txn_flag ='Y' */
            END;
            /* --if @debug_mode ='Y'	Print '[Step.8] FETCH_NEXT_CURSOR_REORD with re-initial var...' */
            /* ---------------------------------- */
            /* init for NEXT polling record -- */
            
            /* ---------------------------------- */
            /* 1). <HA-PMI Txn> Var : [transaction_log] -- */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_txn_sys_dtm, var_txn_hosp, var_txn_type, var_txn_name, var_txn_sex, var_txn_dob, var_txn_dob_str, var_txn_exact_dob, "var_txn_exact_dob_EDMY";
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_txn_hkid, var_txn_pky, var_txn_case, var_txn_upd_by, var_txn_src_sys, var_txn_doc_code, var_txn_doc_type, var_txn_doc_no, var_txn_discharge_dtm;
            SELECT
                NULL, NULL, NULL, NULL, NULL
                INTO var_txn_old_hkid, var_txn_old_pky, var_txn_old_name, var_txn_old_sex, var_txn_old_dob;
            /* 2). <eHR Patient List> Var: [ehr_patient_list] -- */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_ehr_no, var_ehr_start_date, var_ehr_end_date, var_ehr_hkic, var_ehr_doc_type, var_ehr_doc_no, var_ehr_sex, var_ehr_dob, var_ehr_exact_dob, var_ehr_surname, var_ehr_givenname, var_ehr_full_name;
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_ehr_pas_hkic, var_ehr_pas_pky, var_ehr_pas_doc_type, var_ehr_pas_doc_no, var_ehr_pas_sex, var_ehr_pas_dob, var_ehr_pas_exact_dob, var_ehr_pas_surname, var_ehr_pas_givenname, var_ehr_pas_full_name;
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_ehr_flag, var_ehr_flag_prev, var_ehr_flag_new, var_ehr_ppi_ind, var_ehr_non_ha_ind, var_ehr_smart_id;
            /* 3). <Data-Processing> Var -- */
            SELECT
                NULL, NULL, NULL, NULL, NULL
                INTO var_poll_hkid, var_poll_pky, var_to_hkid, var_to_pky, var_to_hkid_ehr_no;
            SELECT
                NULL, NULL, NULL, NULL
                INTO var_old_pas_hkic, var_old_pas_pky, var_old_pas_doc_type, var_old_pas_doc_no;
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_txn_dob_year, var_txn_dob_month, var_txn_dob_day, var_ehr_dob_year, var_ehr_dob_month, var_ehr_dob_day;
            SELECT
                NULL, NULL, NULL, NULL, NULL
                INTO var_pas_name_to_chk, var_ehr_name_to_chk, var_tmp_char, var_char_len, var_txn_doc_type_chk;
            SELECT
                NULL, NULL, NULL, NULL
                INTO var_pas_death_date, var_pas_death_time, var_pas_exact_death, var_pas_death_ind;
            /* 4). <Result/Output> Var -- */
            SELECT
                NULL, NULL, 0, 0, NULL
                INTO var_evt_ack, var_pas_msg_no, var_rtn_err_code, var_row_cnt, var_record_str;
            /* 5). <Polling Job Control Flag> Var -- */
            SELECT
                NULL, NULL, NULL
                INTO var_ack_notify_flag, var_doc_pair_participant, var_doc_pair_changed;
            SELECT
                'N', 'N', 'N', 'N', 'N', 'N'
                INTO var_ehr_txn_flag, var_me_flag, var_poll_hkid_ehr_handled, var_to_hkid_ehr_found, var_to_hkid_knock_door, var_knock_door_triggered;
            /* -------------------------------------------------------------------------------------------------------------------- */
            FETCH pas_txn_csr INTO var_txn_sys_dtm, var_txn_hosp, var_txn_type, var_txn_hkid, var_txn_pky, var_txn_name, var_txn_sex, var_txn_dob, var_txn_exact_dob, var_txn_old_hkid, var_txn_old_pky, var_txn_upd_by, var_txn_src_sys, var_txn_doc_code, var_txn_doc_no, var_txn_old_name, var_txn_old_sex, var_txn_old_dob, var_txn_case, var_txn_discharge_dtm;
        END LOOP;
        /* END of -- <while @@sqlstatus = 0> */
        CLOSE pas_txn_csr;
        /* -------------------------------------- */
        /* The polling_period @poll_start_dtm to @poll_stop_dtm completed -- */
        
        /* -------------------------------------- */
        /* Last event in polled : NO Record during polling period --> set polled_last_sys_dtm as poll_stop_dtm  --- */
        SELECT
            par_poll_stop_dtm
            INTO var_polled_last_sys_dtm;

        IF par_poll_mode = 'A' AND (var_failure_code = 0 OR var_failure_code = 5) THEN
            /* Auto-Polling Mode --- */
            BEGIN
                UPDATE ehr_event_conf
                SET last_poll_dtm = var_polled_last_sys_dtm
                    WHERE config_id = 3 AND system_id = 'PAS_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
                /* To prevent any Reset Time-Marker */
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
                /* Go <Step.1> */
                ;
            END;
        END IF;
        EXIT
        /* For non auto-polling mode */
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
    /* Update last poll_dtm records for NEXT polling time marker  --- */
    
    /* ---------------------------------------------------------- */
    IF par_poll_mode = 'A' AND (var_failure_code = 0 OR var_failure_code = 5) THEN
        /* ----- Auto-Polling Mode --- */
        BEGIN
            RAISE NOTICE '-->[EXIT]UPDATE ehr_event_conf.last_poll_dtm=[%] with failure_code[%]------', var_polled_last_sys_dtm, var_failure_code;
            UPDATE ehr_event_conf
            SET last_poll_dtm = var_polled_last_sys_dtm
                WHERE config_id = 3 AND system_id = 'PAS_POLL' AND COALESCE(last_poll_dtm, '20140501') < COALESCE(var_polled_last_sys_dtm, '20140501')
            /* --- To prevent any Reset Time-Marker */
            ;
        END;
    END IF;
END;
/* ### DEFNCOPY: END OF DEFINITION */
$procedure$
;


ALTER PROCEDURE "ehr_pas_txn_polling" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";