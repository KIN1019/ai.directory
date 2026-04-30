-- DROP FUNCTION hkpmi.ehr_get_statistic();

CREATE OR REPLACE FUNCTION hkpmi.ehr_get_statistic()
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    DROP TABLE IF EXISTS t$tmp_code_table;
    CREATE TEMPORARY TABLE t$tmp_code_table
    AS
    SELECT
        'Y' AS ehr_ppi_ind, ehr_doc_type, a.code_field_full_desc AS ehr_doc_type_desc, code_field AS ehr_flag, ec.code_field_full_desc AS ehr_flag_desc
        FROM (SELECT
            CASE
                WHEN ct.code_field IS NULL THEN dt.ehr_doc_type
                ELSE ct.code_field
            END AS ehr_doc_type, COALESCE(code_field_full_desc, 'Code not found on Code Table') AS code_field_full_desc
            FROM (SELECT
                code_field AS ehr_doc_type
                FROM ehr_code_table
                WHERE TRIM(code_type) = 'EHR_DOC_TYPE' AND TRIM(code_name) = 'ehr_doc_type'
            UNION
            SELECT DISTINCT
                ehr_doc_type
                FROM ehr_patient_list) AS dt
            LEFT OUTER JOIN ehr_code_table AS ct
                ON TRIM(dt.ehr_doc_type) = TRIM(ct.code_field) AND TRIM(ct.code_type) = 'EHR_DOC_TYPE' AND TRIM(ct.code_name) = 'ehr_doc_type') AS a, ehr_code_table AS ec
        WHERE TRIM(ec.code_type) = 'EHR_FLAG' AND TRIM(ec.code_name) = 'ehr_flag';
    INSERT INTO t$tmp_code_table
    SELECT
        'N', ehr_doc_type, ehr_doc_type_desc, ehr_flag, ehr_flag_desc
        FROM t$tmp_code_table;
    OPEN p_refcur FOR
    SELECT
        ct.ehr_doc_type, ct."ehr_doc_type_desc", ct.ehr_flag, ct.ehr_flag_desc, ct."ehr_ppi_ind", COALESCE(cnt, 0) AS cnt
        FROM t$tmp_code_table AS ct
        LEFT OUTER JOIN (SELECT
            CASE ehr_ppi_ind
                WHEN 'Y' THEN 'Y'
                ELSE 'N'
            END AS ehr_ppi_ind, ehr_doc_type, ehr_flag, COUNT(*) AS cnt
            FROM ehr_patient_list
            GROUP BY ehr_ppi_ind, ehr_doc_type, ehr_flag) AS l
            ON TRIM(ct.ehr_doc_type) = TRIM(l.ehr_doc_type) AND TRIM(ct.ehr_flag) = TRIM(l.ehr_flag) AND TRIM(ct."ehr_ppi_ind") = TRIM(l.ehr_ppi_ind);
	return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$tmp_code_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "ehr_get_statistic" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
