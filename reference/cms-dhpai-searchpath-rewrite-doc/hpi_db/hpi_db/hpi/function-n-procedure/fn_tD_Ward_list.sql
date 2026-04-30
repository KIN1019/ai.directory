-- DROP FUNCTION hpi."fn_tD_Ward_list"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_Ward_list"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on Ward_list */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insCase_no" CHAR(12);
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

        IF var_numrows > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'DELETE', 'Ward_list' USING ERRCODE = '200013';
                EXIT error;
            END;
        END IF;
        /* Check whether the deleted rows are in sync. with case */
        IF EXISTS (SELECT
            *
            FROM cpi_case AS c, deleted AS d
            WHERE c.case_no = d.Case_no AND c.discharge_code IS NULL AND status_code = 'AC' AND c.hospital_code = d.Hospital_code) THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'DELETE', 'Ward_list', 'cpi_case' USING ERRCODE = '200018';
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


;ALTER FUNCTION "fn_tD_Ward_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
