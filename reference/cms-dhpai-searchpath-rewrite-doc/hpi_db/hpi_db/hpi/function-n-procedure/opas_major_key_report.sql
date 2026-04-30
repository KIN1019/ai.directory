CREATE OR REPLACE PROCEDURE opas_major_key_report(INOUT pas_return_code int, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE, IN par_hosp_ind VARCHAR, INOUT p_refcur refcursor)
AS 
$BODY$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_ret_code INTEGER;
    var_count INTEGER;
    var_patient_key VARCHAR(16);
    var_original_hkid VARCHAR(24);
    var_ccc_1 VARCHAR(10);
    var_ccc_2 VARCHAR(10);
    var_ccc_3 VARCHAR(10);
    var_ccc_4 VARCHAR(10);
    var_ccc_5 VARCHAR(10);
    var_ccc_6 VARCHAR(10);
    var_phonetic VARCHAR(96);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hosp VARCHAR(6);
    var_temp_date TIMESTAMP WITHOUT TIME ZONE;
    var_hkid_indicator INTEGER;
    var_name_indicator INTEGER;
    var_chi_name_indicator INTEGER;
    var_sex_indicator INTEGER;
    var_dob_indicator INTEGER;
    cur_key CURSOR FOR
    SELECT
        patient_key, original_hkid, COUNT(*)
        FROM t$major_key_changed
        GROUP BY patient_key, original_hkid;
    sql$rowcount BIGINT;
BEGIN
    /* ********************************** */
    /* declare five indicator */
    /* ********************************** */
    SELECT
        1 * INTERVAL '1 day' + par_to_date::TIMESTAMP
        INTO par_to_date;
    SELECT
        hospital_code
        INTO var_hosp
        FROM hospital;
    /* use temp table for separating local, other or all hospitals */
    CREATE TEMPORARY TABLE t$major_key_changed
    AS
    SELECT
        patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm
        FROM cpi_patient_key_changed
        WHERE 1 <> 1;

    IF par_hosp_ind = 'L' THEN
        INSERT INTO t$major_key_changed
        SELECT
            patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm
            FROM h1ahpi_db_dbo.cpi_patient_key_changed
            WHERE update_dtm >= par_from_date AND update_dtm < par_to_date AND update_hospital = var_hosp;
    ELSE
        IF par_hosp_ind = 'O' THEN
            INSERT INTO t$major_key_changed
            SELECT
                patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm
                FROM h1ahpi_db_dbo.cpi_patient_key_changed
                WHERE update_dtm >= par_from_date AND update_dtm < par_to_date AND update_hospital <> var_hosp;
        ELSE
            INSERT INTO t$major_key_changed
            SELECT
                patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm
                FROM h1ahpi_db_dbo.cpi_patient_key_changed
                WHERE update_dtm >= par_from_date AND update_dtm < par_to_date;
        END IF;
    END IF;
    CREATE UNIQUE INDEX major_key ON t$major_key_changed
        (patient_key, original_hkid, update_dtm);
    CREATE INDEX major_key_2 ON t$major_key_changed
        (update_dtm);
    CREATE TEMPORARY TABLE t$major_key
    AS
    SELECT
        patient_key, original_hkid, hkid, patient_name, chi_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, sex, dob, update_hospital, update_by, update_dtm
        FROM cpi_patient_key_changed
        WHERE 1 != 1;
    CREATE UNIQUE INDEX key1 ON t$major_key
        (patient_key, original_hkid, update_dtm);
    OPEN cur_key;
    FETCH cur_key INTO var_patient_key, var_original_hkid, var_count;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            MIN(update_dtm)
            INTO var_temp_date
            FROM t$major_key_changed
            WHERE patient_key = var_patient_key AND original_hkid = var_original_hkid;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount 1
        */
        BEGIN
            SELECT
                update_dtm
                INTO var_update_dtm
                FROM cpi_patient_key_changed
                WHERE patient_key = var_patient_key AND original_hkid = var_original_hkid AND update_dtm < var_temp_date
                ORDER BY update_dtm DESC NULLS FIRST limit 1;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
        /*
        [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
        set rowcount 0
        */
        IF var_error != 0 THEN
            pas_return_code := 99;
            RETURN;
        END IF;

        IF var_rowcount > 0 THEN
            BEGIN
                INSERT INTO t$major_key
                SELECT
                    patient_key, original_hkid, hkid, patient_name, chi_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, sex, dob, update_hospital, update_by, update_dtm
                    FROM cpi_patient_key_changed
                    WHERE patient_key = var_patient_key AND original_hkid = var_original_hkid AND update_dtm = var_update_dtm;

                BEGIN
                    INSERT INTO t$major_key
                    SELECT
                        patient_key, original_hkid, hkid, patient_name, chi_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, sex, dob, update_hospital, update_by, update_dtm
                        FROM t$major_key_changed
                        WHERE patient_key = var_patient_key AND original_hkid = var_original_hkid;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_error != 0 THEN
                    pas_return_code := 99;
                    RETURN;
                END IF;
            END;
        ELSE
            BEGIN
                IF var_count > 1 THEN
                    BEGIN
                        BEGIN
                            INSERT INTO t$major_key
                            SELECT
                                patient_key, original_hkid, hkid, patient_name, chi_name, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, sex, dob, update_hospital, update_by, update_dtm
                                FROM t$major_key_changed
                                WHERE patient_key = var_patient_key AND original_hkid = var_original_hkid AND update_dtm >= par_from_date AND update_dtm < par_to_date;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;

                        IF var_error != 0 THEN
                            pas_return_code := 99;
                            RETURN;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        FETCH cur_key INTO var_patient_key, var_original_hkid, var_count;
    END LOOP;
    CLOSE cur_key;
    /* ********************************************** */
    /* (1)change system datetime's format to string */
    /* (2)add five indicator */
    /* before display  by WL */
    /* ********************************************** */
    SELECT
        0, 0, 0, 0, 0
        INTO var_hkid_indicator, var_sex_indicator, var_name_indicator, var_chi_name_indicator, var_dob_indicator;
    OPEN p_refcur FOR
    SELECT
        patient_key, original_hkid, hkid, patient_name, COALESCE(chi_name, ''), sex, COALESCE(to_char(dob, 'DD/MM/YYYY'), ''), update_hospital, update_by, update_dtm, var_hkid_indicator, var_name_indicator, var_chi_name_indicator, var_sex_indicator, var_dob_indicator, COALESCE(cccode1, ''), COALESCE(cccode2, ''), COALESCE(cccode3, ''), COALESCE(cccode4, ''), COALESCE(cccode5, ''), COALESCE(cccode6, '')
        FROM t$major_key;
    DROP TABLE t$major_key;
    pas_return_code := 0;
    RETURN;
    pas_return_code := 99;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$major_key_changed;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$major_key;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    <<normal_end>>
    BEGIN
    END;

    <<abnormal_end>>
    BEGIN
    END;
END;
$BODY$
LANGUAGE plpgsql;