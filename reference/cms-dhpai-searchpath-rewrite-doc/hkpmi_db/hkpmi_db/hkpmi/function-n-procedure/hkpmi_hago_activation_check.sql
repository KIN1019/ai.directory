-- DROP PROCEDURE hkpmi.hkpmi_hago_activation_check(inout int4, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_activation_check(INOUT pas_return_code integer, IN par_hkid character varying, INOUT par_code integer, INOUT par_status character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_valid_flag VARCHAR(1);
    var_return_code int;
    var_patient_key VARCHAR(16);
    var_old_hkid VARCHAR(24);
    var_txn_type VARCHAR(6);
    var_move_status VARCHAR(1);
    var_age INTEGER;
    var_death_indicator VARCHAR(8);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount INTEGER;
BEGIN
    SELECT
        LPAD(RTRIM(par_hkid), 9)
        INTO par_hkid;
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
        NULL, NULL, NULL, NULL, NULL, NULL, NULL
        INTO var_patient_key, var_old_hkid, var_txn_type, var_move_status, var_age, var_death_indicator, var_death_date;
    SELECT
        patient_key, death_indicator, death_date
        INTO var_patient_key, var_death_indicator, var_death_date
        FROM patient
        WHERE hkid = par_hkid;

    IF var_patient_key IS NULL THEN
        BEGIN
            SELECT
                old_hkid, txn_type
                INTO var_old_hkid, var_txn_type
                FROM hkpmi_pin_change_log
                WHERE old_hkid = par_hkid;

            IF var_txn_type = '020' THEN
                BEGIN
                    SELECT
                        2902, 'The HKID had been merged to another ID'
                        INTO par_code, par_status;
                    pas_return_code := 2902;
                    RETURN;
                END;
            ELSE
                IF var_txn_type = '031' THEN
                    BEGIN
                        SELECT
                            2903, 'The HKID had been changed to another ID'
                            INTO par_code, par_status;
                        pas_return_code := 2903;
                        RETURN;
                    END;
                END IF;
            END IF;
            SELECT
                2907, 'HKID Not Found'
                INTO par_code, par_status;
            pas_return_code := 2907;
            RETURN;
        END;
    ELSE
        BEGIN
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
            SELECT
                COUNT(*)
                INTO var_rowcount
                FROM (SELECT
                    move_episode_indicator.hospital_code, move_episode_indicator.case_no, move_episode_indicator.create_dtm, move_episode_indicator.from_patient_key, move_episode_indicator.to_patient_key, move_episode_indicator.create_user, move_episode_indicator.create_system, move_episode_indicator.move_status, move_episode_indicator.update_dtm, move_episode_indicator.update_user, move_episode_indicator.update_system, move_episode_indicator.info_source_code, move_episode_indicator.reason_code, move_episode_indicator.other_reason
                    FROM move_episode_indicator
                    WHERE move_status = 'O' AND from_patient_key = var_patient_key
                UNION
                SELECT
                    move_episode_indicator.hospital_code, move_episode_indicator.case_no, move_episode_indicator.create_dtm, move_episode_indicator.from_patient_key, move_episode_indicator.to_patient_key, move_episode_indicator.create_user, move_episode_indicator.create_system, move_episode_indicator.move_status, move_episode_indicator.update_dtm, move_episode_indicator.update_user, move_episode_indicator.update_system, move_episode_indicator.info_source_code, move_episode_indicator.reason_code, move_episode_indicator.other_reason
                    FROM move_episode_indicator
                    WHERE move_status = 'O' AND to_patient_key = var_patient_key) AS tem;

            IF var_rowcount <> 0 THEN
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



ALTER PROCEDURE "hkpmi_hago_activation_check" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
