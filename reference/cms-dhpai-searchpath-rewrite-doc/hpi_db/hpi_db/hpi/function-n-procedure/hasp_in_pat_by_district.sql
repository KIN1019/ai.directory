-- DROP FUNCTION hasp_in_pat_by_district(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hasp_in_pat_by_district(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS TABLE(district_board character varying, district_name character varying, case_count integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Adjust the to_date to include the entire day
    par_to_date := par_to_date + INTERVAL '1 day';

    /* changed by Karen at 1996-04-29 for cpi */
    /* before changes are comment for select from Case_view */
    /*
    select distinct District_board, District.District_name, count(Case.Case_no)
    from Case, Transaction_log, District, PMI
    where   (Transaction_log.Case_no = Case.Case_no) and
            (Transaction_datetime >= @from_date) and
            (Transaction_datetime < @to_date) and
            (Cancel_flag is null) and
            (Case.HKID = PMI.HKID) and
            (Transaction_log.Transaction_type like '13_') and
            (District.District_code =* PMI.District_code)
    group by District.District_code
    */
    /* end of comment for select from Case_view */

    /* modify start for select from Case_view */

    /******************************************/

    /* --- add hosp code for HPI by ML on 26.07.1999 --- */
    /* --- use PMI_wo_MRN instead of PMI on 26.07.1999 --- */
    /* --- code index to speed up ---*/

    RETURN QUERY
        SELECT DISTINCT d.district_board,
                        d.district_name,
                        COUNT(cv.case_no)::INTEGER AS case_count
        FROM case_view cv
                 JOIN
             transaction_log tl ON tl.case_no = cv.case_no
                 JOIN
             pmi_wo_mrn p ON cv.hkid = p.hkid
                 LEFT JOIN
             district d ON d.district_code = p.district_code
        WHERE cv.hospital_code = par_hosp_code
          AND tl.hospital_code = par_hosp_code
          AND tl.transaction_datetime >= par_from_date
          AND tl.transaction_datetime < par_to_date
          AND tl.cancel_flag IS NULL
          AND tl.transaction_type LIKE '13_'
        GROUP BY d.district_board, d.district_name
        ORDER BY d.district_name NULLS FIRST;
    /* end of modify for select from Case_view */

END;
$function$
;

;ALTER FUNCTION "hasp_in_pat_by_district" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
