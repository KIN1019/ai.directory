-- DROP FUNCTION hpi."fn_tD_Ward_spec_tx"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_Ward_spec_tx"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on Ward_spec_tx */
DECLARE
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
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
    /* Ward_spec_tx may have Ward_spec_adj ON PARENT DELETE CASCADE */
    DELETE FROM "Ward_spec_adj"
    USING deleted
        WHERE "Ward_spec_adj"."Ward_spec_adj_date" = deleted."Ward_spec_tx_date" AND "Ward_spec_adj"."Ward_code" = deleted."Ward_code" AND "Ward_spec_adj"."Specialty_code" = deleted."Specialty_code" AND COALESCE("Ward_spec_adj"."Treatment_location", 'null') = COALESCE(deleted."Treatment_location", 'null') AND "Ward_spec_adj"."Hospital_code" = deleted."Hospital_code";
    RETURN NULL;

    <<error>>
    BEGIN
        ROLLBACK;
        RETURN NULL;
    END;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tD_Ward_spec_tx" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
