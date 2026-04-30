CREATE OR REPLACE PROCEDURE web_get_last_case_no_by_hkid(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_hkid VARCHAR, IN par_case_type VARCHAR, INOUT p_refcur refcursor)
AS 
$BODY$
DECLARE
    var_patient_key VARCHAR(16);
    sql$rowcount BIGINT;
BEGIN
    SELECT
        patient_key
        INTO var_patient_key
        FROM cpi_patient
        WHERE hkid = par_hkid;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        case_no, ungrouped_query.status_code
        FROM (SELECT
            case_no, status_code, patient_key, admission_dtm, case_type, par_case_type
            FROM cpi_case) AS ungrouped_query
        INNER JOIN (SELECT
            patient_key, status_code, MAX(admission_dtm) AS max_1
            FROM cpi_case
            WHERE hospital_code = par_hospital_code AND patient_key = var_patient_key AND status_code = 'AC' AND case_type = par_case_type
            GROUP BY patient_key, status_code) AS grouped_query
            ON (ungrouped_query.patient_key = grouped_query.patient_key OR (ungrouped_query.patient_key IS NULL AND grouped_query.patient_key IS NULL))
        WHERE admission_dtm = max_1 AND case_type = par_case_type;
END;
$BODY$
LANGUAGE plpgsql;