-- DROP FUNCTION hpi.fn_cpi_ti_new_born();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_ti_new_born()
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
    var_count INTEGER;
    var_hosp_code VARCHAR(3);
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
            RAISE EXCEPTION 'Multiple rows insert of new born is not allowed!' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;
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
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_cpi_ti_new_born" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
