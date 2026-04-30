-- DROP PROCEDURE hpi.cpi_check_schi_name(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_check_schi_name(INOUT pas_return_code integer, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, INOUT par_is_schi_name character varying)
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


;ALTER PROCEDURE "cpi_check_schi_name" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
