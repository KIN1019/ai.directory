-- DROP FUNCTION hkpmi.hkpmi_get_case_patient_gp(bpchar, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_case_patient_gp(par_hosp_code VARCHAR, par_case_no VARCHAR)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
/* --@patient_type    VARCHAR(3) output, */
/* --@patient_gp		char(5) output, */
/* --@return_msg		char(255) output */
DECLARE
    var_valid_flag VARCHAR(01);
    var_return_error_code INTEGER;
    var_return_code INTEGER;
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_row_count INTEGER;
    var_patient_type VARCHAR(3);
    var_patient_gp VARCHAR(5);
    var_return_msg VARCHAR(255);
    sql$rowcount BIGINT;
BEGIN
    <<prog_return>>
    BEGIN
        /* Declaration */
        /* init */
        SELECT
            NULL, NULL
            INTO var_patient_type, var_patient_gp;
        /* validation */
        IF NOT EXISTS (SELECT
            *
            FROM hospital
            WHERE hospital_code = par_hosp_code) THEN
            BEGIN
                SELECT
                    - 1
                    INTO var_return_error_code;
                SELECT
                    ' Invalid Hospital Code!'
                    INTO var_return_msg;
                EXIT prog_return;
            END;
        END IF;
        CALL cpi_pq_validate_caseno(var_return_code, par_case_no, par_hosp_code, var_valid_flag);

        IF (var_valid_flag = 'N' OR var_return_code != 0) THEN
            BEGIN
                SELECT
                    - 2
                    INTO var_return_error_code;
                SELECT
                    'Invalid Case no!'
                    INTO var_return_msg;
                EXIT prog_return;
            END;
        END IF;
        /* Retrieve patient type */
        BEGIN
            SELECT
                patient_type, adm_dtm, source_system_dtm
                INTO var_patient_type, var_adm_dtm, var_update_dtm /* update_dtm */
                FROM pmi_case
                WHERE hospital_code = par_hosp_code AND case_no = par_case_no;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;

        IF var_error <> 0 OR var_row_count <> 1 THEN
            BEGIN
                SELECT
                    - 3
                    INTO var_return_error_code;
                SELECT
                    'Case not found!'
                    INTO var_return_msg;
                EXIT prog_return;
            END;
        END IF;

        IF NOT (SUBSTRING(par_case_no, 1, 3) = ' HN' OR SUBSTRING(par_case_no, 1, 3) = ' AE') THEN
            SELECT
                'N'
                INTO var_valid_flag;
        END IF;

        IF var_valid_flag = 'N' THEN
            BEGIN
                SELECT
                    - 5
                    INTO var_return_error_code;
                SELECT
                    'Check for HN/AE Case no Only !'
                    INTO var_return_msg;
                EXIT prog_return;
            END;
        END IF;
        /* ----- THe Pacode will updated after adm_dtm */

        BEGIN
            SELECT
                patient_group
                INTO var_patient_gp
                FROM patient_type
                WHERE patient_type = var_patient_type::VARCHAR AND effective_dtm = (SELECT
                    MAX(effective_dtm)
                    FROM patient_type
                    WHERE patient_type = var_patient_type::VARCHAR AND
                    /* --and effective_dtm <= @adm_dtm)  ----- THe Pacode will updated after adm_dtm */
                    effective_dtm <= var_update_dtm);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_row_count := sql$rowcount;

        IF var_error <> 0 OR var_row_count = 0 THEN
            BEGIN
                SELECT
                    - 4
                    INTO var_return_error_code;
                SELECT
                    'Patient type not found!'
                    INTO var_return_msg;
                EXIT prog_return;
            END;
        END IF;
        /* 20110120 SL : 'SS' NOT for SFI */
        IF var_patient_type = 'SS' THEN
            SELECT
                NULL
                INTO var_patient_gp;
        END IF;
        SELECT
            0
            INTO var_return_error_code;
    END;
    OPEN p_refcur FOR
    SELECT
        var_patient_type, var_patient_gp, var_return_msg;
	return next p_refcur;

    RETURN;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_case_patient_gp" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

