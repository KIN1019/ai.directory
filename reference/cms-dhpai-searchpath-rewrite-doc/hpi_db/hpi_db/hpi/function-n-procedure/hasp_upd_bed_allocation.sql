-- DROP PROCEDURE hpi.hasp_upd_bed_allocation(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in int4, in int4, in int4, in int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_upd_bed_allocation(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_original_specialty character varying, IN par_effective_date timestamp without time zone, IN par_official_bed integer, IN par_day_bed integer, IN par_isolation_bed integer, IN par_isolation_day integer, IN par_update_by character varying, IN par_update_dtm timestamp without time zone, IN par_old_ward character varying DEFAULT NULL::character varying, IN par_old_specialty character varying DEFAULT NULL::character varying, IN par_old_original character varying DEFAULT NULL::character varying, IN par_old_effective timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_return_code integer DEFAULT NULL::integer, INOUT par_error_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_off INTEGER;
    var_day INTEGER;
    var_upd_date TIMESTAMP WITHOUT TIME ZONE;
    var_ward VARCHAR(4);
    var_spec VARCHAR(4);
    var_date TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<program_end>>
    BEGIN
        SELECT
            0, timestamp_convert(localtimestamp)
            INTO par_return_code, var_upd_date;

        IF par_old_ward IS NOT NULL AND par_old_specialty IS NOT NULL AND par_old_original IS NOT NULL AND par_old_effective IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM bed_allocation
                    WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND specialty_code = par_old_specialty AND original_specialty = par_old_original AND effective_date = par_old_effective) THEN
                    BEGIN
                        BEGIN
                            DELETE FROM bed_allocation
                                WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND specialty_code = par_old_specialty AND original_specialty = par_old_original AND effective_date = par_old_effective;
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
                END IF;
            END;
        END IF;

        IF par_ward_code IS NOT NULL AND par_specialty_code IS NOT NULL AND par_original_specialty IS NOT NULL AND par_effective_date IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM bed_allocation
                    WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND specialty_code = par_specialty_code AND original_specialty = par_original_specialty AND effective_date = par_effective_date) THEN
                    BEGIN
                        BEGIN
                            UPDATE bed_allocation
                            SET official_bed = par_official_bed, day_bed = par_day_bed, isolation_bed = par_isolation_bed, isolation_day = par_isolation_day, update_by = par_update_by, update_dtm = var_upd_date
                                WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND specialty_code = par_specialty_code AND original_specialty = par_original_specialty AND effective_date = par_effective_date;
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
                            INSERT INTO bed_allocation (hospital_code, ward_code, specialty_code, original_specialty, effective_date, official_bed, day_bed, isolation_bed, isolation_day, update_by, update_dtm)
                            VALUES (par_hospital_code, par_ward_code, par_specialty_code, par_original_specialty, par_effective_date, par_official_bed, par_day_bed, par_isolation_bed, par_isolation_day, par_update_by, var_upd_date);
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
            END;
        END IF;
        /* update for Ward_specialty */
        IF par_old_ward IS NOT NULL AND par_old_specialty IS NOT NULL AND par_old_original IS NOT NULL AND par_old_effective IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM Ward_specialty
                    WHERE Hospital_code = par_hospital_code AND Ward_code = par_old_ward AND Specialty_code = par_old_specialty AND Effective_date = par_old_effective) AND NOT EXISTS (SELECT
                    *
                    FROM bed_allocation
                    WHERE hospital_code = par_hospital_code AND ward_code = par_old_ward AND specialty_code = par_old_specialty AND effective_date = par_old_effective) THEN
                    /* handle for multiple original specialty in same ward due to different original */
                    BEGIN
                        BEGIN
                            DELETE FROM Ward_specialty
                                WHERE Hospital_code = par_hospital_code AND Ward_code = par_old_ward AND Specialty_code = par_old_specialty AND Effective_date = par_old_effective;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount <> 1) THEN
                                BEGIN
                                    SELECT
                                        - 1
                                        INTO par_return_code;
                                    SELECT
                                        'Delete old value for Ward Specialty failed.'
                                        INTO par_error_message;
                                    EXIT program_end;
                                END;
                            END IF;
                        END;
                    END;
                END IF;
            END;
        END IF;
        /* --	if @ward_code is not null and @specialty_code is not null and */
        /* --		@original_specialty is not null and @effective_date is not null */
        /* --	begin */
        IF par_ward_code IS NULL THEN
            SELECT
                par_old_ward
                INTO var_ward;
        ELSE
            SELECT
                par_ward_code
                INTO var_ward;
        END IF;

        IF par_specialty_code IS NULL THEN
            SELECT
                par_old_specialty
                INTO var_spec;
        ELSE
            SELECT
                par_specialty_code
                INTO var_spec;
        END IF;

        IF par_effective_date IS NULL THEN
            SELECT
                par_old_effective
                INTO var_date;
        ELSE
            SELECT
                par_effective_date
                INTO var_date;
        END IF;
        SELECT
            SUM(official_bed), SUM(day_bed)
            INTO var_off, var_day
            FROM bed_allocation
            WHERE hospital_code = par_hospital_code AND
            /* --			and ward_code = @ward_code */
            /* --			and specialty_code = @specialty_code */
            /* --			and effective_date = @effective_date */
            ward_code = var_ward AND specialty_code = var_spec AND effective_date = var_date;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 OR var_off IS NULL OR var_day IS NULL THEN
            SELECT
                NULL, NULL
                INTO var_day, var_off;
        END IF;

        IF var_day IS NOT NULL AND var_off IS NOT NULL THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM Ward_specialty
                    /* --				where Hospital_code = @hospital_code */
                    /* --				and Ward_code = @ward_code */
                    /* --				and Specialty_code = @specialty_code */
                    /* --				and Effective_date = @effective_date) */
                    WHERE Hospital_code = par_hospital_code AND Ward_code = var_ward AND Specialty_code = var_spec AND Effective_date = var_date) THEN
                    BEGIN
                        BEGIN
                            UPDATE Ward_specialty
                            SET
                            /* --					Official_bed = @official_bed, */
                            /* --					Day_bed = @day_bed, */
                            Official_bed = var_off, Day_bed = var_day, User_ID = par_update_by, System_datetime = var_upd_date
                                /* --					where Hospital_code = @hospital_code */
                                /* --					and Ward_code = @ward_code */
                                /* --					and Specialty_code = @specialty_code */
                                /* --					and Effective_date = @effective_date */
                                WHERE Hospital_code = par_hospital_code AND Ward_code = var_ward AND Specialty_code = var_spec AND Effective_date = var_date;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount <> 1) THEN
                                BEGIN
                                    SELECT
                                        - 1
                                        INTO par_return_code;
                                    SELECT
                                        'Update Ward Specialty table failed.'
                                        INTO par_error_message;
                                    EXIT program_end;
                                END;
                            END IF;
                        END;
                    END;
                ELSE
                    BEGIN
                        BEGIN
                            INSERT INTO Ward_specialty (effective_date, hospital_code, ward_code, specialty_code, official_bed, day_bed, close_date, system_datetime, user_id)
                            VALUES
                            /* --					(@effective_date, @hospital_code, @ward_code, @specialty_code, */
                            /* --					@official_bed, @day_bed, null, @upd_date, @update_by) */
                            (var_date, par_hospital_code, var_ward, var_spec, var_off, var_day, NULL, var_upd_date, par_update_by);
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF (sql$rowcount <> 1) THEN
                                BEGIN
                                    SELECT
                                        - 1
                                        INTO par_return_code;
                                    SELECT
                                        'Insert Ward Specialty table failed.'
                                        INTO par_error_message;
                                    EXIT program_end;
                                END;
                            END IF;
                        END;
                    END;
                END IF;
            END;
        END IF;
        /* --	end */
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


;ALTER PROCEDURE "hasp_upd_bed_allocation" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
