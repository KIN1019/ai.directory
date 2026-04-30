-- DROP FUNCTION hkpmi.hkpmi_hago_get_pmi_display_min(bpchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_hago_get_pmi_display_min(par_hkid varchar DEFAULT NULL::varchar)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
    var_other_phone VARCHAR(20);
    var_mobile_no VARCHAR(20);
    var_other_phone_trim VARCHAR(20);
    var_first_initial VARCHAR(1);
BEGIN
    /* TEAMCP2-767: Using "hkpmi_hago_get_pmi_display" as template to develop a new SP */
    /* to support HA Go displaying PMI information (minimal data) */
    
    /* -------------------------------------------- */
    /* Get mobile_no from other_phone */
    /* Copied the rule from IPAS pas.ui.Patient.js */
    /* Rule 1: the length is 8 */
    /* Rule 2: the first initial is 4-9 */
    
    /* --select @other_phone = other_phone from patient where hkid = @hkid */
    
    /* --select @mobile_no = null */
    
    /* --if @other_phone is not null and @other_phone <> '' begin */
    
    /* --	select @other_phone_trim = ltrim(rtrim(@other_phone)) */
    
    /* --	if len(@other_phone_trim) = 8 begin */
    
    /* --		select @first_initial = substring(@other_phone_trim,1,1) */
    
    /* --		if @first_initial = '4' or @first_initial = '5' or @first_initial = '6' or */
    
    /* --		@first_initial = '7' or @first_initial = '8' or @first_initial = '9' begin */
    
    /* --			select @mobile_no = @other_phone_trim */
    
    /* --		end */
    
    /* --	end */
    
    /* --end */
    
    /* -------------------------------------------- */
    /* Both the order and the names below are agreed with Jason/Raymond */
    /* They cannot be changed without Jason/Raymond consent */
    OPEN p_refcur FOR
    SELECT
        p.patient_key, p.hkid, p.patient_name, c1.unicode_int AS chi_name_1, c2.unicode_int AS chi_name_2, c3.unicode_int AS chi_name_3, c4.unicode_int AS chi_name_4, c5.unicode_int AS chi_name_5, c6.unicode_int AS chi_name_6, p.sex, p.exact_dob_flag, p.dob, p.phone1, p.phone2, p.address_indicator, p.mobile_phone,
        /* As discussed with Jason/Raymond, return both other_phone & mobile_no */
        p.sms_language other_phone_ext,
        CASE
            WHEN p.mobile_phone IS NOT NULL AND p.mobile_phone <> '' AND LENGTH(LTRIM(RTRIM(p.mobile_phone))) = 8 AND SAFE_SUBSTRING(LTRIM(RTRIM(p.mobile_phone)), 1, 1) IN ('4', '5', '6', '7', '8', '9') THEN LTRIM(RTRIM(p.mobile_phone))
            ELSE NULL
        END AS mobile_no,
        CASE
            WHEN p.sms_language IS NOT NULL AND p.sms_language <> '' AND LTRIM(RTRIM(p.sms_language)) IN (SELECT DISTINCT
                sms_language_code
                FROM sms_language_table) THEN (SELECT
                sms_language
                FROM sms_language_table
                WHERE sms_language_code = LTRIM(RTRIM(p.sms_language)))
            ELSE NULL
        END AS sms_language,
        /* As discussed with Jason/Raymond, return null sms_language for the time being */
        /* hkpmi_patient_contact is obsolete, need to get mobile_no from other_phone */
        
        /* --,m.mobile_no */
        
        /* --,m.sms_language */
        p.source_system_dtm AS pat_demo_upd_dtm
        FROM patient AS p
        LEFT OUTER JOIN ccc_unicode AS c1
            ON SAFE_SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SAFE_SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c2
            ON SAFE_SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SAFE_SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c3
            ON SAFE_SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SAFE_SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c4
            ON SAFE_SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SAFE_SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c5
            ON SAFE_SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SAFE_SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
        LEFT OUTER JOIN ccc_unicode AS c6
            ON SAFE_SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SAFE_SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
        /* hkpmi_patient_contact is obsolete, need to get mobile_no from other_phone */
        
        /* --left outer join hkpmi_patient_contact m on p.patient_key = m.patient_key */
        WHERE p.hkid = par_hkid;
		return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_hago_get_pmi_display_min" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

