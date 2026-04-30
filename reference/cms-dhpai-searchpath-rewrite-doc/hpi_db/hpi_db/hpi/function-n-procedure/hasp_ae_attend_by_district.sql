-- DROP PROCEDURE hasp_ae_attend_by_district(inout int4, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_ae_attend_by_district(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/*
- A&E attendances by districts

    Parameters to be used :-
	     Description               Data Type
	--------------------	       -------------
   1. Hospital code               char(3)
	2. From date                   datetime
	3. To date                     datetime

   Modification History:
		26.07.1999 - Add Hospital code for HPI by Mabel Lau
*/
DECLARE
    var_total_ae_attend integer;
BEGIN
    par_to_date := par_to_date + INTERVAL '1 day';
    /* Add hospital code for HPI by ML on 26.07.1999 */
    SELECT COUNT(*)
    INTO var_total_ae_attend
    FROM Transaction_log
    WHERE Transaction_datetime >= par_from_date
      AND Transaction_datetime < par_to_date
      AND Transaction_type = '300'
      AND Cancel_flag IS NULL
      AND Hospital_code = par_hosp_code;
    /* before changes are comment for select from Case for CPI written below */
    /*
    select distinct District.District_name, count(Case.Case_no), count(Case.Case_no)/@total_ae_attend
    from Case, Transaction_log, District
    where   (Transaction_log.Case_no = Case.Case_no) and
            (Transaction_datetime >= @from_date) and
            (Transaction_datetime < @to_date) and
    	(Transaction_log.Transaction_type = '300') and
    	(District.District_code = Case.District_code) and
    	(Transaction_log.Cancel_flag is null)
    group by District.District_code
    order by District.District_code
    */
    /* end of comment for select from Case for CPI written below */
    /* modify start for the statement to select from Case_view instead of Case */
    /* Add hospital code for HPI by ML on 26.07.1999 */
    DROP TABLE IF EXISTS t$display;
    CREATE TEMPORARY TABLE t$display
    (
        district_name VARCHAR(255),
        case_count    INTEGER,
        percentage    FLOAT
    );
    RAISE NOTICE 'var_total_ae_attend => [%]',var_total_ae_attend;
    INSERT INTO t$display(district_name, case_count, percentage)
    SELECT District.District_name,
           COUNT(Case_view.Case_no),
           COUNT(Case_view.Case_no) / var_total_ae_attend::float AS case_count_ratio
    FROM Case_view
             JOIN Transaction_log ON Transaction_log.Case_no = Case_view.Case_no
             JOIN District ON District.District_code = Case_view.District_code
    WHERE Transaction_datetime >= par_from_date
      AND Transaction_datetime < par_to_date
      AND Transaction_log.Transaction_type = '300'
      AND Transaction_log.Cancel_flag IS NULL
      AND Transaction_log.Hospital_code = par_hosp_code
      AND Case_view.Hospital_code = par_hosp_code
    GROUP BY District.District_code, District.District_name
    ORDER BY District.District_code;

    OPEN p_refcur FOR
        SELECT * FROM t$display;
    /* end of modify for the statement to select from Case_view instead of Case */
    pas_return_code := 0;
    RETURN;
END ;
$procedure$;

;ALTER PROCEDURE "hasp_ae_attend_by_district" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
