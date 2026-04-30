-- DROP FUNCTION hpi.hasp_get_admission_by(varchar, timestamp, timestamp, int4, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_get_admission_by(par_hosp_code character varying, par_trans_fdatetime timestamp without time zone, par_trans_tdatetime timestamp without time zone, par_func_id integer, par_search character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
 
DECLARE
p_refcur refcursor;
var_header VARCHAR(40);
    var_header_desc VARCHAR(200);
    var_religion_code VARCHAR(6);
    var_specialty_desc VARCHAR(200);
    var_specialty_code VARCHAR(8);
    var_hkid VARCHAR(24);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_case_no VARCHAR(24);
    var_age VARCHAR(10);
    var_end_date TIMESTAMP WITHOUT TIME ZONE;
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_building VARCHAR(510);
    var_room VARCHAR(10);
    var_floor VARCHAR(4);
    var_block VARCHAR(4);
    var_district_code VARCHAR(10);
    var_address VARCHAR(510);
    var_nok_hkid VARCHAR(24);
    var_nok_name VARCHAR(96);
    var_nok_home_phone_no VARCHAR(20);
    var_nok_name1 VARCHAR(96);
    var_flag VARCHAR(2);
    var_ccc_1 VARCHAR(10);
    var_ccc_2 VARCHAR(10);
    var_ccc_3 VARCHAR(10);
    var_ccc_4 VARCHAR(10);
    var_ccc_5 VARCHAR(10);
    var_ccc_6 VARCHAR(10);
    var_chinese_name VARCHAR(24);
    var_big_5 VARCHAR(4);
    var_cname VARCHAR(24);
    var_total INTEGER;
    var_mark VARCHAR(2);
    var_scname VARCHAR(24);
    var_is_schi_name VARCHAR(2);
    var_phonetic VARCHAR(96);
    var_addr_code INTEGER;
    var_addr_eng VARCHAR(510);
    var_addr_chi VARCHAR(510);
    var_addr_dist VARCHAR(10);
    var_return_code INTEGER;
    var_addr_eh_eng VARCHAR(510);
    var_addr_eh_chi VARCHAR(510);
    temp_table_csr CURSOR FOR
SELECT
    mark, case_no, hkid, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, dob, death_date, admission_datetime, building, room, floor, block, district_code, address, chinese_name, age, religion_code, specialty_code, specialty_desc, header_desc
FROM t$temp_table;
temp_list_csr CURSOR FOR
SELECT
    hkid, case_no
FROM t$temp_table;
temp_nok_csr CURSOR FOR
SELECT
    HKID, Name, Home_phone_no
FROM NOK
WHERE HKID = var_hkid;
BEGIN
    /* --	declare @building		varchar(47) */
    /* 2006-09-18 Addeded by HK Fong SMR20015696 - Start */
    /* 2006-09-18 Addeded by HK Fong SMR20015696 - End */
SELECT
    1 * INTERVAL '1 day' + par_TRANS_TDATETIME::TIMESTAMP
INTO par_TRANS_TDATETIME;
/* create a temp. patient list table */
drop table IF EXISTS t$temp_table;
CREATE TEMPORARY TABLE t$temp_table
    (Header VARCHAR(40) NOT NULL,
        Header_desc VARCHAR(200) NULL,
        Religion_code VARCHAR(6) NULL,
        Mark VARCHAR(2) NULL,
        Case_no VARCHAR(24) NOT NULL,
        Name VARCHAR(96) NOT NULL,
        CCC_1 VARCHAR(10) NULL,
        CCC_2 VARCHAR(10) NULL,
        CCC_3 VARCHAR(10) NULL,
        CCC_4 VARCHAR(10) NULL,
        CCC_5 VARCHAR(10) NULL,
        CCC_6 VARCHAR(10) NULL,
        HKID VARCHAR(24) NOT NULL,
        Sex VARCHAR(2) NULL,
        DOB TIMESTAMP WITHOUT TIME ZONE NULL,
        Marital_status VARCHAR(2) NULL,
        Patient_status VARCHAR(6) NULL,
        Race_code VARCHAR(4) NULL,
        Death_date TIMESTAMP WITHOUT TIME ZONE NULL,
        Admission_datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        Source_indicator VARCHAR(2) NULL,
        Source_code VARCHAR(6) NULL,
        Ward_code VARCHAR(8) NOT NULL,
        Specialty_code VARCHAR(8) NOT NULL,
        Specialty_desc VARCHAR(60) NULL,
        Discharge_datetime TIMESTAMP WITHOUT TIME ZONE NULL,
        Destination_code VARCHAR(6) NULL,
        Medical_record_number VARCHAR(16) NULL,
        Building VARCHAR(94) NULL,
        Room VARCHAR(10) NULL,
        Floor VARCHAR(4) NULL,
        Block VARCHAR(4) NULL,
        District_code VARCHAR(10) NULL,
        Home_phone_no VARCHAR(20) NULL,
        Address VARCHAR(510) NULL,
        Type VARCHAR(6) NULL,
        Chinese_name VARCHAR(24) NULL,
        Age VARCHAR(10) NULL,
        NOK_name1 VARCHAR(96) NULL,
        NOK_phone_no1 VARCHAR(20) NULL,
        NOK_name2 VARCHAR(96) NULL,
        NOK_phone_no2 VARCHAR(20) NULL,
        case_year VARCHAR(8) NULL,
        SChinese_name VARCHAR(24) NULL /* 2006-09-18 Addeded by HK Fong SMR20015696 */);
    /*
    [7610 - Severity CRITICAL - Unsupported DDL statement. Perform a manual conversion.]
    Alter table #temp_table add primary key (Header, Case_no)
    */
    IF par_FUNC_ID = 1221 THEN
SELECT
    'RELIGION'
INTO var_header;
ELSE
        IF par_FUNC_ID = 1222 OR par_FUNC_ID = 1223 THEN
SELECT
    'SPECIALTY'
INTO var_header;
END IF;
END IF;
    /* changed by Karen at 1996-04-27 for cpi */
    /* before changes are comment for select from Case_view */
    /* get all patient admission in this period */
    /*
    insert #temp_table
            select  @header,
    		null,
    		PMI.Religion_code,
    		null,
    		Case.Case_no,
    		PMI.Name,
    		PMI.CCC_1,
    		PMI.CCC_2,
    		PMI.CCC_3,
    		PMI.CCC_4,
    		PMI.CCC_5,
    		PMI.CCC_6,
    		PMI.HKID,
    		PMI.Sex,
    		PMI.DOB,
    		PMI.Marital_status,
    		Case.Pay_code,
    		PMI.Race_code,
    		PMI.Death_date,
    		Transaction_log.Transaction_datetime,
    		Case.Source_indicator,
    		Case.Source_code,
    		Transaction_log.From_ward_code,
    		Transaction_log.From_specialty_code,
    		Specialty.Specialty_code+' ('+Specialty.Description+')',
    		Case.Discharge_datetime,
    		Case.Destination_code,
    		PMI.Medical_record_number,
    		PMI.Building,
    		PMI.Room,
    		PMI.Floor,
    		PMI.Block,
    		PMI.District_code,
    		PMI.Home_phone_no,
    		Address=space(90),
    		Transaction_log.Transaction_type,
    		Chinese_name = space(12),
    		Age = space(5),
    		NOK_name1 = space(48),
    		NOK_phone_no1 = space(10),
    		NOK_name2 = space(48),
    		NOK_phone_no2 = space(10),
    		null
            from    PMI, Case, Transaction_log, Specialty
            where   (PMI.HKID = Case.HKID) AND
    		(Transaction_log.Transaction_datetime >= @TRANS_FDATETIME) AND
    		(Transaction_log.Transaction_datetime < @TRANS_TDATETIME) AND
    		(Case.Case_no = Transaction_log.Case_no) AND
    		(Transaction_log.From_specialty_code = Specialty.Specialty_code ) and
    		(Transaction_log.Transaction_type = '100') and
    		(Transaction_log.Cancel_flag is NULL)
    */
    /* end of comment for select from Case_view */
    /* modify start for select from Case_view */
    /* get all patient admission in this period */
    
--    [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
    insert into t$temp_table
    	select var_header,
    		null,
    		PMI.Religion_code,
    		null,
    		Case_view.Case_no,
    		PMI.Name,
    		PMI.CCC_1,
    		PMI.CCC_2,
    		PMI.CCC_3,
    		PMI.CCC_4,
    		PMI.CCC_5,
    		PMI.CCC_6,
    		PMI.HKID,
    		PMI.Sex,
    		PMI.DOB,
    		PMI.Marital_status,
    		Case_view.Pay_code,
    		PMI.Race_code,
    		PMI.Death_date,
    		Transaction_log.Transaction_datetime,
    		Case_view.Source_indicator,
    		Case_view.Source_code,
    		Transaction_log.From_ward_code,
    		Transaction_log.From_specialty_code,
    		/*  Specialty.Specialty_code+' ('+Specialty.Description+')', */
    		null,
    		Case_view.Discharge_datetime,
    		Case_view.Destination_code,
    		PMI.Medical_record_number,
    		PMI.Building,
    		PMI.Room,
    		PMI.Floor,
    		PMI.Block,
    		PMI.District_code,
    		PMI.phone1,
		    REPEAT(' ', 90),
	        Transaction_log.Transaction_type,
		    REPEAT(' ', 12),
		    REPEAT(' ', 5),
		    REPEAT(' ', 48),
		    REPEAT(' ', 10),
		    REPEAT(' ', 48),
		    REPEAT(' ', 10),
	        NULL,
		    REPEAT(' ', 12) 	/* 2006-09-18 Addeded by HK Fong SMR20015696 */
    	/* from    PMI, Case_view, Transaction_log, Specialty */
--    	from 	PMI, Case_view, Transaction_log (using index XIE2Transaction_Log)
		    FROM   PMI
				JOIN Case_view ON PMI.HKID = Case_view.HKID
				JOIN Transaction_log ON Case_view.Case_no = Transaction_log.Case_no
    	where   (Transaction_log.Transaction_datetime >= par_trans_fdatetime) AND
    		(Transaction_log.Transaction_datetime < par_trans_tdatetime) AND
    		/* (Transaction_log.From_specialty_code = Specialty.Specialty_code) and   */
    		(Transaction_log.Transaction_type = '100') and
    		(Transaction_log.Cancel_flag is NULL) and
    		(Transaction_log.Hospital_code = par_hosp_code) and
    		(Case_view.Hospital_code = par_hosp_code) and
    		(PMI.PMI_hospital_code = par_hosp_code);
    
    /* add hosp code for HPI by ML on 27.07.1999 */
    /* end of modify for select from Case_view */
    /* Calculate the age */ /* 2006-09-18 Addeded by HK Fong SMR20015696 */
OPEN temp_table_csr;
FETCH temp_table_csr INTO var_mark, var_case_no, var_hkid, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_dob, var_death_date, var_admission_datetime, var_building, var_room, var_floor, var_block, var_district_code, var_address, var_chinese_name, var_age, var_religion_code, var_specialty_code, var_specialty_desc, var_header_desc;

WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        /* check re-use admission# & mark '*' */
        /* add hosp code for HPI by ML on 27.07.1999 */
SELECT
    COUNT(*)
INTO var_total
FROM Transaction_log
WHERE Transaction_type = '100' AND Case_no = var_case_no AND Hospital_code = par_HOSP_CODE;

IF var_total > 1 THEN
SELECT
    '*'
INTO var_mark;
END IF;
        /* calculate age */
SELECT
    REPEAT(' ', 0)
INTO var_address;

IF var_dob is not null THEN
BEGIN
                IF var_death_date IS NULL THEN
SELECT
    var_admission_datetime
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
IF LENGTH(var_ccc_1) > 0 AND var_ccc_1 IS NOT NULL THEN
BEGIN
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    /* unicode_char */null
INTO var_big_5
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(var_ccc_1, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_1, 5, 1);

IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 THEN
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
        IF LENGTH(var_ccc_2) > 0 AND var_ccc_2 IS NOT NULL THEN
BEGIN
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    /* unicode_char */null
INTO var_big_5
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(var_ccc_2, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_2, 5, 1);

IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 THEN
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
        IF LENGTH(var_ccc_3) > 0 AND var_ccc_3 IS NOT NULL THEN
BEGIN
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    /* unicode_char */null
INTO var_big_5
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(var_ccc_3, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_3, 5, 1);

IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 THEN
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
        IF LENGTH(var_ccc_4) > 0 AND var_ccc_4 IS NOT NULL THEN
BEGIN
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    /* unicode_char */null
INTO var_big_5
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(var_ccc_4, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_4, 5, 1);

IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 THEN
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
        IF LENGTH(var_ccc_5) > 0 AND var_ccc_5 IS NOT NULL THEN
BEGIN
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    /* unicode_char */null
INTO var_big_5
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(var_ccc_5, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_5, 5, 1);

IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 THEN
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
        IF LENGTH(var_ccc_6) > 0 AND var_ccc_6 IS NOT NULL THEN
BEGIN
SELECT
    -- ccc_big5.big5 column was obsolete in Sybase in 2015, however, since some SPs were still referring this obsolete column as below,

    -- it’s agreed to hardcode null (or space(s)) as below in PostgreSQL to avoid impact on caller or app frontend

    /* unicode_char */null
INTO var_big_5
FROM ccc_unicode
WHERE CCC_head = SUBSTRING(var_ccc_6, 1, 4) AND CCC_tail = SUBSTRING(var_ccc_6, 5, 1);

IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 THEN
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
CALL hasp_check_schi_name(var_return_code, par_ccc1 => var_ccc_1, par_ccc2 => var_ccc_2, par_ccc3 => var_ccc_3, par_ccc4 => var_ccc_4, par_ccc5 => var_ccc_5, par_ccc6 => var_ccc_6, par_is_schi_name => var_is_schi_name);

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
        /* address */
        /*
        Update by Ray 20020312 for sybase 12
        
        if @room is not null
        	select @address = Room  + @room +  
        if @floor is not null
        	select @address = @address + @floor + /F 
        if @block is not null
        	select @address = @address + Block  + @block +  
        if @building is not null
        	select @address = @address + @building +  
        if @district_code is not null
        	select @address = @address + @district_code
        */
        IF var_room is not null THEN
SELECT
    CONCAT('Room ', RTRIM(var_room), ' ')
INTO var_address;
END IF;

        IF var_floor is not null THEN
SELECT
    CONCAT(var_address, RTRIM(var_floor), '/F ')
INTO var_address;
END IF;

        IF var_block is not null THEN
SELECT
    CONCAT(var_address, 'Block ', RTRIM(var_block), ' ')
INTO var_address;

END IF;

        IF var_building is not null THEN
BEGIN
                /* Added to format Address Code */
                IF SUBSTRING(var_building, 1, 7) = 'HACODE:' THEN
BEGIN
SELECT
    CAST (RIGHT(RTRIM(var_building), LENGTH(RTRIM(var_building)) - 7) AS INTEGER)
INTO var_addr_code;
CALL hasp_get_address_detail(var_return_code, var_addr_code, var_addr_eng, var_addr_chi, var_addr_dist, var_addr_eh_eng, var_addr_eh_chi);

IF var_return_code = 0 AND var_addr_eng IS NOT NULL THEN
SELECT
    var_addr_eng
INTO var_building;
END IF;
END;
END IF;
SELECT
    CONCAT(var_address, RTRIM(var_building), ' ')
INTO var_address;
END;
END IF;

        IF var_district_code is not null THEN
SELECT
    CONCAT(var_address, RTRIM(var_district_code))
INTO var_address;
END IF;
        /* description */
        IF par_FUNC_ID = 1221 THEN
SELECT
    Religion.Religion_description
INTO var_header_desc
FROM Religion
WHERE Religion.Religion_code = var_religion_code;
ELSE
            IF par_FUNC_ID = 1222 OR par_FUNC_ID = 1223 THEN
                /* modified for select description corresponding to the retrieve date range */
                /* 13121996 ML */
BEGIN
                    /* Add hosp code for HPI by ML on 27.07.1999 */
SELECT
    (SELECT
         Description
     FROM Specialty
     WHERE Specialty_code = var_specialty_code AND Hospital_code = par_HOSP_CODE AND Effective_date = (SELECT
                                                                                                           MAX(Effective_date)
                                                                                                       FROM Specialty
                                                                                                       WHERE Specialty_code = var_specialty_code AND Effective_date < par_TRANS_TDATETIME) AND Hospital_code = par_HOSP_CODE)
INTO var_specialty_desc;
SELECT
    CONCAT(RPAD(var_specialty_code, 4, ' '), '(', var_specialty_desc, ')')
INTO var_specialty_desc;
SELECT
    var_specialty_desc
INTO var_header_desc;
END;
END IF;
END IF;
        /* update age to the temp table */
UPDATE t$temp_table
SET Mark = var_mark, Chinese_name = var_cname, Age = var_age, Address = var_address, Header_desc = var_header_desc, SChinese_name = var_scname /* 2006-09-18 Addeded by HK Fong SMR20015696 */
WHERE CURRENT OF temp_table_csr;
/* get next row */
FETCH temp_table_csr INTO var_mark, var_case_no, var_hkid, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_dob, var_death_date, var_admission_datetime, var_building, var_room, var_floor, var_block, var_district_code, var_address, var_chinese_name, var_age, var_religion_code, var_specialty_code, var_specialty_desc, var_header_desc;
END LOOP;
CLOSE temp_table_csr;
OPEN temp_list_csr;
FETCH temp_list_csr INTO var_hkid, var_case_no;

WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        OPEN temp_nok_csr;
FETCH temp_nok_csr INTO var_nok_hkid, var_nok_name, var_nok_home_phone_no;
SELECT
    'N'
INTO var_flag;

WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF var_flag = 'N' THEN
BEGIN
UPDATE t$temp_table
SET NOK_name1 = var_nok_name, NOK_phone_no1 = var_nok_home_phone_no
WHERE case_no = var_case_no AND hkid = var_hkid;
SELECT
    'Y'
INTO var_flag;
END;
ELSE
BEGIN
UPDATE t$temp_table
SET NOK_name2 = var_nok_name, NOK_phone_no2 = var_nok_home_phone_no
WHERE case_no = var_case_no AND hkid = var_hkid;
END;
END IF;
FETCH temp_nok_csr INTO var_nok_hkid, var_nok_name, var_nok_home_phone_no;
END LOOP;
CLOSE temp_nok_csr;
FETCH temp_list_csr INTO var_hkid, var_case_no;
END LOOP;
CLOSE temp_list_csr;
UPDATE t$temp_table
SET case_year = CONCAT('19', SUBSTRING(Case_no, 4, 2))
WHERE SUBSTRING(case_no, 4, 2) > '80';
UPDATE t$temp_table
SET case_year = CONCAT('20', SUBSTRING(Case_no, 4, 2))
WHERE SUBSTRING(case_no, 4, 2) <= '80';

IF par_FUNC_ID = 1221 then

-- DO $$
-- DECLARE
--     rec RECORD;
-- BEGIN
-- FOR rec IN SELECT * FROM "t$temp_table" where case_no = ' HN24002879U' LOOP
-- 								        RAISE NOTICE 'case_no: %, name: %, header: %, header_desc: %, religion_code: %',
-- 								                     rec.case_no, rec.name, rec.header, rec.header_desc, rec.religion_code;
-- 								    END LOOP;
-- END $$;

        /* select a.* from #temp_table a */
        OPEN p_refcur FOR
SELECT
    header, header_desc, religion_code, mark, case_no, name, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, hkid, sex, dob, marital_status, patient_status, race_code, death_date, admission_datetime, source_indicator, source_code, ward_code, specialty_code, specialty_desc, discharge_datetime, destination_code, medical_record_number, building, room, floor, block, district_code, home_phone_no, substring(address, 1, 90), type, chinese_name, age, nok_name1, nok_phone_no1, nok_name2, nok_phone_no2, schinese_name /* 2006-09-18 Addeded by HK Fong SMR20015696 */
FROM t$temp_table AS a
WHERE a.Religion_code IS NOT NULL AND a.Religion_code LIKE par_SEARCH
ORDER BY header_desc::bytea ASC NULLS FIRST, case_year NULLS FIRST, case_no::bytea ASC NULLS FIRST;
ELSE
        IF par_FUNC_ID = 1222 THEN
            /* select a.* from #temp_table a */
            OPEN p_refcur FOR
SELECT
    header, header_desc, religion_code, mark, case_no, name, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, hkid, sex, dob, marital_status, patient_status, race_code, death_date, admission_datetime, source_indicator, source_code, ward_code, specialty_code, specialty_desc, discharge_datetime, destination_code, medical_record_number, building, room, floor, block, district_code, home_phone_no, substring(address, 1, 90), type, chinese_name, age, nok_name1, nok_phone_no1, nok_name2, nok_phone_no2, schinese_name /* 2006-09-18 Addeded by HK Fong SMR20015696 */
FROM t$temp_table AS a
WHERE a.Specialty_code LIKE par_SEARCH
ORDER BY header_desc::bytea ASC NULLS FIRST, case_year NULLS FIRST, case_no::bytea ASC NULLS FIRST;
ELSE
            IF par_FUNC_ID = 1223 THEN
                /* select      a.* from #temp_table a */
                OPEN p_refcur FOR
SELECT
    header, header_desc, religion_code, mark, case_no, name, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, hkid, sex, dob, marital_status, patient_status, race_code, death_date, admission_datetime, source_indicator, source_code, ward_code, specialty_code, specialty_desc, discharge_datetime, destination_code, medical_record_number, building, room, floor, block, district_code, home_phone_no, substring(address, 1, 90), type, chinese_name, age, nok_name1, nok_phone_no1, nok_name2, nok_phone_no2, schinese_name /* 2006-09-18 Addeded by HK Fong SMR20015696 */
FROM t$temp_table AS a
WHERE a.Source_indicator = '3' AND a.Specialty_code LIKE par_SEARCH
ORDER BY header_desc::bytea ASC NULLS FIRST, case_year NULLS FIRST, case_no::bytea ASC NULLS FIRST;
END IF;
END IF;
END IF;
--    pas_return_code := 0;
--    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
return next p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_get_admission_by" OWNER TO "HPI_SCHEMA_OWNER_ROLE";