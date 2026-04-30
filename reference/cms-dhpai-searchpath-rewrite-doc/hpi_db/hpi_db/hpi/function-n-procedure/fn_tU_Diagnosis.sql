-- DROP FUNCTION hpi."fn_tU_Diagnosis"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_Diagnosis"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on Diagnosis */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_rowcount$aws$ INTEGER;
    update$Case_no BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$Case_no = TRUE;
            WHEN 'UPDATE' THEN
                update$Case_no = ((SELECT
                    array_agg(Case_no)
                    FROM deleted) != (SELECT
                    array_agg(Case_no)
                    FROM inserted));
            ELSE
                update$Case_no := FALSE;
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
        /* Case may have Diagnosis ON CHILD UPDATE RESTRICT */
        IF update$Case_no THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, cpi_case
                    WHERE inserted."Case_no" = cpi_case.case_no AND inserted."Hospital_code" = cpi_case.hospital_code;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'UPDATE', 'Diagnosis', 'cpi_case' USING ERRCODE := '200012';
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


;ALTER FUNCTION "fn_tU_Diagnosis" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
