-- DROP FUNCTION hpi.fn_ti_cpi_movement();

CREATE OR REPLACE FUNCTION fn_ti_cpi_movement()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* INSERT trigger on cpi_movement */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    var_date TIMESTAMP WITHOUT TIME ZONE;
    var_insMovement_count INTEGER;
    var_insMovement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_insMovement_type VARCHAR(01);
    var_insCase_no VARCHAR(12);
    var_insHospital_code VARCHAR(3);
    var_case_type VARCHAR(01);
    var_rowcount$aws$ INTEGER;
    update$movement_dtm BOOLEAN = FALSE;
    update$ward_code BOOLEAN = FALSE;
    update$case_no BOOLEAN = FALSE;
    update$bed_no BOOLEAN = FALSE;
    update$specialty BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$movement_dtm = TRUE;
            WHEN 'UPDATE' THEN
                update$movement_dtm = ((SELECT
                    array_agg(movement_dtm)
                    FROM deleted) != (SELECT
                    array_agg(movement_dtm)
                    FROM inserted));
            ELSE
                update$movement_dtm := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$ward_code = TRUE;
            WHEN 'UPDATE' THEN
                update$ward_code = ((SELECT
                    array_agg(ward_code)
                    FROM deleted) != (SELECT
                    array_agg(ward_code)
                    FROM inserted));
            ELSE
                update$ward_code := FALSE;
        END CASE;
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
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$bed_no = TRUE;
            WHEN 'UPDATE' THEN
                update$bed_no = ((SELECT
                    array_agg(bed_no)
                    FROM deleted) != (SELECT
                    array_agg(bed_no)
                    FROM inserted));
            ELSE
                update$bed_no := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$specialty = TRUE;
            WHEN 'UPDATE' THEN
                update$specialty = ((SELECT
                    array_agg(specialty)
                    FROM deleted) != (SELECT
                    array_agg(specialty)
                    FROM inserted));
            ELSE
                update$specialty := FALSE;
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
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_date;

        IF var_numrows = 0 THEN
            RETURN NULL;
        END IF;

        IF var_numrows > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'INSERT', 'cpi_movement' USING ERRCODE = '20013';
                EXIT error;
            END;
        END IF;
        SELECT
            case_type
            INTO var_case_type
            FROM cpi_case AS c, inserted AS i
            WHERE c.case_no = i.case_no AND c.hospital_code = i.hospital_code;
        SELECT
            movement_type
            INTO var_insMovement_type
            FROM inserted;
        /* movement datetime should be in ascending order */
        IF update$movement_dtm THEN
            BEGIN
                SELECT
                    movement_count, movement_dtm, case_no, hospital_code
                    INTO var_insMovement_count, var_insMovement_datetime, var_insCase_no, var_insHospital_code
                    FROM inserted;

                IF var_insMovement_count > 1 AND NOT EXISTS (SELECT
                    *
                    FROM cpi_movement
                    WHERE case_no = var_insCase_no AND movement_count = var_insMovement_count - 1 AND movement_dtm <= var_insMovement_datetime AND hospital_code = var_insHospital_code) THEN
                    BEGIN
                        RAISE EXCEPTION USING ERRCODE = '20017';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ward join with cpi_movement ON CHILD INSERT RESTRICT */
        IF update$ward_code AND var_case_type != 'O' AND var_insMovement_type != 'D' THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                /*
                Modified by Alex on 20-02-1997
                select @validcnt = count(*)
                  from inserted,Ward
                    where
                      inserted.Ward_code = Ward.Ward_code and
                      Ward.Open_date <= Movement_datetime and
                      ( Ward.Close_date > Movement_datetime or
                        Ward.Close_date = null     )
                */
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM ward, inserted
                    WHERE ward.effective_date = (SELECT
                        MAX(ward.effective_date)
                        FROM ward, inserted
                        WHERE ward.effective_date <= inserted.movement_dtm AND ward.ward_code = inserted.ward_code AND ward.hospital_code = inserted.hospital_code) AND inserted.ward_code = ward.ward_code AND ward.active_status = 'A' AND ward.hospital_code = inserted.hospital_code;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_movement', 'ward' USING ERRCODE = '20012';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* cpi_case Must have one cpi_movement ON CHILD INSERT RESTRICT */
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
                        RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_movement', 'cpi_case' USING ERRCODE = '20012';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* Bed join with cpi_movement ON CHILD INSERT RESTRICT */
        IF update$bed_no THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, Bed
                    WHERE inserted.ward_code = Bed.Ward_code AND inserted.bed_no = Bed.Bed_no AND inserted.hospital_code = Bed.Hospital_code;
                SELECT
                    COUNT(*)
                    INTO var_nullcnt
                    FROM inserted
                    WHERE inserted.ward_code IS NULL OR inserted.bed_no IS NULL;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_movement', 'Bed' USING ERRCODE = '20012';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ip_specialty join with cpi_movement ON CHILD INSERT RESTRICT */
        IF update$specialty AND var_case_type != 'O' THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                /*
                Modified by Alex on 20-11-1996
                select @validcnt = count(*)
                  from inserted,Specialty
                    where
                      inserted.Specialty_code = Specialty.Specialty_code    and
                      Specialty.Open_date <= Movement_datetime              and
                      ( Specialty.Close_date > Movement_datetime or
                        Specialty.Close_date = null     )
                */
                SELECT
                    count_1, movement_type
                    INTO var_validcnt, var_insMovement_type
                    FROM (SELECT
                        inserted.movement_type
                        FROM inserted) AS ungrouped_query, (SELECT
                        COUNT(*) AS count_1
                        FROM ip_specialty, inserted
                        WHERE ip_specialty.effective_date = (SELECT
                            MAX(ip_specialty.effective_date)
                            FROM ip_specialty, inserted
                            WHERE ip_specialty.effective_date <= inserted.movement_dtm AND ip_specialty.specialty_code = inserted.specialty AND ip_specialty.hospital_code = inserted.hospital_code) AND inserted.specialty = ip_specialty.specialty_code AND ip_specialty.active_status = 'A' AND ip_specialty.hospital_code = inserted.hospital_code) AS grouped_query;

                IF var_insMovement_type = 'D' THEN
                    SELECT
                        1
                        INTO var_validcnt;
                END IF;

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'INSERT', 'cpi_ovement', 'ip_specialty' USING ERRCODE = '20012';
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

;ALTER FUNCTION "fn_ti_cpi_movement" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
