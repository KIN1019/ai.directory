-- DROP FUNCTION hpi."fn_tU_Func_table"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_Func_table"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on Func_table */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insFunc_ID" INTEGER;
    var_rowcount$aws$ INTEGER;
    update$Func_ID BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$Func_ID = TRUE;
            WHEN 'UPDATE' THEN
                update$Func_ID = ((SELECT
                    array_agg(Func_ID)
                    FROM deleted) != (SELECT
                    array_agg(Func_ID)
                    FROM inserted));
            ELSE
                update$Func_ID := FALSE;
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
        /* Func_table join with User_group_detail ON PARENT UPDATE CASCADE */
        IF update$Func_ID THEN
            BEGIN
                IF var_numrows = 1 THEN
                    BEGIN
                        SELECT
                            inserted."Func_ID"
                            INTO "var_insFunc_ID"
                            FROM inserted;
                        UPDATE "User_group_detail"
                        SET "Func_ID" = "var_insFunc_ID"
                        FROM inserted, deleted
                            WHERE user_group_detail."Func_ID" = deleted."Func_ID";
                    END;
                ELSE
                    BEGIN
                        RAISE EXCEPTION '%', format('UPDATE', 'Func_table') USING ERRCODE := '200013';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tU_Func_table" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
