-- DROP FUNCTION hkpmi_get_patient_language(varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi_get_patient_language(par_hkid character varying, par_patient_key character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
begin
	
    OPEN p_refcur FOR
    SELECT
        p.hkid, l.patient_key, l.language_code, i.language, l.status, l.source_system, l.update_hospital, l.update_datetime, l.update_by
        FROM hkpmi_patient_language AS l, patient AS p, interpretation_language AS i
        WHERE l.patient_key = par_patient_key AND p.hkid = par_hkid AND l.patient_key = p.patient_key AND l.language_code = i.language_code AND l.status = 'A';
	return next p_refcur;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_patient_language" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

