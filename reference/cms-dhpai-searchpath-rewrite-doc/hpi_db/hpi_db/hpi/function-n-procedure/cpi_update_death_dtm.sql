-- DROP PROCEDURE hpi.cpi_update_death_dtm(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_update_death_dtm(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_death_datetime timestamp without time zone, IN par_body_category character varying, IN par_user_id character varying, IN par_user_hospital character varying, IN par_source_system character varying, IN par_workstation_id character varying, INOUT par_error_message character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return_code           INTEGER;
    var_rowcount              INTEGER;
    var_error                 INTEGER;
    var_ret                   INTEGER;
    var_status_code           VARCHAR(2);
    var_patient_key           VARCHAR(8);
    var_dob                   TIMESTAMP WITHOUT TIME ZONE;
    var_today                 TIMESTAMP WITHOUT TIME ZONE;
    var_last_update_datetime  TIMESTAMP WITHOUT TIME ZONE;
    var_check_death_date      TIMESTAMP WITHOUT TIME ZONE;
    var_check_death_indicator VARCHAR(1);
    sql$rowcount              BIGINT;
BEGIN
    <<error>>
    BEGIN
        SELECT timestamp_convert(localtimestamp)
        INTO var_today;
        SELECT 0
        INTO var_error;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin tran
        */
        SELECT dob,
               patient_key,
               update_dtm,
               death_date,
               death_indicator
        INTO var_dob, var_patient_key, var_last_update_datetime, var_check_death_date, var_check_death_indicator
        FROM cpi_patient
        WHERE hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT 'Error in selecting patient'
                INTO par_error_message;
                EXIT error;
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT - 1
                INTO var_error;
                SELECT 'Patient does not exist in cpi_patient'
                INTO par_error_message;
                EXIT error;
            END;
        END IF;

        IF var_dob IS NOT NULL THEN
            BEGIN
                IF COALESCE(par_death_datetime, var_dob) < var_dob THEN
                    BEGIN
                        SELECT - 2
                        INTO var_error;
                        SELECT 'Invalid Death Date/Time'
                        INTO par_error_message;
                        EXIT error;
                    END;
                END IF;
            END;
        ELSE
            IF COALESCE(par_death_datetime, var_today) > var_today THEN
                BEGIN
                    SELECT - 2
                    INTO var_error;
                    SELECT 'Invalid Death Date/Time'
                    INTO par_error_message;
                    EXIT error;
                END;
            END IF;
        END IF;
        /* 20-12-2007 YL: allow update death date/time if patient is not marked to death */
        IF var_check_death_indicator <> 'Y' THEN
            SELECT par_death_datetime
            INTO var_check_death_date;
        END IF;

        BEGIN
            SELECT COUNT(*)
            INTO var_rowcount
            FROM cpi_case
            WHERE patient_key = var_patient_key
              AND case_type IN ('A', 'I')
              AND status_code = 'AC'
              AND discharge_code IS NULL;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT 'System error'
                INTO par_error_message;
                EXIT error;
            END;
        END IF;
        /* All case have been discharged */
        IF var_rowcount = 0 THEN
            BEGIN
                CALL cpi_patient_upd_death(var_return_code, par_hospital_code, par_hkid, var_patient_key,
                                           var_check_death_date, var_check_death_indicator, var_today,
                                           par_user_hospital, par_user_ID, var_last_update_datetime, par_source_system,
                                           'Y', par_body_category);

                IF var_return_code <> 0 THEN
                    BEGIN
                        SELECT - 4
                        INTO var_error;
                        SELECT 'Fail to update the body category of cpi_patient'
                        INTO par_error_message;
                        EXIT error;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                /* Update the death date/time and body category */
                UPDATE cpi_patient
                SET death_date    = var_check_death_date,
                    body_category = par_body_category
                WHERE patient_key = var_patient_key;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;

                IF var_rowcount != 1 OR var_error != 0 THEN
                    BEGIN
                        IF var_error = 0 THEN
                            SELECT - 4
                            INTO var_error;
                        END IF;
                        SELECT 'Fail to update the death date/time and body category of cpi_patient'
                        INTO par_error_message;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
    END;

    IF var_error != 0 THEN
        BEGIN
            --ROLLBACK;
            raise exception '';
            pas_return_code := - 1;
            RETURN;
        END;
    ELSE
        BEGIN
            /*
            [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
            commit
            */
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_update_death_dtm" OWNER TO "HPI_SCHEMA_OWNER_ROLE";