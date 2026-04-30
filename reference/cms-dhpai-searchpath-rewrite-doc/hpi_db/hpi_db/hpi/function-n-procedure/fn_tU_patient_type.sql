-- DROP FUNCTION hpi."fn_tU_patient_type"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_patient_type"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on patient_type */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insPay_code" CHAR(3);
    var_rowcount$aws$ INTEGER;
    update$patient_type BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$patient_type = TRUE;
            WHEN 'UPDATE' THEN
                update$patient_type = ((SELECT
                    array_agg(patient_type)
                    FROM deleted) != (SELECT
                    array_agg(patient_type)
                    FROM inserted));
            ELSE
                update$patient_type := FALSE;
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
        /* patient_type join with cpi_case ON PARENT UPDATE CASCADE */
        IF update$patient_type THEN
            BEGIN
                IF var_numrows = 1 THEN
                    BEGIN
                        SELECT
                            inserted.patient_type
                            INTO "var_insPay_code"
                            FROM inserted;
                        UPDATE cpi_case
                        SET patient_type = "var_insPay_code"
                        FROM inserted, deleted
                            WHERE cpi_case.patient_type = deleted.patient_type;
                    END;
                ELSE
                    BEGIN
                        RAISE EXCEPTION '% % ', 'UPDATE', 'patient_type' USING ERRCODE := '200013';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK ;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tU_patient_type" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
