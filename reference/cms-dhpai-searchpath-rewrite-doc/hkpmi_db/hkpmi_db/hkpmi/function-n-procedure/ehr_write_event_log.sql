-- DROP PROCEDURE hkpmi.ehr_write_event_log(inout int4, in timestamp, in bpchar, in bpchar, in varchar, in varchar, in varchar, in bpchar, in bpchar, in bpchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_write_event_log(INOUT pas_return_code integer, IN par_evt_txn_dtm timestamp without time zone, IN par_evt_log_type VARCHAR, IN par_act_type VARCHAR, IN par_evt_func_detail character varying, IN par_evt_err_msg character varying, IN par_ehr_msg_file character varying, IN par_upd_by VARCHAR, IN par_upd_sys VARCHAR, IN par_upd_host VARCHAR, INOUT par_rtn_msg character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ------------------------------------ */
/* --'I/O' -- for ehr_event_in/ehr_event_out */ 
/* --ENT/EXT/ERR ---Enter/Exit/Error */

/* -----Log info for PAS-WS/EAR process ---------------------- */ 
/* ---Function/SPs the PAS-WS/PAS-EHR invovled with detail in/out-parm */ 
/* -----varchar(255), */
/* ---- full path file name of incoming /outcoming  ehr_msg */

/* --------HA action status for the event by PAS WS ----------------- */ 
/* ---pas-ws/pas_ehr_ear */ 
/* ---PAS_EHR */

/* --@upd_hosp 			char(3), ---PAS_EHR */
/* --- EAP hosts ? */

/* --@evt_remarks 		varchar(128),   -----varchar(255) null, */ 
/* ---vharchr(255) null  ??? */
DECLARE
    var_rtn_code INTEGER;
    var_err_msg VARCHAR(255);
    var_error_code INTEGER;
    var_cnt INTEGER;
    var_exit_flag VARCHAR(1);
    var_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<return_error>>
    BEGIN
        /* ---- last-update on 20140606-- */
        /* ---- last-update on Feb-2015 --- */
        /* ---- last-update on 15-Jul-2015 : for sFTP DR File--- */
        /* ---- last-update on 25-AUg-2015 : New Log_type ='A' */
        /* ---- init values ------------- */
        IF LTRIM(RTRIM(par_evt_log_type)) = '' THEN
            SELECT
                NULL
                INTO par_evt_log_type;
        END IF;

        IF LTRIM(RTRIM(par_act_type)) = '' THEN
            SELECT
                NULL
                INTO par_act_type;
        END IF;

        IF LTRIM(RTRIM(par_evt_func_detail)) = '' THEN
            SELECT
                NULL
                INTO par_evt_func_detail;
        END IF;

        IF LTRIM(RTRIM(par_evt_err_msg)) = '' THEN
            SELECT
                NULL
                INTO par_evt_err_msg;
        END IF;

        IF LTRIM(RTRIM(par_ehr_msg_file)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_msg_file;
        END IF;
        /* ---- 1) check for non-null values ---- */

        IF par_evt_log_type IS NULL OR par_act_type IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_rtn_code;
                SELECT
                    'non-nullable values!'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        /* ---------- */
        IF par_evt_log_type NOT IN ('I', 'O', 'Q', 'G', 'S', 'A') OR par_evt_log_type IS NULL THEN
            BEGIN
                SELECT
                    - 2
                    INTO var_rtn_code;
                SELECT
                    'Incorrect evt_log_type[I/O]!'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_act_type NOT IN ('ENT', 'EXT', 'ERR') OR par_act_type IS NULL THEN
            BEGIN
                SELECT
                    - 3
                    INTO var_rtn_code;
                SELECT
                    'Incorrect act_type type[ENT/EXT/ERR] !'
                    INTO var_err_msg;
                EXIT return_error;
            END;
        END IF;
        /* ----------------------------------------------------- */
        /* --- event_txn_dtm is unique key --- */
        
        /* ----------------------------------------------------- */
        SELECT
            COUNT(1)
            INTO var_cnt
            FROM ehr_event_log
            WHERE evt_txn_dtm = par_evt_txn_dtm AND evt_log_type = par_evt_log_type;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT
                    'N'
                    INTO var_exit_flag;

                WHILE (var_exit_flag = 'N') LOOP
                    SELECT
                        1 * INTERVAL '1 second' + par_evt_txn_dtm::TIMESTAMP
                        INTO par_evt_txn_dtm;
                    SELECT
                        COUNT(1)
                        INTO var_cnt
                        FROM ehr_event_log
                        WHERE evt_txn_dtm = par_evt_txn_dtm;

                    IF (var_cnt = 0) THEN
                        SELECT
                            'Y'
                            INTO var_exit_flag;
                    END IF;
                END LOOP;
            END;
        END IF;
        /* ----------------------------------------------------- */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_sys_dtm;

        BEGIN
            INSERT INTO ehr_event_log (evt_txn_dtm, evt_log_type, act_type, evt_func_detail, /* rtn_code, rtn_msg, */ ehr_msg_file, sys_dtm, upd_by, upd_sys, /* upd_hosp, */ upd_host /* , event_remarks */)
            VALUES (par_evt_txn_dtm, par_evt_log_type, par_act_type, par_evt_func_detail, /* @rtn_code, @rtn_msg, */ par_ehr_msg_file, var_sys_dtm, par_upd_by, par_upd_sys, /* @upd_hosp, */ par_upd_host /* , @evt_remarks */);
            var_error_code := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    SELECT 1 
                    INTO var_error_code;

                    SELECT
                    - 11
                    INTO var_rtn_code;
                    SELECT
                        'Insert ehr_event_log Failed !'
                    INTO var_err_msg;

                    pas_return_code := var_rtn_code;
                    RAISE;
        END;

        SELECT
            NULL
            INTO par_rtn_msg;
        pas_return_code := 0;
        RETURN;
    END;
    SELECT
        var_err_msg
        INTO par_rtn_msg;
    pas_return_code := var_rtn_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "ehr_write_event_log" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
