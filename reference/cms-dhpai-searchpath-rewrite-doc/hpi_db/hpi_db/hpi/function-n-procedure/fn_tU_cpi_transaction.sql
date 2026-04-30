-- DROP FUNCTION hpi."fn_tU_cpi_transaction"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_cpi_transaction"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/*
Modification History
   19980902 WL - OPAS's skip tx will be in "O", delete
					  cpi_suspend_upload_log if "O" is marked
*/
/* UPDATE trigger on cpi_transaction */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insSystem_datetime" TIMESTAMP WITHOUT TIME ZONE;
    "var_insUpload_status" CHAR(01);
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

        IF (SELECT
            COUNT(*)
            FROM inserted
            WHERE upload_status IN ('S', 'K', 'P', 'O')) > 1 THEN
            BEGIN
                RAISE EXCEPTION 'More than one row are found in inserted of cpi_transaction' USING ERRCODE := '25000';
                EXIT error;
            END;
        END IF;

        IF EXISTS (SELECT
            *
            FROM inserted
            WHERE upload_status IN ('S', 'K', 'P', 'O')) THEN
            BEGIN
                DELETE FROM hpi.cpi_suspend_upload_log
                USING deleted
                    WHERE deleted.transaction_datetime = cpi_suspend_upload_log.transaction_datetime AND deleted.hospital_code = cpi_suspend_upload_log.hospital_code;
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK ;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tU_cpi_transaction" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
