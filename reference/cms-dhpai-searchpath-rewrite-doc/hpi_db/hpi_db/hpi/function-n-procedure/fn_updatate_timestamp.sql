CREATE OR REPLACE FUNCTION hpi.fn_updatate_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    new.row_update_datetime = current_timestamp::TIMESTAMP WITHOUT TIME ZONE;
    RETURN new;
END;
$function$
;

-- DROP FUNCTION hpi.fn_update_timestamp();


;ALTER FUNCTION "fn_updatate_timestamp" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
