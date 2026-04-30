-- DROP PROCEDURE hpi.hasp_get_ward_patient_list(inout int4, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_ward_patient_list(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_ward character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code for HPI by ML on 30.09.1999 */
DECLARE
    var_hkid VARCHAR(12);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_ccc_1 VARCHAR(05);
    var_ccc_2 VARCHAR(05);
    var_ccc_3 VARCHAR(05);
    var_ccc_4 VARCHAR(05);
    var_ccc_5 VARCHAR(05);
    var_ccc_6 VARCHAR(05);
    var_case_no VARCHAR(12);
    var_chinese_name VARCHAR(12);
    var_big_5 VARCHAR(02);
    var_cname VARCHAR(12);
    var_age VARCHAR(05);
    var_end_date TIMESTAMP WITHOUT TIME ZONE;
    var_access_code INTEGER;
    var_scname VARCHAR(12);
    var_is_schi_name VARCHAR(01);
    var_phonetic VARCHAR(48);
    ward_list_csr CURSOR FOR
    SELECT
        ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, hkid, case_no, dob, death_date, chinese_name, age
        FROM t$temp_ward_list;
    var_return_code int;
    sql$rowcount BIGINT;
BEGIN
    /* 2006-09-18 Addeded by HK Fong SMR20015696 - Start */
    /* 2006-09-18 Addeded by HK Fong SMR20015696 - End */
    /* create a temp. patient list table */
    DROP TABLE IF EXISTS t$temp_ward_list;
    CREATE TEMPORARY TABLE t$temp_ward_list
    (HKID VARCHAR(12) NOT NULL,
        Name VARCHAR(48) NOT NULL,
        Sex VARCHAR(01) NULL,
        DOB TIMESTAMP WITHOUT TIME ZONE NULL,
        CCC_1 VARCHAR(05) NULL,
        CCC_2 VARCHAR(05) NULL,
        CCC_3 VARCHAR(05) NULL,
        CCC_4 VARCHAR(05) NULL,
        CCC_5 VARCHAR(05) NULL,
        CCC_6 VARCHAR(05) NULL,
        Death_date TIMESTAMP WITHOUT TIME ZONE NULL,
        Admission_datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        Case_no VARCHAR(12) NOT NULL,
        Ward_code VARCHAR(04) NOT NULL,
        Specialty_code VARCHAR(04) NOT NULL,
        Bed_no VARCHAR(05) NULL,
        Chinese_name VARCHAR(12) NULL,
        Age VARCHAR(05) NULL,
        Access_code INTEGER NOT NULL,
        SChinese_name VARCHAR(12) NULL /* 2006-09-18 Addeded by HK Fong SMR20015696 */);
    
    ALTER TABLE t$temp_ward_list ADD CONSTRAINT temp_ward_list_pkey PRIMARY KEY (HKID, Case_no);
    /*
    [7610 - Severity CRITICAL - Unsupported DDL statement. Perform a manual conversion.]
    Alter table #temp_ward_list add primary key (HKID, Case_no)
    */
    /* changed by Karen at 1996-04-30 for cpi */
    /* before changes are comment for select from Case_view written below */
    /* get all patient in the specified ward */
    /*
    insert #temp_ward_list
    select	PMI.HKID,
    	PMI.Name,
    	PMI.Sex,
    	PMI.DOB,
    	PMI.CCC_1,
    	PMI.CCC_2,
    	PMI.CCC_3,
    	PMI.CCC_4,
    	PMI.CCC_5,
    	PMI.CCC_6,
    	PMI.Death_date,
    	Case.Admission_datetime,
    	Ward_list.Case_no,
    	Ward_list.Ward_code,
    	Ward_list.Specialty_code,
    	Ward_list.Bed_no,
    	Chinese_name = space(12),
    	Age = space(5)
      from  Case, PMI, Ward_list
     where  PMI.HKID = Case.HKID and
    	Case.Case_no = Ward_list.Case_no and
    	Ward_list.Ward_code = @ward
    */
    /* end of comment */
    /* change to use PMI_wo_MRN instead of PMI for HPI */
    /* and add hosp code for HPI by ML on 30.08.1999 */
    /* modify start for select from Case_view */
    /* get all patient in the specified ward */
    /*
    insert #temp_ward_list
            select	PMI.HKID,
    		PMI.Name,
    		PMI.Sex,
    		PMI.DOB,
    		PMI.CCC_1,
    		PMI.CCC_2,
    		PMI.CCC_3,
    		PMI.CCC_4,
    		PMI.CCC_5,
    		PMI.CCC_6,
    		PMI.Death_date,
    		Case_view.Admission_datetime,
    		Ward_list.Case_no,
    		Ward_list.Ward_code,
    		Ward_list.Specialty_code,
    		Ward_list.Bed_no,
    		Chinese_name = space(12),
    		Age = space(5)
    	  from  Case_view, PMI, Ward_list
    	 where  PMI.HKID = Case_view.HKID and
    		Case_view.Case_no = Ward_list.Case_no and
    --		Ward_list.Ward_code = @ward
    		Ward_list.Ward_code like @ward
    */
    /*
    ---------------------------------------
    	insert #temp_ward_list
    	select PMI_wo_MRN.HKID, PMI_wo_MRN.Name, PMI_wo_MRN.Sex, PMI_wo_MRN.DOB,
    	       PMI_wo_MRN.CCC_1, PMI_wo_MRN.CCC_2, PMI_wo_MRN.CCC_3,
    	       PMI_wo_MRN.CCC_4, PMI_wo_MRN.CCC_5, PMI_wo_MRN.CCC_6,
    	       PMI_wo_MRN.Death_date, Case_view.Admission_datetime, Ward_list.Case_no,
    	       Ward_list.Ward_code, Ward_list.Specialty_code, Ward_list.Bed_no,
    	       Chinese_name = space(12), Age = space(5), PMI_wo_MRN.Access_code,
    	       SChinese_name = space(12)	--- 2006-09-18 Addeded by HK Fong SMR20015696
    	  from Case_view, PMI_wo_MRN, Ward_list
    	 where PMI_wo_MRN.HKID = Case_view.HKID and
    	       Case_view.Case_no = Ward_list.Case_no and
    	       Ward_list.Ward_code like @ward  and
    	       Case_view.Hospital_code = @hosp_code and
    	       Ward_list.Hospital_code = @hosp_code
    	--- end of modify
        ------------------------------------------------------
    */
    
    /* ----Begin 20130924 --------- */
    INSERT INTO t$temp_ward_list
    SELECT
        pa.hkid AS hkid, pa.patient_name AS name, pa.sex AS sex, pa.dob AS dob, pa.cccode1 AS ccc_1, pa.cccode2 AS ccc_2, pa.cccode3 AS ccc_3, pa.cccode4 AS ccc_4, pa.cccode5 AS ccc_5, pa.cccode6 AS ccc_6, pa.death_date AS death_date, ca.admission_dtm AS admission_datetime, wl.Case_no, wl.Ward_code, wl.Specialty_code, wl.Bed_no, REPEAT(' ', 12) AS Chinese_name, REPEAT(' ', 5) AS Age, pa.access_code AS access_code, REPEAT(' ', 12) AS SChinese_name /* 2006-09-02 Addeded by HK Fong SMR20015696 */
        FROM cpi_case AS ca, cpi_patient AS pa, Ward_list AS wl
        WHERE pa.patient_key = ca.patient_key AND ca.case_no = wl.Case_no AND wl.Ward_code LIKE par_ward;
    /* ---- END 20130924 --------- */
    
    /* get chinese name for each row */ 
    /* 2006-09-18 Addeded by HK Fong SMR20015696 */
    OPEN ward_list_csr;
    FETCH ward_list_csr INTO var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_hkid, var_case_no, var_dob, var_death_date, var_chinese_name, var_age;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        /* calculate age */
        IF var_dob is not NULL THEN
            BEGIN
                IF var_death_date IS NULL THEN
                    SELECT
                        timestamp_convert(localtimestamp)
                        INTO var_end_date;
                ELSE
                    SELECT
                        var_death_date
                        INTO var_end_date;
                END IF;
                CALL hasp_cal_age(var_return_code, var_dob, var_end_date, var_age);
            END;
        END IF;
        /* map ccc code to unicode_char */
        SELECT
            REPEAT(' ', 0)
            INTO var_cname;
        /* get unicode_char for ccc 1 */
        IF LENGTH(NULLIF(var_ccc_1, '')) > 0 THEN
            BEGIN
                SELECT
                    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    				-- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    				/* unicode_char */null
                    INTO var_big_5
                    FROM ccc_unicode
                    WHERE CCC_head = SUBSTRING(var_ccc_1, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_1, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 0 THEN
                    SELECT
                        CONCAT(var_cname, var_big_5)
                        INTO var_cname;
                ELSE
                    SELECT
                        CONCAT(var_cname, REPEAT(' ', 2))
                        INTO var_cname;
                END IF;
            END;
        END IF;
        /* get unicode_char for ccc 2 */
        IF LENGTH(NULLIF(var_ccc_2, '')) > 0 THEN
            BEGIN
                SELECT
                    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    				-- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    				/* unicode_char */null
                    INTO var_big_5
                    FROM ccc_unicode
                    WHERE CCC_head = SUBSTRING(var_ccc_2, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_2, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 0 THEN
                    SELECT
                        CONCAT(var_cname, var_big_5)
                        INTO var_cname;
                ELSE
                    SELECT
                        CONCAT(var_cname, REPEAT(' ', 2))
                        INTO var_cname;
                END IF;
            END;
        END IF;
        /* get unicode_char for ccc 3 */
        IF LENGTH(NULLIF(var_ccc_3, '')) > 0 THEN
            BEGIN
                SELECT
                    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    				-- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    				/* unicode_char */null
                    INTO var_big_5
                    FROM ccc_unicode
                    WHERE CCC_head = SUBSTRING(var_ccc_3, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_3, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 0 THEN
                    SELECT
                        CONCAT(var_cname, var_big_5)
                        INTO var_cname;
                ELSE
                    SELECT
                        CONCAT(var_cname, REPEAT(' ', 2))
                        INTO var_cname;
                END IF;
            END;
        END IF;
        /* get unicode_char for ccc 4 */
        IF LENGTH(NULLIF(var_ccc_4, '')) > 0 THEN
            BEGIN
                SELECT
                    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    				-- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    				/* unicode_char */null
                    INTO var_big_5
                    FROM ccc_unicode
                    WHERE CCC_head = SUBSTRING(var_ccc_4, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_4, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 0 THEN
                    SELECT
                        CONCAT(var_cname, var_big_5)
                        INTO var_cname;
                ELSE
                    SELECT
                        CONCAT(var_cname, REPEAT(' ', 2))
                        INTO var_cname;
                END IF;
            END;
        END IF;
        /* get unicode_char for ccc 5 */
        IF LENGTH(NULLIF(var_ccc_5, '')) > 0 THEN
            BEGIN
                SELECT
                    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    				-- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    				/* unicode_char */null
                    INTO var_big_5
                    FROM ccc_unicode
                    WHERE CCC_head = SUBSTRING(var_ccc_5, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_5, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 0 THEN
                    SELECT
                        CONCAT(var_cname, var_big_5)
                        INTO var_cname;
                ELSE
                    SELECT
                        CONCAT(var_cname, REPEAT(' ', 2))
                        INTO var_cname;
                END IF;
            END;
        END IF;
        /* get unicode_char for ccc 6 */
        IF LENGTH(NULLIF(var_ccc_6, '')) > 0 THEN
            BEGIN
                SELECT
                    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    				-- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    				/* unicode_char */null
                    INTO var_big_5
                    FROM ccc_unicode
                    WHERE CCC_head = SUBSTRING(var_ccc_6, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_6, 5, 1);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 0 THEN
                    SELECT
                        CONCAT(var_cname, var_big_5)
                        INTO var_cname;
                ELSE
                    SELECT
                        CONCAT(var_cname, REPEAT(' ', 2))
                        INTO var_cname;
                END IF;
            END;
        END IF;
        /* 2006-09-18 Addeded by HK Fong SMR20015696 - Start */
        IF COALESCE(var_cname, '') <> '' THEN
            BEGIN
                CALL hasp_check_schi_name(pas_return_code => var_return_code, par_ccc1 => var_ccc_1, par_ccc2 => var_ccc_2, par_ccc3 => var_ccc_3, par_ccc4 => var_ccc_4, par_ccc5 => var_ccc_5, par_ccc6 => var_ccc_6, par_is_schi_name => var_is_schi_name);

                IF var_is_schi_name = 'Y' THEN
                    SELECT
                        var_cname
                        INTO var_scname;
                ELSE
                    SELECT
                        ''
                        INTO var_scname;
                END IF;
            END;
        ELSE
            SELECT
                ''
                INTO var_scname;
        END IF;
        /* 2006-09-18 Addeded by HK Fong SMR20015696 - End */
        /* update chinese name to the temp table */
        UPDATE t$temp_ward_list
        SET Chinese_name = var_cname, Age = var_age, SChinese_name = var_scname /* 2006-09-18 Addeded by HK Fong SMR20015696 */
            WHERE CURRENT OF ward_list_csr;
        /* get next row */
        FETCH ward_list_csr INTO var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_hkid, var_case_no, var_dob, var_death_date, var_chinese_name, var_age;
    END LOOP;
    CLOSE ward_list_csr;
    /* modified as order by Admission datetime to cater yr 2000 */
    /* by Mabel Lau */
    /* select * from #temp_ward_list order by Case_no */
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
    SELECT
        t$temp_ward_list.hkid, t$temp_ward_list.name, t$temp_ward_list.sex, t$temp_ward_list.dob, t$temp_ward_list.ccc_1, t$temp_ward_list.ccc_2, t$temp_ward_list.ccc_3, t$temp_ward_list.ccc_4, t$temp_ward_list.ccc_5, t$temp_ward_list.ccc_6, t$temp_ward_list.death_date, t$temp_ward_list.admission_datetime, t$temp_ward_list.case_no, t$temp_ward_list.ward_code, t$temp_ward_list.specialty_code, t$temp_ward_list.bed_no, t$temp_ward_list.chinese_name, t$temp_ward_list.age, t$temp_ward_list.access_code, t$temp_ward_list.schinese_name
        FROM t$temp_ward_list
        ORDER BY ward_code NULLS FIRST, admission_datetime NULLS FIRST;
    /* end of modification */
    pas_return_code := 0;
    if (var_return_code is not null) AND var_return_code <> 0 then
        pas_return_code := var_return_code;
    END IF;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_ward_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_ward_patient_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";