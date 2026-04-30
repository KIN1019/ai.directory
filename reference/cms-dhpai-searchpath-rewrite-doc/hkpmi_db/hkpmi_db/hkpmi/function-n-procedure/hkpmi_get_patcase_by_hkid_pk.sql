CREATE OR REPLACE FUNCTION hkpmi_get_patcase_by_hkid_pk(IN par_hkid VARCHAR, IN par_patient_key VARCHAR, IN par_case_type VARCHAR)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    IF par_patient_key = '' OR par_patient_key IS NULL THEN
        BEGIN
            SELECT
                patient_key
                INTO par_patient_key
                FROM patient
                WHERE hkid = par_hkid;
        END;
    END IF;
    /* --Patient */
    /*
    [9996 - Severity CRITICAL - Transformer error occurred in fromClause. Please submit report to developers.]
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
    p.update_by,
    p.source_system_dtm,
    p.system_dtm,
    p.row_update_datetime,
    p.filler,
    c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
    c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6,
    --Major NOK
    n.patient_key,
    n.priority,
    n.major_nok,
    n.hkid,
    n.relationship,
    n.nok_name,
    n.building,
    n.room,
    n.floor,
    n.block,
    n.district,
    n.phone1,
    n.phone2,
    n.address_indicator,
    n.mobile_phone,
    n.sms_language,
    n.update_hospital,
    n.update_by,
    n.source_system_dtm,
    n.row_update_datetime,
    --Case
    c.hospital_code,
    c.case_no,
    c.patient_key,
    c.case_type,
    c.adm_dtm,
    c.source_indicator,
    c.source_code,
    c.patient_type,
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
    c.access_code,
    c.create_by,
    c.create_dtm,
    c.update_by,
    c.source_system_dtm,
    c.district,
    c.mrt_indicator,
    c.movement_count,
    c.security_count,
    c.row_update_datetime,
    c.source_system,
    c.filler
    
    from patient p, nok n, pmi_case c,
    ccc_big5 c1, ccc_big5 c2, ccc_big5 c3, ccc_big5 c4, ccc_big5 c5, ccc_big5 c6
    where p.patient_key = @patient_key
    and n.patient_key =* p.patient_key
    and n.priority = 1
    and c.patient_key =* p.patient_key
    and (c.case_type = @case_type or @case_type is null)
    and c.discharge_code IS NULL
    and c.discharge_dtm IS NULL
    and c1.ccc_head =* substring(p.cccode1, 1, 4) and c1.ccc_tail =* substring(p.cccode1, 5, 1)
    and c2.ccc_head =* substring(p.cccode2, 1, 4) and c2.ccc_tail =* substring(p.cccode2, 5, 1)
    and c3.ccc_head =* substring(p.cccode3, 1, 4) and c3.ccc_tail =* substring(p.cccode3, 5, 1)
    and c4.ccc_head =* substring(p.cccode4, 1, 4) and c4.ccc_tail =* substring(p.cccode4, 5, 1)
    and c5.ccc_head =* substring(p.cccode5, 1, 4) and c5.ccc_tail =* substring(p.cccode5, 5, 1)
    and c6.ccc_head =* substring(p.cccode6, 1, 4) and c6.ccc_tail =* substring(p.cccode6, 5, 1)
    */
OPEN p_refcur FOR
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
p.update_by,
p.source_system_dtm,
p.system_dtm,
p.row_update_datetime,
p.filler,
c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6,
--Major NOK
n.patient_key AS patient_key2,
n.priority,
n.major_nok,
n.hkid AS hkid2,
n.relationship,
n.nok_name,
n.building as building2,
n.room as room2,
n.floor as floor2 ,
n.block as block2 ,
n.district as district2,
n.phone1 as phone1_2,
n.phone2 as phone2_2,
n.address_indicator as address_indicator2,
n.mobile_phone as mobile_phone2,
n.sms_language as sms_language2 ,
n.update_hospital as update_hospital2,
n.update_by as update_by2,
n.source_system_dtm as source_system_dtm2,
n.row_update_datetime as  row_update_datetime2,
--Case
c.hospital_code,
c.case_no,
c.patient_key AS patient_key3,
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
c.access_code as access_code2,
c.create_by,
c.create_dtm,
c.update_by as update_by3 ,
c.source_system_dtm as source_system_dtm3,
c.district as district3,
c.mrt_indicator,
c.movement_count,
c.security_count,
c.row_update_datetime as row_update_datetime3,
c.source_system as source_system2,
c.filler as filler2

from patient p
left JOIN nok n ON p.patient_key =n.patient_key and n.priority = 1
left JOIN pmi_case c ON p.patient_key =c.patient_key 
left JOIN ccc_unicode c1 ON substring(p.cccode1, 1, 4) = c1.ccc_head and substring(p.cccode1, 5, 1) = c1.ccc_tail
left JOIN ccc_unicode c2 ON substring(p.cccode2, 1, 4) = c2.ccc_head and substring(p.cccode2, 5, 1) = c2.ccc_tail
left JOIN ccc_unicode c3 ON substring(p.cccode3, 1, 4) = c3.ccc_head and substring(p.cccode3, 5, 1) = c3.ccc_tail
left JOIN ccc_unicode c4 ON substring(p.cccode4, 1, 4) = c4.ccc_head and substring(p.cccode4, 5, 1) = c4.ccc_tail
left JOIN ccc_unicode c5 ON substring(p.cccode5, 1, 4) = c5.ccc_head and substring(p.cccode5, 5, 1) = c5.ccc_tail
left JOIN ccc_unicode c6 ON substring(p.cccode6, 1, 4) = c6.ccc_head and substring(p.cccode6, 5, 1) = c6.ccc_tail
where p.patient_key = par_patient_key
and (c.case_type = par_case_type or par_case_type is null)
and c.discharge_code IS NULL
and c.discharge_dtm IS NULL;
return next p_refcur;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_patcase_by_hkid_pk" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
