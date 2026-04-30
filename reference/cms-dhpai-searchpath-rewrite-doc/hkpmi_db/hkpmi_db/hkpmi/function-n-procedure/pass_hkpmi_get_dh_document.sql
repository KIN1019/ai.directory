CREATE OR REPLACE FUNCTION pass_hkpmi_get_dh_document(IN par_ha_document_type VARCHAR, IN par_is_pseudo_id VARCHAR DEFAULT null)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_dh_document_type VARCHAR(5);

    p_refcur refcursor;
BEGIN
    IF par_is_pseudo_id = 'Y' THEN
        BEGIN
            SELECT
                CASE dh_pseudoid_document_type
                    WHEN NULL THEN dh_default_document_type
                    ELSE dh_pseudoid_document_type
                END
                INTO var_dh_document_type
                FROM ha_dh_document_type
                WHERE ha_document_type = par_ha_document_type AND effective_datetime <= timestamp_convert(localtimestamp)
                ORDER BY effective_datetime DESC NULLS FIRST
                LIMIT 1;

            IF var_dh_document_type IS NULL THEN
                BEGIN
                    SELECT
                        dh_default_document_type
                        INTO var_dh_document_type
                        FROM ha_dh_document_type
                        WHERE ha_document_type = 'OTHER' AND effective_datetime <= timestamp_convert(localtimestamp)
                        ORDER BY effective_datetime DESC NULLS FIRST
                        LIMIT 1;
                END;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT
                dh_default_document_type
                INTO var_dh_document_type
                FROM ha_dh_document_type
                WHERE ha_document_type = par_ha_document_type AND effective_datetime <= timestamp_convert(localtimestamp)
                ORDER BY effective_datetime DESC NULLS FIRST
                LIMIT 1;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        var_dh_document_type AS dh_document_type;
    return next p_refcur;
    RETURN;
END;
$function$
;


ALTER FUNCTION "pass_hkpmi_get_dh_document" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
