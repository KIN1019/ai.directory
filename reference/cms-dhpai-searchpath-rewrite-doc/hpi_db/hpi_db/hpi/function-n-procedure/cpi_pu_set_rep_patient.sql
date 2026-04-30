CREATE OR REPLACE PROCEDURE cpi_pu_set_rep_patient(INOUT pas_return_code int, IN par_hospital_code CHAR, IN par_patient_key CHAR, IN par_update_by CHAR)
AS 
$BODY$
DECLARE
    var_rep_clusters INTEGER;
    var_rep_hospital INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_cnt INTEGER;
    sql$rowcount BIGINT;
BEGIN
    SELECT
        bit_value
        INTO var_rep_hospital
        FROM rep_cluster_bits
        WHERE hospital_code = par_hospital_code;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF (sql$rowcount = 0) THEN
        BEGIN
            RAISE NOTICE 'Fail to get bit value from rep_cluster_bits, set replicate bit to cpi_patient is rejected!';
            pas_return_code := 1;
            RETURN;
        END;
    END IF;
    SELECT
        COUNT(*)
        INTO var_cnt
        FROM cpi_patient
        WHERE patient_key = par_patient_key;

    IF (var_cnt = 0) THEN
        BEGIN
            RAISE NOTICE 'Patient not found, set replicate bit to cpi_patient is rejected!';
            pas_return_code := 1;
            RETURN;
        END;
    END IF;

    BEGIN
        UPDATE cpi_patient
        SET rep_clusters = rep_clusters || var_rep_hospital, update_by = par_update_by, update_dtm = timestamp_convert(localtimestamp)
            WHERE patient_key = par_patient_key;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
    var_rowcount := sql$rowcount;

    IF (var_error != 0) OR (var_rowcount = 0) THEN
        BEGIN
            RAISE NOTICE 'Fail to update cpi_patient, set replicate bit to cpi_patient is rejected!';
            pas_return_code := 1;
            RETURN;
        END;
    END IF;
    pas_return_code := 0;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;