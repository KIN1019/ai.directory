-- DROP PROCEDURE hpi.hasp_get_spec_stat(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_spec_stat(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_input_spec character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    var_desc VARCHAR(30);
    var_opening INTEGER;
    var_remain INTEGER;
    var_bdo REAL;
    var_vac INTEGER;
    var_exc INTEGER;
    var_in_day_treated REAL;
    var_inpat_treated REAL;
    var_occ_rate REAL;
    var_bed_comp REAL;
    var_los REAL;
    var_turnover REAL;
    var_dbp REAL;
    var_dba REAL;
    var_deth_1000 REAL;
    var_prev_date TIMESTAMP WITHOUT TIME ZONE;
    var_date TIMESTAMP WITHOUT TIME ZONE;
    var_ward VARCHAR(4);
    var_spec VARCHAR(4);
    var_loc VARCHAR(4);
    var_ip_bed REAL;
    var_dp_bed INTEGER;
    var_prev_spec VARCHAR(4);
    var_prev_remain INTEGER;
    var_spec_count INTEGER;
    var_adm INTEGER;
    var_ae_adm INTEGER;
    var_txin INTEGER;
    var_txout INTEGER;
    var_td_txin INTEGER;
    var_td_txout INTEGER;
    var_dsch INTEGER;
    var_deth INTEGER;
    var_dp_dsch INTEGER;
    var_dp_deth INTEGER;
    var_ae_day_dsch INTEGER;
    var_ae_day_deth INTEGER;
    var_tx_within_spec INTEGER;
    var_canc_adm INTEGER;
    var_canc_ae_adm INTEGER;
    var_canc_txin INTEGER;
    var_canc_txout INTEGER;
    var_canc_td_txin INTEGER;
    var_canc_td_txout INTEGER;
    var_canc_dsch INTEGER;
    var_canc_deth INTEGER;
    var_canc_dp_dsch INTEGER;
    var_canc_dp_deth INTEGER;
    var_canc_ae_day_dsch INTEGER;
    var_canc_ae_day_deth INTEGER;
    var_canc_tx_within_spec INTEGER;
    var_ttl_ip_bed REAL;
    var_ttl_dp_bed INTEGER;
    var_spec_prev_remain INTEGER;
    var_spec_adm INTEGER;
    var_spec_ae_adm INTEGER;
    var_spec_canc_adm INTEGER;
    var_spec_canc_ae_adm INTEGER;
    var_spec_txin INTEGER;
    var_spec_canc_txin INTEGER;
    var_spec_txout INTEGER;
    var_spec_canc_txout INTEGER;
    var_spec_tx_within_spec INTEGER;
    var_spec_canc_tx_within_spec INTEGER;
    var_spec_td_txin INTEGER;
    var_spec_canc_td_txin INTEGER;
    var_spec_td_txout INTEGER;
    var_spec_canc_td_txout INTEGER;
    var_spec_dsch INTEGER;
    var_spec_canc_dsch INTEGER;
    var_spec_deth INTEGER;
    var_spec_canc_deth INTEGER;
    var_spec_ae_day_dsch INTEGER;
    var_spec_canc_ae_day_dsch INTEGER;
    var_spec_ae_day_deth INTEGER;
    var_spec_canc_ae_day_deth INTEGER;
    var_spec_remain INTEGER;
    var_spec_bdo REAL;
    var_spec_dp_bed INTEGER;
    var_spec_dp_dsch INTEGER;
    var_spec_canc_dp_dsch INTEGER;
    var_spec_dp_deth INTEGER;
    var_spec_canc_dp_deth INTEGER;
    var_spec_in_day_treated REAL;
    var_spec_inpat_treated REAL;
    var_spec_los REAL;
    var_hosp_prev_remain INTEGER;
    var_hosp_adm INTEGER;
    var_hosp_ae_adm INTEGER;
    var_hosp_canc_adm INTEGER;
    var_hosp_canc_ae_adm INTEGER;
    var_hosp_txin INTEGER;
    var_hosp_canc_txin INTEGER;
    var_hosp_txout INTEGER;
    var_hosp_canc_txout INTEGER;
    var_hosp_tx_within_spec INTEGER;
    var_hosp_canc_tx_within_spec INTEGER;
    var_hosp_td_txin INTEGER;
    var_hosp_canc_td_txin INTEGER;
    var_hosp_td_txout INTEGER;
    var_hosp_canc_td_txout INTEGER;
    var_hosp_dsch INTEGER;
    var_hosp_canc_dsch INTEGER;
    var_hosp_deth INTEGER;
    var_hosp_canc_deth INTEGER;
    var_hosp_ae_day_dsch INTEGER;
    var_hosp_canc_ae_day_dsch INTEGER;
    var_hosp_ae_day_deth INTEGER;
    var_hosp_canc_ae_day_deth INTEGER;
    var_hosp_remain INTEGER;
    var_hosp_bdo REAL;
    var_hosp_vac REAL;
    var_hosp_ip_bed REAL;
    var_hosp_exc REAL;
    var_hosp_dp_bed INTEGER;
    var_hosp_dp_dsch INTEGER;
    var_hosp_canc_dp_dsch INTEGER;
    var_hosp_dp_deth INTEGER;
    var_hosp_canc_dp_deth INTEGER;
    var_hosp_bed_comp REAL;
    var_hosp_occ_rate REAL;
    var_hosp_in_day_treated REAL;
    var_hosp_inpat_treated REAL;
    var_hosp_los REAL;
    var_hosp_turnover REAL;
    var_hosp_dbp REAL;
    var_hosp_dba REAL;
    var_hosp_deth_1000 REAL;
    stat_loc_csr CURSOR FOR
    SELECT
        stat_code, stat_loc, stat_prev_remain
        FROM t$stat_table
        WHERE stat_loc IS NOT NULL;
    spec_csr CURSOR FOR
    SELECT DISTINCT
        Specialty_code
        FROM Specialty
        WHERE Specialty_code LIKE par_input_spec AND Specialty_code <> 'A&E' AND Hospital_code = par_hosp_code;
    ward_spec_csr CURSOR FOR
    SELECT DISTINCT
        Ward_code
        FROM Ward_specialty
        WHERE Specialty_code = var_spec AND Ward_code <> 'AE01' AND Hospital_code = par_hosp_code;
    ward_spec_tx_csr CURSOR FOR
    SELECT
        Treatment_location, SUM(COALESCE(Admission, 0)), SUM(COALESCE(Admission_thru_AE, 0)), SUM(COALESCE(Transfer_in, 0)), SUM(COALESCE(Transfer_out, 0)), SUM(COALESCE(Transfer_in_from_TD, 0)), SUM(COALESCE(Transfer_out_to_TD, 0)), SUM(COALESCE(Discharge, 0)), SUM(COALESCE(Death, 0)), SUM(COALESCE(AE_day_discharge, 0)), SUM(COALESCE(AE_day_death, 0)), SUM(COALESCE(Day_discharge, 0)), SUM(COALESCE(Day_death, 0)), SUM(COALESCE(Transfer_within_specialty, 0)), SUM(COALESCE(Canc_admission, 0)), SUM(COALESCE(Canc_admission_thru_AE, 0)), SUM(COALESCE(Canc_transfer_in, 0)), SUM(COALESCE(Canc_transfer_out, 0)), SUM(COALESCE(Canc_transfer_in_from_TD, 0)), SUM(COALESCE(Canc_transfer_out_to_TD, 0)), SUM(COALESCE(Canc_discharge, 0)), SUM(COALESCE(Canc_death, 0)), SUM(COALESCE(Canc_AE_day_discharge, 0)), SUM(COALESCE(Canc_AE_day_death, 0)), SUM(COALESCE(Canc_day_discharge, 0)), SUM(COALESCE(Canc_day_death, 0)), SUM(COALESCE(Canc_transfer_within_specialty, 0))
        FROM Ward_spec_tx_adj_view
        WHERE Ward_spec_tx_date = var_date AND Specialty_code = var_spec AND Treatment_location IS NOT NULL AND Specialty_code <> Treatment_location AND Hospital_code = par_hosp_code
        GROUP BY Treatment_location;
    loc_csr CURSOR FOR
    SELECT
        stat_code, stat_loc
        FROM t$stat_table
        WHERE stat_loc IS NOT NULL AND COALESCE(stat_code, 'null') <> COALESCE(stat_loc, 'null');
    sql$rowcount BIGINT;
    display_csr CURSOR FOR
    SELECT
        t$stat_table.stat_code, t$stat_table.stat_loc, t$stat_table.stat_desc, t$stat_table.stat_prev_remain, t$stat_table.stat_adm, t$stat_table.stat_canc_adm, t$stat_table.stat_ae_adm, t$stat_table.stat_canc_ae_adm, t$stat_table.stat_txin, t$stat_table.stat_canc_txin, t$stat_table.stat_txout, t$stat_table.stat_canc_txout, t$stat_table.stat_tx_within_spec, t$stat_table.stat_canc_tx_within_spec, t$stat_table.stat_td_txin, t$stat_table.stat_canc_td_txin, t$stat_table.stat_td_txout, t$stat_table.stat_canc_td_txout, t$stat_table.stat_dsch, t$stat_table.stat_canc_dsch, t$stat_table.stat_deth, t$stat_table.stat_canc_deth, t$stat_table.stat_ae_day_dsch, t$stat_table.stat_canc_ae_day_dsch, t$stat_table.stat_ae_day_deth, t$stat_table.stat_canc_ae_day_deth, t$stat_table.stat_remain, t$stat_table.stat_bdo, t$stat_table.stat_vac, t$stat_table.stat_ip_bed, t$stat_table.stat_exc, t$stat_table.stat_dp_bed, t$stat_table.stat_dp_dsch, t$stat_table.stat_canc_dp_dsch, t$stat_table.stat_dp_deth, t$stat_table.stat_canc_dp_deth, t$stat_table.stat_bed_comp, t$stat_table.stat_in_day_treated, t$stat_table.stat_occ_rate, t$stat_table.stat_los, t$stat_table.stat_turnover, t$stat_table.stat_dbp, t$stat_table.stat_dba, t$stat_table.stat_deth_1000, t$stat_table.stat_inpat_treated
        FROM t$stat_table
        WHERE stat_code <> 'HOME' AND stat_code LIKE par_input_spec AND (stat_adm <> 0 OR stat_canc_adm <> 0 OR stat_ae_adm <> 0 OR stat_canc_ae_adm <> 0 OR stat_txin <> 0 OR stat_canc_txin <> 0 OR stat_txout <> 0 OR stat_canc_txout <> 0 OR stat_tx_within_spec <> 0 OR stat_canc_tx_within_spec <> 0 OR stat_td_txin <> 0 OR stat_canc_td_txin <> 0 OR stat_td_txout <> 0 OR stat_canc_td_txout <> 0 OR stat_dsch <> 0 OR stat_canc_dsch <> 0 OR stat_deth <> 0 OR stat_canc_deth <> 0 OR stat_ae_day_dsch <> 0 OR stat_canc_ae_day_dsch <> 0 OR stat_ae_day_deth <> 0 OR stat_canc_ae_day_deth <> 0 OR stat_remain <> 0 OR stat_bdo <> 0 OR stat_vac <> 0 OR stat_ip_bed <> 0 OR stat_exc <> 0 OR stat_dp_bed <> 0 OR stat_dp_dsch <> 0 OR stat_canc_dp_dsch <> 0 OR stat_dp_deth <> 0 OR stat_canc_dp_deth <> 0)
        ORDER BY stat_code NULLS FIRST, stat_loc NULLS FIRST;
begin
   DROP TABLE IF EXISTS t$stat_table;
   DROP TABLE IF EXISTS t$start_table;
   DROP TABLE IF EXISTS t$dsp_table;
    /*
    parameter name          Description
    	@input_from_date        From date to be processed
    	@input_to_date          To date to be processed
            @input_spec             Required ward code
    */
    /* create temp table for stat report */
    CREATE TEMPORARY TABLE t$stat_table
    (stat_code VARCHAR(4) NULL,
        stat_loc VARCHAR(4) NULL,
        stat_desc VARCHAR(30) NULL,
        stat_prev_remain INTEGER DEFAULT 0 NULL,
        stat_adm INTEGER DEFAULT 0 NULL,
        stat_canc_adm INTEGER DEFAULT 0 NULL,
        stat_ae_adm INTEGER DEFAULT 0 NULL,
        stat_canc_ae_adm INTEGER DEFAULT 0 NULL,
        stat_txin INTEGER DEFAULT 0 NULL,
        stat_canc_txin INTEGER DEFAULT 0 NULL,
        stat_txout INTEGER DEFAULT 0 NULL,
        stat_canc_txout INTEGER DEFAULT 0 NULL,
        stat_tx_within_spec INTEGER DEFAULT 0 NULL,
        stat_canc_tx_within_spec INTEGER DEFAULT 0 NULL,
        stat_td_txin INTEGER DEFAULT 0 NULL,
        stat_canc_td_txin INTEGER DEFAULT 0 NULL,
        stat_td_txout INTEGER DEFAULT 0 NULL,
        stat_canc_td_txout INTEGER DEFAULT 0 NULL,
        stat_dsch INTEGER DEFAULT 0 NULL,
        stat_canc_dsch INTEGER DEFAULT 0 NULL,
        stat_deth INTEGER DEFAULT 0 NULL,
        stat_canc_deth INTEGER DEFAULT 0 NULL,
        stat_ae_day_dsch INTEGER DEFAULT 0 NULL,
        stat_canc_ae_day_dsch INTEGER DEFAULT 0 NULL,
        stat_ae_day_deth INTEGER DEFAULT 0 NULL,
        stat_canc_ae_day_deth INTEGER DEFAULT 0 NULL,
        stat_remain INTEGER DEFAULT 0 NULL,
        stat_bdo REAL DEFAULT 0 NULL,
        stat_vac INTEGER DEFAULT 0 NULL,
        stat_ip_bed REAL DEFAULT 0 NULL,
        stat_exc INTEGER DEFAULT 0 NULL,
        stat_dp_bed INTEGER DEFAULT 0 NULL,
        stat_dp_dsch INTEGER DEFAULT 0 NULL,
        stat_canc_dp_dsch INTEGER DEFAULT 0 NULL,
        stat_dp_deth INTEGER DEFAULT 0 NULL,
        stat_canc_dp_deth INTEGER DEFAULT 0 NULL,
        stat_bed_comp REAL NULL,
        stat_in_day_treated REAL NULL,
        stat_occ_rate REAL NULL,
        stat_los REAL NULL,
        stat_turnover REAL NULL,
        stat_dbp REAL NULL,
        stat_dba REAL NULL,
        stat_deth_1000 REAL NULL,
        stat_inpat_treated REAL NULL);
    CREATE UNIQUE INDEX stat_index ON t$stat_table
        (stat_code, stat_loc);
    /* calc previous remaining of start date */
    /* add Hospital code for HPI by ML on 26.07.1999 */
    CREATE TEMPORARY TABLE t$start_table
    AS
    SELECT
        MAX(Ward_spec_tx_date) AS tx_date, Ward_code AS ward_code, Specialty_code AS spec_code, Treatment_location AS treat_loc
        FROM Ward_spec_tx
        WHERE Ward_spec_tx_date < par_input_from_date AND Hospital_code = par_hosp_code::VARCHAR
        GROUP BY specialty_code, treatment_location, ward_code;
    INSERT INTO t$stat_table (stat_code, stat_loc, stat_prev_remain)
    SELECT
        spec_code, treat_loc, SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) - SUM(COALESCE(Canc_admission, 0)) - SUM(COALESCE(Discharge, 0)) + SUM(COALESCE(Canc_discharge, 0)) + SUM(COALESCE(Transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Transfer_out, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) - SUM(COALESCE(Death, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) + SUM(COALESCE(Canc_transfer_out_to_TD, 0))
        FROM t$start_table t, Ward_spec_tx_adj_view w
        WHERE t.tx_date = w.Ward_spec_tx_date AND t.ward_code = w.ward_code AND t.spec_code = w.specialty_code AND w.Hospital_code = par_hosp_code AND COALESCE(t.treat_loc, 'null') = COALESCE(w.treatment_location, 'null')
        GROUP BY t.spec_code, t.treat_loc;
    /* add hosp code for HPI by ML on 26.07.1999 */
    OPEN stat_loc_csr;
    FETCH stat_loc_csr INTO var_spec, var_loc, var_prev_remain;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF EXISTS (SELECT
            *
            FROM t$stat_table
            WHERE stat_code = var_loc AND stat_loc IS NULL) THEN
            UPDATE t$stat_table
            SET stat_prev_remain = stat_prev_remain + var_prev_remain
                WHERE stat_code = var_loc AND stat_loc IS NULL;
        ELSE
            INSERT INTO t$stat_table (stat_code, stat_loc, stat_prev_remain)
            VALUES (var_loc, NULL, var_prev_remain);
        END IF;
        FETCH stat_loc_csr INTO var_spec, var_loc, var_prev_remain;
    END LOOP;
    CLOSE stat_loc_csr;
    /* add Hospital code for HPI by ML on 26.06.1999 */
    /* add Hospital code for HPI by ML on 26.06.1999 */
    /* Loop by Date */
    SELECT
        par_input_from_date
        INTO var_date;

    WHILE var_date <= par_input_to_date LOOP
        /* Calc ip and dp bed */
        /* Loop By Specialty */
        OPEN spec_csr;
        FETCH spec_csr INTO var_spec;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            /* Treatment location = null */
            SELECT
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                INTO var_ttl_ip_bed, var_ttl_dp_bed, var_prev_remain, var_adm, var_ae_adm, var_txin, var_txout, var_td_txin, var_td_txout, var_dsch, var_deth, var_dp_dsch, var_dp_deth, var_ae_day_dsch, var_ae_day_deth, var_tx_within_spec, var_canc_adm, var_canc_ae_adm, var_canc_txin, var_canc_txout, var_canc_td_txin, var_canc_td_txout, var_canc_dsch, var_canc_deth, var_canc_dp_dsch, var_canc_dp_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_tx_within_spec, var_dp_bed, var_ip_bed, var_bdo, var_vac, var_exc;
            /* Loop by Ward within Specialty */
            OPEN ward_spec_csr;
            FETCH ward_spec_csr INTO var_ward;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
            END) = 0 LOOP
                /* add Hospital code for HPI by ML on 26.07.1999 */
                SELECT
                    Official_bed, Day_bed
                    INTO var_ip_bed, var_dp_bed
                    FROM Ward_specialty
                    WHERE Ward_code = var_ward AND Specialty_code = var_spec AND Effective_date = (SELECT
                        MAX(Effective_date)
                        FROM Ward_specialty
                        WHERE Ward_code = var_ward AND Specialty_code = var_spec AND Effective_date <= var_date AND Hospital_code = par_hosp_code) AND Hospital_code = par_hosp_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount > 0 THEN
                    SELECT
                        var_ttl_ip_bed + var_ip_bed, var_ttl_dp_bed + var_dp_bed
                        INTO var_ttl_ip_bed, var_ttl_dp_bed;
                END IF;
                FETCH ward_spec_csr INTO var_ward;
            END LOOP;
            CLOSE ward_spec_csr;
            /* Calc tx summary */
            SELECT
                COALESCE(SUM(Admission), 0), COALESCE(SUM(Admission_thru_AE), 0), COALESCE(SUM(Transfer_in), 0), COALESCE(SUM(Transfer_out), 0), COALESCE(SUM(Transfer_in_from_TD), 0), COALESCE(SUM(Transfer_out_to_TD), 0), COALESCE(SUM(Discharge), 0), COALESCE(SUM(Death), 0), COALESCE(SUM(AE_day_discharge), 0), COALESCE(SUM(AE_day_death), 0), COALESCE(SUM(Day_discharge), 0), COALESCE(SUM(Day_death), 0), COALESCE(SUM(Transfer_within_specialty), 0), COALESCE(SUM(Canc_admission), 0), COALESCE(SUM(Canc_admission_thru_AE), 0), COALESCE(SUM(Canc_transfer_in), 0), COALESCE(SUM(Canc_transfer_out), 0), COALESCE(SUM(Canc_transfer_in_from_TD), 0), COALESCE(SUM(Canc_transfer_out_to_TD), 0), COALESCE(SUM(Canc_discharge), 0), COALESCE(SUM(Canc_death), 0), COALESCE(SUM(Canc_AE_day_discharge), 0), COALESCE(SUM(Canc_AE_day_death), 0), COALESCE(SUM(Canc_day_discharge), 0), COALESCE(SUM(Canc_day_death), 0), COALESCE(SUM(Canc_transfer_within_specialty), 0)
                INTO var_adm, var_ae_adm, var_txin, var_txout, var_td_txin, var_td_txout, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_dp_dsch, var_dp_deth, var_tx_within_spec, var_canc_adm, var_canc_ae_adm, var_canc_txin, var_canc_txout, var_canc_td_txin, var_canc_td_txout, var_canc_dsch, var_canc_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_dp_dsch, var_canc_dp_deth, var_canc_tx_within_spec
                FROM Ward_spec_tx_adj_view
                WHERE Ward_spec_tx_date = var_date AND
                /* add hosp code for HPI by ML on 26.07.1999 */
                Hospital_code = par_hosp_code AND ((Specialty_code = var_spec AND Treatment_location is NULL) OR Treatment_location = var_spec);
            /* Calc remaining from previous */
            SELECT
                stat_prev_remain
                INTO var_prev_remain
                FROM t$stat_table
                WHERE stat_code = var_spec AND stat_loc is NULL;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        0
                        INTO var_prev_remain;
                    INSERT INTO t$stat_table (stat_code, stat_loc)
                    VALUES (var_spec, NULL);
                END;
            END IF;
            SELECT
                var_prev_remain + var_adm + var_txin + var_td_txin - var_txout - var_td_txout - var_dsch - var_deth - var_canc_adm - var_canc_txin - var_canc_td_txin + var_canc_txout + var_canc_td_txout + var_canc_dsch + var_canc_deth
                INTO var_remain;
            SELECT
                var_remain + var_ae_day_dsch + var_ae_day_deth - var_canc_ae_day_dsch - var_canc_ae_day_deth
                INTO var_bdo;

            IF var_bdo > var_ttl_ip_bed THEN
                SELECT
                    0, var_bdo - var_ttl_ip_bed
                    INTO var_vac, var_exc;
            ELSE
                SELECT
                    0, var_ttl_ip_bed - var_bdo
                    INTO var_exc, var_vac;
            END IF;
            UPDATE t$stat_table
            SET stat_adm = stat_adm + var_adm, stat_canc_adm = stat_canc_adm + var_canc_adm, stat_ae_adm = stat_ae_adm + var_ae_adm, stat_canc_ae_adm = stat_canc_ae_adm + var_canc_ae_adm, stat_txin = stat_txin + var_txin, stat_canc_txin = stat_canc_txin + var_canc_txin, stat_txout = stat_txout + var_txout, stat_canc_txout = stat_canc_txout + var_canc_txout, stat_tx_within_spec = stat_tx_within_spec + var_tx_within_spec, stat_canc_tx_within_spec = stat_canc_tx_within_spec + var_canc_tx_within_spec, stat_td_txin = stat_td_txin + var_td_txin, stat_canc_td_txin = stat_canc_td_txin + var_canc_td_txin, stat_td_txout = stat_td_txout + var_td_txout, stat_canc_td_txout = stat_canc_td_txout + var_canc_td_txout, stat_dsch = stat_dsch + var_dsch, stat_canc_dsch = stat_canc_dsch + var_canc_dsch, stat_deth = stat_deth + var_deth, stat_canc_deth = stat_canc_deth + var_canc_deth, stat_ae_day_dsch = stat_ae_day_dsch + var_ae_day_dsch, stat_canc_ae_day_dsch = stat_canc_ae_day_dsch + var_canc_ae_day_dsch, stat_ae_day_deth = stat_ae_day_deth + var_ae_day_deth, stat_canc_ae_day_deth = stat_canc_ae_day_deth + var_canc_ae_day_deth, stat_remain = stat_remain + var_remain, stat_bdo = stat_bdo + var_bdo, stat_vac = stat_vac + var_vac, stat_ip_bed = stat_ip_bed + var_ttl_ip_bed, stat_exc = stat_exc + var_exc, stat_dp_bed = stat_dp_bed + var_ttl_dp_bed, stat_dp_dsch = stat_dp_dsch + var_dp_dsch, stat_canc_dp_dsch = stat_canc_dp_dsch + var_canc_dp_dsch, stat_dp_deth = stat_dp_deth + var_dp_deth, stat_canc_dp_deth = stat_canc_dp_deth + var_canc_dp_deth
                WHERE stat_code = var_spec AND stat_loc is NULL;

            IF par_input_from_date <> par_input_to_date THEN
                UPDATE t$stat_table
                SET stat_prev_remain = var_remain
                    WHERE stat_code = var_spec AND stat_loc is NULL;
            END IF;
            /* Treatment location not = null */
            SELECT
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                INTO var_ttl_ip_bed, var_ttl_dp_bed, var_prev_remain, var_adm, var_ae_adm, var_txin, var_txout, var_td_txin, var_td_txout, var_dsch, var_deth, var_dp_dsch, var_dp_deth, var_ae_day_dsch, var_ae_day_deth, var_tx_within_spec, var_canc_adm, var_canc_ae_adm, var_canc_txin, var_canc_txout, var_canc_td_txin, var_canc_td_txout, var_canc_dsch, var_canc_deth, var_canc_dp_dsch, var_canc_dp_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_tx_within_spec, var_dp_bed, var_ip_bed, var_bdo, var_vac, var_exc;
            /* Calc tx summary */
            OPEN ward_spec_tx_csr;
            FETCH ward_spec_tx_csr INTO var_loc, var_adm, var_ae_adm, var_txin, var_txout, var_td_txin, var_td_txout, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_dp_dsch, var_dp_deth, var_tx_within_spec, var_canc_adm, var_canc_ae_adm, var_canc_txin, var_canc_txout, var_canc_td_txin, var_canc_td_txout, var_canc_dsch, var_canc_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_dp_dsch, var_canc_dp_deth, var_canc_tx_within_spec;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
            END) = 0 LOOP
                /* Calc remaining from previous */
                SELECT
                    stat_prev_remain
                    INTO var_prev_remain
                    FROM t$stat_table
                    WHERE stat_code = var_spec AND COALESCE(stat_loc, 'null') = COALESCE(var_loc, 'null');
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    BEGIN
                        SELECT
                            0
                            INTO var_prev_remain;
                        INSERT INTO t$stat_table (stat_code, stat_loc)
                        VALUES (var_spec, var_loc);
                    END;
                END IF;
                SELECT
                    var_prev_remain + var_adm + var_txin + var_td_txin - var_txout - var_td_txout - var_dsch - var_deth - var_canc_adm - var_canc_txin - var_canc_td_txin + var_canc_txout + var_canc_td_txout + var_canc_dsch + var_canc_deth
                    INTO var_remain;
                SELECT
                    var_remain + var_ae_day_dsch + var_ae_day_deth - var_canc_ae_day_dsch - var_canc_ae_day_deth
                    INTO var_bdo;
                UPDATE t$stat_table
                SET stat_adm = stat_adm + var_adm, stat_canc_adm = stat_canc_adm + var_canc_adm, stat_ae_adm = stat_ae_adm + var_ae_adm, stat_canc_ae_adm = stat_canc_ae_adm + var_canc_ae_adm, stat_txin = stat_txin + var_txin, stat_canc_txin = stat_canc_txin + var_canc_txin, stat_txout = stat_txout + var_txout, stat_canc_txout = stat_canc_txout + var_canc_txout, stat_tx_within_spec = stat_tx_within_spec + var_tx_within_spec, stat_canc_tx_within_spec = stat_canc_tx_within_spec + var_canc_tx_within_spec, stat_td_txin = stat_td_txin + var_td_txin, stat_canc_td_txin = stat_canc_td_txin + var_canc_td_txin, stat_td_txout = stat_td_txout + var_td_txout, stat_canc_td_txout = stat_canc_td_txout + var_canc_td_txout, stat_dsch = stat_dsch + var_dsch, stat_canc_dsch = stat_canc_dsch + var_canc_dsch, stat_deth = stat_deth + var_deth, stat_canc_deth = stat_canc_deth + var_canc_deth, stat_ae_day_dsch = stat_ae_day_dsch + var_ae_day_dsch, stat_canc_ae_day_dsch = stat_canc_ae_day_dsch + var_canc_ae_day_dsch, stat_ae_day_deth = stat_ae_day_deth + var_ae_day_deth, stat_canc_ae_day_deth = stat_canc_ae_day_deth + var_canc_ae_day_deth, stat_remain = stat_remain + var_remain, stat_bdo = stat_bdo + var_bdo, stat_dp_dsch = stat_dp_dsch + var_dp_dsch, stat_canc_dp_dsch = stat_canc_dp_dsch + var_canc_dp_dsch, stat_dp_deth = stat_dp_deth + var_dp_deth, stat_canc_dp_deth = stat_canc_dp_deth + var_canc_dp_deth
                    WHERE stat_code = var_spec  AND COALESCE(stat_loc, 'null') = COALESCE(var_loc, 'null');

                IF par_input_from_date <> par_input_to_date THEN
                    UPDATE t$stat_table
                    SET stat_prev_remain = var_remain
                        WHERE stat_code = var_spec  AND COALESCE(stat_loc, 'null') = COALESCE(var_loc, 'null');
                END IF;
                FETCH ward_spec_tx_csr INTO var_loc, var_adm, var_ae_adm, var_txin, var_txout, var_td_txin, var_td_txout, var_dsch, var_deth, var_ae_day_dsch, var_ae_day_deth, var_dp_dsch, var_dp_deth, var_tx_within_spec, var_canc_adm, var_canc_ae_adm, var_canc_txin, var_canc_txout, var_canc_td_txin, var_canc_td_txout, var_canc_dsch, var_canc_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth, var_canc_dp_dsch, var_canc_dp_deth, var_canc_tx_within_spec;
            END LOOP;
            CLOSE ward_spec_tx_csr;
            /*
            update #stat_table set
                    stat_remain = stat_prev_remain,
                    stat_bdo = stat_prev_remain
            where stat_code = @spec
            and stat_loc is not null
            and stat_code <> stat_loc
            and stat_adm = 0
            and stat_ae_adm = 0
            and stat_txin = 0
            and stat_txout = 0
            and stat_td_txin = 0
            and stat_td_txout = 0
            and stat_dsch = 0
            and stat_deth = 0
            and stat_canc_adm = 0
            and stat_canc_ae_adm = 0
            and stat_canc_txin = 0
            and stat_canc_txout = 0
            and stat_canc_td_txin = 0
            and stat_canc_td_txout = 0
            and stat_canc_dsch = 0
            and stat_canc_deth = 0
            */
            FETCH spec_csr INTO var_spec;
        END LOOP;
        CLOSE spec_csr;
        OPEN loc_csr;
        FETCH loc_csr INTO var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            /* add Hospital code for HPI by ML on 26.06.1999 */
            IF NOT EXISTS (SELECT
                *
                FROM Ward_spec_tx
                WHERE Ward_spec_tx_date = var_date AND Specialty_code = var_spec AND COALESCE(Treatment_location, 'null') = COALESCE(var_loc, 'null') AND Hospital_code = par_hosp_code) THEN
                UPDATE t$stat_table
                SET stat_remain = stat_remain + stat_prev_remain, stat_bdo = stat_bdo + stat_prev_remain
                    WHERE stat_code = var_spec AND COALESCE(stat_loc, 'null') = COALESCE(var_loc, 'null');
            END IF;
            FETCH loc_csr INTO var_spec, var_loc;
        END LOOP;
        CLOSE loc_csr;
        SELECT
            1 * INTERVAL '1 day' + var_date::TIMESTAMP
            INTO var_date;
    END LOOP;
   
    DELETE FROM t$stat_table
        WHERE stat_loc IS NOT NULL AND stat_prev_remain = 0 AND stat_adm = 0 AND stat_canc_adm = 0 AND stat_ae_adm = 0 AND stat_canc_ae_adm = 0 AND stat_txin = 0 AND stat_canc_txin = 0 AND stat_txout = 0 AND stat_canc_txout = 0 AND stat_tx_within_spec = 0 AND stat_canc_tx_within_spec = 0 AND stat_dsch = 0 AND stat_canc_dsch = 0 AND stat_deth = 0 AND stat_canc_deth = 0 AND stat_td_txin = 0 AND stat_canc_td_txin = 0 AND stat_td_txout = 0 AND stat_canc_td_txout = 0 AND stat_remain = 0 AND stat_vac = 0 AND stat_bdo = 0 AND stat_exc = 0 AND stat_ip_bed = 0 AND stat_dp_bed = 0 AND stat_dp_dsch = 0 AND stat_canc_dp_dsch = 0 AND stat_dp_deth = 0 AND stat_canc_dp_deth = 0 AND stat_ae_day_dsch = 0 AND stat_canc_ae_day_dsch = 0 AND stat_ae_day_deth = 0 AND stat_canc_ae_day_deth = 0;
    DROP INDEX stat_index;
    UPDATE t$stat_table AS a
	SET stat_desc = (
	    SELECT Description
	    FROM Specialty
	    WHERE Specialty_code = a.stat_code
	      AND Effective_date = (
	          SELECT MAX(Effective_date)
	          FROM Specialty
	          WHERE Specialty_code = a.stat_code
	            AND Effective_date <= par_input_to_date
	            AND Hospital_code = par_hosp_code
	      )
	      AND Hospital_code = par_hosp_code
	)
		WHERE a.stat_loc IS NULL;
    UPDATE t$stat_table
    SET stat_bed_comp = stat_ip_bed / (DATE_PART('days', par_input_to_date::TIMESTAMP-par_input_from_date::TIMESTAMP) + 1)
        WHERE stat_loc IS NULL;
    UPDATE t$stat_table
    SET stat_in_day_treated = stat_txout + stat_dsch + stat_deth - (stat_tx_within_spec / 2) + (stat_canc_tx_within_spec / 2) - stat_canc_txout - stat_canc_dsch - stat_canc_deth, stat_inpat_treated = stat_txout + stat_dsch + stat_deth - (stat_tx_within_spec / 2) - stat_canc_txout - stat_canc_dsch - stat_canc_deth + (stat_canc_tx_within_spec / 2) - stat_dp_dsch - stat_dp_deth + stat_canc_dp_dsch + stat_canc_dp_deth;
    /* where stat_loc is null */
    UPDATE t$stat_table
    SET stat_occ_rate = 100 * stat_bdo / stat_ip_bed
        WHERE stat_loc IS NULL AND stat_ip_bed <> 0;
    UPDATE t$stat_table
    SET stat_occ_rate = 0
        WHERE stat_loc IS NULL AND stat_ip_bed = 0;
    UPDATE t$stat_table
    SET stat_turnover = stat_inpat_treated / stat_bed_comp, stat_dba = ABS(stat_vac - stat_exc) / stat_bed_comp
        WHERE stat_loc IS NULL AND stat_bed_comp <> 0;
    UPDATE t$stat_table
    SET stat_turnover = 0, stat_dba = 0
        WHERE stat_loc IS NULL AND stat_bed_comp = 0;
    UPDATE t$stat_table
    SET stat_los = stat_bdo / stat_inpat_treated
        WHERE stat_inpat_treated <> 0;
    UPDATE t$stat_table
    SET stat_los = NULL
        WHERE stat_inpat_treated = 0;
    UPDATE t$stat_table
    SET stat_dbp = ABS(stat_vac - stat_exc) / stat_inpat_treated
        WHERE stat_loc IS NULL AND stat_inpat_treated <> 0;
    UPDATE t$stat_table
    SET stat_dbp = 0
        WHERE stat_loc IS NULL AND stat_inpat_treated = 0;
    UPDATE t$stat_table
    SET
    /*
    stat_deth_1000 = (stat_deth + stat_dp_deth - stat_canc_deth -
            stat_canc_dp_deth) * 1000 / stat_in_day_treated
    where stat_loc is null
    and stat_in_day_treated <>0
    */
    stat_deth_1000 = 1000 * (stat_deth - stat_canc_deth) / stat_in_day_treated
        WHERE stat_loc IS NULL AND stat_in_day_treated <> 0;
    UPDATE t$stat_table
    SET stat_deth_1000 = 0
        WHERE stat_loc IS NULL AND stat_in_day_treated = 0;
    /* if range of dates then set previous remaining to null */
    IF par_input_from_date <> par_input_to_date THEN
        UPDATE t$stat_table
        SET stat_prev_remain = NULL;
    END IF;
    UPDATE t$stat_table
    SET stat_desc = stat_loc
        WHERE stat_loc IS NOT NULL;

    IF par_input_from_date <> par_input_to_date THEN
        BEGIN
            UPDATE t$stat_table
            SET stat_adm = stat_adm - stat_canc_adm, stat_ae_adm = stat_ae_adm - stat_canc_ae_adm, stat_txin = stat_txin - stat_canc_txin, stat_txout = stat_txout - stat_canc_txout, stat_tx_within_spec = stat_tx_within_spec - stat_canc_tx_within_spec, stat_td_txin = stat_td_txin - stat_canc_td_txin, stat_td_txout = stat_td_txout - stat_canc_td_txout, stat_dsch = stat_dsch - stat_canc_dsch, stat_deth = stat_deth - stat_canc_deth, stat_ae_day_dsch = stat_ae_day_dsch - stat_canc_ae_day_dsch, stat_ae_day_deth = stat_ae_day_deth - stat_canc_ae_day_deth, stat_dp_dsch = stat_dp_dsch - stat_canc_dp_dsch, stat_dp_deth = stat_dp_deth - stat_canc_dp_deth;
            UPDATE t$stat_table
            SET stat_canc_adm = 0, stat_canc_ae_adm = 0, stat_canc_txin = 0, stat_canc_txout = 0, stat_canc_tx_within_spec = 0, stat_canc_td_txin = 0, stat_canc_td_txout = 0, stat_canc_dsch = 0, stat_canc_deth = 0, stat_canc_ae_day_dsch = 0, stat_canc_ae_day_deth = 0, stat_canc_dp_dsch = 0, stat_canc_dp_deth = 0;
        END;
    END IF;
    CREATE TEMPORARY TABLE t$dsp_table
    (dsp_code VARCHAR(4) NULL,
        dsp_loc VARCHAR(4) NULL,
        dsp_desc VARCHAR(30) NULL,
        dsp_prev_remain INTEGER NULL,
        dsp_adm INTEGER NULL,
        dsp_canc_adm INTEGER NULL,
        dsp_ae_adm INTEGER NULL,
        dsp_canc_ae_adm INTEGER NULL,
        dsp_txin INTEGER NULL,
        dsp_canc_txin INTEGER NULL,
        dsp_txout INTEGER NULL,
        dsp_canc_txout INTEGER NULL,
        dsp_tx_within_spec INTEGER NULL,
        dsp_canc_tx_within_spec INTEGER NULL,
        dsp_td_txin INTEGER NULL,
        dsp_canc_td_txin INTEGER NULL,
        dsp_td_txout INTEGER NULL,
        dsp_canc_td_txout INTEGER NULL,
        dsp_dsch INTEGER NULL,
        dsp_canc_dsch INTEGER NULL,
        dsp_deth INTEGER NULL,
        dsp_canc_deth INTEGER NULL,
        dsp_ae_day_dsch INTEGER NULL,
        dsp_canc_ae_day_dsch INTEGER NULL,
        dsp_ae_day_deth INTEGER NULL,
        dsp_canc_ae_day_deth INTEGER NULL,
        dsp_remain INTEGER NULL,
        dsp_bdo REAL NULL,
        dsp_vac REAL NULL,
        dsp_ip_bed REAL NULL,
        dsp_exc REAL NULL,
        dsp_dp_bed INTEGER NULL,
        dsp_dp_dsch INTEGER NULL,
        dsp_canc_dp_dsch INTEGER NULL,
        dsp_dp_deth INTEGER NULL,
        dsp_canc_dp_deth INTEGER NULL,
        dsp_bed_comp REAL NULL,
        dsp_in_day_treated REAL NULL,
        dsp_occ_rate REAL NULL,
        dsp_los REAL NULL,
        dsp_turnover REAL NULL,
        dsp_dbp REAL NULL,
        dsp_dba REAL NULL,
        dsp_deth_1000 REAL NULL,
        dsp_inpat_treated REAL NULL);
    OPEN display_csr;
    SELECT
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        INTO var_spec_prev_remain, var_spec_adm, var_spec_canc_adm, var_spec_ae_adm, var_spec_canc_ae_adm, var_spec_txin, var_spec_canc_txin, var_spec_txout, var_spec_canc_txout, var_spec_tx_within_spec, var_spec_canc_tx_within_spec, var_spec_td_txin, var_spec_canc_td_txin, var_spec_td_txout, var_spec_canc_td_txout, var_spec_dsch, var_spec_canc_dsch, var_spec_deth, var_spec_canc_deth, var_spec_ae_day_dsch, var_spec_canc_ae_day_dsch, var_spec_ae_day_deth, var_spec_canc_ae_day_deth, var_spec_remain, var_spec_bdo, var_spec_dp_bed, var_spec_dp_dsch, var_spec_canc_dp_dsch, var_spec_dp_deth, var_spec_canc_dp_deth, var_spec_in_day_treated, var_spec_los, var_spec_count, var_spec_inpat_treated;
    SELECT
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        INTO var_hosp_prev_remain, var_hosp_adm, var_hosp_canc_adm, var_hosp_ae_adm, var_hosp_canc_ae_adm, var_hosp_txin, var_hosp_canc_txin, var_hosp_txout, var_hosp_canc_txout, var_hosp_tx_within_spec, var_hosp_canc_tx_within_spec, var_hosp_td_txin, var_hosp_canc_td_txin, var_hosp_td_txout, var_hosp_canc_td_txout, var_hosp_dsch, var_hosp_canc_dsch, var_hosp_deth, var_hosp_canc_deth, var_hosp_ae_day_dsch, var_hosp_canc_ae_day_dsch, var_hosp_ae_day_deth, var_hosp_canc_ae_day_deth, var_hosp_remain, var_hosp_bdo, var_hosp_vac, var_hosp_ip_bed, var_hosp_exc, var_hosp_dp_bed, var_hosp_dp_dsch, var_hosp_canc_dp_dsch, var_hosp_dp_deth, var_hosp_canc_dp_deth, var_hosp_in_day_treated, var_hosp_inpat_treated, var_hosp_los, var_hosp_dbp, var_hosp_deth_1000;
    FETCH display_csr INTO var_spec, var_loc, var_desc, var_prev_remain, var_adm, var_canc_adm, var_ae_adm, var_canc_ae_adm, var_txin, var_canc_txin, var_txout, var_canc_txout, var_tx_within_spec, var_canc_tx_within_spec, var_td_txin, var_canc_td_txin, var_td_txout, var_canc_td_txout, var_dsch, var_canc_dsch, var_deth, var_canc_deth, var_ae_day_dsch, var_canc_ae_day_dsch, var_ae_day_deth, var_canc_ae_day_deth, var_remain, var_bdo, var_vac, var_ip_bed, var_exc, var_dp_bed, var_dp_dsch, var_canc_dp_dsch, var_dp_deth, var_canc_dp_deth, var_bed_comp, var_in_day_treated, var_occ_rate, var_los, var_turnover, var_dbp, var_dba, var_deth_1000, var_inpat_treated;

    WHILE (SELECT
        (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END)) = 0 LOOP
        IF coalesce(var_spec,'') <> coalesce(var_prev_spec,'') THEN
            BEGIN
                IF var_spec_count > 1 THEN
                    BEGIN
                        IF var_spec_inpat_treated = 0 THEN
                            SELECT
                                NULL
                                INTO var_spec_los;
                        ELSE
                            SELECT
                                var_spec_bdo / var_spec_inpat_treated
                                INTO var_spec_los;
                        END IF;
                        INSERT INTO t$dsp_table
                        VALUES (NULL, NULL, 'Specialty Total', var_spec_prev_remain, var_spec_adm, var_spec_canc_adm, var_spec_ae_adm, var_spec_canc_ae_adm, var_spec_txin, var_spec_canc_txin, var_spec_txout, var_spec_canc_txout, var_spec_tx_within_spec, var_spec_canc_tx_within_spec, var_spec_td_txin, var_spec_canc_td_txin, var_spec_td_txout, var_spec_canc_td_txout, var_spec_dsch, var_spec_canc_dsch, var_spec_deth, var_spec_canc_deth, var_spec_ae_day_dsch, var_spec_canc_ae_day_dsch, var_spec_ae_day_deth, var_spec_canc_ae_day_deth, var_spec_remain, var_spec_bdo, NULL, NULL, NULL, var_spec_dp_bed, var_spec_dp_dsch, var_spec_canc_dp_dsch, var_spec_dp_deth, var_spec_canc_dp_deth, NULL, var_spec_in_day_treated, NULL, var_spec_los, NULL, NULL, NULL, NULL, var_spec_inpat_treated);
                    END;
                END IF;
                SELECT
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    INTO var_spec_prev_remain, var_spec_adm, var_spec_canc_adm, var_spec_ae_adm, var_spec_canc_ae_adm, var_spec_txin, var_spec_canc_txin, var_spec_txout, var_spec_canc_txout, var_spec_tx_within_spec, var_spec_canc_tx_within_spec, var_spec_td_txin, var_spec_canc_td_txin, var_spec_td_txout, var_spec_canc_td_txout, var_spec_dsch, var_spec_canc_dsch, var_spec_deth, var_spec_canc_deth, var_spec_ae_day_dsch, var_spec_canc_ae_day_dsch, var_spec_ae_day_deth, var_spec_canc_ae_day_deth, var_spec_remain, var_spec_bdo, var_spec_dp_bed, var_spec_dp_dsch, var_spec_canc_dp_dsch, var_spec_dp_deth, var_spec_canc_dp_deth, var_spec_in_day_treated, var_spec_los, var_spec_inpat_treated;
                SELECT
                    var_spec, 0
                    INTO var_prev_spec, var_spec_count;
            END;
        END IF;

        IF COALESCE(var_spec, 'null') <> COALESCE(var_loc, 'null') THEN
            BEGIN
                SELECT
                    var_spec_count + 1
                    INTO var_spec_count;
                SELECT
                    var_spec_prev_remain + var_prev_remain, var_spec_adm + var_adm, var_spec_canc_adm + var_canc_adm, var_spec_ae_adm + var_ae_adm, var_spec_canc_ae_adm + var_canc_ae_adm, var_spec_txin + var_txin, var_spec_canc_txin + var_canc_txin, var_spec_txout + var_txout, var_spec_canc_txout + var_canc_txout, var_spec_tx_within_spec + var_tx_within_spec, var_spec_canc_tx_within_spec + var_canc_tx_within_spec, var_spec_td_txin + var_td_txin, var_spec_canc_td_txin + var_canc_td_txin, var_spec_td_txout + var_td_txout, var_spec_canc_td_txout + var_canc_td_txout, var_spec_dsch + var_dsch, var_spec_canc_dsch + var_canc_dsch, var_spec_deth + var_deth, var_spec_canc_deth + var_canc_deth, var_spec_ae_day_dsch + var_ae_day_dsch, var_spec_canc_ae_day_dsch + var_canc_ae_day_dsch, var_spec_ae_day_deth + var_ae_day_deth, var_spec_canc_ae_day_deth + var_canc_ae_day_deth, var_spec_remain + var_remain, var_spec_bdo + var_bdo, var_spec_dp_bed + var_dp_bed, var_spec_dp_dsch + var_dp_dsch, var_spec_canc_dp_dsch + var_canc_dp_dsch, var_spec_dp_deth + var_dp_deth, var_spec_canc_dp_deth + var_canc_dp_deth, var_spec_in_day_treated + var_in_day_treated, var_spec_inpat_treated + var_inpat_treated
                    INTO var_spec_prev_remain, var_spec_adm, var_spec_canc_adm, var_spec_ae_adm, var_spec_canc_ae_adm, var_spec_txin, var_spec_canc_txin, var_spec_txout, var_spec_canc_txout, var_spec_tx_within_spec, var_spec_canc_tx_within_spec, var_spec_td_txin, var_spec_canc_td_txin, var_spec_td_txout, var_spec_canc_td_txout, var_spec_dsch, var_spec_canc_dsch, var_spec_deth, var_spec_canc_deth, var_spec_ae_day_dsch, var_spec_canc_ae_day_dsch, var_spec_ae_day_deth, var_spec_canc_ae_day_deth, var_spec_remain, var_spec_bdo, var_spec_dp_bed, var_spec_dp_dsch, var_spec_canc_dp_dsch, var_spec_dp_deth, var_spec_canc_dp_deth, var_spec_in_day_treated, var_spec_inpat_treated;
            END;
        END IF;

        IF var_loc IS NULL THEN
            BEGIN
                SELECT
                    var_hosp_prev_remain + var_prev_remain, var_hosp_adm + var_adm, var_hosp_canc_adm + var_canc_adm, var_hosp_ae_adm + var_ae_adm, var_hosp_canc_ae_adm + var_canc_ae_adm, var_hosp_txin + var_txin, var_hosp_canc_txin + var_canc_txin, var_hosp_txout + var_txout, var_hosp_canc_txout + var_canc_txout, var_hosp_tx_within_spec + var_tx_within_spec, var_hosp_canc_tx_within_spec + var_canc_tx_within_spec, var_hosp_td_txin + var_td_txin, var_hosp_canc_td_txin + var_canc_td_txin, var_hosp_td_txout + var_td_txout, var_hosp_canc_td_txout + var_canc_td_txout, var_hosp_dsch + var_dsch, var_hosp_canc_dsch + var_canc_dsch, var_hosp_deth + var_deth, var_hosp_canc_deth + var_canc_deth, var_hosp_ae_day_dsch + var_ae_day_dsch, var_hosp_canc_ae_day_dsch + var_canc_ae_day_dsch, var_hosp_ae_day_deth + var_ae_day_deth, var_hosp_canc_ae_day_deth + var_canc_ae_day_deth, var_hosp_remain + var_remain, var_hosp_bdo + var_bdo, var_hosp_dp_bed + var_dp_bed, var_hosp_dp_dsch + var_dp_dsch, var_hosp_canc_dp_dsch + var_canc_dp_dsch, var_hosp_dp_deth + var_dp_deth, var_hosp_canc_dp_deth + var_canc_dp_deth, var_hosp_in_day_treated + var_dsch + var_deth - var_canc_dsch - var_canc_deth, var_hosp_inpat_treated + var_dsch + var_deth - var_canc_dsch - var_canc_deth - var_dp_dsch - var_dp_deth + var_canc_dp_dsch + var_canc_dp_deth, var_hosp_vac + var_vac, var_hosp_ip_bed + var_ip_bed, var_hosp_exc + var_exc
                    INTO var_hosp_prev_remain, var_hosp_adm, var_hosp_canc_adm, var_hosp_ae_adm, var_hosp_canc_ae_adm, var_hosp_txin, var_hosp_canc_txin, var_hosp_txout, var_hosp_canc_txout, var_hosp_tx_within_spec, var_hosp_canc_tx_within_spec, var_hosp_td_txin, var_hosp_canc_td_txin, var_hosp_td_txout, var_hosp_canc_td_txout, var_hosp_dsch, var_hosp_canc_dsch, var_hosp_deth, var_hosp_canc_deth, var_hosp_ae_day_dsch, var_hosp_canc_ae_day_dsch, var_hosp_ae_day_deth, var_hosp_canc_ae_day_deth, var_hosp_remain, var_hosp_bdo, var_hosp_dp_bed, var_hosp_dp_dsch, var_hosp_canc_dp_dsch, var_hosp_dp_deth, var_hosp_canc_dp_deth, var_hosp_in_day_treated, var_hosp_inpat_treated, var_hosp_vac, var_hosp_ip_bed, var_hosp_exc;
            END;
        ELSE
            BEGIN
                IF var_spec_count > 1 THEN
                    SELECT
                        NULL, var_loc
                        INTO var_spec, var_desc;
                END IF;
            END;
        END IF;
        INSERT INTO t$dsp_table
        VALUES (var_spec, var_loc, var_desc, var_prev_remain, var_adm, var_canc_adm, var_ae_adm, var_canc_ae_adm, var_txin, var_canc_txin, var_txout, var_canc_txout, var_tx_within_spec, var_canc_tx_within_spec, var_td_txin, var_canc_td_txin, var_td_txout, var_canc_td_txout, var_dsch, var_canc_dsch, var_deth, var_canc_deth, var_ae_day_dsch, var_canc_ae_day_dsch, var_ae_day_deth, var_canc_ae_day_deth, var_remain, var_bdo, var_vac, var_ip_bed, var_exc, var_dp_bed, var_dp_dsch, var_canc_dp_dsch, var_dp_deth, var_canc_dp_deth, var_bed_comp, var_in_day_treated, var_occ_rate, var_los, var_turnover, var_dbp, var_dba, var_deth_1000, var_inpat_treated);
        FETCH display_csr INTO var_spec, var_loc, var_desc, var_prev_remain, var_adm, var_canc_adm, var_ae_adm, var_canc_ae_adm, var_txin, var_canc_txin, var_txout, var_canc_txout, var_tx_within_spec, var_canc_tx_within_spec, var_td_txin, var_canc_td_txin, var_td_txout, var_canc_td_txout, var_dsch, var_canc_dsch, var_deth, var_canc_deth, var_ae_day_dsch, var_canc_ae_day_dsch, var_ae_day_deth, var_canc_ae_day_deth, var_remain, var_bdo, var_vac, var_ip_bed, var_exc, var_dp_bed, var_dp_dsch, var_canc_dp_dsch, var_dp_deth, var_canc_dp_deth, var_bed_comp, var_in_day_treated, var_occ_rate, var_los, var_turnover, var_dbp, var_dba, var_deth_1000, var_inpat_treated;
    END LOOP;

    IF var_spec_count > 1 THEN
        BEGIN
            IF var_spec_inpat_treated = 0 THEN
                SELECT
                    NULL
                    INTO var_spec_los;
            ELSE
                SELECT
                    var_spec_bdo / var_spec_inpat_treated
                    INTO var_spec_los;
            END IF;
            INSERT INTO t$dsp_table
            VALUES (NULL, NULL, 'Specialty Total', var_spec_prev_remain, var_spec_adm, var_spec_canc_adm, var_spec_ae_adm, var_spec_canc_ae_adm, var_spec_txin, var_spec_canc_txin, var_spec_txout, var_spec_canc_txout, var_spec_tx_within_spec, var_spec_canc_tx_within_spec, var_spec_td_txin, var_spec_canc_td_txin, var_spec_td_txout, var_spec_canc_td_txout, var_spec_dsch, var_spec_canc_dsch, var_spec_deth, var_spec_canc_deth, var_spec_ae_day_dsch, var_spec_canc_ae_day_dsch, var_spec_ae_day_deth, var_spec_canc_ae_day_deth, var_spec_remain, var_spec_bdo, NULL, NULL, NULL, var_spec_dp_bed, var_spec_dp_dsch, var_spec_canc_dp_dsch, var_spec_dp_deth, var_spec_canc_dp_deth, NULL, var_spec_in_day_treated, NULL, var_spec_los, NULL, NULL, NULL, NULL, var_spec_inpat_treated);
        END;
    END IF;

    IF par_input_spec = '%' THEN
        BEGIN
            SELECT
                var_hosp_ip_bed / (DATE_PART('days', par_input_to_date::TIMESTAMP-par_input_from_date::TIMESTAMP) + 1)
                INTO var_hosp_bed_comp;

            IF var_hosp_ip_bed = 0 THEN
                SELECT
                    NULL
                    INTO var_hosp_occ_rate;
            ELSE
                SELECT
                    100 * var_hosp_bdo / var_hosp_ip_bed
                    INTO var_hosp_occ_rate;
            END IF;

            IF var_hosp_inpat_treated = 0 THEN
                SELECT
                    NULL, NULL
                    INTO var_hosp_los, var_hosp_dbp;
            ELSE
                SELECT
                    var_hosp_bdo / var_hosp_inpat_treated, ABS(var_hosp_vac - var_hosp_exc) / var_hosp_inpat_treated
                    INTO var_hosp_los, var_hosp_dbp;
            END IF;

            IF var_hosp_bed_comp = 0 THEN
                SELECT
                    NULL, NULL
                    INTO var_hosp_turnover, var_hosp_dba;
            ELSE
                SELECT
                    var_hosp_inpat_treated / var_hosp_bed_comp, ABS(var_hosp_vac - var_hosp_exc) / var_hosp_bed_comp
                    INTO var_hosp_turnover, var_hosp_dba;
            END IF;

            IF var_hosp_in_day_treated = 0 THEN
                SELECT
                    NULL
                    INTO var_hosp_deth_1000;
            ELSE
                SELECT
                    1000 * (var_hosp_deth - var_hosp_canc_deth) / var_hosp_in_day_treated
                    INTO var_hosp_deth_1000;
            END IF;
            INSERT INTO t$dsp_table
            VALUES (NULL, NULL, 'Hospital Total', var_hosp_prev_remain, var_hosp_adm, var_hosp_canc_adm, var_hosp_ae_adm, var_hosp_canc_ae_adm, var_hosp_txin, var_hosp_canc_txin, var_hosp_txout, var_hosp_canc_txout, var_hosp_tx_within_spec, var_hosp_canc_tx_within_spec, var_hosp_td_txin, var_hosp_canc_td_txin, var_hosp_td_txout, var_hosp_canc_td_txout, var_hosp_dsch, var_hosp_canc_dsch, var_hosp_deth, var_hosp_canc_deth, var_hosp_ae_day_dsch, var_hosp_canc_ae_day_dsch, var_hosp_ae_day_deth, var_hosp_canc_ae_day_deth, var_hosp_remain, var_hosp_bdo, var_hosp_vac, var_hosp_ip_bed, var_hosp_exc, var_hosp_dp_bed, var_hosp_dp_dsch, var_hosp_canc_dp_dsch, var_hosp_dp_deth, var_hosp_canc_dp_deth, var_hosp_bed_comp, var_hosp_in_day_treated, var_hosp_occ_rate, var_hosp_los, var_hosp_turnover, var_hosp_dbp, var_hosp_dba, var_hosp_deth_1000, var_hosp_inpat_treated);
        END;
    END IF;
    CLOSE display_csr;
    INSERT INTO t$dsp_table
    SELECT
        t$stat_table.stat_code, t$stat_table.stat_loc, t$stat_table.stat_desc, t$stat_table.stat_prev_remain, t$stat_table.stat_adm, t$stat_table.stat_canc_adm, t$stat_table.stat_ae_adm, t$stat_table.stat_canc_ae_adm, t$stat_table.stat_txin, t$stat_table.stat_canc_txin, t$stat_table.stat_txout, t$stat_table.stat_canc_txout, t$stat_table.stat_tx_within_spec, t$stat_table.stat_canc_tx_within_spec, t$stat_table.stat_td_txin, t$stat_table.stat_canc_td_txin, t$stat_table.stat_td_txout, t$stat_table.stat_canc_td_txout, t$stat_table.stat_dsch, t$stat_table.stat_canc_dsch, t$stat_table.stat_deth, t$stat_table.stat_canc_deth, t$stat_table.stat_ae_day_dsch, t$stat_table.stat_canc_ae_day_dsch, t$stat_table.stat_ae_day_deth, t$stat_table.stat_canc_ae_day_deth, t$stat_table.stat_remain, t$stat_table.stat_bdo, t$stat_table.stat_vac, t$stat_table.stat_ip_bed, t$stat_table.stat_exc, t$stat_table.stat_dp_bed, t$stat_table.stat_dp_dsch, t$stat_table.stat_canc_dp_dsch, t$stat_table.stat_dp_deth, t$stat_table.stat_canc_dp_deth, t$stat_table.stat_bed_comp, t$stat_table.stat_in_day_treated, t$stat_table.stat_occ_rate, t$stat_table.stat_los, t$stat_table.stat_turnover, t$stat_table.stat_dbp, t$stat_table.stat_dba, t$stat_table.stat_deth_1000, t$stat_table.stat_inpat_treated
        FROM t$stat_table
        WHERE stat_code = 'HOME';
    DROP TABLE t$stat_table;
    /*
    if @input_from_date <> @input_to_date
    begin
            update #dsp_table set
                    dsp_adm = dsp_adm - dsp_canc_adm,
                    dsp_ae_adm = dsp_ae_adm - dsp_canc_ae_adm,
                    dsp_txin = dsp_txin - dsp_canc_txin,
                    dsp_txout = dsp_txout - dsp_canc_txout,
                    dsp_tx_within_spec = dsp_tx_within_spec - dsp_canc_tx_within_spec,
                    dsp_td_txin = dsp_td_txin - dsp_canc_td_txin,
                    dsp_td_txout = dsp_td_txout - dsp_canc_td_txout,
                    dsp_dsch = dsp_dsch - dsp_canc_dsch,
                    dsp_deth = dsp_deth - dsp_canc_deth,
                    dsp_ae_day_dsch = dsp_ae_day_dsch - dsp_canc_ae_day_dsch,
                    dsp_ae_day_deth = dsp_ae_day_deth - dsp_canc_ae_day_deth,
                    dsp_dp_dsch = dsp_dp_dsch - dsp_canc_dp_dsch,
                    dsp_dp_deth = dsp_dp_deth - dsp_canc_dp_deth
    
            update #dsp_table set
                    dsp_canc_adm = 0,
                    dsp_canc_ae_adm = 0,
                    dsp_canc_txin = 0,
                    dsp_canc_txout = 0,
                    dsp_canc_tx_within_spec = 0,
                    dsp_canc_td_txin = 0,
                    dsp_canc_td_txout = 0,
                    dsp_canc_dsch = 0,
                    dsp_canc_deth = 0,
                    dsp_canc_ae_day_dsch = 0,
                    dsp_canc_ae_day_deth = 0,
                    dsp_canc_dp_dsch = 0,
                    dsp_canc_dp_deth = 0
    end
    */
    /* return temp table to client */
    OPEN p_refcur FOR
    SELECT
        t$dsp_table.dsp_code, t$dsp_table.dsp_loc, t$dsp_table.dsp_desc, t$dsp_table.dsp_prev_remain, t$dsp_table.dsp_adm, t$dsp_table.dsp_canc_adm, t$dsp_table.dsp_ae_adm, t$dsp_table.dsp_canc_ae_adm, t$dsp_table.dsp_txin, t$dsp_table.dsp_canc_txin, t$dsp_table.dsp_txout, t$dsp_table.dsp_canc_txout, t$dsp_table.dsp_tx_within_spec, t$dsp_table.dsp_canc_tx_within_spec, t$dsp_table.dsp_td_txin, t$dsp_table.dsp_canc_td_txin, t$dsp_table.dsp_td_txout, t$dsp_table.dsp_canc_td_txout, t$dsp_table.dsp_dsch, t$dsp_table.dsp_canc_dsch, t$dsp_table.dsp_deth, t$dsp_table.dsp_canc_deth, t$dsp_table.dsp_ae_day_dsch, t$dsp_table.dsp_canc_ae_day_dsch, t$dsp_table.dsp_ae_day_deth, t$dsp_table.dsp_canc_ae_day_deth, t$dsp_table.dsp_remain, t$dsp_table.dsp_bdo, t$dsp_table.dsp_vac, t$dsp_table.dsp_ip_bed, t$dsp_table.dsp_exc, t$dsp_table.dsp_dp_bed, t$dsp_table.dsp_dp_dsch, t$dsp_table.dsp_canc_dp_dsch, t$dsp_table.dsp_dp_deth, t$dsp_table.dsp_canc_dp_deth, t$dsp_table.dsp_bed_comp, t$dsp_table.dsp_in_day_treated, t$dsp_table.dsp_occ_rate, t$dsp_table.dsp_los, t$dsp_table.dsp_turnover, t$dsp_table.dsp_dbp, t$dsp_table.dsp_dba, t$dsp_table.dsp_deth_1000, t$dsp_table.dsp_inpat_treated
        FROM t$dsp_table
        WHERE dsp_adm <> 0 OR dsp_canc_adm <> 0 OR dsp_ae_adm <> 0 OR dsp_canc_ae_adm <> 0 OR dsp_txin <> 0 OR dsp_canc_txin <> 0 OR dsp_txout <> 0 OR dsp_canc_txout <> 0 OR dsp_tx_within_spec <> 0 OR dsp_canc_tx_within_spec <> 0 OR dsp_td_txin <> 0 OR dsp_canc_td_txin <> 0 OR dsp_td_txout <> 0 OR dsp_canc_td_txout <> 0 OR dsp_dsch <> 0 OR dsp_canc_dsch <> 0 OR dsp_deth <> 0 OR dsp_canc_deth <> 0 OR dsp_ae_day_dsch <> 0 OR dsp_canc_ae_day_dsch <> 0 OR dsp_ae_day_deth <> 0 OR dsp_canc_ae_day_deth <> 0 OR dsp_remain <> 0 OR dsp_bdo <> 0 OR dsp_vac <> 0 OR dsp_ip_bed <> 0 OR dsp_exc <> 0 OR dsp_dp_bed <> 0 OR dsp_dp_dsch <> 0 OR dsp_canc_dp_dsch <> 0 OR dsp_dp_deth <> 0 OR dsp_canc_dp_deth <> 0;
    pas_return_code := 0;
    RETURN;

    /*
    
    DROP TABLE IF EXISTS t$stat_table;
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
    
    DROP TABLE IF EXISTS t$dsp_table;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;



;ALTER PROCEDURE "hasp_get_spec_stat" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
