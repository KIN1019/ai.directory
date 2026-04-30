-- DROP FUNCTION hasp_pat_remain_by_spec(varchar, timestamp, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_pat_remain_by_spec(par_hosp_code character varying, par_input_as_at_dt timestamp without time zone, par_input_pay_code character varying, par_input_spec character varying)
 RETURNS TABLE(dsp_spec character varying, dsp_desc character varying, dsp_pat_remain integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    result_str_value_1 VARCHAR(128);
    result_str_value_2 VARCHAR(128);
    var_case_no        VARCHAR(12);
    var_r_spec         VARCHAR(4);
    var_r_treat_loc    VARCHAR(4);
    var_spec           VARCHAR(5);
    var_desc           VARCHAR(30);
    var_pat_remain     INTEGER;
    var_loc            VARCHAR(4);
    var_sum            INTEGER;
    var_prev_spec      VARCHAR(5);
    var_count          INTEGER;
    var_spec_total     INTEGER;
    var_total          INTEGER;
BEGIN
    -- Adjust date
    par_input_as_at_dt := par_input_as_at_dt + INTERVAL '1 day';

    -- Create temporary table for results
    DROP TABLE IF EXISTS t$result_table;
    CREATE TEMP TABLE t$result_table (
                                         result_case_no       VARCHAR(12) NOT NULL UNIQUE,
                                         result_spec          VARCHAR(4),
                                         result_treatment_loc VARCHAR(4));

    -- Insert cases not yet discharged
    INSERT INTO t$result_table (result_case_no)
    SELECT
        case_no
    FROM
        case_view
    WHERE
          ((discharge_code IS NOT NULL AND discharge_datetime >= par_input_as_at_dt) OR discharge_code IS NULL)
      AND admission_datetime < par_input_as_at_dt
      AND case_no LIKE ' HN%'
      AND pay_code LIKE par_input_pay_code
      AND hospital_code = par_hosp_code;

    -- Cursor for updating specialties and locations
    FOR var_case_no IN
        SELECT result_case_no FROM t$result_table ORDER BY result_case_no 
    LOOP
        SELECT
            specialty_code,
            treatment_location
        -- INTO var_r_spec, var_r_treat_loc
        INTO result_str_value_1,result_str_value_2
        FROM
            movement
        WHERE
              case_no = var_case_no
          AND hospital_code = par_hosp_code
          AND movement_count = (SELECT
                                    MAX(movement_count)
                                FROM
                                    movement
                                WHERE
                                      movement_datetime < par_input_as_at_dt
                                  AND case_no = var_case_no
                                  AND hospital_code = par_hosp_code);
        IF FOUND
        THEN
            var_r_spec := result_str_value_1;
            var_r_treat_loc := result_str_value_2;
        END IF;

        UPDATE t$result_table
        SET result_spec          = var_r_spec,
            result_treatment_loc = var_r_treat_loc
        WHERE result_case_no = var_case_no;
    END LOOP;

    -- Create temporary table for counts
    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMP TABLE t$tx_table AS
    SELECT
        result_spec          AS tx_spec,
        result_treatment_loc AS tx_loc,
        COUNT(*)             AS tx_pat_remain
    FROM
        t$result_table
    WHERE result_spec LIKE par_input_spec
    GROUP BY result_spec, result_treatment_loc;

    -- Sum up location figures to corresponding spec
    FOR var_loc, var_sum IN
        SELECT
            tx_loc,
            tx_pat_remain
        FROM
            t$tx_table
        WHERE
              tx_loc IS NOT NULL
          AND tx_loc <> tx_spec
    LOOP
        IF EXISTS (SELECT 1 FROM t$tx_table WHERE tx_spec = var_loc AND tx_loc IS NULL)
        THEN
            UPDATE t$tx_table
            SET tx_pat_remain = tx_pat_remain + var_sum
            WHERE
                  tx_spec = var_loc
              AND tx_loc IS NULL;
        ELSE
            IF EXISTS (SELECT 1 FROM t$tx_table WHERE tx_spec = var_loc AND tx_loc = var_loc)
            THEN
                UPDATE t$tx_table
                SET tx_pat_remain = tx_pat_remain + var_sum
                WHERE
                      tx_spec = var_loc
                  AND tx_loc = var_loc;
            ELSE
                INSERT INTO t$tx_table (tx_spec, tx_loc, tx_pat_remain)
                VALUES (var_loc, NULL, var_sum);
            END IF;
        END IF;
    END LOOP;

    -- Create display table
    DROP TABLE IF EXISTS t$dsp_table;
    CREATE TEMP TABLE t$dsp_table (
                                      dsp_spec VARCHAR(5), dsp_desc VARCHAR(30), dsp_pat_remain INTEGER);

    -- Insert rows into display table
    FOR var_spec, var_desc, var_pat_remain IN
        SELECT
            tx_spec,
            tx_loc,
            tx_pat_remain
        FROM
            t$tx_table
        ORDER BY tx_spec NULLS FIRST, tx_loc NULLS FIRST
    LOOP
--         IF var_spec = '1AS1' or var_spec = 'OPH'
--         THEN
--             RAISE NOTICE 'var_desc => [%]',var_desc;
--             RAISE NOTICE 'var_pat_remain => [%]',var_pat_remain;
--         END IF;
        IF COALESCE(var_prev_spec, 'null') <> COALESCE(var_spec, 'null')
        THEN
            IF var_count >= 1
            THEN
                INSERT INTO t$dsp_table (dsp_spec, dsp_desc, dsp_pat_remain)
                VALUES (NULL, 'Specialty Total', var_spec_total);
                var_count := 0;
            END IF;
            var_spec_total := 0;

            SELECT
                description
            INTO result_str_value_1
            -- INTO var_desc
            FROM
                specialty
            WHERE
                  specialty_code = var_spec
              AND hospital_code = par_hosp_code
              AND effective_date = (SELECT
                                        MAX(effective_date)
                                    FROM
                                        specialty
                                    WHERE
                                          specialty_code = var_spec
                                      AND effective_date <= par_input_as_at_dt
                                      AND hospital_code = par_hosp_code);
            IF FOUND
            THEN
                var_desc := result_str_value_1;
--                 IF var_spec = '1AS1' or var_spec = 'OPH'
--                 THEN
--                     RAISE NOTICE '154-var_desc => [%]',var_desc;
--                 END IF;
            END IF;

            INSERT INTO t$dsp_table (dsp_spec, dsp_desc, dsp_pat_remain)
            VALUES (var_spec, var_desc, var_pat_remain);
            var_total := COALESCE(var_total, 0) + var_pat_remain;
            var_spec_total := var_spec_total + var_pat_remain;
            var_prev_spec := var_spec;
        ELSE
            INSERT INTO t$dsp_table (dsp_spec, dsp_desc, dsp_pat_remain)
            VALUES (NULL, var_desc, var_pat_remain);
            var_spec_total := var_spec_total + var_pat_remain;
            var_count := COALESCE(var_count, 0) + 1;
        END IF;
    END LOOP;

    -- Insert total rows
    IF var_count >= 1
    THEN
        INSERT INTO t$dsp_table (dsp_spec, dsp_desc, dsp_pat_remain)
        VALUES (NULL, 'Specialty Total', var_spec_total);
    END IF;

    INSERT INTO t$dsp_table (dsp_spec, dsp_desc, dsp_pat_remain)
    VALUES (NULL, NULL, NULL);

    INSERT INTO t$dsp_table (dsp_spec, dsp_desc, dsp_pat_remain)
    VALUES ('Total', NULL, var_total);

    -- Return results
    RETURN QUERY
        SELECT
            t.dsp_spec,
            t.dsp_desc,
            t.dsp_pat_remain
        FROM
            t$dsp_table t;

    -- Clean up
    DROP TABLE IF EXISTS t$result_table;
    DROP TABLE IF EXISTS t$tx_table;
    DROP TABLE IF EXISTS t$dsp_table;

END;
$function$
;

;ALTER FUNCTION "hasp_pat_remain_by_spec" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
