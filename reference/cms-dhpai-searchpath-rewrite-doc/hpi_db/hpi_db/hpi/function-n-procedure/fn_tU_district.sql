-- DROP FUNCTION hpi."fn_tU_district"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_district"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* UPDATE trigger on district */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insDistrict_code" CHAR(05);
    var_rowcount$aws$ INTEGER;
    update$district_code BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$district_code = TRUE;
            WHEN 'UPDATE' THEN
                update$district_code = ((SELECT
                    array_agg(district_code)
                    FROM deleted) != (SELECT
                    array_agg(district_code)
                    FROM inserted));
            ELSE
                update$district_code := FALSE;
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
        /* district join with cpi_nok ON PARENT UPDATE CASCADE */
        IF update$district_code THEN
            BEGIN
                IF var_numrows = 1 THEN
                    BEGIN
                        SELECT
                            inserted.district_code
                            INTO "var_insDistrict_code"
                            FROM inserted;
                        UPDATE cpi_nok
                        SET district = "var_insDistrict_code"
                        FROM inserted, deleted
                            WHERE cpi_nok.district = deleted.district_code;
                        UPDATE cpi_case
                        SET district_code = "var_insDistrict_code"
                        FROM inserted, deleted
                            WHERE cpi_case.district = deleted.district_code;
                        UPDATE cpi_patient
                        SET district = "var_insDistrict_code"
                        FROM inserted, deleted
                            WHERE cpi_patient.district = deleted.district_code;
                    END;
                ELSE
                    BEGIN
                        RAISE EXCEPTION '% % ', 'UPDATE', 'district' USING ERRCODE := '200013';
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


;ALTER FUNCTION "fn_tU_district" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
