-- DROP FUNCTION hpi.web_get_wl_user_auth_by_id(varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.web_get_wl_user_auth_by_id(par_hosp_code character varying, par_user_id character varying, par_whitelist_type character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    pas_return_code INTEGER;
    var_error_msg CHAR(100);
    var_return_code INTEGER;
BEGIN
    BEGIN
        IF NOT EXISTS (SELECT
            hosp_code
            FROM pas_func_whitelist
            WHERE hosp_code = par_hosp_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND control_value = 'Y' LIMIT 1)  THEN
            BEGIN
                SELECT
                    'User ID is not exist'
                    INTO var_error_msg;
                SELECT
                    19999
                    INTO var_return_code;
                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := var_return_code;
                /* pas_return_code := var_return_code; */
            END;
        ELSE
            BEGIN
                OPEN p_refcur FOR
                SELECT DISTINCT
                    func_id
                    FROM pas_func_whitelist_group
                    WHERE hosp_code = par_hosp_code AND whitelist_group IN (SELECT
                        whitelist_group
                        FROM pas_func_whitelist
                        WHERE hosp_code = par_hosp_code AND user_id = par_user_id AND whitelist_type = par_whitelist_type AND control_value = 'Y')
                    ORDER BY func_id NULLS FIRST;
                /* pas_return_code := 0; */
                RETURN NEXT p_refcur;
            END;
        END IF;
    END;
END;
$function$
;


;ALTER FUNCTION "web_get_wl_user_auth_by_id" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
