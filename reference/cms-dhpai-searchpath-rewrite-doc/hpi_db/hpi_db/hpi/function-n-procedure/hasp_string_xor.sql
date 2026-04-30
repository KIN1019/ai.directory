-- DROP PROCEDURE hpi.hasp_string_xor(inout int4, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_string_xor(INOUT pas_return_code integer, IN par_str1 character varying, IN par_str2 character varying, INOUT par_outstr character varying)
 LANGUAGE plpgsql
AS $procedure$
/* Return values   Meaning */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_outstring VARCHAR(16);
    var_idx INTEGER;
BEGIN
    SELECT
        1, NULL
        INTO var_idx, var_outstring;

    WHILE var_idx <= OCTET_LENGTH(par_str1) LOOP
        SELECT
            CONCAT(var_outstring,
            CASE CAST (CASE
                WHEN ASCII(SUBSTRING(par_str1, var_idx, 1)) # ASCII(SUBSTRING(par_str2, var_idx, 1)) BETWEEN 1 AND 255 THEN CHR(ASCII(SUBSTRING(par_str1, var_idx, 1)) # ASCII(SUBSTRING(par_str2, var_idx, 1)))
                ELSE NULL
            END AS VARCHAR(01))
                WHEN '' THEN ''
                ELSE CAST (CASE
                    WHEN ASCII(SUBSTRING(par_str1, var_idx, 1)) # ASCII(SUBSTRING(par_str2, var_idx, 1)) BETWEEN 1 AND 255 THEN CHR(ASCII(SUBSTRING(par_str1, var_idx, 1)) # ASCII(SUBSTRING(par_str2, var_idx, 1)))
                    ELSE NULL
                END AS VARCHAR(01))
            END)
            INTO var_outstring;
        SELECT
            var_idx + 1
            INTO var_idx;
    END LOOP;
    SELECT
        var_outstring
        INTO par_outstr;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;
