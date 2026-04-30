-- DROP FUNCTION hpi.hasp_get_disposal_list(timestamp);

CREATE OR REPLACE FUNCTION hpi.hasp_get_disposal_list(par_disposal_date timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_hospital_code VARCHAR(6);
    var_case_no VARCHAR(24);
    var_hkid VARCHAR(24);
    var_name VARCHAR(96);
    var_chi_name VARCHAR(24);
    var_mrn VARCHAR(16);
    var_sex VARCHAR(2);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_dispose_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(2);
    var_retcode INTEGER;
    var_ccc_1 VARCHAR(10);
    var_ccc_2 VARCHAR(10);
    var_ccc_3 VARCHAR(10);
    var_ccc_4 VARCHAR(10);
    var_ccc_5 VARCHAR(10);
    var_ccc_6 VARCHAR(10);
    var_phonetic_name VARCHAR(96);
    /* 2006-09-18 Added by HK Fong SMR20015696 - Start */
    var_schi_name VARCHAR(24);
    var_is_schi_name VARCHAR(2);
	p_refcur refcursor;
    csr CURSOR FOR
    SELECT
        l.hospital_code, l.case_no, l.hkid, l.name, l.mrn, l.discharge_datetime, l.disposal_date
        FROM disposal_list_table AS l
        WHERE l.disposal_date = par_disposal_date AND l.case_no NOT IN (SELECT
            case_no
            FROM disposed_record_table AS r
            WHERE r.hospital_code = l.hospital_code);
BEGIN
    /* 2006-09-18 Added by HK Fong SMR20015696 - End */
    CREATE TEMPORARY TABLE t$temp_output
    (hospital_code VARCHAR(6),
        case_no VARCHAR(24),
        hkid VARCHAR(24) NULL,
        name VARCHAR(96) NULL,
        chi_name VARCHAR(24) NULL,
        mrn VARCHAR(16) NULL,
        sex VARCHAR(2) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        discharge_datetime TIMESTAMP WITHOUT TIME ZONE NULL,
        disposal_date TIMESTAMP WITHOUT TIME ZONE NULL,
        exact_dob_flag VARCHAR(2) NULL,
        /* 2006-09-18 Added by HK Fong SMR20015696 - Start */
        schi_name VARCHAR(24) NULL);
    /* 2006-09-18 Added by HK Fong SMR20015696 - End */
    OPEN csr;
    FETCH csr INTO var_hospital_code, var_case_no, var_hkid, var_name, var_mrn, var_discharge_datetime, var_dispose_dtm;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            CCC_1, CCC_2, CCC_3, CCC_4, CCC_5, CCC_6, Sex, DOB, Exact_DOB_flag
            INTO var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_sex, var_dob, var_exact_dob_flag
            FROM PMI
            WHERE HKID = var_hkid;
        CALL hasp_get_phonetic_chin_name(var_retcode, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_phonetic_name, var_chi_name);

        IF var_retcode != 0 THEN
            BEGIN
                SELECT
                    NULL
                    INTO var_chi_name;
            END;
        END IF;
        /* 2006-09-18 Changed by HK Fong SMR20015696 - Start */
        /*
        insert into #temp_output
        (hospital_code,case_no,hkid,name,chi_name,mrn,sex,dob,discharge_datetime,disposal_date,exact_dob_flag)
        values(@hospital_code,@case_no,@hkid,@name,@chi_name,@mrn,@sex,@dob,@discharge_datetime,@dispose_dtm,@exact_dob_flag)
        */
        IF COALESCE(var_chi_name, '') <> '' THEN
            BEGIN
                CALL hasp_check_schi_name(par_ccc1 => var_ccc_1, par_ccc2 => var_ccc_2, par_ccc3 => var_ccc_3, par_ccc4 => var_ccc_4, par_ccc5 => var_ccc_5, par_ccc6 => var_ccc_6, par_is_schi_name => var_is_schi_name);

                IF var_is_schi_name = 'Y' THEN
                    SELECT
                        var_chi_name
                        INTO var_schi_name;
                ELSE
                    SELECT
                        ''
                        INTO var_schi_name;
                END IF;
            END;
        ELSE
            SELECT
                ''
                INTO var_schi_name;
        END IF;
        INSERT INTO t$temp_output (hospital_code, case_no, hkid, name, chi_name, mrn, sex, dob, discharge_datetime, disposal_date, exact_dob_flag, schi_name)
        VALUES (var_hospital_code, var_case_no, var_hkid, var_name, var_chi_name, var_mrn, var_sex, var_dob, var_discharge_datetime, var_dispose_dtm, var_exact_dob_flag, var_schi_name);
        /* 2006-09-18 Changed by HK Fong SMR20015696 - End */
        FETCH csr INTO var_hospital_code, var_case_no, var_hkid, var_name, var_mrn, var_discharge_datetime, var_dispose_dtm;
    END LOOP;
    CLOSE csr;
    OPEN p_refcur FOR
    SELECT
        hospital_code, case_no, hkid, name, chi_name, mrn, sex, dob, discharge_datetime, disposal_date, exact_dob_flag,
        /* 2006-09-18 Added by HK Fong SMR20015696 - Start */
        schi_name
        /* 2006-09-18 Added by HK Fong SMR20015696 - End */
        FROM t$temp_output
        ORDER BY hkid NULLS FIRST, case_no NULLS FIRST;
    DROP TABLE t$temp_output;
    /*
    
    DROP TABLE IF EXISTS t$temp_output;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;
