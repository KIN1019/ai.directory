-- DROP FUNCTION hpi."fn_tD_User_group"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_User_group"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on User_group */
DECLARE
    var_errno INTEGER;
    var_errmsg VARCHAR(255);
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

        IF EXISTS (SELECT
            *
            FROM deleted, "User_profile"
            WHERE "User_profile"."Group_ID" = deleted."Group_ID" AND "User_profile"."Hospital_code" = deleted."Hospital_code") THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'DELETE', 'User_group', 'User_profile' USING ERRCODE = '200014';
                EXIT error;
            END;
        END IF;
        /* User_group may have User_group_detail ON PARENT DELETE CASCADE */
        DELETE FROM "User_group_detail"
        USING deleted
            WHERE "User_group_detail"."Group_ID" = deleted."Group_ID" AND "User_group_detail"."Hospital_code" = deleted."Hospital_code";
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tD_User_group" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
