-- DROP FUNCTION hkpmi."fn_tD_me_mail_conf"();

CREATE OR REPLACE FUNCTION hkpmi."fn_tD_me_mail_conf"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* ---20140821 -- */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_delhkid CHAR(12);
    var_errno INTEGER;
    var_return_code INTEGER;
    var_rowcount$aws$ INTEGER;
BEGIN
    <<error>>
    BEGIN
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
        /* ---- last update on 20140821 ---- */
        /* ---- 1). DEL operation NOT allowed -- */
        var_numrows := var_rowcount$aws$;

        IF var_numrows > 0 THEN
            BEGIN
                SELECT
                    500015
                    INTO var_errno; /* --Multiple insert/update/delete prohibit */
                EXIT error;
            END;
        END IF;
        RETURN NULL;
    END;
    -- ROLLBACK;
    RAISE EXCEPTION USING ERRCODE := var_errno;
    RETURN NULL;
END;
$function$
;

ALTER FUNCTION "fn_tD_me_mail_conf" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

