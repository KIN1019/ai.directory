-- DROP FUNCTION hpi.fn_cpi_ti_patient_hd();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_ti_patient_hd()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_mrn VARCHAR(8);
    var_hospital_code VARCHAR(3);
    var_valid_flag VARCHAR(1);
    var_return_code INTEGER;
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

    IF var_numrows > 1 THEN
        BEGIN
            RAISE EXCEPTION 'Multiple rows insert of patient_hosptial_data is not allowed!' USING ERRCODE = '25000';
            ROLLBACK; /* ---20130805 */
            RETURN NULL;
        END;
    END IF;
    SELECT
        mrn, hospital_code
        INTO var_mrn, var_hospital_code
        FROM inserted;

    IF (var_mrn IS NOT NULL) THEN
        BEGIN
            CALL cpi_pq_validate_mrn(var_return_code, var_mrn, var_hospital_code, var_valid_flag);

            IF (var_valid_flag = 'N') THEN
                BEGIN
                    IF var_return_code = 1 THEN
                        BEGIN
                            RAISE EXCEPTION 'Invalid MRN, fail to insert patient_hospital_data!' USING ERRCODE = '25000';
                            RETURN NULL;
                        END;
                    ELSE
                        IF var_return_code = 2 THEN
                            BEGIN
                                RAISE EXCEPTION 'Invalid MRN check digit, fail to insert patient_hospital_data!' USING ERRCODE = '25000';
                                RETURN NULL;
                            END;
                        END IF;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_cpi_ti_patient_hd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
