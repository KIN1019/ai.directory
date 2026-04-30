-- DROP FUNCTION hpi."fn_tU_cubicle"();

CREATE OR REPLACE FUNCTION hpi."fn_tU_cubicle"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* --Skip logging if rowcount>1 */
DECLARE
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        SELECT
            count(1)
            FROM inserted
            INTO var_rowcount$aws$;
    ELSE
        SELECT
            count(1)
            FROM deleted
            INTO var_rowcount$aws$;
    END IF;
    var_numrows := var_rowcount$aws$;

    IF var_numrows > 1 THEN
        BEGIN
            RETURN NULL;
        END;
    END IF;

    IF EXISTS (SELECT
        1
        FROM inserted, deleted
        WHERE inserted.isolation_facilities <> deleted.isolation_facilities OR inserted.facility_type <> deleted.facility_type OR inserted.ante_room <> deleted.ante_room OR inserted.ensuite_toilet <> deleted.ensuite_toilet OR (inserted.isolation_facilities IS NULL AND deleted.isolation_facilities IS NOT NULL) OR (inserted.isolation_facilities IS NOT NULL AND deleted.isolation_facilities IS NULL) OR (inserted.facility_type IS NULL AND deleted.facility_type IS NOT NULL) OR (inserted.facility_type IS NOT NULL AND deleted.facility_type IS NULL) OR (inserted.ante_room IS NULL AND deleted.ante_room IS NOT NULL) OR (inserted.ante_room IS NOT NULL AND deleted.ante_room IS NULL) OR (inserted.ensuite_toilet IS NULL AND deleted.ensuite_toilet IS NOT NULL) OR (inserted.ensuite_toilet IS NOT NULL AND deleted.ensuite_toilet IS NULL)) THEN
        BEGIN
            INSERT INTO cubicle_change_log (hospital_code, ward_code, cubicle_no, effective_date, active_status, description, isolation_facilities, project_category, sex, treatment_location, update_datetime, update_by, source_system, patient_category, cubicle_service, official_bed, day_bed, facility_type, ante_room, ensuite_toilet, old_active_status, old_description, old_isolation_facilities, old_project_category, old_sex, old_treatment_location, old_update_datetime, old_update_by, old_source_system, old_patient_category, old_cubicle_service, old_official_bed, old_day_bed, old_facility_type, old_ante_room, old_ensuite_toilet, action, sent)
            SELECT
                inserted.hospital_code, inserted.ward_code, inserted.cubicle_no, inserted.effective_date, inserted.active_status, inserted.description, inserted.isolation_facilities, inserted.project_category, inserted.sex, inserted.treatment_location, inserted.update_datetime, inserted.update_by, inserted.source_system, inserted.patient_category, inserted.cubicle_service, inserted.official_bed, inserted.day_bed, inserted.facility_type, inserted.ante_room, inserted.ensuite_toilet, deleted.active_status, deleted.description, deleted.isolation_facilities, deleted.project_category, deleted.sex, deleted.treatment_location, deleted.update_datetime, deleted.update_by, deleted.source_system, deleted.patient_category, deleted.cubicle_service, deleted.official_bed, deleted.day_bed, deleted.facility_type, deleted.ante_room, deleted.ensuite_toilet, 'U', NULL
                FROM inserted, deleted;

            IF EXISTS (SELECT
                1
                FROM inserted, deleted
                WHERE inserted.isolation_facilities <> deleted.isolation_facilities OR (inserted.isolation_facilities IS NULL AND deleted.isolation_facilities IS NOT NULL) OR (inserted.isolation_facilities IS NOT NULL AND deleted.isolation_facilities IS NULL)) THEN
                BEGIN
                    INSERT INTO bed_change_log (hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, active_status, isolation_facilities, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, bed_ready, old_active_status, old_isolation_facilities, old_bed_type, old_bed_category, old_specialty_code, old_in_service_specialty, old_row_no, old_col_no, old_update_datetime, old_update_by, old_source_system, old_ciwl_indicator, old_isolation_bed, old_bed_ready, action, sent)
                    SELECT
                        a.hospital_code, a.ward_code, a.cubicle_no, a.bed_no, a.effective_datetime, a.active_status, inserted.isolation_facilities, a.bed_type, a.bed_category, a.specialty_code, a.in_service_specialty, a.row_no, a.col_no, inserted.update_datetime, a.update_by, a.source_system, a.ciwl_indicator, a.isolation_bed, a.bed_ready, a.active_status, deleted.isolation_facilities, a.bed_type, a.bed_category, a.specialty_code, a.in_service_specialty, a.row_no, a.col_no, a.update_datetime, a.update_by, a.source_system, a.ciwl_indicator, a.isolation_bed, a.bed_ready, 'U', NULL
                        FROM bed_history AS a, inserted, deleted
                        WHERE inserted.hospital_code = a.hospital_code AND inserted.ward_code = a.ward_code AND inserted.cubicle_no = a.cubicle_no AND inserted.effective_date = a.effective_datetime;
                END;
            END IF;
            RETURN NULL;
        END;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tU_cubicle" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
