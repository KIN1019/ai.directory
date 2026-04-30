-- DROP PROCEDURE hkpmi.hkpmi_hago_get_chi_name(inout int4, in bpchar, inout int4, inout int4, inout int4, inout int4, inout int4, inout int4);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_hago_get_chi_name(INOUT pas_return_code integer, IN par_hkid varchar, 
INOUT par_chi_name_1 integer, INOUT par_chi_name_2 integer, INOUT par_chi_name_3 integer, INOUT par_chi_name_4 integer, INOUT par_chi_name_5 integer, INOUT par_chi_name_6 integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
BEGIN
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
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_hago_get_chi_name" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

