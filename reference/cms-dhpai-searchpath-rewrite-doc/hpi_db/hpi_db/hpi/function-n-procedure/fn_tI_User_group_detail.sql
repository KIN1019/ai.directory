-- DROP FUNCTION hpi."fn_tI_User_group_detail"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_User_group_detail"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on User_group_detail */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_rowcount$aws$ INTEGER;
    update$Group_ID BOOLEAN = FALSE;
    update$Func_ID BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$Group_ID = TRUE;
            WHEN 'UPDATE' THEN
                update$Group_ID = ((SELECT
                    array_agg(Group_ID)
                    FROM deleted) != (SELECT
                    array_agg(Group_ID)
                    FROM inserted));
            ELSE
                update$Group_ID := FALSE;
        END CASE;
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
        /* User_group may have User_group_detail ON CHILD INSERT RESTRICT */
        IF update$Group_ID THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, "User_group"
                    WHERE inserted."Group_ID" = "User_group"."Group_ID" AND inserted."Hospital_code" = "User_group"."Hospital_code";

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'User_group_detail', 'User_group' USING ERRCODE := '200012';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* Func_table join with User_group_detail ON CHILD INSERT RESTRICT */
        IF update$Func_ID THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, "Func_table"
                    WHERE inserted."Func_ID" = "Func_table"."Func_ID";

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'User_group_detail', 'Func_table' USING ERRCODE := '200012';
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


;ALTER FUNCTION "fn_tI_User_group_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
