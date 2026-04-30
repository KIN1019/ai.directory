-- DROP FUNCTION hpi."fn_tU_ward"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_ward"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on ward */
DECLARE
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    update$ward_code BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$ward_code = TRUE;
            WHEN 'UPDATE' THEN
                update$ward_code = ((SELECT
                    array_agg(ward_code)
                    FROM deleted) != (SELECT
                    array_agg(ward_code)
                    FROM inserted));
            ELSE
                update$ward_code := FALSE;
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

        IF update$ward_code THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'UPDATE', 'ward_code' USING ERRCODE := '200019';
                EXIT error;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK ;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tU_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
