-- DROP PROCEDURE hkpmi.hkpmi_hago_forgot_pswd_check(inout int4, in varchar, in varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_forgot_pswd_check(INOUT pas_return_code integer, IN par_hkid character varying, IN par_input_name character varying, INOUT par_code integer, INOUT par_status character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_valid_flag VARCHAR(1);
    var_return_code int;
    var_patient_key VARCHAR(16);
    var_patient_name VARCHAR(96);
    var_old_hkid VARCHAR(24);
    var_txn_type VARCHAR(6);
    var_death_indicator VARCHAR(8);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount INTEGER;
BEGIN
    SELECT
        LPAD(par_hkid, 9)
        INTO par_hkid;

    IF SUBSTRING(par_hkid, 1, 1) = 'U' THEN
        BEGIN
            SELECT
                2908, 'Not Eligible'
                INTO par_code, par_status;
            pas_return_code := 2908;
            RETURN;
        END;
    END IF;
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
        NULL, NULL, NULL, NULL, NULL
        INTO var_patient_key, var_old_hkid, var_txn_type, var_death_indicator, var_death_date;
    SELECT
        patient_key, death_indicator, death_date, patient_name
        INTO var_patient_key, var_death_indicator, var_death_date, var_patient_name
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
                        2902, 'HKID Merged'
                        INTO par_code, par_status;
                    pas_return_code := 2902;
                    RETURN;
                END;
            ELSE
                IF var_txn_type = '031' THEN
                    BEGIN
                        SELECT
                            2903, 'HKID Changed'
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
            IF par_input_name IS NOT NULL THEN
                BEGIN
                    SELECT
                        REGEXP_REPLACE(par_input_name, '[,\s-]', '', 'g')
                        INTO par_input_name;
                    SELECT
                        REGEXP_REPLACE(var_patient_name, '[,\s-]', '', 'g')
                        INTO var_patient_name;

                    IF par_input_name <> UPPER(var_patient_name) THEN
                        BEGIN
                            SELECT
                                2901, 'Name Not Matched'
                                INTO par_code, par_status;
                            pas_return_code := 2901;
                            RETURN;
                        END;
                    END IF;
                END;
            END IF;
            /* death checking */
            IF var_death_indicator IS NOT NULL AND var_death_date IS NOT NULL THEN
                BEGIN
                    SELECT
                        2906, 'Dead Patient'
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
                        2904, 'Episode Moved'
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

ALTER PROCEDURE "hkpmi_hago_forgot_pswd_check" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
