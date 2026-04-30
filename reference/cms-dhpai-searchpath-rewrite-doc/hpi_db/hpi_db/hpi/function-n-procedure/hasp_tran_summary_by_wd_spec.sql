-- DROP FUNCTION hasp_tran_summary_by_wd_spec(varchar, timestamp, timestamp, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_tran_summary_by_wd_spec(par_hosp_code character varying, par_input_from_date timestamp without time zone, par_input_to_date timestamp without time zone, par_input_pay_code character varying, par_input_ward character varying, par_input_spec character varying)
 RETURNS TABLE(result_ward character varying, result_spec character varying, result_ae_adm integer, result_clinical_adm integer, result_tran_in integer, result_tran_out integer, result_disc integer, result_death integer, result_tdisc integer, result_return_tdisc integer, result_day_disc integer, result_day_death integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_ward  VARCHAR(4);
    var_spec  VARCHAR(4);
    var_type  VARCHAR(3);
    var_total INTEGER;
BEGIN
    -- Adjust the end date
    par_input_to_date := par_input_to_date + INTERVAL '1 day';

    -- Create temporary tables
    DROP TABLE IF EXISTS t$result_table;
    CREATE TEMP TABLE t$result_table
    (
        result_ward         VARCHAR(4),
        result_spec         VARCHAR(10),
        result_ae_adm       INTEGER DEFAULT 0,
        result_clinical_adm INTEGER DEFAULT 0,
        result_tran_in      INTEGER DEFAULT 0,
        result_tran_out     INTEGER DEFAULT 0,
        result_disc         INTEGER DEFAULT 0,
        result_death        INTEGER DEFAULT 0,
        result_tdisc        INTEGER DEFAULT 0,
        result_return_tdisc INTEGER DEFAULT 0,
        result_day_disc     INTEGER DEFAULT 0,
        result_day_death    INTEGER DEFAULT 0
    );

    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMP TABLE t$tx_table AS

    SELECT tl.from_ward_code      AS tx_ward,
           tl.from_specialty_code AS tx_spec,
           tl.transaction_type    AS tx_type,
           COUNT(*)               AS tx_total
    FROM transaction_log tl
             JOIN case_view cv ON tl.case_no = cv.case_no
    WHERE tl.transaction_datetime >= par_input_from_date
      AND tl.transaction_datetime < par_input_to_date
      AND tl.cancel_flag IS NULL
      AND (tl.transaction_type IN ('100', '141', '140', '160', '170') OR tl.transaction_type LIKE '13_')
      AND cv.pay_code LIKE par_input_pay_code
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND cv.hospital_code = par_hosp_code
      AND tl.hospital_code = par_hosp_code
    GROUP BY tl.from_ward_code, tl.from_specialty_code, tl.transaction_type;

    -- Insert into t$result_table
    INSERT INTO t$result_table (result_ward, result_spec)
    SELECT DISTINCT tx_ward, tx_spec
    FROM t$tx_table;

    -- Cursor for processing t$tx_table
    FOR var_ward, var_spec, var_type, var_total IN
        SELECT tx_ward, tx_spec, tx_type, tx_total
        FROM t$tx_table
        LOOP
            IF var_type = '141' THEN

                UPDATE t$result_table t
                SET result_tran_in = var_total
                WHERE t.result_ward = var_ward
                  AND t.result_spec = var_spec;

            ELSIF
                var_type = '140' THEN

                UPDATE t$result_table t
                SET result_tran_out = var_total
                WHERE t.result_ward = var_ward
                  AND t.result_spec = var_spec;

            ELSIF
                var_type = '160' THEN

                UPDATE t$result_table t
                SET result_tdisc = var_total
                WHERE t.result_ward = var_ward
                  AND t.result_spec = var_spec;

            ELSIF
                var_type = '170' THEN

                UPDATE t$result_table t
                SET result_return_tdisc = var_total
                WHERE t.result_ward = var_ward
                  AND t.result_spec = var_spec;

            END IF;
        END LOOP;

    -- Calculate a&e and clinical admissions
    DROP TABLE IF EXISTS t$adm_table;
    CREATE TEMP TABLE t$adm_table AS

    SELECT tl.from_ward_code      AS adm_ward,
           tl.from_specialty_code AS adm_spec,
           COUNT(*)               AS adm_total
    FROM transaction_log tl
             JOIN case_view cv ON tl.case_no = cv.case_no
    WHERE tl.transaction_datetime >= par_input_from_date
      AND tl.transaction_datetime < par_input_to_date
      AND tl.cancel_flag IS NULL
      AND tl.transaction_type = '100'
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND cv.pay_code LIKE par_input_pay_code
      AND cv.source_indicator = '3'
      AND cv.hospital_code = par_hosp_code
      AND tl.hospital_code = par_hosp_code
    GROUP BY tl.from_ward_code, tl.from_specialty_code;

    UPDATE t$result_table t
    SET result_ae_adm = t2.adm_total
    FROM t$adm_table t2
    WHERE t.result_ward = t2.adm_ward
      AND t.result_spec = t2.adm_spec;

    UPDATE t$result_table t
    SET result_clinical_adm = t2.tx_total - t.result_ae_adm
    FROM t$tx_table t2
    WHERE t.result_ward = t2.tx_ward
      AND t.result_spec = t2.tx_spec
      AND t2.tx_type = '100';

    -- Calculate discharges and deaths
    DROP TABLE IF EXISTS t$disc_table;
    CREATE TEMP TABLE t$disc_table AS

    SELECT tl.from_ward_code      AS disc_ward,
           tl.from_specialty_code AS disc_spec,
           COUNT(*)               AS disc_total
    FROM transaction_log tl
             JOIN case_view cv ON tl.case_no = cv.case_no
    WHERE tl.transaction_datetime >= par_input_from_date
      AND tl.transaction_datetime < par_input_to_date
      AND tl.cancel_flag IS NULL
      AND tl.transaction_type = '131'
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND cv.pay_code LIKE par_input_pay_code
      AND cv.hospital_code = par_hosp_code
      AND tl.hospital_code = par_hosp_code
    GROUP BY tl.from_ward_code, tl.from_specialty_code;

    UPDATE t$result_table t
    SET result_death = t2.disc_total
    FROM t$disc_table t2
    WHERE t.result_ward = t2.disc_ward
      AND t.result_spec = t2.disc_spec;

    FOR var_ward, var_spec, var_total IN
        SELECT tx_ward, tx_spec, SUM(tx_total) AS tx_disc_total
        FROM t$tx_table
        WHERE tx_type LIKE '13_'
        GROUP BY tx_ward, tx_spec
        LOOP

            UPDATE t$result_table t
            SET result_disc = var_total - t.result_death
            WHERE t.result_ward = var_ward
              AND t.result_spec = var_spec;

        END LOOP;

    -- Calculate day patient discharges and deaths
    DROP TABLE IF EXISTS t$day_table;
    CREATE TEMP TABLE t$day_table AS

    SELECT tl.from_ward_code      AS day_ward,
           tl.from_specialty_code AS day_spec,
           COUNT(*)               AS day_total
    FROM transaction_log tl
             JOIN case_view cv ON tl.case_no = cv.case_no
    WHERE tl.transaction_datetime >= par_input_from_date
      AND tl.transaction_datetime < par_input_to_date
      AND tl.cancel_flag IS NULL
      AND tl.transaction_type = '131'
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND cv.pay_code LIKE par_input_pay_code
      AND cv.source_indicator <> '3'
--      AND DATE_PART('day', cv.discharge_datetime - cv.admission_datetime) = 0
      AND (to_char(cv.discharge_datetime, 'YYYY-MM-DD')::date - to_char(cv.admission_datetime, 'YYYY-MM-DD')::date) = 0
      AND cv.hospital_code = par_hosp_code
      AND tl.hospital_code = par_hosp_code
    GROUP BY tl.from_ward_code, tl.from_specialty_code;

    UPDATE t$result_table t
    SET result_day_death = t2.day_total
    FROM t$day_table t2
    WHERE t.result_ward = t2.day_ward
      AND t.result_spec = t2.day_spec;

    FOR var_ward, var_spec, var_total IN
        SELECT tl.from_ward_code, tl.from_specialty_code, COUNT(*)
        FROM transaction_log tl
                 JOIN case_view cv ON tl.case_no = cv.case_no
        WHERE tl.transaction_datetime >= par_input_from_date
          AND tl.transaction_datetime < par_input_to_date
          AND tl.cancel_flag IS NULL
          AND tl.transaction_type LIKE '13_'
          AND tl.from_ward_code LIKE par_input_ward
          AND tl.from_specialty_code LIKE par_input_spec
          AND cv.pay_code LIKE par_input_pay_code
          AND cv.source_indicator <> '3'
--          AND DATE_PART('day', cv.discharge_datetime - cv.admission_datetime) = 0
          AND (to_char(cv.discharge_datetime, 'YYYY-MM-DD')::date - to_char(cv.admission_datetime, 'YYYY-MM-DD')::date) = 0
          AND cv.hospital_code = par_hosp_code
          AND tl.hospital_code = par_hosp_code
        GROUP BY tl.from_ward_code, tl.from_specialty_code
        LOOP
            UPDATE t$result_table t
            SET result_day_disc = var_total - t.result_day_death
            WHERE t.result_ward = var_ward
              AND t.result_spec = var_spec;
        END LOOP;

    -- Return results
    RETURN QUERY
        SELECT t.result_ward,
               t.result_spec,
               t.result_ae_adm,
               t.result_clinical_adm,
               t.result_tran_in,
               t.result_tran_out,
               t.result_disc,
               t.result_death,
               t.result_tdisc,
               t.result_return_tdisc,
               t.result_day_disc,
               t.result_day_death
        FROM t$result_table t
        ORDER BY t.result_ward NULLS FIRST, t.result_spec NULLS FIRST;

    -- Clean up
    DROP TABLE IF EXISTS t$result_table;

    DROP TABLE IF EXISTS t$tx_table;

    DROP TABLE IF EXISTS t$adm_table;

    DROP TABLE IF EXISTS t$disc_table;

    DROP TABLE IF EXISTS t$day_table;

END;
$function$
;

ALTER FUNCTION "hasp_tran_summary_by_wd_spec" OWNER TO "HPI_SCHEMA_OWNER_ROLE";