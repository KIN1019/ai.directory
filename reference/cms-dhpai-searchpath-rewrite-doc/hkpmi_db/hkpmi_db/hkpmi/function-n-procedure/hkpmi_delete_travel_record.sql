-- DROP PROCEDURE hkpmi.hkpmi_delete_travel_record(inout int4, in bpchar, in bpchar, in varchar, in bpchar, in bpchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_delete_travel_record(INOUT pas_return_code integer, IN par_system_id VARCHAR, IN par_patient_key VARCHAR, IN par_case_no character varying DEFAULT NULL::character varying,
 IN par_status VARCHAR DEFAULT NULL::VARCHAR, IN par_hospital_code VARCHAR DEFAULT NULL::VARCHAR, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_source_system VARCHAR(5);
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_log_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        IF NOT EXISTS (SELECT
            1
            FROM patient
            WHERE patient_key = par_patient_key) THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Patient record not found!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;
        SELECT
            par_system_id
            INTO var_source_system;

        IF var_source_system NOT IN ('ADT', 'OPAS', 'EAI', 'IPAS') THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Source system code is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_case_no IS NOT NULL THEN
            BEGIN
                SELECT
                    LTRIM(RTRIM(par_case_no))
                    INTO par_case_no;

                IF LENGTH(par_case_no) < 12 THEN
                    BEGIN
                        SELECT
                            CONCAT(' ', par_case_no)
                            INTO par_case_no;
                    END;
                END IF;
            END;
        END IF;

        IF par_case_no IS NOT NULL THEN
            IF NOT EXISTS (SELECT
                1
                FROM pmi_case
                WHERE case_no = par_case_no AND hospital_code = par_hospital_code) THEN
                BEGIN
                    SELECT
                        - 1
                        INTO var_error_code;
                    SELECT
                        'Case Number record not found!'
                        INTO var_error_msg;
                    EXIT return_error;
                END;
            END IF;
        END IF;

        IF par_status NOT IN ('D') THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Status is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;
        /* --	if @@trancount = 0 */
        BEGIN
            /*
            [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
            begin tran
            */
        END;

        IF EXISTS (SELECT
            1
            FROM hkpmi_patient_travel_record
            WHERE patient_key = par_patient_key) THEN
            BEGIN
                SELECT
                    update_datetime
                    INTO var_log_datetime
                    FROM hkpmi_patient_travel_record
                    WHERE patient_key = par_patient_key;
                /* --To avoid insert duplicate key error */
                IF EXISTS (SELECT
                    1
                    FROM hkpmi_patient_travel_record AS p, hkpmi_patient_travel_log AS l
                    WHERE l.patient_key = par_patient_key AND l.patient_key = p.patient_key AND l.update_datetime = p.update_datetime) THEN
                    BEGIN
                        SELECT
                            + 5 * INTERVAL '1 millisecond' + var_log_datetime::TIMESTAMP
                            INTO var_log_datetime;
                    END;
                END IF;

                BEGIN
                    INSERT INTO hkpmi_patient_travel_log (source_system, patient_key, travel_indicator, reply_datetime, control_point, travel_type, entry_datetime, update_datetime, status, hospital_code, case_no)
                    SELECT
                        source_system, patient_key, travel_indicator, reply_datetime, control_point, travel_type, entry_datetime, update_datetime, status, hospital_code, case_no
                        FROM hkpmi_patient_travel_record
                        WHERE patient_key = par_patient_key;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                    BEGIN
                        SELECT
                            'Fail to update hkpmi_patient_travel_record_log!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;

                BEGIN
                    UPDATE hkpmi_patient_travel_record
                    SET status = par_status, hospital_code = par_hospital_code, case_no = par_case_no, source_system = var_source_system, update_datetime = localtimestamp
                        WHERE patient_key = par_patient_key;
                    var_error_code := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error_code := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error_code <> 0 OR var_rowcount <> 1 THEN
                    BEGIN
                        SELECT
                            'Fail to delete hkpmi_patient_travel_record!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Patient travel history not found!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;
        SELECT
            NULL
            INTO par_return_message;
        SELECT
            0
            INTO par_return_code;
        /* --	if @@trancount > 0 */
        BEGIN
            /*
            [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
            commit
            */
        END;
        pas_return_code := 0;
        RETURN;
    END;
    SELECT
        var_error_msg
        INTO par_return_message;
    SELECT
        - 1
        INTO par_return_code;
    /* --	if @@trancount > 0 */
    BEGIN
        ROLLBACK;
    END;
    /* --	select @error_code = 500036 */
    /* --	raiserror @error_code, @error_msg */
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_delete_travel_record" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
