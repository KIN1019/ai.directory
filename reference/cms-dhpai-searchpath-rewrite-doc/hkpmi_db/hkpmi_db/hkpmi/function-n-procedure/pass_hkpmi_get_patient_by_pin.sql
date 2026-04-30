CREATE OR REPLACE PROCEDURE pass_hkpmi_get_patient_by_pin(INOUT pas_return_code int,IN par_hospital VARCHAR, IN par_in_pin VARCHAR,  INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_pin_type INTEGER;
    var_pin_len INTEGER;
    var_hkid VARCHAR(12);
    var_case_no VARCHAR(12);
    var_mrn VARCHAR(8);
    var_valid_flag VARCHAR(1);
    var_return_code INTEGER;
    var_return_msg VARCHAR(255);
    var_patient_key VARCHAR(8);
    var_ret_hkid VARCHAR(12);
    var_pin VARCHAR(12);
    var_pos INTEGER;

BEGIN
    BEGIN
        /* --Cater UCH: PIN+.+specialty code */
        SELECT
            LTRIM(RTRIM(par_in_pin))
            INTO var_pin;
        SELECT
            STRPOS(var_pin, '.')
            INTO var_pos;

        IF var_pos > 0 THEN
            SELECT
                SUBSTRING(var_pin, 1, var_pos - 1)
                INTO var_pin;
        END IF;
        SELECT
            OCTET_LENGTH(var_pin)
            INTO var_pin_len;
        SELECT
            CASE
                WHEN var_pin_len = 12 THEN 3 /* --OP */
                WHEN var_pin_len = 11 THEN 2 /* --AE or HN */
                WHEN var_pin_len = 9 THEN 1 /* --HKID */
                WHEN var_pin_len = 8 AND SUBSTRING(var_pin, 1, 1) ~ '^[A-Z]$' THEN 1 /* --HKID */
                WHEN var_pin_len = 8 AND SUBSTRING(var_pin, 1, 1) ~ '^[0-9]$' THEN 0 /* --MRN */
                WHEN var_pin_len >= 2 AND var_pin_len <= 7 THEN 0 /* --MRN */
                ELSE 4
            END
            INTO var_pin_type;
        /* check format */
        IF var_pin_type = 0 THEN
            BEGIN
                SELECT
                    var_pin
                    INTO var_mrn;
                SELECT
                    CONCAT(REPEAT(' ', 8 - var_pin_len), var_mrn)
                    INTO var_mrn;
                CALL cpi_pq_validate_mrn(var_return_code,var_mrn, par_hospital, var_valid_flag);

                IF var_return_code <> 0 THEN
                    BEGIN
                        SELECT
                            - 10, 'Validation error by cpi_pq_validate_mrn'
                            INTO var_return_code, var_return_msg;
                        --EXIT error;
                        OPEN p_refcur FOR
                            SELECT
                                var_return_code, var_return_msg;
                            pas_return_code := var_return_code;
                            RETURN;                        
                    END;
                END IF;
                SELECT
                    patient_key
                    INTO var_patient_key
                    FROM patient_hospital_data
                    WHERE mrn = var_mrn AND hospital_code = par_hospital;
                SELECT
                    hkid
                    INTO var_ret_hkid
                    FROM patient
                    WHERE patient_key = var_patient_key;

                IF var_ret_hkid IS NULL THEN
                    BEGIN
                        SELECT
                            - 100, 'Patient not found by MRN.'
                            INTO var_return_code, var_return_msg;
                        --EXIT error;
                        OPEN p_refcur FOR
                            SELECT
                                var_return_code, var_return_msg;
                            pas_return_code := var_return_code;
                            RETURN;                              

                    END;
                END IF;
            END;
        END IF;

        IF var_pin_type = 1 THEN
            BEGIN
                IF var_pin_len = 8 THEN
                    SELECT
                        CONCAT(' ', var_pin)
                        INTO var_hkid;
                ELSE
                    SELECT
                        var_pin
                        INTO var_hkid;
                END IF;
                CALL cpi_pq_validate_hkid( var_return_code,var_hkid, var_valid_flag);

                IF var_return_code <> 0 THEN
                    BEGIN
                        SELECT
                            - 11, 'Validation error by cpi_pq_validate_hkid'
                            INTO var_return_code, var_return_msg;
                        --EXIT error;
                        OPEN p_refcur FOR
                            SELECT
                                var_return_code, var_return_msg;
                            pas_return_code := var_return_code;
                            RETURN;

                    END;
                END IF;
                SELECT
                    hkid
                    INTO var_ret_hkid
                    FROM patient
                    WHERE hkid = var_hkid;

                IF var_ret_hkid IS NULL THEN
                    BEGIN
                        SELECT
                            - 101, 'Patient not found by HKID.'
                            INTO var_return_code, var_return_msg;
                        --EXIT error;
                        OPEN p_refcur FOR
                            SELECT
                                var_return_code, var_return_msg;
                            pas_return_code := var_return_code;
                            RETURN;

                    END;
                END IF;
            END;
        END IF;

        IF var_pin_type = 2 OR var_pin_type = 3 THEN
            BEGIN
                IF var_pin_len = 11 THEN
                    SELECT
                        CONCAT(' ', var_pin)
                        INTO var_case_no;
                ELSE
                    SELECT
                        var_pin
                        INTO var_case_no;
                END IF;
                CALL cpi_pq_validate_caseno(var_return_code,var_case_no, par_hospital, var_valid_flag, NULL);

                IF var_return_code <> 0 THEN
                    BEGIN
                        SELECT
                            - 12, 'Validation error by cpi_pq_validate_caseno'
                            INTO var_return_code, var_return_msg;
                        --EXIT error;
                        OPEN p_refcur FOR
                            SELECT
                                var_return_code, var_return_msg;
                            pas_return_code := var_return_code;
                            RETURN;

                    END;
                END IF;
                SELECT
                    patient_key
                    INTO var_patient_key
                    FROM pmi_case
                    WHERE case_no = var_case_no AND hospital_code = par_hospital;
                SELECT
                    hkid
                    INTO var_ret_hkid
                    FROM patient
                    WHERE patient_key = var_patient_key;

                IF var_ret_hkid IS NULL THEN
                    BEGIN
                        IF var_pin_type = 2 THEN
                            SELECT
                                - 102
                                INTO var_return_code;
                        ELSE
                            SELECT
                                - 103
                                INTO var_return_code;
                        END IF;
                        SELECT
                            'Patient not found by Case Number.'
                            INTO var_return_msg;
                        --EXIT error;
                        OPEN p_refcur FOR
                            SELECT
                                var_return_code, var_return_msg;
                            pas_return_code := var_return_code;
                            RETURN;

                    END;
                END IF;
            END;
        END IF;

        IF var_pin_type = 4 THEN
            SELECT
                - 104, 'Invalid P.I.N.'
                INTO var_return_code, var_return_msg;
        END IF;
        OPEN p_refcur FOR
        SELECT
            var_return_code, LTRIM(var_ret_hkid);
        pas_return_code := 0;
        RETURN;
    END;
END;
$procedure$
;

ALTER PROCEDURE "pass_hkpmi_get_patient_by_pin" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";