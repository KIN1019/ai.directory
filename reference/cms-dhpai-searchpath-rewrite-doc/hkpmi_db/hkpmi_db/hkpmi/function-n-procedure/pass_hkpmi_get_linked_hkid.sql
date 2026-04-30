CREATE OR REPLACE FUNCTION pass_hkpmi_get_linked_hkid(IN par_hkid VARCHAR, IN par_all_status VARCHAR DEFAULT null)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_pin VARCHAR(12);
    var_pin_len INTEGER;

    p_refcur refcursor;
BEGIN
    SELECT
        LTRIM(RTRIM(par_hkid))
        INTO var_pin;
    SELECT
        OCTET_LENGTH(var_pin)
        INTO var_pin_len;

    IF var_pin_len = 8 THEN
        SELECT
            CONCAT(' ', var_pin)
            INTO par_hkid;
    ELSE
        SELECT
            var_pin
            INTO par_hkid;
    END IF;
    OPEN p_refcur FOR
    SELECT
        LTRIM(RTRIM(link_hkid)), LTRIM(RTRIM(link_status)),
        CASE
            WHEN link_status = 'L' THEN 'Linked (unverified)'
            WHEN link_status = 'CS' THEN 'Patient Merged'
            WHEN link_status = 'CD' THEN 'Different Patient'
            WHEN link_status = 'PS' THEN 'Pending for Merge'
            WHEN link_status = 'DE' THEN 'Patient Deleted'
            WHEN link_status = 'RD' THEN 'Dead Patient'
            ELSE 'N/A'
        END AS link_status_desc,
        /* create_dtm, */
        (CASE
            WHEN create_dtm IS NOT NULL THEN CONCAT(to_char(create_dtm,'DD-MM-YYYY'), ' ', to_char(create_dtm,'HH24:MI:SS:MS'))
            ELSE NULL
        END) AS create_dtm, LTRIM(RTRIM(create_hospital)),
        /* create_user, */
        LTRIM(RTRIM(create_system)),
        /* update_dtm, */
        (CASE
            WHEN update_dtm IS NOT NULL THEN CONCAT(to_char(update_dtm,'DD-MM-YYYY'), ' ', to_char(update_dtm,'HH24:MI:SS:MS'))
            ELSE NULL
        END) AS update_dtm, LTRIM(RTRIM(update_hospital)),
        /* update_user, */
        LTRIM(RTRIM(update_system))
        FROM hkpmi_uid_table
        WHERE uid_hkid = par_hkid 
        -- AND (par_all_status = 'Y' OR link_status IN ('L', 'PS', 'CD'));
        AND link_status IN ('L', 'PS', 'CD');
    return next p_refcur;
    RETURN;
END;
$function$
;

ALTER FUNCTION "pass_hkpmi_get_linked_hkid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
