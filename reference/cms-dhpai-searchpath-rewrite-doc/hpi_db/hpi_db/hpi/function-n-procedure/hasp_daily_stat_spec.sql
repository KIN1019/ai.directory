-- DROP PROCEDURE hpi.hasp_daily_stat_spec(inout int4, in timestamp, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hasp_daily_stat_spec(INOUT pas_return_code integer, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_hospital_code character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_last_report_date TIMESTAMP WITHOUT TIME ZONE;
    var_tx_type VARCHAR(6);
    var_src_ind VARCHAR(2);
    var_adm_date TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_tx_date TIMESTAMP WITHOUT TIME ZONE;
    var_date TIMESTAMP WITHOUT TIME ZONE;
    var_last_date TIMESTAMP WITHOUT TIME ZONE;
    var_hosp VARCHAR(6);
    var_adm INTEGER;
    var_xin INTEGER;
    var_xout INTEGER;
    var_td INTEGER;
    var_ret_td INTEGER;
    var_canc_adm INTEGER;
    var_canc_xin INTEGER;
    var_canc_xout INTEGER;
    var_canc_td INTEGER;
    var_canc_ret_td INTEGER;
    var_ward VARCHAR(8);
    var_ae_day INTEGER;
    var_ttl_ae_day INTEGER;
    var_canc_ae_day INTEGER;
    var_in_out INTEGER;
    var_remain INTEGER;
    var_bdo INTEGER;
    var_bda INTEGER;
    var_ebd INTEGER;
    var_vbd INTEGER;
    var_dsch INTEGER;
    var_canc_dsch INTEGER;
    var_bed INTEGER;
    var_string VARCHAR(220);
    var_ae_adm INTEGER;
    var_canc_ae_adm INTEGER;
    var_death INTEGER;
    var_canc_death INTEGER;
    var_spec VARCHAR(8);
    var_day_dsch INTEGER;
    var_day_deth INTEGER;
    var_loc VARCHAR(8);
    var_day_bed INTEGER;
    var_home_ip_dsch INTEGER;
    var_home_ip_deth INTEGER;
    var_home_dp_dsch INTEGER;
    var_home_dp_deth INTEGER;
    var_prev_stat_date TIMESTAMP WITHOUT TIME ZONE;
    var_case VARCHAR(24);
    ws_csr CURSOR FOR
    SELECT
        ungrouped_query.Specialty_code, ungrouped_query.Treatment_location, sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7, sum_8, sum_9, sum_10, sum_11, sum_12, SUM(COALESCE(AE_day_discharge, 0)) + SUM(COALESCE(AE_day_death, 0)), SUM(COALESCE(Canc_AE_day_discharge, 0)) + SUM(COALESCE(Canc_AE_day_death, 0)), sum_13, sum_14, sum_15, sum_16, SUM(COALESCE(Day_discharge, 0)) - SUM(COALESCE(Canc_day_discharge, 0)), SUM(COALESCE(Day_death, 0)) - SUM(COALESCE(Canc_day_death, 0))
        FROM (SELECT
            Specialty_code, Treatment_location, SUM(COALESCE(AE_day_discharge, 0)) + SUM(COALESCE(AE_day_death, 0)), SUM(COALESCE(Canc_AE_day_discharge, 0)) + SUM(COALESCE(Canc_AE_day_death, 0)), SUM(COALESCE(Day_discharge, 0)) - SUM(COALESCE(Canc_day_discharge, 0)), SUM(COALESCE(Day_death, 0)) - SUM(COALESCE(Canc_day_death, 0))
            FROM Ward_spec_tx_adj_view AS a) AS ungrouped_query
        INNER JOIN (SELECT
            Specialty_code, Treatment_location, SUM(COALESCE(Admission, 0)) AS sum_1, SUM(COALESCE(Transfer_in, 0)) AS sum_2, SUM(COALESCE(Transfer_out, 0)) AS sum_3, SUM(COALESCE(Discharge, 0)) AS sum_4, SUM(COALESCE(Transfer_out_to_TD, 0)) AS sum_5, SUM(COALESCE(Transfer_in_from_TD, 0)) AS sum_6, SUM(COALESCE(Canc_admission, 0)) AS sum_7, SUM(COALESCE(Canc_transfer_in, 0)) AS sum_8, SUM(COALESCE(Canc_transfer_out, 0)) AS sum_9, SUM(COALESCE(Canc_discharge, 0)) AS sum_10, SUM(COALESCE(Canc_transfer_out_to_TD, 0)) AS sum_11, SUM(COALESCE(Canc_transfer_in_from_TD, 0)) AS sum_12, SUM(COALESCE(Admission_thru_AE, 0)) AS sum_13, SUM(COALESCE(Canc_admission_thru_AE, 0)) AS sum_14, SUM(COALESCE(Death, 0)) AS sum_15, SUM(COALESCE(Canc_death, 0)) AS sum_16
            FROM Ward_spec_tx_adj_view AS a
            WHERE Ward_spec_tx_date = var_date AND Ward_code <> 'HOME' AND Specialty_code <> 'HOME' AND Hospital_code = var_hosp
            GROUP BY Specialty_code, Treatment_location) AS grouped_query
            ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL));
    tx_csr CURSOR FOR
    /* --	select Source_indicator, Admission_datetime, Discharge_datetime, */
    /* --		Transaction_type, From_specialty_code, From_treatment_location, */
    SELECT
        Case_no, Transaction_type, From_specialty_code, From_treatment_location, Transaction_datetime
        /* --from Transaction_log t (index XIE2Transaction_Log), ADT_Case c */
        FROM Transaction_log
        /* --		where Transaction_datetime >= dateadd(dd,1,@last_report_date) */
        /* --		where Transaction_datetime >= @date */
        WHERE Transaction_datetime >= 1 * INTERVAL '1 day' + var_prev_stat_date::TIMESTAMP AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Hospital_code = var_hosp AND From_ward_code <> 'HOME' AND From_specialty_code <> 'HOME' AND Cancel_flag IS NULL
    /* --and t.Case_no = c.Case_no */
    /* --and t.Hospital_code = c.Hospital_code */;
    bed_csr CURSOR FOR
    SELECT
        ungrouped_query.Ward_code, ungrouped_query.Specialty_code, Official_bed, Day_bed
        FROM (SELECT
            Ward_code, Specialty_code, Official_bed, Day_bed, Effective_date
            FROM Ward_specialty AS a) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, Specialty_code, MAX(Effective_date) AS max_1
            FROM Ward_specialty AS a
            WHERE Effective_date <= var_date AND Hospital_code = var_hosp
            GROUP BY Ward_code, Specialty_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
        WHERE Effective_date = max_1;
    loc_csr CURSOR FOR
    SELECT
        exc_spec, exc_loc, exc_remain, exc_ae_day, exc_bda, exc_adm, exc_ae_adm, exc_day_dsch, exc_day_deth, exc_dsch, exc_deth, exc_day_bed
        FROM t$exc_table
        WHERE exc_loc IS NOT NULL AND (exc_remain <> 0 OR exc_ae_day <> 0 OR exc_bda <> 0 OR exc_adm <> 0 OR exc_ae_adm <> 0 OR exc_day_dsch <> 0 OR exc_day_deth <> 0 OR exc_dsch <> 0 OR exc_deth <> 0 OR exc_day_bed <> 0);
    out_csr CURSOR FOR
    SELECT
        out_spec, out_remain, out_ae_day, out_bdo, out_vbd, out_bda, out_ebd, out_adm, out_ae_adm, out_day_dsch, out_day_deth, out_dsch, out_deth, out_day_bed
        FROM t$out_table
        WHERE out_remain <> 0 OR out_ae_day <> 0 OR out_bdo <> 0 OR out_vbd <> 0 OR out_bda <> 0 OR out_ebd <> 0 OR out_adm <> 0 OR out_ae_adm <> 0 OR out_day_dsch <> 0 OR out_day_deth <> 0 OR out_dsch <> 0 OR out_deth <> 0 OR out_day_bed <> 0
        ORDER BY out_spec NULLS FIRST;
BEGIN

    DROP TABLE IF EXISTS t$exc_table;
    DROP TABLE IF EXISTS t$out_table;
    DROP TABLE IF EXISTS t$start_table;

    SELECT
        last_reported_date
        INTO var_last_report_date
        FROM hospital_config
        WHERE Hospital_code = par_hospital_code;
    DELETE FROM daily_spec_summary;

    IF par_input_to_date IS NULL THEN
        SELECT
            - 1 * INTERVAL '1 day' + localtimestamp::TIMESTAMP
            INTO par_input_to_date;
    END IF;

    IF par_input_from_date IS NULL THEN
        SELECT
            - 14 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
            INTO par_input_from_date;
    END IF;
    SELECT
        1 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
        INTO par_input_to_date;
    SELECT
        par_input_from_date, par_input_to_date
        INTO var_date, var_last_date;
    /* select @hosp = Hospital_code */
    
    /* --	from Hospital */
    SELECT
        par_hospital_code
        INTO var_hosp;
    CREATE TEMPORARY TABLE t$exc_table
    (exc_spec CHAR(4),
        exc_loc CHAR(4) NULL,
        exc_prev_remain INTEGER DEFAULT 0 NULL,
        exc_remain INTEGER DEFAULT 0 NULL,
        exc_ae_day INTEGER DEFAULT 0 NULL,
        exc_bdo INTEGER DEFAULT 0 NULL,
        exc_bda INTEGER DEFAULT 0 NULL,
        exc_ebd INTEGER DEFAULT 0 NULL,
        exc_vbd INTEGER DEFAULT 0 NULL,
        exc_adm INTEGER DEFAULT 0 NULL,
        exc_ae_adm INTEGER DEFAULT 0 NULL,
        exc_day_dsch INTEGER DEFAULT 0 NULL,
        exc_day_deth INTEGER DEFAULT 0 NULL,
        exc_dsch INTEGER DEFAULT 0 NULL,
        exc_deth INTEGER DEFAULT 0 NULL,
        exc_day_bed INTEGER DEFAULT 0 NULL);
    CREATE TEMPORARY TABLE t$out_table
    (out_spec CHAR(4),
        out_remain INTEGER DEFAULT 0 NULL,
        out_ae_day INTEGER DEFAULT 0 NULL,
        out_bdo INTEGER DEFAULT 0 NULL,
        out_bda INTEGER DEFAULT 0 NULL,
        out_ebd INTEGER DEFAULT 0 NULL,
        out_vbd INTEGER DEFAULT 0 NULL,
        out_adm INTEGER DEFAULT 0 NULL,
        out_ae_adm INTEGER DEFAULT 0 NULL,
        out_day_dsch INTEGER DEFAULT 0 NULL,
        out_day_deth INTEGER DEFAULT 0 NULL,
        out_dsch INTEGER DEFAULT 0 NULL,
        out_deth INTEGER DEFAULT 0 NULL,
        out_day_bed INTEGER DEFAULT 0 NULL);
    CREATE TEMPORARY TABLE t$start_table
    (tx_date TIMESTAMP WITHOUT TIME ZONE,
        ward_code CHAR(4),
        spec_code CHAR(4),
        treat_loc CHAR(4) NULL);

    WHILE var_date < var_last_date LOOP
        TRUNCATE TABLE t$exc_table;
        TRUNCATE TABLE t$out_table;
        TRUNCATE TABLE t$start_table;
        INSERT INTO t$start_table
        SELECT
            MAX(w.Ward_spec_tx_date), w.Ward_code, w.Specialty_code, w.Treatment_location
            FROM Ward_spec_tx as w
            WHERE w.Ward_spec_tx_date < var_date AND w.Hospital_code = var_hosp::VARCHAR AND w.Ward_code <> 'HOME' AND w.Specialty_code <> 'HOME'
            GROUP BY w.Ward_code, w.Specialty_code, w.Treatment_location;
        SELECT
            MAX(tx_date)
            INTO var_prev_stat_date
            FROM t$start_table;
        INSERT INTO t$exc_table (exc_spec, exc_loc, exc_prev_remain)
        SELECT
            spec_code, treat_loc, SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) + SUM(COALESCE(Transfer_in, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out, 0)) - SUM(COALESCE(Discharge, 0)) - SUM(COALESCE(Death, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) - SUM(COALESCE(Canc_admission, 0)) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) + SUM(COALESCE(Canc_discharge, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Canc_transfer_out_to_TD, 0))
            FROM t$start_table as t, Ward_spec_tx_adj_view as w
            WHERE tx_date = Ward_spec_tx_date AND Hospital_code = var_hosp AND t.ward_code = w.Ward_code AND spec_code = Specialty_code AND COALESCE(treat_loc, 'null') = COALESCE(Treatment_location, 'null')
            GROUP BY spec_code, treat_loc;
        UPDATE t$exc_table
        SET exc_remain = exc_prev_remain, exc_ebd = 0, exc_bda = 0, exc_vbd = 0, exc_bdo = 0, exc_ae_day = 0, exc_adm = 0, exc_ae_adm = 0, exc_day_dsch = 0, exc_day_deth = 0, exc_dsch = 0, exc_deth = 0, exc_day_bed = 0;
        /*
        if @date <= @last_report_date
        begin
        	open ws_csr
        	fetch ws_csr into @spec, @loc, @adm, @xin, @xout, @dsch, @td,
        		@ret_td, @canc_adm, @canc_xin, @canc_xout, @canc_dsch,
        		@canc_td, @canc_ret_td, @ae_day, @canc_ae_day,
        		@ae_adm, @canc_ae_adm, @death, @canc_death,
        		@day_dsch, @day_deth
        	while @@sqlstatus = 0
        	begin
        		select @in_out = @adm + @xin + @ret_td - @xout - @dsch
        			- @td - @canc_adm - @canc_xin - @canc_ret_td
        			+ @canc_xout + @canc_dsch + @canc_td
        			- @death + @canc_death,
        			@ttl_ae_day = @ae_day - @canc_ae_day
        		if exists(select * from #exc_table
        			where exc_spec = @spec
        			and isnull(exc_loc,'null') = isnull(@loc,'null'))
        			update #exc_table set
        				exc_remain = exc_remain + @in_out,
        				exc_ae_day = exc_ae_day + @ttl_ae_day,
        				exc_adm = exc_adm + @adm - @canc_adm,
        				exc_ae_adm = exc_ae_adm + @ae_adm - @canc_ae_adm,
        				exc_day_dsch = exc_day_dsch + @day_dsch,
        				exc_day_deth = exc_day_deth + @day_deth,
        				exc_dsch = exc_dsch + @dsch - @canc_dsch,
        				exc_deth = exc_deth + @death - @canc_death
        				where exc_spec = @spec
        				and isnull(exc_loc,'null') = isnull(@loc,'null')
        		else
        			insert into #exc_table values
        				(@spec, @loc, 0, @in_out, @ttl_ae_day, 0,0,0,0,
        				@adm - @canc_adm, @ae_adm - @canc_ae_adm, @day_dsch,
        				@day_deth, @dsch - @canc_dsch, @death - @canc_death, 0)
        		fetch ws_csr into @spec, @loc, @adm, @xin, @xout, @dsch, @td,
        			@ret_td, @canc_adm, @canc_xin, @canc_xout, @canc_dsch,
        			@canc_td, @canc_ret_td, @ae_day, @canc_ae_day,
        			@ae_adm, @canc_ae_adm, @death, @canc_death,
        			@day_dsch, @day_deth
        	end
        	close ws_csr
        end
        else
        begin
        */
        OPEN tx_csr;
        /* --		fetch tx_csr into @src_ind, @adm_date, @dsch_date, @tx_type, */
        FETCH tx_csr INTO var_case, var_tx_type, var_spec, var_loc, var_tx_date;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                INTO var_adm, var_ae_adm, var_ae_day, var_xin, var_xout, var_td, var_ret_td, var_dsch, var_death, var_day_dsch, var_day_deth, var_in_out;
            SELECT
                source_indicator, admission_dtm, discharge_dtm
                INTO var_src_ind, var_adm_date, var_dsch_date
                /* ---from cpi..cpi_case    ----CPI -- */
                FROM cpi_case
                /* --- HPI version --- */
                WHERE case_no = var_case AND hospital_code = var_hosp;

            IF var_tx_type = '100' THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        SELECT
                            1
                            INTO var_adm;
                    END IF;
                    SELECT
                        1
                        INTO var_in_out;

                    IF var_src_ind = '3' THEN
                        SELECT
                            1
                            INTO var_ae_adm;
                    END IF;
                END;
            END IF;

            IF var_tx_type = '141' THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        SELECT
                            1
                            INTO var_xin;
                    END IF;
                    SELECT
                        1
                        INTO var_in_out;
                END;
            END IF;

            IF var_tx_type = '140' THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        SELECT
                            1
                            INTO var_xout;
                    END IF;
                    SELECT
                        - 1
                        INTO var_in_out;
                END;
            END IF;

            IF var_tx_type = '160' THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        SELECT
                            1
                            INTO var_td;
                    END IF;
                    SELECT
                        - 1
                        INTO var_in_out;
                END;
            END IF;

            IF var_tx_type = '171' THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        SELECT
                            1
                            INTO var_ret_td;
                    END IF;
                    SELECT
                        1
                        INTO var_in_out;
                END;
            END IF;

            IF var_tx_type LIKE '13_' AND var_tx_type <> '131' THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        SELECT
                            1
                            INTO var_dsch;
                    END IF;
                    SELECT
                        - 1
                        INTO var_in_out;

                    IF DATE_PART('days', var_dsch_date::TIMESTAMP - var_adm_date::TIMESTAMP) = 0 THEN
                        IF var_src_ind = '3' THEN
                            SELECT
                                1
                                INTO var_ae_day;
                        ELSE
                            SELECT
                                1
                                INTO var_day_dsch;
                        END IF;
                    END IF;
                END;
            END IF;

            IF var_tx_type = '131' THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        SELECT
                            1
                            INTO var_death;
                    END IF;
                    SELECT
                        - 1
                        INTO var_in_out;

                    IF DATE_PART('days', var_dsch_date::TIMESTAMP - var_adm_date::TIMESTAMP) = 0 THEN
                        IF var_src_ind = '3' THEN
                            SELECT
                                1
                                INTO var_ae_day;
                        ELSE
                            SELECT
                                1
                                INTO var_day_deth;
                        END IF;
                    END IF;
                END;
            END IF;

            IF EXISTS (SELECT
                *
                FROM t$exc_table
                WHERE exc_spec = var_spec AND COALESCE(exc_loc, 'null') = COALESCE(var_loc, 'null')) THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        UPDATE t$exc_table
                        SET exc_remain = exc_remain + var_in_out, exc_ae_day = exc_ae_day + var_ae_day, exc_adm = exc_adm + var_adm, exc_ae_adm = exc_ae_adm + var_ae_adm, exc_day_dsch = exc_day_dsch + var_day_dsch, exc_day_deth = exc_day_deth + var_day_deth, exc_dsch = exc_dsch + var_dsch, exc_deth = exc_deth + var_death
                            WHERE exc_spec = var_spec AND COALESCE(exc_loc, 'null') = COALESCE(var_loc, 'null');
                    ELSE
                        UPDATE t$exc_table
                        SET exc_remain = exc_remain + var_in_out
                            WHERE exc_spec = var_spec AND COALESCE(exc_loc, 'null') = COALESCE(var_loc, 'null');
                    END IF;
                END;
            ELSE
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        INSERT INTO t$exc_table
                        VALUES (var_spec, var_loc, 0, var_in_out, var_ae_day, 0, 0, 0, 0, var_adm, var_ae_adm, var_day_dsch, var_day_deth, var_dsch, var_death, 0);
                    ELSE
                        INSERT INTO t$exc_table
                        VALUES (var_spec, var_loc, 0, var_in_out, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                    END IF;
                END;
            END IF;
            /* --fetch tx_csr into @src_ind, @adm_date, @dsch_date, @tx_type, */
            FETCH tx_csr INTO var_case, var_tx_type, var_spec, var_loc, var_tx_date;
        END LOOP;
        CLOSE tx_csr;
        /* end */
        OPEN bed_csr;
        FETCH bed_csr INTO var_ward, var_spec, var_bed, var_day_bed;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF var_bed > 0 OR var_day_bed > 0 THEN
                IF EXISTS (SELECT
                    *
                    FROM t$exc_table
                    WHERE exc_spec = var_spec AND exc_loc IS NULL) THEN
                    UPDATE t$exc_table
                    SET exc_bda = exc_bda + var_bed, exc_day_bed = exc_day_bed + var_day_bed
                        WHERE exc_spec = var_spec AND exc_loc IS NULL;
                ELSE
                    INSERT INTO t$exc_table
                    VALUES (var_spec, NULL, 0, 0, 0, 0, var_bed, 0, 0, 0, 0, 0, 0, 0, 0, var_day_bed);
                END IF;
            END IF;
            FETCH bed_csr INTO var_ward, var_spec, var_bed, var_day_bed;
        END LOOP;
        CLOSE bed_csr;
        DELETE FROM t$exc_table
            WHERE exc_prev_remain = 0 AND exc_remain = 0 AND exc_ae_day = 0 AND exc_bdo = 0 AND exc_bda = 0 AND exc_ebd = 0 AND exc_vbd = 0 AND exc_adm = 0 AND exc_ae_adm = 0 AND exc_day_dsch = 0 AND exc_day_deth = 0 AND exc_dsch = 0 AND exc_deth = 0 AND exc_day_bed = 0;
        
        UPDATE t$exc_table
        SET exc_loc = (SELECT
            IMIS_code
            FROM Specialty
            WHERE Specialty_code = exc_loc AND Hospital_code = var_hosp AND Effective_date = (SELECT
                MAX(Effective_date)
                FROM Specialty
                WHERE Specialty_code = exc_loc AND Hospital_code = var_hosp AND Effective_date <= var_date))
        WHERE exc_loc IS NOT NULL;
       
        UPDATE t$exc_table
        SET exc_spec = (SELECT
            IMIS_code
            FROM Specialty
            WHERE Specialty_code = a.exc_spec AND Hospital_code = var_hosp AND Effective_date = (SELECT
                MAX(Effective_date)
                FROM Specialty
                WHERE Specialty_code = a.exc_spec AND Hospital_code = var_hosp AND Effective_date <= var_date))
        FROM t$exc_table AS a;
        INSERT INTO t$out_table
        SELECT
            exc_spec, SUM(exc_remain), SUM(exc_ae_day), SUM(exc_bdo), SUM(exc_bda), SUM(exc_ebd), SUM(exc_vbd), SUM(exc_adm), SUM(exc_ae_adm), SUM(exc_day_dsch), SUM(exc_day_deth), SUM(exc_dsch), SUM(exc_deth), SUM(exc_day_bed)
            FROM t$exc_table
            WHERE exc_loc IS NULL
            GROUP BY exc_spec;
        OPEN loc_csr;
        FETCH loc_csr INTO var_spec, var_loc, var_remain, var_ae_day, var_bda, var_adm, var_ae_adm, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF var_loc IN ('ICU', 'CCU', 'PRI', 'SCB', 'PIC', 'NIC') THEN
                IF EXISTS (SELECT
                    *
                    FROM t$out_table
                    WHERE out_spec = var_loc) THEN
                    UPDATE t$out_table
                    SET out_remain = out_remain + var_remain, out_ae_day = out_ae_day + var_ae_day, out_bda = out_bda + var_bda, out_adm = out_adm + var_adm, out_ae_adm = out_ae_adm + var_ae_adm, out_day_dsch = out_day_dsch + var_day_dsch, out_day_deth = out_day_deth + var_day_deth, out_dsch = out_dsch + var_dsch, out_deth = out_deth + var_death, out_day_bed = out_day_bed + var_day_bed
                        WHERE out_spec = var_loc;
                ELSE
                    INSERT INTO t$out_table
                    VALUES (var_loc, var_remain, var_ae_day, 0, var_bda, 0, 0, var_adm, var_ae_adm, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed);
                END IF;
            ELSE
                IF EXISTS (SELECT
                    *
                    FROM t$out_table
                    WHERE out_spec = var_spec) THEN
                    UPDATE t$out_table
                    SET out_remain = out_remain + var_remain, out_ae_day = out_ae_day + var_ae_day, out_bda = out_bda + var_bda, out_adm = out_adm + var_adm, out_ae_adm = out_ae_adm + var_ae_adm, out_day_dsch = out_day_dsch + var_day_dsch, out_day_deth = out_day_deth + var_day_deth, out_dsch = out_dsch + var_dsch, out_deth = out_deth + var_death, out_day_bed = out_day_bed + var_day_bed
                        WHERE out_spec = var_spec;
                ELSE
                    INSERT INTO t$out_table
                    VALUES (var_spec, var_remain, var_ae_day, 0, var_bda, 0, 0, var_adm, var_ae_adm, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed);
                END IF;
            END IF;
            FETCH loc_csr INTO var_spec, var_loc, var_remain, var_ae_day, var_bda, var_adm, var_ae_adm, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed;
        END LOOP;
        CLOSE loc_csr;
        SELECT
            0, 0, 0, 0
            INTO var_home_ip_dsch, var_home_ip_deth, var_home_dp_dsch, var_home_dp_deth;
        /*
        if @date <= @last_report_date
        begin
        	select @home_ip_dsch = isnull(Discharge,0)
        			- isnull(Canc_discharge,0),
        		@home_ip_deth = isnull(Death,0) - isnull(Canc_death,0),
        		@home_dp_dsch = isnull(Day_discharge,0)
        			- isnull(Canc_day_discharge,0),
        		@home_dp_deth = isnull(Day_death,0)
        			- isnull(Canc_day_death, 0)
        		from Ward_spec_tx_adj_view
        		where Ward_code = 'HOME'
        		and Specialty_code = 'HOME'
        		and Ward_spec_tx_date = @date
        		and Hospital_code = @hosp
        end
        else
        begin
        */
        SELECT
            COALESCE(COUNT(*), 0)
            INTO var_home_ip_dsch
            FROM Transaction_log AS t
            WHERE Transaction_datetime >= var_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Transaction_type LIKE '13_' AND Transaction_type <> '131' AND Hospital_code = var_hosp AND Cancel_flag IS NULL AND From_ward_code = 'HOME' AND From_specialty_code = 'HOME';
        SELECT
            COALESCE(COUNT(*), 0)
            INTO var_home_ip_deth
            FROM Transaction_log AS t
            WHERE Transaction_datetime >= var_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Transaction_type = '131' AND Hospital_code = var_hosp AND Cancel_flag IS NULL AND From_ward_code = 'HOME' AND From_specialty_code = 'HOME';
        SELECT
            COALESCE(COUNT(*), 0)
            INTO var_home_dp_dsch
            /* --from Transaction_log t (index XIE2Transaction_Log), ADT_Case c */
            FROM Transaction_log AS t, cpi_case AS c /* ---HPI */
            WHERE Transaction_datetime >= var_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Transaction_type LIKE '13_' AND Transaction_type <> '131' AND t.Hospital_code = var_hosp AND Cancel_flag IS NULL AND From_ward_code = 'HOME' AND From_specialty_code = 'HOME' AND t.Case_no = c.case_no AND /* ---cpi_case--- */ t.Hospital_code = c.hospital_code AND DATE_PART('days', discharge_dtm::TIMESTAMP - admission_dtm::TIMESTAMP) = 0;
        /* --and t.Case_no = c.Case_no */
        /* --and t.Hospital_code = c.Hospital_code */
        /* --and datediff(dd,Admission_datetime,Discharge_datetime) = 0 */
        SELECT
            COALESCE(COUNT(*), 0)
            INTO var_home_dp_deth
            /* --from Transaction_log t (index XIE2Transaction_Log), ADT_Case c */
            FROM Transaction_log AS t, cpi_case AS c /* ---HPI */
            WHERE Transaction_datetime >= var_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Transaction_type = '131' AND t.Hospital_code = var_hosp AND Cancel_flag IS NULL AND From_ward_code = 'HOME' AND From_specialty_code = 'HOME' AND t.Case_no = c.case_no AND /* ---cpi_case--- */ t.Hospital_code = c.hospital_code AND DATE_PART('days', discharge_dtm::TIMESTAMP - admission_dtm::TIMESTAMP) = 0;
        /* --and t.Case_no = c.Case_no */
        /* --and t.Hospital_code = c.Hospital_code */
        /* --and datediff(dd,Admission_datetime,Discharge_datetime) = 0 */
        /* end */
        IF var_home_ip_dsch <> 0 OR var_home_dp_dsch <> 0 OR var_home_ip_deth <> 0 OR var_home_dp_deth <> 0 THEN
            IF EXISTS (SELECT
                *
                FROM t$out_table
                WHERE out_spec = 'PSY') THEN
                UPDATE t$out_table
                SET out_dsch = out_dsch + var_home_ip_dsch, out_deth = out_deth + var_home_ip_deth, out_day_dsch = out_day_dsch + var_home_dp_dsch, out_day_deth = out_day_deth + var_home_dp_deth
                    WHERE out_spec = 'PSY';
            ELSE
                INSERT INTO t$out_table
                VALUES ('PSY', 0, 0, 0, 0, 0, 0, 0, 0, var_home_dp_dsch, var_home_dp_deth, var_home_ip_dsch, var_home_ip_deth, 0);
            END IF;
        END IF;
        UPDATE t$out_table
        SET out_bdo = out_remain + out_ae_day;
        UPDATE t$out_table
        SET out_ebd = out_bdo - out_bda, out_vbd = 0
            WHERE out_bdo > out_bda;
        UPDATE t$out_table
        SET out_vbd = out_bda - out_bdo, out_ebd = 0
            WHERE out_bda > out_bdo;
        UPDATE t$out_table
        SET out_dsch = out_dsch - out_day_dsch, out_deth = out_deth - out_day_deth;
        OPEN out_csr;
        FETCH out_csr INTO var_spec, var_remain, var_ae_day, var_bdo, var_vbd, var_bda, var_ebd, var_adm, var_ae_adm, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            /*
            select @string = substring(@hosp + space(3), 1, 3)
            	+ convert(char(8),@date,112)
            	+ substring(@spec + space(3), 1, 3)
            	+ right('00000000' + convert(char(8),@ae_adm), 8)
            	+ right('00000000' + convert(char(8),@adm), 8)
            	+ right('00000000' + convert(char(8),@ae_day), 8)
            	+ right('00000000' + convert(char(8),@remain), 8)
            	+ right('00000000' + convert(char(8),@bdo), 8)
            	+ right('00000000' + convert(char(8),@vbd), 8)
            	+ right('00000000' + convert(char(8),@bda), 8)
            	+ right('00000000' + convert(char(8),@ebd), 8)
            	+ right('00000000' + convert(char(8),@day_dsch), 8)
            	+ right('00000000' + convert(char(8),@day_deth), 8)
            	+ right('00000000' + convert(char(8),@dsch), 8)
            	+ right('00000000' + convert(char(8),@death), 8)
            print @string
            */
            INSERT INTO daily_spec_summary
            VALUES (var_hosp, var_date, var_spec, var_ae_adm, var_adm, var_ae_day, var_remain, var_bdo, var_vbd, var_bda, var_ebd, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed);
            FETCH out_csr INTO var_spec, var_remain, var_ae_day, var_bdo, var_vbd, var_bda, var_ebd, var_adm, var_ae_adm, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed;
        END LOOP;
        CLOSE out_csr;
        UPDATE t$exc_table
        SET exc_prev_remain = exc_remain;
        SELECT
            1 * INTERVAL '1 day' + var_date::TIMESTAMP
            INTO var_date;
    END LOOP;

END;
$procedure$
;

;ALTER PROCEDURE "hasp_daily_stat_spec" OWNER TO "HPI_SCHEMA_OWNER_ROLE";