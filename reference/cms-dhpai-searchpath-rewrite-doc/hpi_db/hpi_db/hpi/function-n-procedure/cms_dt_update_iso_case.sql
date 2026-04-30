-- DROP FUNCTION hpi.cms_dt_update_iso_case(varchar, varchar, varchar, varchar, varchar, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.cms_dt_update_iso_case(par_hospital_code character varying, par_case_no character varying, par_iso_status character varying, par_last_update_datetime character varying, par_last_update_by character varying, par_update_datetime timestamp without time zone, par_update_by character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_movement_count INTEGER;
    var_last_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_iso_service VARCHAR(2);
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    sql$rowcount BIGINT;
    p_refcur refcursor;
BEGIN
    <<error>>
    BEGIN
        SELECT
            299999
            INTO var_error_code;
        /* check hospital code */
        IF par_hospital_code IS NULL OR (RTRIM(par_hospital_code) = '') THEN
            BEGIN
                SELECT
                    'Hospital code cannot be blank.'
                    INTO var_error_msg;
                /* --raiserror @error_code, @error_msg */
                EXIT error;
            END;
        END IF;
        /* check case number */
        IF par_case_no IS NULL OR (RTRIM(par_case_no) = '') THEN
            BEGIN
                SELECT
                    'Case number cannot be blank.'
                    INTO var_error_msg;
                /* --raiserror @error_code, @error_msg */
                EXIT error;
            END;
        END IF;
        /* check update_by */
        IF par_update_by IS NULL OR (RTRIM(par_update_by) = '') THEN
            BEGIN
                SELECT
                    'User ID cannot be blank.'
                    INTO var_error_msg;
                /* --raiserror @error_code, @error_msg */
                EXIT error;
            END;
        END IF;
        /* validate iso_status value */
        BEGIN
            SELECT
                iso_code
                INTO var_iso_service
                FROM isolation_case_code_table
                WHERE iso_code = par_iso_status;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    'Isolation service has not been defined.'
                    INTO var_error_msg;
                EXIT error;
            END;
        END IF;
        /* get last movement count */
        /* case not found by case number */
        BEGIN
            SELECT
                movement_count
                INTO var_movement_count
                FROM cpi_case
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    'Case not found'
                    INTO var_error_msg;
                /* --raiserror @error_code, @error_msg */
                EXIT error;
            END;
        END IF;
        /* check whether the target record is matched and is the latest */
        /* case not found by case number */
        BEGIN
            SELECT
                update_datetime
                INTO var_last_update_dtm
                FROM isolation_case
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND movement_count = var_movement_count;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    CONCAT('Isolation status not found for case: ', par_case_no)
                    INTO var_error_msg;
                /* --raiserror @error_code, @error_msg */
                EXIT error;
            END;
        END IF;
        /* date/time validation */
        IF par_update_datetime < var_last_update_dtm THEN
            BEGIN
                SELECT
                    'INVALID_DATETIME:Update date/time is before the last update date/time of the record.'
                    INTO var_error_msg;
                /* --raiserror @error_code, @error_msg */
                EXIT error;
            END;
        END IF;

        IF par_update_datetime > localtimestamp THEN
            BEGIN
                SELECT
                    'INVALID_DATETIME:Future time is not allowed.'
                    INTO var_error_msg;
                /* --raiserror @error_code, @error_msg */
                EXIT error;
            END;
        END IF;
        /* update the isolation status, date/time and user */
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        begin transaction
        */
        BEGIN
            UPDATE isolation_case
            SET iso_status = par_iso_status, update_datetime = par_update_datetime, update_by = par_update_by
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND movement_count = var_movement_count;
            /* select @error = @@error, @rowcount = @@rowcount */
        
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            EXCEPTION
                WHEN others THEN
                    BEGIN
                        SELECT
                            'Update patient isolation service failure.'
                            INTO var_error_msg;
                        EXIT error;
                    END;
        END;
        OPEN p_refcur FOR
        SELECT
            'Y' AS update_status, 'SUCCESS' AS message;
        RETURN NEXT p_refcur;
        RETURN;
    END;
    OPEN p_refcur FOR
    SELECT
        'N' AS update_status, var_error_msg AS message;
    RETURN NEXT p_refcur;
END;
$function$
;

;ALTER FUNCTION "cms_dt_update_iso_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
