-- DROP FUNCTION hpi.cms_dt_get_bed_list(varchar, varchar);

CREATE OR REPLACE FUNCTION hpi.cms_dt_get_bed_list(par_hospital_code character varying, par_ward_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	p_refcur refcursor;
BEGIN
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
    SELECT
        bh.ward_code, bh.bed_no, bh.bed_type, bh.active_status, bh.bed_category, bh.bed_ready, bh.ciwl_indicator, bh.cubicle_no, bh.hospital_code, bh.in_service_specialty, bh.isolation_bed,
        CASE
            WHEN (c.cubicle_service IS NULL OR LTRIM(c.cubicle_service) = '') THEN ''
            ELSE c.cubicle_service
        END AS cubicle_service,
        CASE
            WHEN (w.Case_no IS NULL) THEN 'V'
            ELSE 'O'
        END AS bed_status,
        CASE
            WHEN (c.isolation_facilities IN ('A', 'AG', 'AN', 'AP', 'AI', 'B', 'BG', 'BN', 'BI', 'BP') AND c.cubicle_service IN ('A', 'I')) THEN 'Y'
            ELSE 'N'
        END AS is_iso_bed, (CONCAT(bh.cubicle_no, ' - Facility: ',
        CASE
            WHEN (LENGTH(LTRIM(c.isolation_facilities)) > 0) THEN SUBSTRING(c.isolation_facilities, 1, 1)
            ELSE 'general'
        END, ' / Service: ',
        CASE
            WHEN (c.cubicle_service = 'NI' OR c.cubicle_service IS NULL OR LTRIM(c.cubicle_service) = '') THEN 'General'
            WHEN (NOT (bst.description IS NULL OR LTRIM(bst.description) = '')) THEN bst.description
            ELSE 'General'
        END, ' / Sex: ',
        CASE
            WHEN c.sex = 'M' THEN 'male'
            WHEN c.sex = 'F' THEN 'female'
            ELSE 'mixed'
        END)) AS headerdesc
	from bed_history bh
	left join (
	select hospital_code, ward_code, bed_no, max(effective_datetime) effective_datetime
	from bed_history
	where effective_datetime <= localtimestamp 
	and ward_code = par_ward_code
	and hospital_code = par_hospital_code
	group by hospital_code, ward_code, bed_no
	) bb on bh.hospital_code = bb.hospital_code and bh.ward_code = bb.ward_code and bh.bed_no = bb.bed_no and bh.effective_datetime = bb.effective_datetime
	left join Ward_list w on bh.ward_code = w.Ward_code and bh.bed_no = w.Bed_no
	left join cubicle c on bh.cubicle_no = c.cubicle_no 
	and bh.hospital_code = c.hospital_code
	and bh.ward_code = c.ward_code
	and bh.active_status = 'A' 
	and bh.effective_datetime = c. effective_date
	left join bed_service_type bst on c.cubicle_service = bst.bed_service
	where bh.effective_datetime <= localtimestamp 
	and bh.ward_code = par_ward_code
	and bh.hospital_code = par_hospital_code
	and bh.effective_datetime = bb.effective_datetime
	and bh.active_status = 'A'
        ORDER BY c.cubicle_no NULLS FIRST, bh.bed_no ASC NULLS FIRST;
    return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "cms_dt_get_bed_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";