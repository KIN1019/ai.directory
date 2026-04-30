-- DROP FUNCTION hasp_pat_remain_by_wd(varchar, timestamp, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_pat_remain_by_wd(par_hosp_code character varying, par_input_as_at_dt timestamp without time zone, par_input_pay_code character varying, par_input_ward character varying)
 RETURNS TABLE(result_ward character varying, patient_remain integer)
 LANGUAGE plpgsql
AS $function$
	/**************************************************/
	/* declare variable to be used in store procedure */
	/**************************************************/
DECLARE
    var_cur_case_no VARCHAR(12);
    var_rst_ward    VARCHAR(4);
BEGIN
    /*
          Parameter name               Description
          @hosp_code                   Hospital code
          @input_as_at_db              As at datetime to be processed
          @input_pay_code              Pay Code to be processed
          @input_ward                  Ward code to be processed
    */
    par_input_as_at_dt := par_input_as_at_dt + INTERVAL '1 day';

	/******************************************/
	/* create temp table to store result      */
	/******************************************/
    DROP TABLE IF EXISTS t$result_table;
    CREATE TEMP TABLE t$result_table
    (
        result_case_no VARCHAR(12) NOT NULL PRIMARY KEY,
        result_ward    VARCHAR(4)
    );

    /************************************************************/
	/* find out Cases which not yet discharge at specified date */
	/* and pay_code = @input_pay_code and is Inpatient          */
	/************************************************************/
	/* change Case_type clause to 'Case_no like ' clause */
	/* to speed up selection by ML on 27.08.1999         */
	/* add hosp code for HPI by ML on 27.07.1999         */
    INSERT INTO t$result_table (result_case_no)
    SELECT case_no
    FROM case_view
    WHERE (
        (discharge_code IS NOT NULL AND discharge_datetime >= par_input_as_at_dt) OR
        (discharge_code IS NULL)
        )
      AND admission_datetime < par_input_as_at_dt
      AND case_no LIKE ' HN%'
      AND pay_code LIKE par_input_pay_code
      AND hospital_code = par_hosp_code;

    /*****************************************************/
	/* Find out the above patient's ward current stay at */
	/*****************************************************/

	/*--------------------------------------------------------------*/
	/* change to use cursor as keys cannot be used correctly in HPI */
	/* add hosp code for HPI by ML on 27.07.1999 */
	/* update #result_table
	set result_ward = Movement.Ward_code
	from #result_table r, Movement
	where r.result_case_no = Movement.Case_no and
	      Movement.Hospital_code = @hosp_code and
	      Movement.Movement_count in
	            (select max(Movement_count)
	             from Movement
	             where Movement_datetime < @input_as_at_dt and
	                   Hospital_code = @hosp_code and
	                   r.result_case_no= Movement.Case_no
	             group by Movement.Case_no)                         */
	/*--------------------------------------------------------------*/
    FOR var_cur_case_no IN
        SELECT result_case_no
        FROM t$result_table
        LOOP
            SELECT ward_code
            INTO var_rst_ward
            FROM movement
            WHERE case_no = var_cur_case_no
              AND hospital_code = par_hosp_code
              AND movement_count = (SELECT MAX(movement_count)
                                    FROM movement
                                    WHERE movement_datetime < par_input_as_at_dt
                                      AND hospital_code = par_hosp_code
                                      AND case_no = var_cur_case_no);

            UPDATE t$result_table
            SET result_ward = var_rst_ward
            WHERE result_case_no = var_cur_case_no;
        END LOOP;

    /**********************************************/
	/* Count and Group to form the display result */
	/**********************************************/
    RETURN QUERY
        SELECT t.result_ward, COUNT(*) ::INTEGER AS patient_remain
        FROM t$result_table t
        WHERE t.result_ward LIKE par_input_ward
        GROUP BY t.result_ward
        ORDER BY t.result_ward;

    /*******************************************/
	/* drop temp table used in store procedure */
	/*******************************************/
    DROP TABLE t$result_table;

    RETURN;
END;
$function$
;

;ALTER FUNCTION "hasp_pat_remain_by_wd" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
