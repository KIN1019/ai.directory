-- DROP FUNCTION hkpmi.hkpmi_get_cms_cases_by_pk(varchar, varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_cms_cases_by_pk(par_hospital_code character varying, par_patient_key character varying, par_from timestamp without time zone, par_to timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    IF (par_from IS NULL) THEN
        SELECT
            '19000101'
            INTO par_from;
    END IF;

    IF (par_to IS NULL) THEN
        SELECT
            '19000101'
            INTO par_to;
    END IF;
    OPEN p_refcur FOR
    SELECT
        hospital_code, case_no, patient_key, case_type, adm_dtm, source_indicator, source_code, patient_type, discharge_code, discharge_dtm, destination_code, adm_specialty_code, adm_ward_code, adm_ward_class, last_specialty_code, last_ward_code, last_ward_class, last_bed_no, pp_code, access_code, create_by, create_dtm, update_by, source_system_dtm, district, mrt_indicator, movement_count, security_count, row_update_datetime, source_system, filler
        FROM pmi_case
        WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code AND (par_from = '19000101' OR adm_dtm >= par_from) AND (par_to = '19000101' OR adm_dtm <= par_to)
        ORDER BY discharge_dtm ASC NULLS FIRST, adm_dtm DESC NULLS FIRST;
	return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_cms_cases_by_pk" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

