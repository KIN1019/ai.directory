-- DROP FUNCTION hpi.fn_cpi_td_patient();

CREATE OR REPLACE FUNCTION hpi.fn_cpi_td_patient()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
    /* 19990130 GL, patient can be deleted since cpi_merge */
    /* raiserror 25000 "Patient record cannot be deleted!" */
    /* ----20130730 --- */
    var_numrows := var_rowcount$aws$;

    IF var_numrows > 1 THEN
        BEGIN
            RAISE EXCEPTION 'Delete multi patient records is restricted' USING ERRCODE = '25000';
            ROLLBACK; /* ----20130805 */
            RETURN NULL;
        END;
    END IF;
    /* ----20130730 --- */
    IF EXISTS (SELECT
        *
        FROM cpi_patient_hospital_data AS p, deleted AS d
        WHERE d.patient_key = p.patient_key) THEN
        BEGIN
            RAISE EXCEPTION 'MRN exists, patient cannot be deleted!' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;

    IF EXISTS (SELECT
        *
        FROM cpi_patient_location AS p, deleted AS d
        WHERE d.patient_key = p.patient_key) THEN
        BEGIN
            RAISE EXCEPTION 'Patient location exists, patient cannot be deleted!' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;

    IF EXISTS (SELECT
        *
        FROM cpi_new_born AS b, deleted AS d
        WHERE d.patient_key = b.mother_patient_key) THEN
        BEGIN
            RAISE EXCEPTION 'Mother''s information exists, patient cannot be deleted' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;

    IF EXISTS (SELECT
        *
        FROM cpi_new_born AS b, deleted AS d
        WHERE d.patient_key = b.new_born_patient_key) THEN
        BEGIN
            RAISE EXCEPTION 'New Born information exists, patient cannot be deleted!' USING ERRCODE = '25000';
            RETURN NULL;
        END;
    END IF;

    BEGIN
        DELETE FROM cpi_unmatch_hkid
        USING deleted
            WHERE cpi_unmatch_hkid.hkid = deleted.hkid;
        EXCEPTION
            WHEN OTHERS THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to delete Unmatch HKID!' USING ERRCODE = '25000';
                    RETURN NULL;
                END;
    END;

    BEGIN
        DELETE FROM cpi_nok
        USING deleted
            WHERE cpi_nok.patient_key = deleted.patient_key;
        EXCEPTION
            WHEN OTHERS THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to delete patient''s NOK' USING ERRCODE = '25000';
                END;
    END;
    /* -- added by WL on 26 NOV 99 --- */
    BEGIN
        DELETE FROM cpi_postal_address
        USING deleted
            WHERE cpi_postal_address.patient_key = deleted.patient_key;
        EXCEPTION
            WHEN OTHERS THEN
                BEGIN
                    RAISE EXCEPTION 'Fail to delete patient''s POSTAL ADDRESS' USING ERRCODE = '25000';
                END;
    END;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_cpi_td_patient" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
