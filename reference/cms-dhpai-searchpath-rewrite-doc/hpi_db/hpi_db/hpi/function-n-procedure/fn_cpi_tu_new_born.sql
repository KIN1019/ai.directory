-- DROP FUNCTION hpi.fn_cpi_tu_new_born();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_tu_new_born()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    var_valid_flag VARCHAR(1);
    var_hkid VARCHAR(12);
    var_mo_prk VARCHAR(8);
    var_birth_order INTEGER;
    var_mo_case VARCHAR(12);
    var_hosp_code VARCHAR(3);
    var_count INTEGER;
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    update$birth_order BOOLEAN = FALSE;
    update$mother_patient_key BOOLEAN = FALSE;
    update$mother_case_no BOOLEAN = FALSE;
BEGIN
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$birth_order = TRUE;
        WHEN 'UPDATE' THEN
            update$birth_order = ((SELECT
                array_agg(birth_order)
                FROM deleted) != (SELECT
                array_agg(birth_order)
                FROM inserted));
        ELSE
            update$birth_order := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$mother_patient_key = TRUE;
        WHEN 'UPDATE' THEN
            update$mother_patient_key = ((SELECT
                array_agg(mother_patient_key)
                FROM deleted) != (SELECT
                array_agg(mother_patient_key)
                FROM inserted));
        ELSE
            update$mother_patient_key := FALSE;
    END CASE;
    CASE TG_OP
        WHEN 'INSERT' THEN
            update$mother_case_no = TRUE;
        WHEN 'UPDATE' THEN
            update$mother_case_no = ((SELECT
                array_agg(mother_case_no)
                FROM deleted) != (SELECT
                array_agg(mother_case_no)
                FROM inserted));
        ELSE
            update$mother_case_no := FALSE;
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
            RAISE EXCEPTION 'Multiple rows update of new born is not allowed!' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;

    IF update$birth_order OR update$mother_patient_key OR update$mother_case_no THEN
        BEGIN
            SELECT
                mother_patient_key, birth_order, mother_case_no, hospital_code
                INTO var_mo_prk, var_birth_order, var_mo_case, var_hosp_code
                FROM inserted;
            SELECT
                COUNT(*)
                INTO var_count
                FROM cpi_new_born
                WHERE mother_patient_key = var_mo_prk AND hospital_code = var_hosp_code AND mother_case_no = var_mo_case AND birth_order = var_birth_order;

            IF var_count > 1 THEN
                BEGIN
                    RAISE EXCEPTION 'Duplicate Birth Order is not allowed!' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
            END IF;
        END;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_cpi_tu_new_born" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
