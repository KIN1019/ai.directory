-- DROP FUNCTION download."fn_tU_transaction_log"();

CREATE OR REPLACE FUNCTION download."fn_tU_transaction_log"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on transaction_log */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insSystem_datetime" TIMESTAMP WITHOUT TIME ZONE;
    "var_insUpload_status" VARCHAR(02);
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
        var_numrows := var_rowcount$aws$;

        IF var_numrows = 0 THEN
            RETURN NULL;
        END IF;

        IF (SELECT
            COUNT(*)
            FROM inserted
            WHERE upload_status IN ('S', 'K', 'P')) > 1 THEN
            BEGIN
                RAISE EXCEPTION 'More than one row are found in inserted of transaction_log' USING ERRCODE := '25000';
                EXIT error;
            END;
        END IF;

        IF EXISTS (SELECT
            *
            FROM inserted
            WHERE upload_status IN ('S', 'K', 'P')) THEN
            BEGIN
                DELETE FROM download.suspend_upload_log
                USING deleted
                    WHERE deleted.system_dtm = suspend_upload_log.transaction_dtm AND deleted.hospital_code = suspend_upload_log.hospital_code;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;

ALTER FUNCTION "fn_tU_transaction_log" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";