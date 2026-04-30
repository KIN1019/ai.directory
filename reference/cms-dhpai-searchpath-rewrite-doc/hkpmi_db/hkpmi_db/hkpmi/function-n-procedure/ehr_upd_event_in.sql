-- DROP PROCEDURE hkpmi.ehr_upd_event_in(inout int4, in bpchar, in timestamp, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in varchar, in varchar, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, inout varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_upd_event_in(INOUT pas_return_code integer, IN par_ack_sys varchar DEFAULT 'PAS'::varchar, IN par_txn_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_msg_no character varying DEFAULT NULL::character varying, IN par_evt_code varchar DEFAULT NULL::varchar, IN par_ehr_number varchar DEFAULT NULL::varchar, IN par_ehr_start_date varchar DEFAULT NULL::varchar, IN par_ehr_end_date varchar DEFAULT NULL::varchar, IN par_ehr_hkic character varying DEFAULT NULL::character varying, IN par_ehr_surname character varying DEFAULT NULL::character varying, IN par_ehr_givenname character varying DEFAULT NULL::character varying, IN par_ehr_full_name character varying DEFAULT NULL::character varying, IN par_ehr_sex varchar DEFAULT NULL::varchar, IN par_ehr_dob varchar DEFAULT NULL::varchar, IN par_ehr_exact_dob varchar DEFAULT NULL::varchar, IN par_ehr_doc_type varchar DEFAULT NULL::varchar, IN par_ehr_doc_no character varying DEFAULT NULL::character varying, IN par_ehr_death_date varchar DEFAULT NULL::varchar, IN par_ehr_death_time varchar DEFAULT NULL::varchar, IN par_ehr_exact_death varchar DEFAULT NULL::varchar, IN par_ehr_death_ind varchar DEFAULT NULL::varchar, IN par_evt_status varchar DEFAULT NULL::varchar, IN par_evt_upd_by varchar DEFAULT NULL::varchar, IN par_evt_upd_sys varchar DEFAULT NULL::varchar, INOUT par_rtn_msg character varying DEFAULT NULL::character varying, IN par_ehr_smart_id character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ------------------------------------ */
/* --------HA action status for the event----------------- */
DECLARE
    var_return_error_code INTEGER;
    var_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<exit_error>>
    BEGIN
        /* ---LastUpdate on 20140609 ----- */
        /* 20160809 : disable the update on sys_dtm --> sys_dtm will be used for event_in record creat_dtm -- */
        /* 20171031 : ehr_smart_id */
        
        /* --declare @run_flag VARCHAR(1) */
        /* ---- init values ------------- */
        IF LTRIM(RTRIM(par_ehr_number)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_number;
        END IF;

        IF LTRIM(RTRIM(par_ehr_hkic)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_hkic;
        END IF;

        IF LTRIM(RTRIM(par_ehr_start_date)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_start_date;
        END IF;

        IF LTRIM(RTRIM(par_ehr_end_date)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_end_date;
        END IF;
        /* -------------------------------------- */
        IF LTRIM(RTRIM(par_ehr_surname)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_surname;
        END IF;

        IF LTRIM(RTRIM(par_ehr_givenname)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_givenname;
        END IF;

        IF LTRIM(RTRIM(par_ehr_full_name)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_full_name;
        END IF;

        IF LTRIM(RTRIM(par_ehr_sex)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_sex;
        END IF;

        IF LTRIM(RTRIM(par_ehr_dob)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_dob;
        END IF;

        IF LTRIM(RTRIM(par_ehr_exact_dob)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_exact_dob;
        END IF;

        IF LTRIM(RTRIM(par_ehr_doc_type)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_doc_type;
        END IF;

        IF LTRIM(RTRIM(par_ehr_doc_no)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_doc_no;
        END IF;

        IF LTRIM(RTRIM(par_ehr_death_date)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_death_date;
        END IF;

        IF LTRIM(RTRIM(par_ehr_death_time)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_death_time;
        END IF;

        IF LTRIM(RTRIM(par_ehr_exact_death)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_exact_death;
        END IF;

        IF LTRIM(RTRIM(par_ehr_death_ind)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_death_ind;
        END IF;
        /* ------------------------------------- */
        IF LTRIM(RTRIM(par_evt_upd_by)) = '' THEN
            SELECT
                NULL
                INTO par_evt_upd_by;
        END IF;

        IF LTRIM(RTRIM(par_evt_upd_sys)) = '' THEN
            SELECT
                NULL
                INTO par_evt_upd_sys;
        END IF;

        IF LTRIM(RTRIM(par_ehr_smart_id)) = '' THEN
            SELECT
                NULL
                INTO par_ehr_smart_id;
        END IF;
        /* --select @run_flag='N' */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_upd_dtm;
        /* --if @ack_sys not in ('EPR','EHR') */
        IF par_ack_sys IS NULL OR par_evt_upd_sys IS NULL OR par_ack_sys NOT IN ('PAS') OR par_evt_upd_sys NOT IN ('EHR_QRY_WS') THEN
            BEGIN
                SELECT
                    500009
                    INTO var_return_error_code;
                EXIT exit_error;
            END;
        END IF;

        IF par_evt_status IS NULL OR par_evt_status NOT IN ('I', 'N', 'E', 'F') THEN
            BEGIN
                SELECT
                    500012
                    INTO var_return_error_code; /* ---invalid ack_status */
                EXIT exit_error;
            END;
        END IF;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount 1
        */
        /* --------------------------------------------- */
        /* --- 2.1.1 ack_ehr_status [status from "P"-->"S"] */
        
        /* --------------------------------------------- */
        IF par_ack_sys = 'PAS' THEN
            BEGIN
                /* --and txn_dtm >=@from_date */
                /* --and txn_dtm <=@to_date */
                BEGIN
                    UPDATE ehr_event_in
                    SET
                    /* ----------MK from EHR_QRY_WS --------- */
                    ehr_start_date = par_ehr_start_date, ehr_end_date = par_ehr_end_date,
                    /* --ehr_doc_type=   @ehr_doc_type, */
                    /* --ehr_doc_no =   @ehr_doc_no, */
                    ehr_surname = par_ehr_surname, ehr_givenname = par_ehr_givenname, ehr_full_name = par_ehr_full_name, ehr_sex = par_ehr_sex, ehr_dob = par_ehr_dob, ehr_exact_dob = par_ehr_exact_dob,
                    /* -------------------------------- */
                    ehr_death_date = par_ehr_death_date, ehr_death_time = par_ehr_death_time, ehr_exact_death = par_ehr_exact_death, ehr_death_ind = par_ehr_death_ind,
                    /* ---------------------------------- */
                    evt_status = par_evt_status, evt_upd_dtm = var_upd_dtm, evt_upd_by = par_evt_upd_by, evt_upd_sys = par_evt_upd_sys, ehr_smart_id = par_ehr_smart_id
                        /* --sys_dtm = getdate() --20160808 */
                        WHERE evt_status = 'P' AND msg_no = par_msg_no;
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
                /* ----Update ehr_event_conf.last_poll_dtm_in ---- */
                UPDATE ehr_event_conf
                SET last_poll_dtm_in = var_upd_dtm
                    WHERE config_id = 7 AND TRIM(system_id) = 'EHR_QRY_WS';
            END;
        END IF;
        /* --------------------------------------------- */
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
END;
$procedure$
;


ALTER PROCEDURE "ehr_upd_event_in" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
