-- DROP FUNCTION hpi."fn_tD_district"();

CREATE OR REPLACE FUNCTION hpi."fn_tD_district"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on district */
DECLARE
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
BEGIN
    <<error>>
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
        /* district join with cpi_nok ON PARENT DELETE RESTRICT */
        IF EXISTS (SELECT
            *
            FROM deleted, cpi_nok
            WHERE cpi_nok.district = deleted.district_code) THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'DELETE', 'district', 'cpi_nok' USING ERRCODE = '200014';
                EXIT error;
            END;
        END IF;
        /* district join with cpi_case ON PARENT DELETE RESTRICT */
        IF EXISTS (SELECT
            *
            FROM deleted, cpi_case
            WHERE cpi_case.district_code = deleted.district_code) THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'DELETE', 'district', 'cpi_case' USING ERRCODE = '200014';
                EXIT error;
            END;
        END IF;
        /* District join with cpi_patient ON PARENT DELETE RESTRICT */
        IF EXISTS (SELECT
            *
            FROM deleted, cpi_patient
            WHERE cpi_patient.district = deleted.district_code) THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'DELETE', 'district', 'cpi_patient' USING ERRCODE = '200014';
                EXIT error;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tD_district" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
