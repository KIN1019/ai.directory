-- DROP PROCEDURE hkpmi.cpi_pq_validate_mrn(inout int4, in bpchar, in bpchar, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.cpi_pq_validate_mrn(INOUT pas_return_code integer, IN par_mrn VARCHAR, IN par_hospital_code VARCHAR, INOUT par_valid_flag VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
/*
Return values   Meaning
1               Format Error
2               Invalid check digit
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_check_sum INTEGER;
    var_check_digit VARCHAR(01);
    var_idx INTEGER;
    var_shift_factor INTEGER;
    var_ck_digit_str VARCHAR(36);
BEGIN
    SELECT
        'Y'
        INTO par_valid_flag;

    IF STRPOS(LTRIM(par_mrn), ' ') > 0 THEN
        BEGIN
            SELECT
                'N'
                INTO par_valid_flag;
            pas_return_code := 1;
            RETURN;
        END;
    END IF;
    SELECT
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        INTO var_ck_digit_str;
    SELECT
        shift_factor
        INTO var_shift_factor
        FROM hospital
        WHERE hospital_code = par_hospital_code;
    SELECT
        0
        INTO var_check_sum;
    SELECT
        8 - CHAR_LENGTH(LTRIM(par_mrn)) + 1
        INTO var_idx;

    WHILE var_idx <= 7 LOOP
        IF SUBSTRING(par_mrn, var_idx, 1) >= 'A' THEN
            SELECT
                var_check_sum + (ASCII(SUBSTRING(par_mrn, var_idx, 1)) - 55) * (11 - var_idx)
                INTO var_check_sum;
        ELSE
            SELECT
                var_check_sum + (ASCII(SUBSTRING(par_mrn, var_idx, 1)) - 48) * (11 - var_idx)
                INTO var_check_sum;
        END IF;
        SELECT
            var_idx + 1
            INTO var_idx;
    END LOOP;
    SELECT
        (((11 - var_check_sum % 11) % 11 + var_shift_factor) % 36) + 1
        INTO var_check_sum;
    SELECT
        SUBSTRING(var_ck_digit_str, var_check_sum, 1)
        INTO var_check_digit;

    IF var_check_digit != SUBSTRING(par_mrn, 8, 1) THEN
        BEGIN
            SELECT
                'N'
                INTO par_valid_flag;
            pas_return_code := 2;
            RETURN;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "cpi_pq_validate_mrn" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

