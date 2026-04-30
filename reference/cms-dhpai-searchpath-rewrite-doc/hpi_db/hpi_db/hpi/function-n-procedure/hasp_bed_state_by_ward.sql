-- DROP FUNCTION hpi.hasp_bed_state_by_ward(varchar, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_bed_state_by_ward(par_hosp_code character varying, par_input_to_datetime timestamp without time zone, par_input_ward character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* ---------------------------------------------------------------------------------------------- */
/* 20180105 to fix/avoid following error : remove SELECT * */

/* ---------------------------------------------------------------------------------------------- */
/* DBCC upgrade_object: Upgrading PROCEDURE dbo.hasp_bed_state_by_ward */
/* Warning: PROCEDURE hasp_bed_state_by_ward contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_bed_state_by_ward. */
/* Warning: PROCEDURE hasp_bed_state_by_ward contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_bed_state_by_ward. */
/* Msg 11031, Level 16, State 1: */
/* Server 'Fxxxx', Procedure 'hasp_bed_state_by_ward', Line 43: */
/* Execution of procedure hasp_bed_state_by_ward failed because of errors parsing the source text in syscomments during upgrade. Please drop and recreate dbo.hasp_bed_state_by_ward. */

/* ---------------------------------------------------------------------------------------------- */
DECLARE
    var_ward VARCHAR(04);
    var_disc_sum INTEGER;
    var_off_sum INTEGER;
    var_day_sum INTEGER;
    p_refcur refcursor;
    extra_ward_csr CURSOR FOR
    SELECT
        tran_ward
        FROM t$extra_ward_table;
    disc_csr CURSOR FOR
    SELECT
        tran_ward, SUM(COALESCE(tran_sum, 0)) AS tran_sum
        FROM t$tran_table
        WHERE tran_type LIKE '13_'
        GROUP BY tran_ward;
    off_csr CURSOR FOR
    SELECT
        Ward_code, SUM(Official_bed) AS off_sum
        FROM t$temp_off_table
        GROUP BY Ward_code;
    day_csr CURSOR FOR
    SELECT
        Ward_code, SUM(Day_bed) AS off_sum
        FROM t$temp_day_table
        GROUP BY Ward_code;
BEGIN
    /*
    Parameter name               Description
    @hosp_code                   Hospital code
    @input_to_datetime           To datetime to be processed
    @input_ward                  Ward code to be processed
    */
    /* ************************************************** */
    /* declare variables */
    /* ************************************************** */
    /* ************************************************** */
    /* Create temp table for holding the result */
    /* ************************************************** */
    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMPORARY TABLE t$tx_table
    (tx_ward VARCHAR(04) NULL,
        tx_desc VARCHAR(30) NULL,
        tx_prev_remain INTEGER DEFAULT 0,
        tx_occupied INTEGER DEFAULT 0,
        tx_off_available INTEGER NULL,
        tx_day_available INTEGER NULL);
    /* ************************************************** */
    /* Retrieve previous remaining by ward */
    /* ************************************************** */
    /* add hosp code for HPI by ML on 27.07.1999 */
    DROP TABLE IF EXISTS t$start_table;
    CREATE TEMPORARY TABLE t$start_table
    AS
    SELECT
        MAX(Ward_spec_tx_date) AS start_date, Ward_code AS start_ward, Specialty_code AS start_spec, Treatment_location AS start_loc
        FROM  Ward_spec_tx
        WHERE Ward_spec_tx_date < to_char(par_input_to_datetime, 'YYYYMMDD')::timestamp AND Ward_code LIKE par_input_ward AND Hospital_code = par_hosp_code
        GROUP BY Ward_code, Specialty_code, Treatment_location;
    INSERT INTO t$tx_table (tx_ward, tx_prev_remain)
    SELECT
        start_ward, SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) - SUM(COALESCE(Canc_admission, 0)) - SUM(COALESCE(Discharge, 0)) + SUM(COALESCE(Canc_discharge, 0)) + SUM(COALESCE(Transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Transfer_out, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) - SUM(COALESCE(Death, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) + SUM(COALESCE(Canc_transfer_out_to_TD, 0))
        FROM t$start_table,  Ward_spec_tx_adj_view
        WHERE t$start_table.start_date = Ward_spec_tx_date AND t$start_table.start_ward = Ward_code AND t$start_table.start_spec = Specialty_code AND COALESCE(t$start_table.start_loc, 'null') = COALESCE(Treatment_location, 'null') AND Hospital_code = par_hosp_code
        /* add hosp code for HPI by ML on 27.07.1999 */
        GROUP BY t$start_table.start_ward;
    /* ****************************************************** */
    /* cal. tran between @start_date and @input_to_datetime */
    /* ****************************************************** */
    DROP TABLE IF EXISTS t$tran_table;
    CREATE TEMPORARY TABLE t$tran_table
    AS
    SELECT
        From_ward_code AS tran_ward, Transaction_type AS tran_type, COUNT(*) AS tran_sum
        FROM  Transaction_log
        /* --from Transaction_log */
        WHERE Transaction_datetime > to_char(par_input_to_datetime, 'YYYYMMDD')::timestamp AND Transaction_datetime <= par_input_to_datetime AND (Transaction_type IN ('100', '141', '140', '160', '170') OR Transaction_type LIKE '13_') AND From_ward_code LIKE par_input_ward AND Cancel_flag IS NULL AND Hospital_code = par_hosp_code
        /* add hosp code for HPI by ML on 27.07.1999 */
        GROUP BY From_ward_code, Transaction_type;
    /* ******************************************************** */
    /* insert ward code (those not exist in Ward_spec_tx, but */
    /* has trasaction within requested date) */
    /* ******************************************************** */
    DROP TABLE IF EXISTS t$extra_ward_table;
    CREATE TEMPORARY TABLE t$extra_ward_table
    AS
    SELECT DISTINCT
        tran_ward
        FROM t$tran_table
        WHERE tran_ward NOT IN (SELECT
            tx_ward
            FROM t$tx_table);
    OPEN extra_ward_csr;
    FETCH extra_ward_csr INTO var_ward;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        INSERT INTO t$tx_table
        VALUES (var_ward, NULL, 0, 0, 0, 0);
        FETCH extra_ward_csr INTO var_ward;
    END LOOP;
    CLOSE extra_ward_csr;
    DROP TABLE t$extra_ward_table;
    /* ************************************************* */
    /* cal current occupied no. */
    /* ************************************************* */
    /*
    [3064 - Severity CRITICAL - In PostgreSQL you should not repeat the target table in the FROM clause of an UPDATE statement. Perform a manual conversion.]
    update #tx_table
    set tx_occupied =tx_prev_remain + isnull(tran_sum,0)
    from #tx_table, #tran_table
    where tx_ward *= tran_ward and tran_type = '100'
    */
    UPDATE t$tx_table
    SET tx_occupied = tx_prev_remain
    WHERE tx_occupied = 0;
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied + COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_ward = tran_ward AND tran_type = '100';
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied + COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_ward = tran_ward AND tran_type = '141';
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied - COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_ward = tran_ward AND tran_type = '140';
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied - COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_ward = tran_ward AND tran_type = '160';
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied + COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_ward = tran_ward AND tran_type = '170';
    OPEN disc_csr;
    FETCH disc_csr INTO var_ward, var_disc_sum;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        UPDATE t$tx_table
        SET tx_occupied = tx_occupied - var_disc_sum
            WHERE tx_ward = var_ward;
        FETCH disc_csr INTO var_ward, var_disc_sum;
    END LOOP;
    CLOSE disc_csr;
    /* *********************************************************** */
    /* cal. no. of official bed in each ward */
    /* *********************************************************** */
    /* add hosp code for HPI by ML on 27.07.1999 */
    /* --select * into #temp_off_table   -- 20180105 */
    DROP TABLE IF EXISTS t$temp_off_table;
    CREATE TEMPORARY TABLE t$temp_off_table
    AS
    SELECT
        Hospital_code, Effective_date, ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed
        FROM (SELECT
            Hospital_code, Effective_date, Ward_code, Specialty_code, Official_bed, Day_bed
            FROM  Ward_specialty) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM  Ward_specialty
            WHERE Effective_date <= par_input_to_datetime AND Ward_code LIKE par_input_ward AND Hospital_code = par_hosp_code
            GROUP BY Ward_code, Specialty_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
        WHERE Effective_date = max_1 AND ungrouped_query.Specialty_code = grouped_query.Specialty_code AND ungrouped_query.Ward_code LIKE par_input_ward AND Hospital_code = par_hosp_code
        ORDER BY Ward_code NULLS FIRST;
    OPEN off_csr;
    FETCH off_csr INTO var_ward, var_off_sum;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF NOT EXISTS (SELECT
            *
            FROM t$tx_table
            WHERE tx_ward = var_ward) THEN
            BEGIN
                IF var_off_sum > 0 THEN
                    INSERT INTO t$tx_table
                    VALUES (var_ward, NULL, 0, 0, var_off_sum, 0);
                END IF;
            END;
        ELSE
            UPDATE t$tx_table
            SET tx_off_available = var_off_sum
                WHERE tx_ward = var_ward;
        END IF;
        FETCH off_csr INTO var_ward, var_off_sum;
    END LOOP;
    CLOSE off_csr;
    DROP TABLE t$temp_off_table;
    /* ********************************************* */
    /* cal. Day bed by ward */
    /* ********************************************* */
    /* add hosp code for HPI by ML on 27.07.1999 */
    /* select * into #temp_day_table -- 20180105 */
    DROP TABLE IF EXISTS t$temp_day_table;
    CREATE TEMPORARY TABLE t$temp_day_table
    AS
    SELECT
        Hospital_code, Effective_date, ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed
        FROM (SELECT
            Hospital_code, Effective_date, Ward_code, Specialty_code, Official_bed, Day_bed
            FROM  Ward_specialty) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM  Ward_specialty
            WHERE Effective_date <= par_input_to_datetime AND Ward_code LIKE par_input_ward AND Hospital_code = par_hosp_code
            GROUP BY Ward_code, Specialty_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
        WHERE Effective_date = max_1 AND ungrouped_query.Specialty_code = grouped_query.Specialty_code AND ungrouped_query.Ward_code LIKE par_input_ward AND Hospital_code = par_hosp_code
        ORDER BY Ward_code NULLS FIRST;
    OPEN day_csr;
    FETCH day_csr INTO var_ward, var_day_sum;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF NOT EXISTS (SELECT
            *
            FROM t$tx_table
            WHERE tx_ward = var_ward) THEN
            BEGIN
                IF var_day_sum > 0 THEN
                    INSERT INTO t$tx_table
                    VALUES (var_ward, NULL, 0, 0, 0, var_day_sum);
                END IF;
            END;
        ELSE
            UPDATE t$tx_table
            SET tx_day_available = var_day_sum
                WHERE tx_ward = var_ward;
        END IF;
        FETCH day_csr INTO var_ward, var_day_sum;
    END LOOP;
    CLOSE day_csr;
    DROP TABLE t$temp_day_table;
    /* ******************************************* */
    /* add ward desc */
    /* ******************************************* */
    /*
    update  #tx_table
    set tx_desc = Description
    from Ward, #tx_table
    where #tx_table.tx_ward = Ward.Ward_code
    */
    /* ****get most up-to-date desc**** */
    /* ****date :  10 Feb 1997 by Winnie Lau ** */
    /*
    update #tx_table
    set tx_desc =   (select w.Description
                     from Ward w, #tx_table a
                     where a.tx_ward= w.Ward_code
                     and w.Effective_date = (select max(Effective_date)
                                            from Ward
                                            where Ward_code = a.tx_ward
                                            and Effective_date <= @input_to_datetime))
    */
    /* add hosp code for HPI by ML on 27.07.1999 */
    DROP TABLE IF EXISTS t$tmp_ward;
    CREATE TEMPORARY TABLE t$tmp_ward
    AS
    SELECT
        ungrouped_query.Ward_code, Description
        FROM (SELECT
            Ward_code, Description, Effective_date, Hospital_code
            FROM  Ward) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, MAX(Effective_date) AS max_1
            FROM  Ward
            WHERE Effective_date <= par_input_to_datetime AND Hospital_code = par_hosp_code
            GROUP BY Ward_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
        WHERE Effective_date = max_1 AND Hospital_code = par_hosp_code;
    UPDATE t$tx_table
    SET tx_desc = Description
    FROM t$tmp_ward
        WHERE t$tx_table.tx_ward = t$tmp_ward.Ward_code;
    DROP TABLE t$tmp_ward;
    /* ***************************** */
    /* display result */
    /* ***************************** */
    OPEN p_refcur FOR
    SELECT
        tx_ward, tx_desc,tx_occupied,tx_off_available,tx_day_available
        FROM t$tx_table
        WHERE tx_occupied > 0 OR tx_off_available > 0 OR tx_day_available > 0
        ORDER BY tx_ward NULLS FIRST;
    RETURN next p_refcur;
    /*

    DROP TABLE IF EXISTS t$tx_table;
    */
    /*

    Temporary table must be removed before end of the function.
    */
    /*

    DROP TABLE IF EXISTS t$start_table;
    */
    /*

    Temporary table must be removed before end of the function.
    */
    /*

    DROP TABLE IF EXISTS t$tran_table;
    */
    /*

    Temporary table must be removed before end of the function.
    */
    /*

    DROP TABLE IF EXISTS t$extra_ward_table;
    */
    /*

    Temporary table must be removed before end of the function.
    */
    /*

    DROP TABLE IF EXISTS t$temp_off_table;
    */
    /*

    Temporary table must be removed before end of the function.
    */
    /*

    DROP TABLE IF EXISTS t$temp_day_table;
    */
    /*

    Temporary table must be removed before end of the function.
    */
    /*

    DROP TABLE IF EXISTS t$tmp_ward;
    */
    /*

    Temporary table must be removed before end of the function.
    */
END;
$function$
;


;ALTER FUNCTION "hasp_bed_state_by_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
