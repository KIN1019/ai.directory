-- DROP FUNCTION hkpmi.ehr_get_all_user();

CREATE OR REPLACE FUNCTION hkpmi.ehr_get_all_user()
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    OPEN p_refcur FOR
    SELECT
        user_id, create_dtm
        FROM ehr_user_table
        ORDER BY user_id NULLS FIRST;
	return next p_refcur;
    RETURN;
END;
$function$
;


ALTER FUNCTION "ehr_get_all_user" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

