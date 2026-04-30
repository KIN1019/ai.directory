-- DROP FUNCTION hpi."fn_tI_cpi_patient_key_changed"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_cpi_patient_key_changed"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on cpi_patient_key_changed */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insOld_HKID" CHAR(12);
    var_ret_code INTEGER;
    var_valid_flag CHAR(1);
    var_rowcount$aws$ INTEGER;
    update$patient_key BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$patient_key = TRUE;
            WHEN 'UPDATE' THEN
                update$patient_key = ((SELECT
                    array_agg(patient_key)
                    FROM deleted) != (SELECT
                    array_agg(patient_key)
                    FROM inserted));
            ELSE
                update$patient_key := FALSE;
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

        IF var_numrows > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'INSERT', 'Major key changed' USING ERRCODE = '200013';
                EXIT error;
            END;
        ELSE
            BEGIN
                SELECT
                    hkid
                    INTO "var_insOld_HKID"
                    FROM inserted;
                /* --Modified by WL on 17 AUG 99 -- */
                /* --exec @ret_code = cpi_pq_validate_hkid @insOld_HKID, @valid_flag */
                CALL cpi_pq_validate_hkid(var_ret_code, "var_insOld_HKID", var_valid_flag );

                IF var_ret_code > 0 OR var_valid_flag <> 'Y' THEN
                    BEGIN
                        RAISE EXCEPTION '% ', 'hkid' USING ERRCODE = '200015';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* cpi_patient may have cpi_patient_key_changed ON CHILD INSERT RESTRICT */
        IF update$patient_key THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, cpi_patient
                    WHERE inserted.patient_key = cpi_patient.patient_key;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_patient_key_changed', 'cpi_patient' USING ERRCODE = '200012';
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


;ALTER FUNCTION "fn_tI_cpi_patient_key_changed" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
