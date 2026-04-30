CREATE OR REPLACE FUNCTION hasp_get_unposted(IN par_hosp_code VARCHAR, IN par_input_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_input_to_date TIMESTAMP WITHOUT TIME ZONE, IN par_input_type VARCHAR) 
 RETURNS SETOF refcursor
  LANGUAGE plpgsql
AS $function$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    p_refcur refcursor;
BEGIN
    /*
    Find unposted backdated transactions
    
            @hosp_code              Hospital_code
            @input_from_date        Start date to be processed
            @input_to_date          End date to be processed
    		  @input_type					Input selection type
    
            27.07.1999 - Add hosp code for HPI by Mabel LAU
    */
    SELECT
        1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
        INTO par_input_to_date;
    /* 20140403/M/Terry Yeung, add missing records in Func_table, start */
    DROP TABLE IF EXISTS t$temp_func_table;
    CREATE TEMPORARY TABLE t$temp_func_table
    (Func_ID INTEGER NULL,
        Func_description VARCHAR(80) NULL);
    INSERT INTO t$temp_func_table
    SELECT
        Func_ID, Func_description
        FROM Func_table;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 13) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (13, 'Mass Dischargess');
        END;
    END IF;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 14) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (14, 'Mass Transfer');
        END;
    END IF;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 16) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (16, 'Trial Discharges');
        END;
    END IF;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 17) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (17, 'Return From Trial Discharges');
        END;
    END IF;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 21) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (21, 'Cancellation of Dischargess');
        END;
    END IF;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 22) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (22, 'Cancellation of Transfer');
        END;
    END IF;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 23) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (23, 'Cancellation of Trial Discharges');
        END;
    END IF;

    IF NOT EXISTS (SELECT
        *
        FROM t$temp_func_table
        WHERE func_id = 24) THEN
        BEGIN
            INSERT INTO t$temp_func_table
            VALUES (24, 'Cancellation of Return Trial Discharges');
        END;
    END IF;
    /* 20140403/M/Terry Yeung, add missing records in Func_table, end */
    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMPORARY TABLE t$tx_table
    (tx_ward VARCHAR(8) NULL,
        tx_spec VARCHAR(8) NULL,
        tx_case VARCHAR(24) NULL,
        tx_date TIMESTAMP WITHOUT TIME ZONE NULL,
        tx_type VARCHAR(6) NULL,
        tx_desc VARCHAR(80) NULL,
        tx_sys_date TIMESTAMP WITHOUT TIME ZONE NULL,
        remark VARCHAR(2) NULL);

    IF par_input_type = 'T' THEN
        INSERT INTO t$tx_table
        SELECT
            From_ward_code, From_specialty_code, Case_no, Transaction_datetime, Transaction_type, REPEAT(' ', 40), System_datetime, NULL
            /* into #tx_table */
            FROM Transaction_log
            WHERE Transaction_datetime >= par_input_from_date AND Transaction_datetime < par_input_to_date AND From_ward_code <> 'AE01' AND ((Transaction_type LIKE '1%' AND Transaction_type NOT IN ('120', '121') AND Post_datetime IS NULL) OR ((Transaction_type LIKE '2%' OR Transaction_type IN ('120', '121')) AND Post_flag = 'Y' AND Post_datetime IS NULL)) AND Hospital_code = par_hosp_code::VARCHAR;
    /* add hosp code for hpi by ML on 27.07.1999 */
    ELSE
        INSERT INTO t$tx_table
        SELECT
            From_ward_code, From_specialty_code, Case_no, Transaction_datetime, Transaction_type, REPEAT(' ', 40), System_datetime, NULL
            FROM Transaction_log
            WHERE System_datetime >= par_input_from_date AND System_datetime < par_input_to_date AND From_ward_code <> 'AE01' AND ((Transaction_type LIKE '1%' AND Transaction_type NOT IN ('120', '121') AND Post_datetime IS NULL) OR ((Transaction_type LIKE '2%' OR Transaction_type IN ('120', '121')) AND Post_flag = 'Y' AND Post_datetime IS NULL)) AND Hospital_code = par_hosp_code::VARCHAR;
    END IF;
    /* add hosp code for hpi by ML on 27.07.1999 */
    UPDATE t$tx_table AS a
    SET
    /* 20140403/M/Terry Yeung, add missing records in Func_table, start */
    /* --tx_desc = (select Func_description from Func_table */
    tx_desc = (SELECT
        func_description
        FROM t$temp_func_table
        /* 20140403/M/Terry Yeung, add missing records in Func_table, end */
        WHERE func_id = CAST (SUBSTRING(a.tx_type, 1, 2) AS INTEGER));
    UPDATE t$tx_table
    SET remark = '*'
        WHERE 12 * (DATE_PART('year', tx_sys_date::TIMESTAMP) - DATE_PART('year', tx_date::TIMESTAMP)) + DATE_PART('month', tx_sys_date::TIMESTAMP) - DATE_PART('month', tx_date::TIMESTAMP) >= 3;

    IF par_input_type = 'T' THEN
        /* Adaptive Server has expanded all '*' elements in the following statement */
        OPEN p_refcur FOR
        SELECT
            t$tx_table.tx_ward, t$tx_table.tx_spec, t$tx_table.tx_case, t$tx_table.tx_date, t$tx_table.tx_type, t$tx_table.tx_desc, t$tx_table.tx_sys_date, t$tx_table.remark
            FROM t$tx_table
            ORDER BY tx_ward NULLS FIRST, tx_spec NULLS FIRST, tx_type NULLS FIRST, tx_date NULLS FIRST, tx_sys_date NULLS FIRST;
    ELSE
        /* Adaptive Server has expanded all '*' elements in the following statement */
        OPEN p_refcur FOR
        SELECT
            t$tx_table.tx_ward, t$tx_table.tx_spec, t$tx_table.tx_case, t$tx_table.tx_date, t$tx_table.tx_type, t$tx_table.tx_desc, t$tx_table.tx_sys_date, t$tx_table.remark
            FROM t$tx_table
            ORDER BY tx_ward NULLS FIRST, tx_spec NULLS FIRST, tx_type NULLS FIRST, tx_sys_date NULLS FIRST, tx_date NULLS FIRST;
    END IF;
    /* 20140403/M/Terry Yeung, add missing records in Func_table, start */
    --DROP TABLE t$temp_func_table;
    /* 20140403/M/Terry Yeung, add missing records in Func_table, end */
    --DROP TABLE t$tx_table;
    return next p_refcur;
    /*
    
    DROP TABLE IF EXISTS t$temp_func_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
    /*
    
    DROP TABLE IF EXISTS t$tx_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;

;ALTER FUNCTION "hasp_get_unposted" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
