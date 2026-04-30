-- DROP PROCEDURE cpi_address_build_short_key(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_address_build_short_key(INOUT pas_return_code integer, IN par_search_name character varying, INOUT par_short_key character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    words text[];
    word1 VARCHAR(50) := '      ';
    word2 VARCHAR(50) := '      ';
    word3 VARCHAR(50) := '      ';
BEGIN

    par_short_key := '';

    IF par_search_name IS NULL OR par_search_name = '' THEN
        RETURN;
    END IF;
    
    words := regexp_split_to_array(TRIM(UPPER(par_search_name)), '\s+');
    
    IF array_length(words, 1) >= 1 THEN word1 := words[1]; END IF;
    IF array_length(words, 1) >= 2 THEN word2 := words[2]; END IF;
    IF array_length(words, 1) >= 3 THEN word3 := words[3]; END IF;

    par_short_key := 
        COALESCE(SUBSTRING(word1, 1, 2), '') ||
        COALESCE(SUBSTRING(word2, 1, 1), '') ||
        COALESCE(SUBSTRING(word3, 1, 1), '') ||
        COALESCE(SUBSTRING(word1, 3, 1), '') ||
        COALESCE(SUBSTRING(word2, 2, 1), '') ||
        COALESCE(SUBSTRING(word3, 2, 1), '');

END;
$procedure$
;

;ALTER PROCEDURE "cpi_address_build_short_key" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
