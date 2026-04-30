-- DROP PROCEDURE hkpmi.hkpmi_moris_get_patient_w_lof(inout int4, in bpchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout int4, inout int4, inout int4, inout int4, inout int4, inout timestamp, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout int4, inout int4, inout int4, inout int4, inout int4, inout timestamp, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout int4, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_moris_get_patient_w_lof(INOUT pas_return_code integer, IN par_patient_hkid character, INOUT par_lof_patient_real_hkid character varying DEFAULT NULL::character varying, INOUT par_lof_eng_name character varying DEFAULT NULL::character varying, INOUT par_lof_cccode1 character varying DEFAULT NULL::character varying, INOUT par_lof_cccode2 character varying DEFAULT NULL::character varying, INOUT par_lof_cccode3 character varying DEFAULT NULL::character varying, INOUT par_lof_cccode4 character varying DEFAULT NULL::character varying, INOUT par_lof_cccode5 character varying DEFAULT NULL::character varying, INOUT par_lof_cccode6 character varying DEFAULT NULL::character varying, INOUT par_lof_unicode1 integer DEFAULT NULL::integer, INOUT par_lof_unicode2 integer DEFAULT NULL::integer, INOUT par_lof_unicode3 integer DEFAULT NULL::integer, INOUT par_lof_unicode4 integer DEFAULT NULL::integer, INOUT par_lof_unicode5 integer DEFAULT NULL::integer, INOUT par_lof_unicode6 integer DEFAULT NULL::integer, INOUT par_lof_dob timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_lof_exact_dob_flag character varying DEFAULT NULL::character varying, INOUT par_lof_sex character varying DEFAULT NULL::character varying, INOUT par_lof_death_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_lof_body_category character varying DEFAULT NULL::character varying, INOUT par_lof_last_hospital_code character varying DEFAULT NULL::character varying, INOUT par_lof_last_case_no character varying DEFAULT NULL::character varying, INOUT par_lof_last_ward_code character varying DEFAULT NULL::character varying, INOUT par_lof_issue_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_hkpmi_patient_hkid character varying DEFAULT NULL::character varying, INOUT par_hkpmi_patient_real_hkid character varying DEFAULT NULL::character varying, INOUT par_hkpmi_eng_name character varying DEFAULT NULL::character varying, INOUT par_hkpmi_cccode1 character varying DEFAULT NULL::character varying, INOUT par_hkpmi_cccode2 character varying DEFAULT NULL::character varying, INOUT par_hkpmi_cccode3 character varying DEFAULT NULL::character varying, INOUT par_hkpmi_cccode4 character varying DEFAULT NULL::character varying, INOUT par_hkpmi_cccode5 character varying DEFAULT NULL::character varying, INOUT par_hkpmi_cccode6 character varying DEFAULT NULL::character varying, INOUT par_hkpmi_unicode1 integer DEFAULT NULL::integer, INOUT par_hkpmi_unicode2 integer DEFAULT NULL::integer, INOUT par_hkpmi_unicode3 integer DEFAULT NULL::integer, INOUT par_hkpmi_unicode4 integer DEFAULT NULL::integer, INOUT par_hkpmi_unicode5 integer DEFAULT NULL::integer, INOUT par_hkpmi_unicode6 integer DEFAULT NULL::integer, INOUT par_hkpmi_dob timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_hkpmi_exact_dob_flag character varying DEFAULT NULL::character varying, INOUT par_hkpmi_sex character varying DEFAULT NULL::character varying, INOUT par_hkpmi_death_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_hkpmi_body_category character varying DEFAULT NULL::character varying, INOUT par_hkpmi_last_hospital_code character varying DEFAULT NULL::character varying, INOUT par_hkpmi_last_case_no character varying DEFAULT NULL::character varying, INOUT par_hkpmi_last_ward_code character varying DEFAULT NULL::character varying, INOUT par_hkpmi_last_update_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_hkpmi_other_doc_no character varying DEFAULT ''::character varying, INOUT par_with_bcf character varying DEFAULT 'N'::character varying, INOUT par_bcf_hospital_code character varying DEFAULT ''::character varying, INOUT par_bcf_hkid character varying DEFAULT ''::character varying, INOUT par_bcf_issue_datetime timestamp without time zone DEFAULT '1900-01-01 00:00:00'::timestamp without time zone, INOUT par_bcf_body_category character varying DEFAULT ''::character varying, INOUT par_bcf_mortuary_id integer DEFAULT 0, INOUT par_return_code integer DEFAULT 1, INOUT par_return_message character varying DEFAULT ''::character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
************************************************
   1. Get LOF data
   2. Get the HKPMI data
   3. IF HKID is changed, get the HKPMI data of the
      new HKID
   4. Find the unicode of each CCCode of patient
      Chinese name
************************************************
*/ /* 20100227 Add by HKFong */
/* 20090913 - Change by HK Fong - Start */
/* 20090913 - Change by HK Fong - End */
DECLARE
    var_patient_key VARCHAR(16);
    sql$rowcount BIGINT;
BEGIN
    IF EXISTS (SELECT
        0
        FROM last_office_form_log AS a
        WHERE a.hkid = par_patient_hkid::VARCHAR AND a.action_type <> 'C' AND a.update_datetime = (SELECT
            MAX(b.update_datetime)
            FROM last_office_form_log AS b
            WHERE b.hkid = a.hkid) LIMIT 1) THEN
        SELECT
            patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, sex, death_datetime, body_category, last_hospital_code, last_case_no, last_ward_code, issue_datetime
            INTO par_lof_eng_name, par_lof_cccode1, par_lof_cccode2, par_lof_cccode3, par_lof_cccode4, par_lof_cccode5, par_lof_cccode6, par_lof_dob, par_lof_exact_dob_flag, par_lof_sex, par_lof_death_datetime, par_lof_body_category, par_lof_last_hospital_code, par_lof_last_case_no, par_lof_last_ward_code, par_lof_issue_datetime
            FROM last_office_form_log AS a
            WHERE a.hkid = par_patient_hkid::VARCHAR AND a.action_type <> 'C' AND a.update_datetime = (SELECT
                MAX(b.update_datetime)
                FROM last_office_form_log AS b
                WHERE b.hkid = a.hkid);
    ELSE
        BEGIN
            SELECT
                - 101146, CONCAT('HKID: ', LTRIM(par_patient_hkid), ', Patient LOF data does not exist!')
                INTO par_return_code, par_return_message;
            pas_return_code := par_return_code;
            RETURN;
        END;
    END IF;

    IF EXISTS (SELECT
        0
        FROM patient
        WHERE hkid = par_patient_hkid LIMIT 1) THEN
        SELECT
            hkid, patient_key, patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, sex, death_date, COALESCE(SAFE_SUBSTRING(filler, 2, 1), '0'), other_doc_no, /* 20100227 Add by HKFong */ system_dtm
            INTO par_hkpmi_patient_hkid, var_patient_key, par_hkpmi_eng_name, par_hkpmi_cccode1, par_hkpmi_cccode2, par_hkpmi_cccode3, par_hkpmi_cccode4, par_hkpmi_cccode5, par_hkpmi_cccode6, par_hkpmi_dob, par_hkpmi_exact_dob_flag, par_hkpmi_sex, par_hkpmi_death_datetime, par_hkpmi_body_category, par_hkpmi_other_doc_no, par_hkpmi_last_update_datetime
            FROM patient
            WHERE hkid = par_patient_hkid;
    ELSE
        BEGIN
            IF NOT EXISTS (SELECT
                0
                FROM patient_key_changed
                WHERE old_hkid = par_patient_hkid::VARCHAR AND new_hkid <> par_patient_hkid::VARCHAR LIMIT 1) THEN
                BEGIN
                    SELECT
                        - 101101, CONCAT('HKID: ', LTRIM(par_patient_hkid), ', patient data not exists in HKPMI!')
                        INTO par_return_code, par_return_message;
                    pas_return_code := par_return_code;
                    RETURN;
                END;
            ELSE
                BEGIN
                    SELECT
                        new_hkid, new_hkid
                        INTO par_lof_patient_real_hkid, par_hkpmi_patient_hkid
                        FROM patient_key_changed
                        WHERE old_hkid = par_patient_hkid::VARCHAR AND new_hkid <> par_patient_hkid::VARCHAR;
                    SELECT
                        hkid, patient_key, patient_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, sex, death_date, COALESCE(SAFE_SUBSTRING(filler, 2, 1), '0'), other_doc_no, /* 20100227 Add by HKFong */ system_dtm
                        INTO par_hkpmi_patient_hkid, var_patient_key, par_hkpmi_eng_name, par_hkpmi_cccode1, par_hkpmi_cccode2, par_hkpmi_cccode3, par_hkpmi_cccode4, par_hkpmi_cccode5, par_hkpmi_cccode6, par_hkpmi_dob, par_hkpmi_exact_dob_flag, par_hkpmi_sex, par_hkpmi_death_datetime, par_hkpmi_body_category, par_hkpmi_other_doc_no, par_hkpmi_last_update_datetime
                        FROM patient
                        WHERE hkid = par_hkpmi_patient_hkid;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        BEGIN
                            SELECT
                                - 101101, CONCAT('HKID: ', LTRIM(par_patient_hkid), ', patient data not exists in HKPMI!')
                                INTO par_return_code, par_return_message;
                            pas_return_code := par_return_code;
                            RETURN;
                        END;
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* 20090913 - Change by HK Fong - Start */
    IF EXISTS (SELECT
        0
        FROM bcf_log
        WHERE hkid = par_hkpmi_patient_hkid::VARCHAR LIMIT 1) THEN
        SELECT
            'Y', hospital_code, hkid, system_datetime, body_category, mortuary_id
            INTO par_with_bcf, par_bcf_hospital_code, par_bcf_hkid, par_bcf_issue_datetime, par_bcf_body_category, par_bcf_mortuary_id
            FROM bcf_log
            WHERE hkid = par_hkpmi_patient_hkid::VARCHAR;
    ELSE
        SELECT
            'N', '', '', '19000101', ''
            INTO par_with_bcf, par_bcf_hospital_code, par_bcf_hkid, par_bcf_issue_datetime, par_bcf_body_category;
    END IF;
    /* 20090913 - Change by HK Fong - End */
    SELECT
        hospital_code, case_no, last_ward_code
        INTO par_hkpmi_last_hospital_code, par_hkpmi_last_case_no, par_hkpmi_last_ward_code
        FROM pmi_case
        WHERE patient_key = var_patient_key AND discharge_code = '1'; /* Find the patient case which discharge to death */
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        BEGIN
            SELECT
                '', '', ''
                INTO par_hkpmi_last_hospital_code, par_hkpmi_last_case_no, par_hkpmi_last_ward_code;
        END;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode1) THEN
        SELECT
            unicode_int
            INTO par_lof_unicode1
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode1;
    ELSE
        SELECT
            0
            INTO par_lof_unicode1;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode2) THEN
        SELECT
            unicode_int
            INTO par_lof_unicode2
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode2;
    ELSE
        SELECT
            0
            INTO par_lof_unicode2;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode3) THEN
        SELECT
            unicode_int
            INTO par_lof_unicode3
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode3;
    ELSE
        SELECT
            0
            INTO par_lof_unicode3;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode4) THEN
        SELECT
            unicode_int
            INTO par_lof_unicode4
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode4;
    ELSE
        SELECT
            0
            INTO par_lof_unicode4;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode5) THEN
        SELECT
            unicode_int
            INTO par_lof_unicode5
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode5;
    ELSE
        SELECT
            0
            INTO par_lof_unicode5;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode6) THEN
        SELECT
            unicode_int
            INTO par_lof_unicode6
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_lof_cccode6;
    ELSE
        SELECT
            0
            INTO par_lof_unicode6;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode1) THEN
        SELECT
            unicode_int
            INTO par_hkpmi_unicode1
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode1;
    ELSE
        SELECT
            0
            INTO par_hkpmi_unicode1;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode2) THEN
        SELECT
            unicode_int
            INTO par_hkpmi_unicode2
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode2;
    ELSE
        SELECT
            0
            INTO par_hkpmi_unicode2;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode3) THEN
        SELECT
            unicode_int
            INTO par_hkpmi_unicode3
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode3;
    ELSE
        SELECT
            0
            INTO par_hkpmi_unicode3;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode4) THEN
        SELECT
            unicode_int
            INTO par_hkpmi_unicode4
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode4;
    ELSE
        SELECT
            0
            INTO par_hkpmi_unicode4;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode5) THEN
        SELECT
            unicode_int
            INTO par_hkpmi_unicode5
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode5;
    ELSE
        SELECT
            0
            INTO par_hkpmi_unicode5;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode6) THEN
        SELECT
            unicode_int
            INTO par_hkpmi_unicode6
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_hkpmi_cccode6;
    ELSE
        SELECT
            0
            INTO par_hkpmi_unicode6;
    END IF;
    SELECT
        1, 'Completed'
        INTO par_return_code, par_return_message;
    pas_return_code := 1;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_moris_get_patient_w_lof" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
