-- DROP PROCEDURE hkpmi.ehr_upd_event_out(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_upd_event_out(INOUT pas_return_code integer, IN par_ack_sys varchar, IN par_msg_no varchar, IN par_ack_status varchar, 
IN par_evt_upd_by varchar DEFAULT 'EHR_WEB_USER'::varchar, IN par_evt_upd_sys varchar DEFAULT 'EHR_ACK_WS'::varchar)
 LANGUAGE plpgsql
AS $procedure$
/* ---Unique key of ehr_event_out */DECLARE
    var_run_flag varchar(1);
    var_return_error_code INTEGER;
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<exit_error>>
    BEGIN
        /* ---LastUpdate on 20140619 ----- */
        /* 20160809 : disable the update on sys_dtm --> sys_dtm will be used for event_out record creat_dtm -- */
        
        /* ---init --- */
        SELECT
            'N'
            INTO var_run_flag;
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_upd_dtm;

        IF par_ack_sys IS NULL OR par_ack_sys NOT IN ('EPR', 'EHR', 'RIS') THEN
            BEGIN
                SELECT
                    500009
                    INTO var_return_error_code;
                EXIT exit_error;
            END;
        END IF;

        IF par_ack_status IS NULL OR par_ack_status NOT IN ('S', 'E', 'K') THEN
            BEGIN
                SELECT
                    500012
                    INTO var_return_error_code; /* ---invalid ack_status */
                EXIT exit_error;
            END;
        END IF;
        /*
        -- NO need to check run_flag WHICH should used by polling job (ehr_read_event_out) ONLY ---
        ------------------------------------------------------
        --- <Step.1> Check polling flag
        ------------------------------------------------------
        --1.1) Start to process 'I'-Event if run_flag =Y
        
        select @run_flag = run_flag
        	from	ehr_event_conf
        	where config_id= 2
        	and system_id='EHR_POLL'
        
        if (@run_flag <> "Y")
        	GOTO EXIT_NORMAL
        */
        
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount 1
        */
        
        /* --------------------------------------------- */
        /* --- 2.1.1 ack_ehr_status [status from "P"-->"S"] */
        
        /* --------------------------------------------- */
        IF par_ack_sys = 'EHR' THEN
            BEGIN
                /* --and txn_dtm >=@from_date */
                /* --and txn_dtm <=@to_date */
                BEGIN
                    UPDATE ehr_event_out
                    SET evt_ack_status_ehr = par_ack_status, evt_upd_dtm_ehr = var_upd_dtm, /* ----eHR upd dtm--- */ evt_upd_by = par_evt_upd_by, evt_upd_sys = par_evt_upd_sys
                        /* --sys_dtm = getdate()	--20160809 */
                        WHERE evt_ack_status_ehr = 'P' AND msg_no = par_msg_no;
                    EXCEPTION
                        WHEN others THEN
                            BEGIN
                                /* --print "ERROR code : %1!",@error */
                                SELECT
                                    500010
                                    INTO var_return_error_code;
                                pas_return_code := var_return_error_code;
                                RAISE;
                                EXIT exit_error;
                            END;
                END;
            END;
        /* --------------------------------------------- */
        /* --- 2.1.2 ack_epr_status [status from "P"-->"S"]-- */
        
        /* --------------------------------------------- */
        ELSE
            IF par_ack_sys = 'EPR' THEN
                BEGIN
                    /* --and txn_dtm >=@from_date */
                    /* --and txn_dtm <=@to_date */
                    BEGIN
                        UPDATE ehr_event_out
                        SET evt_ack_status_epr = par_ack_status, evt_upd_dtm_epr = var_upd_dtm, /* ----ePR upd dtm --- */ evt_upd_by = par_evt_upd_by, evt_upd_sys = par_evt_upd_sys
                            /* --sys_dtm = getdate()	--20160809 */
                            WHERE evt_ack_status_epr = 'P' AND /* ---EPR ACK */ msg_no = par_msg_no;
                        EXCEPTION
                            WHEN others THEN
                                BEGIN
                                    /* --print "ERROR code : %1!",@error */
                                    SELECT
                                        500010
                                        INTO var_return_error_code;
                                    pas_return_code := var_return_error_code;
                                    RAISE;
                                    EXIT exit_error;
                                END;
                    END;
                END;
            /* --------------------------------------------- */
            /* --- 2.1.3 ack_ris_status [status from "P"-->"S"]-- */
            
            /* --------------------------------------------- */
            ELSE
                IF par_ack_sys = 'RIS' THEN
                    BEGIN
                        /* --and txn_dtm >=@from_date */
                        /* --and txn_dtm <=@to_date */
                        BEGIN
                            UPDATE ehr_event_out
                            SET evt_ack_status_ris = par_ack_status, evt_upd_dtm_ris = var_upd_dtm, /* ----Ris upd dtm --- */ evt_upd_by = par_evt_upd_by, evt_upd_sys = par_evt_upd_sys
                                /* --sys_dtm = getdate()	--20160809 */
                                WHERE evt_ack_status_ris = 'P' AND /* ---RIS ACK */ msg_no = par_msg_no;
                            EXCEPTION
                                WHEN others THEN
                                    BEGIN
                                        /* --print "ERROR code : %1!",@error */
                                        SELECT
                                            500010
                                            INTO var_return_error_code;
                                        pas_return_code := var_return_error_code;
                                        RAISE;
                                        EXIT exit_error;
                                    END;
                        END;
                    END;
                END IF;
            END IF;
        END IF;
        /* ----The last ehr_event_in handled by <EHR_ACK_WS> -- */
        UPDATE ehr_event_conf
        SET last_poll_dtm_out = var_upd_dtm
            WHERE config_id = 6 AND system_id = 'EHR_ACK_WS';
        /* --------------------------------------------- */
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount 0
        */
        pas_return_code := 0;
        RETURN;
    END;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount 0
    */
    pas_return_code := var_return_error_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "ehr_upd_event_out" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
