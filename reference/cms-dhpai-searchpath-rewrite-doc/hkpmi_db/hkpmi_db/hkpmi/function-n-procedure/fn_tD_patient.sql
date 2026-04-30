-- DROP FUNCTION hkpmi."fn_tD_patient"();

CREATE OR REPLACE FUNCTION hkpmi."fn_tD_patient"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* DELETE trigger on patient */
DECLARE
    var_errno INTEGER;
    var_errmsg VARCHAR(255);
    var_del_hkid CHAR(12);
BEGIN
    <<system_error>>
    BEGIN
        <<error>>
        BEGIN
            /* patient R/50 pmi_case ON PARENT DELETE RESTRICT */
            IF EXISTS (SELECT
                *
                FROM deleted, pmi_case
                WHERE pmi_case.patient_key = deleted.patient_key) THEN
                BEGIN
                    SELECT
                        200035
                        INTO var_errno;
                    EXIT error;
                END;
            END IF;
            /* patient R/91 patient_detail ON PARENT DELETE CASCADE */
            BEGIN
                DELETE FROM patient_detail
                USING deleted
                    WHERE patient_detail.patient_key = deleted.patient_key;
                EXCEPTION
                    WHEN others THEN
                        EXIT system_error;
            END;
            /* patient R/9 nok ON PARENT DELETE CASCADE */
            BEGIN
                DELETE FROM nok
                USING deleted
                    WHERE nok.patient_key = deleted.patient_key;
                EXCEPTION
                    WHEN others THEN
                        EXIT system_error;
            END;
            /* patient R/6 patient_hospital_data ON PARENT DELETE CASCADE */
            BEGIN
                DELETE FROM patient_hospital_data
                USING deleted
                    WHERE patient_hospital_data.patient_key = deleted.patient_key;
                EXCEPTION
                    WHEN others THEN
                        EXIT system_error;
            END;
            /* Delete patient_detail_1 */
            BEGIN
                DELETE FROM patient_detail_1
                USING deleted
                    WHERE patient_detail_1.patient_key = deleted.patient_key;
                EXCEPTION
                    WHEN others THEN
                        EXIT system_error;
            END;
            /* insert hkid to hkpmi_used_unhkid if it is an unknow ID and not exists in table */
            SELECT
                hkid
                INTO var_del_hkid
                FROM deleted;

            BEGIN
                IF var_del_hkid LIKE 'U%' AND NOT EXISTS (SELECT
                    *
                    FROM hkpmi_used_unhkid
                    WHERE hkid = var_del_hkid) THEN
                    INSERT INTO hkpmi_used_unhkid (hkid, create_dtm, block_type, request_hosp, request_by, filler)
                    VALUES (var_del_hkid, timestamp_convert(localtimestamp), 'U', NULL, 'ADT', NULL);
                END IF;
                EXCEPTION
                    WHEN others THEN
                        EXIT system_error;
            END;
            /* 20130508 */
            DELETE FROM patient_doc_info
            USING deleted
                WHERE patient_doc_info.patient_key = deleted.patient_key;
            /* 20220412 Harmonic LI: delete hkpmi_patient_cvi_record, hkpmi_patient_cvi_dose_info, hkpmi_patient_cvi_mex */
            DELETE FROM hkpmi_patient_cvi_record
            USING deleted
                WHERE hkpmi_patient_cvi_record.patient_key = deleted.patient_key;
            DELETE FROM hkpmi_patient_cvi_dose_info
            USING deleted
                WHERE hkpmi_patient_cvi_dose_info.patient_key = deleted.patient_key;
            DELETE FROM hkpmi_patient_cvi_mex
            USING deleted
                WHERE hkpmi_patient_cvi_mex.patient_key = deleted.patient_key;
            /* Harmonic (20230803): Delete patient_geoaddress_detail */
            -- UPDATE patient_geoaddress_detail
            -- SET last_action = 'P'
            -- FROM deleted
            --     WHERE patient_geoaddress_detail.patient_key = deleted.patient_key;
            /* Harmonic (20230803): Update nok_geoaddress_detail */
            -- UPDATE nok_geoaddress_detail
            -- SET last_action = 'P'
            -- FROM deleted
            --     WHERE nok_geoaddress_detail.patient_key = deleted.patient_key;
            RETURN NULL;
        END;
        RAISE EXCEPTION USING ERRCODE := var_errno;
        RETURN NULL;
    END;
    RAISE EXCEPTION USING ERRCODE := '200072';
    RETURN NULL;
END;
$function$
;


ALTER FUNCTION "fn_tD_patient" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
