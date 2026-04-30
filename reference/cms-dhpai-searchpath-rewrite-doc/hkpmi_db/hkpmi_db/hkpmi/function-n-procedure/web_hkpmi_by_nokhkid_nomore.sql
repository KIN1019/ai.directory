-- DROP PROCEDURE hkpmi.web_hkpmi_by_nokhkid_nomore(inout int4, in varchar, in varchar, in varchar, in int4, in varchar, in int4, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi.web_hkpmi_by_nokhkid_nomore(INOUT pas_return_code integer, IN par_nok_hkid character varying, IN par_last_name character varying, IN par_last_hkid character varying, IN par_authority_code integer, IN par_hosp_code character varying, IN par_row_count integer DEFAULT 301, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    /* --@hosp_code	VARCHAR(3), */
    var_temp_int    INTEGER;
    var_return_code INTEGER;
BEGIN
    /* process user authority code */
    CALL hkpmi_get_int_by_bit(var_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
    SELECT par_authority_code & var_temp_int
    INTO par_authority_code;
    OPEN p_refcur FOR
        SELECT p.hkid,
               p.patient_name,
               p.sex,
               p.dob,
               h.mrn,
               p.phone1,
               c1.unicode_int AS unicode_int1,
               c2.unicode_int AS unicode_int2,
               c3.unicode_int AS unicode_int3,
               c4.unicode_int AS unicode_int4,
               c5.unicode_int AS unicode_int5,
               c6.unicode_int AS unicode_int6
        FROM patient p
                 JOIN
             nok n ON n.patient_key = p.patient_key
                 LEFT JOIN
             patient_hospital_data h ON p.patient_key = h.patient_key
                 LEFT JOIN
             ccc_unicode c1 ON c1.ccc_head = SAFE_SUBSTRING(p.cccode1, 1, 4) AND c1.ccc_tail = SAFE_SUBSTRING(p.cccode1, 5, 1)
                 LEFT JOIN
             ccc_unicode c2 ON c2.ccc_head = SAFE_SUBSTRING(p.cccode2, 1, 4) AND c2.ccc_tail = SAFE_SUBSTRING(p.cccode2, 5, 1)
                 LEFT JOIN
             ccc_unicode c3 ON c3.ccc_head = SAFE_SUBSTRING(p.cccode3, 1, 4) AND c3.ccc_tail = SAFE_SUBSTRING(p.cccode3, 5, 1)
                 LEFT JOIN
             ccc_unicode c4 ON c4.ccc_head = SAFE_SUBSTRING(p.cccode4, 1, 4) AND c4.ccc_tail = SAFE_SUBSTRING(p.cccode4, 5, 1)
                 LEFT JOIN
             ccc_unicode c5 ON c5.ccc_head = SAFE_SUBSTRING(p.cccode5, 1, 4) AND c5.ccc_tail = SAFE_SUBSTRING(p.cccode5, 5, 1)
                 LEFT JOIN
             ccc_unicode c6 ON c6.ccc_head = SAFE_SUBSTRING(p.cccode6, 1, 4) AND c6.ccc_tail = SAFE_SUBSTRING(p.cccode6, 5, 1)
        WHERE n.hkid = par_nok_hkid
          AND n.major_nok = 'Y'
          AND p.patient_name >= par_last_name
          AND (p.access_code & par_authority_code) > 0
          AND h.hospital_code = par_hosp_code
        ORDER BY p.patient_name, p.hkid
        limit par_row_count;

    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "web_hkpmi_by_nokhkid_nomore" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

