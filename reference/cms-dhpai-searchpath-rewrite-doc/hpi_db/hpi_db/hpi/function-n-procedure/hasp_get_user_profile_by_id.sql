-- DROP FUNCTION hpi.hasp_get_user_profile_by_id(varchar);

CREATE OR REPLACE FUNCTION hasp_get_user_profile_by_id(par_user_id character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    pas_return_code INTEGER;
BEGIN
    OPEN p_refcur FOR
    SELECT
        u.User_ID, u.Group_ID, u.Password u_password, u.Department, u.Name, u.Authority_code, u.Expiration_date, u.Effective_date, u.Rank_code, u.Menu, u.DT_security_code, u.Hospital_code, u.HKID, u.User_title, u.DT_enable_flag, u.DT_effective_date, u.DT_expiration_date, u.Password_expiration_date, u.Password_retry_count, u.cuid_flag, u.Email, p.password p_password, p.update_datetime, p.last_updated_by, p.last_update_status
        FROM User_profile AS u
        LEFT OUTER JOIN (SELECT
            hospital_code, user_id, password, update_datetime, last_updated_by, last_update_status
            FROM User_password
            WHERE user_id = par_user_id) AS p
            ON p.hospital_code = u.Hospital_code AND p.user_id = u.User_ID
        WHERE u.User_ID = par_user_id
        ORDER BY p.update_datetime DESC NULLS FIRST;
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "hasp_get_user_profile_by_id" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
