-- DROP PROCEDURE hpi.hasp_daily_stat_ward(inout int4, in timestamp, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hasp_daily_stat_ward(INOUT pas_return_code integer, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_hospital_code character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_last_report_date TIMESTAMP WITHOUT TIME ZONE;
    var_tx_type VARCHAR(6);
    var_adm_date TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_src_ind VARCHAR(2);
    var_tx_date TIMESTAMP WITHOUT TIME ZONE;
    var_date TIMESTAMP WITHOUT TIME ZONE;
    var_last_date TIMESTAMP WITHOUT TIME ZONE;
    var_hosp VARCHAR(6);
    var_case_no VARCHAR(24);
    var_prev_stat_date TIMESTAMP WITHOUT TIME ZONE;
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
    var_day_dsch INTEGER;
    var_day_deth INTEGER;
    var_loc VARCHAR(8);
    var_spec VARCHAR(8);
    var_desc VARCHAR(60);
    var_home_ip_dsch INTEGER;
    var_home_ip_deth INTEGER;
    var_home_dp_dsch INTEGER;
    var_home_dp_deth INTEGER;
    var_day_bed INTEGER;
    var_ttl_adm INTEGER;
    var_ttl_ae_adm INTEGER;
    var_ttl_dsch INTEGER;
    var_ttl_deth INTEGER;
    ws_csr CURSOR FOR
    SELECT
        ungrouped_query.Ward_code, sum_1, sum_2, sum_3, sum_4, sum_5, sum_6, sum_7, sum_8, sum_9, sum_10, sum_11, sum_12, SUM(COALESCE(AE_day_discharge, 0)) + SUM(COALESCE(AE_day_death, 0)), SUM(COALESCE(Canc_AE_day_discharge, 0)) + SUM(COALESCE(Canc_AE_day_death, 0)), sum_13, sum_14, sum_15, sum_16, SUM(COALESCE(Day_discharge, 0)) - SUM(COALESCE(Canc_day_discharge, 0)), SUM(COALESCE(Day_death, 0)) - SUM(COALESCE(Canc_day_death, 0))
        FROM (SELECT
            Ward_code, SUM(COALESCE(AE_day_discharge, 0)) + SUM(COALESCE(AE_day_death, 0)), SUM(COALESCE(Canc_AE_day_discharge, 0)) + SUM(COALESCE(Canc_AE_day_death, 0)), SUM(COALESCE(Day_discharge, 0)) - SUM(COALESCE(Canc_day_discharge, 0)), SUM(COALESCE(Day_death, 0)) - SUM(COALESCE(Canc_day_death, 0))
            FROM Ward_spec_tx_adj_view AS a) AS ungrouped_query
        INNER JOIN (SELECT
            Ward_code, SUM(COALESCE(Admission, 0)) AS sum_1, SUM(COALESCE(Transfer_in, 0)) AS sum_2, SUM(COALESCE(Transfer_out, 0)) AS sum_3, SUM(COALESCE(Discharge, 0)) AS sum_4, SUM(COALESCE(Transfer_out_to_TD, 0)) AS sum_5, SUM(COALESCE(Transfer_in_from_TD, 0)) AS sum_6, SUM(COALESCE(Canc_admission, 0)) AS sum_7, SUM(COALESCE(Canc_transfer_in, 0)) AS sum_8, SUM(COALESCE(Canc_transfer_out, 0)) AS sum_9, SUM(COALESCE(Canc_discharge, 0)) AS sum_10, SUM(COALESCE(Canc_transfer_out_to_TD, 0)) AS sum_11, SUM(COALESCE(Canc_transfer_in_from_TD, 0)) AS sum_12, SUM(COALESCE(Admission_thru_AE, 0)) AS sum_13, SUM(COALESCE(Canc_admission_thru_AE, 0)) AS sum_14, SUM(COALESCE(Death, 0)) AS sum_15, SUM(COALESCE(Canc_death, 0)) AS sum_16
            FROM Ward_spec_tx_adj_view AS a
            WHERE Ward_spec_tx_date = var_date AND Hospital_code = var_hosp AND Ward_code <> 'HOME' AND Specialty_code <> 'HOME'
            GROUP BY Ward_code) AS grouped_query
            ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL));
    tx_csr CURSOR FOR
    /* --select Source_indicator, Admission_datetime, discharge_datetime, */
    /* --	Transaction_type, From_ward_code, Transaction_datetime */
    /* from Transaction_log  t (index XIE2Transaction_Log), ADT_Case c */
    SELECT
        Case_no, Transaction_type, From_ward_code, Transaction_datetime
        FROM Transaction_log
        /* --where Transaction_datetime >= dateadd(dd,1,@last_report_date) */
        WHERE Transaction_datetime >= 1 * INTERVAL '1 day' + var_prev_stat_date::TIMESTAMP AND /* ---20120622 */ Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Hospital_code = var_hosp AND Cancel_flag IS NULL
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
    out_csr CURSOR FOR
    SELECT
        exc_ward, exc_ae_adm, exc_adm, exc_ae_day, exc_remain, exc_bdo, exc_vbd, exc_bda, exc_ebd, exc_day_dsch, exc_day_deth, exc_ip_dsch, exc_ip_deth, exc_day_bed
        FROM t$exc_table
        WHERE exc_ae_adm <> 0 OR exc_adm <> 0 OR exc_ae_day <> 0 OR exc_remain <> 0 OR exc_bdo <> 0 OR exc_vbd <> 0 OR exc_bda <> 0 OR exc_ebd <> 0 OR exc_day_dsch <> 0 OR exc_day_deth <> 0 OR exc_ip_dsch <> 0 OR exc_ip_deth <> 0 OR exc_day_bed <> 0
        ORDER BY exc_ward NULLS FIRST;
begin

    DROP TABLE IF EXISTS t$exc_table;
    DROP TABLE IF EXISTS t$start_table;
	
    SELECT
        Last_reported_date
        INTO var_last_report_date
        FROM hospital_config
        WHERE Hospital_code = par_hospital_code;
    DELETE FROM daily_ward_summary;

    IF par_input_to_date IS NULL THEN
        SELECT
            - 1 * INTERVAL '1 day' + to_char(localtimestamp)::TIMESTAMP
            INTO par_input_to_date;
    END IF;

    IF par_input_from_date IS NULL THEN
        SELECT
            - 13 * INTERVAL '1 day' + par_input_to_date::TIMESTAMP
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
    (exc_ward VARCHAR(4),
        exc_prev_remain INTEGER DEFAULT 0 NULL,
        exc_ae_adm INTEGER DEFAULT 0 NULL,
        exc_adm INTEGER DEFAULT 0 NULL,
        exc_ae_day INTEGER DEFAULT 0 NULL,
        exc_remain INTEGER DEFAULT 0 NULL,
        exc_bdo INTEGER DEFAULT 0 NULL,
        exc_vbd INTEGER DEFAULT 0 NULL,
        exc_bda INTEGER DEFAULT 0 NULL,
        exc_ebd INTEGER DEFAULT 0 NULL,
        exc_day_dsch INTEGER DEFAULT 0 NULL,
        exc_day_deth INTEGER DEFAULT 0 NULL,
        exc_ip_dsch INTEGER DEFAULT 0 NULL,
        exc_ip_deth INTEGER DEFAULT 0 NULL,
        exc_day_bed INTEGER DEFAULT 0 NULL);
    CREATE TEMPORARY TABLE t$start_table
    (tx_date TIMESTAMP WITHOUT TIME ZONE,
        ward_code VARCHAR(4),
        spec_code VARCHAR(4),
        treat_loc VARCHAR(4) NULL);

    WHILE var_date < var_last_date LOOP
        TRUNCATE TABLE t$exc_table;
        TRUNCATE TABLE t$start_table;
        INSERT INTO t$start_table
        SELECT
            MAX(Ward_spec_tx_date), Ward_code, Specialty_code, Treatment_location
            FROM Ward_spec_tx
            WHERE Ward_spec_tx_date < var_date AND Hospital_code = var_hosp::VARCHAR AND Ward_code <> 'HOME' AND Specialty_code <> 'HOME'
            GROUP BY Ward_code, Specialty_code, Treatment_location;
        SELECT
            MAX(tx_date)
            INTO var_prev_stat_date
            FROM t$start_table; /* ---20120622 */
        INSERT INTO t$exc_table (exc_ward, exc_prev_remain)
        SELECT
            t.ward_code, SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) + SUM(COALESCE(Transfer_in, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out, 0)) - SUM(COALESCE(discharge, 0)) - SUM(COALESCE(Death, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) - SUM(COALESCE(Canc_admission, 0)) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) + SUM(COALESCE(Canc_disCHARge, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Canc_transfer_out_to_TD, 0))
            FROM t$start_table as t, Ward_spec_tx_adj_view as w
            WHERE tx_date = Ward_spec_tx_date AND t.ward_code = w.Ward_code AND spec_code = Specialty_code AND COALESCE(treat_loc, 'null') = COALESCE(Treatment_location, 'null') AND Hospital_code = var_hosp
            GROUP BY t.ward_code;
        UPDATE t$exc_table
        SET exc_remain = exc_prev_remain, exc_ae_adm = 0, exc_adm = 0, exc_vbd = 0, exc_bdo = 0, exc_ebd = 0, exc_ae_day = 0, exc_bda = 0, exc_day_dsch = 0, exc_day_deth = 0, exc_ip_dsch = 0, exc_ip_deth = 0, exc_day_bed = 0;
        /*
        ---20120622
        if @date <= @last_report_date
        begin
        	open ws_csr
        	fetch ws_csr into @ward, @adm, @xin, @xout, @dsch, @td,
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
        			@ttl_ae_day = @ae_day - @canc_ae_day,
        			@ttl_ae_adm = @ae_adm - @canc_ae_adm,
        			@ttl_adm = @adm - @canc_adm,
        			@ttl_dsch = @dsch - @canc_dsch - @day_dsch,
        			@ttl_deth = @death - @canc_death - @day_deth
        		if exists(select * from #exc_table
        			where exc_ward = @ward)
        			update #exc_table set
        				exc_remain = exc_remain + @in_out,
        				exc_ae_adm = exc_ae_adm + @ttl_ae_adm,
        				exc_adm = exc_adm + @ttl_adm,
        				exc_ae_day = exc_ae_day + @ttl_ae_day,
        				exc_day_dsch = exc_day_dsch + @day_dsch,
        				exc_day_deth = exc_day_deth + @day_deth,
        				exc_ip_dsch = exc_ip_dsch + @ttl_dsch,
        				exc_ip_deth = exc_ip_deth + @ttl_deth
        				where exc_ward = @ward
        		else
        			insert into #exc_table values
        				(@ward, 0, @ttl_ae_adm, @ttl_adm, @ttl_ae_day, @in_out,
        				0,0,0,0, @day_dsch, @day_deth, @ttl_dsch, @ttl_deth, 0)
        		fetch ws_csr into @ward, @adm, @xin, @xout, @dsch, @td,
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
        /* --fetch tx_csr into @src_ind, @adm_date, @dsch_date, @tx_type,@ward, @tx_date */
        FETCH tx_csr INTO var_case_no, var_tx_type, var_ward, var_tx_date;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                INTO var_adm, var_xin, var_xout, var_td, var_ret_td, var_ae_adm, var_ae_day, var_dsch, var_death, var_day_dsch, var_day_deth, var_in_out;
            SELECT
                source_indicator, admission_dtm, discharge_dtm
                INTO var_src_ind, var_adm_date, var_dsch_date
                /* ---from cpi..cpi_case    ----CPI -- */
                FROM cpi_case
                /* --- HPI version --- */
                WHERE case_no = var_case_no AND hospital_code = var_hosp;

            IF var_tx_type = '100' THEN
                BEGIN
                    SELECT
                        1, 1
                        INTO var_adm, var_in_out;

                    IF var_src_ind = '3' THEN
                        SELECT
                            1
                            INTO var_ae_adm;
                    END IF;
                END;
            END IF;

            IF var_tx_type = '140' THEN
                SELECT
                    1, - 1
                    INTO var_xout, var_in_out;
            END IF;

            IF var_tx_type = '141' THEN
                SELECT
                    1, 1
                    INTO var_xin, var_in_out;
            END IF;

            IF var_tx_type = '160' THEN
                SELECT
                    1, - 1
                    INTO var_td, var_in_out;
            END IF;

            IF var_tx_type = '171' THEN
                SELECT
                    1, 1
                    INTO var_ret_td, var_in_out;
            END IF;

            IF var_tx_type LIKE '13_' AND var_tx_type <> '131' THEN
                BEGIN
                    SELECT
                        1, - 1
                        INTO var_dsch, var_in_out;

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
                    SELECT
                        1, - 1
                        INTO var_death, var_in_out;

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
                WHERE exc_ward = var_ward) THEN
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        UPDATE t$exc_table
                        SET exc_remain = exc_remain + var_in_out, exc_ae_adm = exc_ae_adm + var_ae_adm, exc_adm = exc_adm + var_adm, exc_ae_day = exc_ae_day + var_ae_day, exc_day_dsch = exc_day_dsch + var_day_dsch, exc_day_deth = exc_day_deth + var_day_deth, exc_ip_dsch = exc_ip_dsch + var_dsch, exc_ip_deth = exc_ip_deth + var_death
                            WHERE exc_ward = var_ward;
                    ELSE
                        UPDATE t$exc_table
                        SET exc_remain = exc_remain + var_in_out
                            WHERE exc_ward = var_ward;
                    END IF;
                END;
            ELSE
                BEGIN
                    IF DATE_PART('days', var_tx_date::TIMESTAMP - var_date::TIMESTAMP) = 0 THEN
                        INSERT INTO t$exc_table
                        VALUES (var_ward, 0, var_ae_adm, var_adm, var_ae_day, var_in_out, 0, 0, 0, 0, var_day_dsch, var_day_deth, var_dsch, var_death, 0);
                    ELSE
                        INSERT INTO t$exc_table
                        VALUES (var_ward, 0, 0, 0, 0, var_in_out, 0, 0, 0, 0, 0, 0, 0, 0, 0);
                    END IF;
                END;
            END IF;
            /* --fetch tx_csr into @src_ind, @adm_date, @dsch_date, @tx_type,@ward, @tx_date */
            FETCH tx_csr INTO var_case_no, var_tx_type, var_ward, var_tx_date;
        END LOOP;
        CLOSE tx_csr;
        /* ---	end */
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
                    WHERE exc_ward = var_ward) THEN
                    UPDATE t$exc_table
                    SET exc_bda = exc_bda + var_bed, exc_day_bed = exc_day_bed + var_day_bed
                        WHERE exc_ward = var_ward;
                ELSE
                    INSERT INTO t$exc_table
                    VALUES (var_ward, 0, 0, 0, 0, 0, 0, 0, var_bed, 0, 0, 0, 0, 0, var_day_bed);
                END IF;
            END IF;
            FETCH bed_csr INTO var_ward, var_spec, var_bed, var_day_bed;
        END LOOP;
        CLOSE bed_csr;
        /*
        ---20120622
        if @date <= @last_report_date
        begin
        	select @home_dp_dsch = isnull(Day_discharge,0)
        		- isnull(Canc_day_discharge,0),
        		@home_dp_deth = isnull(Day_death,0)
        		- isnull(Canc_day_death, 0),
        		@home_ip_dsch = isnull(discharge, 0)
        		- isnull(Canc_discharge, 0) - isnull(Day_discharge, 0)
        		+ isnull(Canc_day_discharge, 0),
        		@home_ip_deth = isnull(Death, 0) - isnull(Canc_death, 0)
        		- isnull(Day_death, 0) + isnull(Canc_day_death, 0)
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
            /* --from Transaction_log t (index XIE2Transaction_Log), cpi..cpi_case c   --- CPI */
            FROM Transaction_log AS t, cpi_case AS c
            /* --- HPI */
            WHERE Transaction_datetime >= var_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Transaction_type LIKE '13_' AND Transaction_type <> '131' AND t.Hospital_code = var_hosp AND Cancel_flag IS NULL AND From_ward_code = 'HOME' AND From_specialty_code = 'HOME' AND t.Case_no = c.case_no AND /* ---cpi_case--- */ t.Hospital_code = c.hospital_code AND DATE_PART('days', discharge_dtm::TIMESTAMP - admission_dtm::TIMESTAMP) = 0;
        /* ---and t.Case_no = c.Case_no */
        /* ---and t.Hospital_code = c.Hospital_code */
        /* ---and datediff(dd,Admission_datetime,discharge_datetime) = 0 */
        SELECT
            COALESCE(COUNT(*), 0)
            INTO var_home_dp_deth
            /* --from Transaction_log t (index XIE2Transaction_Log), ADT_Case c */
            /* --from Transaction_log t (index XIE2Transaction_Log), cpi..cpi_case c   --- CPI */
            FROM Transaction_log AS t, cpi_case AS c
            /* --- HPI */
            WHERE Transaction_datetime >= var_date AND Transaction_datetime < 1 * INTERVAL '1 day' + var_date::TIMESTAMP AND Transaction_type = '131' AND t.Hospital_code = var_hosp AND Cancel_flag IS NULL AND From_ward_code = 'HOME' AND From_specialty_code = 'HOME' AND t.Case_no = c.case_no AND /* ---cpi_case--- */ t.Hospital_code = c.hospital_code AND DATE_PART('days', discharge_dtm::TIMESTAMP - admission_dtm::TIMESTAMP) = 0;
        /* --and t.Case_no = c.Case_no */
        /* --and t.Hospital_code = c.Hospital_code */
        /* --and datediff(dd,Admission_datetime,discharge_datetime) = 0 */
        /* --	end */
        IF var_home_dp_dsch <> 0 OR var_home_dp_deth <> 0 OR var_home_ip_dsch <> 0 OR var_home_ip_deth <> 0 THEN
            IF EXISTS (SELECT
                *
                FROM t$exc_table
                WHERE exc_ward = 'HOME') THEN
                UPDATE t$exc_table
                SET exc_day_dsch = exc_day_dsch + var_home_dp_dsch, exc_day_deth = exc_day_deth + var_home_dp_deth, exc_ip_dsch = exc_ip_dsch + var_home_ip_dsch, exc_ip_deth = exc_ip_deth + var_home_ip_deth
                    WHERE exc_ward = 'HOME';
            ELSE
                INSERT INTO t$exc_table
                VALUES ('HOME', 0, 0, 0, 0, 0, 0, 0, 0, 0, var_home_dp_dsch, var_home_dp_deth, var_home_ip_dsch, var_home_ip_deth, 0);
            END IF;
        END IF;
        UPDATE t$exc_table
        SET exc_bdo = exc_remain + exc_ae_day;
        UPDATE t$exc_table
        SET exc_vbd = exc_bda - exc_bdo
            WHERE exc_bda > exc_bdo;
        UPDATE t$exc_table
        SET exc_ebd = exc_bdo - exc_bda
            WHERE exc_bdo > exc_bda;
        OPEN out_csr;
        FETCH out_csr INTO var_ward, var_ae_adm, var_adm, var_ae_day, var_remain, var_bdo, var_vbd, var_bda, var_ebd, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            INSERT INTO daily_ward_summary
            VALUES (var_hosp, var_date, var_ward, var_ae_adm, var_adm, var_ae_day, var_remain, var_bdo, var_vbd, var_bda, var_ebd, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed);
            FETCH out_csr INTO var_ward, var_ae_adm, var_adm, var_ae_day, var_remain, var_bdo, var_vbd, var_bda, var_ebd, var_day_dsch, var_day_deth, var_dsch, var_death, var_day_bed;
        END LOOP;
        CLOSE out_csr;
        UPDATE t$exc_table
        SET exc_prev_remain = exc_remain;
        SELECT
            1 * INTERVAL '1 day' + var_date::TIMESTAMP
            INTO var_date;
    END LOOP;

END;
$procedure$;


;ALTER PROCEDURE "hasp_daily_stat_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";