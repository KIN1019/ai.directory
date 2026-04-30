-- DROP PROCEDURE hpi.hasp_get_phonetic_chin_name(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_phonetic_chin_name(INOUT pas_return_code integer, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, INOUT par_phonetic_name character varying, INOUT par_chinese_name character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
var_ret_code INTEGER;
    var_big5_1 VARCHAR(02);
    var_big5_2 VARCHAR(02);
    var_big5_3 VARCHAR(02);
    var_big5_4 VARCHAR(02);
    var_big5_5 VARCHAR(02);
    var_big5_6 VARCHAR(02);
    var_phonetic_1 VARCHAR(06);
    var_phonetic_2 VARCHAR(06);
    var_phonetic_3 VARCHAR(06);
    var_phonetic_4 VARCHAR(06);
    var_phonetic_5 VARCHAR(06);
    var_phonetic_6 VARCHAR(06);
BEGIN
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,
    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend
    /* unicode_char */null, Phonetic_text
INTO var_big5_1, var_phonetic_1
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(par_ccc1, 1, 4) AND CCC_tail = SUBSTRING(par_ccc1, 5, 1);
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,
    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend
    /* unicode_char */null, Phonetic_text
INTO var_big5_2, var_phonetic_2
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(par_ccc2, 1, 4) AND CCC_tail = SUBSTRING(par_ccc2, 5, 1);
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,
    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend
    /* unicode_char */null, Phonetic_text
INTO var_big5_3, var_phonetic_3
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(par_ccc3, 1, 4) AND CCC_tail = SUBSTRING(par_ccc3, 5, 1);
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,
    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend
    /* unicode_char */null, Phonetic_text
INTO var_big5_4, var_phonetic_4
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(par_ccc4, 1, 4) AND CCC_tail = SUBSTRING(par_ccc4, 5, 1);
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,
    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend
    /* unicode_char */null, Phonetic_text
INTO var_big5_5, var_phonetic_5
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(par_ccc5, 1, 4) AND CCC_tail = SUBSTRING(par_ccc5, 5, 1);
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,
    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend
    /* unicode_char */null, Phonetic_text
INTO var_big5_6, var_phonetic_6
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(par_ccc6, 1, 4) AND CCC_tail = SUBSTRING(par_ccc6, 5, 1);
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
	-- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,
    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend
    /*CONCAT(COALESCE(var_big5_1, '  '), COALESCE(var_big5_2, '  '), COALESCE(var_big5_3, '  '), COALESCE(var_big5_4, '  '), COALESCE(var_big5_5, '  '), COALESCE(var_big5_6, '  '))*/
	'' -- Return empty string instead of null to avoid impact on caller or app frontend
INTO par_chinese_name;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_phonetic_chin_name" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
