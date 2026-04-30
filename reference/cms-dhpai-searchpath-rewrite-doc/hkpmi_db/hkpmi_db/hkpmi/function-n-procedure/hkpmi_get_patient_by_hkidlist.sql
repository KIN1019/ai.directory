-- DROP FUNCTION hkpmi_get_patient_by_hkidlist(varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi_get_patient_by_hkidlist(par_hkid_list1 character varying, par_hkid_list2 character varying, par_hkid_list3 character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    string         VARCHAR(255);
    pos            INT;
    piece          VARCHAR(50);
    count          INT;
    max_loop_count INT := 50;
    loop_count     INT := 0;
    p_refcur refcursor;
BEGIN
    -- Create a temporary table to store HKIDs
	drop table if exists t$temp_hkid;
    CREATE TEMP TABLE t$temp_hkid (hkid VARCHAR(12));

    -- Process par_hkid_list1
    string := par_hkid_list1;
    pos := POSITION(',' IN string);
    WHILE pos <> 0 AND loop_count < max_loop_count
    LOOP
        piece := LEFT(string,pos - 1);
        INSERT INTO t$temp_hkid (hkid) VALUES (piece);
        string := SUBSTRING(string FROM pos + 1);
        pos := POSITION(',' IN string);
        loop_count := loop_count + 1;
    END LOOP;
    INSERT INTO t$temp_hkid (hkid) VALUES (string);

    -- Process par_hkid_list2 if not null or empty
    IF par_hkid_list2 IS NOT NULL AND par_hkid_list2 <> ''
    THEN
        string := par_hkid_list2;
        pos := POSITION(',' IN string);
        loop_count := 0;
        WHILE pos <> 0 AND loop_count < max_loop_count
        LOOP
            piece := LEFT(string,pos - 1);
            INSERT INTO t$temp_hkid (hkid) VALUES (piece);
            string := SUBSTRING(string FROM pos + 1);
            pos := POSITION(',' IN string);
            loop_count := loop_count + 1;
        END LOOP;
        INSERT INTO t$temp_hkid (hkid) VALUES (string);
    END IF;

    -- Process par_hkid_list3 if not null or empty
    IF par_hkid_list3 IS NOT NULL AND par_hkid_list3 <> ''
    THEN
        string := par_hkid_list3;
        pos := POSITION(',' IN string);
        loop_count := 0;
        WHILE pos <> 0 AND loop_count < max_loop_count
        LOOP
            piece := LEFT(string,pos - 1);
            INSERT INTO t$temp_hkid (hkid) VALUES (piece);
            string := SUBSTRING(string FROM pos + 1);
            pos := POSITION(',' IN string);
            loop_count := loop_count + 1;
        END LOOP;
        INSERT INTO t$temp_hkid (hkid) VALUES (string);
    END IF;

    -- Check if the number of HKIDs exceeds the maximum allowed
    SELECT COUNT(*) INTO count FROM t$temp_hkid;
    IF count > max_loop_count
    THEN
        RAISE EXCEPTION 'Maximum number of HKID input is 50, your input (number of HKID input: %) is exceeding the range!', count;
    END IF;

    OPEN p_refcur FOR
        select p.patient_key,
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
        c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6
        from patient p
       inner join t$temp_hkid t on p.hkid = t.hkid
        left join ccc_unicode c1 on c1.ccc_head = substring(p.cccode1, 1, 4) and c1.ccc_tail = substring(p.cccode1, 5, 1)
        left join ccc_unicode c2 on c2.ccc_head = substring(p.cccode2, 1, 4) and c2.ccc_tail = substring(p.cccode2, 5, 1)
        left join ccc_unicode c3 on c3.ccc_head = substring(p.cccode3, 1, 4) and c3.ccc_tail = substring(p.cccode3, 5, 1)
        left join ccc_unicode c4 on c4.ccc_head = substring(p.cccode4, 1, 4) and c4.ccc_tail = substring(p.cccode4, 5, 1)
        left join ccc_unicode c5 on c5.ccc_head = substring(p.cccode5, 1, 4) and c5.ccc_tail = substring(p.cccode5, 5, 1)
        left join ccc_unicode c6 on c6.ccc_head = substring(p.cccode6, 1, 4) and c6.ccc_tail = substring(p.cccode6, 5, 1);

    RETURN NEXT p_refcur;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_patient_by_hkidlist" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
