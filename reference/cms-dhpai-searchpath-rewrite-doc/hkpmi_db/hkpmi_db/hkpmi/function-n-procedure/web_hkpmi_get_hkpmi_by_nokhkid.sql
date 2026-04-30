CREATE OR REPLACE PROCEDURE web_hkpmi_get_hkpmi_by_nokhkid(INOUT pas_return_code int,IN par_nok_hkid VARCHAR, IN par_last_name VARCHAR, IN par_last_hkid VARCHAR, IN par_authority_code INTEGER, IN par_hosp_code VARCHAR,  INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_temp_int INTEGER;
    var_err INTEGER;
    var_t_dob TIMESTAMP WITHOUT TIME ZONE;
    var_t_mrn VARCHAR(8);
    var_t_hkid VARCHAR(12);
    var_t_name VARCHAR(48);
    var_t_tel VARCHAR(10);
    var_t_sex VARCHAR(01);
    var_i INTEGER;
    var_t_cccode1 VARCHAR(5);
    var_t_cccode2 VARCHAR(5);
    var_t_cccode3 VARCHAR(5);
    var_t_cccode4 VARCHAR(5);
    var_t_cccode5 VARCHAR(5);
    var_t_cccode6 VARCHAR(5);
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
    var_hkid VARCHAR(12);
    pmi_csr CURSOR FOR
    SELECT
        p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
        FROM nok AS n, patient AS p
        LEFT OUTER JOIN patient_hospital_data AS h
            ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
        WHERE
        /* --paging modify */
        n.hkid = par_nok_hkid AND n.major_nok = 'Y' AND p.patient_name >= par_last_name AND n.patient_key = p.patient_key AND (p.access_code & par_authority_code) > 0;
BEGIN
    /* for search patient list by major nok hkid only */
    /* if search by major nok name, use web_hkpmi_get_hkpmi_by_nokname */
    DROP TABLE IF EXISTS t$temp_patient_list;
    CREATE TEMPORARY TABLE t$temp_patient_list
    (row_no BIGINT GENERATED ALWAYS AS IDENTITY,
        /* ---- To fix, SRV 16  #311  The optimizer could not find a unique index which it could use to scan table '#temp_patient_list' for cursor 'csr'. */
        hkid VARCHAR(12) NULL,
        name VARCHAR(48) NULL,
        sex VARCHAR(1) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        mrn VARCHAR(8) NULL,
        phone1 VARCHAR(10) NULL,
        cccode1 VARCHAR(05) NULL,
        cccode2 VARCHAR(05) NULL,
        cccode3 VARCHAR(05) NULL,
        cccode4 VARCHAR(05) NULL,
        cccode5 VARCHAR(05) NULL,
        cccode6 VARCHAR(05) NULL);
    CREATE UNIQUE INDEX t$temp_patient_list_idx ON t$temp_patient_list
        (row_no);
    CALL hkpmi_get_int_by_bit(pas_return_code,'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
    SELECT
        par_authority_code & var_temp_int
        INTO par_authority_code;
    /* --- by major nok hkid ----- */
    OPEN pmi_csr;
    /* --paging modify */
    IF par_last_hkid IS NOT NULL THEN
        BEGIN
            WHILE 1 = 1 LOOP
                FETCH pmi_csr INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

                IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) != 0 OR var_t_hkid = par_last_hkid THEN
                    EXIT;
                END IF;
            END LOOP;
        END;
    END IF;
    SELECT
        0
        INTO var_i;
    /* --while @i < 200		---- set rowcount  200 */

    WHILE var_i < 11 LOOP /* --paging modify */
        FETCH pmi_csr INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

        IF (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) != 0 THEN
            EXIT;
        END IF;
        INSERT INTO t$temp_patient_list (hkid,name,sex,dob,mrn,phone1,cccode1,cccode2,cccode3,cccode4,cccode5,cccode6)
        VALUES (var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6);
        SELECT
            var_i + 1
            INTO var_i;
    END LOOP;
    CLOSE pmi_csr;
    /*
    [9996 - Severity CRITICAL - Transformer error occurred in fromClause. Please submit report to developers.]
    select hkid,name,sex,dob,mrn,phone1,
    	c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
    	c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6
    	from #temp_patient_list p,ccc_big5 c1, ccc_big5 c2, ccc_big5 c3, ccc_big5 c4, ccc_big5 c5, ccc_big5 c6
    	where c1.ccc_head =* substring(p.cccode1, 1, 4) and c1.ccc_tail =* substring(p.cccode1, 5, 1)
    	and c2.ccc_head =* substring(p.cccode2, 1, 4) and c2.ccc_tail =* substring(p.cccode2, 5, 1)
    	and c3.ccc_head =* substring(p.cccode3, 1, 4) and c3.ccc_tail =* substring(p.cccode3, 5, 1)
    	and c4.ccc_head =* substring(p.cccode4, 1, 4) and c4.ccc_tail =* substring(p.cccode4, 5, 1)
    	and c5.ccc_head =* substring(p.cccode5, 1, 4) and c5.ccc_tail =* substring(p.cccode5, 5, 1)
    	and c6.ccc_head =* substring(p.cccode6, 1, 4) and c6.ccc_tail =* substring(p.cccode6, 5, 1)
    */
    open p_refcur for select hkid,name,sex,dob,mrn,phone1,
    	c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
    	c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6    
    from t$temp_patient_list p
    RIGHT JOIN ccc_unicode c1 ON c1.ccc_head = substring(p.cccode2, 1, 4) and c1.ccc_tail = substring(p.cccode2, 5, 1)
    RIGHT JOIN ccc_unicode c2 ON c2.ccc_head = substring(p.cccode2, 1, 4) and c2.ccc_tail = substring(p.cccode2, 5, 1)
    RIGHT JOIN ccc_unicode c3 ON c3.ccc_head = substring(p.cccode3, 1, 4) and c3.ccc_tail = substring(p.cccode3, 5, 1)
    RIGHT JOIN ccc_unicode c4 ON c4.ccc_head = substring(p.cccode4, 1, 4) and c4.ccc_tail = substring(p.cccode4, 5, 1)
    RIGHT JOIN ccc_unicode c5 ON c5.ccc_head = substring(p.cccode5, 1, 4) and c5.ccc_tail = substring(p.cccode5, 5, 1)
    RIGHT JOIN ccc_unicode c6 ON c6.ccc_head = substring(p.cccode6, 1, 4) and c6.ccc_tail = substring(p.cccode6, 5, 1);


    -- DROP TABLE t$temp_patient_list;
    /* ----set rowcount 0 */
    pas_return_code := 0;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_patient_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

ALTER PROCEDURE "web_hkpmi_get_hkpmi_by_nokhkid" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
