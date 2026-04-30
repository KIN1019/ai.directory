-- DROP FUNCTION fn_external_service_config_up_tri();

CREATE OR REPLACE FUNCTION fn_external_service_config_up_tri()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* -------------------------------------------------------- */
/* DROP TRIGGER external_service_config_up_tri */
BEGIN
    IF pg_trigger_depth() <> 1 THEN
        RETURN NULL;
    END IF;
    UPDATE external_service_config
    SET update_datetime = timestamp_convert(localtimestamp)
    FROM inserted
        WHERE external_service_config.project = inserted.project AND external_service_config.service = inserted.service AND external_service_config.config_key = inserted.config_key;
    RETURN NULL;
END;
$function$
;

;ALTER FUNCTION "fn_external_service_config_up_tri" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
