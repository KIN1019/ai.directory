-- DROP FUNCTION hpi."fn_tI_bed_history"();

CREATE OR REPLACE FUNCTION hpi."fn_tI_bed_history"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* --Skip logging if rowcount>1 */
DECLARE
    var_numrows INTEGER;
    var_rowcount$aws$ INTEGER;
    var_isolation_facilities CHAR(2);
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
        FROM inserted
        WHERE inserted.isolation_bed = 'Y') THEN
        BEGIN
            SELECT
                isolation_facilities
                INTO var_isolation_facilities
                FROM cubicle, inserted
                WHERE cubicle.hospital_code = inserted.hospital_code AND cubicle.ward_code = inserted.ward_code AND cubicle.cubicle_no = inserted.cubicle_no AND cubicle.effective_date = inserted.effective_datetime;
            INSERT INTO bed_change_log (hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, active_status, isolation_facilities, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, bed_ready, old_active_status, old_isolation_facilities, old_bed_type, old_bed_category, old_specialty_code, old_in_service_specialty, old_row_no, old_col_no, old_update_datetime, old_update_by, old_source_system, old_ciwl_indicator, old_isolation_bed, old_bed_ready, action, sent)
            SELECT
                inserted.hospital_code, inserted.ward_code, inserted.cubicle_no, inserted.bed_no, inserted.effective_datetime, inserted.active_status, var_isolation_facilities, inserted.bed_type, inserted.bed_category, inserted.specialty_code, inserted.in_service_specialty, inserted.row_no, inserted.col_no, inserted.update_datetime, inserted.update_by, inserted.source_system, inserted.ciwl_indicator, inserted.isolation_bed, inserted.bed_ready, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, inserted.update_datetime, NULL, NULL, NULL, NULL, NULL, 'I', NULL
                FROM inserted;
            RETURN NULL;
        END;
    END IF;
    RETURN NULL;
END;
$function$
;


;ALTER FUNCTION "fn_tI_bed_history" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
