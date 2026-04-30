-- DROP FUNCTION hkpmi.ehr_read_event_out(bpchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hkpmi.ehr_read_event_out(par_ack_sys VARCHAR, par_from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, par_to_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_run_flag VARCHAR(1);
    var_poll_count INTEGER;
    var_return_error_code INTEGER;
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    "var_DUMMY_EHR_NO" VARCHAR(12);
BEGIN
    <<exit_error>>
    BEGIN
        /* -------------------------------- */
        /* Used by : */
        /* <EHR_ACK_WS> - To find any <ehr_event_out> with I status , then call reply eHR HL7 msg/call ePR WS */
        /* DateRange allowed : 90 days */
        /* Default Batch-Read count : 50 records */
        
        /* ---tU_ehr_event_out NOT allow 100 records to update at same time .. */
        /* Update  <EHR_ACK_WS.last_ehr_event_out_dtm> -- */
        
        /* -------------------------------- */
        
        /* ----LastUpdate on 20140702 --- */
        
        /* --20141126 : Avoid Duplicate POlling on Records which already marked as 'P' --- */
        /* --20141204 -- To fix SAME Txn DTM for same patient issue  but different result : <E00030-474501 / E00030-474500> --order by txn_dtm + msg_no */
        /* --20150205 -- Return empty resultset when no record found */
        /* --20150211 -- for HA-A47  Events */
        
        /* --20150319 : DUMMY Events :<029438615304> */
        
        /* --20150521 : OLD MKC Shouldbe EHR MajorKey ... */
        
        /* --20160329 : [eHR]Auto-recover if 'E' found in previous 10Mins which caused by TIME-OUT issues -- */
        
        /* --20160623 : [ePR]Auto-recover if 'E' found in previous 10Mins which caused by TIME-OUT issues -- */
        
        /* --20160819 : BugFix for A47 to eHR - pas_doc_par is (BC/blank docno), it should be (ID/pas_hkic) */
        
        /* --20161108 : BugFix for A47 to eHR - pas_doc_par is (NA/ehr_hkic is not null), it should be (ID/ehr_hkic) */
        
        /* --20161122 : BugFix for A47 to eHR - turn BE / BN / BC to ID */
        
        /* --20170223 : BugFix for A47 to eHR - turn BE / BN / BC to ID */
        
        /* --20170622 : HKIC (ID/BC/BN/BE + HKIC#) or Doc.Pair (Doc.Type + Doc_no), they canÔÇÖt be coexisted   -- */
        
        /* --20170918 : */
        
        /* --20180105 : TO prevent EVENT_OUT stuck due to [A47 Event to eHR: NA/Blank on Doc.Type] */
        
        /* --20191018 : Add RIS Support */
        /* 20210913 :BackDate allowed period to 1.5 Years (540 Day) as request from eHR side/EH4 -- */
        
        /* ------------------------------------------------------------------------------ */
        /* 20210927 : TO prevent table scan on ehr_event_out  caused by backdate extented to 540 Days -- */
        /* XIE2_ehr_event_out  evt_ack_status_ehr, txn_dtm */
        /* XIE3_ehr_event_out  evt_ack_status_epr, txn_dtm */
        /* XIE4_ehr_event_out  evt_ack_status_ris, txn_dtm */
        
        /* ------------------------------------------------------------------------------ */
        
        /* ---init --- */
        SELECT
            'N'
            INTO var_run_flag;
        SELECT
            localtimestamp
            INTO var_upd_dtm;
        SELECT
            '029438615304'
            INTO "var_DUMMY_EHR_NO";

        IF par_from_date IS NULL THEN
            BEGIN
                SELECT
                    to_char(localtimestamp::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                    INTO par_from_date;
                /* ---select @from_date = dateadd(dd,-1,@from_date) */
                /* --select @from_date = dateadd(dd,-180,@from_date)    ----BackDate to 90 Days */
                SELECT
                    - 540 * INTERVAL '1 day' + par_from_date::TIMESTAMP
                    INTO par_from_date /* ----BackDate to 90 Days */;
            END;
        END IF;

        IF par_to_date IS NULL THEN
            SELECT
                localtimestamp
                INTO par_to_date;
        ELSE
            SELECT
                1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
                INTO par_to_date;
        END IF;
        /* --if @ack_sys not in ('EPR','EHR') */
        IF par_ack_sys NOT IN ('EPR', 'EHR', 'RIS') THEN
            /* --- RIS Support */
            BEGIN
                SELECT
                    500009
                    INTO var_return_error_code;
                EXIT exit_error;
            END;
        END IF;
        /* --if datediff(dd,@from_date,@to_date) > 30  ---- Date Range 30 Days ---- */
        /* --if datediff(dd,@from_date,@to_date) > 180  ---- Date Range 30 Days ---- */

        IF DATE_PART('days', par_to_date::TIMESTAMP, par_from_date::TIMESTAMP) > 540 THEN
            /* ---- Date Range 30 Days ---- */
            BEGIN
                SELECT
                    500011
                    INTO var_return_error_code;
                EXIT exit_error;
            END;
        END IF;
        /* ------------------------------------------------------ */
        /* --- <Step.1> Check polling flag */
        
        /* ------------------------------------------------------ */
        
        /* --1.1) Start to process 'I'-Event if run_flag =Y */
        SELECT
            COALESCE(run_flag, 'N'), COALESCE(poll_count, 50)
            INTO var_run_flag, var_poll_count
            FROM ehr_event_conf
            WHERE config_id = 6 AND system_id = 'EHR_ACK_WS';

        IF (var_run_flag <> 'Y') THEN
            BEGIN
                SELECT
                    500022
                    INTO var_return_error_code;
                EXIT exit_error;
            END;
        END IF;
        /* --- init -- */

        IF COALESCE(var_poll_count, 0) > 99 OR COALESCE(var_poll_count, 0) < 1 THEN
            SELECT
                50
                INTO var_poll_count;
        END IF; /* ----Default 50 records each time-- */
        /* ------------------------------- */
        /* --Default Batch-Read count : 50 records */
        /* ------------------------------- */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @poll_count clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount @poll_count
        */
        /* --------------------------------------------- */
        /* --- 2.1.1 ack_ehr_status [status from "I"-->"P"] */
        
        /* --------------------------------------------- */
        IF par_ack_sys = 'EHR' THEN
            BEGIN
                /* ------------------------------------------- */
                /* --A). [Self-healing Process] on eHR ACK  -- */
                /* ------------------------------------------- */
                /* BEGIN : 20160329 --- */
                IF EXISTS (SELECT
                    1
                    FROM ehr_event_out
                    WHERE evt_ack_status_ehr = 'E' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                    /* --- Only auto-recover(i.e update E-->I) for previous 10Min failed ehr_event_out */
                    txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO") THEN
                    BEGIN
                        UPDATE ehr_event_out
                        SET evt_ack_status_ehr = 'I', evt_upd_dtm_ehr = var_upd_dtm /* ----eHR ACK upd_dtm */
                            WHERE evt_ack_status_ehr = 'E' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                            /* --- Only auto-recover(i.e update E-->I) for previous 10Min failed ehr_event_out */
                            txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO";
                    END;
                END IF;
                /* END : 20160329 --- */
                /* BEGIN : 20180105 : SKIP the Stuck-A47 EventOut caused by NA pas_doc_type --- */

                IF EXISTS (SELECT
                    1
                    FROM ehr_event_out
                    WHERE evt_ack_status_ehr = 'P' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                    /* --- Only auto-recover(i.e update P-->K) to prevent EVENT_OUT Stuck due to stuck PatientMerge A47  eventout */
                    txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO" AND evt_code = 'ADT_A47' AND COALESCE(pas_doc_type, 'NA') = 'NA')
                /* and msg_no like '%M'    -- PatientMerge A47 Event : */
                THEN
                    BEGIN
                        UPDATE ehr_event_out
                        SET evt_ack_status_ehr = 'K', evt_upd_dtm_ehr = var_upd_dtm /* ----eHR ACK upd_dtm */
                            WHERE evt_ack_status_ehr = 'P' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                            /* --- Only auto-recover(i.e update P-->K) to prevent EVENT_OUT Stuck due to stuck PatientMerge A47  eventout */
                            txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO" AND evt_code = 'ADT_A47' AND COALESCE(pas_doc_type, 'NA') = 'NA';
                        /* and msg_no like '%M'    -- PatientMerge A47 Event : */
                    END;
                END IF;
                /* END : 2080105 --- */
                
                /* ------------------------------------------------------------------ */
                /* B). [Pick-up] eHR Event_Out records for normal processing    -- */
                /* 20210927 : use XIE2_ehr_event_out (evt_ack_status_ehr, txn_dtm) */
                
                /* ------------------------------------------------------------------ */
                
                /* ---20141126 ---- */
                IF EXISTS (SELECT
                    1
                    FROM ehr_event_out
                    WHERE evt_ack_status_ehr = 'I' AND txn_dtm >= par_from_date AND txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO"
                /* 20150319 : DUMMY Events :<029438615304> */
                ) THEN
                    BEGIN
                        BEGIN
                            UPDATE ehr_event_out
                            SET evt_ack_status_ehr = 'P', evt_upd_dtm_ehr = var_upd_dtm /* ----eHR ACK upd_dtm */
                                /* --FROM ehr_event_out (index XIE2_ehr_event_out) -- to use INdex */
                                WHERE evt_ack_status_ehr = 'I' AND txn_dtm >= par_from_date AND txn_dtm <= par_to_date;
                            EXCEPTION
                                WHEN others THEN
                                    BEGIN
                                        /* --print "ERROR code : %1!",@error */
                                        SELECT
                                            500010
                                            INTO var_return_error_code;
                                        EXIT exit_error;
                                    END;
                        END;
                        OPEN p_refcur FOR
                        SELECT
                            msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, (
                            /* ------------------------------------------------------------------------------------------- */
                            /* 20170622:HKIC (ID + HKIC#) or Doc.Pair (Doc.Type + Doc_no), they canÔÇÖt be coexisted   -- */
                            /* (1) pas_hkic is NULL for Doc.Pair participant                                -- */
                            
                            /* -------------------------------------------------------------------------------------------- */
                            CASE
                                WHEN evt_code = 'ADT_A47' AND LTRIM(RTRIM(ehr_hkic)) IS NULL AND pas_doc_type NOT IN ('BN', 'BE', 'BC', 'ID') THEN NULL
                                ELSE pas_hkic
                            END) AS pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob,
                            /* 20160819 :  pass pas_hkic out when hkic is not blank and non pseudo for ADT_A47/A45--- */
                            (CASE
                                WHEN evt_code = 'ADT_A47' AND pas_doc_type IN ('BN', 'BE', 'BC') THEN 'BC'
                            /* 20170706 : BE/BN/BC will be handled as ID */
                                WHEN evt_code = 'ADT_A47' AND pas_doc_type IN ('AN', 'AE', 'AR') THEN 'AR'
                                WHEN evt_code = 'ADT_A47' AND LTRIM(RTRIM(ehr_hkic)) IS NOT NULL AND LTRIM(RTRIM(pas_hkic)) NOT LIKE 'U%' AND pas_doc_type NOT IN ('BN', 'BE', 'BC') THEN 'ID'
                            /* 20161108 : DocType='ID' for Non-Doc.Pair Patient */
                                WHEN evt_code = 'ADT_A47' AND LTRIM(RTRIM(ehr_hkic)) IS NULL AND LTRIM(RTRIM(pas_doc_type)) IS NULL THEN 'NA'
                            /* 20170322: if pas_doc_type is empty ==> NA for <Doc.Pair> patient in A47 */
                                ELSE pas_doc_type
                            END) AS pas_doc_type, (
                            /* -------------------------------------------------------------------------------------------- */
                            /* 20170622:HKIC (ID/BC + HKIC#) or Doc.Pair (Doc.Type + Doc_no), they canÔÇÖt be coexisted -- */
                            /* (2) pas_doc_no is NULL for HKIC participant                                   -- */
                            
                            /* -------------------------------------------------------------------------------------------- */
                            CASE
                                WHEN evt_code = 'ADT_A47' AND pas_doc_type IN ('BN', 'BE', 'BC', 'ID') THEN NULL
                                ELSE pas_doc_no
                            END) AS pas_doc_no, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, evt_crt_hosp, evt_upd_dtm_ehr, evt_upd_dtm_epr, evt_upd_dtm_ris, evt_upd_by, evt_upd_sys, sys_dtm
                            /* ----20150211 -- */
                            /* --old_pas_hkic,old_pas_surname,old_pas_givenname,old_pas_full_name,old_pas_sex,old_pas_dob,old_pas_exact_dob,old_pas_doc_type,old_pas_doc_no */
                            /* --20150520 -- */
                            /* --ehr_hkic,ehr_surname,ehr_givenname,ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no */
                            FROM ehr_event_out
                            WHERE evt_ack_status_ehr = 'P' AND
                            /* --- eHR ACK */
                            txn_dtm >= par_from_date AND txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO"
                            /* 20150319 : DUMMY Events :<029438615304> */
                            ORDER BY txn_dtm NULLS FIRST, msg_no NULLS FIRST /* ---20141204 */;
							return next p_refcur;
END; /* ---20141126 --- */
                /* 20150205 -- */
                ELSE
                    BEGIN
                        OPEN p_refcur FOR
                        SELECT
                            msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, evt_crt_hosp, evt_upd_dtm_ehr, evt_upd_dtm_epr, evt_upd_dtm_ris, evt_upd_by, evt_upd_sys, sys_dtm
                            /* ----20150211 -- */
                            /* --old_pas_hkic,old_pas_surname,old_pas_givenname,old_pas_full_name,old_pas_sex,old_pas_dob,old_pas_exact_dob,old_pas_doc_type,old_pas_doc_no */
                            /* --20150520 -- */
                            /* --ehr_hkic,ehr_surname,ehr_givenname,ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no */
                            FROM ehr_event_out
                            WHERE 1 = 0;
							return next p_refcur;
                    END;
                END IF;
            END;
        /* --------------------------------------------- */
        /* --- 2.1.2 ack_epr_status [status from "I"-->"P"]-- */
        
        /* --------------------------------------------- */
        /* --- 20150319 : NO ACK to ePR for DUMMY_EHR_NO */
        ELSE
            IF par_ack_sys = 'EPR' THEN
                BEGIN
                    /* ------------------------------------------- */
                    /* --A). [Self-healing Process] on ePR ACK  -- */
                    /* ------------------------------------------- */
                    /* BEGIN : 20160623 --- */
                    IF EXISTS (SELECT
                        1
                        FROM ehr_event_out
                        WHERE evt_ack_status_epr = 'E' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                        /* --- Only auto-recover(i.e update E-->I) for previous 10Min failed ehr_event_out */
                        txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO") THEN
                        BEGIN
                            UPDATE ehr_event_out
                            SET evt_ack_status_epr = 'I', evt_upd_dtm_epr = var_upd_dtm /* ----eHR ACK upd_dtm */
                                WHERE evt_ack_status_epr = 'E' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                                /* --- Only auto-recover(i.e update E-->I) for previous 10Min failed ehr_event_out */
                                txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO";
                        END;
                    END IF;
                    /* END : 20160623 --- */
                    
                    /* ------------------------------------------------------------- */
                    /* B). [Pick-up] ePR Event_Out records for normal processing   -- */
                    /* 20210927 : use XIE3_ehr_event_out (evt_ack_status_epr, txn_dtm) */
                    
                    /* ------------------------------------------------------------- */
                    
                    /* ---20141126 --- */
                    IF EXISTS (SELECT
                        1
                        FROM ehr_event_out
                        WHERE evt_ack_status_epr = 'I' AND /* ---ePR ACK */ txn_dtm >= par_from_date AND txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO"
                    /* 20150319 : DUMMY Events :<029438615304> */
                    ) THEN
                        BEGIN
                            BEGIN
                                UPDATE ehr_event_out
                                SET evt_ack_status_epr = 'P', evt_upd_dtm_epr = var_upd_dtm /* ----ePR ACK upd_dtm */
                                    /* --FROM ehr_event_out (index XIE3_ehr_event_out) -- to use INdex */
                                    WHERE evt_ack_status_epr = 'I' AND /* ---ePR ACK */ txn_dtm >= par_from_date AND txn_dtm <= par_to_date;
                                EXCEPTION
                                    WHEN others THEN
                                        BEGIN
                                            /* --print "ERROR code : %1!",@error */
                                            SELECT
                                                500010
                                                INTO var_return_error_code;
                                            EXIT exit_error;
                                        END;
                            END;
                            OPEN p_refcur FOR
                            SELECT
                                msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, evt_crt_hosp, evt_upd_dtm_ehr, evt_upd_dtm_epr, evt_upd_dtm_ris, evt_upd_by, evt_upd_sys, sys_dtm
                                /* ----20150211 -- */
                                /* --old_pas_hkic,old_pas_surname,old_pas_givenname,old_pas_full_name,old_pas_sex,old_pas_dob,old_pas_exact_dob,old_pas_doc_type,old_pas_doc_no */
                                /* --20150520 -- */
                                /* --ehr_hkic,ehr_surname,ehr_givenname,ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no */
                                FROM ehr_event_out
                                WHERE evt_ack_status_epr = 'P' AND
                                /* --- ePR ACK */
                                txn_dtm >= par_from_date AND txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO"
                                /* 20150319 : DUMMY Events :<029438615304> */
                                ORDER BY txn_dtm NULLS FIRST, msg_no NULLS FIRST /* --20141204 */;
							return next p_refcur;
                        END; /* ---20141126 --- */
                    /* ---20150205 --- */
                    ELSE
                        BEGIN
                            OPEN p_refcur FOR
                            SELECT
                                msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, evt_crt_hosp, evt_upd_dtm_ehr, evt_upd_dtm_epr, evt_upd_dtm_ris, evt_upd_by, evt_upd_sys, sys_dtm
                                /* ----20150211 -- */
                                /* --old_pas_hkic,old_pas_surname,old_pas_givenname,old_pas_full_name,old_pas_sex,old_pas_dob,old_pas_exact_dob,old_pas_doc_type,old_pas_doc_no */
                                /* --20150520 -- */
                                /* --ehr_hkic,ehr_surname,ehr_givenname,ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no */
                                FROM ehr_event_out
                                WHERE 1 = 0;
							return next p_refcur;
                        END;
                    END IF;
                END;
            ELSE
                IF par_ack_sys = 'RIS' THEN
                    BEGIN
                        /* ------------------------------------------- */
                        /* --A). [Self-healing Process] on RIS ACK  -- */
                        /* ------------------------------------------- */
                        /* BEGIN : 20191212 --- */
                        IF EXISTS (SELECT
                            1
                            FROM ehr_event_out
                            WHERE evt_ack_status_ris = 'E' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                            /* --- Only auto-recover(i.e update E-->I) for previous 10Min failed ehr_event_out */
                            txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO") THEN
                            BEGIN
                                UPDATE ehr_event_out
                                SET evt_ack_status_ris = 'I', evt_upd_dtm_ris = var_upd_dtm /* ----eHR ACK upd_dtm */
                                    WHERE evt_ack_status_ris = 'E' AND txn_dtm >= - 10 * INTERVAL '1 minute' + par_to_date::TIMESTAMP AND
                                    /* --- Only auto-recover(i.e update E-->I) for previous 10Min failed ehr_event_out */
                                    txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO";
                            END;
                        END IF;
                        /* END : 20160623 --- */
                        
                        /* ------------------------------------------------------------- */
                        /* B). [Pick-up] Ris Event_Out records for normal processing   -- */
                        /* 20210927 : use XIE4_ehr_event_out (evt_ack_status_ris, txn_dtm) */
                        
                        /* ------------------------------------------------------------- */
                        
                        /* ---20191212 --- */
                        IF EXISTS (SELECT
                            1
                            FROM ehr_event_out
                            WHERE evt_ack_status_ris = 'I' AND /* ---ris ACK */ txn_dtm >= par_from_date AND txn_dtm <= par_to_date AND ehr_number <> "var_DUMMY_EHR_NO"
                        /* 20150319 : DUMMY Events :<029438615304> */
                        ) THEN
                            BEGIN
                                /* FOR RIS */
                                
                                /* --and msg_no in ('P2020092917490900000','P2020092917553900000') */
                                BEGIN
                                    UPDATE ehr_event_out
                                    SET evt_ack_status_ris = 'P', evt_upd_dtm_ris = var_upd_dtm /* ----RIS ACK upd_dtm */
                                        /* --FROM ehr_event_out (index XIE4_ehr_event_out) -- to use INdex */
                                        WHERE evt_ack_status_ris = 'I' AND
                                        /* Ris ACK */
                                        txn_dtm >= par_from_date AND txn_dtm <= par_to_date AND txn_dtm >= '20201006 18:00';
                                    EXCEPTION
                                        WHEN others THEN
                                            BEGIN
                                                /* --print "ERROR code : %1!",@error */
                                                SELECT
                                                    500010
                                                    INTO var_return_error_code;
                                                EXIT exit_error;
                                            END;
                                END;
                                OPEN p_refcur FOR
                                SELECT
                                    msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, evt_crt_hosp, evt_upd_dtm_ehr, evt_upd_dtm_epr, evt_upd_dtm_ris, evt_upd_by, evt_upd_sys, sys_dtm
                                    /* ----20150211 -- */
                                    /* --old_pas_hkic,old_pas_surname,old_pas_givenname,old_pas_full_name,old_pas_sex,old_pas_dob,old_pas_exact_dob,old_pas_doc_type,old_pas_doc_no */
                                    /* --20150520 -- */
                                    /* --ehr_hkic,ehr_surname,ehr_givenname,ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no */
                                    FROM ehr_event_out
                                    WHERE evt_ack_status_ris = 'P' AND
                                    /* --- Ris ACK */
                                    txn_dtm >= par_from_date AND txn_dtm <= par_to_date AND txn_dtm >= '20201006 18:00' AND
                                    /* FOR RIS */
                                    
                                    /* --and msg_no in ('P2020092917490900000','P2020092917553900000') */
                                    ehr_number <> "var_DUMMY_EHR_NO"
                                    /* 20150319 : DUMMY Events :<029438615304> */
                                    ORDER BY txn_dtm NULLS FIRST, msg_no NULLS FIRST /* --20141204 */;
							return next p_refcur;
                            END; /* ---20141126 --- */
                        /* ---20150205 --- */
                        ELSE
                            BEGIN
                                OPEN p_refcur FOR
                                SELECT
                                    msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, pas_hkic, pas_surname, pas_givenname, pas_full_name, pas_sex, pas_dob, pas_exact_dob, pas_doc_type, pas_doc_no, pas_death_date, pas_death_time, pas_exact_death, pas_death_ind, evt_ack, evt_ack_status_ehr, evt_ack_status_epr, evt_ack_status_ris, evt_crt_by, evt_crt_sys, evt_crt_hosp, evt_upd_dtm_ehr, evt_upd_dtm_epr, evt_upd_dtm_ris, evt_upd_by, evt_upd_sys, sys_dtm
                                    /* ----20150211 -- */
                                    /* --old_pas_hkic,old_pas_surname,old_pas_givenname,old_pas_full_name,old_pas_sex,old_pas_dob,old_pas_exact_dob,old_pas_doc_type,old_pas_doc_no */
                                    /* --20150520 -- */
                                    /* --ehr_hkic,ehr_surname,ehr_givenname,ehr_full_name,ehr_sex,ehr_dob,ehr_exact_dob,ehr_doc_type,ehr_doc_no */
                                    FROM ehr_event_out
                                    WHERE 1 = 0;
							return next p_refcur;
                            END;
                        END IF;
                    END;
                END IF;
            END IF;
        END IF;
        /* ----The last ehr_event_out handled by <EHR_ACK_WS> -- */
        UPDATE ehr_event_conf
        SET last_ehr_event_out_dtm = var_upd_dtm
            WHERE config_id = 6 AND system_id = 'EHR_ACK_WS';
        /* --------------------------------------------- */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount 0
        */
       
        RETURN;

        <<exit_normal>>
        BEGIN
        END;
    END;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount 0
    */
    
    RETURN;
END;
$function$
;


ALTER FUNCTION "ehr_read_event_out" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
