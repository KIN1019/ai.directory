-- DROP PROCEDURE hkpmi.ehr_write_event_in(inout int4, in timestamp, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in varchar, in varchar, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in varchar, in varchar, in varchar, in bpchar, in bpchar, in bpchar, in bpchar, in varchar, in bpchar, in bpchar, in bpchar, inout varchar, in bpchar, in bpchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.ehr_write_event_in(INOUT pas_return_code integer, IN par_txn_dtm timestamp without time zone, IN par_msg_no character varying, 
IN par_evt_code varchar, IN par_ehr_number varchar, IN par_ehr_start_date varchar, IN par_ehr_end_date varchar, IN par_ehr_hkic character varying, IN par_ehr_surname character varying, 

IN par_ehr_givenname character varying, IN par_ehr_full_name character varying, IN par_ehr_sex varchar, IN par_ehr_dob varchar, IN par_ehr_exact_dob varchar, IN par_ehr_doc_type varchar, 
IN par_ehr_doc_no character varying, IN par_ehr_death_date varchar, IN par_ehr_death_time varchar, IN par_ehr_exact_death varchar, IN par_ehr_death_ind varchar, IN par_old_ehr_hkic character varying DEFAULT NULL::character varying,
 IN par_old_ehr_surname character varying DEFAULT NULL::character varying, IN par_old_ehr_givenname character varying DEFAULT NULL::character varying, 
 IN par_old_ehr_full_name character varying DEFAULT NULL::character varying, IN par_old_ehr_sex varchar DEFAULT NULL::varchar, IN par_old_ehr_dob varchar DEFAULT NULL::varchar,
  IN par_old_ehr_exact_dob varchar DEFAULT NULL::varchar, IN par_old_ehr_doc_type varchar DEFAULT NULL::varchar, IN par_old_ehr_doc_no character varying DEFAULT NULL::character varying, 
  IN par_evt_status varchar DEFAULT NULL::varchar, IN par_evt_crt_by varchar DEFAULT NULL::varchar, IN par_evt_crt_sys varchar DEFAULT NULL::varchar, INOUT par_rtn_msg character varying DEFAULT NULL::character varying, 
  IN par_ehr_conf_code varchar DEFAULT NULL::varchar, IN par_ehr_conf_value varchar DEFAULT NULL::varchar, IN par_ehr_smart_id character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ------------------------------------ */
/* --------HA action status for the event by PAS WS ----------------- */ /* --I/Q */
/* Feb2015--- */
DECLARE
    var_rtn_code INTEGER;
    var_err_msg varchar(255);
    var_error_code INTEGER;
    var_sys_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_run_flag varchar(1);
BEGIN
    <<return_error>>
    BEGIN
        <<return_normal>>
        BEGIN
            /* ---last-update: 20140609--- */
            /* ---20150204 : 8th eHR HA Integration Meeting */
            /* 20150212 -- 2nd phase : ehr_conf_code/ehr_conf_value */
            /* 20171031 : ehr_smart_id */
            SELECT
                'Y'
                INTO var_run_flag;
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
            IF LTRIM(RTRIM(par_old_ehr_hkic)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_hkic;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_surname)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_surname;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_givenname)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_givenname;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_full_name)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_full_name;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_sex)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_sex;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_dob)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_dob;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_exact_dob)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_exact_dob;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_doc_type)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_doc_type;
            END IF;

            IF LTRIM(RTRIM(par_old_ehr_doc_no)) = '' THEN
                SELECT
                    NULL
                    INTO par_old_ehr_doc_no;
            END IF;
            /* ----20150126 --- */
            IF LTRIM(RTRIM(par_ehr_conf_code)) = '' THEN
                SELECT
                    NULL
                    INTO par_ehr_conf_code;
            END IF;

            IF LTRIM(RTRIM(par_ehr_conf_value)) = '' THEN
                SELECT
                    NULL
                    INTO par_ehr_conf_value;
            END IF;

            IF LTRIM(RTRIM(par_ehr_smart_id)) = '' THEN
                SELECT
                    NULL
                    INTO par_ehr_smart_id;
            END IF;
            /* ---- 1) check for non-null values ---- */

            IF par_msg_no IS NULL OR par_ehr_number IS NULL OR par_evt_code IS NULL OR
            /* --or @ehr_full_name is null		--- NULLable for NID patient by PAS_POLL */
            (par_ehr_full_name IS NULL AND par_evt_crt_sys = 'EHR_RCV_WS') THEN
                BEGIN
                    SELECT
                        - 1
                        INTO var_rtn_code;
                    SELECT
                        'non-nullable values NOT allowed!'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;
            /* ----------refer to ehr_code_table --- */
            IF par_evt_status NOT IN ('I', 'Q') THEN
                BEGIN
                    SELECT
                        - 2
                        INTO var_rtn_code;
                    SELECT
                        'Incorrect event_in status !'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;
            /* --- only insert by EHR_RCV_WS/PAS_POLL --- */

            IF par_evt_crt_sys NOT IN ('EHR_RCV_WS', 'PAS_POLL', 'EHR_EXG_WS') THEN
                BEGIN
                    SELECT
                        - 3
                        INTO var_rtn_code;
                    SELECT
                        'Incorrect evt_crt_sys  !'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;
            /* ------------------------------------------------------ */
            /* --- <Step.1> Check run_flag */
            
            /* ------------------------------------------------------ */
            
            /* --1.1) for ERH_RCV_WS only, NOT need to check for <PAS_POLL.ehr_pas_txn_polling> */
            IF par_evt_crt_sys = 'EHR_RCV_WS' THEN
                BEGIN
                    SELECT
                        COALESCE(run_flag, 'N')
                        INTO var_run_flag
                        FROM ehr_event_conf
                        WHERE config_id = 5 AND system_id = 'EHR_RCV_WS';

                    IF var_run_flag != 'Y' THEN
                        BEGIN
                            SELECT
                                - 4
                                INTO var_rtn_code;
                            SELECT
                                'RUN_FLAG disabled !'
                                INTO var_err_msg;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* --- message already exists --- */

            IF EXISTS (SELECT
                *
                FROM ehr_event_in
                WHERE msg_no = par_msg_no) THEN
                BEGIN
                    SELECT
                        - 5
                        INTO var_rtn_code;
                    SELECT
                        'The Event Record Record already Exist !'
                        INTO var_err_msg;
                    /* --GOTO return_error */
                    EXIT return_normal /* ---2015024 : 8th eHR HA Integration Meeting */;
                END;
            END IF;
            SELECT
                localtimestamp
                INTO var_sys_dtm;

            BEGIN
                INSERT INTO ehr_event_in (msg_no, evt_code, txn_dtm, ehr_number, ehr_start_date, ehr_end_date, ehr_hkic, ehr_surname, ehr_givenname, ehr_full_name, ehr_sex, ehr_dob, ehr_exact_dob, ehr_doc_type, ehr_doc_no, ehr_death_date, ehr_death_time, ehr_exact_death, ehr_death_ind, old_ehr_hkic, old_ehr_surname, old_ehr_givenname, old_ehr_full_name, old_ehr_sex, old_ehr_dob, old_ehr_exact_dob, old_ehr_doc_type, old_ehr_doc_no, evt_status, evt_crt_by, evt_crt_sys, sys_dtm, ehr_conf_code, ehr_conf_value, ehr_smart_id)
                VALUES (par_msg_no, par_evt_code, par_txn_dtm, par_ehr_number, par_ehr_start_date, par_ehr_end_date, par_ehr_hkic, par_ehr_surname, par_ehr_givenname, par_ehr_full_name, par_ehr_sex, par_ehr_dob, par_ehr_exact_dob, par_ehr_doc_type, par_ehr_doc_no, par_ehr_death_date, par_ehr_death_time, par_ehr_exact_death, par_ehr_death_ind, par_old_ehr_hkic, par_old_ehr_surname, par_old_ehr_givenname, par_old_ehr_full_name, par_old_ehr_sex, par_old_ehr_dob, par_old_ehr_exact_dob, par_old_ehr_doc_type, par_old_ehr_doc_no, par_evt_status, par_evt_crt_by, par_evt_crt_sys, var_sys_dtm, par_ehr_conf_code, par_ehr_conf_value, par_ehr_smart_id);
                var_error_code := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error_code := 1;
            END;

            IF var_error_code != 0 THEN
                BEGIN
                    SELECT
                        - 11
                        INTO var_rtn_code;
                    SELECT
                        'Insert ehr_event_in Failed !'
                        INTO var_err_msg;
                    EXIT return_error;
                END;
            END IF;
            /* ----Update ehr_event_conf.last_ehr_event_in_dtm ---- */
            IF par_evt_crt_sys = 'PAS_POLL' THEN
                UPDATE ehr_event_conf
                SET last_ehr_event_in_dtm = par_txn_dtm
                    WHERE config_id = 3 AND system_id = 'PAS_POLL';
            ELSE
                IF par_evt_crt_sys = 'EHR_RCV_WS' THEN
                    UPDATE ehr_event_conf
                    SET last_ehr_event_in_dtm = par_txn_dtm
                        WHERE config_id = 5 AND system_id = 'EHR_RCV_WS';
                ELSE
                    IF par_evt_crt_sys = 'EHR_EXG_WS' THEN
                        UPDATE ehr_event_conf
                        SET last_ehr_event_in_dtm = par_txn_dtm
                            WHERE config_id = 9 AND system_id = 'EHR_EXG_WS';
                    END IF;
                END IF;
            END IF;
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


ALTER PROCEDURE "ehr_write_event_in" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
