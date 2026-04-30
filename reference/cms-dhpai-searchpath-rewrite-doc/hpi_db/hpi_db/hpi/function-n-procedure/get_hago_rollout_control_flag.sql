-- DROP FUNCTION hpi.get_hago_rollout_control_flag(varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.get_hago_rollout_control_flag(par_hospital_code character varying, par_workstation_id character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
BEGIN
    --p_refcur := 'p_refcur';
    OPEN p_refcur FOR
    SELECT
        RTRIM(hospital_code), workstation_id, rollout_control_flag, rollout_ready
        FROM hago_rollout_control
        WHERE workstation_id IN ('ALL', par_workstation_id) AND hospital_code = par_hospital_code;
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "get_hago_rollout_control_flag" OWNER TO "HPI_SCHEMA_OWNER_ROLE";