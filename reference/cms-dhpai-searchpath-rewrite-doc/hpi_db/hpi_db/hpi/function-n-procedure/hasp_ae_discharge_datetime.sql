-- DROP PROCEDURE hpi.hasp_ae_discharge_datetime(inout int4, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_ae_discharge_datetime(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_discharge_datetime timestamp without time zone, IN par_user_id character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
Return values   Meaning
0				Normal
1				Invalid Hospital code
2				ADT_Case not found
3				ADT_Case already discharged
4				Discharge datetime < last movement datetime
5				Row changed(ADT_Case missed) between retreive and upadate
12				Discharge datetime > system_datetime
13				(within 2 mins)Discharge datetime > system_datetime
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_transaction_type VARCHAR(12);
    var_retcode INTEGER;
    var_discharge_code VARCHAR(4);
    var_adm_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_message VARCHAR(400);
    var_last_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_time_diff INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin transaction
        */
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support SAVE TRAN cis command. Perform a manual conversion.]
        save transaction cis
        */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_system_datetime;
        SELECT
            0
            INTO var_error;

        IF NOT EXISTS (SELECT
            *
            FROM Hospital
            WHERE Hospital_code = par_hospital_code) THEN
            BEGIN
                SELECT
                    CONCAT('Invalid Hospital code ', par_hospital_code)
                    INTO var_message;
                SELECT
                    1
                    INTO var_error;
                EXIT abnormal_end;
            END;
        END IF;
        /* ---Modified by WL on 21 July 1999 for HPI ---- */
        SELECT
            Discharge_code, ADT_Case.row_update_datetime, Movement_datetime
            INTO var_discharge_code, var_timestamp, var_last_movement_datetime
            FROM ADT_Case, Movement
            WHERE ADT_Case.Case_no = par_case_no AND ADT_Case.Hospital_code = par_hospital_code AND Movement.Case_no = par_case_no AND Movement.Hospital_code = par_hospital_code AND ADT_Case.Movement_count = Movement.Movement_count;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount = 0 THEN
            BEGIN
                SELECT
                    CONCAT('Case not found ', par_case_no)
                    INTO var_message;
                SELECT
                    2
                    INTO var_error;
                EXIT abnormal_end;
            END;
        END IF;
        IF var_discharge_code is not NULL THEN
            BEGIN
                SELECT
                    CONCAT('Case already discharged ', par_case_no)
                    INTO var_message;
                SELECT
                    3
                    INTO var_error;
                EXIT abnormal_end;
            END;
        END IF;

        IF par_discharge_datetime > var_system_datetime THEN
            BEGIN
                SELECT
                    (FLOOR(DATE_PART('epoch', par_discharge_datetime::TIMESTAMP) - DATE_PART('epoch', var_system_datetime::TIMESTAMP)) / 60)::NUMERIC(20, 0)
                    INTO var_time_diff;
                IF var_time_diff > 2 THEN
                    BEGIN
                        SELECT
                            CONCAT('Discharge datetime > system datetime', par_case_no)
                            INTO var_message;
                        SELECT
                            12
                            INTO var_error;
                        EXIT abnormal_end;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            CONCAT('Discharge dtm > system dtm(within 2 mins)', par_case_no)
                            INTO var_message;
                        SELECT
                            13
                            INTO var_error;
                        EXIT abnormal_end;
                    END;
                END IF;
            END;
        END IF;

        IF par_discharge_datetime < var_last_movement_datetime THEN
            BEGIN
                SELECT
                    CONCAT('Discharge datetime < last movement datetime ', par_case_no, ' ', to_char(par_discharge_datetime::TIMESTAMP WITHOUT TIME ZONE, 'Mon DD YYYY HH:MI:SS.MSpm'))
                    INTO var_message;
                SELECT
                    4
                    INTO var_error;
                EXIT abnormal_end;
            END;
        END IF;
        /* ----- Modified by WL on 21 July 1999 for HPI --- */
        
        /*
        update ADT_Case
                set Discharge_datetime = @discharge_datetime,
                    User_ID = @user_id,
                    System_datetime = @system_datetime
                where Case_no = @case_no and
        				  Hospital_code = @hospital_code and
                      timestamp = @timestamp
        */
        UPDATE cpi_case
        SET discharge_dtm = par_discharge_datetime, update_by = par_user_id, update_dtm = var_system_datetime
            WHERE case_no = par_case_no AND hospital_code = par_hospital_code AND row_update_datetime = var_timestamp;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_rowcount = 0 THEN
            BEGIN
                SELECT
                    CONCAT('Row change between retreive and upadate ', par_case_no)
                    INTO var_message;
                SELECT
                    5
                    INTO var_error;
                EXIT abnormal_end;
            END;
        END IF;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support COMMIT TRAN command. Perform a manual conversion.]
        commit transaction
        */
        pas_return_code := 0;
        RETURN;
    END;
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support ROLLBACK TRAN cis command. Perform a manual conversion.]
    rollback transaction cis
    */
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support COMMIT TRAN command. Perform a manual conversion.]
    commit tran
    */
    SELECT
        CONCAT('hasp_ae_discharge_datetime ', var_message)
        INTO var_message;
    /* ---- Modified by WL on 21 July 1999 for HPI --- */
    INSERT INTO Error_log
    VALUES (par_hospital_code, var_system_datetime, var_message, NULL, NULL, NULL);
    pas_return_code := var_error;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_ae_discharge_datetime" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
