-- DROP PROCEDURE hasp_hospital_inpatient_tx(inout int4, in timestamp, in timestamp, in varchar, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4, inout float4);

CREATE OR REPLACE PROCEDURE hasp_hospital_inpatient_tx(INOUT pas_return_code integer, IN par_input_from_date timestamp without time zone, IN par_input_to_date timestamp without time zone, IN par_hosp_code character varying, INOUT par_average_bed_complement real, INOUT par_available_bed_day real, INOUT par_inpatient_remaining real, INOUT par_emergency_day_admission real, INOUT par_vacant_bed_days real, INOUT par_excess_bed_days real, INOUT par_average_daily_bed_occupancy real, INOUT par_percentage_of_occupancy real, INOUT par_no_of_in_day_treated real, INOUT par_no_of_day_treated real, INOUT par_length_of_stay real, INOUT par_turnover real, INOUT par_turnover_day_in_btn_patient real, INOUT par_turnover_day_bed_period real, INOUT par_gross_death_per_1000 real, INOUT par_death_per_1000_less_24 real, INOUT par_death_per_1000_less_48 real)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_prev_date TIMESTAMP WITHOUT TIME ZONE;
    var_prev_remaining INTEGER;
    var_prev_ward_code VARCHAR(04);
    var_prev_official_bed INTEGER;
    var_cur_date TIMESTAMP WITHOUT TIME ZONE;
    var_cur_ward_code VARCHAR(04);
    var_cur_official_bed INTEGER;
    var_cur_adj INTEGER;
    var_cur_emgy_day_adm INTEGER;
    var_cur_specialty_code VARCHAR(04);
    var_cur_nobed_ward_code VARCHAR(04);
    var_inpat_remain INTEGER;
    var_temp_date TIMESTAMP WITHOUT TIME ZONE;
    var_days NUMERIC(10, 2);
    var_temp_a REAL;
    var_temp_b REAL;
    var_death_within_48 REAL;
    available_bed_day_cur CURSOR FOR
    SELECT
        Effective_date, Official_bed
        FROM Ward_specialty
        WHERE Effective_date > par_input_from_date AND Effective_date <= par_input_to_date AND COALESCE(Specialty_code, '') = COALESCE(var_cur_specialty_code, '') AND Ward_code = var_cur_ward_code AND Hospital_code = par_hosp_code
        ORDER BY Effective_date NULLS FIRST;
    ward_spec_cur CURSOR FOR
    SELECT
        Ward_code, Specialty_code, Official_bed
        FROM t$ward_spec_2
        WHERE effective_date = par_input_from_date
        ORDER BY Ward_code NULLS FIRST, Specialty_code NULLS FIRST;
    nobed_ward_cur CURSOR FOR
    SELECT
        Ward_code
        FROM Ward AS a
        WHERE NOT EXISTS (SELECT
            *
            FROM t$ward_spec_2
            WHERE Ward_code = a.Ward_code) AND Ward_code NOT IN ('AE01', 'A&E', 'AEO', 'HOME') AND
        /* --			Ward_code not in ('A&E', 'AEO') and */
        Effective_date = (SELECT
            MAX(Effective_date)
            FROM Ward
            WHERE Ward_code = a.Ward_code AND Effective_date < par_input_to_date AND Active_status = 'A' AND Hospital_code = par_hosp_code) AND NOT EXISTS (SELECT
            *
            FROM Ward
            WHERE Ward_code = a.Ward_code AND Effective_date >= a.Effective_date AND Effective_date < 1 * INTERVAL '1 day' + par_input_from_date::TIMESTAMP AND Active_status = 'D' AND Hospital_code = par_hosp_code) AND a.Hospital_code = par_hosp_code
    /* --- Add hosp code for HPI by ML on 26.07.1999 */
    ;
    ward_spec_tx_cur CURSOR FOR
    SELECT
        Ward_spec_tx_date, SUM(Admission) - SUM(COALESCE(Canc_admission, 0)) - SUM(Discharge) + SUM(COALESCE(Canc_discharge, 0)) + SUM(Transfer_in) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(Transfer_out) + SUM(COALESCE(Canc_transfer_out, 0)) - SUM(Death) + SUM(COALESCE(Canc_death, 0)) + SUM(Transfer_in_from_TD) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) - SUM(Transfer_out_to_TD) + SUM(COALESCE(Canc_transfer_out_to_TD, 0)), SUM(AE_day_discharge) + SUM(AE_day_death) - SUM(COALESCE(Canc_AE_day_discharge, 0)) - SUM(COALESCE(Canc_AE_day_death, 0))
        FROM Ward_spec_tx_adj_view
        WHERE Ward_spec_tx_date > par_input_from_date AND Ward_spec_tx_date <= par_input_to_date AND
        /* -- Add hosp code for HPI by ML on 26.07.199 -- */
        Ward_code = var_cur_ward_code AND Hospital_code = par_hosp_code
        GROUP BY Ward_spec_tx_date
        ORDER BY Ward_spec_tx_date NULLS FIRST;
    ward_cur CURSOR FOR
    SELECT
        ward_code
        FROM t$stat_table
        WHERE stat_date = par_input_from_date
        ORDER BY ward_code NULLS FIRST;
BEGIN
    /*
    parameter name          Description
    @input_from_date        From date to be processed
    @input_to_date          To date to be processed
    */
    SELECT
        DATE_PART('days', par_input_to_date::TIMESTAMP - par_input_from_date::TIMESTAMP) + 1
        INTO var_days;
    /* store daily statistics */
    /*
    create table #stat_table (stat_date datetime,
                              ward_code VARCHAR(04),
                              inpatient_remaining int,
                              emergency_day_adm   int,
                              available_bed_day   int,
                              unique clustered (stat_date,
                                     ward_code))
    
    /* use to retrieve the patient remaining at the start date */
    create table #ward_spec_tx (Ward_spec_tx_date datetime,
                             Ward_code         VARCHAR(04),
                             Specialty_code    VARCHAR(04),
                             Treatment_location VARCHAR(04) NULL,
                             unique clustered (Ward_spec_tx_date,
                                               Ward_code,
                                               Specialty_code,
                                               Treatment_location
                                               ))
    
    /* use to retrieve the official bed at the start date */
    create table #ward_spec (Effective_date    datetime,
                             Ward_code         VARCHAR(04),
                             Specialty_code    VARCHAR(04),
                             unique clustered (Effective_date,
                                               Ward_code,
                                               Specialty_code))
    */
    /* found available bed days at start date */
    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
    DROP TABLE IF EXISTS t$ward_spec;
    CREATE TEMPORARY TABLE t$ward_spec
    AS
    SELECT
        MAX(Effective_date) AS effective_date, Ward_code, Specialty_code
        FROM Ward_specialty
        WHERE effective_date <= par_input_from_date AND
        /* Ward_code != 'AE01' */
        Ward_code NOT IN ('AE01', 'A&E', 'AEO', 'HOME') AND Hospital_code = par_hosp_code
        GROUP BY Ward_code, Specialty_code;
    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
    DROP TABLE IF EXISTS t$ward_spec_2;
    CREATE TEMPORARY TABLE t$ward_spec_2
    AS
    SELECT
        par_input_from_date AS effective_date, a.Ward_code, a.Specialty_code, b.Official_bed
        FROM t$ward_spec AS a, Ward_specialty AS b
        WHERE a.Effective_date = b.Effective_date AND a.Ward_code = b.Ward_code AND COALESCE(a.Specialty_code,'') = COALESCE(b.Specialty_code,'') AND b.Hospital_code = par_hosp_code;
    /**CREATE UNIQUE INDEX #major_key ON t$ward_spec_2
        (patient_key, original_hkid, update_dtm);*/
    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
    INSERT INTO t$ward_spec_2
    SELECT
        par_input_from_date AS effective_date, Ward_code, Specialty_code, 0
        FROM Ward_specialty AS a
        WHERE Effective_date > par_input_from_date AND Effective_date <= par_input_to_date AND NOT EXISTS (SELECT
            *
            FROM t$ward_spec
            WHERE Ward_code = a.Ward_code AND COALESCE(Specialty_code,'') = COALESCE(a.Specialty_code,'')) AND Hospital_code = par_hosp_code
        GROUP BY Ward_code, Specialty_code;
   
    /* calculate available bed days for all days */
    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
    OPEN ward_spec_cur;
    FETCH ward_spec_cur INTO var_cur_ward_code, var_cur_specialty_code, var_prev_official_bed;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            par_input_from_date
            INTO var_prev_date;
        OPEN available_bed_day_cur;
        FETCH available_bed_day_cur INTO var_cur_date, var_cur_official_bed;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                1 * INTERVAL '1 day' + var_prev_date::TIMESTAMP
                INTO var_temp_date;

            WHILE var_temp_date < var_cur_date LOOP
                INSERT INTO t$ward_spec_2
                VALUES (var_temp_date, var_cur_ward_code, var_cur_specialty_code, var_prev_official_bed);
                SELECT
                    1 * INTERVAL '1 day' + var_temp_date::TIMESTAMP
                    INTO var_temp_date;
            END LOOP;
            INSERT INTO t$ward_spec_2
            VALUES (var_cur_date, var_cur_ward_code, var_cur_specialty_code, var_cur_official_bed);
            SELECT
                var_cur_official_bed, var_cur_date
                INTO var_prev_official_bed, var_prev_date;
            FETCH available_bed_day_cur INTO var_cur_date, var_cur_official_bed;
        END LOOP;
        CLOSE available_bed_day_cur;
        SELECT
            1 * INTERVAL '1 day' + var_prev_date::TIMESTAMP
            INTO var_temp_date;

        WHILE var_temp_date <= par_input_to_date LOOP
            INSERT INTO t$ward_spec_2
            VALUES (var_temp_date, var_cur_ward_code, var_cur_specialty_code, var_prev_official_bed);
            SELECT
                1 * INTERVAL '1 day' + var_temp_date::TIMESTAMP
                INTO var_temp_date;
        END LOOP;
        FETCH ward_spec_cur INTO var_cur_ward_code, var_cur_specialty_code, var_prev_official_bed;
    END LOOP;
    CLOSE ward_spec_cur;
   
    DROP TABLE IF EXISTS t$stat_table;
    CREATE TEMPORARY TABLE t$stat_table
    AS
    SELECT
        effective_date AS stat_date, Ward_code AS ward_code, 0 AS inpatient_remaining, 0 AS emergency_day_adm, SUM(Official_bed) AS available_bed_day
        FROM t$ward_spec_2
        GROUP BY effective_date, Ward_code;
    /* insert into #stat_table for those ward that has no beds */
    /*
    declare nobed_ward_cur cursor for
    select Ward_code
       from Ward a
       where not exists( select * from #ward_spec_2
                                where Ward_code =  a.Ward_code ) and
             Ward_code != 'AE01' and
             ( Close_date = null or
               Close_date > @input_from_date ) and
             Open_date < @input_to_date
    for read only
    */
    
   	/* 2025-04-07 performance tuning by Liam Mao-R&D@Harmony Cloud */
    CREATE INDEX stat_idx1_ward_date ON t$stat_table(stat_date,ward_code);
    
    OPEN nobed_ward_cur;
    FETCH nobed_ward_cur INTO var_cur_nobed_ward_code;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            par_input_from_date
            INTO var_temp_date;

        WHILE var_temp_date <= par_input_to_date LOOP
            INSERT INTO t$stat_table
            VALUES (var_temp_date, var_cur_nobed_ward_code, 0, 0, 0);
            SELECT
                1 * INTERVAL '1 day' + var_temp_date::TIMESTAMP
                INTO var_temp_date;
        END LOOP;
        FETCH nobed_ward_cur INTO var_cur_nobed_ward_code;
    END LOOP;
    CLOSE nobed_ward_cur;
   
    /* calculate patient remaining at the start date */
    /* --- Add hosp code for HPI on 26.07.1999 */
    DROP TABLE IF EXISTS t$ward_spec_tx;
    CREATE TEMPORARY TABLE t$ward_spec_tx
    AS
    SELECT
        MAX(ward_spec_tx_date) AS ward_spec_tx_date, ward_code, specialty_code, treatment_location
        FROM Ward_spec_tx
        WHERE ward_spec_tx_date <= par_input_from_date AND Hospital_code = par_hosp_code::VARCHAR
        GROUP BY ward_code, specialty_code, treatment_location;
    /* found patient remaining at the start date */
    /* --- Modified by WL on 28 DEC 1998, since sybase11 do not --- */
    /* --- support sub-query --- */
    
    /*
    update #stat_table
    set inpatient_remaining =
        (select
           sum(isnull(Previous_remaining, 0))
            + sum(isnull(Admission, 0)) - sum(isnull(Canc_admission, 0))
            - sum(isnull(Discharge, 0)) + sum(isnull(Canc_discharge, 0))
            + sum(isnull(Transfer_in, 0)) - sum(isnull(Canc_transfer_in, 0))
            - sum(isnull(Transfer_out, 0)) + sum(isnull(Canc_transfer_out, 0))
            - sum(isnull(Death, 0)) + sum(isnull(Canc_death, 0))
            + sum(isnull(Transfer_in_from_TD, 0)) - sum(isnull(Canc_transfer_in_from_TD, 0))
            - sum(isnull(Transfer_out_to_TD, 0)) + sum(isnull(Canc_transfer_out_to_TD, 0))
         from #ward_spec_tx a, Ward_spec_tx_adj_view b
         where a.Ward_spec_tx_date  = b.Ward_spec_tx_date  and
              a.Ward_code          = b.Ward_code          and
              a.Specialty_code     = b.Specialty_code     and
              isnull(a.Treatment_location, 'null')
                   = isnull(b.Treatment_location, 'null') and
              c.ward_code          = a.Ward_code
        )
    from #stat_table c
    where stat_date = @input_from_date
    */
    UPDATE t$stat_table AS c
    SET inpatient_remaining = COALESCE((SELECT
        SUM(COALESCE(Previous_remaining, 0)) + SUM(COALESCE(Admission, 0)) - SUM(COALESCE(Canc_admission, 0)) - SUM(COALESCE(Discharge, 0)) + SUM(COALESCE(Canc_discharge, 0)) + SUM(COALESCE(Transfer_in, 0)) - SUM(COALESCE(Canc_transfer_in, 0)) - SUM(COALESCE(Transfer_out, 0)) + SUM(COALESCE(Canc_transfer_out, 0)) - SUM(COALESCE(Death, 0)) + SUM(COALESCE(Canc_death, 0)) + SUM(COALESCE(Transfer_in_from_TD, 0)) - SUM(COALESCE(Canc_transfer_in_from_TD, 0)) - SUM(COALESCE(Transfer_out_to_TD, 0)) + SUM(COALESCE(Canc_transfer_out_to_TD, 0))
        FROM t$ward_spec_tx AS a, Ward_spec_tx_adj_view AS b
        WHERE a.Ward_spec_tx_date = b.Ward_spec_tx_date AND COALESCE(a.Ward_code, '') = COALESCE(b.Ward_code::VARCHAR, '') AND COALESCE(a.Specialty_code, '') = COALESCE(b.Specialty_code::VARCHAR, '') AND COALESCE(a.Treatment_location, '') = COALESCE(b.Treatment_location, '') AND COALESCE(c.ward_code, '') = COALESCE(a.Ward_code, '') AND b.Hospital_code = par_hosp_code), 0)
    WHERE c.stat_date = par_input_from_date;
    /* found emergency patient at the start date */
    /* --- Modified by WL on 28 DEC 1998, since sybase11 do not --- */
    /* --- support sub-query --- */
    
    /*
    update #stat_table
      set emergency_day_adm =
          (select sum(AE_day_discharge) + sum(AE_day_death)
                    - sum(isnull(Canc_AE_day_discharge, 0))
                    - sum(isnull(Canc_AE_day_death, 0))
               from Ward_spec_tx_adj_view
               where Ward_spec_tx_date = @input_from_date and
                     Ward_code         = c.ward_code )
    from #stat_table c
    where stat_date = @input_from_date
    */
    /* --- Add hosp code for hpi by ML on 26.07.1999 --- */
    UPDATE t$stat_table AS c
    SET emergency_day_adm = COALESCE((SELECT
        SUM(AE_day_discharge) + SUM(AE_day_death) - SUM(COALESCE(Canc_AE_day_discharge, 0)) - SUM(COALESCE(Canc_AE_day_death, 0))
        FROM Ward_spec_tx_adj_view
        WHERE Ward_spec_tx_date = par_input_from_date AND Ward_code = c.ward_code AND Hospital_code = par_hosp_code), 0)
    WHERE c.stat_date = par_input_from_date;
   
    /* collect inpatient remaining of each day from start date to end date */
    OPEN ward_cur;
    FETCH ward_cur INTO var_cur_ward_code;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP	    	  
        SELECT
            par_input_from_date
            INTO var_prev_date;
        SELECT
            inpatient_remaining
            INTO var_prev_remaining
            FROM t$stat_table
            WHERE stat_date = par_input_from_date AND ward_code = var_cur_ward_code;
           
        OPEN ward_spec_tx_cur;
        FETCH ward_spec_tx_cur INTO var_cur_date, var_cur_adj, var_cur_emgy_day_adm;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                1 * INTERVAL '1 day' + var_prev_date::TIMESTAMP
                INTO var_temp_date;

            WHILE var_temp_date < var_cur_date LOOP
                UPDATE t$stat_table
                SET inpatient_remaining = var_prev_remaining
                    WHERE stat_date = var_temp_date AND ward_code = var_cur_ward_code;
                SELECT
                    1 * INTERVAL '1 day' + var_temp_date::TIMESTAMP
                    INTO var_temp_date;
            END LOOP;
           
            SELECT
                var_prev_remaining + var_cur_adj, var_cur_date
                INTO var_prev_remaining, var_prev_date;
            UPDATE t$stat_table
            SET inpatient_remaining = var_prev_remaining, emergency_day_adm = var_cur_emgy_day_adm
                WHERE stat_date = var_cur_date AND ward_code = var_cur_ward_code;
            FETCH ward_spec_tx_cur INTO var_cur_date, var_cur_adj, var_cur_emgy_day_adm;
    	END LOOP;
    
        SELECT
            1 * INTERVAL '1 day' + var_prev_date::TIMESTAMP
            INTO var_temp_date;

        WHILE var_temp_date <= par_input_to_date LOOP
            UPDATE t$stat_table
            SET inpatient_remaining = var_prev_remaining
                WHERE stat_date = var_temp_date AND ward_code = var_cur_ward_code;
            SELECT
                1 * INTERVAL '1 day' + var_temp_date::TIMESTAMP
                INTO var_temp_date;
        END LOOP;
       
        CLOSE ward_spec_tx_cur;
        FETCH ward_cur INTO var_cur_ward_code;
    END LOOP;
    CLOSE ward_cur;

    select COALESCE((SUM(available_bed_day) / var_days), 0)
        INTO par_average_bed_complement
        FROM t$stat_table;
    /* print 'average bed com: %1!', @average_bed_complement */
    SELECT
        COALESCE(SUM(available_bed_day), 0)
        INTO par_available_bed_day
        FROM t$stat_table;
    /* print 'available bed day: %1!', @available_bed_day */
    SELECT
        COALESCE(SUM(inpatient_remaining), 0), COALESCE(SUM(emergency_day_adm), 0)
        INTO par_inpatient_remaining, par_emergency_day_admission
        FROM t$stat_table;
    /* print 'inpatient remaining: %1!, emergency: %2!', @inpatient_remaining, @emergency_day_admission */
    SELECT
        COALESCE(SUM(available_bed_day - inpatient_remaining - emergency_day_adm), 0)
        INTO par_vacant_bed_days
        FROM t$stat_table
        WHERE available_bed_day > (inpatient_remaining + emergency_day_adm);
    /* print 'vacant bed: %1!', @vacant_bed_days */
    SELECT
        COALESCE(SUM(inpatient_remaining + emergency_day_adm - available_bed_day), 0)
        INTO par_excess_bed_days
        FROM t$stat_table
        WHERE available_bed_day < (inpatient_remaining + emergency_day_adm);
    /* print 'excess bed: %1!', @excess_bed_days */
    SELECT
        (par_inpatient_remaining + par_emergency_day_admission) / var_days
        INTO par_average_daily_bed_occupancy;
    /* print 'average daily occupancy %1!', @average_daily_bed_occupancy */
    IF par_available_bed_day = 0 THEN
        SELECT
            0
            INTO par_percentage_of_occupancy;
    ELSE
        SELECT
            (par_inpatient_remaining + par_emergency_day_admission) / par_available_bed_day * 100
            INTO par_percentage_of_occupancy;
    END IF;
    /* print 'percentage of occupancy: %1!', @percentage_of_occupancy */
    SELECT
        COALESCE(SUM(Discharge + Death - COALESCE(Canc_discharge, 0) - COALESCE(Canc_death, 0)), 0)
        INTO par_no_of_in_day_treated
        FROM Ward_spec_tx_adj_view
        WHERE Ward_spec_tx_date BETWEEN par_input_from_date AND par_input_to_date AND
        /* -- Add hosp code for HPI by ML on 26.07.1999 --- */
        Hospital_code = par_hosp_code;
    /* print 'no of in day treated: %1!', @no_of_in_day_treated */
    SELECT
        COALESCE(SUM(Day_discharge + Day_death - COALESCE(Canc_day_discharge, 0) - COALESCE(Canc_day_death, 0)), 0)
        INTO par_no_of_day_treated
        FROM Ward_spec_tx_adj_view
        WHERE Ward_spec_tx_date BETWEEN par_input_from_date AND par_input_to_date AND
        /* -- Add hosp code for HPI by ML on 26.07.1999 --- */
        Hospital_code = par_hosp_code;
    /* print 'no of day treated: %1!', @no_of_day_treated */
    IF (par_no_of_in_day_treated - par_no_of_day_treated) = 0 THEN
        SELECT
            0
            INTO par_length_of_stay;
    ELSE
        SELECT
            (par_inpatient_remaining + par_emergency_day_admission) / (par_no_of_in_day_treated - par_no_of_day_treated)
            INTO par_length_of_stay;
    END IF;
    /* print 'length of stay: %1! ', @length_of_stay */
    IF par_average_bed_complement = 0 THEN
        SELECT
            0
            INTO par_turnover;
    ELSE
        SELECT
            (par_no_of_in_day_treated - par_no_of_day_treated) / par_average_bed_complement
            INTO par_turnover;
    END IF;
    /* print 'turnover: %1!', @turnover */
    IF (par_no_of_in_day_treated - par_no_of_day_treated) = 0 THEN
        SELECT
            0
            INTO par_turnover_day_in_btn_patient;
    ELSE
        SELECT
            ABS(par_vacant_bed_days - par_excess_bed_days) / (par_no_of_in_day_treated - par_no_of_day_treated)
            INTO par_turnover_day_in_btn_patient;
    END IF;
    /* print 'turnover_day_in_btn_patient: %1!', @turnover_day_in_btn_patient */
    IF par_average_bed_complement = 0 THEN
        SELECT
            0
            INTO par_turnover_day_bed_period;
    ELSE
        SELECT
            ABS(par_vacant_bed_days - par_excess_bed_days) / par_average_bed_complement
            INTO par_turnover_day_bed_period;
    END IF;
    /* print 'turnover_day_bed_period: %1!', @turnover_day_bed_period */
    IF par_no_of_in_day_treated = 0 THEN
        SELECT
            0
            INTO par_gross_death_per_1000;
    ELSE
        select 
            COALESCE(SUM(Death - COALESCE(Canc_death, 0)), 0) * 1000 / par_no_of_in_day_treated
        INTO par_gross_death_per_1000
        from Ward_spec_tx_adj_view
        where Ward_spec_tx_date between par_input_from_date and par_input_to_date
        and Hospital_code = par_hosp_code;
    END IF;
    /* print 'gross_death_per_1000: %1!', @gross_death_per_1000 */
    SELECT
        COALESCE(SUM(Death - COALESCE(Canc_death, 0) - Day_death + COALESCE(Canc_day_death, 0)), 0), par_no_of_in_day_treated - COALESCE(SUM(Day_death - COALESCE(Canc_day_death, 0)), 0)
        INTO var_temp_a, var_temp_b
        FROM Ward_spec_tx_adj_view
        WHERE Ward_spec_tx_date BETWEEN par_input_from_date AND par_input_to_date AND
        /* --- add hosp code for HPI by ML on 26.07.1999 --- */
        Hospital_code = par_hosp_code;

    IF var_temp_b = 0 THEN
        SELECT
            0
            INTO par_death_per_1000_less_24;
    ELSE
        SELECT
            var_temp_a * 1000 / var_temp_b
            INTO par_death_per_1000_less_24;
    END IF;
    /* print 'death_per_1000_less_24: %1!', @death_per_1000_less_24 */
    /* changed by Karen at 1996-04-29 for cpi */
    /* before changes are comment for select from Case_view below */
    /*
    select @death_within_48 = count(*) from
    Transaction_log a, Case b
    where Transaction_datetime between @input_from_date and @input_to_date and
          Transaction_type = '131' and
          a.Case_no = b.Case_no    and
          datediff(dd, Admission_datetime, Discharge_datetime) < 2
    */
    /* end of comment for select from Case_view below */
    /* modify start for select from Case_view */
    /* -- add hosp code for HPI by ML on 26.07.1999 -- */
    /* -- add index for Tx log to speed up selection */
    SELECT
        COUNT(*)
        INTO var_death_within_48
        FROM Transaction_log AS a, Case_view AS b
        WHERE Transaction_datetime BETWEEN par_input_from_date AND par_input_to_date AND Transaction_type = '131' AND Cancel_flag IS NULL AND a.Case_no = b.Case_no AND DATE_PART('days', Discharge_datetime::TIMESTAMP - Admission_datetime::TIMESTAMP) < 2 AND a.Hospital_code = par_hosp_code AND b.Hospital_code = par_hosp_code;
    /* end of modify for select from Case_view */
    IF (par_no_of_in_day_treated - var_death_within_48) = 0 THEN
        SELECT
            0
            INTO par_death_per_1000_less_48;
    ELSE
        SELECT
            (SUM(Death - COALESCE(Canc_death, 0)) - var_death_within_48) * 1000 / (par_no_of_in_day_treated - var_death_within_48)
            INTO par_death_per_1000_less_48
            FROM Ward_spec_tx_adj_view
            WHERE Ward_spec_tx_date BETWEEN par_input_from_date AND par_input_to_date AND Hospital_code = par_hosp_code;
    END IF;
   
    /* -- add hosp code HPI by ML on 26.07.1999 --- */
    
    /* print 'death_per_1000_less_48: %1!', @death_per_1000_less_48 */
    --DROP TABLE t$ward_spec;
    --DROP TABLE t$stat_table;
    --DROP TABLE t$ward_spec_tx;
    pas_return_code := 0;
    RETURN;
    END;
$procedure$
;

;ALTER PROCEDURE "hasp_hospital_inpatient_tx" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
