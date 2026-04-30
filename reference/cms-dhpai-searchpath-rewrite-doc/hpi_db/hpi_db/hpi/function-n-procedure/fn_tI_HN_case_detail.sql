-- DROP FUNCTION hpi."fn_tI_HN_case_detail"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_HN_case_detail"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on HN_case_detail */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_i_icd9 CHAR(4);
    var_e_icd9 CHAR(4);
    var_rowcount$aws$ INTEGER;
    update$Case_no BOOLEAN = FALSE;
    update$PP_code BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$Case_no = TRUE;
            WHEN 'UPDATE' THEN
                update$Case_no = ((SELECT
                    array_agg(Case_no)
                    FROM deleted) != (SELECT
                    array_agg(Case_no)
                    FROM inserted));
            ELSE
                update$Case_no := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$PP_code = TRUE;
            WHEN 'UPDATE' THEN
                update$PP_code = ((SELECT
                    array_agg(PP_code)
                    FROM deleted) != (SELECT
                    array_agg(PP_code)
                    FROM inserted));
            ELSE
                update$PP_code := FALSE;
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
        /* No more than 1 row can be inserted */
        IF var_numrows > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'INSERT', 'HN_case_detail' USING ERRCODE = '200013';
                EXIT error;
            END;
        END IF;
        /* cpi_case may have HN_case_detail ON CHILD INSERT RESTRICT */
        IF update$Case_no THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    count_1, Internal_ICD9_code, External_ICD9_code
                    INTO var_validcnt, var_i_icd9, var_e_icd9
                    FROM (SELECT
                        Internal_ICD9_code, External_ICD9_code
                        FROM inserted) AS ungrouped_query, (SELECT
                        COUNT(*) AS count_1
                        FROM inserted, cpi_case
                        WHERE inserted.Case_no = cpi_case.case_no AND inserted.Hospital_code = cpi_case.hospital_code) AS grouped_query;
                RAISE NOTICE '[fn_tI_HN_case_detail81]%,%,%', var_validcnt, var_nullcnt, var_numrows;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'HN_case_detail', 'cpi_case' USING ERRCODE = '200012';
                        EXIT error;
                    END;
                END IF;

                IF (var_i_icd9 IS NULL AND var_e_icd9 IS NOT NULL) OR (var_i_icd9 IS NOT NULL AND var_e_icd9 IS NULL) THEN
                    BEGIN
                        RAISE EXCEPTION USING ERRCODE = '200028';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* pp contains PP_code ON CHILD UPDATE RESTRICT */
        IF update$PP_code THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, pp
                    WHERE inserted.PP_code = pp.pp_code;
                SELECT
                    COUNT(*)
                    INTO var_nullcnt
                    FROM inserted
                    WHERE inserted.PP_code IS NULL;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    RAISE NOTICE '[fn_tI_HN_case_detail115]%,%,%', var_validcnt, var_nullcnt, var_numrows;

                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'HN_case_detail', 'pp' USING ERRCODE = '200012';
                        EXIT error;
                    END;
                END IF;
            /* insert row to PP_to_CIS if PP_code is not null */
            /*
            if exists( select * from inserted
                          where PP_code != null )
            begin
               insert into PP_to_CIS
                  select getdate(), Case_no, PP_code, 'A', null
                     from inserted
            end
            */
            END;
        END IF;
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tI_HN_case_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
