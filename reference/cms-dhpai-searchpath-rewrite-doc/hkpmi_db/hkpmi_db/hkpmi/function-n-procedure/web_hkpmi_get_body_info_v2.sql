-- DROP PROCEDURE web_hkpmi_get_body_info_v2(in varchar, in varchar, inout varchar, out varchar, out varchar, out varchar, out varchar, out varchar, out varchar, out varchar, out varchar, out varchar, out int4, out int4, out int4, out int4, out int4, out int4, out timestamp, out varchar, out timestamp, out varchar, out int4, out varchar);

CREATE OR REPLACE PROCEDURE web_hkpmi_get_body_info_v2(INOUT pas_return_code INT, IN par_hospital_code character varying, IN par_case_no character varying, INOUT par_hkid character varying, OUT par_lof_hkid character varying, OUT par_patient_name character varying, OUT par_sex character varying, OUT par_cccode1 character varying, OUT par_cccode2 character varying, OUT par_cccode3 character varying, OUT par_cccode4 character varying, OUT par_cccode5 character varying, OUT par_cccode6 character varying, OUT par_unicode1 integer, OUT par_unicode2 integer, OUT par_unicode3 integer, OUT par_unicode4 integer, OUT par_unicode5 integer, OUT par_unicode6 integer, OUT par_dob timestamp without time zone, OUT par_exact_dob_flag character varying, OUT par_death_date timestamp without time zone, OUT par_body_category character varying, OUT par_retcode integer, OUT par_error_msg character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_patient_key VARCHAR(16);
BEGIN
    pas_return_code := 0;
    par_retcode := 0;
    par_error_msg := NULL;

    IF par_case_no IS NOT NULL THEN
        BEGIN
            SELECT p.hkid,
                   p.patient_name,
                   p.sex,
                   p.cccode1,
                   p.cccode2,
                   p.cccode3,
                   p.cccode4,
                   p.cccode5,
                   p.cccode6,
                   c1.unicode_int,
                   c2.unicode_int,
                   c3.unicode_int,
                   c4.unicode_int,
                   c5.unicode_int,
                   c6.unicode_int,
                   p.dob,
                   p.exact_dob_flag,
                   p.death_date,
                   SAFE_SUBSTRING(p.filler, 2, 1)
            INTO par_hkid, par_patient_name, par_sex,
                par_cccode1, par_cccode2, par_cccode3,
                par_cccode4, par_cccode5, par_cccode6,
                par_unicode1, par_unicode2, par_unicode3,
                par_unicode4, par_unicode5, par_unicode6,
                par_dob, par_exact_dob_flag, par_death_date,
                par_body_category
            FROM patient p
                     JOIN pmi_case c ON p.patient_key = c.patient_key
                     LEFT JOIN ccc_unicode c1
                               ON SAFE_SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SAFE_SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
                     LEFT JOIN ccc_unicode c2
                               ON SAFE_SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SAFE_SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
                     LEFT JOIN ccc_unicode c3
                               ON SAFE_SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SAFE_SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
                     LEFT JOIN ccc_unicode c4
                               ON SAFE_SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SAFE_SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
                     LEFT JOIN ccc_unicode c5
                               ON SAFE_SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SAFE_SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
                     LEFT JOIN ccc_unicode c6
                               ON SAFE_SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SAFE_SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
            WHERE c.hospital_code = par_hospital_code
              AND c.case_no = par_case_no;

            IF NOT FOUND THEN
                pas_return_code := -1;
                par_retcode := -1;
                par_error_msg := 'Patient not found for this case number';
                RETURN;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                pas_return_code := -1;
                par_retcode := -1;
                par_error_msg := 'Error in selecting body information';
                RETURN;
        END;
    ELSIF par_hkid IS NOT NULL THEN
        BEGIN
            SELECT p.hkid,
                   p.patient_name,
                   p.sex,
                   p.cccode1,
                   p.cccode2,
                   p.cccode3,
                   p.cccode4,
                   p.cccode5,
                   p.cccode6,
                   c1.unicode_int,
                   c2.unicode_int,
                   c3.unicode_int,
                   c4.unicode_int,
                   c5.unicode_int,
                   c6.unicode_int,
                   p.dob,
                   p.exact_dob_flag,
                   p.death_date,
                   SAFE_SUBSTRING(p.filler, 2, 1),
                   p.patient_key
            INTO par_hkid, par_patient_name, par_sex,
                par_cccode1, par_cccode2, par_cccode3,
                par_cccode4, par_cccode5, par_cccode6,
                par_unicode1, par_unicode2, par_unicode3,
                par_unicode4, par_unicode5, par_unicode6,
                par_dob, par_exact_dob_flag, par_death_date,
                par_body_category, var_patient_key
            FROM patient p
                     LEFT JOIN ccc_unicode c1
                               ON SAFE_SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND SAFE_SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
                     LEFT JOIN ccc_unicode c2
                               ON SAFE_SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND SAFE_SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
                     LEFT JOIN ccc_unicode c3
                               ON SAFE_SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND SAFE_SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
                     LEFT JOIN ccc_unicode c4
                               ON SAFE_SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND SAFE_SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
                     LEFT JOIN ccc_unicode c5
                               ON SAFE_SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND SAFE_SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
                     LEFT JOIN ccc_unicode c6
                               ON SAFE_SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND SAFE_SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
            WHERE p.hkid = par_hkid;

            IF NOT FOUND THEN
                pas_return_code := -1;
                par_retcode := -1;
                par_error_msg := 'Patient not found';
                RETURN;
            END IF;

            IF par_case_no IS NULL THEN
                SELECT case_no
                INTO par_case_no
                FROM pmi_case
                WHERE patient_key = var_patient_key
                  AND discharge_code = '1';
            END IF;

            par_lof_hkid := NULL;
            SELECT hkid
            INTO par_lof_hkid
            FROM last_office_form_log
            WHERE last_case_no = par_case_no
              AND last_hospital_code = par_hospital_code
              AND action_type = 'A'
            GROUP BY hkid, issue_datetime
            HAVING MAX(issue_datetime) = issue_datetime
            ORDER BY issue_datetime ASC
            LIMIT 1;
        EXCEPTION
            WHEN OTHERS THEN
                pas_return_code := -1;
                par_retcode := -1;
                par_error_msg := 'Error in selecting body information';
                RETURN;
        END;
    END IF;

    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "web_hkpmi_get_body_info_v2" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

