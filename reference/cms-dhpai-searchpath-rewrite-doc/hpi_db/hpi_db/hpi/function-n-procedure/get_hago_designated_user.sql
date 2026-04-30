-- DROP FUNCTION hpi.get_hago_designated_user(varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.get_hago_designated_user(par_hospital_code character varying, par_user_id character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_hago_designated_user VARCHAR(1);
    p_refcur refcursor;
BEGIN
    IF EXISTS (SELECT
        1
        FROM hago_designated_user
        WHERE hospital_code = par_hospital_code AND user_id = par_user_id) THEN
        BEGIN
            SELECT
                'Y'
                INTO var_hago_designated_user;
        END;
    ELSE
        BEGIN
            SELECT
                'N'
                INTO var_hago_designated_user;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        var_hago_designated_user;
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "get_hago_designated_user" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
