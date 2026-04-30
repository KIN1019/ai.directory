-- DROP FUNCTION download."fn_tI_transaction_log"();

CREATE OR REPLACE FUNCTION download."fn_tI_transaction_log"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on transaction_log */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_errno INTEGER;
    var_errmsg VARCHAR(255);
    var_new_dtm VARCHAR(60);
    var_prev_dtm VARCHAR(60);
    var_return_code INTEGER;
begin

    <<error>>
    BEGIN
        SELECT
            TO_CHAR(system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYY-MM-DD HH24:MI:SS.US')
            INTO var_new_dtm
            FROM inserted;
        SELECT
            TO_CHAR(system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYY-MM-DD HH24:MI:SS.US')
            INTO var_prev_dtm
            FROM download.transaction_log_control;

        IF (DATE_PART('epoch', var_new_dtm::TIMESTAMP) - DATE_PART('epoch', var_prev_dtm::TIMESTAMP))::NUMERIC(20, 0) < - 2 THEN
            BEGIN
                RAISE NOTICE '!!!!! Prev %, Current %', var_prev_dtm, var_new_dtm;
                SELECT
                    300004
                    INTO var_errno;
                EXIT error;
            END;
        END IF;
        UPDATE download.transaction_log_control
        SET system_dtm = inserted.system_dtm
        FROM inserted;
        RETURN NULL;
    END;
    RAISE EXCEPTION USING ERRCODE := var_errno;
    RETURN NULL;
END;
$function$
;

ALTER FUNCTION "fn_tI_transaction_log" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";