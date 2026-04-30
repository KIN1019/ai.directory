-- DROP PROCEDURE hpi.hasp_upd_cubicle(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in timestamp, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_upd_cubicle(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_cubicle_no character varying, IN par_effective_date timestamp without time zone, IN par_active_status character varying, IN par_description character varying, IN par_isolation_facilities character varying, IN par_project_category character varying, IN par_care_category character varying, IN par_sex character varying, IN par_treatment_location character varying, IN par_update_by character varying, IN par_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_patient_category character varying, IN par_cubicle_service character varying, IN par_official_bed integer, IN par_day_bed integer, IN par_old_ward character varying DEFAULT NULL::character varying, IN par_old_cubicle character varying DEFAULT NULL::character varying, IN par_old_effective timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_error_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_org_status VARCHAR(1);
    var_next_date TIMESTAMP WITHOUT TIME ZONE;
    var_upd_date TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<program_end>>
    BEGIN
        SELECT
            0, timestamp_convert(localtimestamp)
            INTO par_return_code, var_upd_date;

        IF par_old_ward IS NOT NULL AND par_old_cubicle IS NOT NULL AND par_old_effective IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM cubicle
                    WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND cubicle_no = par_old_cubicle AND effective_date = par_old_effective) THEN
                    BEGIN
                        SELECT
                            active_status
                            INTO var_org_status
                            FROM cubicle
                            WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND cubicle_no = par_old_cubicle AND effective_date = par_old_effective;

                        BEGIN
                            DELETE FROM cubicle
                                WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND cubicle_no = par_old_cubicle AND effective_date = par_old_effective;
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

        IF par_ward_code IS NOT NULL AND par_cubicle_no IS NOT NULL AND par_effective_date IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM cubicle
                    WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date = par_effective_date) THEN
                    BEGIN
                        BEGIN
                            UPDATE cubicle
                            SET active_status = par_active_status, description = par_description, isolation_facilities = par_isolation_facilities, project_category = par_project_category, care_category = par_care_category, sex = par_sex, treatment_location = par_treatment_location, update_datetime = var_upd_date, update_by = par_update_by, source_system = par_source_system, patient_category = par_patient_category, cubicle_service = par_cubicle_service, official_bed = par_official_bed, day_bed = par_day_bed
                                WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date = par_effective_date;
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
                            INSERT INTO cubicle (hospital_code, ward_code, cubicle_no, effective_date, active_status, description, isolation_facilities, project_category, care_category, sex, treatment_location, update_datetime, update_by, source_system, patient_category, cubicle_service, official_bed, day_bed)
                            VALUES (par_hospital_code, par_ward_code, par_cubicle_no, par_effective_date, par_active_status, par_description, par_isolation_facilities, par_project_category, par_care_category, par_sex, par_treatment_location, var_upd_date, par_update_by, par_source_system, par_patient_category, par_cubicle_service, par_official_bed, par_day_bed);
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
                /* if added or updated active cubicle, add cubicle to future date */
                IF var_org_status <> 'A' AND par_active_status = 'A' THEN
                    BEGIN
                        IF EXISTS (SELECT
                            *
                            FROM bed_allocation
                            WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND effective_date > par_effective_date) AND NOT EXISTS (SELECT
                            *
                            FROM cubicle
                            WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND effective_date = (SELECT
                                MIN(effective_date)
                                FROM bed_allocation
                                WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND effective_date > par_effective_date)) THEN
                            BEGIN
                                BEGIN
                                    INSERT INTO cubicle (hospital_code, ward_code, cubicle_no, effective_date, active_status, description, isolation_facilities, project_category, care_category, sex, treatment_location, update_datetime, update_by, source_system, patient_category, cubicle_service, official_bed, day_bed)
                                    SELECT DISTINCT
                                        par_hospital_code, par_ward_code, par_cubicle_no, effective_date, par_active_status, par_description, par_isolation_facilities, par_project_category, par_care_category, par_sex, par_treatment_location, var_upd_date, par_update_by, par_source_system, par_patient_category, par_cubicle_service, 0, 0
                                        FROM bed_allocation AS b
                                        WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND effective_date > par_effective_date AND NOT EXISTS (SELECT
                                            *
                                            FROM cubicle
                                            WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = par_cubicle_no AND effective_date = b.effective_date);
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF (sql$rowcount < 1) THEN
                                        BEGIN
                                            SELECT
                                                - 1
                                                INTO par_return_code;
                                            SELECT
                                                'Insert future cubicle failed.'
                                                INTO par_error_message;
                                            EXIT program_end;
                                        END;
                                    END IF;
                                END;
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


;ALTER PROCEDURE "hasp_upd_cubicle" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
