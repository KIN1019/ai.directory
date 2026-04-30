-- DROP PROCEDURE hpi.hasp_upd_bed_history(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, inout int4, inout varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_upd_bed_history(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_cubicle_no character varying, IN par_bed_no character varying, IN par_effective_datetime timestamp without time zone, IN par_active_status character varying, IN par_bed_type character varying, IN par_bed_category character varying, IN par_specialty_code character varying, IN par_in_service_specialty character varying, IN par_row_no integer, IN par_col_no integer, IN par_update_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_ciwl_indicator character varying, IN par_isolation_bed character varying, IN par_old_ward character varying DEFAULT NULL::character varying, IN par_old_cubicle character varying DEFAULT NULL::character varying, IN par_old_bed character varying DEFAULT NULL::character varying, IN par_old_effective timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_error_message character varying DEFAULT NULL::character varying, IN par_bed_ready character varying DEFAULT NULL::character varying, IN par_physical_bed_no character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_org_status VARCHAR(1);
    var_next_date TIMESTAMP WITHOUT TIME ZONE;
    var_iso VARCHAR(2);
    var_proj VARCHAR(2);
    var_service VARCHAR(3);
    var_location VARCHAR(2);
    var_capacity VARCHAR(2);
    var_upd_date TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;

BEGIN
    <<program_end>>
    BEGIN
        SELECT
            0, timestamp_convert(localtimestamp)
            INTO par_return_code, var_upd_date;

        IF par_old_ward IS NOT NULL AND par_old_cubicle IS NOT NULL AND par_old_bed IS NOT NULL AND par_old_effective IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM bed_history
                    WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND cubicle_no = par_old_cubicle AND bed_no = par_old_bed AND effective_datetime = par_old_effective) THEN
                    BEGIN
                        SELECT
                            active_status
                            INTO var_org_status
                            FROM bed_history
                            WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND cubicle_no = par_old_cubicle AND bed_no = par_old_bed AND effective_datetime = par_old_effective;

                        BEGIN
                            DELETE FROM bed_history
                                WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND cubicle_no = par_old_cubicle AND bed_no = par_old_bed AND effective_datetime = par_old_effective;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount <> 1) THEN
                                BEGIN
                                    SELECT
                                        - 1
                                        INTO par_return_code;
                                    SELECT
                                        'Delete old value failed.'
                                        INTO par_error_message;
                                    EXIT program_end;
                                END;
                            END IF;
                        END;
                    END;
                ELSE
                    SELECT
                        NULL
                        INTO var_org_status;
                END IF;
            END;
        END IF;

        IF par_ward_code IS NOT NULL AND par_cubicle_no IS NOT NULL AND par_bed_no IS NOT NULL AND par_effective_datetime IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM bed_history
                    WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND bed_no = par_bed_no AND effective_datetime = par_effective_datetime) THEN
                    BEGIN
                        BEGIN
                            UPDATE bed_history
                            SET active_status = par_active_status, bed_type = par_bed_type, bed_category = par_bed_category, specialty_code = par_specialty_code, in_service_specialty = par_in_service_specialty, row_no = par_row_no, col_no = par_col_no, update_datetime = var_upd_date, update_by = par_update_by, source_system = par_source_system, ciwl_indicator = par_ciwl_indicator, isolation_bed = par_isolation_bed, bed_ready = par_bed_ready, physical_bed_no = par_physical_bed_no
                                WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND bed_no = par_bed_no AND effective_datetime = par_effective_datetime;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount <> 1) THEN
                                BEGIN
                                    SELECT
                                        - 1
                                        INTO par_return_code;
                                    SELECT
                                        'Update table failed.'
                                        INTO par_error_message;
                                    EXIT program_end;
                                END;
                            END IF;
                        END;
                    END;
                ELSE
                    BEGIN
                        BEGIN
                            INSERT INTO bed_history (hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, active_status, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, bed_ready, physical_bed_no)
                            VALUES (par_hospital_code, par_ward_code, par_cubicle_no, par_bed_no, par_effective_datetime, par_active_status, par_bed_type, par_bed_category, par_specialty_code, par_in_service_specialty, par_row_no, par_col_no, var_upd_date, par_update_by, par_source_system, par_ciwl_indicator, par_isolation_bed, par_bed_ready, par_physical_bed_no);
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount <> 1) THEN
                                BEGIN
                                    SELECT
                                        - 1
                                        INTO par_return_code;
                                    SELECT
                                        'Insert table failed.'
                                        INTO par_error_message;
                                    EXIT program_end;
                                END;
                            END IF;
                        END;
                    END;
                END IF;
                /* Update Bed and bed_category tables */
                SELECT
                    isolation_facilities, cubicle_service, project_category, patient_category, CAST (official_bed AS VARCHAR(2))
                    INTO var_iso, var_service, var_proj, var_location, var_capacity
                    FROM cubicle
                    WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date = (SELECT
                        MAX(effective_date)
                        FROM cubicle
                        WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date <= par_effective_datetime);
                CALL hasp_bed_maintenance(par_return_code, par_hospital_code, par_ward_code, par_bed_no, par_bed_type, '3', 'V', NULL, NULL, NULL, NULL, par_effective_datetime, par_update_by, 'U', var_service, var_location, var_iso, var_proj, par_cubicle_no, var_capacity, 'N', NULL);


                IF par_return_code <> 0 THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO par_return_code;
                        SELECT
                            'Update Bed/bed category failed.'
                            INTO par_error_message;
                        EXIT program_end;
                    END;
                END IF;
                /*
                if new active bed is added, add an inactive entry in next
                cubicle effective date
                */
                IF var_org_status <> 'A' AND par_active_status = 'A' THEN
                    BEGIN
                        SELECT
                            MIN(effective_date)
                            INTO var_next_date
                            FROM cubicle
                            WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date > par_effective_datetime;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount > 0 AND var_next_date IS NOT NULL THEN
                            BEGIN
                                IF NOT EXISTS (SELECT
                                    *
                                    FROM bed_history
                                    WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND bed_no = par_bed_no AND effective_datetime = var_next_date) THEN
                                    BEGIN
                                        BEGIN
                                            INSERT INTO bed_history (hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, active_status, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, bed_ready, physical_bed_no)
                                            VALUES (par_hospital_code, par_ward_code, par_cubicle_no, par_bed_no, var_next_date, 'D', par_bed_type, par_bed_category, par_specialty_code, par_in_service_specialty, par_row_no, par_col_no, var_upd_date, par_update_by, par_source_system, par_ciwl_indicator, par_isolation_bed, par_bed_ready, par_physical_bed_no);
                                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                            IF (sql$rowcount <> 1) THEN
                                                BEGIN
                                                    SELECT
                                                        - 1
                                                        INTO par_return_code;
                                                    SELECT
                                                        'Insert future bed failed.'
                                                        INTO par_error_message;
                                                    EXIT program_end;
                                                END;
                                            END IF;
                                        END;
                                    END;
                                END IF;
                                /* Update Bed and bed_category tables */
                                SELECT
                                    isolation_facilities, cubicle_service, project_category, patient_category, CAST (official_bed AS VARCHAR(2))
                                    INTO var_iso, var_service, var_proj, var_location, var_capacity
                                    FROM cubicle
                                    WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date = (SELECT
                                        MAX(effective_date)
                                        FROM cubicle
                                        WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date <= var_next_date);
                                CALL hasp_bed_maintenance(par_return_code, par_hospital_code, par_ward_code, par_bed_no, par_bed_type, '3', 'V', NULL, NULL, NULL, NULL, var_next_date, par_update_by, 'U', var_service, var_location, var_iso, var_proj, par_cubicle_no, var_capacity, 'N', NULL);

                                IF par_return_code <> 0 THEN
                                    BEGIN
                                        SELECT
                                            - 1
                                            INTO par_return_code;
                                        SELECT
                                            'Update Bed/bed category failed.'
                                            INTO par_error_message;
                                        EXIT program_end;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
    END;

    IF par_return_code = 0 THEN
        SELECT
            NULL
            INTO par_error_message;
    END IF;
    pas_return_code := par_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_upd_bed_history" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
