-- DROP FUNCTION hpi.hasp_bed_state_by_spec(varchar, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.hasp_bed_state_by_spec(par_hosp_code character varying, par_input_to_datetime timestamp without time zone, par_input_spec character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* add hosp code for HPI by Mabel LAU on 27.07.1999 */
/* ---------------------------------------------------------------------------------------------- */
/* 20180105 to fix/avoid following error : remove SELECT * */

/* ------------------------------------------------------------------------------------------------ */

/* --DBCC upgrade_object: Upgrading PROCEDURE dbo.hasp_bed_state_by_spec */
/* Warning: PROCEDURE hasp_bed_state_by_spec contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_bed_state_by_spec. */
/* Warning: PROCEDURE hasp_bed_state_by_spec contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_bed_state_by_spec. */
/* Warning: PROCEDURE hasp_bed_state_by_spec contains the SELECT * construct in the outermost */
/* SELECT query. */
/* Please verify that the table(s) referenced in the SELECT * have not */
/* been altered.  During upgrade the SELECT * is expanded to include all */
/* columns of the table(s). */
/* Run DBCC upgrade_object with the 'force' option to upgrade hasp_bed_state_by_spec. */

/* --Msg 11031, Level 16, State 1: */

/* --Server 'XXXX', Procedure 'hasp_bed_state_by_spec', Line 103: */

/* --Execution of procedure hasp_bed_state_by_spec failed because of errors parsing the source text in syscomments during upgrade. Please DROP and recreate dbo.hasp_bed_state_by_spec. */

/* ------------------------------------------------------------------------------------------------ */
DECLARE
    var_spec VARCHAR(04);
    var_loc VARCHAR(04);
    var_disc_sum INTEGER;
    var_off_sum INTEGER;
    var_day_sum INTEGER;
    var_sum INTEGER;
    var_dsp_spec VARCHAR(04);
    var_dsp_desc VARCHAR(30);
    var_dsp_occupied INTEGER;
    var_dsp_vacant INTEGER;
    var_dsp_off_available INTEGER;
    var_dsp_excess INTEGER;
    var_dsp_occupancy REAL;
    var_dsp_day_available INTEGER;
    var_total_spec VARCHAR(05);
    var_total_occupied INTEGER;
    var_total_vacant INTEGER;
    var_total_off_available INTEGER;
    var_total_excess INTEGER;
    var_total_occupancy REAL;
    var_total_day_available INTEGER;
    var_prev_spec VARCHAR(04);
    var_count INTEGER;
    var_occ NUMERIC(6, 2);
    var_real_occupied REAL;
    var_real_available REAL;
    var_spec_occupied INTEGER;
    p_refcur refcursor;
    disc_csr CURSOR FOR
    SELECT
        tran_spec, tran_loc, SUM(COALESCE(tran_sum, 0)) AS tran_sum
        FROM t$tran_table
        WHERE tran_type LIKE '13_'
        GROUP BY tran_spec, tran_loc;
    off_csr CURSOR FOR
    SELECT
        Specialty_code, SUM(Official_bed) AS off_sum
        FROM t$temp_off_table
        GROUP BY Specialty_code;
    day_csr CURSOR FOR
    SELECT
        Specialty_code, SUM(Day_bed) AS off_sum
        FROM t$temp_day_table
        GROUP BY Specialty_code;
    sum_csr CURSOR FOR
    SELECT
        tx_loc, SUM(tx_occupied)
        FROM t$tx_table
        WHERE tx_loc IS NOT NULL
        GROUP BY tx_loc;
    dsp_csr CURSOR FOR
    SELECT
        COALESCE(tx_spec, ''), COALESCE(tx_loc,''), tx_occupied, tx_off_available, tx_day_available
        FROM t$tx_table
        WHERE tx_occupied > 0 OR tx_off_available > 0 OR tx_day_available > 0
        ORDER BY tx_spec NULLS FIRST, tx_loc NULLS FIRST;
BEGIN
    /*
    Parameter name               Description
    @hosp_code                   Hospital code
    @input_to_datetime           To datetime to be processed
    @input_ward                  Spec code to be processed
    */
    /* ************************************************** */
    /* declare variables */
    /* ************************************************** */
    /* ************************************************** */
    /* Create temp table for holding the result */
    /* ************************************************** */
    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMPORARY TABLE t$tx_table
    (tx_spec VARCHAR(04) NULL,
        tx_loc VARCHAR(04) NULL,
        tx_prev_remain INTEGER DEFAULT 0,
        tx_occupied INTEGER DEFAULT 0,
        tx_off_available INTEGER DEFAULT 0,
        tx_day_available INTEGER DEFAULT 0);
    /* ************************************************** */
    /* Retrieve previous remaining by ward */
    /* ************************************************** */
    DROP TABLE IF EXISTS t$start_table;
    CREATE TEMPORARY TABLE t$start_table
    AS
    SELECT
        MAX(Ward_spec_tx_date) AS start_date, Ward_code AS start_ward, Specialty_code AS start_spec, Treatment_location AS start_loc
        FROM Ward_spec_tx
        WHERE Ward_spec_tx_date < to_char(par_input_to_datetime, 'YYYYMMDD')::timestamp AND Specialty_code LIKE par_input_spec AND Hospital_code = par_hosp_code
        /* add hosp code for HPI by ML on 27.07.1999 */
        GROUP BY Ward_code, Specialty_code, Treatment_location;
    INSERT INTO t$tx_table (tx_spec, tx_loc, tx_prev_remain)
    SELECT
        start_spec, start_loc, SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) - SUM(COALESCE(Canc_admission, 0)) - SUM(COALESCE(Discharge, 0)) + SUM(COALESCE(Canc_discharge, 0)) + SUM(COALESCE(Transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Transfer_out, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) - SUM(COALESCE(Death, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) + SUM(COALESCE(Canc_transfer_out_to_TD, 0))
        FROM t$start_table, Ward_spec_tx_adj_view
        WHERE t$start_table.start_date = Ward_spec_tx_date AND t$start_table.start_ward = Ward_code AND t$start_table.start_spec = Specialty_code AND COALESCE(t$start_table.start_loc, 'null') = COALESCE(Treatment_location, 'null') AND Hospital_code = par_hosp_code
        /* add hosp code for HPI by ML on 27.07.1999 */
        GROUP BY t$start_table.start_spec, t$start_table.start_loc;
    /*
    select tx_spec, tx_loc, tx_prev_remain
    from t$tx_table
    */
    /* ******************************************************** */
    /* select tran between @start_date and @input_to_datetime */
    /* ******************************************************** */
    /* add hosp code for HPI by ML on 27.07.1999 */
    DROP TABLE IF EXISTS t$tran_table;
    CREATE TEMPORARY TABLE t$tran_table
    AS
    SELECT
        From_specialty_code AS tran_spec, From_treatment_location AS tran_loc, Transaction_type AS tran_type, COUNT(*) AS tran_sum
        FROM Transaction_log
        WHERE Transaction_datetime > to_char(par_input_to_datetime, 'YYYYMMDD')::timestamp AND Transaction_datetime <= par_input_to_datetime AND (Transaction_type IN ('100', '141', '140', '160', '170') OR Transaction_type LIKE '13_') AND From_specialty_code LIKE par_input_spec AND Cancel_flag IS NULL AND Hospital_code = par_hosp_code
        GROUP BY From_specialty_code, From_treatment_location, Transaction_type;
    /*
    select *
    from t$tran_table
    */
    /* ******************************************************** */
    /* insert spec,loc  (those not exist in Ward_spec_tx, but */
    /* has trasaction within requested date) */
    /* ******************************************************** */
    DROP TABLE IF EXISTS t$extra_spec_table;
    CREATE TEMPORARY TABLE t$extra_spec_table
    AS
    SELECT DISTINCT
        tran_spec, tran_loc
        FROM t$tran_table AS t
        WHERE NOT EXISTS (SELECT
            *
            FROM t$tx_table
            WHERE t.tran_spec = tx_spec AND COALESCE(t$tx_table.tx_loc, 'null') = COALESCE(t.tran_loc, 'null'));
    /*
    select *
    from #extra_spec_table
    */
    INSERT INTO t$tx_table
    SELECT
        tran_spec, tran_loc, 0, 0, 0, 0
        FROM t$extra_spec_table;
    DROP TABLE t$extra_spec_table;
    /* ************************************************* */
    /* cal current occupied no. */
    /* ************************************************* */
    /*
    [3064 - Severity CRITICAL - In PostgreSQL you should not repeat the target table in the FROM clause of an UPDATE statement. Perform a manual conversion.]
    update t$tx_table
    set tx_occupied =tx_prev_remain + isnull(tran_sum,0)
    from t$tx_table, t$tran_table
    where tx_spec*= tran_spec and
          tran_type = '100' and
          isnull(t$tx_table.tx_loc, 'null') *=
          isnull(t$tran_table.tran_loc, 'null')
    */
    /*
    select tx_spec, tx_loc, tx_prev_remain, tx_occupied
    from t$tx_table
    */
    update t$tx_table
    set tx_occupied = tx_prev_remain
    WHERE tx_occupied = 0;
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied + COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE t$tx_table.tx_spec = t$tran_table.tran_spec AND t$tran_table.tran_type = '100' AND COALESCE(t$tx_table.tx_loc, 'null') = COALESCE(t$tran_table.tran_loc, 'null');
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied + COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE t$tx_table.tx_spec = t$tran_table.tran_spec AND t$tran_table.tran_type = '141' AND COALESCE(t$tx_table.tx_loc, 'null') = COALESCE(t$tran_table.tran_loc, 'null');
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied - COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_spec = tran_spec AND tran_type = '140' AND COALESCE(t$tx_table.tx_loc, 'null') = COALESCE(t$tran_table.tran_loc, 'null');
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied - COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_spec = tran_spec AND tran_type = '160' AND COALESCE(t$tx_table.tx_loc, 'null') = COALESCE(t$tran_table.tran_loc, 'null');
    UPDATE t$tx_table
    SET tx_occupied = tx_occupied + COALESCE(tran_sum, 0)
    FROM t$tran_table
        WHERE tx_spec = tran_spec AND tran_type = '170' AND COALESCE(t$tx_table.tx_loc, 'null') = COALESCE(t$tran_table.tran_loc, 'null');
    OPEN disc_csr;
    FETCH disc_csr INTO var_spec, var_loc, var_disc_sum;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        UPDATE t$tx_table
        SET tx_occupied = tx_occupied - var_disc_sum
            WHERE tx_spec = var_spec AND tx_loc = var_loc;
        FETCH disc_csr INTO var_spec, var_loc, var_disc_sum;
    END LOOP;
    CLOSE disc_csr;
    /*
    select tx_spec, tx_loc, tx_prev_remain, tx_occupied
    from t$tx_table
    */
    /* ************************************************* */
    /* insert rows if loc not find in spec */
    /* ************************************************* */
    DROP TABLE IF EXISTS t$loc_table;
    CREATE TEMPORARY TABLE t$loc_table
    AS
    SELECT DISTINCT
        tx_loc
        FROM t$tx_table AS t
        WHERE tx_loc IS NOT NULL AND NOT EXISTS (SELECT
            tx_spec
            FROM t$tx_table
            WHERE t$tx_table.tx_spec = t.tx_loc AND t$tx_table.tx_loc IS NULL);
    INSERT INTO t$tx_table
    SELECT
        tx_loc, NULL, 0, 0, 0, 0
        FROM t$loc_table;
    /*
    select tx_spec,tx_loc,tx_occupied,tx_off_available,tx_day_available
    from t$tx_table
    order by tx_spec, tx_loc
    */
    DROP TABLE t$loc_table;
    /* *********************************************************** */
    /* cal. no. of official bed in each spec */
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
            FROM Ward_specialty) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM Ward_specialty
            WHERE Effective_date <= par_input_to_datetime AND Specialty_code LIKE par_input_spec AND Hospital_code = par_hosp_code
            GROUP BY Ward_code, Specialty_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
        WHERE Effective_date = max_1 AND ungrouped_query.Specialty_code = grouped_query.Specialty_code AND ungrouped_query.Specialty_code LIKE par_input_spec AND Hospital_code = par_hosp_code
        ORDER BY Specialty_code NULLS FIRST;
    OPEN off_csr;
    FETCH off_csr INTO var_spec, var_off_sum;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF NOT EXISTS (SELECT
            *
            FROM t$tx_table
            WHERE tx_spec = var_spec AND tx_loc IS NULL) THEN
            BEGIN
                IF var_off_sum > 0 THEN
                    INSERT INTO t$tx_table
                    VALUES (var_spec, NULL, 0, 0, var_off_sum, 0);
                END IF;
            END;
        ELSE
            UPDATE t$tx_table
            SET tx_off_available = var_off_sum
                WHERE tx_spec = var_spec AND tx_loc IS NULL;
        END IF;
        FETCH off_csr INTO var_spec, var_off_sum;
    END LOOP;
    CLOSE off_csr;
    DROP TABLE t$temp_off_table;
    /*
    select tx_spec, tx_loc, tx_occupied, tx_off_available
    from t$tx_table
    */
    /* ********************************************* */
    /* cal. Day bed by spec */
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
            FROM Ward_specialty) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM Ward_specialty
            WHERE Effective_date <= par_input_to_datetime AND Specialty_code LIKE par_input_spec AND Hospital_code = par_hosp_code
            GROUP BY Ward_code, Specialty_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
        WHERE Effective_date = max_1 AND ungrouped_query.Specialty_code = grouped_query.Specialty_code AND ungrouped_query.Specialty_code LIKE par_input_spec AND Hospital_code = par_hosp_code
        ORDER BY Specialty_code NULLS FIRST;
    OPEN day_csr;
    FETCH day_csr INTO var_spec, var_day_sum;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF NOT EXISTS (SELECT
            *
            FROM t$tx_table
            WHERE tx_spec = var_spec AND tx_loc IS NULL) THEN
            BEGIN
                IF var_day_sum > 0 THEN
                    INSERT INTO t$tx_table
                    VALUES (var_spec, NULL, 0, 0, 0, var_day_sum);
                END IF;
            END;
        ELSE
            UPDATE t$tx_table
            SET tx_day_available = var_day_sum
                WHERE tx_spec = var_spec AND tx_loc IS NULL;
        END IF;
        FETCH day_csr INTO var_spec, var_day_sum;
    END LOOP;
    CLOSE day_csr;
    DROP TABLE t$temp_day_table;
    /*
    select tx_spec, tx_loc, tx_occupied,
             tx_off_available, tx_day_available
    from t$tx_table
    order by tx_spec, tx_loc
    */
    /* ***************************************************** */
    /* sum up loc's figure to its corresponding specialty */
    /* ***************************************************** */
    OPEN sum_csr;
    FETCH sum_csr INTO var_loc, var_sum;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        UPDATE t$tx_table
        SET tx_occupied = tx_occupied + var_sum
            WHERE tx_spec = var_loc AND tx_loc IS NULL;
        FETCH sum_csr INTO var_loc, var_sum;
    END LOOP;
    CLOSE sum_csr;
    /*
    select tx_spec, tx_loc, tx_occupied,
             tx_off_available, tx_day_available
    from t$tx_table
    order by tx_spec, tx_loc
    */
    /* ******************************************* */
    /* create display table   : #dsp_table */
    /* ******************************************* */
    DROP TABLE IF EXISTS t$dsp_table;
    CREATE TEMPORARY TABLE t$dsp_table
    (dsp_spec VARCHAR(05) NULL,
        dsp_desc VARCHAR(30) NULL,
        dsp_occupied REAL NULL,
        dsp_vacant INTEGER NULL,
        dsp_off_availabled REAL NULL,
        dsp_excess INTEGER NULL,
        dsp_occupancy REAL NULL,
        dsp_day_available INTEGER NULL);
    SELECT
        0, 0, 0, 0, 0, 0
        INTO var_dsp_occupied, var_dsp_vacant, var_dsp_off_available, var_dsp_excess, var_dsp_occupancy, var_dsp_day_available;
    SELECT
        0, 0, 0, 0, 0, 0
        INTO var_total_occupied, var_total_vacant, var_total_off_available, var_total_excess, var_total_occupancy, var_total_day_available;
    SELECT
        0
        INTO var_count;
    SELECT
        0
        INTO var_spec_occupied;
    SELECT
        ''
        INTO var_prev_spec;
    --raise NOTICE 'ppp var_dsp_spec=%, var_dsp_desc=%, var_prev_spec=%',var_dsp_spec,var_dsp_desc,var_prev_spec;
    OPEN dsp_csr;
    FETCH dsp_csr INTO var_dsp_spec, var_dsp_desc, var_dsp_occupied, var_dsp_off_available, var_dsp_day_available;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        --raise NOTICE 'kkkk var_dsp_spec=%, var_dsp_desc=%, var_prev_spec=%',var_dsp_spec,var_dsp_desc,var_prev_spec;
        IF (var_dsp_spec <> var_dsp_desc) OR (var_prev_spec <> var_dsp_spec) THEN
            --raise NOTICE 'JJJJ';
            BEGIN
                IF var_dsp_occupied IS NULL THEN
                    SELECT
                        0
                        INTO var_dsp_occupied;
                END IF;

                IF var_dsp_off_available IS NULL THEN
                    SELECT
                        0
                        INTO var_dsp_off_available;
                END IF;

                IF var_dsp_day_available IS NULL THEN
                    SELECT
                        0
                        INTO var_dsp_day_available;
                END IF;
                SELECT
                    0
                    INTO var_occ;
                --raise NOTICE 'var_prev_spec=%, var_dsp_spec=%',var_prev_spec,var_dsp_spec;
                IF var_prev_spec <> var_dsp_spec THEN
                    --raise NOTICE 'GGG';
                    BEGIN
                        IF var_count >= 1 THEN
                            BEGIN
                                INSERT INTO t$dsp_table
                                VALUES (NULL, 'Specialty Total', var_spec_occupied, NULL, NULL, NULL, NULL, NULL);
                                SELECT
                                    0
                                    INTO var_count;
                            END;
                        END IF;
                        SELECT
                            0
                            INTO var_spec_occupied;

                        IF var_dsp_occupied > var_dsp_off_available THEN
                            BEGIN
                                SELECT
                                    0
                                    INTO var_dsp_vacant;
                                SELECT
                                    var_dsp_occupied - var_dsp_off_available
                                    INTO var_dsp_excess;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    var_dsp_off_available - var_dsp_occupied
                                    INTO var_dsp_vacant;
                                SELECT
                                    0
                                    INTO var_dsp_excess;
                            END;
                        END IF;

                        IF var_dsp_off_available <> 0 THEN
                            BEGIN
                                /*
                                select @dsp_occupancy =
                                (@dsp_occupied/@dsp_off_available) *100
                                */
                                SELECT
                                    var_dsp_occupied
                                    INTO var_real_occupied;
                                SELECT
                                    var_dsp_off_available
                                    INTO var_real_available;
                                SELECT
                                    (var_real_occupied / var_real_available)
                                    INTO var_dsp_occupancy;
                                SELECT
                                    var_dsp_occupancy
                                    INTO var_occ;
                            END;
                        ELSE
                            /* select @dsp_occupancy = 0 */
                            SELECT
                                0
                                INTO var_occ;
                        END IF;
                        /*
                        select @dsp_desc = Description from Specialty
                        where Specialty_code = @dsp_spec
                        */
                        /* add hosp code for HPI by ML on 27.07.1999 */
                        SELECT
                            (SELECT
                                Description
                                FROM Specialty
                                WHERE Specialty_code = var_dsp_spec AND Hospital_code = par_hosp_code AND Effective_date = (SELECT
                                    MAX(Effective_date)
                                    FROM Specialty
                                    WHERE Specialty_code = var_dsp_spec AND Effective_date <= par_input_to_datetime) AND Hospital_code = par_hosp_code)
                            INTO var_dsp_desc;
                        --raise NOTICE 'var_dsp_spec=%, var_dsp_desc=%',var_dsp_spec, var_dsp_desc;
                        INSERT INTO t$dsp_table
                        VALUES (var_dsp_spec, var_dsp_desc, var_dsp_occupied, var_dsp_vacant, var_dsp_off_available, var_dsp_excess, var_dsp_occupancy, var_dsp_day_available);
                        SELECT
                            var_total_occupied + var_dsp_occupied, var_total_vacant + var_dsp_vacant, var_total_off_available + var_dsp_off_available, var_total_excess + var_dsp_excess, var_total_day_available + var_dsp_day_available
                            INTO var_total_occupied, var_total_vacant, var_total_off_available, var_total_excess, var_total_day_available;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            var_count + 1
                            INTO var_count;
                        INSERT INTO t$dsp_table
                        VALUES (NULL, var_dsp_desc, var_dsp_occupied, NULL, NULL, NULL, NULL, NULL);
                    END;
                END IF;
                SELECT
                    var_spec_occupied + var_dsp_occupied
                    INTO var_spec_occupied;
                SELECT
                    var_dsp_spec
                    INTO var_prev_spec;
            END;
        END IF;
        FETCH dsp_csr INTO var_dsp_spec, var_dsp_desc, var_dsp_occupied, var_dsp_off_available, var_dsp_day_available;
    END LOOP;
    CLOSE dsp_csr;
    /* ******************************************* */
    /* prepare data for the row of Total */
    /* ******************************************* */
    IF var_count >= 1 THEN
        INSERT INTO t$dsp_table
        VALUES (NULL, 'Specialty Total', var_spec_occupied, NULL, NULL, NULL, NULL, NULL);
    END IF;

    IF var_total_off_available <> 0 THEN
        BEGIN
            SELECT
                var_total_occupied
                INTO var_real_occupied;
            SELECT
                var_total_off_available
                INTO var_real_available;
            SELECT
                (var_real_occupied / var_real_available)
                INTO var_total_occupancy;
            SELECT
                var_total_occupancy
                INTO var_occ;
        END;
    ELSE
        SELECT
            0
            INTO var_occ;
    END IF;
    /* ********************************************* */
    /* insert the row Total to the display table */
    /* ********************************************* */
    INSERT INTO t$dsp_table
    VALUES ('Total', NULL, var_total_occupied, var_total_vacant, var_total_off_available, var_total_excess, var_total_occupancy, var_total_day_available);
    /* select * from #dsp_table  --20180105 */
    OPEN p_refcur FOR
    SELECT
        dsp_spec, dsp_desc, dsp_occupied, dsp_vacant, dsp_off_availabled, dsp_excess, dsp_occupancy, dsp_day_available
        FROM t$dsp_table;
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
    
    DROP TABLE IF EXISTS t$extra_spec_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$loc_table;
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
    
    DROP TABLE IF EXISTS t$dsp_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
 $function$
;


;ALTER FUNCTION "hasp_bed_state_by_spec" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
