-- DROP PROCEDURE hkpmi.hkpmi_hago_get_chi_name_pua(inout int4, in bpchar, inout int4, inout int4, inout int4, inout int4, inout int4, inout int4, inout int4);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_get_chi_name_pua(INOUT pas_return_code integer, IN par_hkid varchar, INOUT par_chi_name_1 integer, 
INOUT par_chi_name_2 integer, INOUT par_chi_name_3 integer, INOUT par_chi_name_4 integer, INOUT par_chi_name_5 integer, INOUT par_chi_name_6 integer, INOUT par_is_pua integer)
 LANGUAGE plpgsql
AS $procedure$
/* 0 = false; 1 = true */
DECLARE
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
BEGIN
    /* --@inputNum	int */
    SELECT
        cccode1, cccode2, cccode3, cccode4, cccode5, cccode6
        INTO var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6
        FROM patient
        WHERE hkid = par_hkid;
    SELECT
        unicode_int
        INTO par_chi_name_1
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(var_cccode1, 1, 4) AND ccc_tail = SUBSTRING(var_cccode1, 5, 1);
    SELECT
        unicode_int
        INTO par_chi_name_2
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(var_cccode2, 1, 4) AND ccc_tail = SUBSTRING(var_cccode2, 5, 1);
    SELECT
        unicode_int
        INTO par_chi_name_3
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(var_cccode3, 1, 4) AND ccc_tail = SUBSTRING(var_cccode3, 5, 1);
    SELECT
        unicode_int
        INTO par_chi_name_4
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(var_cccode4, 1, 4) AND ccc_tail = SUBSTRING(var_cccode4, 5, 1);
    SELECT
        unicode_int
        INTO par_chi_name_5
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(var_cccode5, 1, 4) AND ccc_tail = SUBSTRING(var_cccode5, 5, 1);
    SELECT
        unicode_int
        INTO par_chi_name_6
        FROM ccc_unicode
        WHERE ccc_head = SUBSTRING(var_cccode6, 1, 4) AND ccc_tail = SUBSTRING(var_cccode6, 5, 1);
    /*
    E000-EFFF 	   57344-61439
    F000-FFFF 	   61440-65535
    F0000-10FFFF   983040-1114111
    F0000-FFFFF    983040-1048575
    100000-10FFFF  1048576-1114111
    
    E000-F8FF	   57344-63743
    F0000-FFFFD	   983040-1048573
    100000-10FFFD  1048576-1114109
    */
    /* SET @inputNum = 1114111 */
    par_is_pua := 0;

    IF (par_chi_name_1 >= 57344 AND par_chi_name_1 <= 63743) OR (par_chi_name_1 >= 983040 AND par_chi_name_1 <= 1048573) OR (par_chi_name_1 >= 1048576 AND par_chi_name_1 <= 1114109) THEN
        par_is_pua := 1;
    ELSE
        IF (par_chi_name_2 >= 57344 AND par_chi_name_2 <= 63743) OR (par_chi_name_2 >= 983040 AND par_chi_name_2 <= 1048573) OR (par_chi_name_2 >= 1048576 AND par_chi_name_2 <= 1114109) THEN
            par_is_pua := 1;
        ELSE
            IF (par_chi_name_3 >= 57344 AND par_chi_name_3 <= 63743) OR (par_chi_name_3 >= 983040 AND par_chi_name_3 <= 1048573) OR (par_chi_name_3 >= 1048576 AND par_chi_name_3 <= 1114109) THEN
                par_is_pua := 1;
            ELSE
                IF (par_chi_name_4 >= 57344 AND par_chi_name_4 <= 63743) OR (par_chi_name_4 >= 983040 AND par_chi_name_4 <= 1048573) OR (par_chi_name_4 >= 1048576 AND par_chi_name_4 <= 1114109) THEN
                    par_is_pua := 1;
                ELSE
                    IF (par_chi_name_5 >= 57344 AND par_chi_name_5 <= 63743) OR (par_chi_name_5 >= 983040 AND par_chi_name_5 <= 1048573) OR (par_chi_name_5 >= 1048576 AND par_chi_name_5 <= 1114109) THEN
                        par_is_pua := 1;
                    ELSE
                        IF (par_chi_name_6 >= 57344 AND par_chi_name_6 <= 63743) OR (par_chi_name_6 >= 983040 AND par_chi_name_6 <= 1048573) OR (par_chi_name_6 >= 1048576 AND par_chi_name_6 <= 1114109) THEN
                            par_is_pua := 1;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_get_chi_name_pua" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

