CREATE OR REPLACE FUNCTION web_get_cms_patient_list(IN par_hospital_code VARCHAR, IN par_ward_code VARCHAR)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
DECLARE
	p_refcur refcursor;
BEGIN
    open p_refcur for select
    w.bed_no, w.case_no, w.specialty_code, w.ward_code,
    p.t_prk patient_key, p.hkid, p.name, p.sex, p.dob, p.exact_dob_flag,
    p.ccc_1 cccode1, p.ccc_2 cccode2, p.ccc_3 cccode3, p.ccc_4 cccode4, p.ccc_5 cccode5, p.ccc_6 cccode6,
    c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
    c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6,
    p.medical_record_number mrn,
    c.admission_datetime, c.discharge_code, c.discharge_datetime, c.case_type,
    p.death_indicator, p.death_date
    from pmi p
		INNER JOIN adt_case AS c on c.t_prk = p.t_prk
		INNER JOIN ward_list as w on w.case_no = c.case_no
		LEFT OUTER JOIN ccc_unicode AS c1 ON SUBSTRING(p.ccc_1, 1, 4) = c1.ccc_head AND SUBSTRING(p.ccc_1, 5, 1) = c1.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c2 ON SUBSTRING(p.ccc_2, 1, 4) = c2.ccc_head AND SUBSTRING(p.ccc_2, 5, 1) = c2.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c3 ON SUBSTRING(p.ccc_3, 1, 4) = c3.ccc_head AND SUBSTRING(p.ccc_3, 5, 1) = c3.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c4 ON SUBSTRING(p.ccc_4, 1, 4) = c4.ccc_head AND SUBSTRING(p.ccc_4, 5, 1) = c4.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c5 ON SUBSTRING(p.ccc_5, 1, 4) = c5.ccc_head AND SUBSTRING(p.ccc_5, 5, 1) = c5.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c6 ON SUBSTRING(p.ccc_6, 1, 4) = c6.ccc_head AND SUBSTRING(p.ccc_6, 5, 1) = c6.ccc_tail
    where w.hospital_code = par_hospital_code
    and w.ward_code = par_ward_code;

    RETURN NEXT p_refcur;
END;
$function$;