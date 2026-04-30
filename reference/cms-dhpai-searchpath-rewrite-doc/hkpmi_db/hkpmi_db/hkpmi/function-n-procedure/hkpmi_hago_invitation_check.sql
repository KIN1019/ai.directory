-- DROP PROCEDURE hkpmi.hkpmi_hago_invitation_check(inout int4, in varchar, inout int4, inout varchar, in varchar, inout varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_invitation_check(INOUT pas_return_code integer, IN par_hkid character varying, INOUT par_code integer, INOUT par_status character varying, IN par_phone character varying DEFAULT ''::character varying, INOUT par_phone_status character varying DEFAULT 'N'::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_valid_flag VARCHAR(1);
    var_return_code int;
    var_patient_key VARCHAR(16);
    var_old_hkid VARCHAR(12);
    var_txn_type VARCHAR(6);
    var_move_status VARCHAR(1);
    var_death_indicator VARCHAR(8);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_home_phone VARCHAR(20);
    var_office_phone VARCHAR(20);
    var_other_phone VARCHAR(20);
    "var_yrDiff" INTEGER;
    "var_monDiff" INTEGER;
   	sql$rowcount INTEGER;
BEGIN
    CALL cpi_pq_validate_hkid(var_return_code, par_hkid, var_valid_flag);

    IF var_valid_flag = 'N' THEN
        BEGIN
            SELECT
                2905, 'Invalid HKID'
                INTO par_code, par_status;
            pas_return_code := 2905;
            RETURN;
        END;
    END IF;
    SELECT
        NULL, NULL, NULL, NULL, NULL, NULL
        INTO var_patient_key, var_old_hkid, var_txn_type, var_move_status, var_death_indicator, var_death_date;
    SELECT
        patient_key, death_indicator, death_date, dob, phone1, phone2, mobile_phone
        INTO var_patient_key, var_death_indicator, var_death_date, var_dob, var_home_phone, var_office_phone, var_other_phone
        FROM patient
        WHERE hkid = par_hkid;

    IF var_patient_key IS NULL THEN
        BEGIN
            SELECT
                2907, 'HKID Not Found'
                INTO par_code, par_status;
            pas_return_code := 2907;
            RETURN;
        END;
    ELSE
        BEGIN
            /* Check phone number matched with one of phone numbers in HKPMI */
            IF par_phone IN (var_home_phone, var_office_phone, var_other_phone) THEN
                SELECT
                    'Y'
                    INTO par_phone_status;
            ELSE
                SELECT
                    'N'
                    INTO par_phone_status;
            END IF;
            /* age checking */
            SELECT
                date_part('year', timestamp_convert(localtimestamp)::TIMESTAMP) - date_part('year', var_dob::TIMESTAMP)
                INTO "var_yrDiff";
            SELECT
                date_part('month', timestamp_convert(localtimestamp)::TIMESTAMP) - date_part('month', var_dob::TIMESTAMP)
                INTO "var_monDiff";

            IF date_part('day', timestamp_convert(localtimestamp)::DATE) - date_part('day', var_dob::DATE) < 0 THEN
                SELECT
                    "var_monDiff" - 1
                    INTO "var_monDiff";
            END IF;

            IF "var_monDiff" < 0 THEN
                SELECT
                    "var_yrDiff" - 1
                    INTO "var_yrDiff";
            END IF;

            IF "var_yrDiff" < 18 THEN
                BEGIN
                    SELECT
                        2908, 'Not Eligible'
                        INTO par_code, par_status;
                    pas_return_code := 2908;
                    RETURN;
                END;
            END IF;
            /* death checking */
            IF var_death_indicator IS NOT NULL AND var_death_date IS NOT NULL THEN
                BEGIN
                    SELECT
                        2906, 'Death patient record'
                        INTO par_code, par_status;
                    pas_return_code := 2906;
                    RETURN;
                END;
            END IF;
            /* yellow flag checking */
            /* Adaptive Server has expanded all '*' elements in the following statement */
            OPEN p_refcur FOR
            SELECT
                move_episode_indicator.hospital_code, move_episode_indicator.case_no, move_episode_indicator.create_dtm, move_episode_indicator.from_patient_key, move_episode_indicator.to_patient_key, move_episode_indicator.create_user, move_episode_indicator.create_system, move_episode_indicator.move_status, move_episode_indicator.update_dtm, move_episode_indicator.update_user, move_episode_indicator.update_system, move_episode_indicator.info_source_code, move_episode_indicator.reason_code, move_episode_indicator.other_reason
                FROM move_episode_indicator
                WHERE move_status = 'O' AND from_patient_key = var_patient_key
            UNION
            SELECT
                move_episode_indicator.hospital_code, move_episode_indicator.case_no, move_episode_indicator.create_dtm, move_episode_indicator.from_patient_key, move_episode_indicator.to_patient_key, move_episode_indicator.create_user, move_episode_indicator.create_system, move_episode_indicator.move_status, move_episode_indicator.update_dtm, move_episode_indicator.update_user, move_episode_indicator.update_system, move_episode_indicator.info_source_code, move_episode_indicator.reason_code, move_episode_indicator.other_reason
                FROM move_episode_indicator
                WHERE move_status = 'O' AND to_patient_key = var_patient_key;

            IF (SELECT EXISTS(SELECT from_patient_key FROM  move_episode_indicator WHERE move_status = 'O' AND from_patient_key = var_patient_key LIMIT 1)) OR
               (SELECT EXISTS(SELECT to_patient_key FROM move_episode_indicator WHERE move_status = 'O' AND to_patient_key = var_patient_key LIMIT 1)) THEN
               BEGIN
                    SELECT
                    2904, 'Record in Verification (Yellow Flag)'
                    INTO par_code, par_status;
                    pas_return_code := 2904;
                    RETURN;
               END;
            END IF;

            SELECT
                0, ''
                INTO par_code, par_status;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_invitation_check" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
