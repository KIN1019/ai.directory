CREATE OR REPLACE PROCEDURE ehr_ejb_sp(INOUT pas_return_code int, IN par_in_ejb_type VARCHAR, IN par_in_system_id VARCHAR, IN par_in_config_id INTEGER, IN par_in_oper_mode VARCHAR, IN par_in_sftp_status VARCHAR DEFAULT '', IN par_in_message_no VARCHAR DEFAULT '', IN par_in_file_name VARCHAR DEFAULT '', INOUT p_refcur refcursor DEFAULT NULL)
AS 
$BODY$
/* READ_CONF/UPD_CONF/INS_SFTP_TXN/UPD_SFTP_TXN */ 
/* --'LOG_FILE' */
/* READ/UPD/ */
/* E/W/??? */
DECLARE
    var_rc INTEGER;
    var_err INTEGER;
    var_txn_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_txn_dtm_str VARCHAR(20);
    sql$rowcount BIGINT;
BEGIN
    <<exit_error>>
    BEGIN
        <<exit_normal>>
        BEGIN
            /* ------------------------------------------------------------ */
            /* --1. update ehr_event_conf set last_poll_dtm = getdate() where system_id = ? */
            IF par_in_ejb_type = 'UPD_CONF' AND par_in_oper_mode = 'UPD' THEN
                BEGIN
                    UPDATE ehr_event_conf
                    SET last_poll_dtm = localtimestamp
                        WHERE system_id = par_in_system_id AND config_id = par_in_config_id;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rc := sql$rowcount;
                        var_err := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_err := 1;
                    END;

                    IF var_err <> 0 OR var_rc <> 1 THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    EXIT exit_normal;
                END;
            END IF;
            /* ------------------------------------------------------------ */
            /* --2. select system_id, run_flag from ehr_event_conf where system_id = 'LOG_FILE' */
            IF par_in_ejb_type = 'READ_CONF' AND par_in_oper_mode = 'READ' THEN
                BEGIN
                    OPEN p_refcur FOR
                    SELECT
                        system_id, run_flag
                        FROM ehr_event_conf
                        WHERE system_id = par_in_system_id AND config_id = par_in_config_id;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rc := sql$rowcount;
                        var_err := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_err := 1;
                    END;

                    IF var_err <> 0 OR var_rc <> 1 THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    EXIT exit_normal;
                END;
            END IF;
            /* ------------------------------------------------------------ */
            /* --3. insert ehr_event_txn */
            IF par_in_ejb_type = 'INS_SFTP_TXN' AND par_in_message_no <> '' AND par_in_file_name <> '' THEN
                BEGIN
                    SELECT
                        CONCAT(LEFT(par_in_message_no, 4), '-', SUBSTRING(par_in_message_no, 5, 2), '-', SUBSTRING(par_in_message_no, 7, 2), ' ', SUBSTRING(par_in_message_no, 9, 2), ':', SUBSTRING(par_in_message_no, 11, 2), ':', SUBSTRING(par_in_message_no, 13, 2))
                        INTO var_txn_dtm_str;
                    SELECT
                        CAST (var_txn_dtm_str AS TIMESTAMP WITHOUT TIME ZONE)
                        INTO var_txn_dtm;

                    IF EXISTS (SELECT
                        1
                        FROM ehr_event_txn
                        WHERE evt_txn_dtm = var_txn_dtm AND evt_txn_type = 'FTP' AND evt_msg_no = par_in_message_no) THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    INSERT INTO ehr_event_txn (evt_txn_dtm, evt_txn_type, evt_msg_no, ehr_flag, sys_dtm, upd_by, upd_sys, ehr_surname)
                    VALUES (var_txn_dtm, 'FTP', par_in_message_no, 'I', localtimestamp, 'SFTP', 'SFTP', par_in_file_name);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rc := sql$rowcount;
                        var_err := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_err := 1;
                    END;

                    IF var_err <> 0 OR var_rc <> 1 THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    EXIT exit_normal;
                END;
            END IF;
            /* ------------------------------------------------------------ */
            /* --4. update ehr_event_txn SFTP to fail */
            IF par_in_ejb_type = 'UPD_SFTP_TXN' AND par_in_sftp_status = 'E' AND par_in_message_no <> '' THEN
                BEGIN
                    SELECT
                        CONCAT(LEFT(par_in_message_no, 4), '-', SUBSTRING(par_in_message_no, 5, 2), '-', SUBSTRING(par_in_message_no, 7, 2), ' ', SUBSTRING(par_in_message_no, 9, 2), ':', SUBSTRING(par_in_message_no, 11, 2), ':', SUBSTRING(par_in_message_no, 13, 2))
                        INTO var_txn_dtm_str;
                    SELECT
                        CAST (var_txn_dtm_str AS TIMESTAMP WITHOUT TIME ZONE)
                        INTO var_txn_dtm;

                    IF NOT EXISTS (SELECT
                        1
                        FROM ehr_event_txn
                        WHERE evt_txn_dtm = var_txn_dtm AND evt_txn_type = 'FTP' AND evt_msg_no = par_in_message_no) THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    UPDATE ehr_event_txn
                    SET ehr_flag = par_in_sftp_status, sys_dtm = localtimestamp
                        WHERE evt_txn_dtm = var_txn_dtm AND evt_txn_type = 'FTP' AND evt_msg_no = par_in_message_no;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rc := sql$rowcount;
                        var_err := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_err := 1;
                    END;

                    IF var_err <> 0 OR var_rc <> 1 THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    EXIT exit_normal;
                END;
            END IF;
            /* ------------------------------------------------------------ */
            /* --5. update ehr_event_txn SFTP to wait */
            IF par_in_ejb_type = 'UPD_SFTP_TXN' AND par_in_sftp_status = 'W' AND par_in_message_no <> '' AND par_in_file_name <> '' THEN
                BEGIN
                    SELECT
                        CONCAT(LEFT(par_in_message_no, 4), '-', SUBSTRING(par_in_message_no, 5, 2), '-', SUBSTRING(par_in_message_no, 7, 2), ' ', SUBSTRING(par_in_message_no, 9, 2), ':', SUBSTRING(par_in_message_no, 11, 2), ':', SUBSTRING(par_in_message_no, 13, 2))
                        INTO var_txn_dtm_str;
                    SELECT
                        CAST (var_txn_dtm_str AS TIMESTAMP WITHOUT TIME ZONE)
                        INTO var_txn_dtm;

                    IF NOT EXISTS (SELECT
                        1
                        FROM ehr_event_txn
                        WHERE evt_txn_dtm = var_txn_dtm AND evt_txn_type = 'FTP' AND evt_msg_no = par_in_message_no) THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    UPDATE ehr_event_txn
                    SET ehr_flag = par_in_sftp_status, sys_dtm = localtimestamp, ehr_givenname = par_in_file_name
                        WHERE evt_txn_dtm = var_txn_dtm AND evt_txn_type = 'FTP' AND evt_msg_no = par_in_message_no;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rc := sql$rowcount;
                        var_err := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_err := 1;
                    END;

                    IF var_err <> 0 OR var_rc <> 1 THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    EXIT exit_normal;
                END;
            END IF;
            /* ------------------------------------------------------------ */
            /* --6. update ehr_event_txn SFTP to finish */
            IF par_in_ejb_type = 'UPD_SFTP_TXN' AND par_in_file_name <> '' AND par_in_message_no = '' THEN
                BEGIN
                    IF NOT EXISTS (SELECT
                        1
                        FROM ehr_event_txn
                        WHERE evt_txn_type = 'FTP' AND ehr_givenname = par_in_file_name) THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    SELECT
                        evt_msg_no, evt_txn_dtm
                        INTO par_in_message_no, var_txn_dtm
                        FROM ehr_event_txn
                        WHERE evt_txn_type = 'FTP' AND ehr_givenname = par_in_file_name;
                    UPDATE ehr_event_txn
                    SET ehr_flag = par_in_sftp_status, sys_dtm = localtimestamp
                        WHERE evt_txn_dtm = var_txn_dtm AND evt_txn_type = 'FTP' AND evt_msg_no = par_in_message_no;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    BEGIN
                        var_rc := sql$rowcount;
                        var_err := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_err := 1;
                    END;

                    IF var_err <> 0 OR var_rc <> 1 THEN
                        BEGIN
                            EXIT exit_error;
                        END;
                    END IF;
                    EXIT exit_normal;
                END;
            END IF;
            /* --------------------------------------------- */
        END;
        pas_return_code := 0;
        RETURN;
    END;
    pas_return_code := - 1;
    RETURN;
    /* --	return @return_error_code */
END;
$BODY$
LANGUAGE plpgsql;