-- DROP FUNCTION hkpmi.fn_update_timestamp();

CREATE OR REPLACE FUNCTION hkpmi.fn_update_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    new.row_update_datetime= current_timestamp::TIMESTAMP without TIME ZONE;
    return new;
end
$function$
;


ALTER FUNCTION "fn_update_timestamp" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

