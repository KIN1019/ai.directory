-- DROP PROCEDURE hkpmi.hkpmi_check_schi_name(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, inout bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_check_schi_name(INOUT pas_return_code integer, IN par_ccc1 VARCHAR, IN par_ccc2 VARCHAR, IN par_ccc3 VARCHAR, IN par_ccc4 VARCHAR, IN par_ccc5 VARCHAR, IN par_ccc6 VARCHAR, INOUT par_is_schi_name VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    IF SUBSTRING(COALESCE(par_ccc1, '     '), 5, 1) = 'S' OR SUBSTRING(COALESCE(par_ccc2, '     '), 5, 1) = 'S' OR SUBSTRING(COALESCE(par_ccc3, '     '), 5, 1) = 'S' OR SUBSTRING(COALESCE(par_ccc4, '     '), 5, 1) = 'S' OR SUBSTRING(COALESCE(par_ccc5, '     '), 5, 1) = 'S' OR SUBSTRING(COALESCE(par_ccc6, '     '), 5, 1) = 'S' THEN
        SELECT
            'Y'
            INTO par_is_schi_name;
    ELSE
        SELECT
            'N'
            INTO par_is_schi_name;
    END IF;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_check_schi_name" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

