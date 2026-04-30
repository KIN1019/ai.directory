-- DROP PROCEDURE hasp_get_duration_cte(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_duration_cte(INOUT pas_return_code integer DEFAULT 0, IN par_hosp_code character varying DEFAULT NULL::character varying, IN par_input_from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_input_to_date timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_input_spec character varying DEFAULT NULL::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$ 
DECLARE 
BEGIN 
    /* 
    - Duration of Stay of Inpatient Report 
     
    Using CTE and batch operations instead of temporary tables and cursor loops to improve performance 
     
    Parameter description: 
    @hosp_code              Hospital code 
    @input_from_date        Report start date 
    @input_to_date          Report end date (inclusive) 
    @input_spec             Specialty code (optional) 
    */ 
     
    -- Adjust end date to be inclusive 
    par_input_to_date := par_input_to_date + INTERVAL '1 day'; 
     
    -- Main query uses CTE to process all data at once 
    OPEN p_refcur FOR 
    WITH  
    -- Get eligible inpatient cases 
    eligible_cases AS ( 
        SELECT  
            c.Case_no,  
            c.Admission_datetime, 
            c.Discharge_datetime, 
            c.Discharge_code 
        FROM ADT_Case c 
        WHERE c.Case_no SIMILAR TO ' HN%'  
          AND c.Hospital_code = par_hosp_code  
          AND c.Admission_datetime < par_input_to_date 
          AND (c.Discharge_code IS NULL OR (c.Discharge_code IS NOT NULL AND c.Discharge_datetime >= par_input_to_date))) 
    , 
    -- Get specialty movement records for cases 
    case_movements AS ( 
        SELECT  
            m.Case_no, 
            m.Specialty_code, 
            m.Movement_datetime, 
            ROW_NUMBER() OVER (PARTITION BY m.Case_no ORDER BY m.Movement_datetime,m.Movement_count) as movement_seq, 
            LEAD(m.Movement_datetime) OVER (PARTITION BY m.Case_no ORDER BY m.Movement_datetime,m.Movement_count) as next_movement_datetime, 
            LAST_VALUE(m.Specialty_code) OVER (PARTITION BY m.Case_no ORDER BY m.Movement_datetime,m.Movement_count 
                                             ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as final_specialty 
        FROM Movement m 
        JOIN eligible_cases ec ON m.Case_no = ec.Case_no 
        WHERE m.Movement_datetime < par_input_to_date  
          AND m.Hospital_code = par_hosp_code 
    ), 
    -- Calculate hospitalization days for each specialty period 
    specialty_periods AS ( 
        SELECT  
            cm.Case_no, 
            cm.final_specialty as Specialty_code, -- Using final specialty 
            cm.Movement_datetime as period_start, 
            COALESCE(cm.next_movement_datetime, par_input_to_date) as period_end, 
            -- Calculate day difference 
            DATE_PART('day',  
                COALESCE(cm.next_movement_datetime, par_input_to_date)::date::timestamp -  
                cm.Movement_datetime::date::timestamp 
            ) as days_in_period 
        FROM case_movements cm 
        JOIN eligible_cases ec ON cm.Case_no = ec.Case_no 
        WHERE COALESCE (cm.final_specialty,'null') <> 'HOME' 
        	AND COALESCE (cm.Specialty_code,'null') <> 'HOME' 
    ), 
    -- Aggregate total hospitalization days per specialty for each case 
    case_final_specialty_totals AS ( 
        SELECT  
            Case_no, 
            Specialty_code, 
            SUM(days_in_period) as total_days 
        FROM specialty_periods 
        GROUP BY Case_no, Specialty_code 
    ), 
    -- Get specialty descriptions 
    specialty_descriptions AS ( 
        SELECT  
            s.Specialty_code, 
            s.Description 
        FROM Specialty s 
        WHERE s.Hospital_code = par_hosp_code 
          AND s.Effective_date = ( 
              SELECT MAX(Effective_date) 
              FROM Specialty 
              WHERE Specialty_code = s.Specialty_code 
                AND Effective_date < par_input_to_date 
                AND Hospital_code = par_hosp_code 
          ) 
    ), 
    -- Statistics by length of stay intervals 
    los_stats AS ( 
        SELECT  
            cst.Specialty_code, 
            sd.Description as los_desc, 
            COUNT(CASE WHEN cst.total_days BETWEEN 0 AND 30 THEN 1 END) as los_1, 
            COUNT(CASE WHEN cst.total_days BETWEEN 31 AND 60 THEN 1 END) as los_2, 
            COUNT(CASE WHEN cst.total_days BETWEEN 61 AND 90 THEN 1 END) as los_3, 
            COUNT(CASE WHEN cst.total_days BETWEEN 91 AND 180 THEN 1 END) as los_4, 
            COUNT(CASE WHEN cst.total_days BETWEEN 181 AND 365 THEN 1 END) as los_5, 
            -- Yearly statistics for stays longer than 1 year 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 1 THEN 1 END) as los_6, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 2 THEN 1 END) as los_7, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 3 THEN 1 END) as los_8, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 4 THEN 1 END) as los_9, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 5 THEN 1 END) as los_10, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 6 THEN 1 END) as los_11, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 7 THEN 1 END) as los_12, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 8 THEN 1 END) as los_13, 
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 9 THEN 1 END) as los_14,             
            COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 10 THEN 1 END) as los_15, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 11 THEN 1 END) as los_16, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 12 THEN 1 END) as los_17, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 13 THEN 1 END) as los_18, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 14 THEN 1 END) as los_19, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 15 THEN 1 END) as los_20, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 16 THEN 1 END) as los_21, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 17 THEN 1 END) as los_22, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 18 THEN 1 END) as los_23, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 19 THEN 1 END) as los_24, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 20 THEN 1 END) as los_25, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 21 THEN 1 END) as los_26, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 22 THEN 1 END) as los_27, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 23 THEN 1 END) as los_28, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 24 THEN 1 END) as los_29, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 25 THEN 1 END) as los_30, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 26 THEN 1 END) as los_31, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 27 THEN 1 END) as los_32, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 28 THEN 1 END) as los_33, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 29 THEN 1 END) as los_34, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) = 30 THEN 1 END) as los_35, 
			COUNT(CASE WHEN cst.total_days > 365  AND EXTRACT(YEAR FROM AGE((ec.Admission_datetime + INTERVAL '1 day' * cst.total_days)::timestamp,ec.Admission_datetime)) > 30 THEN 1 END) as los_36 
        FROM case_final_specialty_totals cst 
        JOIN eligible_cases ec ON cst.Case_no = ec.Case_no 
        LEFT JOIN specialty_descriptions sd ON cst.Specialty_code = sd.Specialty_code 
        WHERE (par_input_spec IS NULL OR cst.Specialty_code LIKE par_input_spec) 
        GROUP BY cst.Specialty_code, sd.Description 
    ) 
    -- Final result 
    SELECT  
        Specialty_code as los_spec, 
        los_desc, 
        los_1, los_2, los_3, los_4, los_5, los_6,  
        los_7, los_8, los_9, los_10, los_11, los_12,  
        los_13, los_14, los_15, los_16, los_17, los_18,  
        los_19, los_20, los_21, los_22, los_23, los_24,  
        los_25, los_26, los_27, los_28, los_29, los_30,  
        los_31, los_32, los_33, los_34, los_35, los_36 
    FROM los_stats 
    WHERE los_1 > 0 OR los_2 > 0 OR los_3 > 0 OR los_4 > 0 OR los_5 > 0 OR los_6 > 0 OR 
    	los_7 > 0 OR los_8 > 0 OR los_9 > 0 OR los_10 > 0 OR los_11 > 0 OR los_12 > 0 OR  
        los_13 > 0 OR los_14 > 0 OR los_15 > 0 OR los_16 > 0 OR los_17 > 0 OR los_18 > 0 OR  
        los_19 > 0 OR los_20 > 0 OR los_21 > 0 OR los_22 > 0 OR los_23 > 0 OR los_24 > 0 OR  
        los_25 > 0 OR los_26 > 0 OR los_27 > 0 OR los_28 > 0 OR los_29 > 0 OR los_30 > 0 OR  
        los_31 > 0 OR los_32 > 0 OR los_33 > 0 OR los_34 > 0 OR los_35 > 0 OR los_36 > 0 
    ORDER BY Specialty_code::bytea NULLS FIRST; 

    pas_return_code := 0; 
    RETURN; 
END; 
$procedure$
;
;ALTER PROCEDURE "hasp_get_duration_cte" OWNER TO "HPI_SCHEMA_OWNER_ROLE";