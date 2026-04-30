-- DROP FUNCTION hpi."fn_tU_destination"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_destination"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on destination */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insDestination_code" CHAR(03);
    var_rowcount$aws$ INTEGER;
    update$destination_code BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$destination_code = TRUE;
            WHEN 'UPDATE' THEN
                update$destination_code = ((SELECT
                    array_agg(destination_code)
                    FROM deleted) != (SELECT
                    array_agg(destination_code)
                    FROM inserted));
            ELSE
                update$destination_code := FALSE;
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
        /* destination join with cpi_case ON PARENT UPDATE CASCADE */
        IF update$destination_code THEN
            BEGIN
                IF var_numrows = 1 THEN
                    BEGIN
                        SELECT
                            inserted.destination_code
                            INTO "var_insDestination_code"
                            FROM inserted;
                        UPDATE cpi_case
                        SET destination_code = "var_insDestination_code"
                        FROM inserted, deleted
                            WHERE cpi_case.destination_code = deleted.destination_code;
                    END;
                ELSE
                    BEGIN
                        RAISE EXCEPTION '% % ', 'UPDATE', 'destination' USING ERRCODE := '200013';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK ;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tU_destination" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
