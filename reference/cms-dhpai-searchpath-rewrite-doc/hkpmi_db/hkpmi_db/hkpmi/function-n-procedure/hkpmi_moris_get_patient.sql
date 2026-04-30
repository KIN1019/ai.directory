-- DROP PROCEDURE hkpmi.hkpmi_moris_get_patient(inout int4, in varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout int4, inout int4, inout int4, inout int4, inout int4, inout timestamp, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_moris_get_patient(INOUT pas_return_code integer, IN par_patient_hkid character varying, INOUT par_old_patient_hkid character varying DEFAULT NULL::character varying, INOUT par_patient_real_hkid character varying DEFAULT NULL::character varying, INOUT par_eng_name character varying DEFAULT NULL::character varying, INOUT par_cccode1 character varying DEFAULT NULL::character varying, INOUT par_cccode2 character varying DEFAULT NULL::character varying, INOUT par_cccode3 character varying DEFAULT NULL::character varying, INOUT par_cccode4 character varying DEFAULT NULL::character varying, INOUT par_cccode5 character varying DEFAULT NULL::character varying, INOUT par_cccode6 character varying DEFAULT NULL::character varying, INOUT par_unicode1 integer DEFAULT NULL::integer, INOUT par_unicode2 integer DEFAULT NULL::integer, INOUT par_unicode3 integer DEFAULT NULL::integer, INOUT par_unicode4 integer DEFAULT NULL::integer, INOUT par_unicode5 integer DEFAULT NULL::integer, INOUT par_unicode6 integer DEFAULT NULL::integer, INOUT par_dob timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_exact_dob_flag character varying DEFAULT NULL::character varying, INOUT par_sex character varying DEFAULT NULL::character varying, INOUT par_death_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_body_category character varying DEFAULT NULL::character varying, INOUT par_last_hospital_code character varying DEFAULT NULL::character varying, INOUT par_last_case_no character varying DEFAULT NULL::character varying, INOUT par_last_ward_code character varying DEFAULT NULL::character varying, INOUT par_last_update_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, INOUT par_other_doc_no character varying DEFAULT ''::character varying, INOUT par_return_code integer DEFAULT 1, INOUT par_return_message character varying DEFAULT ''::character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
************************************************
   1.a Check the patient has changed HKID or not
   1.b Find the patient data
   2. Find the patient's discharge to death case
   3. Find the unicode of each CCCode of patient
      Chinese name
************************************************
*/ /* 20100227 Add by HKFong */
DECLARE
    var_patient_key VARCHAR(16);
    var_temp_patient_hkid VARCHAR(24);
    sql$rowcount BIGINT;
BEGIN
    IF EXISTS (SELECT
        0
        FROM patient
        WHERE hkid = par_patient_hkid LIMIT 1) THEN
        BEGIN
            /* 20090306 HKFong - Start */
            IF EXISTS (SELECT
                0
                FROM patient_key_changed
                WHERE old_hkid <> par_patient_hkid::VARCHAR AND new_hkid = par_patient_hkid::VARCHAR LIMIT 1) THEN
                SELECT
                    new_hkid, old_hkid, new_hkid
                    INTO var_temp_patient_hkid, par_old_patient_hkid, par_patient_real_hkid
                    FROM patient_key_changed
                    WHERE old_hkid <> par_patient_hkid::VARCHAR AND new_hkid = par_patient_hkid::VARCHAR;
            ELSE
                /* 20090306 HKFong - End */
                SELECT
                    par_patient_hkid
                    INTO var_temp_patient_hkid;
            END IF;
        END;
    ELSE
        BEGIN
            IF EXISTS (SELECT
                0
                FROM patient_key_changed
                WHERE old_hkid = par_patient_hkid::VARCHAR AND new_hkid <> par_patient_hkid::VARCHAR LIMIT 1) THEN
                SELECT
                    new_hkid, old_hkid, new_hkid
                    INTO var_temp_patient_hkid, par_old_patient_hkid, par_patient_real_hkid
                    FROM patient_key_changed
                    WHERE old_hkid = par_patient_hkid::VARCHAR AND new_hkid <> par_patient_hkid::VARCHAR;
            /*
            ELSE if exists (SELECT 0 FROM patient_key_changed where old_hkid <> @patient_hkid and new_hkid = @patient_hkid)
            SELECT @temp_patient_hkid = new_hkid,
            	   @old_patient_hkid = old_hkid,
            	   @patient_real_hkid = new_hkid
              FROM patient_key_changed
             where old_hkid <> @patient_hkid
               and new_hkid = @patient_hkid
            */
            ELSE
                SELECT
                    par_patient_hkid
                    INTO var_temp_patient_hkid;
            END IF;
        END;
    END IF;
    SELECT
        patient_name, patient_key, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, sex, death_date, COALESCE(SAFE_SUBSTRING(filler, 2, 1), '0'), other_doc_no, /* 20100227 Add by HKFong */ system_dtm
        INTO par_eng_name, var_patient_key, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_dob, par_exact_dob_flag, par_sex, par_death_datetime, par_body_category, par_other_doc_no, par_last_update_datetime
        FROM patient
        WHERE hkid = var_temp_patient_hkid;
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
    SELECT
        hospital_code, case_no, last_ward_code
        INTO par_last_hospital_code, par_last_case_no, par_last_ward_code
        FROM pmi_case
        WHERE patient_key = var_patient_key AND discharge_code = '1'; /* Find the patient case which discharge to death */
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        BEGIN
            SELECT
                '', '', ''
                INTO par_last_hospital_code, par_last_case_no, par_last_ward_code;
        END;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_cccode1 LIMIT 1) THEN
        SELECT
            unicode_int
            INTO par_unicode1
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_cccode1;
    ELSE
        SELECT
            0
            INTO par_unicode1;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_cccode2 LIMIT 1) THEN
        SELECT
            unicode_int
            INTO par_unicode2
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_cccode2;
    ELSE
        SELECT
            0
            INTO par_unicode2;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_cccode3 LIMIT 1) THEN
        SELECT
            unicode_int
            INTO par_unicode3
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_cccode3;
    ELSE
        SELECT
            0
            INTO par_unicode3;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_cccode4 LIMIT 1) THEN
        SELECT
            unicode_int
            INTO par_unicode4
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_cccode4;
    ELSE
        SELECT
            0
            INTO par_unicode4;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_cccode5 LIMIT 1) THEN
        SELECT
            unicode_int
            INTO par_unicode5
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_cccode5;
    ELSE
        SELECT
            0
            INTO par_unicode5;
    END IF;

    IF EXISTS (SELECT
        0
        FROM ccc_unicode
        WHERE CONCAT(ccc_head, ccc_tail) = par_cccode6 LIMIT 1) THEN
        SELECT
            unicode_int
            INTO par_unicode6
            FROM ccc_unicode
            WHERE CONCAT(ccc_head, ccc_tail) = par_cccode6;
    ELSE
        SELECT
            0
            INTO par_unicode6;
    END IF;
    SELECT
        1, 'Completed'
        INTO par_return_code, par_return_message;
    pas_return_code := 1;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_moris_get_patient" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
