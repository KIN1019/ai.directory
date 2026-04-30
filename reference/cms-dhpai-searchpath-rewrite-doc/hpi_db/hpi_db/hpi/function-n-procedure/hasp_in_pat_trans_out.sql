-- DROP FUNCTION hasp_in_pat_trans_out(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hasp_in_pat_trans_out(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS TABLE(description character varying, child_count integer, adult_count integer, unknown_count integer, prev_count integer, no_of_days integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_return_code INTEGER;
    var_adm_dt          TIMESTAMP;
    var_dest            VARCHAR(3);
    var_dob             TIMESTAMP;
    var_prev_from_date  TIMESTAMP;
    var_prev_to_date    TIMESTAMP;
    var_age             INT;
    var_no_of_days      INT;
    var_tx_dt           TIMESTAMP;
    var_case_no     VARCHAR(12);
    var_age_char        VARCHAR(5);
BEGIN
    -- Adjust dates
    par_to_date := par_to_date + INTERVAL '1 day';
    var_prev_from_date := par_from_date - INTERVAL '1 year';
    var_prev_to_date := par_to_date - INTERVAL '1 year';
    var_no_of_days := EXTRACT(DAY FROM (par_to_date - par_from_date));

    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMP TABLE t$tx_table
    (
        dest        VARCHAR(6),
        description VARCHAR(60),
        prev        INT DEFAULT 0,
        adult       INT DEFAULT 0,
        child       INT DEFAULT 0,
        unknown     INT DEFAULT 0
    );

    -- Cursor for previous year transactions
    FOR var_case_no IN
        SELECT case_no
        FROM transaction_log
        WHERE cancel_flag IS NULL
          AND transaction_type IN ('130', '134')
          AND transaction_datetime >= var_prev_from_date
          AND transaction_datetime < var_prev_to_date
          AND hospital_code = par_hosp_code
        LOOP
            SELECT c.admission_datetime, c.destination_code, p.dob, c.discharge_datetime
            INTO var_adm_dt, var_dest, var_dob, var_tx_dt
            FROM case_view c
                     JOIN pmi_wo_mrn p ON c.hkid = p.hkid
            WHERE c.case_no = var_case_no
              AND c.hospital_code = par_hosp_code;

            IF var_tx_dt < var_prev_to_date THEN
                INSERT INTO t$tx_table (dest, prev) VALUES (var_dest, 1);
            ELSE
                IF var_dob IS NULL THEN
                    INSERT INTO t$tx_table (dest, unknown) VALUES (var_dest, 1);
                ELSE
                    CALL hasp_cal_age(var_return_code, var_dob, var_tx_dt, var_age_char);
                    IF RIGHT(var_age_char, 1) IN ('m', 'd') THEN
                        var_age := 0;
                    ELSE
                        var_age := CAST(SAFE_SUBSTRING(var_age_char, 1, 3) AS INT);
                    END IF;

                    IF var_age < 16 THEN
                        INSERT INTO t$tx_table (dest, child) VALUES (var_dest, 1);
                    ELSE
                        INSERT INTO t$tx_table (dest, adult) VALUES (var_dest, 1);
                    END IF;
                END IF;
            END IF;
        END LOOP;

    -- Cursor for current year transactions
    FOR var_case_no IN
        SELECT case_no
        FROM transaction_log
        WHERE cancel_flag IS NULL
          AND transaction_type IN ('130', '134')
          AND transaction_datetime >= par_from_date
          AND transaction_datetime < par_to_date
          AND hospital_code = par_hosp_code
        LOOP
            SELECT c.admission_datetime, c.destination_code, p.dob, c.discharge_datetime
            INTO var_adm_dt, var_dest, var_dob, var_tx_dt
            FROM case_view c
                     JOIN pmi_wo_mrn p ON c.hkid = p.hkid
            WHERE c.case_no = var_case_no
              AND c.hospital_code = par_hosp_code;

            IF var_tx_dt < var_prev_to_date THEN
                INSERT INTO t$tx_table (dest, prev) VALUES (var_dest, 1);
            ELSE
                IF var_dob IS NULL THEN
                    INSERT INTO t$tx_table (dest, unknown) VALUES (var_dest, 1);
                ELSE
                    CALL hasp_cal_age(var_return_code, var_dob, var_tx_dt, var_age_char);
                    IF RIGHT(var_age_char, 1) IN ('m', 'd') THEN
                        var_age := 0;
                    ELSE
                        var_age := CAST(SAFE_SUBSTRING(var_age_char, 1, 3) AS INT);
                    END IF;

                    IF var_age < 16 THEN
                        INSERT INTO t$tx_table (dest, child) VALUES (var_dest, 1);
                    ELSE
                        INSERT INTO t$tx_table (dest, adult) VALUES (var_dest, 1);
                    END IF;
                END IF;
            END IF;
        END LOOP;

    -- Update descriptions
    UPDATE t$tx_table AS t
    SET description = d.description
    FROM destination d
    WHERE t.dest = d.destination_code;

    UPDATE t$tx_table t
    SET description = t.dest
    WHERE t.description IS NULL;

    -- Return results
    RETURN QUERY
        SELECT t.description,
               SUM(t.child) ::INTEGER   AS child_count,
               SUM(t.adult) ::INTEGER   AS adult_count,
               SUM(t.UNKNOWN) ::INTEGER AS unknown_count,
               SUM(t.prev) ::INTEGER    AS prev_count,
               var_no_of_days::INTEGER
        FROM t$tx_table t
        GROUP BY t.description
        ORDER BY t.description;

    DROP TABLE t$tx_table;
END;
$function$
;

;ALTER FUNCTION "hasp_in_pat_trans_out" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
