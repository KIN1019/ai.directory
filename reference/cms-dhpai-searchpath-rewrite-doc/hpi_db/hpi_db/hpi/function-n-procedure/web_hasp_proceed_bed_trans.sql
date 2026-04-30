-- DROP PROCEDURE hpi.web_hasp_proceed_bed_trans(inout int4, in varchar, in int4, in timestamp, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_proceed_bed_trans(INOUT pas_return_code integer, IN par_host character varying, IN par_seq integer, IN par_exec_datetime timestamp without time zone, IN par_status character varying, INOUT par_return_code integer, INOUT par_error_message character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_a_hospital_code VARCHAR(3);
    var_a_ward_code VARCHAR(4);
    var_a_specialty_code VARCHAR(4);
    var_a_original_specialty VARCHAR(4);
    var_a_effective_date TIMESTAMP WITHOUT TIME ZONE;
    var_a_official_bed INTEGER;
    var_a_day_bed INTEGER;
    var_a_isolation_bed INTEGER;
    var_a_isolation_day INTEGER;
    var_a_update_by VARCHAR(12);
    var_a_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_a_old_ward VARCHAR(4);
    var_a_old_specialty VARCHAR(4);
    var_a_old_original VARCHAR(4);
    var_a_old_effective TIMESTAMP WITHOUT TIME ZONE;
    bed_allocation_cursor CURSOR FOR
    SELECT
        hospital_code, ward_code, specialty_code, original_specialty, effective_date, official_bed, day_bed, isolation_bed, isolation_day, update_by, update_dtm, old_ward, old_specialty, old_original, old_effective
        FROM bed_allocation_trans
        WHERE seq = par_seq AND exec_datetime = par_exec_datetime AND host = par_host;
    var_return_code int;
    var_c_hospital_code VARCHAR(3);
    var_c_ward_code VARCHAR(4);
    var_c_cubicle_no VARCHAR(4);
    var_c_effective_date TIMESTAMP WITHOUT TIME ZONE;
    var_c_active_status VARCHAR(1);
    var_c_description VARCHAR(48);
    var_c_isolation_facilities VARCHAR(3);
    var_c_project_category VARCHAR(2);
    var_c_care_category VARCHAR(1);
    var_c_sex VARCHAR(1);
    var_c_treatment_location VARCHAR(4);
    var_c_update_by VARCHAR(12);
    var_c_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_c_source_system VARCHAR(5);
    var_c_patient_category VARCHAR(5);
    var_c_cubicle_service VARCHAR(3);
    var_c_official_bed INTEGER;
    var_c_day_bed INTEGER;
    var_c_old_ward VARCHAR(4);
    var_c_old_cubicle VARCHAR(4);
    var_c_old_effective TIMESTAMP WITHOUT TIME ZONE;
    cubicle_cursor CURSOR FOR
    SELECT
        hospital_code, ward_code, cubicle_no, effective_date, active_status, description, isolation_facilities, project_category, care_category, sex, treatment_location, update_by, update_datetime, source_system, patient_category, cubicle_service, official_bed, day_bed, old_ward, old_cubicle, old_effective
        FROM cubicle_trans
        WHERE seq = par_seq AND exec_datetime = par_exec_datetime AND host = par_host;
    var_h_hospital_code VARCHAR(3);
    var_h_ward_code VARCHAR(4);
    var_h_cubicle_no VARCHAR(4);
    var_h_bed_no VARCHAR(5);
    var_h_effective_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_h_active_status VARCHAR(1);
    var_h_bed_type VARCHAR(1);
    var_h_bed_category VARCHAR(5);
    var_h_specialty_code VARCHAR(4);
    var_h_in_service_specialty VARCHAR(4);
    var_h_row_no INTEGER;
    var_h_col_no INTEGER;
    var_h_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_h_update_by VARCHAR(12);
    var_h_source_system VARCHAR(5);
    var_h_ciwl_indicator VARCHAR(1);
    var_h_isolation_bed VARCHAR(1);
    var_h_old_ward VARCHAR(4);
    var_h_old_cubicle VARCHAR(4);
    var_h_old_bed VARCHAR(5);
    var_h_old_effective TIMESTAMP WITHOUT TIME ZONE;
    var_h_bed_ready VARCHAR(1);
    var_h_physical_bed_no VARCHAR(5);
    bed_history_cursor CURSOR FOR
    SELECT
        hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, active_status, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, old_ward, old_cubicle, old_bed, old_effective, bed_ready, physical_bed_no
        FROM bed_history_trans
        WHERE seq = par_seq AND exec_datetime = par_exec_datetime AND host = par_host;
    
BEGIN
    <<program_end>>
    BEGIN
        /* --Clear old data */
        DELETE FROM bed_allocation_trans
            WHERE exec_datetime < - 3 * INTERVAL '1 day' + timestamp_convert(localtimestamp)::TIMESTAMP;
        DELETE FROM cubicle_trans
            WHERE exec_datetime < - 3 * INTERVAL '1 day' + timestamp_convert(localtimestamp)::TIMESTAMP;
        DELETE FROM bed_history_trans
            WHERE exec_datetime < - 3 * INTERVAL '1 day' + timestamp_convert(localtimestamp)::TIMESTAMP;
        /* --Set default return code */
        SELECT
            0
            INTO par_return_code;
        /* --Delete transaction record if status is error */
        IF par_status = 'E' THEN
            BEGIN
                DELETE FROM bed_allocation_trans
                    WHERE seq = par_seq AND exec_datetime = par_exec_datetime AND host = par_host;
                DELETE FROM cubicle_trans
                    WHERE seq = par_seq AND exec_datetime = par_exec_datetime AND host = par_host;
                DELETE FROM bed_history_trans
                    WHERE seq = par_seq AND exec_datetime = par_exec_datetime AND host = par_host;
                /* --Skip to proceed */
                EXIT program_end;
            END;
        END IF;
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
        BEGIN TRANSACTION
        */
        /* --Proceed bed allocation transaction */
        OPEN bed_allocation_cursor;
        FETCH NEXT FROM bed_allocation_cursor INTO var_a_hospital_code, var_a_ward_code, var_a_specialty_code, var_a_original_specialty, var_a_effective_date, var_a_official_bed, var_a_day_bed, var_a_isolation_bed, var_a_isolation_day, var_a_update_by, var_a_update_dtm, var_a_old_ward, var_a_old_specialty, var_a_old_original, var_a_old_effective;

        WHILE ((CASE FOUND::INT
            WHEN 0 THEN - 1
            ELSE 0
        END) <> - 1) LOOP
            IF ((CASE FOUND::INT
                WHEN 0 THEN - 1
                ELSE 0
            END) <> - 2) THEN
                BEGIN
                    CALL hasp_upd_bed_allocation(par_return_code, var_a_hospital_code, var_a_ward_code, var_a_specialty_code, var_a_original_specialty, var_a_effective_date, var_a_official_bed, var_a_day_bed, var_a_isolation_bed, var_a_isolation_day, var_a_update_by, var_a_update_dtm, var_a_old_ward, var_a_old_specialty, var_a_old_original, var_a_old_effective, par_return_code, par_error_message);

                    IF par_return_code <> 0 THEN
                        EXIT program_end;
                    END IF;
                END;
            END IF;
            FETCH NEXT FROM bed_allocation_cursor INTO var_a_hospital_code, var_a_ward_code, var_a_specialty_code, var_a_original_specialty, var_a_effective_date, var_a_official_bed, var_a_day_bed, var_a_isolation_bed, var_a_isolation_day, var_a_update_by, var_a_update_dtm, var_a_old_ward, var_a_old_specialty, var_a_old_original, var_a_old_effective;
        END LOOP;
        CLOSE bed_allocation_cursor;
        /* --Proceed cubicle transaction */
        OPEN cubicle_cursor;
        FETCH NEXT FROM cubicle_cursor INTO var_c_hospital_code, var_c_ward_code, var_c_cubicle_no, var_c_effective_date, var_c_active_status, var_c_description, var_c_isolation_facilities, var_c_project_category, var_c_care_category, var_c_sex, var_c_treatment_location, var_c_update_by, var_c_update_datetime, var_c_source_system, var_c_patient_category, var_c_cubicle_service, var_c_official_bed, var_c_day_bed, var_c_old_ward, var_c_old_cubicle, var_c_old_effective;

        WHILE ((CASE FOUND::INT
            WHEN 0 THEN - 1
            ELSE 0
        END) <> - 1) LOOP
            IF ((CASE FOUND::INT
                WHEN 0 THEN - 1
                ELSE 0
            END) <> - 2) THEN
                BEGIN
                    CALL hasp_upd_cubicle(par_return_code, var_c_hospital_code, var_c_ward_code, var_c_cubicle_no, var_c_effective_date, var_c_active_status, var_c_description, var_c_isolation_facilities, var_c_project_category, var_c_care_category, var_c_sex, var_c_treatment_location, var_c_update_by, var_c_update_datetime, var_c_source_system, var_c_patient_category, var_c_cubicle_service, var_c_official_bed, var_c_day_bed, var_c_old_ward, var_c_old_cubicle, var_c_old_effective, par_return_code, par_error_message);

                    IF par_return_code <> 0 THEN
                        EXIT program_end;
                    END IF;
                END;
            END IF;
            FETCH NEXT FROM cubicle_cursor INTO var_c_hospital_code, var_c_ward_code, var_c_cubicle_no, var_c_effective_date, var_c_active_status, var_c_description, var_c_isolation_facilities, var_c_project_category, var_c_care_category, var_c_sex, var_c_treatment_location, var_c_update_by, var_c_update_datetime, var_c_source_system, var_c_patient_category, var_c_cubicle_service, var_c_official_bed, var_c_day_bed, var_c_old_ward, var_c_old_cubicle, var_c_old_effective;
        END LOOP;
        CLOSE cubicle_cursor;
        /* --Proceed bed history transaction */
        OPEN bed_history_cursor;
        FETCH NEXT FROM bed_history_cursor INTO var_h_hospital_code, var_h_ward_code, var_h_cubicle_no, var_h_bed_no, var_h_effective_datetime, var_h_active_status, var_h_bed_type, var_h_bed_category, var_h_specialty_code, var_h_in_service_specialty, var_h_row_no, var_h_col_no, var_h_update_datetime, var_h_update_by, var_h_source_system, var_h_ciwl_indicator, var_h_isolation_bed, var_h_old_ward, var_h_old_cubicle, var_h_old_bed, var_h_old_effective, var_h_bed_ready, var_h_physical_bed_no;

        WHILE ((CASE FOUND::INT
            WHEN 0 THEN - 1
            ELSE 0
        END) <> - 1) LOOP
            IF ((CASE FOUND::INT
                WHEN 0 THEN - 1
                ELSE 0
            END) <> - 2) THEN
                BEGIN
                    CALL hasp_upd_bed_history(par_return_code, var_h_hospital_code, var_h_ward_code, var_h_cubicle_no, var_h_bed_no, var_h_effective_datetime, var_h_active_status, var_h_bed_type, var_h_bed_category, var_h_specialty_code, var_h_in_service_specialty, var_h_row_no, var_h_col_no, var_h_update_datetime, var_h_update_by, var_h_source_system, var_h_ciwl_indicator, var_h_isolation_bed, var_h_old_ward, var_h_old_cubicle, var_h_old_bed, var_h_old_effective, par_return_code, par_error_message, var_h_bed_ready, var_h_physical_bed_no);

                    IF par_return_code <> 0 THEN
                        EXIT program_end;
                    END IF;
                END;
            END IF;
            FETCH NEXT FROM bed_history_cursor INTO var_h_hospital_code, var_h_ward_code, var_h_cubicle_no, var_h_bed_no, var_h_effective_datetime, var_h_active_status, var_h_bed_type, var_h_bed_category, var_h_specialty_code, var_h_in_service_specialty, var_h_row_no, var_h_col_no, var_h_update_datetime, var_h_update_by, var_h_source_system, var_h_ciwl_indicator, var_h_isolation_bed, var_h_old_ward, var_h_old_cubicle, var_h_old_bed, var_h_old_effective, var_h_bed_ready, var_h_physical_bed_no;
        END LOOP;
        CLOSE bed_history_cursor;
    END;

    IF par_return_code = 0 THEN
        BEGIN
            /*
            [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
            COMMIT TRANSACTION
            */
            SELECT
                NULL
                INTO par_error_message;
        END;
    END IF;
    exception
        when others then 
            begin
                SELECT
                    'unknown exception'
                    INTO par_error_message;
                SELECT
                    -1
                    INTO par_return_code;
            end;
    DELETE FROM bed_allocation_trans
        WHERE seq = par_seq AND exec_datetime = par_exec_datetime;
    DELETE FROM cubicle_trans
        WHERE seq = par_seq AND exec_datetime = par_exec_datetime;
    DELETE FROM bed_history_trans
        WHERE seq = par_seq AND exec_datetime = par_exec_datetime;

    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_proceed_bed_trans" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
