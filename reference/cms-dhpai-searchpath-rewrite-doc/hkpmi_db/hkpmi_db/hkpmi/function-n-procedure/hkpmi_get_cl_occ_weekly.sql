-- DROP FUNCTION hkpmi.hkpmi_get_cl_occ_weekly(bpchar, timestamp);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_cl_occ_weekly(par_cluster VARCHAR, par_input_dtm timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_date TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    CREATE TEMPORARY TABLE t$temp_occ_table
    ("cluster" VARCHAR(5),
        "report_date" TIMESTAMP WITHOUT TIME ZONE,
        "total_bed" INTEGER DEFAULT 0 NULL,
        "occ_bed" INTEGER DEFAULT 0 NULL,
        "occ_rate" NUMERIC(10, 2) NULL);
    CREATE UNIQUE INDEX temp_occ_index ON t$temp_occ_table
        ("cluster", "report_date");

    IF par_input_dtm IS NULL THEN
        SELECT
            MAX(summary_dtm)
            INTO par_input_dtm
            FROM bed_occupancy_summary2;
    END IF;

    IF par_cluster = 'ALL' OR par_cluster IS NULL THEN
        SELECT
            '%'
            INTO par_cluster;
    END IF;
    SELECT
        - 6 * INTERVAL '1 day' + par_input_dtm::TIMESTAMP
        INTO var_date;

    WHILE var_date <= par_input_dtm LOOP
        INSERT INTO t$temp_occ_table (report_date, cluster, total_bed, occ_bed)
        SELECT
            ungrouped_query.summary_dtm, ungrouped_query.cluster, sum_1, SUM(official_bed_occupied) + SUM(added_bed_occupied) + SUM(other_bed_occupied)
            FROM (SELECT
                summary_dtm, cluster, SUM(official_bed_occupied) + SUM(added_bed_occupied) + SUM(other_bed_occupied)) AS ungrouped_query
            INNER JOIN (SELECT
                summary_dtm, cluster, SUM(official_bed) AS sum_1
                FROM bed_occupancy_summary2
                WHERE summary_dtm = var_date AND cluster LIKE par_cluster AND hospital_code IN ('TMH', 'CMC', 'YCH', 'PMH', 'KWH', 'QEH', 'UCH', 'TKO', 'PWH', 'NDH', 'AHN', 'PYN', 'QMH', 'RH')
                GROUP BY summary_dtm, cluster) AS grouped_query
                ON (ungrouped_query.summary_dtm = grouped_query.summary_dtm OR (ungrouped_query.summary_dtm IS NULL AND grouped_query.summary_dtm IS NULL));
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            INSERT INTO t$temp_occ_table (cluster, report_date, total_bed, occ_bed)
            SELECT DISTINCT
                cluster, var_date, NULL, NULL
                FROM bed_occupancy_summary2;
        END IF;
        SELECT
            1 * INTERVAL '1 day' + var_date::TIMESTAMP
            INTO var_date;
    END LOOP;
    UPDATE t$temp_occ_table
    SET "occ_rate" = 100 * CAST ("occ_bed" AS DOUBLE PRECISION) / CAST ("total_bed" AS DOUBLE PRECISION)
        WHERE total_bed <> 0;
    OPEN p_refcur FOR
    SELECT
        cluster, report_date, occ_rate
        FROM t$temp_occ_table;
	return next p_refcur;
    DROP TABLE t$temp_occ_table;
    /*
    
    DROP TABLE IF EXISTS t$temp_occ_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$function$
;


ALTER FUNCTION "hkpmi_get_cl_occ_weekly" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
