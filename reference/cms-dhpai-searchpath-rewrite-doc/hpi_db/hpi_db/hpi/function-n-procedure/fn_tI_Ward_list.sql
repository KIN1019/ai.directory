-- DROP FUNCTION hpi."fn_tI_Ward_list"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_Ward_list"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on Ward_list */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insCase_no" CHAR(12);
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

        IF var_numrows > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'INSERT', 'Ward_list' USING ERRCODE = '200013';
                EXIT error;
            END;
        END IF;
        /* Check whether the inserted rows are in sync. with movement */
        IF NOT EXISTS (SELECT
            *
            FROM cpi_case AS c, cpi_movement AS m, inserted AS i
            WHERE c.case_no = i.Case_no AND c.discharge_code IS NULL AND m.case_no = i.Case_no AND m.movement_count = c.movement_count AND m.ward_code = i.Ward_code AND COALESCE(m.bed_no, 'unk') = COALESCE(i.Bed_no, 'unk') AND m.specialty = i.Specialty_code AND i.Hospital_code = c.hospital_code AND i.Hospital_code = m.hospital_code) THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'INSERT', 'Ward_list', 'cpi_movement' USING ERRCODE = '200018';
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


;ALTER FUNCTION "fn_tI_Ward_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
