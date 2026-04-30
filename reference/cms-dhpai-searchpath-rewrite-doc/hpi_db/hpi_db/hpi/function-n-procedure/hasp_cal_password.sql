CREATE OR REPLACE PROCEDURE hasp_cal_password(INOUT pas_return_code int, IN par_user_id VARCHAR, INOUT par_password VARCHAR)
AS 
$BODY$
/* Return values   Meaning */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_tempstr VARCHAR(16);
    var_keylength INTEGER;
    var_idx INTEGER;
    var_checksum INTEGER;
    var_random_str VARCHAR(90);
BEGIN
    SELECT
        1, 17, 'ADT repostion - Password calculation routine.'
        INTO var_idx, var_checksum, var_random_str;

    WHILE var_idx <= CHAR_LENGTH(LTRIM(RTRIM(par_user_id))) LOOP
        SELECT
            var_checksum + ASCII(SUBSTRING(LTRIM(RTRIM(par_user_id)), var_idx, 1)) * (2 * var_idx - 1)
            INTO var_checksum;
        SELECT
            var_idx + 1
            INTO var_idx;
    END LOOP;
    SELECT
        (var_checksum % 8) + 1
        INTO var_keylength;
    SELECT
        0
        INTO var_idx;

    WHILE var_idx < 4 LOOP
        SELECT
            SUBSTRING(var_random_str, (var_idx * 8 + var_keylength), 8)
            INTO var_tempstr;
        CALL hasp_string_xor(pas_return_code, var_tempstr, par_password, par_password);
        SELECT
            var_idx + 1
            INTO var_idx;
    END LOOP;
    pas_return_code := 0;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;