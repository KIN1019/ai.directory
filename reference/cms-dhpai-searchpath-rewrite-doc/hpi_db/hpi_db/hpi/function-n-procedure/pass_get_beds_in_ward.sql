CREATE OR REPLACE FUNCTION pass_get_beds_in_ward(IN par_hospital_code CHAR, IN par_ward_code CHAR)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
DECLARE
	p_refcur refcursor;
BEGIN
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
    SELECT
        bh.hospital_code, bh.ward_code, bh.cubicle_no, bh.bed_no,
        CASE
            WHEN bh.bed_type = 'E' THEN 'Added'
            WHEN bh.bed_type = 'D' THEN 'Day'
            WHEN bh.bed_type = 'R' THEN 'Official'
            ELSE 'N/A'
        END AS bed_type,
        CASE
            WHEN (w.Case_no IS NULL) THEN 'Vacant'
            ELSE 'Occupied'
        END AS bed_status, bh.isolation_bed,
        CASE
            WHEN (c.isolation_facilities IN ('A', 'AG', 'AN', 'AP', 'AI', 'B', 'BG', 'BN', 'BI', 'BP') AND c.cubicle_service IN ('A', 'I')) THEN 'Y'
            ELSE 'N'
        END AS isolation_cubicle,
        CASE
            WHEN (LENGTH(LTRIM(c.isolation_facilities)) > 0) THEN SUBSTRING(c.isolation_facilities, 1, 1)
            ELSE 'General'
        END AS facility,
        CASE
            WHEN (c.cubicle_service IS NULL OR LTRIM(c.cubicle_service) = '') THEN ''
            ELSE c.cubicle_service
        END AS service,
        CASE
            WHEN (c.cubicle_service = 'NI' OR c.cubicle_service IS NULL OR LTRIM(c.cubicle_service) = '') THEN 'General'
            WHEN (NOT (bst.description IS NULL OR LTRIM(bst.description) = '')) THEN bst.description
            ELSE 'General'
        END AS service_description,
        CASE
            WHEN c.sex = 'M' THEN 'male'
            WHEN c.sex = 'F' THEN 'female'
            ELSE 'mixed'
        END AS sex,
        CASE
            WHEN bh.active_status = 'A' THEN 'Active'
            ELSE 'Inactive'
        END AS active_status, bh.effective_datetime
        /*
        (bh.cubicle_no + ' - Facility: ' +
        case
        	when (len(ltrim(c.isolation_facilities)) > 0) then substring(c.isolation_facilities, 1, 1)
        	else 'general'
        end
        + ' / Service: ' +
        case
        	when (c.cubicle_service='NI' or
        	c.cubicle_service is null or
        	ltrim(c.cubicle_service) = '') then 'General'
        	when (not(bst.description is null or ltrim(bst.description) = '')) then bst.description
        	else 'General'
        end
        + ' / Sex: ' +
        case
        	when c.sex = 'M' then 'male'
        	when c.sex = 'F' then 'female'
        	else 'mixed'
        end) headerDesc
        */
        FROM (SELECT
            ungrouped_query.hospital_code, ungrouped_query.ward_code, cubicle_no, ungrouped_query.bed_no, effective_datetime, active_status, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, bed_ready, physical_bed_no
            FROM (SELECT
                bed_history.hospital_code, bed_history.ward_code, bed_history.cubicle_no, bed_history.bed_no, bed_history.effective_datetime, bed_history.active_status, bed_history.bed_type, bed_history.bed_category, bed_history.specialty_code, bed_history.in_service_specialty, bed_history.row_no, bed_history.col_no, bed_history.update_datetime, bed_history.update_by, bed_history.source_system, bed_history.ciwl_indicator, bed_history.isolation_bed, bed_history.bed_ready, bed_history.physical_bed_no
                FROM bed_history) AS ungrouped_query
            INNER JOIN (SELECT
                hospital_code, ward_code, bed_no, MAX(effective_datetime) AS max_1
                FROM bed_history
                WHERE effective_datetime <= localtimestamp AND ward_code = par_ward_code AND hospital_code = par_hospital_code
                GROUP BY hospital_code, ward_code, bed_no) AS grouped_query
                ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
            WHERE effective_datetime = max_1 AND active_status = 'A') AS bh
        LEFT OUTER JOIN Ward_list AS w
            ON bh.hospital_code = w.Hospital_code AND bh.ward_code = w.Ward_code AND bh.bed_no = w.Bed_no
        LEFT OUTER JOIN cubicle AS c
            ON bh.cubicle_no = c.cubicle_no AND bh.hospital_code = c.hospital_code AND bh.ward_code = c.ward_code AND bh.active_status = 'A' AND bh.effective_datetime = c.effective_date
        LEFT OUTER JOIN bed_service_type AS bst
            ON c.cubicle_service = bst.bed_service
        ORDER BY c.cubicle_no NULLS FIRST, bh.bed_no ASC NULLS FIRST;
END;
$function$;