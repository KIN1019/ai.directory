-- DROP PROCEDURE hpi.opas_cpi_get_patient_info(inout int4, in varchar, in varchar, inout int4, inout varchar, inout varchar, in int4, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE opas_cpi_get_patient_info(INOUT pas_return_code integer, IN par_hkpmi character varying, IN par_hospital character varying, INOUT par_patient_no integer, INOUT par_hkid character varying, INOUT par_case_no character varying, IN par_result_type integer, IN par_patient_status character varying, IN par_case_spec character varying, IN par_case_subs character varying, IN par_case_security integer, IN par_case_sp_security integer, IN par_return_access_code character varying DEFAULT 'N'::character varying, IN par_return_hkic_symbol character varying DEFAULT 'N'::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* 2011-05-25 - jw - Fix opas database name to adapt Testing environment */
/* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
/* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration */
/* 2009-05-05 Shelley SMR20017336 Bug fix on retrieving chi_name */
/* 2008-02-18 Shelley SMR20017098 Bug fix on getting case specialty and opas unit */
/* 2007-10-22 Shelley SMR20016550 Change RPC to DC */ /* 2010-12-09 SMR20017866 HKIC Symbol input in Registration */
DECLARE
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(2);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(2);
    var_ccc_1 VARCHAR(10);
    var_ccc_2 VARCHAR(10);
    var_ccc_3 VARCHAR(10);
    var_ccc_4 VARCHAR(10);
    var_ccc_5 VARCHAR(10);
    var_ccc_6 VARCHAR(10);
    var_chi_name VARCHAR(24);
    var_marital_status VARCHAR(2);
    var_race_code VARCHAR(4);
    var_other_document_no VARCHAR(24);
    var_reference VARCHAR(40);
    var_mrn VARCHAR(16);
    var_remark VARCHAR(255);
    var_building VARCHAR(94);
    var_room VARCHAR(10);
    var_floor VARCHAR(4);
    var_block VARCHAR(4);
    var_district_code VARCHAR(10);
    var_religion_code VARCHAR(6);
    var_home_phone_no VARCHAR(20);
    var_other_phone_no_1 VARCHAR(20);
    var_other_phone_ext_1 VARCHAR(8);
    var_other_phone_no_2 VARCHAR(20);
    var_other_phone_ext_2 VARCHAR(8);
    var_death_indicator VARCHAR(2);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_death_code VARCHAR(8);
    var_card_holder INTEGER;
    var_patient_key VARCHAR(16);
    var_priority INTEGER;
    var_nok_name VARCHAR(96);
    var_nok_hkid VARCHAR(24);
    var_nok_relation_code VARCHAR(4);
    var_nok_building VARCHAR(94);
    var_nok_room VARCHAR(10);
    var_nok_floor VARCHAR(4);
    var_nok_block VARCHAR(4);
    var_nok_district_code VARCHAR(10);
    var_nok_home_phone VARCHAR(20);
    var_nok_other_phone_no_1 VARCHAR(20);
    var_nok_other_phone_ext_1 VARCHAR(8);
    var_nok_other_phone_no_2 VARCHAR(20);
    var_nok_other_phone_ext_2 VARCHAR(8);
    var_access_code INTEGER;
    var_security INTEGER;
    var_update_hospital VARCHAR(6);
    var_update_by VARCHAR(24);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_create_by VARCHAR(24);
    var_create_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hkic_symbol VARCHAR(2);
    var_opas_db VARCHAR(60);
   
    var_age VARCHAR(12);
    var_age_day INTEGER;
    var_age_month INTEGER;
    var_age_year INTEGER;
    var_return_code INTEGER;
    var_same_server INTEGER;
    var_return_msg VARCHAR(255);
BEGIN /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
    /* 2011-05-25 - jw - Fix opas database name to adapt Testing environment - Start */
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@SERVERNAME function. Use suitable function or create user defined function.]
    select @servername = UPPER(@@servername)
    */
    /* 2011-05-25 - jw - Fix opas database name to adapt Testing environment - End */
    /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
  
    IF par_hospital = 'TMP' THEN
        SELECT
            'TMH'
            INTO par_hospital;
    END IF;

    IF par_hospital = 'SYP' THEN
        SELECT
            'QMH'
            INTO par_hospital;
    END IF;

    IF par_hospital = 'SKC' THEN
        SELECT
            'PMH'
            INTO par_hospital;
    END IF;
    /* 2008-02-18 Shelley SMR20017098 Bug fix on getting case specialty and opas unit-begin */
    /*
    if @case_no > ''
    begin
    	select @case_spec = last_specialty, @case_subs = last_sub_specialty, @patient_status =patient_type
    	from cpi_case
    	where case_no =@case_no
    end
    */
    /* 2008-02-18 Shelley SMR20017098 Bug fix on getting case specialty and opas unit-end */
    IF par_case_spec = '' THEN
        BEGIN
            SELECT
                NULL
                INTO par_case_spec;
            SELECT
                NULL
                INTO par_case_sp_security;
            SELECT
                NULL
                INTO par_case_security;
        END;
    END IF;

    IF par_case_subs = '' THEN
        SELECT
            NULL
            INTO par_case_subs;
    END IF;

    IF par_hkpmi = 'Y' THEN
        BEGIN
         
	            CALL cpi_get_patient_info(var_return_code, par_hospital, par_hkid, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, var_mrn, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_patient_key, var_priority, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, var_access_code, var_security, var_update_hospital, var_update_by, var_hkic_symbol); /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
	
	            IF var_patient_key > '' THEN
	                BEGIN
	                    SELECT
	                        CAST (var_patient_key AS INTEGER)
	                        INTO par_patient_no;
	                    SELECT
	                        update_by, update_dtm, create_by, create_dtm
	                        INTO var_update_by, var_update_dtm, var_create_by, var_create_dtm
	                        FROM cpi_patient
	                        WHERE patient_key = var_patient_key;
	                END;
	            END IF;
	 
            pas_return_code := var_return_code;
            RETURN;
        END;
    ELSE
        BEGIN
            IF par_patient_no > 0 THEN
                SELECT
                    patient_key
                    INTO var_patient_key
                    FROM cpi_patient
                    WHERE patient_no = par_patient_no;
            ELSE
                IF par_hkid > '' THEN
                    SELECT
                        patient_key
                        INTO var_patient_key
                        FROM cpi_patient
                        WHERE hkid = par_hkid;
                ELSE
                    IF par_case_no > '' THEN
                        SELECT
                            patient_key
                            INTO var_patient_key
                            FROM cpi_case
                            WHERE case_no = par_case_no AND hospital_code = par_hospital;
                    END IF;
                END IF;
            END IF;
            SELECT
                patient_no, hkid, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, reference, building, room, floor, block, district, religion, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext, death_indicator, death_date, death_code, card_holder, access_code, security, update_hospital, update_by, update_dtm, create_by, create_dtm, hkic_symbol
                INTO par_patient_no, par_hkid, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_access_code, var_security, var_update_hospital, var_update_by, var_update_dtm, var_create_by, var_create_dtm, var_hkic_symbol /* 2010-12-07 SMR20017866 HKIC Symbol input in Registration */
                FROM cpi_patient
                WHERE patient_key = var_patient_key;
            SELECT
                mrn, remark
                INTO var_mrn, var_remark
                FROM cpi_patient_hospital_data
                WHERE patient_key = var_patient_key AND hospital_code = par_hospital;
            SELECT
                priority, nok_name, hkid, relationship, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, office_phone_ext
                INTO var_priority, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2
                FROM cpi_nok
                WHERE patient_key = var_patient_key AND major_nok = 'Y';
        END;
    END IF;
    /* 2009-05-05 Shelley SMR20017336 Bug fix on retrieving chi_name begin */
    CALL opas_cpi_ccc_to_chi_name(var_return_code, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_return_code, var_return_msg);
    /* 2009-05-05 Shelley SMR20017336 Bug fix on retrieving chi_name end */
    IF par_result_type = 0 OR par_result_type = 100 THEN
        OPEN p_refcur FOR
        SELECT
            par_patient_no;
    ELSE
        IF par_result_type = 1 THEN
            IF par_return_access_code = 'Y' THEN
                BEGIN
                    /* 2010-12-09 SMR20017866 HKIC Symbol input in Registration - Start */
                    IF par_return_hkic_symbol = 'Y' THEN
                        BEGIN
                            OPEN p_refcur FOR
                            SELECT
                                par_patient_no, par_hkid, var_patient_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_dob, var_exact_dob_flag, var_marital_status, var_race_code, var_other_document_no, var_reference, var_mrn, CAST ('' AS VARCHAR(24)),
                                CASE CAST (var_building AS VARCHAR(255))
                                    WHEN '' THEN ''
                                    ELSE CAST (var_building AS VARCHAR(255))
                                END, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, CAST (par_patient_status AS VARCHAR(6)), var_death_indicator, var_death_date, var_death_code, var_security, CAST (var_create_by AS VARCHAR(16)), var_create_dtm, CAST (var_update_by AS VARCHAR(16)), var_update_dtm, CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(2)), CAST ('' AS VARCHAR(24)), CAST ('' AS VARCHAR(2)), CAST (var_access_code AS INTEGER), var_hkic_symbol;
                        END;
                    ELSE
                        /* 2010-12-09 SMR20017866 HKIC Symbol input in Registration - End */
                        BEGIN
                            OPEN p_refcur FOR
                            SELECT
                                par_patient_no, par_hkid, var_patient_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_dob, var_exact_dob_flag, var_marital_status, var_race_code, var_other_document_no, var_reference, var_mrn, CAST ('' AS VARCHAR(24)),
                                CASE CAST (var_building AS VARCHAR(255))
                                    WHEN '' THEN ''
                                    ELSE CAST (var_building AS VARCHAR(255))
                                END, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, CAST (par_patient_status AS VARCHAR(6)), var_death_indicator, var_death_date, var_death_code, var_security, CAST (var_create_by AS VARCHAR(32)), var_create_dtm, CAST (var_update_by AS VARCHAR(16)), var_update_dtm, CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(2)), CAST ('' AS VARCHAR(24)), CAST ('' AS VARCHAR(2)), CAST (var_access_code AS INTEGER);
                        END;
                    END IF;
                END;
            ELSE
                BEGIN
                    /* 2010-12-09 SMR20017866 HKIC Symbol input in Registration - Start */
                    IF par_return_hkic_symbol = 'Y' THEN
                        BEGIN
                            OPEN p_refcur FOR
                            SELECT
                                par_patient_no, par_hkid, var_patient_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_dob, var_exact_dob_flag, var_marital_status, var_race_code, var_other_document_no, var_reference, var_mrn, CAST ('' AS VARCHAR(24)),
                                CASE CAST (var_building AS VARCHAR(255))
                                    WHEN '' THEN ''
                                    ELSE CAST (var_building AS VARCHAR(255))
                                END, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, CAST (par_patient_status AS VARCHAR(6)), var_death_indicator, var_death_date, var_death_code, var_security, CAST (var_create_by AS VARCHAR(16)), var_create_dtm, CAST (var_update_by AS VARCHAR(16)), var_update_dtm, CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(2)), CAST ('' AS VARCHAR(24)), CAST ('' AS VARCHAR(2)), var_hkic_symbol;
                        END;
                    ELSE
                        /* 2010-12-09 SMR20017866 HKIC Symbol input in Registration - End */
                        BEGIN
                            OPEN p_refcur FOR
                            SELECT
                                par_patient_no, par_hkid, var_patient_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_dob, var_exact_dob_flag, var_marital_status, var_race_code, var_other_document_no, var_reference, var_mrn, CAST ('' AS VARCHAR(24)),
                                CASE CAST (var_building AS VARCHAR(255))
                                    WHEN '' THEN ''
                                    ELSE CAST (var_building AS VARCHAR(255))
                                END, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, CAST (par_patient_status AS VARCHAR(6)), var_death_indicator, var_death_date, var_death_code, var_security, CAST (var_create_by AS VARCHAR(16)), var_create_dtm, CAST (var_update_by AS VARCHAR(16)), var_update_dtm, CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(2)), CAST ('' AS VARCHAR(24)), CAST ('' AS VARCHAR(2));
                        END;
                    END IF;
                END;
            END IF;
        ELSE
            IF par_result_type = 2 THEN
                OPEN p_refcur FOR
                SELECT
                    par_case_no, par_hkid, var_patient_name, var_chi_name, var_sex, var_dob, var_death_date, par_patient_no, var_death_indicator, var_death_code, par_case_spec, par_case_subs, par_case_security, var_security, par_case_sp_security, CAST ('' AS VARCHAR(20)), var_mrn, CAST (par_patient_status AS VARCHAR(6)), var_card_holder;
            ELSE
                IF par_result_type = 3 THEN
                    OPEN p_refcur FOR
                    SELECT
                        par_hkid, var_patient_name, var_chi_name, var_mrn;
                ELSE
                    IF par_result_type = 4 THEN
                        OPEN p_refcur FOR
                        SELECT
                            par_hkid, var_patient_name, var_sex, var_chi_name, var_mrn, var_dob, var_exact_dob_flag, var_building, var_room, var_floor, var_block, var_district_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_marital_status, par_patient_status, var_race_code, var_reference, var_death_indicator, var_death_date;
                    ELSE
                        IF par_result_type = 5 THEN
                            OPEN p_refcur FOR
                            SELECT
                                var_patient_name, CAST (COALESCE(var_chi_name, '') AS VARCHAR(24)), par_hkid, var_mrn, var_sex, var_dob, var_exact_dob_flag, CAST (var_card_holder AS SMALLINT);
                        ELSE
                            IF par_result_type = 6 THEN
                                OPEN p_refcur FOR
                                SELECT
                                    COALESCE(var_nok_name, ''), COALESCE(var_nok_relation_code, ''), COALESCE(var_nok_other_phone_no_1, ''), COALESCE(var_nok_other_phone_ext_1, ''), COALESCE(var_nok_home_phone, ''), par_hkid, var_patient_name, var_sex, var_chi_name, var_mrn, var_dob, var_exact_dob_flag, var_building, var_room, var_floor, var_block, var_district_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_marital_status, par_patient_status, var_race_code, var_reference, var_death_indicator, var_death_date;
                            ELSE
                                IF par_result_type = 7 THEN
                                    OPEN p_refcur FOR
                                    SELECT
                                        par_case_no, par_hkid, var_patient_name, var_chi_name, var_sex, var_dob, var_death_date, par_patient_no, var_death_indicator, var_death_code, par_case_spec, par_case_subs, par_case_security, var_security, par_case_sp_security, CAST ('' AS VARCHAR(20)), var_mrn, CAST (par_patient_status AS VARCHAR(6)), var_card_holder, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1;
                                ELSE
                                    IF par_result_type = 8 THEN
                                        BEGIN
                                            OPEN p_refcur FOR
                                            SELECT
                                                par_patient_no, par_hkid, var_patient_name, var_chi_name, var_dob, var_sex;
                                        END;
                                    ELSE
                                        IF par_result_type = 9 THEN
                                            BEGIN
                                                OPEN p_refcur FOR
                                                SELECT
                                                    par_case_no, par_hkid, var_patient_name, var_chi_name, var_sex, var_dob, var_death_date, par_patient_no, var_death_indicator, var_death_code, par_case_spec, par_case_subs, par_case_security, var_security, par_case_sp_security, CAST ('' AS VARCHAR(20)), var_mrn, CAST (par_patient_status AS VARCHAR(6)), var_card_holder, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1;
                                            END;
                                        ELSE
                                            IF par_result_type = 10 THEN
                                                BEGIN
                                                    IF var_dob IS NULL THEN
                                                        BEGIN
                                                            SELECT
                                                                ''
                                                                INTO var_age;
                                                        END;
                                                    ELSE
                                                        BEGIN
                                                            SELECT
                                                                date_part('year', localtimestamp::TIMESTAMP) - date_part('year', var_dob::TIMESTAMP)
                                                                INTO var_age_year;
                                                            SELECT
                                                                date_part('month', localtimestamp::TIMESTAMP) - date_part('month', var_dob::TIMESTAMP)
                                                                INTO var_age_month;
                                                            SELECT
                                                                date_part('day', localtimestamp::TIMESTAMP) - date_part('day', var_dob::TIMESTAMP)
                                                                INTO var_age_day;

                                                            IF var_age_year >= 3 THEN
                                                                SELECT
                                                                    CONCAT(LTRIM(RTRIM(CAST (var_age_year AS VARCHAR(10)))), 'y')
                                                                    INTO var_age;
                                                            ELSE
                                                                IF var_age_year >= 1 AND var_age_year <= 2 THEN
                                                                    BEGIN
                                                                        IF var_age_month < 0 THEN
                                                                            SELECT
                                                                                CONCAT(LTRIM(RTRIM(CAST ((12 + var_age_month) + (var_age_year * 12) AS VARCHAR(10)))), 'm')
                                                                                INTO var_age;
                                                                        ELSE
                                                                            SELECT
                                                                                CONCAT(LTRIM(RTRIM(CAST (var_age_month + (var_age_year * 12) AS VARCHAR(10)))), 'm')
                                                                                INTO var_age;
                                                                        END IF;
                                                                    END;
                                                                ELSE
                                                                    BEGIN
                                                                        IF var_age_month < 0 THEN
                                                                            IF (var_age_day = 0 AND var_age_month = - 9) OR var_age_month < - 9 THEN
                                                                                SELECT
                                                                                    CONCAT(LTRIM(RTRIM(CAST (var_age_day AS VARCHAR(10)))), 'd')
                                                                                    INTO var_age;
                                                                            ELSE
                                                                                SELECT
                                                                                    CONCAT(LTRIM(RTRIM(CAST (12 + var_age_month AS VARCHAR(10)))), 'm')
                                                                                    INTO var_age;
                                                                            END IF;
                                                                        ELSE
                                                                            IF (var_age_day = 0 AND var_age_month = 3) OR var_age_month < 3 THEN
                                                                                SELECT
                                                                                    CONCAT(LTRIM(RTRIM(CAST (var_age_day AS VARCHAR(10)))), 'd')
                                                                                    INTO var_age;
                                                                            ELSE
                                                                                SELECT
                                                                                    CONCAT(LTRIM(RTRIM(CAST (var_age_month AS VARCHAR(10)))), 'm')
                                                                                    INTO var_age;
                                                                            END IF;
                                                                        END IF;
                                                                    END;
                                                                END IF;
                                                            END IF;
                                                        END;
                                                    END IF;
                                                    OPEN p_refcur FOR
                                                    SELECT
                                                        var_chi_name, var_patient_name, var_sex, var_dob, par_patient_status, var_age;
                                                END;
                                            ELSE
                                                IF par_result_type = 11 THEN
                                                    BEGIN
                                                        OPEN p_refcur FOR
                                                        SELECT
                                                            par_case_no, par_hkid, var_patient_name, var_chi_name, var_sex, var_dob, var_death_date, par_patient_no, var_death_indicator, var_death_code, par_case_spec, par_case_subs, par_case_security, var_security, par_case_sp_security, CAST ('' AS VARCHAR(20)), var_mrn, CAST (par_patient_status AS VARCHAR(6)), var_card_holder, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6;
                                                    END;
                                                ELSE
                                                    IF par_result_type = 12 THEN
                                                        BEGIN
                                                            OPEN p_refcur FOR
                                                            SELECT
                                                                par_case_no, par_hkid, var_patient_name, var_chi_name, var_sex, var_dob, var_death_date, par_patient_no, var_death_indicator, var_death_code, par_case_spec, par_case_subs, par_case_security, var_security, par_case_sp_security, CAST ('' AS VARCHAR(20)), var_mrn, CAST (par_patient_status AS VARCHAR(6)), var_card_holder, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6;
                                                        END;
                                                    ELSE
                                                        IF par_result_type = 13 THEN
                                                            BEGIN
                                                                OPEN p_refcur FOR
                                                                SELECT
                                                                    par_case_no, par_hkid, var_patient_name, var_chi_name, var_sex, var_dob, var_death_date, par_patient_no, var_death_indicator, var_death_code, par_case_spec, par_case_subs, par_case_security, var_security, par_case_sp_security, CAST ('' AS VARCHAR(20)), var_mrn, CAST (par_patient_status AS VARCHAR(6)), var_card_holder, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6;
                                                            END;
                                                        ELSE
                                                            IF par_result_type = 14 THEN
                                                                BEGIN
                                                                    OPEN p_refcur FOR
                                                                    SELECT
                                                                        par_patient_no, par_hkid, var_patient_name, var_chi_name, var_dob, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6
                                                                        WHERE var_patient_key > '';
                                                                END;
                                                            ELSE
                                                                IF par_result_type = 15 THEN
                                                                    BEGIN
                                                                        OPEN p_refcur FOR
                                                                        SELECT
                                                                            par_hkid, var_patient_name, var_sex, var_chi_name, var_mrn, var_dob, var_exact_dob_flag, var_building, var_room, var_floor, var_block, var_district_code, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_marital_status, par_patient_status, var_race_code, var_reference, var_death_indicator, var_death_date, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6;
                                                                    END;
                                                                ELSE
                                                                    IF par_result_type = 16 THEN
                                                                        OPEN p_refcur FOR
                                                                        SELECT
                                                                            var_patient_name, CAST (COALESCE(var_chi_name, '') AS VARCHAR(24)), par_hkid, var_mrn, var_sex, var_dob, var_exact_dob_flag, CAST (var_card_holder AS SMALLINT), var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6;
                                                                    ELSE
                                                                        IF par_result_type = 17 THEN
                                                                            OPEN p_refcur FOR
                                                                            SELECT
                                                                                par_hkid, var_patient_name, var_chi_name, var_mrn, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6;
                                                                        ELSE
                                                                            IF par_result_type = 18 THEN
                                                                                BEGIN
                                                                                    OPEN p_refcur FOR
                                                                                    SELECT
                                                                                        par_case_no, par_hkid, var_patient_name, var_chi_name, var_sex, var_dob, var_death_date, par_patient_no, var_death_indicator, var_death_code, par_case_spec, par_case_subs, par_case_security, var_security, par_case_sp_security, CAST ('' AS VARCHAR(20)), var_mrn, CAST (par_patient_status AS VARCHAR(6)), var_card_holder, var_home_phone_no, var_other_phone_no_1, var_other_phone_ext_1, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6;
                                                                                END;
                                                                            ELSE
                                                                                IF par_result_type = 19 THEN
                                                                                    BEGIN
                                                                                        OPEN p_refcur FOR
                                                                                        SELECT
                                                                                            par_patient_no, par_hkid, var_patient_name, var_chi_name, var_dob, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_exact_dob_flag;
                                                                                    END;
                                                                                END IF;
                                                                            END IF;
                                                                        END IF;
                                                                    END IF;
                                                                END IF;
                                                            END IF;
                                                        END IF;
                                                    END IF;
                                                END IF;
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
END;
$procedure$
;


;ALTER PROCEDURE "opas_cpi_get_patient_info" OWNER TO "HPI_SCHEMA_OWNER_ROLE";