-- DROP PROCEDURE hpi.hasp_sys_decode(inout int4, in bytea, in bytea, in bytea, in bytea, in bytea, in bytea, in bytea, in bytea, inout varchar, in bytea, in bytea, in bytea, in bytea);

CREATE OR REPLACE PROCEDURE hpi.hasp_sys_decode(INOUT pas_return_code integer, IN par_decoded_code1 bytea, IN par_decoded_code2 bytea, IN par_decoded_code3 bytea, IN par_decoded_code4 bytea, IN par_decoded_code5 bytea, IN par_decoded_code6 bytea, IN par_decoded_code7 bytea, IN par_decoded_code8 bytea, INOUT par_code character varying, IN par_decoded_code9 bytea DEFAULT NULL::bytea, IN par_decoded_code10 bytea DEFAULT NULL::bytea, IN par_decoded_code11 bytea DEFAULT NULL::bytea, IN par_decoded_code12 bytea DEFAULT NULL::bytea)
 LANGUAGE plpgsql
AS $procedure$
/*
20101122 SL : for User_profile.HKID  - same as ops_sys_decode
* same for CPI/HPI
*/
/* 2008-11-25 Pui Yee SMR20016989 Enhancement on OPAS for case of HKID collection for OPAS CUID Implementation */
/* End - SMR20016989 */
DECLARE
    var_code1 VARCHAR(2);
    var_code2 VARCHAR(2);
    var_code3 VARCHAR(2);
    var_code4 VARCHAR(2);
    var_code5 VARCHAR(2);
    var_code6 VARCHAR(2);
    var_code7 VARCHAR(2);
    var_code8 VARCHAR(2);
    /* 2008-11-25 Pui Yee SMR20016989 Enhancement on OPAS for case of HKID collection for OPAS CUID Implementation */
    var_code9 VARCHAR(2);
    var_code10 VARCHAR(2);
    var_code11 VARCHAR(2);
    var_code12 VARCHAR(2);
BEGIN
    /* End - SMR20016989 */
    /* 2004-03-31 Noel Chan SMR20012235 SQL 2000 Backend Upgrade - Enhanced for Empty string behavior change - Start */
    /*
    select @code1 = VARCHAR(convert(int, @decoded_code1) -10)
    select @code2 = VARCHAR(convert(int, @decoded_code3) +10)
    select @code3 = VARCHAR(convert(int, @decoded_code5) -20)
    select @code4 = VARCHAR(convert(int, @decoded_code7) +20)
    select @code5 = VARCHAR(convert(int, @decoded_code2) -15)
    select @code6 = VARCHAR(convert(int, @decoded_code4) +15)
    select @code7 = VARCHAR(convert(int, @decoded_code6) -25)
    select @code8 = VARCHAR(convert(int, @decoded_code8) +25)
    */
    IF par_decoded_code1 IS NULL THEN
        SELECT
            ''
            INTO var_code1;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code1 AS INTEGER) - 10 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code1 AS INTEGER) - 10)
                ELSE NULL
            END, ' ')
            INTO var_code1;
    END IF;

    IF par_decoded_code3 IS NULL THEN
        SELECT
            ''
            INTO var_code2;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code3 AS INTEGER) + 10 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code3 AS INTEGER) + 10)
                ELSE NULL
            END, ' ')
            INTO var_code2;
    END IF;

    IF par_decoded_code5 IS NULL THEN
        SELECT
            ''
            INTO var_code3;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code5 AS INTEGER) - 20 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code5 AS INTEGER) - 20)
                ELSE NULL
            END, ' ')
            INTO var_code3;
    END IF;

    IF par_decoded_code7 IS NULL THEN
        SELECT
            ''
            INTO var_code4;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code7 AS INTEGER) + 20 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code7 AS INTEGER) + 20)
                ELSE NULL
            END, ' ')
            INTO var_code4;
    END IF;

    IF par_decoded_code2 IS NULL THEN
        SELECT
            ''
            INTO var_code5;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code2 AS INTEGER) - 15 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code2 AS INTEGER) - 15)
                ELSE NULL
            END, ' ')
            INTO var_code5;
    END IF;

    IF par_decoded_code4 IS NULL THEN
        SELECT
            ''
            INTO var_code6;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code4 AS INTEGER) + 15 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code4 AS INTEGER) + 15)
                ELSE NULL
            END, ' ')
            INTO var_code6;
    END IF;

    IF par_decoded_code6 IS NULL THEN
        SELECT
            ''
            INTO var_code7;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code6 AS INTEGER) - 25 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code6 AS INTEGER) - 25)
                ELSE NULL
            END, ' ')
            INTO var_code7;
    END IF;

    IF par_decoded_code6 IS NULL THEN
        SELECT
            ''
            INTO var_code8;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code8 AS INTEGER) + 25 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code8 AS INTEGER) + 25)
                ELSE NULL
            END, ' ')
            INTO var_code8;
    END IF;
    /* 2004-03-31 Noel Chan SMR20012235 SQL 2000 Backend Upgrade - Enhanced for Empty string behavior change - End */
    /* 2008-11-25 Pui Yee SMR20016989 Enhancement on OPAS for case of HKID collection for OPAS CUID Implementation */
    IF par_decoded_code9 IS NULL THEN
        SELECT
            ''
            INTO var_code9;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code9 AS INTEGER) + 0 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code9 AS INTEGER) + 0)
                ELSE NULL
            END, ' ')
            INTO var_code9;
    END IF;

    IF par_decoded_code10 IS NULL THEN
        SELECT
            ''
            INTO var_code10;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code10 AS INTEGER) + 0 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code10 AS INTEGER) + 0)
                ELSE NULL
            END, ' ')
            INTO var_code10;
    END IF;

    IF par_decoded_code11 IS NULL THEN
        SELECT
            ''
            INTO var_code11;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code11 AS INTEGER) + 0 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code11 AS INTEGER) + 0)
                ELSE NULL
            END, ' ')
            INTO var_code11;
    END IF;

    IF par_decoded_code12 IS NULL THEN
        SELECT
            ''
            INTO var_code12;
    ELSE
        SELECT
            COALESCE(CASE
                WHEN CAST (par_decoded_code12 AS INTEGER) + 0 BETWEEN 1 AND 255 THEN CHR(CAST (par_decoded_code12 AS INTEGER) + 0)
                ELSE NULL
            END, ' ')
            INTO var_code12;
    END IF;
    SELECT
        CONCAT(var_code1, var_code2, var_code3, var_code4, var_code5, var_code6, var_code7, var_code8, var_code9, var_code10, var_code11, var_code12)
        INTO par_code;
    /* End - SMR20016989 */
END;
$procedure$
;
