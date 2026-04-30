-- DROP FUNCTION hpi."fn_tD_cpi_case"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_cpi_case"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* ERwin Builtin Thu Jul 28 11:21:44 1994 */
/* DELETE trigger on cpi_case */
DECLARE
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

    IF var_numrows = 0 THEN
        RETURN NULL;
    END IF;
    /* cpi_case Must have one cpi_movement ON PARENT DELETE CASCADE */
    DELETE FROM cpi_movement
    USING deleted
        WHERE cpi_movement.case_no = deleted.case_no AND cpi_movement.hospital_code = deleted.hospital_code;
    /* cpi_case may have Diagnosis ON PARENT DELETE CASCADE */
    DELETE FROM "Diagnosis"
    USING deleted
        WHERE "Diagnosis"."Case_no" = deleted.case_no AND "Diagnosis"."Hospital_code" = deleted.hospital_code;
    /* cpi_case may have cpi_case_key_changed ON PARENT DELETE CASCADE */
    DELETE FROM cpi_case_key_changed
    USING deleted
        WHERE cpi_case_key_changed.case_no = deleted.case_no AND cpi_case_key_changed.hospital_code = deleted.hospital_code;
    /* cpi_case may have HN_case_detail ON PARENT DELETE CASCADE */
    DELETE FROM "HN_case_detail"
    USING deleted
        WHERE "HN_case_detail"."Case_no" = deleted.case_no AND "HN_case_detail"."Hospital_code" = deleted.hospital_code;
    /* cpi_case Contains cpi_ae_case_detail ON PARENT DELETE CASCADE */
    DELETE FROM cpi_ae_case_detail
    USING deleted
        WHERE cpi_ae_case_detail.case_no = deleted.case_no AND cpi_ae_case_detail.hospital_code = deleted.hospital_code;
    /* cpi_case Contains cpi_patient_location ON PARENT DELETE CASCADE */
    DELETE FROM cpi_patient_location
    USING deleted
        WHERE cpi_patient_location.case_no = deleted.case_no AND cpi_patient_location.hospital_code = deleted.hospital_code;
    RETURN NULL;

    <<error>>
    BEGIN
    END;
    RETURN NULL;
END;
$function$
;

;ALTER FUNCTION "fn_tD_cpi_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
