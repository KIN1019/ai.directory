-- DROP FUNCTION hkpmi_get_patient_ehr_by_hkid(bpchar);

CREATE OR REPLACE FUNCTION hkpmi_get_patient_ehr_by_hkid(par_hkid varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
BEGIN
   
    OPEN p_refcur FOR
    SELECT
        p.patient_key, ehr.ehr_number
        FROM ehr_patient_list AS ehr
        RIGHT OUTER JOIN patient AS p
            ON (ehr.pas_hkic = p.hkid AND ehr.ehr_ppi_ind = 'Y')
        WHERE p.hkid = par_hkid AND ehr.ehr_flag IN ('VAL', 'MKU', 'MKC', 'MKE', 'MKP', 'MKM', 'MES');
    RETURN NEXT p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_patient_ehr_by_hkid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

