-- DROP FUNCTION hpi."fn_tU_ip_specialty"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_ip_specialty"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on ip_specialty */
DECLARE
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    update$specialty_code BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$specialty_code = TRUE;
            WHEN 'UPDATE' THEN
                update$specialty_code = ((SELECT
                    array_agg(specialty_code)
                    FROM deleted) != (SELECT
                    array_agg(specialty_code)
                    FROM inserted));
            ELSE
                update$specialty_code := FALSE;
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
        var_numrows := var_rowcount$aws$;

        IF var_numrows = 0 THEN
            RETURN NULL;
        END IF;

        IF update$specialty_code THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'UPDATE', 'specialty_code' USING ERRCODE := '200019';
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


;ALTER FUNCTION "fn_tU_ip_specialty" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
