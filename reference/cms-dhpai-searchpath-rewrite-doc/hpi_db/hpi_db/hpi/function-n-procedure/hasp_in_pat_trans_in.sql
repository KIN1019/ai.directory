-- DROP FUNCTION hasp_in_pat_trans_in(varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hasp_in_pat_trans_in(par_hosp_code character varying, par_from_date timestamp without time zone, par_to_date timestamp without time zone)
 RETURNS TABLE(description text, sum_child integer, sum_adult integer, sum_unknown integer, sum_prev integer, no_of_days integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_adm_dt         TIMESTAMP;
    var_source         VARCHAR(6);
    var_dob            TIMESTAMP;
    var_prev_from_date TIMESTAMP;
    var_prev_to_date   TIMESTAMP;
    var_age            INTEGER;
    var_no_of_days     INTEGER;
BEGIN
    -- Adjust date ranges
    par_to_date := par_to_date + INTERVAL '1 day';
    var_prev_from_date := par_from_date - INTERVAL '1 year';
    var_prev_to_date := par_to_date - INTERVAL '1 year';
    var_no_of_days := EXTRACT(DAY FROM (par_to_date - par_from_date));

    DROP TABLE IF EXISTS t$tx_table;
    CREATE TEMPORARY TABLE t$tx_table (
        source  VARCHAR(6),
        prev    INTEGER DEFAULT 0,
        adult   INTEGER DEFAULT 0,
        child   INTEGER DEFAULT 0,
        unknown INTEGER DEFAULT 0
    );

    /* changed by Karen at 1996-04-30 for cpi */
    /* before changes are comment for select from Case_view written below */
    /*
    declare CUR1 cursor for select
    Admission_datetime, Source_code, PMI.DOB
    from Case, PMI
    where (Case.HKID = PMI.HKID) and
          (Case_type = 'I') and
          (((Admission_datetime >= @prev_from_date) and
        (Admission_datetime < @prev_to_date)) or
           ((Admission_datetime >= @from_date) and
            (Admission_datetime < @to_date))) and
          (Case.Source_indicator = '5')
    */
    /* end of comment */
    /* modify start for select from Case_view */
    /* updated to improve performance by chuls @960806 */
    /*
    declare CUR1 cursor for select
    Admission_datetime, Source_code, PMI.DOB
    from Case_view, PMI
    where (Case_view.HKID = PMI.HKID) and
          (Case_type = 'I') and
          (((Admission_datetime >= @prev_from_date) and
            (Admission_datetime < @prev_to_date)) or
           ((Admission_datetime >= @from_date) and
            (Admission_datetime < @to_date))) and
          (Case_view.Source_indicator = '5')
    */
    /* updated to improve performance by chuls @960806 */
    /* end of modify */

    /* add hosp code for hpi by ML on 26.07.1999 */
    /* use PMI_wo_MRN instead of PMI on 26.07.1999 */

    FOR var_adm_dt, var_source, var_dob IN
        SELECT
            t.transaction_datetime,
            c.source_code,
            p.dob
        FROM
            transaction_log t
            JOIN case_view c ON t.case_no = c.case_no
            JOIN pmi_wo_mrn p ON c.hkid = p.hkid
        WHERE
              t.transaction_datetime >= par_from_date
          AND t.transaction_datetime < par_to_date
          AND t.transaction_type = '100'
          AND t.from_ward_code <> 'AE01'
          AND t.cancel_flag IS NULL
          AND c.source_indicator = '5'
          AND t.hospital_code = par_hosp_code
          AND c.hospital_code = par_hosp_code
    LOOP
        IF var_dob IS NULL
        THEN
            INSERT INTO t$tx_table (source, unknown) VALUES (var_source, 1);
        ELSE
            var_age := EXTRACT(YEAR FROM AGE(var_adm_dt, var_dob));
            IF var_age < 16
            THEN
                INSERT INTO t$tx_table (source, child) VALUES (var_source, 1);
            ELSE
                INSERT INTO t$tx_table (source, adult) VALUES (var_source, 1);
            END IF;
        END IF;
    END LOOP;

    /* Add hosp code for HPI by ML on 26.07.1999 */
    /* modified to use PMI_wo_MRN instead of PMI on 26.07.1999 */

    FOR var_adm_dt, var_source, var_dob IN
        SELECT
            t.transaction_datetime,
            c.source_code,
            p.dob
        FROM
            transaction_log t
            JOIN case_view c ON t.case_no = c.case_no
            JOIN pmi_wo_mrn p ON c.hkid = p.hkid
        WHERE
              t.transaction_datetime >= var_prev_from_date
          AND t.transaction_datetime < var_prev_to_date
          AND t.transaction_type = '100'
          AND t.from_ward_code <> 'AE01'
          AND t.cancel_flag IS NULL
          AND c.source_indicator = '5'
          AND t.hospital_code = par_hosp_code
          AND c.hospital_code = par_hosp_code
    LOOP
        INSERT INTO t$tx_table (source, prev) VALUES (var_source, 1);
    END LOOP;

    -- Final select
    RETURN QUERY
        SELECT
            d.description::text,
            COALESCE(SUM(t.child), 0) :: INTEGER,
            COALESCE(SUM(t.adult), 0):: INTEGER,
            COALESCE(SUM(t.unknown), 0):: INTEGER,
            COALESCE(SUM(t.prev), 0):: INTEGER,
            var_no_of_days::INTEGER
        FROM
            t$tx_table t
            JOIN destination d ON d.destination_code = t.source
        GROUP BY d.description
        ORDER BY d.description NULLS FIRST;

END;
$function$
;

;ALTER FUNCTION "hasp_in_pat_trans_in" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
