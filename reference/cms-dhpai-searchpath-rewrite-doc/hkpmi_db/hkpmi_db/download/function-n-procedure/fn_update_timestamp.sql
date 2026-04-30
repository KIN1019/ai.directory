-- DROP FUNCTION download.fn_update_timestamp();

CREATE OR REPLACE FUNCTION download.fn_update_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    new.row_update_datetime= current_timestamp::TIMESTAMP without TIME ZONE;
    return new;
end
$function$;

ALTER FUNCTION "fn_update_timestamp" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";