-- DROP FUNCTION hkpmi.hkpmi_get_cms_case_by_caseno(bpchar, bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_cms_case_by_caseno(par_hospital_code varchar, par_case_no varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    OPEN p_refcur FOR
    SELECT
        hospital_code, case_no, patient_key, case_type, adm_dtm, source_indicator, source_code, patient_type, discharge_code, discharge_dtm, destination_code, adm_specialty_code, adm_ward_code, adm_ward_class, last_specialty_code, last_ward_code, last_ward_class, last_bed_no, pp_code, access_code, create_by, create_dtm, update_by, source_system_dtm, district, mrt_indicator, movement_count, security_count, row_update_datetime, source_system, filler
        FROM pmi_case
        WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
	return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_cms_case_by_caseno" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

