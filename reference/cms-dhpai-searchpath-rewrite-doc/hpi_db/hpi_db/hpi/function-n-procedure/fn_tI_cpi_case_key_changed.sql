-- DROP FUNCTION hpi."fn_tI_cpi_case_key_changed"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_cpi_case_key_changed"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on cpi_case_key_changed */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insOld_HKID" CHAR(12);
    var_ret_code INTEGER;
    var_rowcount$aws$ INTEGER;
    update$case_no BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$case_no = TRUE;
            WHEN 'UPDATE' THEN
                update$case_no = ((SELECT
                    array_agg(case_no)
                    FROM deleted) != (SELECT
                    array_agg(case_no)
                    FROM inserted));
            ELSE
                update$case_no := FALSE;
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
                RAISE EXCEPTION '% % ', 'INSERT', 'cpi_case_key_changed' USING ERRCODE = '200013';
                EXIT error;
            END;
        END IF;
        /*
        else
        begin
           select @insOld_HKID = Old_HKID
              from inserted
        
           exec @ret_code = hasp_check_hkid @insOld_HKID
           if @ret_code > 0
           begin
              raiserror 200015, "HKID"
              goto error
           end
        end
        */
        /* cpi_case may have cpi_case_key_changed ON CHILD INSERT RESTRICT */
        IF update$case_no THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, cpi_case
                    WHERE inserted.case_no = cpi_case.case_no AND inserted.hospital_code = cpi_case.hospital_code;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_case_key_changed', 'cpi_case' USING ERRCODE = '200012';
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


;ALTER FUNCTION "fn_tI_cpi_case_key_changed" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
