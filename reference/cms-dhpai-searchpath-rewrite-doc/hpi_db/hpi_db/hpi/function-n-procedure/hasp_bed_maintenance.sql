-- DROP PROCEDURE hpi.hasp_bed_maintenance(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_bed_maintenance(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_ward_code character varying, IN par_bed_no character varying, IN par_bed_type character varying, IN par_class character varying, IN par_status character varying, IN par_remarks character varying, IN par_active_date timestamp without time zone, IN par_inactive_date timestamp without time zone, IN par_bed_category character varying, IN par_effective_dtm timestamp without time zone, IN par_update_by character varying, IN par_update_type character varying, IN par_bed_service character varying DEFAULT NULL::character varying, IN par_bed_location character varying DEFAULT NULL::character varying, IN par_isolation_facilities character varying DEFAULT NULL::character varying, IN par_funded_bed character varying DEFAULT NULL::character varying, IN par_cubicle_no character varying DEFAULT NULL::character varying, IN par_original_capacity character varying DEFAULT NULL::character varying, IN par_delete_bed character varying DEFAULT NULL::character varying, IN par_original_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return_code INTEGER;
    var_row INTEGER;
    var_error INTEGER;
    var_bed_cat_service VARCHAR(2);
    var_bed_cat_type VARCHAR(2);
    var_bed_cat_iso VARCHAR(1);
    var_org_eff_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_today TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        IF (par_isolation_facilities = 'A' OR (par_isolation_facilities = 'B' AND par_funded_bed = '1')) AND par_bed_service = 'FET' THEN
            BEGIN
                SELECT
                    - 2
                    INTO var_return_code;
                EXIT return_error;
            END;
        END IF;
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_today;

        IF par_update_type = 'D' THEN
            BEGIN
                DELETE FROM Bed
                    WHERE Ward_code = par_ward_code AND Bed_no = par_bed_no AND Hospital_code = par_hosp_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_row := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_row <> 1 AND var_error <> 0 THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO var_return_code;
                        EXIT return_error;
                    END;
                END IF;

                IF par_delete_bed = 'Y' THEN
                    BEGIN
                        IF EXISTS (SELECT
                            *
                            FROM bed_category
                            WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime = par_effective_dtm) THEN
                            DELETE FROM bed_category
                                WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime = par_effective_dtm;
                        END IF;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM Bed
                    WHERE Bed_no = par_bed_no AND Ward_code = par_ward_code AND Hospital_code = par_hosp_code) THEN
                    BEGIN
                        UPDATE Bed
                        SET Bed_type = par_bed_type, Class = par_class, Remarks = par_remarks, Active_date = par_active_date, Inactive_date = par_inactive_date
                            WHERE Ward_code = par_ward_code AND Bed_no = par_bed_no AND Hospital_code = par_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        BEGIN
                            var_row := sql$rowcount;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                    END;
                ELSE
                    BEGIN
                        INSERT INTO Bed (ward_code, bed_no, bed_type, class, status, remarks, active_date, inactive_date, hospital_code)
                        VALUES (par_ward_code, par_bed_no, par_bed_type, par_class, par_status, par_remarks, par_active_date, par_inactive_date, par_hosp_code);
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        BEGIN
                            var_row := sql$rowcount;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                    END;
                END IF;

                IF var_row <> 1 OR var_error <> 0 THEN
                    BEGIN
                        SELECT
                            - 1
                            INTO var_return_code;
                        EXIT return_error;
                    END;
                END IF;

                IF par_effective_dtm IS NOT NULL THEN
                    BEGIN
                        IF par_bed_category IS NULL THEN
                            BEGIN
                                IF par_bed_service IS NULL THEN
                                    IF par_isolation_facilities IN ('A', 'B', 'C') THEN
                                        SELECT
                                            'IS'
                                            INTO var_bed_cat_service;
                                    ELSE
                                        SELECT
                                            'NO'
                                            INTO var_bed_cat_service;
                                    END IF;
                                ELSE
                                    IF par_bed_service IN ('ICU', 'CCU', 'HDU', 'PIC', 'NIC') THEN
                                        SELECT
                                            SUBSTRING(par_bed_service, 1, 2)
                                            INTO var_bed_cat_service;
                                    ELSE
                                        SELECT
                                            'NO'
                                            INTO var_bed_cat_service;
                                    END IF;
                                END IF;

                                IF var_bed_cat_service <> 'IS' AND par_isolation_facilities IN ('A', 'B', 'C') THEN
                                    SELECT
                                        'I'
                                        INTO var_bed_cat_iso;
                                ELSE
                                    SELECT
                                        NULL
                                        INTO var_bed_cat_iso;
                                END IF;

                                IF par_bed_type = 'R' THEN
                                    IF var_bed_cat_service = 'IS' OR var_bed_cat_iso = 'I' THEN
                                        SELECT
                                            'CO'
                                            INTO var_bed_cat_type;
                                    ELSE
                                        SELECT
                                            'OF'
                                            INTO var_bed_cat_type;
                                    END IF;
                                ELSE
                                    IF var_bed_cat_service = 'IS' OR var_bed_cat_iso = 'I' THEN
                                        SELECT
                                            'CA'
                                            INTO var_bed_cat_type;
                                    ELSE
                                        SELECT
                                            'AD'
                                            INTO var_bed_cat_type;
                                    END IF;
                                END IF;
                                SELECT
                                    CONCAT(var_bed_cat_service, var_bed_cat_type, var_bed_cat_iso)
                                    INTO par_bed_category;
                            END;
                        END IF;

                        IF par_original_dtm IS NULL THEN
                            BEGIN
                                IF EXISTS (SELECT
                                    *
                                    FROM bed_category
                                    WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime = par_effective_dtm) THEN
                                    BEGIN
                                        UPDATE bed_category
                                        SET bed_category = par_bed_category, effective_datetime = par_effective_dtm, update_by = par_update_by, update_dtm = var_today, bed_service = par_bed_service, bed_location = par_bed_location, bed_type = par_bed_type, isolation_facilities = par_isolation_facilities, funded_bed = par_funded_bed, cubicle_no = par_cubicle_no, original_capacity = par_original_capacity
                                            WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime = par_effective_dtm;
                                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                        BEGIN
                                            var_row := sql$rowcount;
                                            var_error := 0;
                                            EXCEPTION
                                                WHEN OTHERS THEN
                                                    var_error := 1;
                                        END;
                                    END;
                                ELSE
                                    BEGIN
                                        IF EXISTS (SELECT
                                            *
                                            FROM bed_category
                                            WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime > var_today) THEN
                                            BEGIN
                                                SELECT
                                                    MIN(effective_datetime)
                                                    INTO var_org_eff_dtm
                                                    FROM bed_category
                                                    WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime > var_today;
                                                UPDATE bed_category
                                                SET bed_category = par_bed_category, effective_datetime = par_effective_dtm, update_by = par_update_by, update_dtm = var_today, bed_service = par_bed_service, bed_location = par_bed_location, bed_type = par_bed_type, isolation_facilities = par_isolation_facilities, funded_bed = par_funded_bed, cubicle_no = par_cubicle_no, original_capacity = par_original_capacity
                                                    WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime = var_org_eff_dtm;
                                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                BEGIN
                                                    var_row := sql$rowcount;
                                                    var_error := 0;
                                                    EXCEPTION
                                                        WHEN OTHERS THEN
                                                            var_error := 1;
                                                END;
                                            END;
                                        ELSE
                                            BEGIN
                                                INSERT INTO bed_category (hospital_code, ward_code, bed_no, bed_category, effective_datetime, update_by, update_dtm, bed_service, bed_location, bed_type, isolation_facilities, funded_bed, cubicle_no, original_capacity)
                                                VALUES (par_hosp_code, par_ward_code, par_bed_no, par_bed_category, par_effective_dtm, par_update_by, var_today, par_bed_service, par_bed_location, par_bed_type, par_isolation_facilities, par_funded_bed, par_cubicle_no, par_original_capacity);
                                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                BEGIN
                                                    var_row := sql$rowcount;
                                                    var_error := 0;
                                                    EXCEPTION
                                                        WHEN OTHERS THEN
                                                            var_error := 1;
                                                END;
                                            END;
                                        END IF;
                                    END;
                                END IF;
                            END;
                        END IF;

                        IF var_row <> 1 OR var_error <> 0 THEN
                            BEGIN
                                SELECT
                                    - 1
                                    INTO var_return_code;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        IF EXISTS (SELECT
                            *
                            FROM bed_category
                            WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime = par_original_dtm) THEN
                            BEGIN
                                UPDATE bed_category
                                SET bed_category = par_bed_category, bed_service = par_bed_service, bed_location = par_bed_location, bed_type = par_bed_type, isolation_facilities = par_isolation_facilities, funded_bed = par_funded_bed, cubicle_no = par_cubicle_no, original_capacity = par_original_capacity, update_by = par_update_by, effective_datetime = par_effective_dtm, update_dtm = var_today
                                    WHERE hospital_code = par_hosp_code AND ward_code = par_ward_code AND bed_no = par_bed_no AND effective_datetime = par_original_dtm;

                                IF var_row <> 1 OR var_error <> 0 THEN
                                    BEGIN
                                        SELECT
                                            - 1
                                            INTO var_return_code;
                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        SELECT
            0
            INTO var_return_code;
    END;
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_bed_maintenance" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
