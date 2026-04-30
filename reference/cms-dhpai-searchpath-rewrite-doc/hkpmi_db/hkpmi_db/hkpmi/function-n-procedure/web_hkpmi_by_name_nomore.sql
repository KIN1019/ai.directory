-- DROP PROCEDURE hkpmi.web_hkpmi_by_name_nomore(inout int4, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in int4, in varchar, in int4);

CREATE OR REPLACE PROCEDURE hkpmi.web_hkpmi_by_name_nomore(INOUT pas_return_code integer, IN par_name character varying, IN par_sex character varying, IN par_from_dob timestamp without time zone, IN par_to_dob timestamp without time zone, IN par_last_name character varying, IN par_last_hkid character varying, IN par_authority_code integer, IN par_hosp_code character varying, IN par_row_count integer DEFAULT 301, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    /* --par_hosp_code	VARCHAR(3), */
    var_temp_int INTEGER;
    var_err INTEGER;
    var_t_dob TIMESTAMP WITHOUT TIME ZONE;
    var_t_mrn VARCHAR(16);
    var_t_hkid VARCHAR(24);
    var_t_name VARCHAR(96);
    var_t_tel VARCHAR(20);
    var_t_sex VARCHAR(2);
    var_i INTEGER;
    var_t_cccode1 INTEGER;
    var_t_cccode2 INTEGER;
    var_t_cccode3 INTEGER;
    var_t_cccode4 INTEGER;
    var_t_cccode5 INTEGER;
    var_t_cccode6 INTEGER;
    pmi_csr cursor for
                SELECT p.hkid,
                    p.patient_name,
                    p.sex,
                    p.dob,
                    h.mrn,
                    p.phone1,
                    c1.unicode_int AS unicode_int1,
                    c2.unicode_int AS unicode_int2,
                    c3.unicode_int AS unicode_int3,
                    c4.unicode_int AS unicode_int4,
                    c5.unicode_int AS unicode_int5,
                    c6.unicode_int AS unicode_int6
                FROM patient p
                        LEFT JOIN
                    patient_hospital_data h ON p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code
                        LEFT JOIN
                    ccc_unicode c1 ON c1.ccc_head = substring(p.cccode1, 1, 4) AND c1.ccc_tail = substring(p.cccode1, 5, 1)
                        LEFT JOIN
                    ccc_unicode c2 ON c2.ccc_head = substring(p.cccode2, 1, 4) AND c2.ccc_tail = substring(p.cccode2, 5, 1)
                        LEFT JOIN
                    ccc_unicode c3 ON c3.ccc_head = substring(p.cccode3, 1, 4) AND c3.ccc_tail = substring(p.cccode3, 5, 1)
                        LEFT JOIN
                    ccc_unicode c4 ON c4.ccc_head = substring(p.cccode4, 1, 4) AND c4.ccc_tail = substring(p.cccode4, 5, 1)
                        LEFT JOIN
                    ccc_unicode c5 ON c5.ccc_head = substring(p.cccode5, 1, 4) AND c5.ccc_tail = substring(p.cccode5, 5, 1)
                        LEFT JOIN
                    ccc_unicode c6 ON c6.ccc_head = substring(p.cccode6, 1, 4) AND c6.ccc_tail = substring(p.cccode6, 5, 1)
                WHERE p.patient_name LIKE par_name
                AND p.patient_name >= par_last_name
                AND p.sex in (select unnest(string_to_array(RTRIM(par_sex), null)))
                AND (p.access_code & par_authority_code) > 0
                -- AND h.hospital_code = par_hosp_code
                ORDER BY p.patient_name, p.hkid;
    pmi_csr_dob cursor for
                SELECT p.hkid,
                    p.patient_name,
                    p.sex,
                    p.dob,
                    h.mrn,
                    p.phone1,
                    c1.unicode_int AS unicode_int1,
                    c2.unicode_int AS unicode_int2,
                    c3.unicode_int AS unicode_int3,
                    c4.unicode_int AS unicode_int4,
                    c5.unicode_int AS unicode_int5,
                    c6.unicode_int AS unicode_int6
                FROM patient p
                        LEFT JOIN
                    patient_hospital_data h ON p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code
                        LEFT JOIN
                    ccc_unicode c1 ON c1.ccc_head = substring(p.cccode1, 1, 4) AND c1.ccc_tail = substring(p.cccode1, 5, 1)
                        LEFT JOIN
                    ccc_unicode c2 ON c2.ccc_head = substring(p.cccode2, 1, 4) AND c2.ccc_tail = substring(p.cccode2, 5, 1)
                        LEFT JOIN
                    ccc_unicode c3 ON c3.ccc_head = substring(p.cccode3, 1, 4) AND c3.ccc_tail = substring(p.cccode3, 5, 1)
                        LEFT JOIN
                    ccc_unicode c4 ON c4.ccc_head = substring(p.cccode4, 1, 4) AND c4.ccc_tail = substring(p.cccode4, 5, 1)
                        LEFT JOIN
                    ccc_unicode c5 ON c5.ccc_head = substring(p.cccode5, 1, 4) AND c5.ccc_tail = substring(p.cccode5, 5, 1)
                        LEFT JOIN
                    ccc_unicode c6 ON c6.ccc_head = substring(p.cccode6, 1, 4) AND c6.ccc_tail = substring(p.cccode6, 5, 1)
                WHERE p.patient_name LIKE par_name
                AND p.patient_name >= par_last_name
                AND p.sex in (select unnest(string_to_array(RTRIM(par_sex), null)))
                AND p.dob >= par_from_dob
                AND p.dob <= par_to_dob
                AND (p.access_code & par_authority_code) > 0
                -- AND h.hospital_code = par_hosp_code
                ORDER BY p.patient_name, p.hkid;
BEGIN
    /* get hospital code */
    DROP TABLE IF EXISTS t$temp_patient_list;
    CREATE TEMPORARY TABLE t$temp_patient_list
    (
        --"row_no" BIGINT GENERATED ALWAYS AS IDENTITY,
        /* ---- To fix: SRV 16  #311  The optimizer could not find a unique index which it could use to scan table '#temp_patient_list' for cursor 'csr'. */
        "hkid" VARCHAR(24) NULL,
        "name" VARCHAR(96) NULL,
        "sex" VARCHAR(2) NULL,
        "dob" TIMESTAMP WITHOUT TIME ZONE NULL,
        "mrn" VARCHAR(16) NULL,
        "home_phone" VARCHAR(20) NULL,
        "cccode1" INTEGER NULL,
        "cccode2" INTEGER NULL,
        "cccode3" INTEGER NULL,
        "cccode4" INTEGER NULL,
        "cccode5" INTEGER NULL,
        "cccode6" INTEGER NULL,
        "chi_name" VARCHAR(24) NULL,
        "schi_name" VARCHAR(24) NULL);
    --CREATE UNIQUE INDEX t$temp_patient_list_idx ON t$temp_patient_list
    --    ("row_no");

    /* --select par_hosp_code = Hospital_code from Hospital */
    /* process name & sex */
    SELECT CONCAT(RTRIM(par_name), '%')
    INTO par_name;

    /* process user authority code */
    CALL hkpmi_get_int_by_bit(pas_return_code, 'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
    SELECT par_authority_code & var_temp_int
    INTO par_authority_code;

    SELECT
        0
        INTO var_i;

    IF par_from_dob is NULL THEN
        BEGIN
            /* --insert #temp_patient_list ---Should not use select into which depend on DB option... */
            OPEN pmi_csr;
            WHILE var_i < par_row_count LOOP
                FETCH pmi_csr INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

                IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) != 0 THEN
                    EXIT;
                END IF;
                INSERT INTO t$temp_patient_list
                VALUES (var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6, NULL, NULL);
                SELECT
                    var_i + 1
                    INTO var_i;
            END LOOP;
            CLOSE pmi_csr;
        END;
    ELSE
        BEGIN
            OPEN pmi_csr_dob;
            WHILE var_i < par_row_count LOOP
                FETCH pmi_csr_dob INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

                IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) != 0 THEN
                    EXIT;
                END IF;
                INSERT INTO t$temp_patient_list
                VALUES (var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6, NULL, NULL);
                SELECT
                    var_i + 1
                    INTO var_i;
            END LOOP;
            CLOSE pmi_csr_dob;
        END;
    END IF;

    OPEN p_refcur FOR
    SELECT
        hkid, name, sex, dob, mrn, home_phone, cccode1 AS unicode_int1, cccode2 AS unicode_int2, cccode3 AS unicode_int3, cccode4 AS unicode_int4, cccode5 AS unicode_int5, cccode6 AS unicode_int6
        FROM t$temp_patient_list
        ORDER BY name NULLS FIRST, hkid NULLS FIRST;
    /* ----set rowcount 0 */
    pas_return_code := 0;
    RETURN;
    -- DROP TABLE t$temp_patient_list;
    -- return_code := - 1;
    -- RETURN;

    -- /* Users do not input Age on the PSP screen */
    -- IF par_from_dob is NULL THEN
    --     BEGIN
    --         OPEN p_refcur FOR
    --             SELECT p.hkid,
    --                 p.patient_name,
    --                 p.sex,
    --                 p.dob,
    --                 h.mrn,
    --                 p.phone1,
    --                 c1.unicode_int AS unicode_int1,
    --                 c2.unicode_int AS unicode_int2,
    --                 c3.unicode_int AS unicode_int3,
    --                 c4.unicode_int AS unicode_int4,
    --                 c5.unicode_int AS unicode_int5,
    --                 c6.unicode_int AS unicode_int6
    --             FROM patient p
    --                     LEFT JOIN
    --                 patient_hospital_data h ON p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code
    --                     LEFT JOIN
    --                 ccc_unicode c1 ON c1.ccc_head = substring(p.cccode1, 1, 4) AND c1.ccc_tail = substring(p.cccode1, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c2 ON c2.ccc_head = substring(p.cccode2, 1, 4) AND c2.ccc_tail = substring(p.cccode2, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c3 ON c3.ccc_head = substring(p.cccode3, 1, 4) AND c3.ccc_tail = substring(p.cccode3, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c4 ON c4.ccc_head = substring(p.cccode4, 1, 4) AND c4.ccc_tail = substring(p.cccode4, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c5 ON c5.ccc_head = substring(p.cccode5, 1, 4) AND c5.ccc_tail = substring(p.cccode5, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c6 ON c6.ccc_head = substring(p.cccode6, 1, 4) AND c6.ccc_tail = substring(p.cccode6, 5, 1)
    --             WHERE p.patient_name LIKE par_name
    --             AND p.patient_name >= par_last_name
    --             AND p.sex in (select unnest(string_to_array(RTRIM(par_sex), null)))
    --             AND (p.access_code & par_authority_code) > 0
    --             -- AND h.hospital_code = par_hosp_code
    --             ORDER BY p.patient_name, p.hkid
    --             limit par_row_count;
    --     END;
    -- END IF;
    -- /* Users input Age on the PSP screen, frontend calculates the DOB range from the Age */

    -- IF par_from_dob is not NULL THEN
    --     BEGIN
    --         OPEN p_refcur FOR
    --             SELECT p.hkid,
    --                 p.patient_name,
    --                 p.sex,
    --                 p.dob,
    --                 h.mrn,
    --                 p.phone1,
    --                 c1.unicode_int AS unicode_int1,
    --                 c2.unicode_int AS unicode_int2,
    --                 c3.unicode_int AS unicode_int3,
    --                 c4.unicode_int AS unicode_int4,
    --                 c5.unicode_int AS unicode_int5,
    --                 c6.unicode_int AS unicode_int6
    --             FROM patient p
    --                     LEFT JOIN
    --                 patient_hospital_data h ON p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code
    --                     LEFT JOIN
    --                 ccc_unicode c1 ON c1.ccc_head = substring(p.cccode1, 1, 4) AND c1.ccc_tail = substring(p.cccode1, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c2 ON c2.ccc_head = substring(p.cccode2, 1, 4) AND c2.ccc_tail = substring(p.cccode2, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c3 ON c3.ccc_head = substring(p.cccode3, 1, 4) AND c3.ccc_tail = substring(p.cccode3, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c4 ON c4.ccc_head = substring(p.cccode4, 1, 4) AND c4.ccc_tail = substring(p.cccode4, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c5 ON c5.ccc_head = substring(p.cccode5, 1, 4) AND c5.ccc_tail = substring(p.cccode5, 5, 1)
    --                     LEFT JOIN
    --                 ccc_unicode c6 ON c6.ccc_head = substring(p.cccode6, 1, 4) AND c6.ccc_tail = substring(p.cccode6, 5, 1)
    --             WHERE p.patient_name LIKE par_name
    --             AND p.patient_name >= par_last_name
    --             AND p.sex in (select unnest(string_to_array(RTRIM(par_sex), null)))
    --             AND p.dob >= par_from_dob
    --             AND p.dob <= par_to_dob
    --             AND (p.access_code & par_authority_code) > 0
    --             -- AND h.hospital_code = par_hosp_code
    --             ORDER BY p.patient_name, p.hkid
    --             limit par_row_count;
    --     END;
    -- END IF;
    -- pas_return_code := 0;
    -- RETURN;
END;
$procedure$
;


ALTER PROCEDURE "web_hkpmi_by_name_nomore" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

