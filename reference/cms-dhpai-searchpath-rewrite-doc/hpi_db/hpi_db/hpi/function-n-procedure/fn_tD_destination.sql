-- DROP FUNCTION hpi."fn_tD_destination"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_destination"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on destination */
DECLARE
    var_numrows INTEGER;
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
        /* destination join with cpi_case ON PARENT DELETE RESTRICT */
        IF EXISTS (SELECT
            *
            FROM deleted, cpi_case
            WHERE cpi_case.destination_code = deleted.destination_code) THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'DELETE', 'destination', 'cpi_case' USING ERRCODE = '200014';
                EXIT error;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tD_destination" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
