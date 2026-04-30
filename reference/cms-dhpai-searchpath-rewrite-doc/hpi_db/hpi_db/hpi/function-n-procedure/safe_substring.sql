-- DROP FUNCTION hpi.safe_substring(text, int4, int4);

CREATE OR REPLACE FUNCTION hpi.safe_substring(str text, start integer, length integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN CASE 
        WHEN length(substring(str, start, length)) = 0 THEN NULL
        ELSE substring(str, start, length)
    END;
END;
$function$
;


;ALTER FUNCTION "safe_substring" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
