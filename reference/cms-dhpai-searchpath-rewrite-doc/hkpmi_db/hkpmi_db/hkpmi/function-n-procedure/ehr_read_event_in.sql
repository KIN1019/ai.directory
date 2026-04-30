-- DROP FUNCTION hkpmi.ehr_read_event_in(bpchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hkpmi.ehr_read_event_in(par_ack_sys VARCHAR DEFAULT 'PAS'::VARCHAR, par_from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, par_to_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_run_flag VARCHAR(1);
    var_poll_count INTEGER;
    var_return_error_code INTEGER;
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<exit_error>>
    BEGIN
        /* ----LastUpdate on 20140702 --- */
        /* ---20141126 ---Avoid Duplicate POlling on Records which already marked as 'P' --- */
        /* --20141204 -- To fix SAME Txn DTM for same patient issue  --order by txn_dtm + msg_no */
        /* --20150205 -- Return empty resultset when no record found */
        
        /* ---init --- */
        SELECT
            'N'
            INTO var_run_flag;
        SELECT
            localtimestamp
            INTO var_upd_dtm;

        IF par_from_date IS NULL THEN
            BEGIN
                SELECT
                    to_char(localtimestamp::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                    INTO par_from_date;
                /* --select @from_date = dateadd(dd,-1,@from_date) */
                SELECT
                    - 7 * INTERVAL '1 day' + par_from_date::TIMESTAMP
                    INTO par_from_date;
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
        /* --if @ack_sys not in ('EPR','EHR','PAS') */
        IF par_ack_sys NOT IN ('PAS') THEN
            BEGIN
                SELECT
                    500009
                    INTO var_return_error_code;
                EXIT exit_error;
            END;
        END IF;

        IF DATE_PART('days', par_to_date::TIMESTAMP, par_from_date::TIMESTAMP) > 30 THEN
            /* ---- Date Range 180 Days ---- */
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
        
        /* --1.1) Start to process 'Q'-Event if run_flag =Y */
        SELECT
            COALESCE(run_flag, 'N'), COALESCE(poll_count, 50)
            INTO var_run_flag, var_poll_count
            FROM ehr_event_conf
            WHERE config_id = 7 AND system_id = 'EHR_QRY_WS';

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
        IF par_ack_sys = 'PAS' THEN
            BEGIN
                /* ---20141126 --- */
                IF EXISTS (SELECT
                    1
                    FROM ehr_event_in
                    WHERE evt_status = 'Q' AND txn_dtm >= par_from_date AND txn_dtm <= par_to_date) THEN
                    BEGIN
                        BEGIN
                            UPDATE ehr_event_in
                            SET evt_status = 'P', evt_upd_dtm = var_upd_dtm /* ----eHR ACK upd_dtm */
                                WHERE evt_status = 'Q' AND txn_dtm >= par_from_date AND txn_dtm <= par_to_date;
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
                            msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_doc_type, ehr_doc_no, evt_status, evt_crt_by, evt_crt_sys, evt_upd_dtm, evt_upd_by, evt_upd_sys, sys_dtm
                            FROM ehr_event_in
                            WHERE evt_status = 'P' AND
                            /* --- */
                            txn_dtm >= par_from_date AND txn_dtm <= par_to_date
                            ORDER BY txn_dtm NULLS FIRST, msg_no NULLS FIRST /* ---20141204 */;
							return next p_refcur;
                    END; /* ---20141126 --- */
                /* ---20150205 --- */
                ELSE
                    BEGIN
                        OPEN p_refcur FOR
                        SELECT
                            msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_doc_type, ehr_doc_no, evt_status, evt_crt_by, evt_crt_sys, evt_upd_dtm, evt_upd_by, evt_upd_sys, sys_dtm
                            FROM ehr_event_in
                            WHERE 1 = 0;
							return next p_refcur;
                    END;
                END IF;
                /* ----The last ehr_event_in handled by <EHR_QRY_WS> -- */
                UPDATE ehr_event_conf
                SET last_ehr_event_in_dtm = var_upd_dtm
                    WHERE config_id = 7 AND system_id = 'EHR_QRY_WS';
            END;
        END IF;
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


ALTER FUNCTION "ehr_read_event_in" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
