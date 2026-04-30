-- DROP FUNCTION hpi."fn_tD_Func_table"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_Func_table"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on Func_table */
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
        /* Func_table join with User_group_detail ON PARENT DELETE RESTRICT */
        IF EXISTS (SELECT
            *
            FROM deleted, "User_group_detail"
            WHERE "User_group_detail"."Func_ID" = deleted."Func_ID") THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'DELETE', 'Func_table', 'User_group_detail' USING ERRCODE = '200014';
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


;ALTER FUNCTION "fn_tD_Func_table" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
