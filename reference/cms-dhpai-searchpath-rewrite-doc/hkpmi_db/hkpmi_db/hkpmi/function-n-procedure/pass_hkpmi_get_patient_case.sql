CREATE OR REPLACE PROCEDURE pass_hkpmi_get_patient_case(INOUT pas_return_code int ,IN par_hospital_code VARCHAR, IN par_hkid VARCHAR, IN par_case_no VARCHAR DEFAULT null, INOUT p_refcur refcursor DEFAULT NULL)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_c_patient_key VARCHAR(8);
    var_error_msg VARCHAR(255);
    var_rowcount INTEGER;
    var_error INTEGER;
    var_pin VARCHAR(12);
    var_pin_len INTEGER;
    sql$rowcount BIGINT;
BEGIN
    SELECT
        LTRIM(RTRIM(par_case_no))
        INTO var_pin;
    SELECT
        OCTET_LENGTH(var_pin)
        INTO var_pin_len;

    IF var_pin_len = 11 THEN
        SELECT
            CONCAT(' ', var_pin)
            INTO par_case_no;
    ELSE
        SELECT
            var_pin
            INTO par_case_no;
    END IF;

    IF par_case_no IS NOT NULL THEN
        BEGIN
            BEGIN
                SELECT
                    patient_key
                    INTO var_c_patient_key
                    FROM pmi_case
                    WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF (var_error != 0) OR (var_rowcount = 0) THEN
                BEGIN
                    RAISE EXCEPTION 'Case not found!' USING ERRCODE := '200123';
                    pas_return_code := 200123;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    SELECT
        LTRIM(RTRIM(par_hkid))
        INTO var_pin;
    SELECT
        OCTET_LENGTH(var_pin)
        INTO var_pin_len;

    IF var_pin_len = 8 THEN
        SELECT
            CONCAT(' ', var_pin)
            INTO par_hkid;
    ELSE
        SELECT
            var_pin
            INTO par_hkid;
    END IF;
    DROP TABLE IF EXISTS t$temp_result;
    CREATE TEMPORARY TABLE t$temp_result
    (
        /* --Patient */
        patient_key VARCHAR(12),
        hkid VARCHAR(12),
        other_doc_no VARCHAR(12) NULL,
        patient_name VARCHAR(48),
        sex VARCHAR(1),
        dob VARCHAR(10) NULL,
        exact_dob_flag VARCHAR(1),
        death_indicator VARCHAR(1) NULL,
        death_date VARCHAR(10) NULL,
        unicode_int1 INTEGER NULL,
        unicode_int2 INTEGER NULL,
        unicode_int3 INTEGER NULL,
        unicode_int4 INTEGER NULL,
        unicode_int5 INTEGER NULL,
        unicode_int6 INTEGER NULL,
        phone1 VARCHAR(10) NULL,
        phone2 VARCHAR(10) NULL,
        address_indicator VARCHAR(4) NULL,
        mobile_phone VARCHAR(10) NULL,
        sms_language VARCHAR(4) NULL,
        marital_status VARCHAR(1),
        race VARCHAR(2),
        religion VARCHAR(3) NULL,
        access_code INTEGER,
        /* --Case */
        hospital_code VARCHAR(3) NULL,
        mrn VARCHAR(8) NULL,
        case_no VARCHAR(12) NULL,
        case_type VARCHAR(1) NULL,
        admission_dtm VARCHAR(19) NULL,
        source_indicator VARCHAR(1) NULL,
        source_code VARCHAR(3) NULL,
        discharge_dtm VARCHAR(19) NULL,
        destination_code VARCHAR(5) NULL,
        last_specialty_code VARCHAR(4) NULL,
        last_ward_code VARCHAR(4) NULL,
        last_ward_class VARCHAR(1) NULL,
        last_bed_no VARCHAR(5) NULL,
        /* --Referring Doctor */
        pp_code VARCHAR(8) NULL,
        pp_name VARCHAR(48) NULL,
        /* --Preferred Language */
        language_code VARCHAR(5) NULL,
        language VARCHAR(50) NULL);
    /* --Patient */
    /*
    [9996 - Severity CRITICAL - Transformer error occurred in fromClause. Please submit report to developers.]
    insert into #temp_result
            (patient_key, hkid, other_doc_no,
             patient_name, sex,
             dob, exact_dob_flag, death_indicator, death_date,
             unicode_int1,
             unicode_int2,
             unicode_int3,
             unicode_int4,
             unicode_int5,
             unicode_int6,
             phone1,
             phone2,
             address_indicator,
             mobile_phone,
             sms_language,
             marital_status, race, religion,
             access_code
            )
    	select rtrim(patient_key) patient_key, rtrim(hkid) hkid, other_doc_no,
            rtrim(patient_name) patient_name, sex,
    	convert(VARCHAR(10), dob, 105) as dob, exact_dob_flag,
    	case
                 when(death_indicator is null) then 'N'
    	     else 'Y'
    	end death_indicator,
            convert(VARCHAR(10), death_date, 105) as death_date,
    	c1.unicode_int unicode_int1,
    	c2.unicode_int unicode_int2,
    	c3.unicode_int unicode_int3,
    	c4.unicode_int unicode_int4,
    	c5.unicode_int unicode_int5,
    	c6.unicode_int unicode_int6,
            phone1,
            phone2,
            address_indicator,
            mobile_phone,
            sms_language,
            marital_status, race, religion,
            access_code & 1
    
            from patient,
            ccc_big5 c1, ccc_big5 c2, ccc_big5 c3,
            ccc_big5 c4, ccc_big5 c5, ccc_big5 c6
    	where hkid = @hkid
    	and substring(cccode1,1,4) *= c1.ccc_head
    	and substring(cccode1,5,1) *= c1.ccc_tail
    	and substring(cccode2,1,4) *= c2.ccc_head
    	and substring(cccode2,5,1) *= c2.ccc_tail
    	and substring(cccode3,1,4) *= c3.ccc_head
    	and substring(cccode3,5,1) *= c3.ccc_tail

    	and substring(cccode4,1,4) *= c4.ccc_head
    	and substring(cccode4,5,1) *= c4.ccc_tail

    	and substring(cccode5,1,4) *= c5.ccc_head
    	and substring(cccode5,5,1) *= c5.ccc_tail

    	and substring(cccode6,1,4) *= c6.ccc_head
    	and substring(cccode6,5,1) *= c6.ccc_tail
    */
    insert into t$temp_result
            (patient_key, hkid, other_doc_no,
             patient_name, sex,
             dob, exact_dob_flag, death_indicator, death_date,
             unicode_int1,
             unicode_int2,
             unicode_int3,
             unicode_int4,
             unicode_int5,
             unicode_int6,
             phone1,
             phone2,
             address_indicator,
             mobile_phone,
             sms_language,
             marital_status, race, religion,
             access_code
            )
        select rtrim(p.patient_key) as patient_key, rtrim(p.hkid) as hkid, p.other_doc_no,
            rtrim(p.patient_name) as patient_name, p.sex,
    	to_char(p.dob,'DD-MM-YYYY') as dob, p.exact_dob_flag,
    	case
            when(p.death_indicator is null) then 'N'
    	    else 'Y'
    	end as death_indicator,
            to_char(p.death_date,'DD-MM-YYYY') as death_date,
    	c1.unicode_int as unicode_int1,
    	c2.unicode_int as unicode_int2,
    	c3.unicode_int as unicode_int3,
    	c4.unicode_int as unicode_int4,
    	c5.unicode_int as unicode_int5,
    	c6.unicode_int as unicode_int6,
            p.phone1,
            p.phone2,
            p.address_indicator,
            p.mobile_phone,
            p.sms_language,
            p.marital_status, p.race, p.religion,
            p.access_code & 1

            from patient p
        LEFT JOIN ccc_unicode c1 ON substring(p.cccode1,1,4) = c1.ccc_head and substring(p.cccode1,5,1) = c1.ccc_tail
        LEFT JOIN ccc_unicode c2 ON substring(p.cccode2,1,4) = c2.ccc_head and substring(p.cccode2,5,1) = c2.ccc_tail
        LEFT JOIN ccc_unicode c3 ON substring(p.cccode3,1,4) = c3.ccc_head and substring(p.cccode3,5,1) = c3.ccc_tail
        LEFT JOIN ccc_unicode c4 ON substring(p.cccode4,1,4) = c4.ccc_head and substring(p.cccode4,5,1) = c4.ccc_tail
        LEFT JOIN ccc_unicode c5 ON substring(p.cccode5,1,4) = c5.ccc_head and substring(p.cccode5,5,1) = c5.ccc_tail
        LEFT JOIN ccc_unicode c6 ON substring(p.cccode6,1,4) = c6.ccc_head and substring(p.cccode6,5,1) = c6.ccc_tail
        where p.hkid = par_hkid;
    /* --MRN */
    UPDATE t$temp_result AS tmp
    SET mrn = p.mrn
    FROM patient_hospital_data AS p
        WHERE tmp.patient_key = p.patient_key AND p.hospital_code = par_hospital_code;
    /* --Case */
    UPDATE t$temp_result AS tmp
    SET hospital_code = par_hospital_code, case_no = c.case_no, case_type = c.case_type, admission_dtm = CONCAT(to_char(c.adm_dtm,'DD-MM-YYYY'), ' ', to_char(c.adm_dtm,'HH24:MI:SS')), source_indicator = c.source_indicator, source_code = c.source_code, discharge_dtm = CONCAT(to_char(c.discharge_dtm,'DD-MM-YYYY'), ' ', to_char(c.discharge_dtm,'HH24:MI:SS')), destination_code = c.destination_code, last_specialty_code = c.last_specialty_code, last_ward_code = c.last_ward_code, last_ward_class = c.last_ward_class, last_bed_no = c.last_bed_no,
    /* --Referring Doctor */
    pp_code = c.pp_code
    FROM pmi_case AS c
        WHERE tmp.patient_key = c.patient_key AND c.hospital_code = par_hospital_code AND c.case_no = par_case_no;
    /* --Referring Doctor */
    UPDATE t$temp_result AS tmp
    SET pp_name = p.pp_name
    FROM pp AS p
        WHERE tmp.pp_code = p.pp_code;
    /* --Preferred Language */
    UPDATE t$temp_result AS tmp
    SET language_code = pl.language_code, language = l.language
    FROM hkpmi_patient_language AS pl, interpretation_language AS l
        WHERE tmp.patient_key = pl.patient_key AND pl.status = 'A' AND pl.language_code = l.language_code AND (l.expiry_date IS NULL OR l.expiry_date >timestamp_convert(localtimestamp));
    OPEN p_refcur FOR
    /* --Patient */
    SELECT
        patient_key, hkid, other_doc_no, patient_name, sex, dob, exact_dob_flag, death_indicator, death_date, unicode_int1, unicode_int2, unicode_int3, unicode_int4, unicode_int5, unicode_int6, phone1, phone2, address_indicator, mobile_phone, sms_language, marital_status, race, religion, access_code,
        /* --Case */
        hospital_code, mrn, case_no, case_type, admission_dtm, source_indicator, source_code, discharge_dtm, destination_code, last_specialty_code, last_ward_code, last_ward_class, last_bed_no,
        /* --Referring Doctor */
        pp_code, pp_name,
        /* --Preferred Language */
        language_code, language
        FROM t$temp_result;
    -- DROP TABLE t$temp_result;
    /*
    
    DROP TABLE IF EXISTS t$temp_result;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

ALTER PROCEDURE "pass_hkpmi_get_patient_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";