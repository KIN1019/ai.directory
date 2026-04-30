-- DROP FUNCTION hpi."fn_tU_User_group"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_User_group"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on User_group */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insGroup_ID" CHAR(10);
    var_errno INTEGER;
    var_errmsg VARCHAR(255);
    var_rowcount$aws$ INTEGER;
    update$Group_ID BOOLEAN = FALSE;
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
        /* User_group join with User_profile ON PARENT UPDATE CASCADE */
        IF update$Group_ID THEN
            BEGIN
                IF var_numrows = 1 THEN
                    BEGIN
                        SELECT
                            inserted."Group_ID"
                            INTO "var_insGroup_ID"
                            FROM inserted;
                        UPDATE "User_profile"
                        SET "Group_ID" = "var_insGroup_ID"
                        FROM inserted, deleted
                            WHERE user_profile."Group_ID" = deleted."Group_ID" AND user_profile."Hospital_code" = deleted."Hospital_code";
                    END;
                ELSE
                    BEGIN
                        RAISE EXCEPTION '% % ', 'UPDATE', 'User_group' USING ERRCODE := '200013';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* User_group may have User_group_detail ON PARENT UPDATE CASCADE */
        IF update$Group_ID THEN
            BEGIN
                IF var_numrows = 1 THEN
                    BEGIN
                        SELECT
                            inserted."Group_ID"
                            INTO "var_insGroup_ID"
                            FROM inserted;
                        UPDATE "User_group_detail"
                        SET "Group_ID" = "var_insGroup_ID"
                        FROM inserted, deleted
                            WHERE User_group_detail."Group_ID" = deleted."Group_ID" AND User_group_detail."Hospital_code" = deleted."Hospital_code";
                    END;
                ELSE
                    BEGIN
                        RAISE EXCEPTION '% % ', 'UPDATE', 'User_group' USING ERRCODE := '200013';
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


;ALTER FUNCTION "fn_tU_User_group" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
