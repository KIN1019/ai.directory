-- DROP FUNCTION hkpmi."fn_tU_me_mail_conf"();

CREATE OR REPLACE FUNCTION hkpmi."fn_tU_me_mail_conf"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* ---20140821 -- */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_del_mail_last_serial INTEGER;
    var_ins_mail_last_serial INTEGER;
    var_del_ehr_mail_last_serial INTEGER;
    var_ins_ehr_mail_last_serial INTEGER;
    var_del_last_poll_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_ins_last_poll_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_errno INTEGER;
    var_err_msg VARCHAR(128);
    var_return_code INTEGER;
    var_rowcount$aws$ INTEGER;
    update$mail_last_serial BOOLEAN = false;
    update$ehr_mail_last_serial BOOLEAN = false;
    update$last_poll_dtm BOOLEAN = false;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$mail_last_serial = TRUE;
            WHEN 'UPDATE' THEN
                update$mail_last_serial = ((SELECT
                    array_agg(mail_last_serial)
                    FROM deleted) != (SELECT
                    array_agg(mail_last_serial)
                    FROM inserted));
            ELSE
                update$mail_last_serial := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$ehr_mail_last_serial = TRUE;
            WHEN 'UPDATE' THEN
                update$ehr_mail_last_serial = ((SELECT
                    array_agg(ehr_mail_last_serial)
                    FROM deleted) != (SELECT
                    array_agg(ehr_mail_last_serial)
                    FROM inserted));
            ELSE
                update$ehr_mail_last_serial := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$last_poll_dtm = TRUE;
            WHEN 'UPDATE' THEN
                update$last_poll_dtm = ((SELECT
                    array_agg(last_poll_dtm)
                    FROM deleted) != (SELECT
                    array_agg(last_poll_dtm)
                    FROM inserted));
            ELSE
                update$last_poll_dtm := FALSE;
        END CASE;

        IF (TG_OP = 'INSERT') THEN
            SELECT
                count(1)
                FROM inserted
                INTO var_rowcount$aws$;
        ELSE
            SELECT
                count(1)
                FROM deleted
                INTO var_rowcount$aws$;
        END IF;
        /* -----Last Update on 20140821 ---- */
        /* ---- 1). NO multiple update allowed -- */
        var_numrows := var_rowcount$aws$;

        IF var_numrows > 1 THEN
            BEGIN
                SELECT
                    500015
                    INTO var_errno; /* --Multiple update and delete prohibit */
                EXIT error;
            END;
        END IF;
        SELECT
            mail_last_serial, ehr_mail_last_serial, last_poll_dtm
            INTO var_ins_mail_last_serial, var_ins_ehr_mail_last_serial, var_ins_last_poll_dtm
            FROM inserted;
        SELECT
            mail_last_serial, ehr_mail_last_serial, last_poll_dtm
            INTO var_del_mail_last_serial, var_del_ehr_mail_last_serial, var_del_last_poll_dtm
            FROM deleted;
        /* ------------------- */
        /* Prevent to Reset mail_last_serial/ehr_mail_last_seril ---- */
        
        /* ------------------- */
        IF update$mail_last_serial THEN
            BEGIN
                IF COALESCE(var_ins_mail_last_serial, 0) < COALESCE(var_del_mail_last_serial, 0) THEN
                    BEGIN
                        SELECT
                            500026
                            INTO var_errno;
                        /* --- */
                        SELECT
                            CONCAT('Update me_mail_conf prohibited :mail_last_serial[', CAST (var_ins_mail_last_serial AS CHAR(5)), ']')
                            INTO var_err_msg;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF update$ehr_mail_last_serial THEN
            BEGIN
                IF COALESCE(var_ins_ehr_mail_last_serial, 0) < COALESCE(var_del_ehr_mail_last_serial, 0) THEN
                    BEGIN
                        SELECT
                            500026
                            INTO var_errno;
                        /* --- */
                        SELECT
                            CONCAT('Update me_mail_conf prohibited :ehr_mail_last_serial[', CAST (var_ins_ehr_mail_last_serial AS CHAR(5)), ']')
                            INTO var_err_msg;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ------------------- */
        /* Prevent to Reset TimeMarker to backdate ---- */
        
        /* ------------------- */
        IF update$last_poll_dtm THEN
            BEGIN
                IF COALESCE(var_ins_last_poll_dtm, '20140101') < COALESCE(var_del_last_poll_dtm, '20140101') THEN
                    BEGIN
                        SELECT
                            500026
                            INTO var_errno;
                        SELECT
                            CONCAT('Update me_mail_conf prohibited : New dtm[', aws_sapase_ext.conv_datetime_to_string('CHAR (20)'::TEXT, 'DATETIME'::TEXT, var_ins_last_poll_dtm::TIMESTAMP WITHOUT TIME ZONE, 117), '] Org dtm[', aws_sapase_ext.conv_datetime_to_string('CHAR (20)'::TEXT, 'DATETIME'::TEXT, var_del_last_poll_dtm::TIMESTAMP WITHOUT TIME ZONE, 117), ']')
                            INTO var_err_msg;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        RETURN NULL;
    END;
    -- ROLLBACK;
    RAISE EXCEPTION '%', format('%s', var_err_msg) USING ERRCODE := var_errno;
    RETURN NULL;
END;
$function$
;

ALTER FUNCTION "fn_tU_me_mail_conf" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
