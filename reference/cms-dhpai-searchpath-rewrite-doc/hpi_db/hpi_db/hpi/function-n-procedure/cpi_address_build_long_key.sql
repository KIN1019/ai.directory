-- DROP PROCEDURE cpi_address_build_long_key(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_address_build_long_key(INOUT pas_return_code integer, IN par_search_name character varying, INOUT par_long_key character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    IF par_search_name IS NULL THEN
        par_long_key := NULL;
        RETURN;
    END IF;
    
    par_long_key := SUBSTRING(REGEXP_REPLACE(UPPER(par_search_name), '\s', '', 'g'), 1, 24);
END;
$procedure$
;


;ALTER PROCEDURE "cpi_address_build_long_key" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
