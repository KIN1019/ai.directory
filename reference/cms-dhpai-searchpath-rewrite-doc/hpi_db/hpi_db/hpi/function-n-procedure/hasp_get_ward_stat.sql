-- DROP PROCEDURE hpi.hasp_get_ward_stat(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_ward_stat(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_ward character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    result_str_value            VARCHAR(128);
    result_int_value            INTEGER;
    result_real_value           REAL;
    result_dtm_value            TIMESTAMP WITHOUT TIME ZONE;
    var_cdbb_count              INTEGER;
    var_cdbb_record             RECORD;
    var_error                   INTEGER;
    var_rowcount                INTEGER;
    var_errarg                  VARCHAR(80);
    var_desc                    VARCHAR(30);
    var_remain                  INTEGER;
    var_date                    TIMESTAMP WITHOUT TIME ZONE;
    var_temp_date               TIMESTAMP WITHOUT TIME ZONE;
    var_ward                    VARCHAR(4);
    var_spec                    VARCHAR(4);
    var_loc                     VARCHAR(4);
    var_prev_remain             INTEGER;
    var_adm                     INTEGER;
    var_txin                    INTEGER;
    var_txout                   INTEGER;
    var_td_txin                 INTEGER;
    var_td_txout                INTEGER;
    var_dsch                    INTEGER;
    var_deth                    INTEGER;
    var_day_dsch                INTEGER;
    var_day_deth                INTEGER;
    var_ae_day_dsch             INTEGER;
    var_ae_day_deth             INTEGER;
    var_ae_adm                  INTEGER;
    var_tx_within_ward          INTEGER;
    var_canc_adm                INTEGER;
    var_canc_txin               INTEGER;
    var_canc_txout              INTEGER;
    var_canc_td_txin            INTEGER;
    var_canc_td_txout           INTEGER;
    var_canc_dsch               INTEGER;
    var_canc_deth               INTEGER;
    var_canc_day_dsch           INTEGER;
    var_canc_day_deth           INTEGER;
    var_canc_ae_day_dsch        INTEGER;
    var_canc_ae_day_deth        INTEGER;
    var_canc_ae_adm             INTEGER;
    var_canc_tx_within_ward     INTEGER;
    var_dp_bed                  INTEGER;
    var_ip_bed                  REAL;
    var_bdo                     REAL;
    var_vac                     REAL;
    var_exc                     REAL;
    var_days                    REAL;
    var_ttl_prev_remain         INTEGER;
    var_ttl_adm                 INTEGER;
    var_ttl_canc_adm            INTEGER;
    var_ttl_txin                INTEGER;
    var_ttl_canc_txin           INTEGER;
    var_ttl_txout               INTEGER;
    var_ttl_canc_txout          INTEGER;
    var_ttl_tx_within_ward      INTEGER;
    var_ttl_canc_tx_within_ward INTEGER;
    var_ttl_td_txin             INTEGER;
    var_ttl_canc_td_txin        INTEGER;
    var_ttl_td_txout            INTEGER;
    var_ttl_canc_td_txout       INTEGER;
    var_ttl_dsch                INTEGER;
    var_ttl_canc_dsch           INTEGER;
    var_ttl_deth                INTEGER;
    var_ttl_canc_deth           INTEGER;
    var_ttl_ae_day_dsch         INTEGER;
    var_ttl_canc_ae_day_dsch    INTEGER;
    var_ttl_ae_day_deth         INTEGER;
    var_ttl_canc_ae_day_deth    INTEGER;
    var_ttl_remain              INTEGER;
    var_ttl_bdo                 REAL;
    var_ttl_vac                 REAL;
    var_ttl_ip_bed              REAL;
    var_ttl_exc                 REAL;
    var_ttl_dp_bed              INTEGER;
    var_ttl_day_dsch            INTEGER;
    var_ttl_canc_day_dsch       INTEGER;
    var_ttl_day_deth            INTEGER;
    var_ttl_canc_day_deth       INTEGER;
    var_ttl_inpat_treated       REAL;
    var_ttl_occ_rate            REAL;
    var_ttl_los                 REAL;
    var_ttl_turnover            REAL;
    var_ttl_turnover_interval   REAL;
    ward_csr
        CURSOR FOR
        SELECT DISTINCT Ward_code
        FROM Ward
        WHERE Ward_code LIKE par_input_ward
          AND Ward_code <> 'AE01'
          AND Hospital_code = par_hosp_code;
    ward_spec_csr
        CURSOR FOR
        SELECT DISTINCT Specialty_code
        FROM Ward_specialty
        WHERE Ward_code = var_ward
          AND Specialty_code <> 'A&E'
          AND Hospital_code = par_hosp_code;
    sql$rowcount
                                BIGINT;
BEGIN
    /*
    parameter name          Description
    @input_from_date        From date to be processed
    @input_to_date          To date to be processed
    @input_ward             Required ward code
    */
    /* ---------------------------------------------------------------------------------------------- */
    /* 20180105 to fix/avoid following error : remove SELECT * */

    /* ---------------------------------------------------------------------------------------------- */
    /* DBCC upgrade_object: Upgrading PROCEDURE dbo.hasp_get_ward_stat */
    /* Warning: PROCEDURE hasp_get_ward_stat contains the SELECT * construct in the outermost */
    /* SELECT query. */
    /* Please verify that the table(s) referenced in the SELECT * have not */
    /* been altered.  During upgrade the SELECT * is expanded to include all */
    /* columns of the table(s). */
    /* Run DBCC upgrade_object with the 'force' option to upgrade hasp_get_ward_stat. */
    /* Warning: PROCEDURE hasp_get_ward_stat contains the SELECT * construct in the outermost */
    /* SELECT query. */
    /* Please verify that the table(s) referenced in the SELECT * have not */
    /* been altered.  During upgrade the SELECT * is expanded to include all */
    /* columns of the table(s). */
    /* Run DBCC upgrade_object with the 'force' option to upgrade hasp_get_ward_stat. */
    /* Warning: PROCEDURE hasp_get_ward_stat contains the SELECT * construct in the outermost */
    /* SELECT query. */
    /* Please verify that the table(s) referenced in the SELECT * have not */
    /* been altered.  During upgrade the SELECT * is expanded to include all */
    /* columns of the table(s). */
    /* Run DBCC upgrade_object with the 'force' option to upgrade hasp_get_ward_stat. */
    /* Msg 11031, Level 16, State 1: */
    /* Server 'xxx', Procedure 'hasp_get_ward_stat', Line 25: */
    /* Execution of procedure hasp_get_ward_stat failed because of errors parsing the source text in syscomments during upgrade. Please drop and recreate dbo.hasp_get_ward_stat. */

    /* ---------------------------------------------------------------------------------------------- */

    /* create temp table for stat report */
    SELECT DATE_PART('days', par_input_to_date::timestamp::date::timestamp
        - par_input_from_date::timestamp::date::timestamp) + 1
    INTO var_days;
    DROP TABLE IF EXISTS t$stat_table;
    CREATE
        TEMPORARY TABLE t$stat_table
    (
        stat_code                VARCHAR(4),
        stat_desc                VARCHAR(30)       NULL,
        stat_prev_remain         INTEGER DEFAULT 0 NULL,
        stat_adm                 INTEGER DEFAULT 0 NULL,
        stat_canc_adm            INTEGER DEFAULT 0 NULL,
        stat_txin                INTEGER DEFAULT 0 NULL,
        stat_canc_txin           INTEGER DEFAULT 0 NULL,
        stat_txout               INTEGER DEFAULT 0 NULL,
        stat_canc_txout          INTEGER DEFAULT 0 NULL,
        stat_tx_within_ward      INTEGER DEFAULT 0 NULL,
        stat_canc_tx_within_ward INTEGER DEFAULT 0 NULL,
        stat_td_txin             INTEGER DEFAULT 0 NULL,
        stat_canc_td_txin        INTEGER DEFAULT 0 NULL,
        stat_td_txout            INTEGER DEFAULT 0 NULL,
        stat_canc_td_txout       INTEGER DEFAULT 0 NULL,
        stat_dsch                INTEGER DEFAULT 0 NULL,
        stat_canc_dsch           INTEGER DEFAULT 0 NULL,
        stat_deth                INTEGER DEFAULT 0 NULL,
        stat_canc_deth           INTEGER DEFAULT 0 NULL,
        stat_ae_day_dsch         INTEGER DEFAULT 0 NULL,
        stat_canc_ae_day_dsch    INTEGER DEFAULT 0 NULL,
        stat_ae_day_deth         INTEGER DEFAULT 0 NULL,
        stat_canc_ae_day_deth    INTEGER DEFAULT 0 NULL,
        stat_remain              INTEGER DEFAULT 0 NULL,
        stat_bdo                 REAL    DEFAULT 0 NULL,
        stat_vac                 REAL    DEFAULT 0 NULL,
        stat_ip_bed              REAL    DEFAULT 0 NULL,
        stat_exc                 REAL    DEFAULT 0 NULL,
        stat_dp_bed              INTEGER DEFAULT 0 NULL,
        stat_day_dsch            INTEGER DEFAULT 0 NULL,
        stat_canc_day_dsch       INTEGER DEFAULT 0 NULL,
        stat_day_deth            INTEGER DEFAULT 0 NULL,
        stat_canc_day_deth       INTEGER DEFAULT 0 NULL,
        stat_inpat_treated       REAL    DEFAULT 0 NULL,
        stat_occ_rate            REAL    DEFAULT 0 NULL,
        stat_los                 REAL    DEFAULT 0 NULL,
        stat_turnover            REAL    DEFAULT 0 NULL,
        stat_turnover_interval   REAL    DEFAULT 0 NULL,
        Primary Key (stat_code)
    );
    /*
    create table #start_table (Ward_spec_tx_date datetime,
    			 Ward_code         VARCHAR(04),
    			 Specialty_code    VARCHAR(04),
    			 Treatment_location VARCHAR(04) NULL,
    			 unique clustered (Ward_spec_tx_date,
    					   Ward_code,
    					   Specialty_code,
                                               Treatment_location))
    */
    /* calc previous remaining of start date */
    /*
    insert #start_table
        select max(Ward_spec_tx_date), Ward_code, Specialty_code,
               Treatment_location
            from Ward_spec_tx(2)
    	where Ward_spec_tx_date < @input_from_date
            group by Ward_code, Specialty_code, Treatment_location

    insert into #stat_table (stat_code, stat_prev_remain)
    	select a.Ward_code,
    	  sum(isnull(Previous_remaining, 0))
    	   + sum(isnull(Admission, 0)) - sum(isnull(Canc_admission, 0))
    	   - sum(isnull(Discharge, 0)) + sum(isnull(Canc_discharge, 0))
    	   + sum(isnull(Transfer_in, 0)) - sum(isnull(Canc_transfer_in, 0))
    	   - sum(isnull(Transfer_out, 0)) + sum(isnull(Canc_transfer_out, 0))
    	   - sum(isnull(Death, 0)) + sum(isnull(Canc_death, 0))
    	   + sum(isnull(Transfer_in_from_TD, 0)) - sum(isnull(Canc_transfer_in_from_TD, 0))
    	   - sum(isnull(Transfer_out_to_TD, 0)) + sum(isnull(Canc_transfer_out_to_TD, 0))
            from #start_table a, Ward_spec_tx_adj_view b
    	where a.Ward_spec_tx_date  = b.Ward_spec_tx_date  and
    	     a.Ward_code          = b.Ward_code          and
    	     a.Specialty_code     = b.Specialty_code     and
    	     isnull(a.Treatment_location, 'null')
                      = isnull(b.Treatment_location, 'null')
    	group by a.Ward_code
    */
    /* add hospital code for hpi by ML on 26.07.1999 */
    DROP TABLE IF EXISTS t$start_table;
    CREATE
        TEMPORARY TABLE t$start_table
    AS
    SELECT MAX(Ward_spec_tx_date) AS tx_date,
           Ward_code              AS ward_code,
           Specialty_code         AS spec_code,
           Treatment_location     AS treat_loc
    FROM Ward_spec_tx
    WHERE Ward_spec_tx_date < par_input_from_date
      AND Hospital_code = par_hosp_code::VARCHAR
    GROUP BY ward_code, specialty_code, treatment_location;

    INSERT INTO t$stat_table (stat_code, stat_prev_remain)
    SELECT a.ward_code,
           SUM(COALESCE(b.Previous_remaining, 0)) + SUM(COALESCE(b.Admission, 0)) - SUM(COALESCE(b.Canc_admission, 0)) -
           SUM(COALESCE(b.Discharge, 0)) + SUM(COALESCE(b.Canc_discharge, 0)) + SUM(COALESCE(b.Transfer_in, 0)) -
           SUM(COALESCE(b.Canc_transfer_in, 0)) - SUM(COALESCE(b.Transfer_out, 0)) +
           SUM(COALESCE(b.Canc_transfer_out, 0)) -
           SUM(COALESCE(b.Death, 0)) + SUM(COALESCE(b.Canc_death, 0)) + SUM(COALESCE(b.Transfer_in_from_TD, 0)) -
           SUM(COALESCE(b.Canc_transfer_in_from_TD, 0)) - SUM(COALESCE(b.Transfer_out_to_TD, 0)) +
           SUM(COALESCE(b.Canc_transfer_out_to_TD, 0))
    FROM t$start_table AS a,
         Ward_spec_tx_adj_view AS b
    WHERE a.tx_date = b.Ward_spec_tx_date
      AND a.ward_code = b.ward_code
      AND a.spec_code = b.specialty_code
      AND b.Hospital_code = par_hosp_code
      AND
        /* add hospital code for hpi by ML on 26.07.1999 */
        COALESCE(a.treat_loc, 'null') = COALESCE(b.treatment_location, 'null')
    GROUP BY a.ward_code
    ORDER BY a.ward_code NULLS FIRST;
    /* add hospital code for hpi by ML on 26.07.1999 */
/* add hospital code for hpi by ML on 26.07.1999 */
/* Loop by Date */
    SELECT par_input_from_date
    INTO var_date;

    WHILE
        var_date <= par_input_to_date
    LOOP
        /*
        if @date <> @input_from_date
        update #stat_table set stat_prev_remain = stat_remain
        */
        /* Calc ip and dp bed */
        /* Loop By Ward */
        OPEN ward_csr;
        LOOP
            FETCH ward_csr INTO var_ward;
            EXIT WHEN NOT FOUND;

            SELECT 0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0,
                   0
            INTO var_ttl_ip_bed, var_ttl_dp_bed, var_prev_remain, var_adm, var_txin, var_txout, var_td_txin, var_td_txout, var_dsch, var_deth, var_day_dsch, var_day_deth, var_ae_day_dsch, var_ae_day_deth, var_ae_adm, var_tx_within_ward, var_canc_adm, var_canc_txin, var_canc_txout, var_canc_td_txin, var_canc_td_txout, var_canc_dsch, var_canc_deth, var_canc_day_dsch, var_canc_day_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_ae_adm, var_canc_tx_within_ward, var_dp_bed, var_ip_bed, var_bdo, var_vac, var_exc;
            /* Loop by Specialty within Ward */
/* add hospital code for hpi by ML on 26.07.1999 */
            OPEN ward_spec_csr;
            LOOP
                FETCH ward_spec_csr INTO var_spec;
                EXIT WHEN NOT FOUND;

                SELECT Official_bed,
                       Day_bed
                -- INTO var_ip_bed, var_dp_bed
                INTO result_real_value,result_int_value
                FROM Ward_specialty
                WHERE Ward_code = var_ward
                  AND Specialty_code = var_spec
                  AND Effective_date = (SELECT MAX(Effective_date)
                                        FROM Ward_specialty
                                        WHERE Ward_code = var_ward
                                          AND Specialty_code = var_spec
                                          AND Effective_date <= var_date
                                          AND Hospital_code = par_hosp_code)
                  AND Hospital_code = par_hosp_code;

                IF FOUND
                THEN
                    var_ip_bed := result_real_value;
                    var_dp_bed := result_int_value;
                    SELECT var_ttl_ip_bed + var_ip_bed,
                           var_ttl_dp_bed + var_dp_bed
                    INTO var_ttl_ip_bed, var_ttl_dp_bed;
                END IF;
                --                     GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
--                     IF
--                         sql$rowcount > 0 THEN
--                         SELECT var_ttl_ip_bed + var_ip_bed,
--                                var_ttl_dp_bed + var_dp_bed
--                         INTO var_ttl_ip_bed, var_ttl_dp_bed;
--                     END IF;
            END LOOP;
            CLOSE ward_spec_csr;
/* Calc tx summary */
            SELECT COALESCE(SUM(Admission), 0),
                   COALESCE(SUM(Transfer_in), 0),
                   COALESCE(SUM(Transfer_out), 0),
                   COALESCE(SUM(Transfer_in_from_TD), 0),
                   COALESCE(SUM(Transfer_out_to_TD), 0),
                   COALESCE(SUM(Discharge), 0),
                   COALESCE(SUM(Death), 0),
                   COALESCE(SUM(AE_day_discharge), 0),
                   COALESCE(SUM(AE_day_death), 0),
                   COALESCE(SUM(Admission_thru_AE), 0),
                   COALESCE(SUM(Day_discharge), 0),
                   COALESCE(SUM(Day_death), 0),
                   COALESCE(SUM(Transfer_within_ward), 0),
                   COALESCE(SUM(Canc_admission), 0),
                   COALESCE(SUM(Canc_transfer_in), 0),
                   COALESCE(SUM(Canc_transfer_out), 0),
                   COALESCE(SUM(Canc_transfer_in_from_TD), 0),
                   COALESCE(SUM(Canc_transfer_out_to_TD), 0),
                   COALESCE(SUM(Canc_discharge), 0),
                   COALESCE(SUM(Canc_death), 0),
                   COALESCE(SUM(Canc_AE_day_discharge), 0),
                   COALESCE(SUM(Canc_AE_day_death), 0),
                   COALESCE(SUM(Canc_admission_thru_AE), 0),
                   COALESCE(SUM(Canc_day_discharge), 0),
                   COALESCE(SUM(Canc_day_death), 0),
                   COALESCE(SUM(Canc_transfer_within_ward), 0)
            INTO var_adm, var_txin, var_txout, var_td_txin, var_td_txout, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_ae_adm, var_day_dsch, var_day_deth, var_tx_within_ward, var_canc_adm, var_canc_txin, var_canc_txout, var_canc_td_txin, var_canc_td_txout, var_canc_dsch, var_canc_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_ae_adm, var_canc_day_dsch, var_canc_day_deth, var_canc_tx_within_ward
            FROM Ward_spec_tx_adj_view
            WHERE Ward_spec_tx_date = var_date
              AND Ward_code = var_ward
              AND Hospital_code = par_hosp_code
            GROUP BY Ward_code;

            IF NOT FOUND
            THEN
                var_adm := 0;var_txin := 0;var_txout := 0;var_td_txin := 0;var_td_txout := 0;var_dsch := 0;
                var_deth := 0; var_ae_day_dsch := 0; var_ae_day_deth := 0; var_ae_adm := 0; var_day_dsch := 0;
                var_day_deth := 0; var_tx_within_ward := 0; var_canc_adm := 0; var_canc_txin := 0;
                var_canc_txout := 0; var_canc_td_txin := 0; var_canc_td_txout := 0; var_canc_dsch := 0;
                var_canc_deth := 0; var_canc_ae_day_dsch := 0; var_canc_ae_day_deth := 0; var_canc_ae_adm := 0;
                var_canc_day_dsch := 0; var_canc_day_deth := 0; var_canc_tx_within_ward := 0;
            END IF;

            /* add hosp code for HPI by ML on 26.07.1999 */
            /* Calc remaining from previous */
            SELECT stat_prev_remain
            -- INTO var_prev_remain
            INTO result_int_value
            FROM t$stat_table
            WHERE stat_code = var_ward;

            IF FOUND
            THEN
                var_prev_remain := result_int_value;
            ELSE
                BEGIN
                    SELECT 0
                    INTO var_prev_remain;
                    INSERT INTO t$stat_table (stat_code)
                    VALUES (var_ward);
                END;
            END IF;

            --                 GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
--                 IF
--                     sql$rowcount = 0 THEN
--                     BEGIN
--                         SELECT 0
--                         INTO var_prev_remain;
--                         INSERT INTO t$stat_table (stat_code)
--                         VALUES (var_ward);
--                     END;
--                 END IF;

            SELECT var_prev_remain + var_adm + var_txin + var_td_txin - var_txout - var_td_txout - var_dsch -
                   var_deth - var_canc_adm -
                   var_canc_txin - var_canc_td_txin + var_canc_txout + var_canc_td_txout + var_canc_dsch +
                   var_canc_deth
            INTO var_remain;

            SELECT var_remain + var_ae_day_dsch + var_ae_day_deth - var_canc_ae_day_dsch - var_canc_ae_day_deth
            INTO var_bdo;

            IF
                var_bdo > var_ttl_ip_bed
            THEN
                SELECT 0,
                       var_bdo - var_ttl_ip_bed
                INTO var_vac, var_exc;
            ELSE
                SELECT 0,
                       var_ttl_ip_bed - var_bdo
                INTO var_exc, var_vac;
            END IF;

            UPDATE t$stat_table
            SET stat_adm                 = COALESCE(stat_adm + var_adm, 0),
                stat_canc_adm            = COALESCE(stat_canc_adm + var_canc_adm, 0),
                stat_txin                = COALESCE(stat_txin + var_txin, 0),
                stat_canc_txin           = COALESCE(stat_canc_txin + var_canc_txin, 0),
                stat_txout               = COALESCE(stat_txout + var_txout, 0),
                stat_canc_txout          = COALESCE(stat_canc_txout + var_canc_txout, 0),
                stat_tx_within_ward      = COALESCE(stat_tx_within_ward + var_tx_within_ward, 0),
                stat_canc_tx_within_ward = COALESCE(stat_canc_tx_within_ward + var_canc_tx_within_ward, 0),
                stat_td_txin             = COALESCE(stat_td_txin + var_td_txin, 0),
                stat_canc_td_txin        = COALESCE(stat_canc_td_txin + var_canc_td_txin, 0),
                stat_td_txout            = COALESCE(stat_td_txout + var_td_txout, 0),
                stat_canc_td_txout       = COALESCE(stat_canc_td_txout + var_canc_td_txout, 0),
                stat_dsch                = COALESCE(stat_dsch + var_dsch, 0),
                stat_canc_dsch           = COALESCE(stat_canc_dsch + var_canc_dsch, 0),
                stat_deth                = COALESCE(stat_deth + var_deth, 0),
                stat_canc_deth           = COALESCE(stat_canc_deth + var_canc_deth, 0),
                stat_ae_day_dsch         = COALESCE(stat_ae_day_dsch + var_ae_day_dsch, 0),
                stat_canc_ae_day_dsch    = COALESCE(stat_canc_ae_day_dsch + var_canc_ae_day_dsch, 0),
                stat_ae_day_deth         = COALESCE(stat_ae_day_deth + var_ae_day_deth, 0),
                stat_canc_ae_day_deth    = COALESCE(stat_canc_ae_day_deth + var_canc_ae_day_deth, 0),
                stat_remain              = COALESCE(stat_remain + var_remain, 0),
                stat_bdo                 = COALESCE(stat_bdo + var_bdo, 0),
                stat_vac                 = COALESCE(stat_vac + var_vac, 0),
                stat_ip_bed              = COALESCE(stat_ip_bed + var_ttl_ip_bed, 0),
                stat_exc                 = COALESCE(stat_exc + var_exc, 0),
                stat_dp_bed              = COALESCE(stat_dp_bed + var_ttl_dp_bed, 0),
                stat_day_dsch            = COALESCE(stat_day_dsch + var_day_dsch, 0),
                stat_canc_day_dsch       = COALESCE(stat_canc_day_dsch + var_canc_day_dsch, 0),
                stat_day_deth            = COALESCE(stat_day_deth + var_day_deth, 0),
                stat_canc_day_deth       = COALESCE(stat_canc_day_deth + var_canc_day_deth, 0)
            WHERE stat_code = var_ward;

            IF
                par_input_from_date <> par_input_to_date
            THEN
                UPDATE t$stat_table
                SET stat_prev_remain = var_remain
                WHERE stat_code = var_ward;
            END IF;

        END LOOP;
        CLOSE ward_csr;
        SELECT 1 * INTERVAL '1 day' + var_date::TIMESTAMP
        INTO var_date;
    END LOOP;
    /* add hospital code for hpi by ML on 26.07.1999 */
    UPDATE t$stat_table
    SET stat_desc = subquery.Description
    FROM (SELECT a.stat_code,
                 (SELECT w.Description
                  FROM Ward w
                  WHERE w.Ward_code = a.stat_code
                    AND w.Effective_date = (SELECT MAX(w2.Effective_date)
                                            FROM Ward w2
                                            WHERE w2.Ward_code = a.stat_code
                                              AND w2.Effective_date <= par_input_to_date
                                              AND w2.Hospital_code = par_hosp_code)
                    AND w.Hospital_code = par_hosp_code) AS Description
          FROM t$stat_table a) AS subquery
    WHERE t$stat_table.stat_code = subquery.stat_code;

/* if range of dates then set previous remaining to null */
    IF
        par_input_from_date <> par_input_to_date
    THEN
        UPDATE t$stat_table
        SET stat_prev_remain = NULL;
    END IF;

    UPDATE t$stat_table
    SET stat_occ_rate = stat_bdo * 100 / stat_ip_bed
    WHERE stat_ip_bed <> 0
      AND stat_code <> 'HOME';

    UPDATE t$stat_table
    SET stat_occ_rate = NULL
    WHERE stat_ip_bed = 0
       OR stat_code = 'HOME';

    UPDATE t$stat_table
    SET stat_inpat_treated =
            stat_dsch - stat_canc_dsch + stat_deth - stat_canc_deth + stat_txout - stat_canc_txout -
            stat_day_dsch + stat_canc_day_dsch - stat_day_deth + stat_canc_day_deth -
            (stat_tx_within_ward / 2) +
            (stat_canc_tx_within_ward / 2)
    WHERE stat_code <> 'HOME';

    UPDATE t$stat_table
    SET stat_inpat_treated = NULL
    WHERE stat_code = 'HOME';

    UPDATE t$stat_table
    SET stat_los = stat_bdo / stat_inpat_treated
    WHERE stat_code <> 'HOME'
      AND stat_inpat_treated <> 0;

    UPDATE t$stat_table
    SET stat_los = NULL
    WHERE stat_inpat_treated = 0
       OR stat_code = 'HOME';

    UPDATE t$stat_table
    SET stat_turnover = stat_inpat_treated * var_days / stat_ip_bed
    WHERE stat_code <> 'HOME'
      AND stat_ip_bed <> 0;

    UPDATE t$stat_table
    SET stat_turnover = NULL
    WHERE stat_code = 'HOME'
       OR stat_ip_bed = 0;

    UPDATE t$stat_table
    SET stat_turnover_interval = (stat_vac - stat_exc) * var_days / stat_ip_bed
    WHERE stat_code <> 'HOME'
      AND stat_vac >= stat_exc
      AND stat_ip_bed <> 0;

    UPDATE t$stat_table
    SET stat_turnover_interval = NULL
    WHERE stat_code = 'HOME'
       OR stat_vac < stat_exc
       OR stat_ip_bed = 0;

    DROP TABLE IF EXISTS t$dsp_table;

    CREATE
        TEMPORARY TABLE t$dsp_table
    (
        dsp_code                VARCHAR(4)        NULL,
        dsp_desc                VARCHAR(30)       NULL,
        dsp_prev_remain         INTEGER DEFAULT 0 NULL,
        dsp_adm                 INTEGER DEFAULT 0 NULL,
        dsp_canc_adm            INTEGER DEFAULT 0 NULL,
        dsp_txin                INTEGER DEFAULT 0 NULL,
        dsp_canc_txin           INTEGER DEFAULT 0 NULL,
        dsp_txout               INTEGER DEFAULT 0 NULL,
        dsp_canc_txout          INTEGER DEFAULT 0 NULL,
        dsp_tx_within_ward      INTEGER DEFAULT 0 NULL,
        dsp_canc_tx_within_ward INTEGER DEFAULT 0 NULL,
        dsp_td_txin             INTEGER DEFAULT 0 NULL,
        dsp_canc_td_txin        INTEGER DEFAULT 0 NULL,
        dsp_td_txout            INTEGER DEFAULT 0 NULL,
        dsp_canc_td_txout       INTEGER DEFAULT 0 NULL,
        dsp_dsch                INTEGER DEFAULT 0 NULL,
        dsp_canc_dsch           INTEGER DEFAULT 0 NULL,
        dsp_deth                INTEGER DEFAULT 0 NULL,
        dsp_canc_deth           INTEGER DEFAULT 0 NULL,
        dsp_ae_day_dsch         INTEGER DEFAULT 0 NULL,
        dsp_canc_ae_day_dsch    INTEGER DEFAULT 0 NULL,
        dsp_ae_day_deth         INTEGER DEFAULT 0 NULL,
        dsp_canc_ae_day_deth    INTEGER DEFAULT 0 NULL,
        dsp_remain              INTEGER DEFAULT 0 NULL,
        dsp_bdo                 REAL    DEFAULT 0 NULL,
        dsp_vac                 REAL    DEFAULT 0 NULL,
        dsp_ip_bed              REAL    DEFAULT 0 NULL,
        dsp_exc                 INTEGER DEFAULT 0 NULL,
        dsp_dp_bed              INTEGER DEFAULT 0 NULL,
        dsp_day_dsch            INTEGER DEFAULT 0 NULL,
        dsp_canc_day_dsch       INTEGER DEFAULT 0 NULL,
        dsp_day_deth            INTEGER DEFAULT 0 NULL,
        dsp_canc_day_deth       INTEGER DEFAULT 0 NULL,
        dsp_inpat_treated       REAL    DEFAULT 0 NULL,
        dsp_occ_rate            REAL    DEFAULT 0 NULL,
        dsp_los                 REAL    DEFAULT 0 NULL,
        dsp_turnover            REAL    DEFAULT 0 NULL,
        dsp_turnover_interval   REAL    DEFAULT 0 NULL
    );
    /* --insert into #dsp_table select * from #stat_table  --20180105 */
    INSERT INTO t$dsp_table
    SELECT stat_code,
           stat_desc,
           stat_prev_remain,
           stat_adm,
           stat_canc_adm,
           stat_txin,
           stat_canc_txin,
           stat_txout,
           stat_canc_txout,
           stat_tx_within_ward,
           stat_canc_tx_within_ward,
           stat_td_txin,
           stat_canc_td_txin,
           stat_td_txout,
           stat_canc_td_txout,
           stat_dsch,
           stat_canc_dsch,
           stat_deth,
           stat_canc_deth,
           stat_ae_day_dsch,
           stat_canc_ae_day_dsch,
           stat_ae_day_deth,
           stat_canc_ae_day_deth,
           stat_remain,
           stat_bdo,
           stat_vac,
           stat_ip_bed,
           stat_exc,
           stat_dp_bed,
           stat_day_dsch,
           stat_canc_day_dsch,
           stat_day_deth,
           stat_canc_day_deth,
           stat_inpat_treated,
           stat_occ_rate,
           stat_los,
           stat_turnover,
           stat_turnover_interval
    FROM t$stat_table
    WHERE stat_code <> 'HOME'
    ORDER BY stat_code;

    SELECT SUM(stat_prev_remain),
           SUM(stat_adm),
           SUM(stat_canc_adm),
           SUM(stat_txin),
           SUM(stat_canc_txin),
           SUM(stat_txout),
           SUM(stat_canc_txout),
           SUM(stat_tx_within_ward),
           SUM(stat_canc_tx_within_ward),
           SUM(stat_td_txin),
           SUM(stat_canc_td_txin),
           SUM(stat_td_txout),
           SUM(stat_canc_td_txout),
           SUM(stat_dsch),
           SUM(stat_canc_dsch),
           SUM(stat_deth),
           SUM(stat_canc_deth),
           SUM(stat_ae_day_dsch),
           SUM(stat_canc_ae_day_dsch),
           SUM(stat_ae_day_deth),
           SUM(stat_canc_ae_day_deth),
           SUM(stat_remain),
           SUM(stat_bdo),
           SUM(stat_vac),
           SUM(stat_ip_bed),
           SUM(stat_exc),
           SUM(stat_dp_bed),
           SUM(stat_day_dsch),
           SUM(stat_canc_day_dsch),
           SUM(stat_day_deth),
           SUM(stat_canc_day_deth)
    INTO var_ttl_prev_remain, var_ttl_adm, var_ttl_canc_adm, var_ttl_txin, var_ttl_canc_txin, var_ttl_txout, var_ttl_canc_txout, var_ttl_tx_within_ward, var_ttl_canc_tx_within_ward, var_ttl_td_txin, var_ttl_canc_td_txin, var_ttl_td_txout, var_ttl_canc_td_txout, var_ttl_dsch, var_ttl_canc_dsch, var_ttl_deth, var_ttl_canc_deth, var_ttl_ae_day_dsch, var_ttl_canc_ae_day_dsch, var_ttl_ae_day_deth, var_ttl_canc_ae_day_deth, var_ttl_remain, var_ttl_bdo, var_ttl_vac, var_ttl_ip_bed, var_ttl_exc, var_ttl_dp_bed, var_ttl_day_dsch, var_ttl_canc_day_dsch, var_ttl_day_deth, var_ttl_canc_day_deth
    FROM t$stat_table
    WHERE stat_code <> 'HOME';

    SELECT
        var_ttl_dsch - var_ttl_canc_dsch + var_ttl_deth - var_ttl_canc_deth - var_ttl_day_dsch + var_ttl_canc_day_dsch -
        var_ttl_day_deth + var_ttl_canc_day_deth
    INTO var_ttl_inpat_treated;

    IF
        var_ttl_ip_bed <> 0
    THEN
        SELECT var_ttl_bdo * 100 / var_ttl_ip_bed
        INTO var_ttl_occ_rate;
    ELSE
        SELECT NULL
        INTO var_ttl_occ_rate;
    END IF;

    IF
        var_ttl_inpat_treated <> 0
    THEN
        SELECT var_ttl_bdo / var_ttl_inpat_treated
        INTO var_ttl_los;
    ELSE
        SELECT NULL
        INTO var_ttl_los;
    END IF;

    IF
        var_ttl_ip_bed <> 0 AND var_ttl_vac >= var_ttl_exc
    THEN
        SELECT var_ttl_inpat_treated * var_days / var_ttl_ip_bed,
               (var_ttl_vac - var_ttl_exc) * var_days / var_ttl_ip_bed
        INTO var_ttl_turnover, var_ttl_turnover_interval;
    ELSE
        SELECT NULL,
               NULL
        INTO var_ttl_turnover, var_ttl_turnover_interval;
    END IF;

    INSERT INTO t$dsp_table
    VALUES (NULL, 'Hospital Total', var_ttl_prev_remain, var_ttl_adm, var_ttl_canc_adm, var_ttl_txin, var_ttl_canc_txin,
            var_ttl_txout, var_ttl_canc_txout, var_ttl_tx_within_ward, var_ttl_canc_tx_within_ward, var_ttl_td_txin,
            var_ttl_canc_td_txin, var_ttl_td_txout, var_ttl_canc_td_txout, var_ttl_dsch, var_ttl_canc_dsch,
            var_ttl_deth,
            var_ttl_canc_deth, var_ttl_ae_day_dsch, var_ttl_canc_ae_day_dsch, var_ttl_ae_day_deth,
            var_ttl_canc_ae_day_deth,
            var_ttl_remain, var_ttl_bdo, var_ttl_vac, var_ttl_ip_bed, var_ttl_exc, var_ttl_dp_bed, var_ttl_day_dsch,
            var_ttl_canc_day_dsch, var_ttl_day_deth, var_ttl_canc_day_deth, var_ttl_inpat_treated, var_ttl_occ_rate,
            var_ttl_los, var_ttl_turnover, var_ttl_turnover_interval);

    IF
        EXISTS (SELECT *
                FROM t$stat_table
                WHERE stat_code = 'HOME')
    THEN
        /* --insert into #dsp_table select * from #stat_table  --20180105 */
        INSERT INTO t$dsp_table
        SELECT stat_code,
               stat_desc,
               stat_prev_remain,
               stat_adm,
               stat_canc_adm,
               stat_txin,
               stat_canc_txin,
               stat_txout,
               stat_canc_txout,
               stat_tx_within_ward,
               stat_canc_tx_within_ward,
               stat_td_txin,
               stat_canc_td_txin,
               stat_td_txout,
               stat_canc_td_txout,
               stat_dsch,
               stat_canc_dsch,
               stat_deth,
               stat_canc_deth,
               stat_ae_day_dsch,
               stat_canc_ae_day_dsch,
               stat_ae_day_deth,
               stat_canc_ae_day_deth,
               stat_remain,
               stat_bdo,
               stat_vac,
               stat_ip_bed,
               stat_exc,
               stat_dp_bed,
               stat_day_dsch,
               stat_canc_day_dsch,
               stat_day_deth,
               stat_canc_day_deth,
               stat_inpat_treated,
               stat_occ_rate,
               stat_los,
               stat_turnover,
               stat_turnover_interval
        FROM t$stat_table
        WHERE stat_code = 'HOME';
    END IF;

    IF
        par_input_from_date <> par_input_to_date
    THEN
        BEGIN
            UPDATE t$dsp_table
            SET dsp_adm            = dsp_adm - dsp_canc_adm,
                dsp_txin           = dsp_txin - dsp_canc_txin,
                dsp_txout          = dsp_txout - dsp_canc_txout,
                dsp_tx_within_ward = dsp_tx_within_ward - dsp_canc_tx_within_ward,
                dsp_td_txin        = dsp_td_txin - dsp_canc_td_txin,
                dsp_td_txout       = dsp_td_txout - dsp_canc_td_txout,
                dsp_dsch           = dsp_dsch - dsp_canc_dsch,
                dsp_deth           = dsp_deth - dsp_canc_deth,
                dsp_ae_day_dsch    = dsp_ae_day_dsch - dsp_canc_ae_day_dsch,
                dsp_ae_day_deth    = dsp_ae_day_deth - dsp_canc_ae_day_deth,
                dsp_day_dsch       = dsp_day_dsch - dsp_canc_day_dsch,
                dsp_day_deth       = dsp_day_deth - dsp_canc_day_deth;

            UPDATE t$dsp_table
            SET dsp_canc_adm            = 0,
                dsp_canc_txin           = 0,
                dsp_canc_txout          = 0,
                dsp_canc_tx_within_ward = 0,
                dsp_canc_td_txin        = 0,
                dsp_canc_td_txout       = 0,
                dsp_canc_dsch           = 0,
                dsp_canc_deth           = 0,
                dsp_canc_ae_day_dsch    = 0,
                dsp_canc_ae_day_deth    = 0,
                dsp_canc_day_dsch       = 0,
                dsp_canc_day_deth       = 0;
        END;
    END IF;

    /* return temp table to client */
    /* --select * from #dsp_table --20180105 */
    OPEN p_refcur FOR
        SELECT dsp_code,
               dsp_desc,
               dsp_prev_remain,
               dsp_adm,
               dsp_canc_adm,
               dsp_txin,
               dsp_canc_txin,
               dsp_txout,
               dsp_canc_txout,
               dsp_tx_within_ward,
               dsp_canc_tx_within_ward,
               dsp_td_txin,
               dsp_canc_td_txin,
               dsp_td_txout,
               dsp_canc_td_txout,
               dsp_dsch,
               dsp_canc_dsch,
               dsp_deth,
               dsp_canc_deth,
               dsp_ae_day_dsch,
               dsp_canc_ae_day_dsch,
               dsp_ae_day_deth,
               dsp_canc_ae_day_deth,
               dsp_remain,
               dsp_bdo,
               dsp_vac,
               dsp_ip_bed,
               dsp_exc,
               dsp_dp_bed,
               dsp_day_dsch,
               dsp_canc_day_dsch,
               dsp_day_deth,
               dsp_canc_day_deth,
               dsp_inpat_treated,
               dsp_occ_rate,
               dsp_los,
               dsp_turnover,
               dsp_turnover_interval
        FROM t$dsp_table
        WHERE dsp_adm <> 0
           OR dsp_canc_adm <> 0
           OR dsp_txin <> 0
           OR dsp_canc_txin <> 0
           OR dsp_txout <> 0
           OR dsp_canc_txout <> 0
           OR dsp_tx_within_ward <> 0
           OR dsp_canc_tx_within_ward <> 0
           OR dsp_td_txin <> 0
           OR dsp_canc_td_txin <> 0
           OR dsp_td_txout <> 0
           OR dsp_canc_td_txout <> 0
           OR dsp_dsch <> 0
           OR dsp_canc_dsch <> 0
           OR dsp_deth <> 0
           OR dsp_canc_deth <> 0
           OR dsp_ae_day_dsch <> 0
           OR dsp_canc_ae_day_dsch <> 0
           OR dsp_ae_day_deth <> 0
           OR dsp_canc_ae_day_deth <> 0
           OR dsp_remain <> 0
           OR dsp_bdo <> 0
           OR dsp_vac <> 0
           OR dsp_ip_bed <> 0
           OR dsp_exc <> 0
           OR dsp_dp_bed <> 0
           OR dsp_day_dsch <> 0
           OR dsp_canc_day_dsch <> 0
           OR dsp_day_deth <> 0
           OR dsp_canc_day_deth <> 0;
    pas_return_code
        := 0;
    RETURN;
END ;
$procedure$
;


;ALTER PROCEDURE "hasp_get_ward_stat" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
