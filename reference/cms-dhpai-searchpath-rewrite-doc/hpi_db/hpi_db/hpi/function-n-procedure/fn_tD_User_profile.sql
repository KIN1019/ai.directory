-- DROP FUNCTION hpi."fn_tD_User_profile"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_User_profile"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* 20111228 : NOT allow to delete User_profile entries */
/* Same for CPI/HPI */
/* DELETE trigger on User_profile */
DECLARE
    var_numrows INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
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

        IF var_numrows >= 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'DELETE', 'NOT allow to delete User_profile' USING ERRCODE = '200013';
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


;ALTER FUNCTION "fn_tD_User_profile" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
