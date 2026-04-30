-- DROP FUNCTION hpi.web_pmi_hpi_get_case_movement(varchar, varchar);

CREATE OR REPLACE FUNCTION web_pmi_hpi_get_case_movement(par_hospitalcode character varying, par_caseno character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
BEGIN
    OPEN p_refcur FOR
    SELECT
        a.hospital_code, a.case_no, a.movement_count, a.ward_code, a.bed_no,
        a.specialty, a.ward_class, a.movement_type, a.movement_dtm,
        a.treatment_location, a.update_dtm, a.update_by, a.doctor_code,
        b.move_desc, ww.location_code
    FROM cpi_movement AS a
    INNER JOIN cpi_movement_type AS b ON a.movement_type = b.move_code
    LEFT JOIN (
    	select ungrouped_query.hospital_code, ungrouped_query.ward_code, location_code
        FROM (SELECT w.hospital_code, w.ward_code, w.location_code, w.effective_date
              FROM ward_location AS w) AS ungrouped_query
    	INNER JOIN (
	    	SELECT w.hospital_code, w.ward_code, MAX(w.effective_date) AS max_1
	        FROM cpi_movement AS a2, ward_location AS w
	        WHERE a2.hospital_code = w.hospital_code 
	        AND a2.ward_code = w.ward_code
	        AND w.effective_date <= a2.movement_dtm
	        AND w.active_status = 'A'
	        AND a2.hospital_code = par_hospitalcode
	        AND a2.case_no = par_caseno
	        GROUP BY w.hospital_code, w.ward_code) AS grouped_query
    	ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
    	WHERE effective_date = max_1) AS ww
    ON a.hospital_code = ww.hospital_code AND a.ward_code = ww.ward_code
    WHERE a.hospital_code = par_hospitalcode AND a.case_no = par_caseno
    ORDER BY a.movement_count NULLS FIRST;
    
    return next p_refcur;
END;
$function$
;


;ALTER FUNCTION "web_pmi_hpi_get_case_movement" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
