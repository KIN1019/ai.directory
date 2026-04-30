CREATE OR REPLACE PROCEDURE pas_me_mail_notify(INOUT pas_return_code int,IN par_in_hosp VARCHAR, IN par_in_oper_mode VARCHAR, IN par_in_ehr_mail VARCHAR, IN par_in_serial_no INTEGER DEFAULT null, IN par_debug_mode VARCHAR DEFAULT 'N',  INOUT p_refcur refcursor DEFAULT NULL)
 LANGUAGE plpgsql
AS $procedure$
/* -- */ /* ---C : chk move_episode_indicator ; R: Retrieve me_mail_record / U : update the me_mail_record.mail_status by serialno */
/* Y : chk me_mail_record.me_ehr_flag='Y' to send eMail for eHR patient ME notification */
/* will be used to update me_mail-record.mail_status */
DECLARE
    var_cur_hosp VARCHAR(3);
    var_last_poll_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_last_serial INTEGER;
    var_ehr_last_serial INTEGER;
    var_mail_addr VARCHAR(128);
    var_ehr_mail_addr VARCHAR(128);
    var_new_last_serial INTEGER;
    var_new_ehr_last_serial INTEGER;
    var_hosp_me_txn_flag VARCHAR(1);
    var_me_hosp VARCHAR(3);
    var_me_case VARCHAR(12);
    var_me_crt_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_me_from_pky VARCHAR(8);
    var_me_to_pky VARCHAR(8);
    var_me_crt_user VARCHAR(12);
    var_me_crt_sys VARCHAR(5);
    var_me_status VARCHAR(1);
    var_me_info_code VARCHAR(1);
    var_me_reason_code VARCHAR(1);
    var_me_reason_oth VARCHAR(255);
    /* ----------------- */
    var_me_from_hkid VARCHAR(12);
    var_me_from_ehr_no VARCHAR(12);
    var_me_to_hkid VARCHAR(12);
    var_me_to_ehr_no VARCHAR(12);
    var_me_ehr_mail_flag VARCHAR(1);
    var_cur_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_poll_start_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_poll_stop_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_polled_last_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_begin_tran VARCHAR(1);
    var_mail_crt_date VARCHAR(8);
    var_new_hosp_ehr_serial INTEGER;
    var_new_ehr_serial INTEGER;
    var_mail_status VARCHAR(1);
    var_ehr_mail_status VARCHAR(1);
    var_me_crt_status VARCHAR(1);
    var_me_upd_status VARCHAR(1);
    var_me_upd_user VARCHAR(12);
    var_me_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_me_txn_type VARCHAR(3);
    var_tmp_skip VARCHAR(1);
    hosp_csr CURSOR FOR
    SELECT
        hosp_code, last_poll_dtm, mail_last_serial, ehr_mail_last_serial, mail_addr, ehr_mail_addr
        FROM me_mail_conf
        WHERE hosp_code LIKE par_in_hosp;
    me_txn_csr CURSOR FOR
    SELECT
        hospital_code, case_no, create_dtm, from_patient_key, to_patient_key, create_user, create_system, move_status, info_source_code, reason_code, other_reason, update_user, update_dtm
        FROM move_episode_indicator
        WHERE ((create_dtm >= var_poll_start_dtm AND create_dtm <= var_poll_stop_dtm) OR
        /* ME Create Records for <me_mail_record> */
        /* --(update_dtm >= @poll_start_dtm AND update_dtm <= @poll_stop_dtm)  -- 20170321 : ME Update Records for <me_mail_record> */
        (update_dtm >= var_poll_start_dtm AND update_dtm <= var_poll_stop_dtm AND move_status IN ('O', 'S'))
        /* 20170615: ME Update(O->S;S->O)  Records for <me_mail_record> */
        ) AND hospital_code = var_cur_hosp
        ORDER BY create_dtm NULLS FIRST
    /* ----- Latest system_dtm will be used as last_poll_dtm to update ehr_event_conf.last_poll_dtm */
    ;
    sql$rowcount BIGINT;
BEGIN
    BEGIN
        BEGIN
            /* ------------------------------------- */
            /* Last update: 20140821 */
            
            /* --20141024 */
            
            /* --20141029 */
            
            /* --20150513  --@me_status='I' to handle normal ME mail as well --- */
            
            /* --20150601  --General eMail notification for all ME records (include 'M'/'C' status) */
            
            /* --20170321  --Enrich the content to include UPD me records */
            
            /* --20170329  --retrive the UPD fields */
            
            /* --20170519 */
            /* --20170615  -- */
            /* a)	All ME cases performed on the previous day with the latest status */
            /* b)   All OUTSTANDING cases performed BEFORE the PREVIOUS day with status changed : S --> O or O --> S */
            
            /* ------------------------------------- */
            /* --- me_mail_conf record--- */
            /* ---- move_episode_indicator record--- */
            
            /* ------------------------------ */
            
            /* --------------------------------- */
            IF UPPER(par_in_oper_mode) NOT IN ('C', 'R', 'U') THEN
                BEGIN
                    pas_return_code := - 1;
                    RAISE EXCEPTION '%', format('[EXIT]chk_mode[%s] should either C/R/U', par_in_oper_mode) USING ERRCODE := '500017';
                    RETURN;
                END;
            END IF;

            IF UPPER(par_in_ehr_mail) NOT IN ('Y', 'N') THEN
                BEGIN
                    pas_return_code := - 1;
                    RAISE EXCEPTION '%', format('[EXIT]chk_ehr_me[%s] should either Y/N', par_in_ehr_mail) USING ERRCODE := '500017';
                    RETURN;
                END;
            END IF;

            IF UPPER(par_in_hosp) = 'ALL' THEN
                SELECT
                    '%'
                    INTO par_in_hosp;
            END IF;
            /* Retrieve all hosp */
            
            /* ------------------------------------------------------------------------------- */
            /* --- A). Check move_episode_indicator and create me_mail_record if ME found --- */
            
            /* ------------------------------------------------------------------------------- */
            IF par_in_oper_mode = 'C' THEN
                BEGIN
                    SELECT
                        --aws_sapase_ext.conv_datetime_to_string('VARCHAR (8)'::TEXT, 'DATETIME'::TEXT, localtimestamp::TIMESTAMP WITHOUT TIME ZONE, 112)
                        to_char(timestamp_convert(localtimestamp),'YYYYMMDD')
                        INTO var_mail_crt_date;
                    /* --------------------------------------------------------------------- */
                    /* Cursor me_mail_conf/move_episode_indicator --- */
                    
                    /* --------------------------------------------------------------------- */
                    
                    /* ------------------------------------------------------------------------------ */
                    /* Check hospital by hospital : TRANSACTIONS committed Hospital by Hospital -- */
                    
                    /* ------------------------------------------------------------------------------ */
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_cur_hosp, var_last_poll_dtm, var_last_serial, var_ehr_last_serial, var_mail_addr, var_ehr_mail_addr, var_new_last_serial, var_new_ehr_last_serial;
                    SELECT
                        NULL, NULL, NULL
                        INTO var_poll_start_dtm, var_poll_stop_dtm, var_new_hosp_ehr_serial;
                    SELECT
                        'N', 'N'
                        INTO var_begin_tran, var_hosp_me_txn_flag;
                    OPEN hosp_csr;
                    FETCH hosp_csr INTO var_cur_hosp, var_last_poll_dtm, var_last_serial, var_ehr_last_serial, var_mail_addr, var_ehr_mail_addr;

                    WHILE (CASE
                        WHEN FOUND THEN 0
                        WHEN NOT FOUND THEN 2
                        ELSE 1
                    END) = 0 LOOP
                        /* ------------------------------------------------------ */
                        /* A.1) Polling setting for the Hospital -- */
                        
                        /* ------------------------------------------------------ */
                        SELECT
                            timestamp_convert(localtimestamp)
                            INTO var_cur_sys_dtm;
                        SELECT
                            COALESCE(var_last_poll_dtm, '20140101')
                            INTO var_poll_start_dtm;
                        /* --select @poll_stop_dtm = @cur_sys_dtm */
                        SELECT
                            - 60 * INTERVAL '1 second' + var_cur_sys_dtm::TIMESTAMP
                            INTO var_poll_stop_dtm;
                        /* --- To prevent the missing ME record WHICH NOT COMMMIT yet --- */
                        
                        /* --select @polled_last_sys_dtm = @poll_stop_dtm		---Should be set after processing */
                        
                        /* --select @new_last_serial =isnull(@last_serial,0) */
                        
                        /* --select @new_ehr_last_serial =isnull(@ehr_last_serial,0) */
                        
                        /*
                        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
                        if @@trancount = 0
                        			begin
                        				begin tran
                        				select @begin_tran='Y'
                        			end
                        */
                        IF par_debug_mode = 'Y' THEN
                            RAISE NOTICE 'hosp_csr:% From[%] To [%] with LastSerial[%].[%]--', var_cur_hosp, var_poll_start_dtm, var_poll_stop_dtm, var_last_serial, var_ehr_last_serial;
                        END IF;
                        /* ------------------------------------------------------ */
                        /* --A.2). Check ME record for the specified hospital @cur_hosp -- */
                        /* ------------------------------------------------------ */
                        SELECT
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'X', 'X'
                            INTO var_me_hosp, var_me_case, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_status, var_me_info_code, var_me_reason_code, var_me_reason_oth, var_me_from_hkid, var_me_from_ehr_no, var_me_to_hkid, var_me_to_ehr_no, var_me_ehr_mail_flag, var_new_ehr_serial, var_ehr_mail_status, var_mail_status;
                        SELECT
                            NULL, NULL, NULL, NULL, 'CRT', 'N'
                            INTO var_me_crt_status, var_me_upd_status, var_me_upd_user, var_me_upd_dtm, var_me_txn_type, var_tmp_skip;
                        /* ------------------------------------------------------ */
                        /* --- Init hosp.Serial -------- */
                        
                        /* ----------------------------------- */
                        SELECT
                            COALESCE(var_last_serial, 0)
                            INTO var_new_last_serial; /* --init hosp.last_serial */
                        SELECT
                            COALESCE(var_ehr_last_serial, 0)
                            INTO var_new_hosp_ehr_serial; /* --init hosp.ehr_serial */
                        /* ------------------------------------------------------ */
                        OPEN me_txn_csr;
                        FETCH me_txn_csr INTO var_me_hosp, var_me_case, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_status, var_me_info_code, var_me_reason_code, var_me_reason_oth, var_me_upd_user, var_me_upd_dtm;

                        WHILE (CASE
                            WHEN FOUND THEN 0
                            WHEN NOT FOUND THEN 2
                            ELSE 1
                        END) = 0 LOOP
                            /* -------------------------------------------------- */
                            /* 20170322 :  To define UPD */
                            /* A). <ME UPDATE> Record -- */
                            
                            /* -------------------------------------------------- */
                            /* 1). if upd_user <> crt_user OR */
                            /* 2). if upd_dtm later than crt_dtm 10 Min */
                            /* 3). Found <move_episode_indicator_log> record -- */
                            
                            /* -------------------------------------------------- */
                            /*
                            if  @me_upd_user <> @me_crt_user
                            -- OR @me_upd_dtm >= dateadd(mi,10,@me_crt_dtm)
                            OR exists (select 1 from move_episode_indicator_log	where hospital_code=@me_hosp and case_no =@me_case )
                            */
                            IF DATE_PART('days', var_me_upd_dtm::TIMESTAMP- var_me_crt_dtm::TIMESTAMP) >= 1 THEN
                                /* 20170615 : crt/upd NOT IN SAME day */
                                BEGIN
                                    SELECT
                                        'UPD'
                                        INTO var_me_txn_type;
                                    SELECT
                                        var_me_status
                                        INTO var_me_upd_status;
                                    /*
                                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                                    set rowcount 1
                                    */
                                    /* 1st record defined as crt_status */
                                    SELECT
                                        move_status
                                        INTO var_me_crt_status
                                        FROM move_episode_indicator_log
                                        WHERE hospital_code = var_me_hosp AND case_no = var_me_case
                                        ORDER BY create_dtm NULLS FIRST, update_dtm NULLS FIRST;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount = 0 THEN
                                        /* No me_log found */
                                        SELECT
                                            var_me_status
                                            INTO var_me_crt_status;
                                    END IF;
                                    /*
                                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                                    set rowcount 0
                                    */
                                END;
                            ELSE
                                /* B). <ME CREATE> Record -- */
                                BEGIN
                                    SELECT
                                        var_me_status
                                        INTO var_me_crt_status;
                                    SELECT
                                        NULL
                                        INTO var_me_upd_status; /* --Leave BLANK */
                                    SELECT
                                        NULL
                                        INTO var_me_upd_user;
                                    SELECT
                                        NULL
                                        INTO var_me_upd_dtm;
                                END;
                            END IF;
                            /* ------------------------------------------------------------------------------------------------------- */
                            /* 20170322 : SKIP the records before the <UPD> me implmentation -- */
                            
                            /* ------------------------------------------------------------------------------------------------------- */
                            /* --if datediff(day,@me_crt_dtm,@me_upd_dtm) >= 1    -- this <UPD> -CRT records already handled in previous day */
                            /* --if @me_crt_dtm > @poll_start_dtm			-- already handling, temporay SKIP */
                            
                            /* --if exists (select 1 from me_mail_record where me_hosp = @me_hosp and me_case = @me_case and me_crt_dtm =@me_crt_dtm /*and me_upd_dtm=@me_upd_dtm*/) */
                            
                            /* --begin */
                            
                            /* --	select @tmp_skip='Y' */
                            
                            /* --end */
                            
                            /* ------------------------------------------------------ */
                            /* To prevent creatie duplicate ME txn records -- */
                            
                            /* ------------------------------------------------------ */
                            
                            /* --if not exists (select 1 from me_mail_record where me_hosp = @me_hosp and me_case = @me_case and me_crt_dtm =@me_crt_dtm and me_upd_dtm=@me_upd_dtm) */
                            /* 20170615 : one ME mail within same mail -- */
                            IF NOT EXISTS (SELECT
                                1
                                FROM me_mail_record
                                WHERE mail_crt_date = var_mail_crt_date AND me_hosp = var_me_hosp AND me_case = var_me_case AND me_crt_dtm = var_me_crt_dtm) THEN
                                BEGIN
                                    /* --select @new_last_serial =isnull(@last_serial,0) + 1		--Inc for hosp.last_serial */
                                    SELECT
                                        'Y'
                                        INTO var_hosp_me_txn_flag;
                                    /* --if @debug_mode ='Y' print me_txn_csr:%1!.%2!.[%3!].%4!.[%5!].%6!--,@me_hosp,@me_case,@me_crt_dtm,@me_from_pky,@me_to_pky,@me_crt_user */
                                    /* -------------------------------------------- */
                                    SELECT
                                        hkid
                                        INTO var_me_from_hkid
                                        FROM patient
                                        WHERE patient_key = var_me_from_pky;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount = 0 THEN /* ---The patient may merged and not exist in patient table --- */
                                        SELECT
                                            old_hkid
                                            INTO var_me_from_hkid
                                            FROM hkpmi_pin_change_log
                                            WHERE old_patient_key = var_me_from_pky AND txn_dtm >= var_me_crt_dtm;
                                    END IF;
                                    SELECT
                                        hkid
                                        INTO var_me_to_hkid
                                        FROM patient
                                        WHERE patient_key = var_me_to_pky;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount = 0 THEN /* ---The patient may merged and not exist in patient table --- */
                                        SELECT
                                            old_hkid
                                            INTO var_me_to_hkid
                                            FROM hkpmi_pin_change_log
                                            WHERE old_patient_key = var_me_to_pky AND txn_dtm >= var_me_crt_dtm;
                                    END IF;
                                    /* ------------------------------------------------------ */
                                    /* ---A.3) Create ME mail records with <I> status --- */
                                    SELECT
                                        'I'
                                        INTO var_mail_status; /* ---all ME records need to handle ---20150513 */
                                    /* ---------------------------------------------------------------------------------------- */
                                    /* <@new_last_serial > : Use Same Serial for ALL <Today> Mail records created */
                                    
                                    /* ---------------------------------------------------------------------------------------- */
                                    SELECT
                                        mail_serial_no
                                        INTO var_new_last_serial
                                        FROM me_mail_record
                                        WHERE mail_crt_date = var_mail_crt_date AND me_hosp = var_me_hosp AND mail_status = 'I';
                                    /* --Assign new serial-- */
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount = 0 THEN
                                        BEGIN
                                            SELECT
                                                COALESCE(var_new_last_serial, 0) + 1
                                                INTO var_new_last_serial /* --Inc for hosp.last_serial for just new created record */;
                                        END;
                                    END IF;
                                    /* ------------------------------------------------------------------------------------------ */
                                    SELECT
                                        ehr_number
                                        INTO var_me_from_ehr_no
                                        FROM ehr_patient_list
                                        WHERE pas_pky = var_me_from_pky;
                                    SELECT
                                        ehr_number
                                        INTO var_me_to_ehr_no
                                        FROM ehr_patient_list
                                        WHERE pas_pky = var_me_to_pky;

                                    IF COALESCE(var_me_from_ehr_no, 'NULL') = 'NULL' AND COALESCE(var_me_to_ehr_no, 'NULL') = 'NULL' THEN
                                        SELECT
                                            'N'
                                            INTO var_me_ehr_mail_flag;
                                    ELSE
                                        SELECT
                                            'Y'
                                            INTO var_me_ehr_mail_flag;
                                    END IF;
                                    /* ------------------------------------------------------------------------------------------ */
                                    IF var_me_ehr_mail_flag = 'Y' THEN
                                        BEGIN
                                            IF var_me_status IN ('O', 'S') THEN /* ---20150601 */
                                                SELECT
                                                    'I'
                                                    INTO var_ehr_mail_status;
                                            ELSE
                                                BEGIN
                                                    SELECT
                                                        'X'
                                                        INTO var_ehr_mail_status;
                                                END;
                                            END IF;
                                            /* ---------------------------------------------------------------------------------------- */
                                            /* B. <@new_ehr_serial > : */
                                            
                                            /* ---------------------------------------------------------------------------------------- */
                                            /* Diff Serial for different eHR patient : -- */
                                            /* CHeck/Re-Use Serial assigned for this eHR patient or not for same mail_crt_date --- */
                                            /* Ohterwise, @new_ehr_last_serial + 1 assigned --- */
                                            
                                            /* ---------------------------------------------------------------------------------------- */
                                            IF var_ehr_mail_status = 'I' THEN
                                                /* B.1) eHR ME record need to send */
                                                BEGIN
                                                    SELECT
                                                        ehr_mail_serial_no
                                                        INTO var_new_ehr_serial
                                                        FROM me_mail_record
                                                        WHERE mail_crt_date = var_mail_crt_date AND me_hosp = var_me_hosp AND ehr_mail_flag = 'Y' AND ehr_mail_status = 'I';
                                                    /* 20170418 BugFix : Only Inc for sending record with <I> status */
                                                    /* ehr_serial will be NULL if <X> mail_status */
                                                    /* and (me_from_hkid in (@me_from_hkid,@me_to_hkid) or me_to_hkid in (@me_from_hkid,@me_to_hkid))  --?? */
                                                    
                                                    /* --Assign new serial-- */
                                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                    IF sql$rowcount = 0 THEN
                                                        BEGIN
                                                            SELECT
                                                                COALESCE(var_new_hosp_ehr_serial, 0) + 1
                                                                INTO var_new_hosp_ehr_serial; /* --Inc for hosp.last_serial for just new created record */
                                                            SELECT
                                                                var_new_hosp_ehr_serial
                                                                INTO var_new_ehr_serial;
                                                        END;
                                                    END IF;
                                                END;
                                            ELSE
                                                BEGIN
                                                    /* B.2) eHR ME record NOT need to send */
                                                    SELECT
                                                        NULL
                                                        INTO var_new_ehr_serial;
                                                END;
                                            END IF;
                                            /* -------------------------------- */
                                            /* --if @debug_mode ='Y' print 9999:%1!.%2!.[%3!].%4!.[%5!].%6!.[%7!].[%8!].%9!,@me_hosp,@me_case,@me_from_hkid,@me_to_hkid,@new_hosp_ehr_serial,@new_ehr_serial,@me_from_ehr_no,@me_to_ehr_no,@me_ehr_mail_flag */
                                        END;
                                    END IF;
                                    /* if @me_ehr_mail_flag ='Y' */
                                    
                                    /* ------------------------------------------------------------------------------------------ */
                                    
                                    /* --if @tmp_skip !='Y'    --20170322 -- */
                                    
                                    /* --BEGIN */
                                    BEGIN
                                        INSERT INTO me_mail_record (me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_user, me_crt_sys, me_status, me_info_code, me_reason_code, me_reason_oth, ehr_mail_flag, ehr_from_ehr_no, ehr_to_ehr_no, mail_status, ehr_mail_status, mail_serial_no, ehr_mail_serial_no, mail_addr, ehr_mail_addr, mail_crt_date, sys_dtm, me_upd_status, me_upd_user, me_upd_dtm)
                                        VALUES (var_me_hosp, var_me_case, var_me_from_hkid, var_me_to_hkid, var_me_crt_dtm, var_me_crt_user, var_me_crt_sys, var_me_crt_status, /* @me_status, */ var_me_info_code, var_me_reason_code, var_me_reason_oth, var_me_ehr_mail_flag, var_me_from_ehr_no, var_me_to_ehr_no, var_mail_status, var_ehr_mail_status, var_new_last_serial, var_new_ehr_serial, var_mail_addr, var_ehr_mail_addr, var_mail_crt_date, var_cur_sys_dtm, var_me_upd_status, var_me_upd_user, var_me_upd_dtm);
                                        var_error := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                var_error := 1;
                                    END;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                    var_rowcount := sql$rowcount;

                                    IF var_error <> 0 OR var_rowcount = 0 THEN

                                        IF var_begin_tran = 'Y' THEN
                                            --ROLLBACK;
                                            RAISE EXCEPTION '';
                                        END IF;
                                        IF par_in_oper_mode = 'R' THEN
                                            DROP TABLE t$tmp_mail_record;
                                        END IF;
                                        pas_return_code := - 1;
                                        RETURN;
                                    END IF;

                                    IF par_debug_mode = 'Y' THEN
                                        RAISE NOTICE 'me_txn_csr:%.%.[%].[%].[%->%].ehr_mail_flag[%].[%].[%]', var_me_hosp, var_me_case, var_me_crt_dtm, var_me_from_hkid, var_me_to_hkid, var_new_ehr_serial, var_me_ehr_mail_flag, var_me_from_ehr_no, var_me_to_ehr_no;
                                    END IF;
                                    /* --END */
                                END;
                            END IF;
                            /* --- END of : 	if not exists (select 1 from me_mail_record) */
                            SELECT
                                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'X', 'X'
                                INTO var_me_hosp, var_me_case, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_status, var_me_info_code, var_me_reason_code, var_me_reason_oth, var_me_from_hkid, var_me_from_ehr_no, var_me_to_hkid, var_me_to_ehr_no, var_me_ehr_mail_flag, var_new_ehr_serial, var_ehr_mail_status, var_mail_status;
                            SELECT
                                NULL, NULL, NULL, NULL, 'CRT', 'N'
                                INTO var_me_crt_status, var_me_upd_status, var_me_upd_user, var_me_upd_dtm, var_me_txn_type, var_tmp_skip;
                            FETCH me_txn_csr INTO var_me_hosp, var_me_case, var_me_crt_dtm, var_me_from_pky, var_me_to_pky, var_me_crt_user, var_me_crt_sys, var_me_status, var_me_info_code, var_me_reason_code, var_me_reason_oth, var_me_upd_user, var_me_upd_dtm;
                        END LOOP; /* ---END me_txn_csr */
                        CLOSE me_txn_csr;
                        /* MUST be Closed for each hospital ! */
                        /* DEALLOCATE CURSOR me_txn_csr -- MUST be deallocated after all hospital processed ! */
                        
                        /* --------------------------------------------------- */
                        SELECT
                            var_new_hosp_ehr_serial
                            INTO var_new_ehr_last_serial;
                        /* ----------------------------------------------------------------------------------- */
                        /* ---A.4) Update the me_mail_conf. info if ME records created for the specific Hosp--- */
                        /* ------------------------------------------------------------------------------------ */
                        /* --if @hosp_me_txn_flag ='Y'   --20150602 */
                        /* --begin */
                        SELECT
                            var_poll_stop_dtm
                            INTO var_polled_last_sys_dtm;

                        IF par_debug_mode = 'Y' THEN
                            RAISE NOTICE 'hosp_csr:upd me_mail_conf: %.with new LastSerial[%].[%] last polled dtm[%]--', var_cur_hosp, var_new_last_serial, var_new_ehr_last_serial, var_polled_last_sys_dtm;
                        END IF;

                        BEGIN
                            UPDATE me_mail_conf
                            SET mail_last_serial = var_new_last_serial, ehr_mail_last_serial = var_new_ehr_last_serial, last_poll_dtm = var_polled_last_sys_dtm, sys_dtm = timestamp_convert(localtimestamp) /* ---@cur_sys_dtm */
                                WHERE hosp_code = var_cur_hosp;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF var_error <> 0 OR var_rowcount = 0 THEN
                            --EXIT return_error;
                            IF var_begin_tran = 'Y' THEN
                                --ROLLBACK;
                                RAISE EXCEPTION '';
                            END IF;
                            IF par_in_oper_mode = 'R' THEN
                                DROP TABLE t$tmp_mail_record;
                            END IF;
                            pas_return_code := - 1;
                            RETURN;
                        END IF;
                        /* --end */
                        /* -------------------------------------------------------------------------------- */
                        /* Check hospital by hospital : TRANSACTIONS committed Hospital by Hospital -- */
                        
                        /* ------------------------------------------------------------------------------- */
                        IF var_begin_tran = 'Y' THEN
                            /*
                            [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                            COMMIT
                            */
                            BEGIN
                                return;
                            END;
                        END IF;
                        SELECT
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                            INTO var_cur_hosp, var_last_poll_dtm, var_last_serial, var_ehr_last_serial, var_mail_addr, var_ehr_mail_addr, var_new_last_serial, var_new_ehr_last_serial;
                        SELECT
                            NULL, NULL, NULL
                            INTO var_poll_start_dtm, var_poll_stop_dtm, var_new_hosp_ehr_serial;
                        SELECT
                            'N', 'N'
                            INTO var_begin_tran, var_hosp_me_txn_flag;
                        FETCH hosp_csr INTO var_cur_hosp, var_last_poll_dtm, var_last_serial, var_ehr_last_serial, var_mail_addr, var_ehr_mail_addr;
                    END LOOP;
                    /* --- END hosp_csr */
                    CLOSE hosp_csr;
                    -- EXIT return_normal;
                    IF var_begin_tran = 'Y' THEN
                    /*
                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                    COMMIT
                    */
                        BEGIN
                            return;
                        END;
                    END IF;
                    IF par_in_oper_mode = 'R' THEN
                        DROP TABLE t$tmp_mail_record;
                    END IF;
                    pas_return_code := 0;
                    RETURN;
                END;
            END IF; /* ---ENDí@if @chk_mode ='C' */
            /* ------------------------------------------------------------------------------- */
            /* --- B). Check me_mail_record with mail_status ='I' and update the mail_status ='P' after retrieving the record */
            
            /* ------------------------------------------------------------------------------- */
            IF par_in_oper_mode = 'R' THEN
                BEGIN
                    /* ------------------------------------------ */
                    /* --B.1) Temporary Result Table ------------ */
                    /* ------------------------------------------ */
                    CREATE TEMPORARY TABLE t$tmp_mail_record
                    (me_hosp VARCHAR(3) NULL,
                        me_case VARCHAR(12) NULL,
                        me_from_hkid VARCHAR(12) NULL,
                        me_to_hkid VARCHAR(12) NULL,
                        me_crt_dtm TIMESTAMP WITHOUT TIME ZONE NULL,
                        me_crt_sys VARCHAR(12) NULL,
                        me_info_code VARCHAR(1) NULL,
                        /* Checked with Patient/Refered by other hospitals */
                        me_info_desc VARCHAR(30) NULL, /* --<Referred by others> */
                        me_status VARCHAR(1) NULL,
                        /* <Same patient/Different patient> */
                        me_status_desc VARCHAR(20) NULL,
                        /* <Same patient/Different patient> */
                        me_reason_code VARCHAR(1) NULL,
                        /* for Different Patient Only -- */
                        me_reason_oth VARCHAR(255) NULL,
                        /* FreeText input by user -- */
                        me_reason_desc VARCHAR(255) NULL,
                        me_crt_user VARCHAR(12) NULL,
                        /* ----------------------------------- */
                        mail_serial_no INTEGER NULL,
                        mail_addr VARCHAR(128) NULL,
                        ehr_mail_flag VARCHAR(1) NULL,
                        me_upd_status VARCHAR(1) NULL, /* --20170329 */
                        me_upd_status_desc VARCHAR(20) NULL,
                        /* <Same patient/Different patient> */
                        me_upd_user VARCHAR(12) NULL,
                        me_upd_dtm TIMESTAMP WITHOUT TIME ZONE NULL);
                    CREATE UNIQUE INDEX t$tmp_mail_record_pky ON t$tmp_mail_record
                        (me_hosp, me_case, me_crt_dtm); /* ---Unique Index for move_episode_indicator */
                    /* ------------------------------------------ */
                    /* B.2.1) eHR ME Result Table ------------ */
                    
                    /* ------------------------------------------ */
                    IF par_in_ehr_mail = 'Y' THEN
                        BEGIN
                            SELECT
                                timestamp_convert(localtimestamp)
                                INTO var_cur_sys_dtm;
                            INSERT INTO t$tmp_mail_record (me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_sys, me_info_code, me_status, me_reason_code, me_reason_oth, me_crt_user, mail_serial_no, mail_addr, ehr_mail_flag, me_upd_status, me_upd_user, me_upd_dtm)
                            SELECT
                                me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_sys, me_info_code, me_status, me_reason_code, me_reason_oth, me_crt_user, ehr_mail_serial_no, ehr_mail_addr, ehr_mail_flag, me_upd_status, me_upd_user, me_upd_dtm
                                FROM me_mail_record
                                WHERE ehr_mail_status = 'I' AND /* ---eHR ME records only */ me_hosp LIKE par_in_hosp AND ehr_mail_flag = 'Y' /* --ehr mail flag */
                                ORDER BY me_hosp NULLS FIRST, ehr_mail_serial_no NULLS FIRST, me_crt_dtm NULLS FIRST;
                            /* ----- No email address for hospital */
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_rowcount = 0 THEN
                                /* --- NO ME mail record */
                                BEGIN
                                    OPEN p_refcur FOR
                                    SELECT
                                        me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_sys, me_info_desc, me_status, me_reason_desc, me_crt_user, mail_serial_no, mail_addr, ehr_mail_flag, me_upd_status, me_upd_user, me_upd_dtm
                                        FROM t$tmp_mail_record
                                        WHERE 1 = 2;
                                    -- EXIT return_normal;
                                    IF var_begin_tran = 'Y' THEN
                                    /*
                                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                                    COMMIT
                                    */
                                        BEGIN
                                            return;
                                        END;
                                    END IF;
                                    IF par_in_oper_mode = 'R' THEN
                                        DROP TABLE t$tmp_mail_record;
                                    END IF;
                                    pas_return_code := 0;
                                    RETURN;                                    
                                END;
                            END IF;
                            /*
                            -----------------------------------------------------------------
                            ------------Insert the Ohter Hosps ME record  as Well ----------
                            -----------------------------------------------------------------
                            insert into #tmp_mail_record
                            	  (me_hosp,me_case,me_from_hkid,me_to_hkid,me_crt_dtm,me_crt_sys,me_info_code,me_status,me_reason_code,me_reason_oth,me_crt_user,
                            		mail_serial_no, mail_addr,ehr_mail_flag)
                            select m1.me_hosp,m1.me_case,m1.me_from_hkid,m1.me_to_hkid,m1.me_crt_dtm,m1.me_crt_sys,m1.me_info_code,m1.me_status,m1.me_reason_code,m1.me_reason_oth,m1.me_crt_user,
                            	m1.mail_serial_no, m1.mail_addr,m1.ehr_mail_flag
                            from me_mail_record m1, me_mail_record m2
                            where  m1.me_hosp != m2.me_hosp			--Other Hospital Case
                            	and m1.ehr_mail_flag ='Y'		--ehr mail flag
                            	and m1.mail_crt_date *= m2.mail_crt_date
                            	--and m1.ehr_mail_status='I'		---eHR ME records only
                            	and (m1.me_from_hkid *= m2.me_from_hkid or m1.me_from_hkid *=m2.me_to_hkid
                            		or m1.me_to_hkid *= m2.me_to_hkid or m1.me_to_hkid *=m2.me_from_hkid )
                            */
                            /* --------------------------------------------------- */
                            /* --B.2.1)  Update me_mail_record.ehr_mail_status  -- */
                            /* --------------------------------------------------- */
                            /*
                            [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
                            if @@trancount = 0
                            			begin
                            				begin tran
                            				select @begin_tran='Y'
                            			end
                            */ /* --ehr mail flag */
                            BEGIN
                                UPDATE me_mail_record
                                SET ehr_mail_status = 'P',
                                /* ehr_mail_status = Processing */
                                ehr_mail_upd_dtm = var_cur_sys_dtm
                                    WHERE ehr_mail_status = 'I' AND
                                    /* eHR ME records only */
                                    me_hosp LIKE par_in_hosp AND ehr_mail_flag = 'Y';
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_error <> 0 THEN /* ---or @rowcount = 0 */
                                -- EXIT return_error;
                                IF var_begin_tran = 'Y' THEN
                                    --ROLLBACK;
                                    RAISE EXCEPTION '';
                                END IF;
                                IF par_in_oper_mode = 'R' THEN
                                    DROP TABLE t$tmp_mail_record;
                                END IF;
                                pas_return_code := - 1;
                                RETURN;

                            END IF;
                        END;
                    /* ------------------------------------------ */
                    /* B.3.1) all ME Result Table ------------ */
                    
                    /* ------------------------------------------ */
                    ELSE
                        BEGIN
                            INSERT INTO t$tmp_mail_record (me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_sys, me_info_code, me_status, me_reason_code, me_reason_oth, me_crt_user, mail_serial_no, mail_addr, ehr_mail_flag, me_upd_status, me_upd_user, me_upd_dtm)
                            SELECT
                                me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_sys, me_info_code, me_status, me_reason_code, me_reason_oth, me_crt_user, mail_serial_no, mail_addr, ehr_mail_flag, me_upd_status, me_upd_user, me_upd_dtm /* --Normal ME mail conf */
                                FROM me_mail_record
                                WHERE mail_status = 'I' AND
                                /* all ME records */
                                me_hosp LIKE par_in_hosp
                                ORDER BY me_hosp NULLS FIRST, me_crt_dtm NULLS FIRST;
                            /* ----- No email address for hospital */
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_rowcount = 0 THEN
                                /* --- NO ME mail record */
                                BEGIN
                                    OPEN p_refcur FOR
                                    SELECT
                                        me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_sys, me_info_desc, me_status, me_reason_desc, me_crt_user, mail_serial_no, mail_addr, ehr_mail_flag, me_upd_status, me_upd_user, me_upd_dtm
                                        FROM t$tmp_mail_record
                                        WHERE 1 = 2;
                                    -- EXIT return_normal;
                                    IF var_begin_tran = 'Y' THEN
                                    /*
                                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                                    COMMIT
                                    */
                                        BEGIN
                                            return;
                                        END;
                                    END IF;
                                    IF par_in_oper_mode = 'R' THEN
                                        DROP TABLE t$tmp_mail_record;
                                    END IF;
                                    pas_return_code := 0;
                                    RETURN;                                                              

                                END;
                            END IF;
                            /* ----------------------------------------------- */
                            /* --B.3.2)  Update me_mail_record.mail_status --- */
                            /* ---------------------------------------------- */
                            /*
                            [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
                            if @@trancount = 0
                            			begin
                            				begin tran
                            				select @begin_tran='Y'
                            			end
                            */
                            BEGIN
                                UPDATE me_mail_record
                                SET mail_status = 'P',
                                /* mail_status = Processing */
                                mail_upd_dtm = var_cur_sys_dtm
                                    WHERE mail_status = 'I' AND
                                    /* all ME records only */
                                    me_hosp LIKE par_in_hosp;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_error <> 0 THEN /* ---or @rowcount = 0 */
                                -- EXIT return_error;

                                IF var_begin_tran = 'Y' THEN
                                    --ROLLBACK;
                                    RAISE EXCEPTION '';
                                END IF;
                                IF par_in_oper_mode = 'R' THEN
                                    DROP TABLE t$tmp_mail_record;
                                END IF;
                                pas_return_code := - 1;
                                RETURN;

                            END IF;
                        END;
                    END IF;
                    /* ------------------------------------------------------------------------------------------------ */
                    /* ---B.4 : Update the Description --- */
                    /* ------------------------------------------------------------------------------------------------ */
                    UPDATE t$tmp_mail_record AS m
                    SET me_info_desc = c.description
                    FROM move_episode_code_table AS c
                        WHERE c.type = 'information_source' AND c.code = m.me_info_code;
                    /* ------------------------------------------------------------------------------------------------ */
                    UPDATE t$tmp_mail_record AS m
                    SET me_reason_desc = c.description
                    FROM move_episode_code_table AS c
                        WHERE c.type = 'reason' AND c.code = m.me_reason_code AND m.me_reason_code != '5';
                    UPDATE t$tmp_mail_record
                    SET me_reason_desc = me_reason_oth
                        WHERE me_reason_code = '5';
                    /* ------------------------------------------------------------------------------------------------ */
                    UPDATE t$tmp_mail_record
                    SET me_crt_sys = 'IPAS'
                        WHERE me_crt_sys = 'ADT';
                    /* ----------------------------------------------------------------------------------------------- */
                    UPDATE t$tmp_mail_record
                    SET me_status_desc = 'Same Patient'
                        WHERE me_status = 'S';
                    UPDATE t$tmp_mail_record
                    SET me_status_desc = 'Different Patient'
                        WHERE me_status = 'O';
                    UPDATE t$tmp_mail_record
                    SET me_upd_status_desc = 'Same Patient'
                        WHERE me_upd_status = 'S';
                    UPDATE t$tmp_mail_record
                    SET me_upd_status_desc = 'Different Patient'
                        WHERE me_upd_status = 'O';
                    /* ------------------------------------------ */
                    /* --B.5) Retrieve from Result Table -------- */
                    /* ------------------------------------------ */
                    BEGIN
                        OPEN p_refcur FOR
                        SELECT
                            me_hosp, me_case, me_from_hkid, me_to_hkid, me_crt_dtm, me_crt_sys, me_info_desc, me_status, me_reason_desc, me_crt_user, mail_serial_no, mail_addr, ehr_mail_flag, me_upd_status, me_upd_user, me_upd_dtm
                            FROM t$tmp_mail_record
                            ORDER BY me_hosp NULLS FIRST, mail_serial_no NULLS FIRST, me_crt_dtm NULLS FIRST;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;

                    IF var_error <> 0 THEN /* --or @rowcount = 0 */
                        -- EXIT return_error;
                        IF var_begin_tran = 'Y' THEN
                            --ROLLBACK;
                            RAISE EXCEPTION '';
                        END IF;
                        IF par_in_oper_mode = 'R' THEN
                            DROP TABLE t$tmp_mail_record;
                        END IF;
                        pas_return_code := - 1;
                        RETURN;   
                    END IF;
                    /* --NOT allowed within BEGIN TRAN Session --- */
                    /* --drop table #tmp_mail_record   ---Msg 2762,The 'DROP TABLE' command is not allowed within a multi-statement transaction in the 'tempdb' database. */
                    -- EXIT return_normal;
                    IF var_begin_tran = 'Y' THEN
                    /*
                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                    COMMIT
                    */
                        BEGIN
                            return;
                        END;
                    END IF;
                    IF par_in_oper_mode = 'R' THEN
                        DROP TABLE t$tmp_mail_record;
                    END IF;
                    pas_return_code := 0;
                    RETURN;                    
                END;
            END IF;
            /* End @in_oper_mode ='R' */
            
            /* ------------------------------------------------------------------------------- */
            /* --- C). Check me_mail_record with mail_status ='I' and update the mail_status ='P' after retrieving the record */
            
            /* ------------------------------------------------------------------------------- */
            IF par_in_oper_mode = 'U' THEN
                BEGIN
                    SELECT
                        timestamp_convert(localtimestamp)
                        INTO var_cur_sys_dtm;
                    /*
                    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
                    if @@trancount = 0
                    		begin
                    			begin tran
                    			select @begin_tran='Y'
                    		end
                    */
                    /* ----------------------------------------------------------------------------------------- */
                    /* --C.1  Update me_mail_record.ehr_mail_status  and me_mail_conf.ehr_mail_last_sent_dtm -- */
                    /* ------------------------------------------------------------------------------------ */
                    IF par_in_ehr_mail = 'Y' THEN
                        BEGIN
                            BEGIN
                                UPDATE me_mail_record
                                SET ehr_mail_status = 'S',
                                /* ehr_mail_status = Completed */
                                ehr_mail_upd_dtm = var_cur_sys_dtm
                                    WHERE ehr_mail_status = 'P' AND
                                    /* ehr_mail_status from Processing */
                                    me_hosp = par_in_hosp AND ehr_mail_serial_no = par_in_serial_no AND /* --ehr_mail_serial_no */ ehr_mail_flag = 'Y';
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_error <> 0 THEN /* --or @rowcount = 0 */
                                -- EXIT return_error;
                                IF var_begin_tran = 'Y' THEN
                                    --ROLLBACK;
                                    RAISE EXCEPTION '';
                                END IF;
                                IF par_in_oper_mode = 'R' THEN
                                    DROP TABLE t$tmp_mail_record;
                                END IF;
                                pas_return_code := - 1;
                                RETURN;                                
                            END IF;
                            UPDATE me_mail_conf
                            SET ehr_mail_last_sent_dtm = var_cur_sys_dtm, sys_dtm = var_cur_sys_dtm
                                WHERE hosp_code = par_in_hosp;
                            /* --select @error = @@error, @rowcount = @@rowcount */
                            /* --if @error <> 0 --or @rowcount = 0 */
                            /* --	GOTO RETURN_ERROR */
                            -- EXIT return_normal;
                            IF var_begin_tran = 'Y' THEN
                            /*
                            [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                            COMMIT
                            */
                                BEGIN
                                    return;
                                END;
                            END IF;
                            IF par_in_oper_mode = 'R' THEN
                                DROP TABLE t$tmp_mail_record;
                            END IF;
                            pas_return_code := 0;
                            RETURN;                                                
                        END;
                    /* --------------------------------------------------- */
                    /* --C.2  Update me_mail_record.mail_status / me_mail_conf.mail_last_sent_dtm  -- */
                    /* --------------------------------------------------- */
                    ELSE
                        BEGIN
                            BEGIN
                                UPDATE me_mail_record
                                SET mail_status = 'S',
                                /* mail_status = Completed */
                                mail_upd_dtm = var_cur_sys_dtm
                                    WHERE mail_status = 'P' AND
                                    /* mail_status from Processing */
                                    me_hosp = par_in_hosp AND mail_serial_no = par_in_serial_no;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_error <> 0 THEN /* --or @rowcount = 0 */
                                -- EXIT return_error;
                                IF var_begin_tran = 'Y' THEN
                                    --ROLLBACK;
                                    RAISE EXCEPTION '';
                                END IF;
                                IF par_in_oper_mode = 'R' THEN
                                    DROP TABLE t$tmp_mail_record;
                                END IF;
                                pas_return_code := - 1;
                                RETURN;   
                            END IF;
                            UPDATE me_mail_conf
                            SET mail_last_sent_dtm = var_cur_sys_dtm, sys_dtm = var_cur_sys_dtm
                                WHERE hosp_code = par_in_hosp;
                            /* --select @error = @@error, @rowcount = @@rowcount */
                            /* --if @error <> 0 --or @rowcount = 0 */
                            /* --	GOTO RETURN_ERROR */
                            -- EXIT return_normal;
                            IF var_begin_tran = 'Y' THEN
                            /*
                            [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                            COMMIT
                            */
                                BEGIN
                                    return;
                                END;
                            END IF;
                            IF par_in_oper_mode = 'R' THEN
                                DROP TABLE t$tmp_mail_record;
                            END IF;
                            pas_return_code := 0;
                            RETURN;
                        END;
                    END IF;
                END;
            END IF;
            /* ------------------------- */
        END;
    END;
    /*
    
    DROP TABLE IF EXISTS t$tmp_mail_record;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

ALTER PROCEDURE "pas_me_mail_notify" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";