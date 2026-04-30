-- DROP PROCEDURE hkpmi.hkpmi_set_travel_record(inout int4, in bpchar, in bpchar, in varchar, in bpchar, in varchar, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_set_travel_record(INOUT pas_return_code integer, IN par_system_id varchar, IN par_reference_id varchar, IN par_reply_datetime character varying, IN "par_withTravelRecord" varchar, IN par_control_point character varying DEFAULT NULL::character varying, IN par_travel_type character varying DEFAULT NULL::character varying, IN par_entry_datetime character varying DEFAULT NULL::character varying, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* --Y/N */DECLARE
    var_patient_key VARCHAR(8);
    var_hkid VARCHAR(12);
    var_source_system VARCHAR(5);
    var_error_msg VARCHAR(255);
    var_error_code INTEGER;
    var_rowcount INTEGER;
    var_log_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_dt_entry_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_dt_reply_datetime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        SELECT
            SUBSTRING(par_reference_id, 1, 8)
            INTO var_patient_key;
        SELECT
            par_system_id
            INTO var_source_system;
        SELECT
            hkid
            INTO var_hkid
            FROM patient
            WHERE patient_key = var_patient_key;

        IF var_hkid IS NULL THEN
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

        IF var_source_system NOT IN ('ADT', 'OPAS', 'EAI', 'IPAS', 'RIS', 'THE') THEN
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
        /* select @travel_type = ltrim(rtrim((@travel_type))) */

        IF par_travel_type IS NOT NULL AND COALESCE(LTRIM(RTRIM((par_travel_type))), '') <> '' THEN
            BEGIN
                IF par_travel_type NOT IN ('A', 'D') THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Travel type is invalid!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* if @withTravelRecord = 'Y' or @withTravelRecord = 'N' */
        /* begin */

        IF par_reply_datetime IS NULL THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Reply date time is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;

        IF par_reply_datetime IS NOT NULL AND LENGTH(par_reply_datetime) >= 19 THEN
            BEGIN
                SELECT
                    CAST (par_reply_datetime AS TIMESTAMP WITHOUT TIME ZONE)
                    INTO var_dt_reply_datetime;
            END;
        ELSE
            BEGIN
                SELECT
                    - 1
                    INTO var_error_code;
                SELECT
                    'Reply date time is invalid!'
                    INTO var_error_msg;
                EXIT return_error;
            END;
        END IF;
        /* end */

        IF "par_withTravelRecord" = 'Y' AND par_entry_datetime IS NOT NULL AND par_entry_datetime != '' AND COALESCE(LTRIM(RTRIM((par_entry_datetime))), '') <> '' THEN
            BEGIN
                IF LENGTH(par_entry_datetime) = 10 THEN
                    BEGIN
                        SELECT
                            CAST (par_entry_datetime AS TIMESTAMP WITHOUT TIME ZONE)
                            INTO var_dt_entry_datetime;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            - 1
                            INTO var_error_code;
                        SELECT
                            'Entry date time is invalid!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        IF EXISTS (SELECT
            1
            FROM hkpmi_patient_travel_record
            WHERE patient_key = var_patient_key::VARCHAR) THEN
            BEGIN
                SELECT
                    update_datetime
                    INTO var_log_datetime
                    FROM hkpmi_patient_travel_record
                    WHERE patient_key = var_patient_key::VARCHAR;
                /* --To avoid insert duplicate key error */
                IF EXISTS (SELECT
                    1
                    FROM hkpmi_patient_travel_record AS p, hkpmi_patient_travel_log AS l
                    WHERE l.patient_key = var_patient_key::VARCHAR AND l.patient_key = p.patient_key AND l.update_datetime = p.update_datetime) THEN
                    BEGIN
                        SELECT
                            3 * INTERVAL '1 millisecond' + var_log_datetime::TIMESTAMP
                            INTO var_log_datetime;
                    END;
                END IF;

                BEGIN
                    INSERT INTO hkpmi_patient_travel_log
                    SELECT
                        source_system, patient_key, travel_indicator, reply_datetime, control_point, travel_type, entry_datetime,
                        /* --update_datetime */
                        var_log_datetime
                        FROM hkpmi_patient_travel_record
                        WHERE patient_key = var_patient_key::VARCHAR;
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
                    SET source_system = var_source_system, patient_key = var_patient_key, travel_indicator = "par_withTravelRecord", reply_datetime = var_dt_reply_datetime, control_point = par_control_point, travel_type = par_travel_type, entry_datetime = var_dt_entry_datetime, update_datetime = localtimestamp
                        WHERE patient_key = var_patient_key::VARCHAR;
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
                            'Fail to update hkpmi_patient_travel_record!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                BEGIN
                    INSERT INTO hkpmi_patient_travel_record (source_system, patient_key, travel_indicator, reply_datetime, control_point, travel_type, entry_datetime, update_datetime)
                    VALUES (var_source_system, var_patient_key, "par_withTravelRecord", var_dt_reply_datetime, par_control_point, par_travel_type, var_dt_entry_datetime, localtimestamp);
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
                            'Fail to insert hkpmi_patient_travel_record!'
                            INTO var_error_msg;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            NULL
            INTO par_return_message;
        SELECT
            0
            INTO par_return_code;

        pas_return_code := 0;
        RETURN;
    END;
    SELECT
        var_error_msg
        INTO par_return_message;
    SELECT
        - 1
        INTO par_return_code;
    rollback;
    /* --	select @error_code = 500036 */
    /* --	raiserror @error_code, @error_msg */
    pas_return_code := - 1;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_set_travel_record" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
