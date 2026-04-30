CREATE OR REPLACE PROCEDURE hasp_get_access_changed(INOUT pas_return_code int, IN par_hkid VARCHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE, IN par_active_only VARCHAR DEFAULT null, INOUT p_refcur refcursor DEFAULT NULL)
  LANGUAGE plpgsql
AS 
$procedure$
/*
2015-08-06 : Freda TONG , PasCr-2014/00244 - Able to know the number of patients with confidentiality log
and to add  sort listed  function to show the active patient only
*/
DECLARE
    var_temp_patient_key VARCHAR(8);
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_temp_count INTEGER;
    var_rowcount INTEGER;
    var_total_patient INTEGER;
    get_access_changed_csr CURSOR FOR
    SELECT
        patient_key, COUNT(*)
        FROM cpi_access_changed
        WHERE update_dtm >= par_from_date AND update_dtm <= par_to_date
        GROUP BY patient_key order by min(update_dtm);
    sql$rowcount BIGINT;
BEGIN
    IF (par_hkid is not NULL) THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                original_hkid AS hkid, patient_key AS original_hkid, update_dtm AS system_datetime, access_status AS access_status, update_hospital AS hospital_code, update_by AS user_id, 1 AS total_patient
                FROM cpi_access_changed
                WHERE original_hkid = par_hkid;
        END;
    ELSE
        IF (par_from_date is not NULL AND par_to_date is not NULL) THEN
            BEGIN
                DROP TABLE IF EXISTS t$access_chg;
                CREATE TEMPORARY TABLE t$access_chg
                AS
                SELECT
                    var_total_patient AS total_patient, original_hkid AS hkid, patient_key AS original_hkid, update_dtm AS system_datetime, access_status AS access_status, update_hospital AS hospital_code, update_by AS user_id
                    FROM cpi_access_changed
                    WHERE 1 != 1;
                
                DROP TABLE IF EXISTS t$temp_tbl;
                CREATE TEMPORARY TABLE t$temp_tbl
                AS
                SELECT
                    ungrouped_query.patient_key, original_hkid, access_status
                    FROM (SELECT
                        patient_key, original_hkid, access_status, update_dtm
                        FROM cpi_access_changed AS a) AS ungrouped_query
                    INNER JOIN (SELECT
                        patient_key, MAX(update_dtm) AS max_1
                        FROM cpi_access_changed AS a
                        WHERE update_dtm >= par_from_date AND update_dtm <= par_to_date
                        GROUP BY patient_key) AS grouped_query
                        ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                    WHERE update_dtm = max_1
                    ORDER BY patient_key NULLS FIRST;
                var_total_patient := (SELECT
                    COUNT(*)
                    FROM t$temp_tbl);
                OPEN get_access_changed_csr;
                FETCH get_access_changed_csr INTO var_temp_patient_key, var_temp_count;

                WHILE (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) = 0 LOOP
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 1
                    */
                    SELECT
                        update_dtm
                        INTO var_system_dtm
                        FROM cpi_access_changed
                        WHERE patient_key = var_temp_patient_key AND update_dtm < par_from_date
                        ORDER BY update_dtm DESC NULLS FIRST limit 1;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;
                    /*
                    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
                    set rowcount 0
                    */
                    IF var_rowcount > 0 THEN
                        BEGIN
                            INSERT INTO t$access_chg
                            SELECT
                                var_total_patient AS total_patient, original_hkid AS hkid, patient_key AS original_hkid, update_dtm AS system_datetime, access_status AS access_status, update_hospital AS hospital_code, update_by AS user_id
                                FROM cpi_access_changed
                                WHERE update_dtm >= var_system_dtm AND update_dtm <= par_to_date AND patient_key = var_temp_patient_key;
                        END;
                    ELSE
                        BEGIN
                            IF var_temp_count > 1 THEN
                                BEGIN
                                    INSERT INTO t$access_chg
                                    SELECT
                                        var_total_patient AS total_patient, original_hkid AS hkid, patient_key AS original_hkid, update_dtm AS system_datetime, access_status AS access_status, update_hospital AS hospital_code, update_by AS user_id
                                        FROM cpi_access_changed
                                        WHERE update_dtm >= par_from_date AND update_dtm <= par_to_date AND patient_key = var_temp_patient_key;
                                END;
                            END IF;
                        END;
                    END IF;
                    FETCH get_access_changed_csr INTO var_temp_patient_key, var_temp_count;
                END LOOP; /* Adaptive Server has expanded all '*' elements in the following statement */
                OPEN p_refcur FOR
                SELECT
                    HKID, Original_HKID, System_datetime, Access_status, Hospital_code, user_id, total_patient
                    FROM t$access_chg;
                --DROP TABLE t$access_chg;
                --DROP TABLE t$temp_tbl;
                CLOSE get_access_changed_csr;
            END;
        ELSE
            IF (par_active_only = 'TRUE') THEN
                BEGIN
                    DROP TABLE IF EXISTS t$access_chg_2;
                    CREATE TEMPORARY TABLE t$access_chg_2
                    AS
                    SELECT
                        var_total_patient AS total_patient, original_hkid AS hkid, patient_key AS original_hkid, update_dtm AS system_datetime, access_status AS access_status, update_hospital AS hospital_code, update_by AS user_id
                        FROM cpi_access_changed
                        WHERE 1 != 1;
                    DROP TABLE IF EXISTS t$temp_tbl_2;
                    CREATE TEMPORARY TABLE t$temp_tbl_2
                    AS
                    SELECT
                        original_hkid, ungrouped_query.patient_key, update_dtm, access_status, update_hospital, update_by
                        FROM (SELECT
                            original_hkid, patient_key, update_dtm, access_status, update_hospital, update_by
                            FROM cpi_access_changed AS a) AS ungrouped_query
                        INNER JOIN (SELECT
                            patient_key, MAX(update_dtm) AS max_1
                            FROM cpi_access_changed AS a
                            GROUP BY patient_key) AS grouped_query
                            ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
                        WHERE update_dtm = max_1 AND access_status = 'C'
                        ORDER BY patient_key NULLS FIRST;
                    var_total_patient := (SELECT
                        COUNT(*)
                        FROM t$temp_tbl_2);
                    INSERT INTO t$access_chg_2
                    SELECT
                        var_total_patient AS total_patient, original_hkid AS hkid, patient_key AS original_hkid, update_dtm AS system_datetime, access_status AS access_status, update_hospital AS hospital_code, update_by AS user_id
                        FROM t$temp_tbl_2;
                    OPEN p_refcur FOR
                    SELECT
                        HKID, Original_HKID, System_datetime, Access_status, Hospital_code, user_id, total_patient
                        FROM t$access_chg_2;
                    --DROP TABLE t$access_chg_2;
                    --DROP TABLE t$temp_tbl_2;
                END;
            ELSE
                BEGIN
                    pas_return_code := 99;
                    RETURN;
                END;
            END IF;
        END IF;
    END IF;
    pas_return_code := 0;
    /*
    
    DROP TABLE IF EXISTS t$access_chg;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$temp_tbl;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$access_chg_2;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$temp_tbl_2;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$;

;ALTER PROCEDURE "hasp_get_access_changed" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
