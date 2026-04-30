-- DROP PROCEDURE hpi.hasp_can_ae_discharge_by_cis(inout int4, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_can_ae_discharge_by_cis(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_user_id character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
Return values   Meaning
0				Normal
1				Invalid Hospital code
2				ADT_Case not found
3				ADT_Case has not been discharged
4				ADT_Case not discharged by AECIS (user not match)
5				Cannot cancel prev AE discharge (SP error)
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_retcode INTEGER;
    var_message VARCHAR(200);
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_upd_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_discharge_code VARCHAR(01);
    var_last_user_id VARCHAR(08);
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
                raise exception '';
            END;
        END IF;
        /* --------- Modified by WL on 21 July for HPI ---------- */
        SELECT
            a.Discharge_code, a.User_ID, a.System_datetime
            INTO var_last_discharge_code, var_last_user_id, var_last_upd_datetime
            FROM ADT_Case AS a
            WHERE a.Case_no = par_case_no AND a.Hospital_code = par_hospital_code;
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
                raise exception '';
            END;
        END IF;

        IF var_last_discharge_code = NULL THEN
            BEGIN
                SELECT
                    CONCAT('Case has not been discharged ', par_case_no)
                    INTO var_message;
                SELECT
                    3
                    INTO var_error;
                raise exception '';
            END;
        END IF;

        IF var_last_user_id != par_user_id THEN
            BEGIN
                SELECT
                    CONCAT('Case not discharged by AECIS ', par_case_no, ' ', var_last_user_id)
                    INTO var_message;
                SELECT
                    4
                    INTO var_error;
                raise exception '';
            END;
        END IF;
        /* add hospital code for HPI by ML on 22.09.1999 */
        CALL hasp_cis_can_discharge(var_retcode, par_hospital_code, par_case_no, 'AE01', par_user_id, var_last_upd_datetime, 'AE');

        IF var_retcode != 0 THEN
            BEGIN
                SELECT
                    CONCAT('Cannot cancel prev AE discharge ', par_case_no)
                    INTO var_message;
                SELECT
                    5
                    INTO var_error;
                raise exception '';
            END;
        END IF;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support COMMIT TRAN command. Perform a manual conversion.]
        commit transaction
        */
        pas_return_code := 0;
        RETURN;
    END;
    EXCEPTION
        when others THEN
            BEGIN
            END;
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support ROLLBACK TRAN cis command. Perform a manual conversion.]
    rollback transaction cis
    */
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support COMMIT TRAN command. Perform a manual conversion.]
    commit transaction
    */
    SELECT
        CONCAT('hasp_can_ae_discharge_by_cis ', var_message)
        INTO var_message;
    /* --------- Modified by WL on 21 July 1999 for HPI ----- */
    INSERT INTO Error_log
    VALUES (par_hospital_code, var_system_datetime, var_message, NULL, NULL, NULL);
    pas_return_code := var_error;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_can_ae_discharge_by_cis" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
