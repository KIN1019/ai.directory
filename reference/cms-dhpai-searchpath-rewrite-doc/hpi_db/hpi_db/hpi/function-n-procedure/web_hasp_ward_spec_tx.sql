-- DROP PROCEDURE web_hasp_ward_spec_tx(inout int4, in varchar, in timestamp, in timestamp, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE web_hasp_ward_spec_tx(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_ward character varying, IN par_input_spec character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* -- add hosp code for hpi by ML on 27.07.1999 -- */
DECLARE
    result_str_value  VARCHAR(256);
    result_int_value  INTEGER;
    var_error         INTEGER;
    var_rowcount      INTEGER;
    var_errarg        VARCHAR(80);
    var_ward          VARCHAR(4);
    var_spec          VARCHAR(4);
    var_cnt           INTEGER;
    var_type          VARCHAR(3);
    var_from_date     TIMESTAMP WITHOUT TIME ZONE;
    var_to_date       TIMESTAMP WITHOUT TIME ZONE;
    var_remain        INTEGER;
    var_prev_ward     VARCHAR(4);
    var_prev_spec     VARCHAR(4);
    var_in_out        INTEGER;
    var_adm           INTEGER;
    var_xin           INTEGER;
    var_xout          INTEGER;
    var_dsch          INTEGER;
    var_deth          INTEGER;
    var_td_xin        INTEGER;
    var_td_xout       INTEGER;
    var_aed_dsch      INTEGER;
    var_aed_deth      INTEGER;
    var_dp_dsch       INTEGER;
    var_dp_deth       INTEGER;
    var_tx_within_ws  INTEGER;
    var_inpatient_bda INTEGER;
    tx_csr CURSOR FOR
        SELECT Ward_code,
               Specialty_code,
               SUM(COALESCE(Admission, 0)) - SUM(COALESCE(Canc_admission, 0)),
               SUM(COALESCE(Transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in, 0)),
               SUM(COALESCE(Transfer_out, 0)) - SUM(COALESCE(Canc_transfer_out, 0)),
               SUM(COALESCE(Discharge, 0)) - SUM(COALESCE(Canc_discharge, 0)),
               SUM(COALESCE(Death, 0)) - SUM(COALESCE(Canc_death, 0)),
               SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)),
               SUM(COALESCE(Transfer_out_to_TD, 0)) - SUM(COALESCE(Canc_transfer_out_to_TD, 0)),
               SUM(COALESCE(AE_day_discharge, 0)) - SUM(COALESCE(Canc_AE_day_discharge, 0)),
               SUM(COALESCE(AE_day_death, 0)) - SUM(COALESCE(Canc_AE_day_death, 0)),
               SUM(COALESCE(Day_discharge, 0)) - SUM(COALESCE(Canc_day_discharge, 0)),
               SUM(COALESCE(Day_death, 0)) - SUM(COALESCE(Canc_day_death, 0))
        FROM Ward_spec_tx_adj_view
        WHERE Ward_spec_tx_date >= var_from_date
          AND Ward_spec_tx_date < var_to_date
          AND Hospital_code = par_hosp_code
        GROUP BY Ward_code, Specialty_code;
    day_csr CURSOR FOR
        SELECT Ward_code,
               Specialty_code,
               Official_bed
        FROM t$temp_day_table;
BEGIN
	IF date_part('days' , par_input_to_date - par_input_from_date) > 180 THEN
		SET LOCAL temp_buffers = '64MB';
	END IF;

    /* -- add hosp code for hpi by ML on 27.07.1999 -- */
    DROP TABLE IF EXISTS t$dsp_table;
    CREATE TEMPORARY TABLE t$dsp_table
    (
        dsp_ward          VARCHAR(4),
        dsp_spec          VARCHAR(4),
        dsp_prev_remain   INTEGER NULL,
        dsp_adm           INTEGER NULL,
        dsp_txin          INTEGER NULL,
        dsp_txout         INTEGER NULL,
        dsp_tx_within_ws  INTEGER NULL,
        dsp_dsch          INTEGER NULL,
        dsp_deth          INTEGER NULL,
        dsp_td_txin       INTEGER NULL,
        dsp_td_txout      INTEGER NULL,
        dsp_aed_dsch      INTEGER NULL,
        dsp_aed_deth      INTEGER NULL,
        dsp_remain        INTEGER NULL,
        dsp_bdo           INTEGER NULL,
        dsp_dp_dsch       INTEGER NULL,
        dsp_dp_deth       INTEGER NULL,
        dsp_inpatient_bda INTEGER NULL)    
       ;
    /* dsp_remain int null) */
    
--  	CREATE UNIQUE INDEX dsp_index ON t$dsp_table(dsp_ward, dsp_spec);
  	CREATE INDEX dsp_index ON t$dsp_table(dsp_ward, dsp_spec);
  
  	IF date_part('days' , par_input_to_date - par_input_from_date) > 180 THEN
		ALTER TABLE t$dsp_table SET (fillfactor = 10);
	END IF;

    /* calc previous remaining of start date */
    /* -- add hosp code for hpi by ML on 27.07.1999 -- */
    DROP TABLE IF EXISTS t$start_table;
    CREATE TEMPORARY TABLE t$start_table
    AS
    SELECT MAX(Ward_spec_tx_date) AS tx_date,
           Ward_code              AS ward_code,
           Specialty_code         AS spec_code,
           Treatment_location     AS treat_loc
    FROM Ward_spec_tx
    WHERE Ward_spec_tx_date < par_input_from_date
      AND Hospital_code = par_hosp_code::VARCHAR
    GROUP BY specialty_code, treatment_location, ward_code;

    INSERT INTO t$dsp_table (dsp_ward, dsp_spec, dsp_prev_remain)
    SELECT t1.ward_code,
           t1.spec_code,
           SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) - SUM(COALESCE(Canc_admission, 0)) -
           SUM(COALESCE(Discharge, 0)) + SUM(COALESCE(Canc_discharge, 0)) + SUM(COALESCE(Transfer_in, 0)) -
           SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Transfer_out, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) -
           SUM(COALESCE(Death, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) -
           SUM(COALESCE(Canc_transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) +
           SUM(COALESCE(Canc_transfer_out_to_TD, 0))
    FROM t$start_table t1,
         Ward_spec_tx_adj_view t2
    WHERE t1.tx_date = t2.Ward_spec_tx_date
      AND t1.ward_code = t2.ward_code
      AND t1.spec_code = t2.specialty_code
      AND COALESCE(t1.treat_loc, 'null') = COALESCE(t2.treatment_location, 'null')
      AND Hospital_code = par_hosp_code
    GROUP BY t1.ward_code, t1.spec_code;
    /* -- add hosp code for hpi by ML on 27.07.1999 -- */
    UPDATE t$dsp_table
    SET dsp_remain        = 0,
        dsp_adm           = 0,
        dsp_txin          = 0,
        dsp_txout         = 0,
        dsp_dsch          = 0,
        dsp_deth          = 0,
        dsp_td_txin       = 0,
        dsp_td_txout      = 0,
        dsp_aed_dsch      = 0,
        dsp_aed_deth      = 0,
        dsp_dp_dsch       = 0,
        dsp_dp_deth       = 0,
        dsp_tx_within_ws  = 0,
        dsp_inpatient_bda = 0;
    /* dsp_td_txin = 0, dsp_td_txout = 0 */
    DROP TABLE t$start_table;
    /* loop for each day in @input_from_date and @input_to_date */
    SELECT par_input_from_date,
           1 * INTERVAL '1 day' + par_input_from_date::TIMESTAMP
    INTO var_from_date, var_to_date;
   
    WHILE var_from_date <= par_input_to_date
        LOOP
	        
            OPEN tx_csr;
            SELECT NULL,
                   NULL
            INTO var_prev_ward, var_prev_spec;
            /* fetch tx_csr into @ward, @spec, @type, @cnt */
            FETCH tx_csr INTO var_ward, var_spec, var_adm, var_xin, var_xout, var_dsch, var_deth, var_td_xin, var_td_xout, var_aed_dsch, var_aed_deth, var_dp_dsch, var_dp_deth;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0
                LOOP
                    IF NOT EXISTS (SELECT 1
                                   FROM t$dsp_table
                                   WHERE dsp_ward = var_ward
                                     AND dsp_spec = var_spec) THEN
                        BEGIN
                            INSERT INTO t$dsp_table
                            VALUES (var_ward, var_spec, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                            /* (@ward, @spec, 0,0,0,0,0,0,0,0,0) */
                        END;
                    END IF;

                    IF (coalesce(var_ward, 'null') <> coalesce(var_prev_ward, 'null')
                        OR coalesce(var_spec, 'null') <> coalesce(var_prev_spec, 'null')) AND
                       (var_prev_ward IS NOT NULL AND var_prev_spec IS NOT NULL) THEN
                        BEGIN
                            SELECT var_remain + var_in_out
                            INTO var_remain;

                            UPDATE t$dsp_table
                            SET dsp_remain = dsp_remain + var_remain
                            WHERE dsp_ward = var_prev_ward
                              AND dsp_spec = var_prev_spec;

                            IF par_input_from_date <> par_input_to_date THEN
                                UPDATE t$dsp_table
                                SET dsp_prev_remain = var_remain
                                WHERE dsp_ward = var_prev_ward
                                  AND dsp_spec = var_prev_spec;
                            END IF;
                        END;
                    END IF;

                    IF coalesce(var_ward, 'null') <> coalesce(var_prev_ward, 'null')
                        OR coalesce(var_spec, 'null') <> coalesce(var_prev_spec, 'null') THEN
                        BEGIN
                            SELECT dsp_prev_remain
                            -- INTO var_remain
                            INTO result_str_value
                            FROM t$dsp_table
                            WHERE dsp_ward = var_ward
                              AND dsp_spec = var_spec;
                            IF FOUND THEN
                                var_remain := result_str_value;
                            END IF;

                            SELECT 0,
                                   var_ward,
                                   var_spec
                            INTO var_in_out, var_prev_ward, var_prev_spec;
                        END;
                    END IF;

                    SELECT COUNT(*)
                    INTO var_tx_within_ws
                    FROM Transaction_log
                    WHERE Transaction_datetime >= var_from_date
                      AND Transaction_datetime < var_to_date
                      AND Transaction_type LIKE '14_'
                      AND Cancel_flag IS NULL
                      AND From_ward_code = var_ward
                      AND From_specialty_code = var_spec
                      AND From_ward_code = To_ward_code
                      AND From_specialty_code = To_specialty_code
                      AND Hospital_code = par_hosp_code;
                    /* -- add hosp code for HPI by ML on 27.07.1999 -- */
                    UPDATE t$dsp_table
                    SET dsp_adm          = dsp_adm + var_adm,
                        dsp_txin         = dsp_txin + var_xin,
                        dsp_txout        = dsp_txout + var_xout,
                        dsp_dsch         = dsp_dsch + var_dsch,
                        dsp_deth         = dsp_deth + var_deth,
                        dsp_td_txin      = dsp_td_txin + var_td_xin,
                        dsp_td_txout     = dsp_td_txout + var_td_xout,
                        dsp_aed_dsch     = dsp_aed_dsch + var_aed_dsch,
                        dsp_aed_deth     = dsp_aed_deth + var_aed_deth,
                        dsp_dp_dsch      = dsp_dp_dsch + var_dp_dsch,
                        dsp_dp_deth      = dsp_dp_deth + var_dp_deth,
                        dsp_tx_within_ws = dsp_tx_within_ws + var_tx_within_ws
                    WHERE dsp_ward = var_ward
                      AND dsp_spec = var_spec;
                    SELECT var_adm + var_xin - var_xout - var_dsch - var_deth + var_td_xin - var_td_xout
                    INTO var_in_out;
                    /* fetch tx_csr into @ward, @spec, @type, @cnt */
                    FETCH tx_csr INTO var_ward, var_spec, var_adm, var_xin, var_xout, var_dsch, var_deth, var_td_xin, var_td_xout, var_aed_dsch, var_aed_deth, var_dp_dsch, var_dp_deth;
                END LOOP;
            CLOSE tx_csr;
           
            SELECT var_remain + var_in_out
            INTO var_remain;
            UPDATE t$dsp_table
            SET dsp_remain = dsp_remain + var_remain
            WHERE dsp_ward = var_prev_ward
              AND dsp_spec = var_prev_spec;

            IF par_input_from_date <> par_input_to_date THEN
                UPDATE t$dsp_table
                SET dsp_prev_remain = var_remain
                WHERE dsp_ward = var_prev_ward
                  AND dsp_spec = var_prev_spec;
            END IF;
            /*
            update #dsp_table set
            dsp_remain = dsp_remain + dsp_prev_remain
            from #dsp_table d
            where not exists
            (select * from #tx_table
                    where tx_ward = d.dsp_ward
                    and tx_spec = d.dsp_spec)
            */
            UPDATE t$dsp_table AS d
            SET dsp_remain = dsp_remain + dsp_prev_remain
            WHERE NOT EXISTS (SELECT 1
                              FROM Ward_spec_tx
                              WHERE Ward_code = d.dsp_ward
                                AND Specialty_code = d.dsp_spec
                                AND Ward_spec_tx_date >= var_from_date
                                AND Ward_spec_tx_date < var_to_date
                                AND Hospital_code = par_hosp_code);
          	
            /* -- add hosp code for HPI by ML on 27.07.1999 -- */

            /* ********************************************* */

            /* cal. BDA by ward, by specialty */

            /* ********************************************* */
            --DROP TABLE IF EXISTS t$temp_day_table;
            CREATE TEMPORARY TABLE t$temp_day_table
            AS
            SELECT DISTINCT
                ON (Ward_code, Specialty_code) Effective_date,
                                               Ward_code,
                                               Specialty_code,
                                               Official_bed
            FROM (SELECT Effective_date,
                         Ward_code,
                         Specialty_code,
                         Official_bed,
                         MAX(Effective_date) OVER (PARTITION BY Ward_code, Specialty_code) AS MaxDate
                  FROM Ward_specialty
                  WHERE Effective_date < var_to_date
                    AND Ward_code LIKE par_input_ward
                    AND Specialty_code LIKE par_input_spec) AS subquery
            WHERE Effective_date = MaxDate
            ORDER BY Ward_code,
                     Specialty_code;

            OPEN day_csr;
            FETCH day_csr INTO var_ward, var_spec, var_inpatient_bda;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
                END) = 0
                LOOP
                    IF NOT EXISTS (SELECT 1
                                   FROM t$dsp_table
                                   WHERE dsp_ward = var_ward
                                     AND dsp_spec = var_spec) THEN
                        BEGIN
                            IF var_inpatient_bda > 0 THEN
                                INSERT INTO t$dsp_table
                                VALUES (var_ward, var_spec, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        var_inpatient_bda);
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            UPDATE t$dsp_table
                            /* --set dsp_inpatient_bda = @inpatient_bda */
                            SET dsp_inpatient_bda = dsp_inpatient_bda + var_inpatient_bda
                            WHERE dsp_ward = var_ward
                              AND dsp_spec = var_spec;
                        END;
                    END IF;
                    FETCH day_csr INTO var_ward, var_spec, var_inpatient_bda;
                END LOOP;
            CLOSE day_csr;
           
            DROP TABLE t$temp_day_table;
            /* ********************************************* */
            /* cal. BDA by ward, by specialty */
            /* ********************************************* */
            SELECT 1 * INTERVAL '1 day' + var_from_date::TIMESTAMP,
                   1 * INTERVAL '1 day' + var_to_date::TIMESTAMP
            INTO var_from_date, var_to_date;
        END LOOP;
    
    UPDATE t$dsp_table
    SET dsp_bdo = dsp_remain + dsp_aed_dsch + dsp_aed_deth;

    DROP TABLE IF EXISTS t$rep_table;
    CREATE TEMPORARY TABLE t$rep_table
    (
        rep_ward          VARCHAR(5),
        rep_spec          VARCHAR(5),
        rep_prev_remain   INTEGER NULL,
        rep_adm           INTEGER NULL,
        rep_txin          INTEGER NULL,
        rep_txout         INTEGER NULL,
        rep_tx_within_ws  INTEGER NULL,
        rep_dsch          INTEGER NULL,
        rep_deth          INTEGER NULL,
        rep_td_txin       INTEGER NULL,
        /* rep_td_txout int, rep_remain int) */
        rep_td_txout      INTEGER NULL,
        rep_aed_dsch      INTEGER NULL,
        rep_aed_deth      INTEGER NULL,
        rep_remain        INTEGER NULL,
        rep_bdo           INTEGER NULL,
        rep_dp_dsch       INTEGER NULL,
        rep_dp_deth       INTEGER NULL,
        rep_inpatient_bda INTEGER NULL
    );
    /* --20170912, create #rep_index otherwise the final ordering would be a bit different from before change image */
    /* --since #rep_table is updated below. Without this index, the updated record will be moved to last */
    /* --create unique index #rep_index on #rep_table(rep_ward, rep_spec) */
    /* Adaptive Server has expanded all '*' elements in the following statement */
    INSERT INTO t$rep_table
    SELECT t$dsp_table.dsp_ward,
           t$dsp_table.dsp_spec,
           t$dsp_table.dsp_prev_remain,
           t$dsp_table.dsp_adm,
           t$dsp_table.dsp_txin,
           t$dsp_table.dsp_txout,
           t$dsp_table.dsp_tx_within_ws,
           t$dsp_table.dsp_dsch,
           t$dsp_table.dsp_deth,
           t$dsp_table.dsp_td_txin,
           t$dsp_table.dsp_td_txout,
           t$dsp_table.dsp_aed_dsch,
           t$dsp_table.dsp_aed_deth,
           t$dsp_table.dsp_remain,
           t$dsp_table.dsp_bdo,
           t$dsp_table.dsp_dp_dsch,
           t$dsp_table.dsp_dp_deth,
           t$dsp_table.dsp_inpatient_bda
    FROM t$dsp_table
    WHERE coalesce(dsp_ward, 'null') <> 'HOME'
      AND coalesce(dsp_spec, 'null') <> 'HOME'
    ORDER BY dsp_ward NULLS FIRST, dsp_spec NULLS FIRST;

    IF par_input_ward = '%' AND par_input_spec = '%' THEN
        INSERT INTO t$rep_table
        SELECT 'HOSP.',
               'TOTAL',
               SUM(dsp_prev_remain),
               SUM(dsp_adm),
               SUM(dsp_txin),
               SUM(dsp_txout),
               SUM(dsp_tx_within_ws),
               SUM(dsp_dsch),
               SUM(dsp_deth),
               SUM(dsp_td_txin),
               SUM(dsp_td_txout),
               SUM(dsp_aed_dsch),
               SUM(dsp_aed_deth),
            /* sum(dsp_remain) */
               SUM(dsp_remain),
               SUM(dsp_bdo),
               SUM(dsp_dp_dsch),
               SUM(dsp_dp_deth),
               SUM(dsp_inpatient_bda)
        FROM t$dsp_table
        WHERE coalesce(dsp_ward, 'null') <> 'HOME'
          AND coalesce(dsp_spec, 'null') <> 'HOME';
    END IF;
    /* Adaptive Server has expanded all '*' elements in the following statement */
    INSERT INTO t$rep_table
    SELECT t$dsp_table.dsp_ward,
           t$dsp_table.dsp_spec,
           t$dsp_table.dsp_prev_remain,
           t$dsp_table.dsp_adm,
           t$dsp_table.dsp_txin,
           t$dsp_table.dsp_txout,
           t$dsp_table.dsp_tx_within_ws,
           t$dsp_table.dsp_dsch,
           t$dsp_table.dsp_deth,
           t$dsp_table.dsp_td_txin,
           t$dsp_table.dsp_td_txout,
           t$dsp_table.dsp_aed_dsch,
           t$dsp_table.dsp_aed_deth,
           t$dsp_table.dsp_remain,
           t$dsp_table.dsp_bdo,
           t$dsp_table.dsp_dp_dsch,
           t$dsp_table.dsp_dp_deth,
           t$dsp_table.dsp_inpatient_bda
    FROM t$dsp_table
    WHERE dsp_ward = 'HOME'
      AND dsp_spec = 'HOME';

    IF par_input_from_date <> par_input_to_date THEN
        UPDATE t$rep_table
        SET rep_prev_remain = NULL;
    END IF;
   
    /* Adaptive Server has expanded all '*' elements in the following statement */
    OPEN p_refcur FOR
        SELECT t$rep_table.rep_ward,
               t$rep_table.rep_spec,
               t$rep_table.rep_prev_remain,
               t$rep_table.rep_adm,
               t$rep_table.rep_txin,
               t$rep_table.rep_txout,
               t$rep_table.rep_tx_within_ws,
               t$rep_table.rep_dsch,
               t$rep_table.rep_deth,
               t$rep_table.rep_td_txin,
               t$rep_table.rep_td_txout,
               t$rep_table.rep_aed_dsch,
               t$rep_table.rep_aed_deth,
               t$rep_table.rep_remain,
               t$rep_table.rep_bdo,
               t$rep_table.rep_dp_dsch,
               t$rep_table.rep_dp_deth,
               t$rep_table.rep_inpatient_bda
        FROM t$rep_table
        WHERE (rep_adm <> 0 OR rep_txin <> 0 OR rep_txout <> 0 OR rep_td_txin <> 0 OR rep_td_txout <> 0 OR
               rep_dsch <> 0 OR rep_deth <> 0 OR rep_aed_dsch <> 0 OR rep_aed_deth <> 0 OR rep_bdo <> 0 OR
               rep_dp_dsch <> 0 OR rep_dp_deth <> 0 OR rep_tx_within_ws <> 0 OR rep_remain <> 0 OR
               rep_inpatient_bda <> 0)
          AND rep_ward LIKE par_input_ward
          AND rep_spec LIKE par_input_spec;
    pas_return_code := 0;
   
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_ward_spec_tx" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
