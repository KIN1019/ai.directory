-- DROP FUNCTION hpi.pass_get_patient_movement(bpchar, bpchar);

CREATE OR REPLACE FUNCTION hpi.pass_get_patient_movement(par_hospital_code character, par_case_no character)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare 
	p_refcur refcursor;
BEGIN
    OPEN p_refcur FOR
    SELECT
        CASE CAST (b.move_desc AS VARCHAR(50))
            WHEN '' THEN ''
            ELSE CAST (b.move_desc AS VARCHAR(50))
        END AS type,
        CASE CAST (a.ward_code AS VARCHAR(50))
            WHEN '' THEN ''
            ELSE CAST (a.ward_code AS VARCHAR(50))
        END AS ward,
        CASE CAST (a.bed_no AS VARCHAR(50))
            WHEN '' THEN ''
            ELSE CAST (a.bed_no AS VARCHAR(50))
        END AS bed,
        CASE CAST (a.specialty AS VARCHAR(50))
            WHEN '' THEN ''
            ELSE CAST (a.specialty AS VARCHAR(50))
        END AS "specialty/unit",
        CASE CAST (a.ward_class AS VARCHAR(50))
            WHEN '' THEN ''
            ELSE CAST (a.ward_class AS VARCHAR(50))
        END AS "ward class", CONCAT(to_char(a.movement_dtm, 'dd mon yyyy'), ' ', to_char(a.movement_dtm, 'hh:mm:ss:mmm')) AS "Movement Time"
        FROM cpi_movement AS a, cpi_movement_type AS b
        WHERE a.hospital_code = par_hospital_code AND a.case_no = par_case_no AND a.movement_type = b.move_code
        ORDER BY a.movement_count NULLS FIRST;
END;
$function$
;
