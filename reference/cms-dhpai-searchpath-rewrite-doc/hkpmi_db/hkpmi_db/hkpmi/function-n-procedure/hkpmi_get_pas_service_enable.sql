-- DROP FUNCTION hkpmi.hkpmi_get_pas_service_enable(bpchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_pas_service_enable(par_hospital_code VARCHAR DEFAULT NULL::VARCHAR, par_project_id character varying DEFAULT NULL::character varying, par_service_name character varying DEFAULT NULL::character varying, par_service_feature character varying DEFAULT NULL::character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    OPEN p_refcur FOR
    SELECT
        enable, hospital_code, database_type, project_id, service_type, service_name, service_feature
        FROM hkpmi_pas_service_breaker
        WHERE hospital_code = par_hospital_code AND project_id = par_project_id AND service_name = par_service_name AND (par_service_feature IS NULL OR service_feature = par_service_feature);
		return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_pas_service_enable" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

