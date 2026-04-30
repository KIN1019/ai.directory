-- DROP FUNCTION hkpmi.hkpmi_get_patcase_by_caseno(varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_patcase_by_caseno(par_hospital_code character varying, par_case_no character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	 p_refcur refcursor;
BEGIN
open p_refcur for
select
    p.patient_key,
    p.religion,
    p.hkid,
    p.patient_name,
    p.sex,
    p.cccode1,
    p.cccode2,
    p.cccode3,
    p.cccode4,
    p.cccode5,
    p.cccode6,
    p.chi_name,
    p.dob,
    p.exact_dob_flag,
    p.marital_status,
    p.race,
    p.other_doc_no,
    p.building,
    p.room,
    p.floor,
    p.block,
    p.district,
    p.phone1,
    p.phone2,
    p.address_indicator,
    p.mobile_phone,
    p.sms_language,
    p.death_indicator,
    p.death_date,
    p.death_diagnosis,
    p.death_external_cause,
    p.patient_type,
    p.pcs_count,
    p.access_code,
    p.update_hospital,
    p.source_system,
    p.update_by ,
    p.source_system_dtm,
    p.system_dtm,
    p.row_update_datetime,
    p.filler,
    c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
    c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6,
    --Major NOK
    n.patient_key as patient_key2  ,
    n.priority,
    n.major_nok,
    n.hkid as hkid2,
    n.relationship,
    n.nok_name,
    n.building as building2,
    n.room as room2,
    n.floor as floor2,
    n.block as block2,
    n.district as  district2,
    n.phone1 as phone1_2 ,
    n.phone2 as phone2_2,
    n.address_indicator as address_indicator2,
    n.mobile_phone as mobile_phone2,
    n.sms_language as sms_language2,
    n.update_hospital as update_hospital2,
    n.update_by as update_by_2,
    n.source_system_dtm as source_system_dtm2,
    n.row_update_datetime as row_update_datetime2,
    --Case
    c.hospital_code,
    c.case_no,
    c.patient_key as patient_key3,
    c.case_type,
    c.adm_dtm,
    c.source_indicator,
    c.source_code,
    c.patient_type as patient_type2,
    c.discharge_code,
    c.discharge_dtm,
    c.destination_code,
    c.adm_specialty_code,
    c.adm_ward_code,
    c.adm_ward_class,
    c.last_specialty_code,
    c.last_ward_code,
    c.last_ward_class,
    c.last_bed_no,
    c.pp_code,
    c.access_code as access_code2 ,
    c.create_by,
    c.create_dtm,
    c.update_by as update_by_3,
    c.source_system_dtm as source_system_dtm3,
    c.district as district3,
    c.mrt_indicator,
    c.movement_count,
    c.security_count,
    c.row_update_datetime as row_update_datetime3,
    c.source_system as source_system2,
    c.filler as filler2
    
    from patient p
		INNER JOIN pmi_case AS c on c.patient_key = p.patient_key
		RIGHT JOIN nok AS n on n.patient_key = p.patient_key
		LEFT OUTER JOIN ccc_unicode AS c1 ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c2 ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c3 ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c4 ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c5 ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
		LEFT OUTER JOIN ccc_unicode AS c6 ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
    where c.case_no = par_case_no
    and c.hospital_code = par_hospital_code
    and n.priority = 1;
return next p_refcur;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_patcase_by_caseno" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
