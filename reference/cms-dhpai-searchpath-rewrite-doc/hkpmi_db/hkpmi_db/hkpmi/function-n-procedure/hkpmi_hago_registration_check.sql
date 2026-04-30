-- DROP PROCEDURE hkpmi.hkpmi_hago_registration_check(inout int4, in varchar, in varchar, inout int4, inout varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_registration_check(INOUT pas_return_code integer, IN par_hkid character varying, IN par_input_name character varying, INOUT par_code integer, INOUT par_status character varying, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_valid_flag VARCHAR(1);
    var_return_code int;
    var_patient_name VARCHAR(96);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_death_indicator VARCHAR(8);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_patient_key VARCHAR(16);
    var_move_status VARCHAR(1);
    var_bcf_date TIMESTAMP WITHOUT TIME ZONE;
    "var_yrDiff" INTEGER;
    "var_monDiff" INTEGER;
   sql$rowcount INTEGER;
BEGIN
    /* HKID validation */
    SELECT
        LPAD(RTRIM(par_hkid), 9)
        INTO par_hkid;

    IF SUBSTRING(par_hkid, 1, 1) = 'U' THEN
        BEGIN
            SELECT
                2905, 'Invalid HKID'
                INTO par_code, par_status;
            pas_return_code := 2905;
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
        NULL, NULL, NULL, NULL, NULL, NULL
        INTO var_patient_name, var_dob, var_death_indicator, var_death_date, var_patient_key, var_move_status;
    SELECT
        patient_name, dob, death_indicator, death_date, patient_key
        INTO var_patient_name, var_dob, var_death_indicator, var_death_date, var_patient_key
        FROM patient
        WHERE hkid = par_hkid;

    IF var_patient_name IS NULL THEN
        BEGIN
            SELECT
                2907, 'HKID Not Found'
                INTO par_code, par_status;
            pas_return_code := 2907;
            RETURN;
        END;
    END IF;
    /* name checking */
    SELECT
        REGEXP_REPLACE(par_input_name, '[,\s-]', '', 'g')
        INTO par_input_name;
    SELECT
        REGEXP_REPLACE(var_patient_name, '[,\s-]', '', 'g')
        INTO var_patient_name;

    IF par_input_name IS NOT NULL AND par_input_name <> UPPER(var_patient_name) THEN
        BEGIN
            SELECT
                2901, 'Name Not Matched'
                INTO par_code, par_status;
            pas_return_code := 2901;
            RETURN;
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
$procedure$
;

ALTER PROCEDURE "hkpmi_hago_registration_check" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
