-- DROP PROCEDURE hkpmi.cpi_address_build_long_key(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.cpi_address_build_long_key(INOUT pas_return_code integer, IN par_search_name character varying, INOUT par_long_key character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    SELECT REGEXP_REPLACE(UPPER(par_search_name), '[\s]', '', 'g')
    INTO par_search_name;

    /* Delete all the space and get the leftmost 24 characters */
    SELECT
        SAFE_SUBSTRING(par_search_name, 1, 24)
    INTO par_long_key;
END;
$procedure$
;


ALTER PROCEDURE "cpi_address_build_long_key" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

