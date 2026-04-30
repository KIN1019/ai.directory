-- DROP FUNCTION hpi."fn_tU_Event_log"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_Event_log"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on Event_log */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insSystem_datetime" TIMESTAMP WITHOUT TIME ZONE;
    "var_insUpload_status" CHAR(01);
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
            WHERE "Upload_status" IN ('S', 'K', 'P')) > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'UPDATE', 'Event_log' USING ERRCODE := '200013';
                EXIT error;
            END;
        END IF;
        /*
        if exists (select * from inserted
        			where Upload_status in ("S","K","P"))
          begin
        		delete Suspend_upload_log
        			from deleted
        			where deleted.System_datetime =
        					Suspend_upload_log.System_datetime
          end
        */
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tU_Event_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
