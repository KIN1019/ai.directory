-- DROP FUNCTION hpi."fn_tI_pp"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_pp"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
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

        IF update$district_code THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, district
                    WHERE inserted.district_code = district.district_code;
                SELECT
                    COUNT(*)
                    INTO var_nullcnt
                    FROM inserted
                    WHERE inserted.district_code IS NULL;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'pp', 'district' USING ERRCODE := '200012';
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


;ALTER FUNCTION "fn_tI_pp" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
