CREATE OR REPLACE FUNCTION hasp_get_user_profile_list()
 RETURNS SETOF refcursor
   LANGUAGE plpgsql
 AS $function$
DECLARE
    var_today TIMESTAMP WITHOUT TIME ZONE;
    p_refcur refcursor;
BEGIN
    SELECT timestamp_convert(localtimestamp)
    INTO var_today;

    OPEN p_refcur FOR
    SELECT
        User_ID, Name, HKID, Group_ID, Department, Rank_code, Authority_code, REPEAT(' ', 1) AS system_authority, REPEAT(' ', 1) AS user_authority, Effective_date, Expiration_date,
        CASE
            WHEN Effective_date <= var_today AND COALESCE(Expiration_date, 1 * INTERVAL '1 day' + var_today::TIMESTAMP) > var_today THEN 'Y'
            ELSE 'N'
        END AS Active_status, Email
        FROM User_profile
        WHERE Group_ID <> 'TRAINING' AND User_ID NOT LIKE '@%'
        ORDER BY User_ID NULLS FIRST;
    return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_get_user_profile_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
