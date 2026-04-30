-- DROP FUNCTION hasp_get_adm_source(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hasp_get_adm_source(par_hosp_code character varying, par_input_from_dt timestamp without time zone, par_input_to_dt timestamp without time zone)
 RETURNS TABLE(hosp_name character varying, others integer, ae integer, opd integer, transfer_in integer, new_born integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_source_code      VARCHAR(3);
    var_source_indicator VARCHAR(1);
BEGIN
    -- Adjust end date
    par_input_to_dt := par_input_to_dt + INTERVAL '1 day';

    -- Create temporary table
    DROP TABLE IF EXISTS t$disp_table;
    CREATE TEMP TABLE t$disp_table
    (
        hosp_code   VARCHAR(3),
        hosp_name   VARCHAR(30),
        others      INTEGER DEFAULT 0,
        ae          INTEGER DEFAULT 0,
        opd         INTEGER DEFAULT 0,
        transfer_in INTEGER DEFAULT 0,
        new_born    INTEGER DEFAULT 0
    );

    -- Cursor to fetch source data
    FOR var_source_code, var_source_indicator IN
        SELECT cv.source_code, cv.source_indicator
        FROM transaction_log tl
                 JOIN case_view cv ON cv.case_no = tl.case_no
        WHERE tl.cancel_flag IS NULL
          AND tl.transaction_type = '100'
          AND tl.transaction_datetime >= par_input_from_dt
          AND tl.transaction_datetime < par_input_to_dt
          AND tl.hospital_code = par_hosp_code
          AND cv.hospital_code = par_hosp_code
        LOOP
            -- Insert if not exists
            IF NOT EXISTS (SELECT 1 FROM t$disp_table WHERE hosp_code = var_source_code) THEN
                INSERT INTO t$disp_table (hosp_code) VALUES (var_source_code);
            END IF;

            -- Update counts based on source_indicator
            IF var_source_indicator = '0' THEN
                UPDATE t$disp_table t SET others = t.others + 1 WHERE hosp_code = var_source_code;
            ELSIF var_source_indicator = '3' THEN
                UPDATE t$disp_table t SET ae = t.ae + 1 WHERE hosp_code = var_source_code;
            ELSIF var_source_indicator = '4' THEN
                UPDATE t$disp_table t SET opd = t.opd + 1 WHERE hosp_code = var_source_code;
            ELSIF var_source_indicator = '5' THEN
                UPDATE t$disp_table t SET transfer_in = t.transfer_in + 1 WHERE hosp_code = var_source_code;
            ELSIF var_source_indicator = '8' THEN
                UPDATE t$disp_table t SET new_born = t.new_born + 1 WHERE hosp_code = var_source_code;
            END IF;
        END LOOP;

    -- Update hospital names
    UPDATE t$disp_table
    SET hosp_name = d.description
    FROM destination d
    WHERE t$disp_table.hosp_code = d.destination_code;

    -- Return results
    RETURN QUERY
        SELECT t.hosp_name, t.others, t.ae, t.opd, t.transfer_in, t.new_born
        FROM t$disp_table t
        ORDER BY t.hosp_name NULLS FIRST;

    -- Clean up
    DROP TABLE IF EXISTS t$disp_table;

END;
$function$
;

;ALTER FUNCTION "hasp_get_adm_source" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
