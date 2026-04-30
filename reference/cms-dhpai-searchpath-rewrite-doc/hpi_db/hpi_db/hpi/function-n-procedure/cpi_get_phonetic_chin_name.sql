-- DROP PROCEDURE hpi.cpi_get_phonetic_chin_name(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_get_phonetic_chin_name(INOUT pas_return_code integer, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, INOUT par_phonetic_name character varying, INOUT par_chinese_name character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_ret_code INTEGER;
    var_ccc_unicode_1 VARCHAR(4);
    var_ccc_unicode_2 VARCHAR(4);
    var_ccc_unicode_3 VARCHAR(4);
    var_ccc_unicode_4 VARCHAR(4);
    var_ccc_unicode_5 VARCHAR(4);
    var_ccc_unicode_6 VARCHAR(4);
    var_phonetic_1 VARCHAR(12);
    var_phonetic_2 VARCHAR(12);
    var_phonetic_3 VARCHAR(12);
    var_phonetic_4 VARCHAR(12);
    var_phonetic_5 VARCHAR(12);
    var_phonetic_6 VARCHAR(12);
BEGIN
    SELECT
        unicode_char, phonetic_text
        INTO var_ccc_unicode_1, var_phonetic_1
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(par_ccc1, 1, 4) AND ccc_tail = SUBSTRING(par_ccc1, 5, 1);
    SELECT
        unicode_char, phonetic_text
        INTO var_ccc_unicode_2, var_phonetic_2
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(par_ccc2, 1, 4) AND ccc_tail = SUBSTRING(par_ccc2, 5, 1);
    SELECT
        unicode_char, phonetic_text
        INTO var_ccc_unicode_3, var_phonetic_3
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(par_ccc3, 1, 4) AND ccc_tail = SUBSTRING(par_ccc3, 5, 1);
    SELECT
        unicode_char, phonetic_text
        INTO var_ccc_unicode_4, var_phonetic_4
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(par_ccc4, 1, 4) AND ccc_tail = SUBSTRING(par_ccc4, 5, 1);
    SELECT
        unicode_char, phonetic_text
        INTO var_ccc_unicode_5, var_phonetic_5
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(par_ccc5, 1, 4) AND ccc_tail = SUBSTRING(par_ccc5, 5, 1);
    SELECT
        unicode_char, phonetic_text
        INTO var_ccc_unicode_6, var_phonetic_6
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(par_ccc6, 1, 4) AND ccc_tail = SUBSTRING(par_ccc6, 5, 1);
    SELECT
        CONCAT(RTRIM(var_phonetic_1), ', ')
        INTO par_phonetic_name;
    SELECT
        CONCAT(RTRIM(par_phonetic_name), ' ', var_phonetic_2)
        INTO par_phonetic_name;
    SELECT
        CONCAT(RTRIM(par_phonetic_name), ' ', var_phonetic_3)
        INTO par_phonetic_name;
    SELECT
        CONCAT(RTRIM(par_phonetic_name), ' ', var_phonetic_4)
        INTO par_phonetic_name;
    SELECT
        CONCAT(RTRIM(par_phonetic_name), ' ', var_phonetic_5)
        INTO par_phonetic_name;
    SELECT
        CONCAT(RTRIM(par_phonetic_name), ' ', var_phonetic_6)
        INTO par_phonetic_name;
    SELECT
        CONCAT(COALESCE(var_ccc_unicode_1, '  '), COALESCE(var_ccc_unicode_2, '  '), COALESCE(var_ccc_unicode_3, '  '), COALESCE(var_ccc_unicode_4, '  '), COALESCE(var_ccc_unicode_5, '  '), COALESCE(var_ccc_unicode_6, '  '))
        INTO par_chinese_name;

    IF par_chinese_name = REPEAT(' ', 12) THEN
        SELECT
            NULL
            INTO par_chinese_name;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_get_phonetic_chin_name" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
