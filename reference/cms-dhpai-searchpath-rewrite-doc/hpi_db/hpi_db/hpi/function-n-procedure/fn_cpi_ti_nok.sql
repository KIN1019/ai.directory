-- DROP FUNCTION hpi.fn_cpi_ti_nok();

CREATE OR REPLACE FUNCTION fn_cpi_ti_nok()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    var_valid_flag VARCHAR(1);
    var_hkid VARCHAR(12);
    var_dist VARCHAR(5);
    var_patient_key VARCHAR(8);
   
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    update$district BOOLEAN = FALSE;
    update$patient_key BOOLEAN = FALSE;
BEGIN
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$district = TRUE;
        WHEN 'UPDATE' THEN
            update$district = ((SELECT
                array_agg(district)
                FROM deleted) != (SELECT
                array_agg(district)
                FROM inserted));
        ELSE
            update$district := FALSE;
    END CASE;
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

    IF var_numrows > 1 THEN
        BEGIN
            RAISE EXCEPTION 'Multiple rows insert of NOK is not allowed!' USING ERRCODE = '25000';
            ROLLBACK; /* ---20130805 */
            RETURN NULL;
        END;
    END IF;
    SELECT
        hkid, district, patient_key
        INTO var_hkid, var_dist, var_patient_key
        FROM inserted;

    IF (var_hkid IS NOT NULL) THEN
        BEGIN
            CALL cpi_pq_validate_hkid(var_return_code, var_hkid, var_valid_flag);

            IF (var_valid_flag = 'N') THEN
                BEGIN
                    IF var_return_code = 1 THEN
                        BEGIN
                            RAISE EXCEPTION 'Invalid HKID, fail to insert NOK record!' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
                    ELSE
                        IF var_return_code = 2 THEN
                            BEGIN
                                RAISE EXCEPTION 'Invalid HKID check digit, fail to insert NOK record!' USING ERRCODE = '25000';
                                RETURN NULL;
                            END;
                        END IF;
                    END IF;
                END;
            END IF;
        END;
    END IF;

    IF update$district THEN
        BEGIN
            IF var_dist IS NOT NULL THEN
                BEGIN
                    CALL cpi_pq_validate_district(var_return_code, var_dist, var_valid_flag);

                    IF var_return_code <> 0 OR var_valid_flag <> 'Y' THEN
                        BEGIN
                            RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_nok', 'district' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;

    IF update$patient_key THEN
        BEGIN
            IF NOT EXISTS (SELECT
                *
                FROM cpi_patient
                WHERE patient_key = var_patient_key) THEN
                BEGIN
                    RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_nok', 'cpi_patient' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
            END IF;
        END;
    END IF;
   
    RETURN NULL;
END;
$function$
;

;ALTER FUNCTION "fn_cpi_ti_nok" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
