-- DROP FUNCTION hpi.cpi_get_case_w_pat_by_caseno(varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.cpi_get_case_w_pat_by_caseno(par_hospital_code character varying, par_case_no character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    pas_return_code INTEGER;
BEGIN
    --p_refcur := 'p_refcur';
    OPEN p_refcur FOR
    /* Case Information */
    SELECT
        c.hospital_code, c.case_no, c.patient_key, c.case_type, c.admission_dtm, c.source_indicator, c.source_code, c.patient_type, c.discharge_code, c.discharge_dtm, c.destination_code, c.last_specialty, c.last_sub_specialty, c.last_ward_code, c.last_ward_class, c.last_bed_no, c.access_code, c.status_code, c.create_by, c.create_dtm, c.update_by, c.update_dtm, c.movement_count, c.district_code, c.mrt_indicator, c.document_flag,
        /* Patient Information */
        /* SetMajorKey */
        p.hkid, p.patient_name, p.sex, p.dob, p.exact_dob_flag, p.cccode1 AS cccode1, p.cccode2 AS cccode2, p.cccode3 AS cccode3, p.cccode4 AS cccode4, p.cccode5 AS cccode5, p.cccode6 AS cccode6, c1.unicode_int AS Unicode_int1, c2.unicode_int AS Unicode_int2, c3.unicode_int AS Unicode_int3, c4.unicode_int AS Unicode_int4, c5.unicode_int AS Unicode_int5, c6.unicode_int AS Unicode_int6, p.access_code, p.body_category, p.card_holder, p.create_by, p.create_dtm, p.create_hospital, p.death_code, p.death_date, p.death_indicator, p.exact_dob_flag, p.phone1, p.patient_key, p.marital_status, p.phone2, p.address_indicator, p.other_doc_no, p.mobile_phone, p.sms_language, p.race, p.reference, p.religion, p.update_by, p.update_dtm, p.update_hospital, p.hkic_symbol
        FROM cpi_case AS c
        INNER JOIN cpi_patient AS p
            ON c.patient_key = p.patient_key
        LEFT OUTER JOIN ccc_unicode AS c1
            ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c2
            ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c3
            ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c4
            ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c5
            ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c6
            ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
        WHERE c.case_no = par_case_no AND c.hospital_code = par_hospital_code;
    RETURN NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "cpi_get_case_w_pat_by_caseno" OWNER TO "HPI_SCHEMA_OWNER_ROLE";