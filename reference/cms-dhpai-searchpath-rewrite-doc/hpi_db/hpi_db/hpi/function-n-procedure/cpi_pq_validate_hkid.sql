-- DROP PROCEDURE hpi.cpi_pq_validate_hkid(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_pq_validate_hkid(INOUT pas_return_code integer, IN par_hkid character varying, INOUT par_valid_flag character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_char_part VARCHAR(2);
    var_num_part VARCHAR(6);
    var_check_sum INTEGER;
    var_check_digit VARCHAR(01);
    var_idx INTEGER;
BEGIN
    SELECT
        'Y'
        INTO par_valid_flag;

    IF CHAR_LENGTH(RTRIM(par_hkid)) != 9 THEN
        BEGIN
            SELECT
                'N'
                INTO par_valid_flag;
            pas_return_code := 1;
            RETURN;
        END;
    END IF;

    IF SUBSTRING(par_hkid, 2, 1) = ' ' OR (SUBSTRING(par_hkid, 2, 1) >= '0' AND SUBSTRING(par_hkid, 2, 1) <= '9') OR STRPOS(SUBSTRING(par_hkid, 3, 6), ' ') > 0 THEN
        BEGIN
            SELECT
                'N'
                INTO par_valid_flag;
            pas_return_code := 1;
            RETURN;
        END;
    END IF;
    SELECT
        0
        INTO var_check_sum;

    IF SUBSTRING(par_hkid, 1, 1) = ' ' THEN
        SELECT
            var_check_sum + 36 * 9
            INTO var_check_sum;
    ELSE
        SELECT
            var_check_sum + (ASCII(SUBSTRING(par_hkid, 1, 1)) - 55) * 9
            INTO var_check_sum;
    END IF;
    SELECT
        var_check_sum + (ASCII(SUBSTRING(par_hkid, 2, 1)) - 55) * 8
        INTO var_check_sum;
    SELECT
        3
        INTO var_idx;

    WHILE var_idx <= 8 LOOP
        SELECT
            var_check_sum + CAST (SUBSTRING(par_hkid, var_idx, 1) AS INTEGER) * (10 - var_idx)
            INTO var_check_sum;
        SELECT
            var_idx + 1
            INTO var_idx;
    END LOOP;
    SELECT
        11 - var_check_sum % 11
        INTO var_check_sum;

    IF var_check_sum = 11 THEN
        SELECT
            '0'
            INTO var_check_digit;
    ELSE
        IF var_check_sum = 10 THEN
            SELECT
                'A'
                INTO var_check_digit;
        ELSE
            SELECT
                CAST (var_check_sum AS VARCHAR(01))
                INTO var_check_digit;
        END IF;
    END IF;

    IF var_check_digit != SUBSTRING(par_hkid, 9, 1) THEN
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


;ALTER PROCEDURE "cpi_pq_validate_hkid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
