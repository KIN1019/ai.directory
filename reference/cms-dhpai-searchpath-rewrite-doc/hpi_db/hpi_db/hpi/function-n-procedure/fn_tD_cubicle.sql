-- DROP FUNCTION "fn_tD_cubicle"();

CREATE OR REPLACE FUNCTION "fn_tD_cubicle"()
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
        FROM deleted
        WHERE deleted.isolation_facilities IN ('AG', 'AI', 'AN', 'AP', 'BG', 'BI', 'BN', 'BP')) THEN
        BEGIN
            INSERT INTO cubicle_change_log (hospital_code, ward_code, cubicle_no, effective_date, active_status, description, isolation_facilities, project_category, sex, treatment_location, update_datetime, update_by, source_system, patient_category, cubicle_service, official_bed, day_bed, facility_type, ante_room, ensuite_toilet, old_active_status, old_description, old_isolation_facilities, old_project_category, old_sex, old_treatment_location, old_update_datetime, old_update_by, old_source_system, old_patient_category, old_cubicle_service, old_official_bed, old_day_bed, old_facility_type, old_ante_room, old_ensuite_toilet, action, sent)
            SELECT
                deleted.hospital_code, deleted.ward_code, deleted.cubicle_no, deleted.effective_date, NULL, NULL, NULL, NULL, timestamp_convert(localtimestamp), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, deleted.active_status, deleted.description, deleted.isolation_facilities, deleted.project_category, deleted.sex, deleted.treatment_location, deleted.update_datetime, deleted.update_by, deleted.source_system, deleted.patient_category, deleted.cubicle_service, deleted.official_bed, deleted.day_bed, deleted.facility_type, deleted.ante_room, deleted.ensuite_toilet, 'D', NULL
                FROM deleted;
            RETURN NULL;
        END;
    END IF;
    RETURN NULL;
END;
$function$
;

;ALTER FUNCTION "fn_tD_cubicle" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
