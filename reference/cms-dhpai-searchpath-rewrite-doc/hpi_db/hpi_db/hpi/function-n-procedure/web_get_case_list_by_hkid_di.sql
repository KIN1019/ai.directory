CREATE OR REPLACE FUNCTION web_get_case_list_by_hkid_di(IN par_hospital_code VARCHAR, IN par_hkid VARCHAR, IN "par_intervalInYear" INTEGER)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
/* Interval In Year for HN and AE cases */
DECLARE
    var_patient_key VARCHAR(8);
    sql$rowcount BIGINT;
	cur1 refcursor;
	cur2 refcursor;
BEGIN
    SELECT
        patient_key
        INTO var_patient_key
        FROM cpi_patient
        WHERE hkid = par_hkid;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount = 0 THEN
        BEGIN
            OPEN cur1 FOR
            SELECT
                hospital_code, case_no, case_type, admission_dtm, discharge_dtm, last_specialty
                FROM cpi_case
                WHERE 1 = 2;
            RETURN NEXT cur1;
        END;
    END IF;

    IF "par_intervalInYear" = 0 THEN
        BEGIN
            OPEN cur2 FOR
            SELECT
                hospital_code, case_no, case_type, admission_dtm, discharge_dtm, last_specialty
                FROM cpi_case
                WHERE patient_key = var_patient_key AND hospital_code = par_hospital_code AND status_code = 'AC'
                ORDER BY admission_dtm DESC NULLS FIRST;
        END;
    ELSE
        BEGIN
            OPEN cur2 FOR
            SELECT
                hospital_code, case_no, case_type, admission_dtm, discharge_dtm, last_specialty
                FROM cpi_case
                WHERE patient_key = var_patient_key AND hospital_code = par_hospital_code AND status_code = 'AC' AND (case_type = 'O' OR (case_type IN ('A', 'I') AND (discharge_dtm IS NULL OR
                /* non-discharge cases */
                discharge_dtm >= - "par_intervalInYear" * INTERVAL '1 year' + timestamp_convert(localtimestamp)::TIMESTAMP
                /* number of year(s) before */
                )))
                ORDER BY admission_dtm DESC NULLS FIRST;
        END;
    END IF;

    RETURN NEXT cur2;
END;
$function$;