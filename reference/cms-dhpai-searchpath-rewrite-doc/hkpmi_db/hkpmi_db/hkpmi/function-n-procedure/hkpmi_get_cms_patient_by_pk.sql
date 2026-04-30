-- DROP FUNCTION hkpmi.hkpmi_get_cms_patient_by_pk(varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_cms_patient_by_pk(par_patient_key character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
BEGIN
    OPEN p_refcur FOR
    SELECT
        patient_key, religion, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_diagnosis, death_external_cause, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, row_update_datetime, filler, c1.unicode_int AS unicode_int1, c2.unicode_int AS unicode_int2, c3.unicode_int AS unicode_int3, c4.unicode_int AS unicode_int4, c5.unicode_int AS unicode_int5, c6.unicode_int AS unicode_int6
        FROM patient AS p
        LEFT OUTER JOIN ccc_unicode AS c1
            ON c1.ccc_head = SUBSTRING(p.cccode1, 1, 4) AND c1.ccc_tail = SUBSTRING(p.cccode1, 5, 1)
        LEFT OUTER JOIN ccc_unicode AS c2
            ON c2.ccc_head = SUBSTRING(p.cccode2, 1, 4) AND c2.ccc_tail = SUBSTRING(p.cccode2, 5, 1)
        LEFT OUTER JOIN ccc_unicode AS c3
            ON c3.ccc_head = SUBSTRING(p.cccode3, 1, 4) AND c3.ccc_tail = SUBSTRING(p.cccode3, 5, 1)
        LEFT OUTER JOIN ccc_unicode AS c4
            ON c4.ccc_head = SUBSTRING(p.cccode4, 1, 4) AND c4.ccc_tail = SUBSTRING(p.cccode4, 5, 1)
        LEFT OUTER JOIN ccc_unicode AS c5
            ON c5.ccc_head = SUBSTRING(p.cccode5, 1, 4) AND c5.ccc_tail = SUBSTRING(p.cccode5, 5, 1)
        LEFT OUTER JOIN ccc_unicode AS c6
            ON c6.ccc_head = SUBSTRING(p.cccode6, 1, 4) AND c6.ccc_tail = SUBSTRING(p.cccode6, 5, 1)
        WHERE patient_key = par_patient_key;
	RETURN NEXT p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_cms_patient_by_pk" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

