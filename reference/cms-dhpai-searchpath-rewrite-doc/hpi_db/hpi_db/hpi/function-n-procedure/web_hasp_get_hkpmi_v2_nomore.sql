-- DROP FUNCTION hpi.web_hasp_get_hkpmi_v2_nomore(varchar, varchar, varchar, timestamp, timestamp, varchar, varchar, int4, int4);

CREATE OR REPLACE FUNCTION hpi.web_hasp_get_hkpmi_v2_nomore(par_hosp_code character varying, par_name character varying, par_sex character varying, par_from_dob timestamp without time zone, par_to_dob timestamp without time zone, par_last_name character varying, par_last_hkid character varying, par_authority_code integer, par_row_count integer DEFAULT 301)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    /* --@hosp_code	char(3), */
    var_temp_int INTEGER;
    pas_return_code INTEGER;
    p_refcur refcursor;
BEGIN
--    p_refcur := 'p_refcur';
    /* get hospital code */
    /* --select @hosp_code = Hospital_code from Hospital */
    /* process name & sex */
    SELECT
        CONCAT(RTRIM(par_name), '%'), CONCAT('[', RTRIM(par_sex), ']')
        INTO par_name, par_sex;
    raise notice 'par_row_count=% ',par_row_count;
    /* process user authority code */
    CALL cpi_get_int_by_bin(pas_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
    SELECT
        par_authority_code & var_temp_int
        INTO par_authority_code;
    /* Users do not input Age on the PSP screen */
       raise notice 'par_name=% par_sex=% par_authority_code=%',par_name,par_sex, par_authority_code;
    IF par_from_dob IS NULL THEN
        OPEN p_refcur FOR
        SELECT
            p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, c1.unicode_int AS unicode_int1, c2.unicode_int AS unicode_int2, c3.unicode_int AS unicode_int3, c4.unicode_int AS unicode_int4, c5.unicode_int AS unicode_int5, c6.unicode_int AS unicode_int6
            FROM cpi_patient AS p
            INNER JOIN cpi_patient_hospital_data AS h
                ON p.patient_key = h.patient_key
            LEFT OUTER JOIN ccc_unicode AS c1
                ON c1.ccc_head = SAFE_SUBSTRING(p.cccode1, 1, 4) AND c1.ccc_tail = SAFE_SUBSTRING(p.cccode1, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c2
                ON c2.ccc_head = SAFE_SUBSTRING(p.cccode2, 1, 4) AND c2.ccc_tail = SAFE_SUBSTRING(p.cccode2, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c3
                ON c3.ccc_head = SAFE_SUBSTRING(p.cccode3, 1, 4) AND c3.ccc_tail = SAFE_SUBSTRING(p.cccode3, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c4
                ON c4.ccc_head = SAFE_SUBSTRING(p.cccode4, 1, 4) AND c4.ccc_tail = SAFE_SUBSTRING(p.cccode4, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c5
                ON c5.ccc_head = SAFE_SUBSTRING(p.cccode5, 1, 4) AND c5.ccc_tail = SAFE_SUBSTRING(p.cccode5, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c6
                ON c6.ccc_head = SAFE_SUBSTRING(p.cccode6, 1, 4) AND c6.ccc_tail = SAFE_SUBSTRING(p.cccode6, 5, 1)
            WHERE p.patient_name LIKE par_name AND p.sex SIMILAR TO par_sex AND (p.access_code & par_authority_code) > 0 AND h.hospital_code = par_hosp_code
            /* PB version orders by patient key */
            /* order by p.patient_key */
            ORDER BY p.patient_name, p.hkid
            LIMIT par_row_count;
            RETURN NEXT p_refcur;
    ELSE
        /* Users input Age on the PSP screen, frontend calculates the DOB range from the Age */
        OPEN p_refcur FOR
        SELECT
            p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, c1.unicode_int AS unicode_int1, c2.unicode_int AS unicode_int2, c3.unicode_int AS unicode_int3, c4.unicode_int AS unicode_int4, c5.unicode_int AS unicode_int5, c6.unicode_int AS unicode_int6
            FROM cpi_patient AS p
            INNER JOIN cpi_patient_hospital_data AS h
                ON p.patient_key = h.patient_key
            LEFT OUTER JOIN ccc_unicode AS c1
                ON c1.ccc_head = SAFE_SUBSTRING(p.cccode1, 1, 4) AND c1.ccc_tail = SAFE_SUBSTRING(p.cccode1, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c2
                ON c2.ccc_head = SAFE_SUBSTRING(p.cccode2, 1, 4) AND c2.ccc_tail = SAFE_SUBSTRING(p.cccode2, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c3
                ON c3.ccc_head = SAFE_SUBSTRING(p.cccode3, 1, 4) AND c3.ccc_tail = SAFE_SUBSTRING(p.cccode3, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c4
                ON c4.ccc_head = SAFE_SUBSTRING(p.cccode4, 1, 4) AND c4.ccc_tail = SAFE_SUBSTRING(p.cccode4, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c5
                ON c5.ccc_head = SAFE_SUBSTRING(p.cccode5, 1, 4) AND c5.ccc_tail = SAFE_SUBSTRING(p.cccode5, 5, 1)
            LEFT OUTER JOIN ccc_unicode AS c6
                ON c6.ccc_head = SAFE_SUBSTRING(p.cccode6, 1, 4) AND c6.ccc_tail = SAFE_SUBSTRING(p.cccode6, 5, 1)
            WHERE p.patient_name LIKE par_name AND p.dob >= par_from_dob AND p.dob <= par_to_dob AND p.sex SIMILAR TO par_sex AND (p.access_code & par_authority_code) > 0 AND h.hospital_code = par_hosp_code
            /* PB version orders by patient key */
            /* order by p.patient_key */
            ORDER BY p.patient_name, p.hkid
            LIMIT par_row_count;
             RETURN NEXT p_refcur;
    END IF;
   
END;
/* END CREATE OR REPLACE PROCEDURE web_hasp_get_hkpmi_v2_nomore */
$function$
;


;ALTER FUNCTION "web_hasp_get_hkpmi_v2_nomore" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
