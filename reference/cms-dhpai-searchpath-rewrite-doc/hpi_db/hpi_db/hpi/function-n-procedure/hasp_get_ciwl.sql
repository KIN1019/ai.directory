-- DROP PROCEDURE hpi.hasp_get_ciwl(inout int4, in varchar, in timestamp, in timestamp);

CREATE OR REPLACE PROCEDURE hasp_get_ciwl(INOUT pas_return_code integer, IN par_hosp character varying, IN par_from_date timestamp without time zone, IN par_to_date timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_today TIMESTAMP WITHOUT TIME ZONE;
    var_count INTEGER;
    var_bdo INTEGER;
    var_spec VARCHAR(8);
    var_case VARCHAR(24);
    var_adm_date TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_move_date TIMESTAMP WITHOUT TIME ZONE;
    var_move_type VARCHAR(2);
    var_prev_date TIMESTAMP WITHOUT TIME ZONE;
    var_prev_type VARCHAR(2);
    var_prev_spec VARCHAR(8);
    var_src_ind VARCHAR(2);
    var_adm_0 INTEGER;
    var_adm_3 INTEGER;
    var_adm_4 INTEGER;
    var_adm_5 INTEGER;
    var_dsch_0 INTEGER;
    var_dsch_1 INTEGER;
    var_dsch_2 INTEGER;
    var_dsch_3 INTEGER;
    var_dsch_4 INTEGER;
    var_dsch_5 INTEGER;
    var_dsch_6 INTEGER;
    var_dsch_7 INTEGER;
    var_dsch_a INTEGER;
    var_aeday_dsch INTEGER;
    var_aeday_deth INTEGER;
    var_dsch_code VARCHAR(2);
    var_dp_dsch INTEGER;
    var_dp_deth INTEGER;
    var_move_spec VARCHAR(8);
    var_los_xout INTEGER;
    var_los INTEGER;
    var_ip_bed INTEGER;
    var_dp_bed INTEGER;
    var_ward VARCHAR(8);
    var_xin INTEGER;
    var_xout INTEGER;
    var_tdin INTEGER;
    var_tdout INTEGER;
    var_string VARCHAR(368);
    var_ciwl_ind VARCHAR(2);
    var_remain INTEGER;
    var_vac INTEGER;
    var_exc INTEGER;
    var_loc VARCHAR(8);
    var_move_loc VARCHAR(8);
    var_prev_loc VARCHAR(8);
    var_prev_ciwl_ind VARCHAR(2);
    var_days INTEGER;
    var_spec_adm_0 INTEGER;
    var_spec_adm_3 INTEGER;
    var_spec_adm_4 INTEGER;
    var_spec_adm_5 INTEGER;
    var_spec_xin INTEGER;
    var_spec_xout INTEGER;
    var_spec_tdin INTEGER;
    var_spec_tdout INTEGER;
    var_spec_dsch_0 INTEGER;
    var_spec_dsch_1 INTEGER;
    var_spec_dsch_2 INTEGER;
    var_spec_dsch_3 INTEGER;
    var_spec_dsch_4 INTEGER;
    var_spec_dsch_5 INTEGER;
    var_spec_dsch_6 INTEGER;
    var_spec_dsch_7 INTEGER;
    var_spec_dsch_a INTEGER;
    var_spec_aeday_dsch INTEGER;
    var_spec_aeday_deth INTEGER;
    var_spec_dp_dsch INTEGER;
    var_spec_dp_deth INTEGER;
    var_spec_remain INTEGER;
    var_spec_bdo INTEGER;
    var_spec_ip_bed INTEGER;
    var_spec_vac INTEGER;
    var_spec_exc INTEGER;
    var_spec_dp_bed INTEGER;
    var_spec_los INTEGER;
    var_spec_los_xout INTEGER;
    var_hosp_adm_0 INTEGER;
    var_hosp_adm_3 INTEGER;
    var_hosp_adm_4 INTEGER;
    var_hosp_adm_5 INTEGER;
    var_hosp_xin INTEGER;
    var_hosp_xout INTEGER;
    var_hosp_tdin INTEGER;
    var_hosp_tdout INTEGER;
    var_hosp_dsch_0 INTEGER;
    var_hosp_dsch_1 INTEGER;
    var_hosp_dsch_2 INTEGER;
    var_hosp_dsch_3 INTEGER;
    var_hosp_dsch_4 INTEGER;
    var_hosp_dsch_5 INTEGER;
    var_hosp_dsch_6 INTEGER;
    var_hosp_dsch_7 INTEGER;
    var_hosp_dsch_a INTEGER;
    var_hosp_aeday_dsch INTEGER;
    var_hosp_aeday_deth INTEGER;
    var_hosp_dp_dsch INTEGER;
    var_hosp_dp_deth INTEGER;
    var_hosp_remain INTEGER;
    var_hosp_bdo INTEGER;
    var_hosp_ip_bed INTEGER;
    var_hosp_vac INTEGER;
    var_hosp_exc INTEGER;
    var_hosp_dp_bed INTEGER;
    var_hosp_los INTEGER;
    var_hosp_los_xout INTEGER;
    bed_csr CURSOR FOR
    SELECT
        ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed
        FROM (SELECT
            Ward_code, Specialty_code, Official_bed, Day_bed, Effective_date
            FROM Ward_specialty) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM Ward_specialty
            WHERE Ward_code <> 'AE01' AND Effective_date <= var_today AND Hospital_code = par_hosp
            GROUP BY Ward_code, Specialty_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
        WHERE Effective_date = max_1;
    adm_csr CURSOR FOR
    SELECT
        Source_indicator, From_specialty_code, From_treatment_location
        FROM Transaction_log AS t, Case_view AS c
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type = '100' AND Cancel_flag IS NULL AND t.Hospital_code = par_hosp AND c.Hospital_code = par_hosp AND t.Case_no = c.Case_no;
    xin_csr CURSOR FOR
    SELECT
        From_specialty_code, From_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type = '141' AND (From_specialty_code <> To_specialty_code OR COALESCE(From_treatment_location, 'null') <> COALESCE(To_treatment_location, 'null')) AND Cancel_flag IS NULL AND Hospital_code = par_hosp;
    xout_csr CURSOR FOR
    SELECT
        From_specialty_code, From_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type = '140' AND (From_specialty_code <> To_specialty_code OR COALESCE(From_treatment_location, 'null') <> COALESCE(To_treatment_location, 'null')) AND Cancel_flag IS NULL AND Hospital_code = par_hosp;
    tdout_csr CURSOR FOR
    SELECT
        From_specialty_code, From_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type = '160' AND Cancel_flag IS NULL AND Hospital_code = par_hosp;
    tdout_home_csr CURSOR FOR
    SELECT
        From_specialty_code, From_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type = '161' AND Cancel_flag IS NULL AND Hospital_code = par_hosp;
    tdin_csr CURSOR FOR
    SELECT
        From_specialty_code, From_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type = '171' AND Cancel_flag IS NULL AND Hospital_code = par_hosp;
    tdin_home_csr CURSOR FOR
    SELECT
        From_specialty_code, From_treatment_location
        FROM Transaction_log
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type = '170' AND Cancel_flag IS NULL AND Hospital_code = par_hosp;
    dsch_csr CURSOR FOR
    SELECT
        t.Case_no, Admission_datetime, From_specialty_code, Discharge_code, Source_indicator, Discharge_datetime, From_treatment_location
        FROM Transaction_log AS t, Case_view AS c
        WHERE Transaction_datetime >= var_today AND Transaction_datetime < 1 * INTERVAL '1 day' + var_today::TIMESTAMP AND Transaction_type LIKE '13_' AND Cancel_flag IS NULL AND t.Hospital_code = par_hosp AND c.Hospital_code = par_hosp AND t.Case_no = c.Case_no;
    move_csr CURSOR FOR
    SELECT
        Movement_datetime, Movement_type, Specialty_code, Treatment_location
        FROM Movement
        WHERE Case_no = var_case AND Hospital_code = par_hosp
        ORDER BY Movement_count NULLS FIRST;
    bal_csr CURSOR FOR
    SELECT
        spec_code, loc, ciwl_ind, adm_0, adm_3, adm_4, adm_5, xin, xout, tdin, tdout, dsch_0, dsch_1, dsch_2, dsch_3, dsch_4, dsch_5, dsch_6, dsch_7, dsch_a, aeday_dsch, aeday_deth, dp_dsch, dp_deth, remain, bdo, ip_bed, vac, exc, dp_bed, los_ttl, los_xout
        FROM t$daily_balance;
    loc_csr CURSOR FOR
    SELECT
        loc, ciwl_ind, adm_0, adm_3, adm_4, adm_5, xin, xout, tdin, tdout, dsch_0, dsch_1, dsch_2, dsch_3, dsch_4, dsch_5, dsch_6, dsch_7, dsch_a, aeday_dsch, aeday_deth, dp_dsch, dp_deth, remain, bdo, ip_bed, vac, exc, dp_bed, los_ttl, los_xout
        FROM t$daily_balance
        WHERE loc IS NOT NULL;
    dsp_csr CURSOR FOR
    SELECT
        spec_code, loc, ciwl_ind, adm_0, adm_3, adm_4, adm_5, xin, xout, tdin, tdout, dsch_0, dsch_1, dsch_2, dsch_3, dsch_4, dsch_5, dsch_6, dsch_7, dsch_a, aeday_dsch, aeday_deth, dp_dsch, dp_deth, remain, bdo, ip_bed, vac, exc, dp_bed, los_ttl, los_xout
        FROM t$summary_table
        WHERE (adm_0 <> 0 OR adm_3 <> 0 OR adm_4 <> 0 OR adm_5 <> 0 OR xin <> 0 OR xout <> 0 OR tdin <> 0 OR tdout <> 0 OR dsch_0 <> 0 OR dsch_1 <> 0 OR dsch_2 <> 0 OR dsch_3 <> 0 OR dsch_4 <> 0 OR dsch_5 <> 0 OR dsch_6 <> 0 OR dsch_7 <> 0 OR dsch_a <> 0 OR aeday_dsch <> 0 OR aeday_deth <> 0 OR dp_dsch <> 0 OR dp_deth <> 0 OR remain <> 0 OR ip_bed <> 0 OR vac <> 0 OR exc <> 0 OR dp_bed <> 0 OR los_ttl <> 0 OR los_xout <> 0 OR bdo <> 0) AND spec_code <> 'HOME'
        ORDER BY spec_code NULLS FIRST, loc NULLS FIRST, ciwl_ind NULLS FIRST;
    sql$rowcount BIGINT;
BEGIN
    IF par_from_date IS NULL THEN
        SELECT
            - 1 * INTERVAL '1 month' + CONCAT(to_char(localtimestamp, 'YYYYMMDD'))::TIMESTAMP
            INTO par_from_date;
    END IF;

    IF par_to_date IS NULL THEN
        SELECT
            - 1 * INTERVAL '1 day' + 1 * INTERVAL '1 month' + par_from_date::TIMESTAMP::TIMESTAMP
            INTO par_to_date;
    END IF;
    SELECT
        DATE_PART('days', par_to_date::TIMESTAMP - par_from_date::TIMESTAMP)
        INTO var_days;
       
    DROP TABLE IF EXISTS t$daily_balance;
    DROP TABLE IF EXISTS t$summary_table;
    DROP TABLE IF EXISTS t$start_table;
   
    CREATE TEMPORARY TABLE t$daily_balance
    (spec_code VARCHAR(8),
        loc VARCHAR(8) NULL,
        ciwl_ind VARCHAR(2) DEFAULT NULL NULL,
        prev_remain INTEGER DEFAULT 0,
        xin INTEGER DEFAULT 0,
        xout INTEGER DEFAULT 0,
        tdin INTEGER DEFAULT 0,
        tdout INTEGER DEFAULT 0,
        adm_0 INTEGER DEFAULT 0,
        adm_3 INTEGER DEFAULT 0,
        adm_4 INTEGER DEFAULT 0,
        adm_5 INTEGER DEFAULT 0,
        dsch_0 INTEGER DEFAULT 0,
        dsch_1 INTEGER DEFAULT 0,
        dsch_2 INTEGER DEFAULT 0,
        dsch_3 INTEGER DEFAULT 0,
        dsch_4 INTEGER DEFAULT 0,
        dsch_5 INTEGER DEFAULT 0,
        dsch_6 INTEGER DEFAULT 0,
        dsch_7 INTEGER DEFAULT 0,
        dsch_a INTEGER DEFAULT 0,
        aeday_dsch INTEGER DEFAULT 0,
        aeday_deth INTEGER DEFAULT 0,
        dp_dsch INTEGER DEFAULT 0,
        dp_deth INTEGER DEFAULT 0,
        remain INTEGER DEFAULT 0,
        bdo INTEGER DEFAULT 0,
        ip_bed INTEGER DEFAULT 0,
        vac INTEGER DEFAULT 0,
        exc INTEGER DEFAULT 0,
        dp_bed INTEGER DEFAULT 0,
        los_xout INTEGER DEFAULT 0,
        los_ttl INTEGER DEFAULT 0);
    CREATE UNIQUE INDEX daily_index ON t$daily_balance
        (spec_code, loc, ciwl_ind);
    CREATE TEMPORARY TABLE t$summary_table
    (spec_code VARCHAR(8),
        loc VARCHAR(8) NULL,
        ciwl_ind VARCHAR(2) DEFAULT NULL NULL,
        xin INTEGER DEFAULT 0,
        xout INTEGER DEFAULT 0,
        tdin INTEGER DEFAULT 0,
        tdout INTEGER DEFAULT 0,
        adm_0 INTEGER DEFAULT 0,
        adm_3 INTEGER DEFAULT 0,
        adm_4 INTEGER DEFAULT 0,
        adm_5 INTEGER DEFAULT 0,
        dsch_0 INTEGER DEFAULT 0,
        dsch_1 INTEGER DEFAULT 0,
        dsch_2 INTEGER DEFAULT 0,
        dsch_3 INTEGER DEFAULT 0,
        dsch_4 INTEGER DEFAULT 0,
        dsch_5 INTEGER DEFAULT 0,
        dsch_6 INTEGER DEFAULT 0,
        dsch_7 INTEGER DEFAULT 0,
        dsch_a INTEGER DEFAULT 0,
        aeday_dsch INTEGER DEFAULT 0,
        aeday_deth INTEGER DEFAULT 0,
        dp_dsch INTEGER DEFAULT 0,
        dp_deth INTEGER DEFAULT 0,
        remain INTEGER DEFAULT 0,
        bdo INTEGER DEFAULT 0,
        ip_bed INTEGER DEFAULT 0,
        vac INTEGER DEFAULT 0,
        exc INTEGER DEFAULT 0,
        dp_bed INTEGER DEFAULT 0,
        los_xout INTEGER DEFAULT 0,
        los_ttl INTEGER DEFAULT 0);
    CREATE UNIQUE INDEX summary_index ON t$summary_table
        (spec_code, loc, ciwl_ind);
    SELECT
        par_from_date
        INTO var_today;

    WHILE var_today <= par_to_date LOOP
        /* --		print 'Processing for %1!', @today */
        /* Caculate Previous Remaining */
        /* --		print 'Calculate Previous Remaining' */
        CREATE TEMPORARY TABLE t$start_table
        AS
        SELECT
            MAX(Ward_spec_tx_date) AS tx_date, Ward_code AS ward_code, Specialty_code AS spec_code, Treatment_location AS treat_loc
            FROM Ward_spec_tx
            WHERE Ward_spec_tx_date < var_today AND Hospital_code = par_hosp::VARCHAR
            GROUP BY specialty_code, treatment_location, ward_code;
        INSERT INTO t$daily_balance (spec_code, loc, prev_remain)
        SELECT
            spec_code, treat_loc, SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) - SUM(COALESCE(Canc_admission, 0)) - SUM(COALESCE(Discharge, 0)) + SUM(COALESCE(Canc_discharge, 0)) + SUM(COALESCE(Transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Transfer_out, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) - SUM(COALESCE(Death, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) + SUM(COALESCE(Canc_transfer_out_to_TD, 0))
            FROM t$start_table as t, Ward_spec_tx_adj_view as w
            WHERE tx_date = Ward_spec_tx_date AND t.ward_code = w.ward_code AND spec_code = specialty_code AND COALESCE(treat_loc, 'null') = COALESCE(treatment_location, 'null')
            GROUP BY spec_code, treat_loc;
        UPDATE t$daily_balance
        SET ciwl_ind = (SELECT
            ciwl_ind
            FROM ciwl_table
            WHERE hosp_code = par_hosp AND spec_code = a.spec_code AND eff_date = (SELECT
                MAX(eff_date)
                FROM ciwl_table
                WHERE hosp_code = par_hosp AND spec_code = a.spec_code AND eff_date <= var_today))
        FROM t$daily_balance AS a;
        /* Number of Beds */
        /* --		print 'Number of Beds' */
        OPEN bed_csr;
        FETCH bed_csr INTO var_ward, var_spec, var_ip_bed, var_dp_bed;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF var_ip_bed <> 0 OR var_dp_bed <> 0 THEN
                IF EXISTS (SELECT
                    *
                    FROM t$daily_balance
                    WHERE spec_code = var_spec AND loc IS NULL) THEN
                    UPDATE t$daily_balance
                    SET ip_bed = ip_bed + var_ip_bed, dp_bed = dp_bed + var_dp_bed
                        WHERE spec_code = var_spec AND loc IS NULL;
                ELSE
                    BEGIN
                        SELECT
                            ciwl_ind
                            INTO var_ciwl_ind
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                                MAX(eff_date)
                                FROM ciwl_table
                                WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            SELECT
                                NULL
                                INTO var_ciwl_ind;
                        END IF;
                        INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, ip_bed, dp_bed)
                        VALUES (var_spec, NULL, var_ciwl_ind, var_ip_bed, var_dp_bed);
                    END;
                END IF;
            END IF;
            FETCH bed_csr INTO var_ward, var_spec, var_ip_bed, var_dp_bed;
        END LOOP;
        CLOSE bed_csr;
        /* Admission */
        /* --		print 'Admission' */
        OPEN adm_csr;
        FETCH adm_csr INTO var_src_ind, var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                0, 0, 0, 0
                INTO var_adm_0, var_adm_3, var_adm_4, var_adm_5;

            IF var_src_ind = '0' THEN
                SELECT
                    1
                    INTO var_adm_0;
            END IF;

            IF var_src_ind = '3' THEN
                SELECT
                    1
                    INTO var_adm_3;
            END IF;

            IF var_src_ind = '4' THEN
                SELECT
                    1
                    INTO var_adm_4;
            END IF;

            IF var_src_ind = '5' THEN
                SELECT
                    1
                    INTO var_adm_5;
            END IF;

            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET adm_0 = adm_0 + var_adm_0, adm_3 = adm_3 + var_adm_3, adm_4 = adm_4 + var_adm_4, adm_5 = adm_5 + var_adm_5
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, adm_0, adm_3, adm_4, adm_5)
                    VALUES (var_spec, var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5);
                END;
            END IF;
            FETCH adm_csr INTO var_src_ind, var_spec, var_loc;
        END LOOP;
        CLOSE adm_csr;
        /* Transfer In */
        /* --		print 'Transfer In' */
        OPEN xin_csr;
        FETCH xin_csr INTO var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET xin = xin + 1
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, xin)
                    VALUES (var_spec, var_loc, var_ciwl_ind, 1);
                END;
            END IF;
            FETCH xin_csr INTO var_spec, var_loc;
        END LOOP;
        CLOSE xin_csr;
        /* Transfer Out */
        /* --		print 'Transfer Out' */
        OPEN xout_csr;
        FETCH xout_csr INTO var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET xout = xout + 1
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, xout)
                    VALUES (var_spec, var_loc, var_ciwl_ind, 1);
                END;
            END IF;
            FETCH xout_csr INTO var_spec, var_loc;
        END LOOP;
        CLOSE xout_csr;
        /* Return From Trial Discharge */
        /* --		print 'Return From Trial Discharge' */
        OPEN tdin_csr;
        FETCH tdin_csr INTO var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET tdin = tdin + 1
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, tdin)
                    VALUES (var_spec, var_loc, var_ciwl_ind, 1);
                END;
            END IF;
            FETCH tdin_csr INTO var_spec, var_loc;
        END LOOP;
        CLOSE tdin_csr;
        OPEN tdin_home_csr;
        FETCH tdin_home_csr INTO var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET tdout = tdout + 1
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, tdout)
                    VALUES (var_spec, var_loc, var_ciwl_ind, 1);
                END;
            END IF;
            FETCH tdin_home_csr INTO var_spec, var_loc;
        END LOOP;
        CLOSE tdin_home_csr;
        /* Trial Discharge */
        /* --		print 'Trial Discharge' */
        OPEN tdout_csr;
        FETCH tdout_csr INTO var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET tdout = tdout + 1
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, tdout)
                    VALUES (var_spec, var_loc, var_ciwl_ind, 1);
                END;
            END IF;
            FETCH tdout_csr INTO var_spec, var_loc;
        END LOOP;
        CLOSE tdout_csr;
        OPEN tdout_home_csr;
        FETCH tdout_home_csr INTO var_spec, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET tdin = tdin + 1
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, tdin)
                    VALUES (var_spec, var_loc, var_ciwl_ind, 1);
                END;
            END IF;
            FETCH tdout_home_csr INTO var_spec, var_loc;
        END LOOP;
        CLOSE tdout_home_csr;
        /* Discharge */
        /* --		print 'Discharge' */
        OPEN dsch_csr;
        FETCH dsch_csr INTO var_case, var_adm_date, var_spec, var_dsch_code, var_src_ind, var_dsch_date, var_loc;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                INTO var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_dp_dsch, var_dp_deth, var_aeday_dsch, var_aeday_deth;

            IF var_dsch_code = '0' THEN
                SELECT
                    1
                    INTO var_dsch_0;
            END IF;

            IF var_dsch_code = '1' THEN
                BEGIN
                    SELECT
                        1
                        INTO var_dsch_1;

                    IF DATE_PART('days', var_dsch_date::TIMESTAMP - var_adm_date::TIMESTAMP) = 0 THEN
                        IF var_src_ind = '3' THEN
                            SELECT
                                1
                                INTO var_aeday_deth;
                        ELSE
                            SELECT
                                1
                                INTO var_dp_deth;
                        END IF;
                    END IF;
                END;
            ELSE
                BEGIN
                    IF DATE_PART('days', var_dsch_date::TIMESTAMP - var_adm_date::TIMESTAMP) = 0 THEN
                        IF var_src_ind = '3' THEN
                            SELECT
                                1
                                INTO var_aeday_dsch;
                        ELSE
                            SELECT
                                1
                                INTO var_dp_dsch;
                        END IF;
                    END IF;
                END;
            END IF;

            IF var_dsch_code = '2' THEN
                SELECT
                    1
                    INTO var_dsch_2;
            END IF;

            IF var_dsch_code = '3' THEN
                SELECT
                    1
                    INTO var_dsch_3;
            END IF;

            IF var_dsch_code = '4' THEN
                SELECT
                    1
                    INTO var_dsch_4;
            END IF;

            IF var_dsch_code = '5' THEN
                SELECT
                    1
                    INTO var_dsch_5;
            END IF;

            IF var_dsch_code = '6' THEN
                SELECT
                    1
                    INTO var_dsch_6;
            END IF;

            IF var_dsch_code = '7' THEN
                SELECT
                    1
                    INTO var_dsch_7;
            END IF;

            IF var_dsch_code = 'A' THEN
                SELECT
                    1
                    INTO var_dsch_a;
            END IF;

            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null')) THEN
                UPDATE t$daily_balance
                SET aeday_dsch = aeday_dsch + var_aeday_dsch, aeday_deth = aeday_deth + var_aeday_deth, dp_dsch = dp_dsch + var_dp_dsch, dp_deth = dp_deth + var_dp_deth, dsch_0 = dsch_0 + var_dsch_0, dsch_1 = dsch_1 + var_dsch_1, dsch_2 = dsch_2 + var_dsch_2, dsch_3 = dsch_3 + var_dsch_3, dsch_4 = dsch_4 + var_dsch_4, dsch_5 = dsch_5 + var_dsch_5, dsch_6 = dsch_6 + var_dsch_6, dsch_7 = dsch_7 + var_dsch_7, dsch_a = dsch_a + var_dsch_a
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null');
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_spec AND eff_date <= var_today);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, aeday_dsch, aeday_deth, dp_dsch, dp_deth, dsch_0, dsch_1, dsch_2, dsch_3, dsch_4, dsch_5, dsch_6, dsch_7, dsch_a)
                    VALUES (var_spec, var_loc, var_ciwl_ind, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a);
                END;
            END IF;
            /* Get LOS */
            /* --			print 'Get LOS' */
            SELECT
                NULL, NULL, NULL, 0, NULL
                INTO var_prev_type, var_prev_date, var_prev_spec, var_los, var_prev_loc;
            OPEN move_csr;
            FETCH move_csr INTO var_move_date, var_move_type, var_move_spec, var_move_loc;

            WHILE (CASE
                WHEN FOUND THEN 0
                WHEN NOT FOUND THEN 2
                ELSE 1
            END) = 0 LOOP
                IF var_prev_type IS NOT NULL OR var_prev_date IS NOT NULL OR var_prev_spec IS NOT NULL THEN
                    BEGIN
                        IF var_prev_spec <> var_move_spec OR var_move_type = 'D' OR var_prev_loc <> var_move_loc THEN
                            BEGIN
                                IF var_prev_spec = 'HOME' THEN
                                    SELECT
                                        0
                                        INTO var_los;
                                ELSE
                                    SELECT
                                        DATE_PART('days', var_move_date::TIMESTAMP - var_prev_date::TIMESTAMP)
                                        INTO var_los;
                                END IF;

                                IF var_prev_spec = 'HOME' OR var_move_spec = 'HOME' THEN
                                    SELECT
                                        0
                                        INTO var_los_xout;
                                ELSE
                                    IF var_move_type = 'D' THEN
                                        SELECT
                                            0
                                            INTO var_los_xout;
                                    ELSE
                                        SELECT
                                            1
                                            INTO var_los_xout;
                                    END IF;
                                END IF;

                                IF var_los = 0 AND var_prev_spec <> 'HOME' AND var_move_type = 'D' AND var_src_ind = '3' AND DATE_PART('days', var_dsch_date::TIMESTAMP - var_adm_date::TIMESTAMP) = 0 THEN
                                    SELECT
                                        1
                                        INTO var_los;
                                END IF;

                                IF EXISTS (SELECT
                                    *
                                    FROM t$daily_balance
                                    WHERE spec_code = var_prev_spec AND COALESCE(loc, 'null') = COALESCE(var_prev_loc, 'null')) THEN
                                    UPDATE t$daily_balance
                                    SET los_ttl = los_ttl + var_los, los_xout = los_xout + var_los_xout
                                        WHERE spec_code = var_prev_spec AND COALESCE(loc, 'null') = COALESCE(var_prev_loc, 'null');
                                ELSE
                                    BEGIN
                                        SELECT
                                            ciwl_ind
                                            INTO var_ciwl_ind
                                            FROM ciwl_table
                                            WHERE hosp_code = par_hosp AND spec_code = var_prev_spec AND eff_date = (SELECT
                                                MAX(eff_date)
                                                FROM ciwl_table
                                                WHERE hosp_code = par_hosp AND spec_code = var_prev_spec AND eff_date <= var_prev_date);
                                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                        IF sql$rowcount = 0 THEN
                                            SELECT
                                                NULL
                                                INTO var_ciwl_ind;
                                        END IF;
                                        INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, los_ttl, los_xout)
                                        VALUES (var_prev_spec, var_prev_loc, var_ciwl_ind, var_los, var_los_xout);
                                    END;
                                END IF;
                                SELECT
                                    var_move_type, var_move_date, var_move_spec, var_move_loc
                                    INTO var_prev_type, var_prev_date, var_prev_spec, var_prev_loc;
                            END;
                        END IF;
                    END;
                ELSE
                    SELECT
                        var_move_type, var_move_spec, var_move_date, var_move_loc
                        INTO var_prev_type, var_prev_spec, var_prev_date, var_prev_loc;
                END IF;
                FETCH move_csr INTO var_move_date, var_move_type, var_move_spec, var_move_loc;
            END LOOP;
            CLOSE move_csr;
            FETCH dsch_csr INTO var_case, var_adm_date, var_spec, var_dsch_code, var_src_ind, var_dsch_date, var_loc;
        END LOOP;
        CLOSE dsch_csr;
        /* Update daily balance to summary */
        /* --		print 'Update daily balance to summary' */
        UPDATE t$daily_balance
        SET remain = prev_remain + adm_0 + adm_3 + adm_4 + adm_5 + xin + tdin - dsch_0 - dsch_1 - dsch_2 - dsch_3 - dsch_4 - dsch_5 - dsch_6 - dsch_7 - dsch_a - xout - tdout;
        OPEN loc_csr;
        FETCH loc_csr INTO var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_ip_bed, var_vac, var_exc, var_dp_bed, var_los, var_los_xout;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$daily_balance
                WHERE spec_code = var_loc AND loc IS NULL) THEN
                UPDATE t$daily_balance
                SET adm_0 = adm_0 + var_adm_0, adm_3 = adm_3 + var_adm_3, adm_4 = adm_4 + var_adm_4, adm_5 = adm_5 + var_adm_5, xin = xin + var_xin, xout = xout + var_xout, tdin = tdin + var_tdin, tdout = tdout + var_tdout, dsch_0 = dsch_0 + var_dsch_0, dsch_1 = dsch_1 + var_dsch_1, dsch_2 = dsch_2 + var_dsch_2, dsch_3 = dsch_3 + var_dsch_3, dsch_4 = dsch_4 + var_dsch_4, dsch_5 = dsch_5 + var_dsch_5, dsch_6 = dsch_6 + var_dsch_6, dsch_7 = dsch_7 + var_dsch_7, dsch_a = dsch_a + var_dsch_a, aeday_dsch = aeday_dsch + var_aeday_dsch, aeday_deth = aeday_deth + var_aeday_deth, dp_dsch = dp_dsch + var_dp_dsch, dp_deth = dp_deth + var_dp_deth, remain = remain + var_remain, bdo = bdo + var_bdo, los_ttl = los_ttl + var_los, los_xout = los_xout + var_los_xout
                    WHERE spec_code = var_loc AND loc IS NULL;
            ELSE
                BEGIN
                    SELECT
                        ciwl_ind
                        INTO var_ciwl_ind
                        FROM ciwl_table
                        WHERE hosp_code = par_hosp AND spec_code = var_loc AND eff_date = (SELECT
                            MAX(eff_date)
                            FROM ciwl_table
                            WHERE hosp_code = par_hosp AND spec_code = var_loc AND eff_date <= par_to_date);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_ciwl_ind;
                    END IF;
                    INSERT INTO t$daily_balance (spec_code, loc, ciwl_ind, adm_0, adm_3, adm_4, adm_5, xin, xout, tdin, tdout, dsch_0, dsch_1, dsch_2, dsch_3, dsch_4, dsch_5, dsch_6, dsch_7, dsch_a, aeday_dsch, aeday_deth, dp_dsch, dp_deth, remain, bdo, los_ttl, los_xout)
                    VALUES (var_loc, NULL, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_los, var_los_xout);
                END;
            END IF;
            FETCH loc_csr INTO var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_ip_bed, var_vac, var_exc, var_dp_bed, var_los, var_los_xout;
        END LOOP;
        CLOSE loc_csr;
        UPDATE t$daily_balance
        SET bdo = remain + aeday_dsch + aeday_deth;
        UPDATE t$daily_balance
        SET vac = ip_bed - bdo
            WHERE ip_bed > bdo AND loc IS NULL;
        UPDATE t$daily_balance
        SET exc = bdo - ip_bed
            WHERE bdo > ip_bed AND loc IS NULL;
        OPEN bal_csr;
        FETCH bal_csr INTO var_spec, var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_ip_bed, var_vac, var_exc, var_dp_bed, var_los, var_los_xout;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF EXISTS (SELECT
                *
                FROM t$summary_table
                WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null') AND ciwl_ind = var_ciwl_ind) THEN
                UPDATE t$summary_table
                SET adm_0 = adm_0 + var_adm_0, adm_3 = adm_3 + var_adm_3, adm_4 = adm_4 + var_adm_4, adm_5 = adm_5 + var_adm_5, xin = xin + var_xin, xout = xout + var_xout, tdin = tdin + var_tdin, tdout = tdout + var_tdout, dsch_0 = dsch_0 + var_dsch_0, dsch_1 = dsch_1 + var_dsch_1, dsch_2 = dsch_2 + var_dsch_2, dsch_3 = dsch_3 + var_dsch_3, dsch_4 = dsch_4 + var_dsch_4, dsch_5 = dsch_5 + var_dsch_5, dsch_6 = dsch_6 + var_dsch_6, dsch_7 = dsch_7 + var_dsch_7, dsch_a = dsch_a + var_dsch_a, aeday_dsch = aeday_dsch + var_aeday_dsch, aeday_deth = aeday_deth + var_aeday_deth, dp_dsch = dp_dsch + var_dp_dsch, dp_deth = dp_deth + dp_deth, remain = remain + var_remain, bdo = bdo + var_bdo, ip_bed = ip_bed + var_ip_bed, vac = vac + var_vac, exc = exc + var_exc, dp_bed = dp_bed + var_dp_bed, los_ttl = los_ttl + var_los, los_xout = los_xout + var_los_xout
                    WHERE spec_code = var_spec AND COALESCE(loc, 'null') = COALESCE(var_loc, 'null') AND ciwl_ind = var_ciwl_ind;
            ELSE
                INSERT INTO t$summary_table (spec_code, loc, ciwl_ind, adm_0, adm_3, adm_4, adm_5, xin, xout, tdin, tdout, dsch_0, dsch_1, dsch_2, dsch_3, dsch_4, dsch_5, dsch_6, dsch_7, dsch_a, aeday_dsch, aeday_deth, dp_dsch, dp_deth, remain, bdo, ip_bed, vac, exc, dp_bed, los_ttl, los_xout)
                VALUES (var_spec, var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_ip_bed, var_vac, var_exc, var_dp_bed, var_los, var_los_xout);
            END IF;
            FETCH bal_csr INTO var_spec, var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_ip_bed, var_vac, var_exc, var_dp_bed, var_los, var_los_xout;
        END LOOP;
        CLOSE bal_csr;
        /* Daily Completed */
        /* --		print 'Daily Completed' */
        DROP TABLE t$start_table;
        TRUNCATE TABLE t$daily_balance;
        SELECT
            1 * INTERVAL '1 day' + var_today::TIMESTAMP
            INTO var_today;
    END LOOP;
    /* Summary */
    /* --	print 'Summary' */
    SELECT
        NULL, 0, NULL
        INTO var_prev_spec, var_count, var_prev_ciwl_ind;
    SELECT
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        INTO var_spec_adm_0, var_spec_adm_3, var_spec_adm_4, var_spec_adm_5, var_spec_xin, var_spec_xout, var_spec_tdin, var_spec_tdout, var_spec_dsch_0, var_spec_dsch_1, var_spec_dsch_2, var_spec_dsch_3, var_spec_dsch_4, var_spec_dsch_5, var_spec_dsch_6, var_spec_dsch_7, var_spec_dsch_a, var_spec_aeday_dsch, var_spec_aeday_deth, var_spec_dp_dsch, var_spec_dp_deth, var_spec_remain, var_spec_bdo, var_spec_ip_bed, var_spec_vac, var_spec_exc, var_spec_dp_bed, var_spec_los, var_spec_los_xout;
    SELECT
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        INTO var_hosp_adm_0, var_hosp_adm_3, var_hosp_adm_4, var_hosp_adm_5, var_hosp_xin, var_hosp_xout, var_hosp_tdin, var_hosp_tdout, var_hosp_dsch_0, var_hosp_dsch_1, var_hosp_dsch_2, var_hosp_dsch_3, var_hosp_dsch_4, var_hosp_dsch_5, var_hosp_dsch_6, var_hosp_dsch_7, var_hosp_dsch_a, var_hosp_aeday_dsch, var_hosp_aeday_deth, var_hosp_dp_dsch, var_hosp_dp_deth, var_hosp_remain, var_hosp_bdo, var_hosp_ip_bed, var_hosp_vac, var_hosp_exc, var_hosp_dp_bed, var_hosp_los, var_hosp_los_xout;
    OPEN dsp_csr;
    FETCH dsp_csr INTO var_spec, var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_ip_bed, var_vac, var_exc, var_dp_bed, var_los, var_los_xout;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        IF var_prev_spec IS NULL THEN
            SELECT
                var_spec, var_ciwl_ind
                INTO var_prev_spec, var_prev_ciwl_ind;
        ELSE
            BEGIN
                IF var_prev_spec <> var_spec THEN
                    BEGIN
                        IF var_count > 1 THEN
                            BEGIN
                                SELECT
                                    CONCAT(SUBSTRING(CONCAT(par_hosp, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(var_prev_spec, REPEAT(' ', 4)), 1, 4), 'TOT ', SUBSTRING(CONCAT(var_prev_ciwl_ind, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(CAST (var_spec_adm_0 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_adm_3 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_adm_4 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_adm_5 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_0 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_1 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_2 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_3 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_4 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_5 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_6 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_7 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_a AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_los_xout AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_xin AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_xout AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_remain AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_bdo AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), REPEAT(' ', 7), REPEAT(' ', 7), REPEAT(' ', 7), SUBSTRING(CONCAT(CAST (var_spec_dp_dsch AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dp_deth AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_los AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_days AS VARCHAR(4)), REPEAT(' ', 4)), 1, 4))
                                    INTO var_string;
                                RAISE NOTICE '%', var_string;
                            END;
                        END IF;
                        SELECT
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                            INTO var_spec_adm_0, var_spec_adm_3, var_spec_adm_4, var_spec_adm_5, var_spec_xin, var_spec_xout, var_spec_tdin, var_spec_tdout, var_spec_dsch_0, var_spec_dsch_1, var_spec_dsch_2, var_spec_dsch_3, var_spec_dsch_4, var_spec_dsch_5, var_spec_dsch_6, var_spec_dsch_7, var_spec_dsch_a, var_spec_aeday_dsch, var_spec_aeday_deth, var_spec_dp_dsch, var_spec_dp_deth, var_spec_remain, var_spec_bdo, var_spec_ip_bed, var_spec_vac, var_spec_exc, var_spec_dp_bed, var_spec_los, var_spec_los_xout;
                        SELECT
                            0, var_spec, var_ciwl_ind
                            INTO var_count, var_prev_spec, var_prev_ciwl_ind;
                    END;
                END IF;
            END;
        END IF;

        IF var_ciwl_ind IN ('Y', 'N') THEN
            BEGIN
                SELECT
                    var_count + 1
                    INTO var_count;
                SELECT
                    CONCAT(SUBSTRING(CONCAT(par_hosp, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(var_spec, REPEAT(' ', 4)), 1, 4), SUBSTRING(CONCAT(var_loc, REPEAT(' ', 4)), 1, 4), SUBSTRING(CONCAT(var_ciwl_ind, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(CAST (var_adm_0 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_adm_3 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_adm_4 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_adm_5 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_0 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_1 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_2 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_3 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_4 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_5 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_6 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_7 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dsch_a AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_los_xout AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_xin AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_xout AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_remain AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_bdo AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_ip_bed AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_vac AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_exc AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dp_dsch AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_dp_deth AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_los AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_days AS VARCHAR(4)), REPEAT(' ', 4)), 1, 4))
                    INTO var_string;
                RAISE NOTICE '%', var_string;
                SELECT
                    var_spec_adm_0 + var_adm_0, var_spec_adm_3 + var_adm_3, var_spec_adm_4 + var_adm_4, var_spec_adm_5 + var_adm_5, var_spec_xin + var_xin, var_spec_xout + var_xout, var_spec_tdin + var_tdin, var_spec_tdout + var_tdout, var_spec_dsch_0 + var_dsch_0, var_spec_dsch_1 + var_dsch_1, var_spec_dsch_2 + var_dsch_2, var_spec_dsch_3 + var_dsch_3, var_spec_dsch_4 + var_dsch_4, var_spec_dsch_5 + var_dsch_5, var_spec_dsch_6 + var_dsch_6, var_spec_dsch_7 + var_dsch_7, var_spec_dsch_a + var_dsch_a, var_spec_aeday_dsch + var_aeday_dsch, var_spec_aeday_deth + var_aeday_deth, var_spec_dp_dsch + var_dp_dsch, var_spec_dp_deth + var_dp_deth, var_spec_remain + var_remain, var_spec_bdo + var_bdo, var_spec_ip_bed + var_ip_bed, var_spec_vac + var_vac, var_spec_exc + var_exc, var_spec_dp_bed + var_dp_bed, var_spec_los + var_los, var_spec_los_xout + var_los_xout
                    INTO var_spec_adm_0, var_spec_adm_3, var_spec_adm_4, var_spec_adm_5, var_spec_xin, var_spec_xout, var_spec_tdin, var_spec_tdout, var_spec_dsch_0, var_spec_dsch_1, var_spec_dsch_2, var_spec_dsch_3, var_spec_dsch_4, var_spec_dsch_5, var_spec_dsch_6, var_spec_dsch_7, var_spec_dsch_a, var_spec_aeday_dsch, var_spec_aeday_deth, var_spec_dp_dsch, var_spec_dp_deth, var_spec_remain, var_spec_bdo, var_spec_ip_bed, var_spec_vac, var_spec_exc, var_spec_dp_bed, var_spec_los, var_spec_los_xout;
            END;
        END IF;

        IF var_loc IS NULL THEN
            SELECT
                var_hosp_adm_0 + var_adm_0, var_hosp_adm_3 + var_adm_3, var_hosp_adm_4 + var_adm_4, var_hosp_adm_5 + var_adm_5, var_hosp_xin + var_xin, var_hosp_xout + var_xout, var_hosp_tdin + var_tdin, var_hosp_tdout + var_tdout, var_hosp_dsch_0 + var_dsch_0, var_hosp_dsch_1 + var_dsch_1, var_hosp_dsch_2 + var_dsch_2, var_hosp_dsch_3 + var_dsch_3, var_hosp_dsch_4 + var_dsch_4, var_hosp_dsch_5 + var_dsch_5, var_hosp_dsch_6 + var_dsch_6, var_hosp_dsch_7 + var_dsch_7, var_hosp_dsch_a + var_dsch_a, var_hosp_aeday_dsch + var_aeday_dsch, var_hosp_aeday_deth + var_aeday_deth, var_hosp_dp_dsch + var_dp_dsch, var_hosp_dp_deth + var_dp_deth, var_hosp_remain + var_remain, var_hosp_bdo + var_bdo, var_hosp_ip_bed + var_ip_bed, var_hosp_vac + var_vac, var_hosp_exc + var_exc, var_hosp_dp_bed + var_dp_bed, var_hosp_los + var_los, var_hosp_los_xout + var_los_xout
                INTO var_hosp_adm_0, var_hosp_adm_3, var_hosp_adm_4, var_hosp_adm_5, var_hosp_xin, var_hosp_xout, var_hosp_tdin, var_hosp_tdout, var_hosp_dsch_0, var_hosp_dsch_1, var_hosp_dsch_2, var_hosp_dsch_3, var_hosp_dsch_4, var_hosp_dsch_5, var_hosp_dsch_6, var_hosp_dsch_7, var_hosp_dsch_a, var_hosp_aeday_dsch, var_hosp_aeday_deth, var_hosp_dp_dsch, var_hosp_dp_deth, var_hosp_remain, var_hosp_bdo, var_hosp_ip_bed, var_hosp_vac, var_hosp_exc, var_hosp_dp_bed, var_hosp_los, var_hosp_los_xout;
        END IF;
        FETCH dsp_csr INTO var_spec, var_loc, var_ciwl_ind, var_adm_0, var_adm_3, var_adm_4, var_adm_5, var_xin, var_xout, var_tdin, var_tdout, var_dsch_0, var_dsch_1, var_dsch_2, var_dsch_3, var_dsch_4, var_dsch_5, var_dsch_6, var_dsch_7, var_dsch_a, var_aeday_dsch, var_aeday_deth, var_dp_dsch, var_dp_deth, var_remain, var_bdo, var_ip_bed, var_vac, var_exc, var_dp_bed, var_los, var_los_xout;
    END LOOP;
    CLOSE dsp_csr;

    IF var_count > 1 THEN
        BEGIN
            SELECT
                CONCAT(SUBSTRING(CONCAT(par_hosp, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(var_prev_spec, REPEAT(' ', 4)), 1, 4), 'TOT ', SUBSTRING(CONCAT(var_prev_ciwl_ind, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(CAST (var_spec_adm_0 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_adm_3 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_adm_4 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_adm_5 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_0 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_1 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_2 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_3 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_4 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_5 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_6 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_7 AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dsch_a AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_los_xout AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_xin AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_xout AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_remain AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_bdo AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), 'n/a    ', 'n/a    ', 'n/a    ', SUBSTRING(CONCAT(CAST (var_spec_dp_dsch AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_dp_deth AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_spec_los AS VARCHAR(7)), REPEAT(' ', 7)), 1, 7), SUBSTRING(CONCAT(CAST (var_days AS VARCHAR(4)), REPEAT(' ', 4)), 1, 4))
                INTO var_string;
            RAISE NOTICE '%', var_string;
        END;
    END IF;
    /*
    select @string = substring(@hosp + space(3), 1, 3)
    		+ 'GRND'
    		+ 'TOT '
    		+ space(1)
    		+ substring(convert(VARCHAR(7),@hosp_adm_0) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_adm_3) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_adm_4) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_adm_5) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_0) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_1) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_2) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_3) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_4) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_5) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_6) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_7) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dsch_a) + space(7), 1, 7)
    --		+ substring(convert(VARCHAR(7),@hosp_aeday_dsch) + space(7), 1, 7)
    --		+ substring(convert(VARCHAR(7),@hosp_aeday_deth) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_los_xout) + space(7), 1, 7)
    		+ space(7)
    		+ space(7)
    --		+ substring(convert(VARCHAR(7),@hosp_tdin) + space(7), 1, 7)
    --		+ substring(convert(VARCHAR(7),@hosp_tdout) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_remain) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_bdo) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_ip_bed) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_vac) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_exc) + space(7), 1, 7)
    --		+ substring(convert(VARCHAR(7),@hosp_dp_bed) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dp_dsch) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_dp_deth) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(7),@hosp_los) + space(7), 1, 7)
    		+ substring(convert(VARCHAR(4),@days) + space(4), 1, 4)
    	print @string
    
    	if exists(select * from #summary_table
    		where (adm_0 <> 0 or adm_3 <> 0 or adm_4 <> 0 or adm_5 <> 0
    		or xin <> 0 or xout <> 0 or tdin <> 0 or tdout <> 0
    		or dsch_0 <> 0 or dsch_1 <> 0 or dsch_2 <> 0 or dsch_3 <> 0
    		or dsch_4 <> 0 or dsch_5 <> 0 or dsch_6 <> 0 or dsch_7 <> 0
    		or dsch_a <> 0 or aeday_dsch <> 0 or aeday_deth <> 0
    		or dp_dsch <> 0 or dp_deth <> 0 or remain <> 0 or ip_bed <> 0
    		or vac <> 0 or exc <> 0 or dp_bed <> 0 or los_ttl <> 0
    		or los_xout <> 0 or bdo <> 0)
    		and spec_code = 'HOME')
    	begin
    		select @adm_0 = adm_0, @adm_3 = adm_3, @adm_4 = adm_4, @adm_5 = adm_5,
    			@xin = xin, @xout = xout, @tdin = tdin, @tdout = tdout,
    			@dsch_0 = dsch_0, @dsch_1 = dsch_1, @dsch_2 = dsch_2,
    			@dsch_3 = dsch_3, @dsch_4 = dsch_4, @dsch_5 = dsch_5,
    			@dsch_5 = dsch_6, @dsch_7 = dsch_7,
    			@dsch_a = dsch_a, @aeday_dsch = aeday_dsch, @aeday_deth = aeday_deth,
    			@dp_dsch = dp_dsch, @dp_deth = dp_deth, @remain = remain, @bdo = bdo,
    			@ip_bed = ip_bed, @vac = vac, @exc = exc, @dp_bed = dp_bed,
    			@los = los_ttl, @los_xout = los_xout
    			from #summary_table
    			where spec_code = 'HOME'
    		select @string = substring(@hosp + space(3), 1, 3)
    			+ 'HOME'
    			+ space(4)
    			+ space(1)
    			+ substring(convert(VARCHAR(7),@adm_0) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@adm_3) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@adm_4) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@adm_5) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_0) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_1) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_2) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_3) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_4) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_5) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_6) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_7) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dsch_a) + space(7), 1, 7)
    --			+ substring(convert(VARCHAR(7),@aeday_dsch) + space(7), 1, 7)
    --			+ substring(convert(VARCHAR(7),@aeday_deth) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@los_xout) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@xin) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@xout) + space(7), 1, 7)
    --			+ substring(convert(VARCHAR(7),@tdin) + space(7), 1, 7)
    --			+ substring(convert(VARCHAR(7),@tdout) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@remain) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@bdo) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@ip_bed) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@vac) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@exc) + space(7), 1, 7)
    --			+ substring(convert(VARCHAR(7),@dp_bed) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dp_dsch) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@dp_deth) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(7),@los) + space(7), 1, 7)
    			+ substring(convert(VARCHAR(4),@days) + space(4), 1, 4)
    		print @string
    	end
    */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_ciwl" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
