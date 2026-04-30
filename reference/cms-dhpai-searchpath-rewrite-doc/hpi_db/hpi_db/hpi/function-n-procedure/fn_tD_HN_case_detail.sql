-- DROP FUNCTION hpi."fn_tD_HN_case_detail"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_HN_case_detail"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on HN_case_detail */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
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
        /* No more than 1 row can be inserted */
        IF var_numrows > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'DELETE', 'HN_case_detail' USING ERRCODE = '200013';
                EXIT error;
            END;
        END IF;
        /* insert row to PP_to_CIS if PP_code is not null */
        /*
        if exists( select * from deleted
                   where PP_code != null )
        insert into PP_to_CIS
           select getdate(), Case_no, PP_code, 'D', null
              from deleted
        */
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tD_HN_case_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
