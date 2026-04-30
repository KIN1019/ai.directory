-- DROP PROCEDURE hpi.hasp_get_duration(inout int4, in varchar, in timestamp, in timestamp, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_duration(INOUT pas_return_code integer DEFAULT 0, IN par_hosp_code character varying DEFAULT NULL::character varying, IN par_input_from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_input_to_date timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_input_spec character varying DEFAULT NULL::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* add hosp code parameter for HPI by ML on 27.07.1999 */
DECLARE
var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    var_case VARCHAR(12);
    var_spec VARCHAR(4);
    var_los SMALLINT;
    var_adm_date TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_last_date TIMESTAMP WITHOUT TIME ZONE;
    var_move_spec VARCHAR(4);
    var_last_spec VARCHAR(4);
    var_move_date TIMESTAMP WITHOUT TIME ZONE;
    case_csr CURSOR FOR
		SELECT
		    Case_no, Admission_datetime
		FROM ADT_Case
		/* --where Case_type = 'I' */
		WHERE Case_no SIMILAR TO ' HN%' AND Hospital_code = par_hosp_code AND Admission_datetime < par_input_to_date 
			AND (Discharge_code IS NULL OR (Discharge_code IS NOT NULL AND Discharge_datetime >= par_input_to_date))
		order by Admission_datetime;
	
	move_csr CURSOR FOR
		SELECT
		    Specialty_code, Movement_datetime
		FROM Movement
		WHERE Case_no = var_case AND Movement_datetime < par_input_to_date AND Hospital_code = par_hosp_code
		order by Movement_datetime;
	sql$rowcount BIGINT;
BEGIN
    /*
    - Duration of Stay of Inpatient Report
    
    parameter name          Description
    @hosp_code              Hospital Code
    @input_from_date        Report start date to be processed
    @input_to_date          Report end date to be processed
    @input_spec             Specialty code to be processed
    
    27.07.1999 - Add hosp code for HPI on 27.07.1999
    */
    /* declare temporary variables */
    /* create temp table */
DROP TABLE IF EXISTS t$los_table;
    CREATE TEMPORARY TABLE t$los_table
    (los_spec VARCHAR(4) NOT NULL,
        los_desc VARCHAR(30) NULL,
        los_1 SMALLINT,
        los_2 SMALLINT,
        los_3 SMALLINT,
        los_4 SMALLINT,
        los_5 SMALLINT,
        los_6 SMALLINT,
        los_7 SMALLINT,
        los_8 SMALLINT,
        los_9 SMALLINT,
        los_10 SMALLINT,
        los_11 SMALLINT,
        los_12 SMALLINT,
        los_13 SMALLINT,
        los_14 SMALLINT,
        los_15 SMALLINT,
        los_16 SMALLINT,
        los_17 SMALLINT,
        los_18 SMALLINT,
        los_19 SMALLINT,
        los_20 SMALLINT,
        los_21 SMALLINT,
        los_22 SMALLINT,
        los_23 SMALLINT,
        los_24 SMALLINT,
        los_25 SMALLINT,
        los_26 SMALLINT,
        los_27 SMALLINT,
        los_28 SMALLINT,
        los_29 SMALLINT,
        los_30 SMALLINT,
        los_31 SMALLINT,
        los_32 SMALLINT,
        los_33 SMALLINT,
        los_34 SMALLINT,
        los_35 SMALLINT,
        los_36 SMALLINT);
    /* declare cursor for selecting patient staying cases */
	SELECT
	    par_input_to_date + INTERVAL '1 day'
	INTO par_input_to_date;
	/* add hosp code for HPI by ML on 27.07.1999 */
	/* change Case_type = 'I' to Case_no like ' HN%' */
	/* to speed up selection */
	/* add hosp code for HPI by ML on 27.07.1999 */
	OPEN case_csr;
	FETCH case_csr INTO var_case, var_adm_date;
	
	WHILE (CASE
	        WHEN FOUND THEN 0
	        WHEN NOT FOUND THEN 2
	        ELSE 1
	    END) = 0 LOOP
	        OPEN move_csr;
	        FETCH move_csr INTO var_move_spec, var_move_date;
	        SELECT
	            var_move_date, 0, var_move_date, var_move_spec
	        INTO var_last_date, var_los, var_adm_date, var_last_spec;
	
	        WHILE (CASE
	                    WHEN FOUND THEN 0
	                    WHEN NOT FOUND THEN 2
	                    ELSE 1
	                END) = 0 LOOP
	                    IF var_last_spec <> 'HOME' THEN
	                    SELECT
	                        var_los + DATE_PART('day', var_move_date::timestamp::date::timestamp - var_last_date::timestamp::date::timestamp)
	                    INTO var_los;
--	                            RAISE NOTICE 'old var_los is %',var_los;
	
	                    END IF;
	                    SELECT
	                        var_move_date, var_move_spec
	                    INTO var_last_date, var_last_spec;
	                    FETCH move_csr INTO var_move_spec, var_move_date;
	                END LOOP;
	        CLOSE move_csr;
	       
	        IF var_last_spec <> 'HOME' THEN
		        BEGIN
			        SELECT
			            -- var_los + EXTRACT(day from(par_input_to_date - var_last_date)), var_last_spec
                        var_los +  DATE_PART('day', par_input_to_date::timestamp::date::timestamp - var_last_date::timestamp::date::timestamp), var_last_spec
			        INTO var_los, var_spec;
--			        RAISE NOTICE 'var_los is %',var_los;
		
			        IF NOT EXISTS (SELECT
			                            *
			                            FROM t$los_table
			                            WHERE var_spec = los_spec) THEN
			                            INSERT INTO t$los_table
			                            VALUES (var_spec, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			        END IF;
	        	END;
	        END IF;
	
	        SELECT
	            var_adm_date + (var_los * INTERVAL '1 day')
	        INTO var_dsch_date;
	
	        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
	
	        IF sql$rowcount > 0 AND var_spec LIKE par_input_spec AND var_last_spec <> 'HOME' THEN
	        BEGIN
		        SELECT
		            -- EXTRACT(day from(var_dsch_date - var_adm_date))
                    DATE_PART('day', var_dsch_date::timestamp::date::timestamp - var_adm_date::timestamp::date::timestamp)
		        INTO var_los;
--		        RAISE NOTICE 'now var_los is %',var_los;
		
			        IF var_los > 365 THEN
			                            /* if @los >300  ----- 20030610 SL */
				        BEGIN
--					        SELECT ABS(EXTRACT(YEAR FROM AGE(var_dsch_date, var_adm_date)))
					        select (EXTRACT(YEAR FROM var_dsch_date) - EXTRACT(YEAR FROM var_adm_date))
					        INTO var_los;
--					        RAISE NOTICE 'now var_los is change %',var_los;
					
						        IF (var_adm_date + INTERVAL '1 year' * var_los)::TIMESTAMP > var_dsch_date THEN
							        SELECT
							            var_los - 1
							        INTO var_los;
							        
--							        RAISE NOTICE 'now var_los is change2 %',var_los;
						        END IF;
						
	                            IF var_los > 30 THEN
							        UPDATE t$los_table
							        SET los_36 = los_36 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 30 THEN
							        UPDATE t$los_table
							        SET los_35 = los_35 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 29 THEN
							        UPDATE t$los_table
							        SET los_34 = los_34 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 28 THEN
							        UPDATE t$los_table
							        SET los_33 = los_33 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 27 THEN
							        UPDATE t$los_table
							        SET los_32 = los_32 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 26 THEN
							        UPDATE t$los_table
							        SET los_31 = los_31 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 25 THEN
							        UPDATE t$los_table
							        SET los_30 = los_30 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 24 THEN
							        UPDATE t$los_table
							        SET los_29 = los_29 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 23 THEN
							        UPDATE t$los_table
							        SET los_28 = los_28 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 22 THEN
							        UPDATE t$los_table
							        SET los_27 = los_27 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 21 THEN
							        UPDATE t$los_table
							        SET los_26 = los_26 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 20 THEN
							        UPDATE t$los_table
							        SET los_25 = los_25 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 19 THEN
							        UPDATE t$los_table
							        SET los_24 = los_24 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 18 THEN
							        UPDATE t$los_table
							        SET los_23 = los_23 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 17 THEN
							        UPDATE t$los_table
							        SET los_22 = los_22 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 16 THEN
							        UPDATE t$los_table
							        SET los_21 = los_21 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 15 THEN
							        UPDATE t$los_table
							        SET los_20 = los_20 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 14 THEN
							        UPDATE t$los_table
							        SET los_19 = los_19 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 13 THEN
							        UPDATE t$los_table
							        SET los_18 = los_18 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 12 THEN
							        UPDATE t$los_table
							        SET los_17 = los_17 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 11 THEN
							        UPDATE t$los_table
							        SET los_16 = los_16 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 10 THEN
							        UPDATE t$los_table
							        SET los_15 = los_15 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 9 THEN
							        UPDATE t$los_table
							        SET los_14 = los_14 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 8 THEN
							        UPDATE t$los_table
							        SET los_13 = los_13 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 7 THEN
							        UPDATE t$los_table
							        SET los_12 = los_12 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 6 THEN
							        UPDATE t$los_table
							        SET los_11 = los_11 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 5 THEN
							        UPDATE t$los_table
							        SET los_10 = los_10 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 4 THEN
							        UPDATE t$los_table
							        SET los_9 = los_9 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 3 THEN
							        UPDATE t$los_table
							        SET los_8 = los_8 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los = 2 THEN
							        UPDATE t$los_table
							        SET los_7 = los_7 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
						        IF var_los <= 1 THEN
							        UPDATE t$los_table
							        SET los_6 = los_6 + 1
							        WHERE los_spec = var_spec;
						        END IF;
						
				        END;
					
			        ELSE
				        BEGIN
				        IF var_los > 180 THEN
				        UPDATE t$los_table
				        SET los_5 = los_5 + 1
				        WHERE los_spec = var_spec;
				        ELSE
				            IF var_los > 90 THEN
						        UPDATE t$los_table
						        SET los_4 = los_4 + 1
						        WHERE los_spec = var_spec;
						        ELSE
				                	IF var_los > 60 THEN
								        UPDATE t$los_table
								        SET los_3 = los_3 + 1
								        WHERE los_spec = var_spec;
								        ELSE
				                    	IF var_los > 30 THEN
									        UPDATE t$los_table
									        SET los_2 = los_2 + 1
									        WHERE los_spec = var_spec;
				        				else
--        							        RAISE NOTICE 'var_los is % date is % % %',var_los,par_input_to_date,var_move_date , var_last_date;
									        UPDATE t$los_table
									        SET los_1 = los_1 + 1
									        WHERE los_spec = var_spec;
				        				END IF;
				       				 END IF;
				       		 END IF;
			       		 END IF;
			        END;
			      END IF;
		        END;
	        END IF;
	        FETCH case_csr INTO var_case, var_adm_date;
	END LOOP;
	CLOSE case_csr;
	/*
	update for getting description with effective date nearest to the retrieve
	date range  13121996 ML
	*/
	/* add hosp code for HPI by ML on 27.07.1999 */
	-- RAISE NOTICE ' los_spec : %', t$los_table.los_spec;
	
	--UPDATE t$los_table
	--SET los_desc = (SELECT
	--                    Description
	--                FROM Specialty
	--                WHERE Specialty_code = a.los_spec AND Hospital_code = par_hosp_code AND Effective_date = (SELECT
	--                                                                                                              MAX(Effective_date)
	--                                                                                                          FROM Specialty
	--                                                                                                          WHERE Specialty_code = par_input_spec AND Effective_date < par_input_to_date AND Hospital_code = par_hosp_code))
	--    FROM t$los_table AS a;
	   
	   UPDATE t$los_table
		SET los_desc = (
		    SELECT Description
           
		    FROM Specialty
		    WHERE Specialty_code = t$los_table.los_spec
		    AND Hospital_code = par_hosp_code
		    AND Effective_date = (
		        SELECT MAX(Effective_date)
		        FROM Specialty
		        WHERE Specialty_code = t$los_table.los_spec
		        AND Effective_date < par_input_to_date
		        AND Hospital_code = par_hosp_code
		    )
		);
	   
	OPEN p_refcur FOR
		SELECT
		    t$los_table.los_spec, t$los_table.los_desc, t$los_table.los_1, t$los_table.los_2, t$los_table.los_3, t$los_table.los_4, t$los_table.los_5, t$los_table.los_6, t$los_table.los_7, t$los_table.los_8, t$los_table.los_9, t$los_table.los_10, t$los_table.los_11, t$los_table.los_12, t$los_table.los_13, t$los_table.los_14, t$los_table.los_15, t$los_table.los_16, t$los_table.los_17, t$los_table.los_18, t$los_table.los_19, t$los_table.los_20, t$los_table.los_21, t$los_table.los_22, t$los_table.los_23, t$los_table.los_24, t$los_table.los_25, t$los_table.los_26, t$los_table.los_27, t$los_table.los_28, t$los_table.los_29, t$los_table.los_30, t$los_table.los_31, t$los_table.los_32, t$los_table.los_33, t$los_table.los_34, t$los_table.los_35, t$los_table.los_36
		FROM t$los_table
		WHERE los_1 > 0 OR los_2 > 0 OR los_3 > 0 OR los_4 > 0 OR los_5 > 0 OR los_6 > 0 OR los_7 > 0 OR los_8 > 0 OR los_9 > 0 OR los_10 > 0 OR los_11 > 0 OR los_12 > 0 OR los_13 > 0 OR los_14 > 0 OR los_15 > 0 OR los_16 > 0 OR los_17 > 0 OR los_18 > 0 OR los_19 > 0 OR los_20 > 0 OR los_21 > 0 OR los_22 > 0 OR los_23 > 0 OR los_24 > 0 OR los_25 > 0 OR los_26 > 0 OR los_27 > 0 OR los_28 > 0 OR los_29 > 0 OR los_30 > 0 OR los_31 > 0 OR los_32 > 0 OR los_33 > 0 OR los_34 > 0 OR los_35 > 0 OR los_36 > 0
		ORDER BY los_spec::bytea NULLS first;
	
	pas_return_code := 0;
    RETURN;
	    /*
	    
	    DROP TABLE IF EXISTS t$los_table;
	    */
	    /*
	    
	    Temporary table must be removed before end of the function.
	    */
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_duration" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
