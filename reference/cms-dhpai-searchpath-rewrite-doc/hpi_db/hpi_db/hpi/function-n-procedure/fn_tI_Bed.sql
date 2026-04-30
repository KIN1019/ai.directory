-- DROP FUNCTION hpi."fn_tI_Bed"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_Bed"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on Bed */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_rowcount$aws$ INTEGER;
    update$Ward_code BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$Ward_code = TRUE;
            WHEN 'UPDATE' THEN
                update$Ward_code = ((SELECT
                    array_agg(Ward_code)
                    FROM deleted) != (SELECT
                    array_agg(Ward_code)
                    FROM inserted));
            ELSE
                update$Ward_code := FALSE;
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
        /* Ward may have Bed ON CHILD INSERT RESTRICT */
        IF update$Ward_code THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                /*
                Modified by Alex on 20-11-1996
                select @validcnt = count(*)
                  from inserted,Ward
                    where
                      inserted.Ward_code = Ward.Ward_code and
                      ( Ward.Close_date = null or
                        Ward.Close_date > getdate() )
                */
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM ward, inserted
                    WHERE ward.effective_date = (SELECT
                        MAX(ward.effective_date)
                        FROM ward, inserted
                        /* where ward.effective_date <= getdate() */
                        /* and ward.ward_code = inserted.Ward_code */
                        WHERE ward.ward_code = inserted."Ward_code" AND ward.hospital_code = inserted."Hospital_code") AND inserted."Ward_code" = ward.ward_code AND
                    /* and ward.active_status = "A" */
                    inserted."Hospital_code" = ward.hospital_code;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'Bed', 'Ward' USING ERRCODE = '200012';
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


;ALTER FUNCTION "fn_tI_Bed" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
