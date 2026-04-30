-- DROP FUNCTION hpi.ops_sys_get_whats_new_list(varchar);

CREATE OR REPLACE FUNCTION hpi.ops_sys_get_whats_new_list(par_hospital character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    pas_return_code INTEGER;
BEGIN
    OPEN p_refcur FOR
    SELECT
        a.hospital, a.message_id, a.message_type, a.message_header, a.message_start_date, a.message_new_period, COALESCE(b.message_content, '') AS message_content,
        CASE
            WHEN EXISTS (SELECT
                0
                FROM ipas_whats_new_message_dtl AS c
                WHERE c.hospital = a.hospital AND c.message_id = a.message_id AND c.message_line >= 1) THEN 'Y'
            ELSE 'N'
        END AS with_long_msg
        FROM ipas_whats_new_message_dtl AS b
        RIGHT OUTER JOIN ipas_whats_new_message AS a
            ON (b.hospital = a.hospital AND b.message_id = a.message_id AND b.message_line = 0)
        WHERE a.message_start_date <= localtimestamp AND (a.message_expiry_date IS NULL OR a.message_expiry_date > localtimestamp)
        ORDER BY 5 DESC NULLS FIRST, 2 DESC NULLS FIRST;
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "ops_sys_get_whats_new_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
