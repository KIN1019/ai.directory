-- DROP FUNCTION hpi.hasp_bed_statistics(varchar, timestamp);

CREATE OR REPLACE FUNCTION hasp_bed_statistics(par_hosp_code character varying, par_in_date timestamp without time zone)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/*
- Bed Statistics report

    Parameters to be used :-
             Description               Data Type
    --------------------               -------------
   1. Hospital code               VARCHAR(3)
   2. In date                     datetime

    Modification History:
        26.07.1999 - Add Hospital code for HPI by Mabel Lau
*/
DECLARE
p_refcur refcursor;
    var_error INTEGER;
    var_no_of_ae01_bed INTEGER;
    var_no_of_total_bed INTEGER;
    var_official_beds INTEGER;
    var_ward_code VARCHAR(4);
    var_tr_loc VARCHAR(4);
    var_previous_remaining INTEGER;
    var_admission INTEGER;
    var_discharge INTEGER;
    var_td_transfer_in INTEGER;
    var_td_transfer_out INTEGER;
    var_death INTEGER;
    var_canc_admission INTEGER;
    var_canc_discharge INTEGER;
    var_canc_td_transfer_in INTEGER;
    var_canc_td_transfer_out INTEGER;
    var_canc_death INTEGER;
    var_prev_date TIMESTAMP WITHOUT TIME ZONE;
    var_next_date TIMESTAMP WITHOUT TIME ZONE;
    var_ae_day_dsch INTEGER;
    var_ae_day_deth INTEGER;
    var_canc_ae_day_dsch INTEGER;
    var_max_tx_date TIMESTAMP WITHOUT TIME ZONE;
    var_adm INTEGER;
    var_dsch INTEGER;
    var_transfer_in INTEGER;
    var_transfer_out INTEGER;
    var_c_death INTEGER;
    var_c_adm INTEGER;
    var_c_dsch INTEGER;
    var_c_transfer_in INTEGER;
    var_c_transfer_out INTEGER;
    var_c_td_transfer_in INTEGER;
    var_c_td_transfer_out INTEGER;
    var_remain INTEGER;
    var_spec_code VARCHAR(4);
    var_canc_ae_day_deth INTEGER;
    var_count_test INTEGER;
    Ward_spec CURSOR FOR
SELECT Official_bed, Ward_code, Specialty_code
FROM (
         SELECT
             Official_bed,
             Ward_code,
             Specialty_code,
             Effective_date,
             Hospital_code,
             ROW_NUMBER() OVER (PARTITION BY Ward_code, Specialty_code ORDER BY Effective_date DESC) AS rn
         FROM Ward_specialty
         WHERE (Effective_date < var_next_date) AND (Hospital_code = par_hosp_code)
     ) subquery
WHERE rn = 1;

Ward_spec_tx CURSOR FOR
SELECT Ward_spec_tx_date,
       Previous_remaining,
       Admission,
       Discharge,
       Transfer_in,
       Transfer_out,
       Death,
       Transfer_in_from_TD,
       Transfer_out_to_TD,
       Ward_code,
       Specialty_code,
       Treatment_location
FROM (
         SELECT
             Ward_spec_tx_date,
             Previous_remaining,
             Admission,
             Discharge,
             Transfer_in,
             Transfer_out,
             Death,
             Transfer_in_from_TD,
             Transfer_out_to_TD,
             Ward_code,
             Specialty_code,
             Treatment_location,
             Hospital_code,
             ROW_NUMBER() OVER (PARTITION BY Ward_code, Specialty_code, Treatment_location ORDER BY Ward_spec_tx_date DESC) AS rn
         FROM Ward_spec_tx
         WHERE (Ward_spec_tx_date <= par_in_date) AND (Hospital_code = par_hosp_code)
     ) subquery
WHERE rn = 1;
sql$rowcount BIGINT;

BEGIN
SELECT
    1 * INTERVAL '1 day' + par_in_date::TIMESTAMP
INTO var_next_date;
SELECT
    - 1 * INTERVAL '1 day' + par_in_date::TIMESTAMP
INTO var_prev_date;
SELECT
    0, 0, 0
INTO var_no_of_ae01_bed, var_no_of_total_bed, var_previous_remaining;
/* --- Add hospital code for HPI by ML on 26.07.1999 */
OPEN ward_spec;

WHILE ((CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0) LOOP
        FETCH ward_spec INTO var_official_beds, var_ward_code, var_spec_code;

        IF (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 THEN
BEGIN
                IF var_ward_code = 'AE01' THEN
SELECT
    var_no_of_ae01_bed + var_official_beds
INTO var_no_of_ae01_bed;
ELSE
SELECT
    var_no_of_total_bed + var_official_beds
INTO var_no_of_total_bed;
END IF;
END;
END IF;
END LOOP;
CLOSE ward_spec;
/* find previous remaining */
/* --- Add hospital code for HPI by ML on 26.07.1999 */
OPEN ward_spec_tx;

WHILE (1 = 1) LOOP
        FETCH ward_spec_tx INTO var_max_tx_date, var_remain, var_adm, var_dsch, var_transfer_in, var_transfer_out, var_death, var_td_transfer_in, var_td_transfer_out, var_ward_code, var_spec_code, var_tr_loc;
                    RAISE NOTICE 'update today data : var_spec_code: %, var_ward_code: %, var_tr_loc :', var_spec_code, var_ward_code;

        IF ((CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0) THEN
BEGIN
                IF var_max_tx_date = par_in_date THEN
                    RAISE NOTICE 'update today data : var_previous_remaining: %, var_remain: %', var_previous_remaining, var_remain;
SELECT
    var_previous_remaining + var_remain
INTO var_previous_remaining;
ELSE
BEGIN
SELECT
    var_previous_remaining + var_remain + var_adm - var_dsch + var_transfer_in - var_transfer_out - var_death + var_td_transfer_in - var_td_transfer_out
INTO var_previous_remaining;
RAISE NOTICE 'update before : var_previous_remaining: %, var_remain: %', var_previous_remaining, var_remain;

                        DECLARE
result_Canc_admission integer;
                            result_Canc_discharge integer;
                            result_Canc_transfer_in integer;
                            result_Canc_transfer_out integer;
                            result_Canc_transfer_in_from_TD integer;
                            result_Canc_transfer_out_to_TD integer;
                            result_Canc_death integer;

begin
--                            SELECT
--                                COALESCE(SUM(Canc_admission), 0), 
--                                COALESCE(SUM(Canc_discharge), 0), 
--                                COALESCE(SUM(Canc_transfer_in), 0), 
--                                COALESCE(SUM(Canc_transfer_out), 0), 
--                                COALESCE(SUM(Canc_transfer_in_from_TD), 0), 
--                                COALESCE(SUM(Canc_transfer_out_to_TD), 0), 
--                                COALESCE(SUM(Canc_death), 0)
--                                INTO result_Canc_admission, result_Canc_discharge, result_Canc_transfer_in, result_Canc_transfer_out, result_Canc_transfer_in_from_TD, result_Canc_transfer_out_to_TD, result_Canc_death
--                                FROM Ward_spec_adj
--                                WHERE ((Ward_code = var_ward_code) or (Ward_code is null) ) 
--                                       AND ((Specialty_code = var_spec_code)  or (Specialty_code is null)) 
--                                       AND ((Treatment_location = var_tr_loc) or (Treatment_location is null)) 
--                                       AND ((Ward_spec_adj_date >= var_max_tx_date)  or (var_max_tx_date is null) or (Ward_spec_adj_date is null)) 
--                                       AND (Ward_spec_adj_date <= par_in_date) 
--                                       AND (Hospital_code = par_hosp_code);
--                            
--                            IF FOUND THEN
--                                var_c_adm = result_Canc_admission;
--                                var_c_dsch = result_Canc_discharge;
--                                var_c_transfer_in = result_Canc_transfer_in;
--                                var_c_transfer_out = result_Canc_transfer_out;
--                                var_c_td_transfer_in = result_Canc_transfer_in_from_TD;
--                                var_c_td_transfer_out = result_Canc_transfer_out_to_TD;
--                                var_c_death = result_Canc_death;
--                            end IF;
	                        
	                        
--					  IF var_tr_loc IS NULL THEN
SELECT
    COALESCE(SUM(Canc_admission), 0),
    COALESCE(SUM(Canc_discharge), 0),
    COALESCE(SUM(Canc_transfer_in), 0),
    COALESCE(SUM(Canc_transfer_out), 0),
    COALESCE(SUM(Canc_transfer_in_from_TD), 0),
    COALESCE(SUM(Canc_transfer_out_to_TD), 0),
    COALESCE(SUM(Canc_death), 0)
INTO result_Canc_admission, result_Canc_discharge, result_Canc_transfer_in, result_Canc_transfer_out, result_Canc_transfer_in_from_TD, result_Canc_transfer_out_to_TD, result_Canc_death
FROM Ward_spec_adj
WHERE (Ward_code = var_ward_code)
  AND (Specialty_code = var_spec_code)
--				              AND (Treatment_location IS NULL)
  AND ((Treatment_location = var_tr_loc) or  (var_tr_loc IS NULL AND Treatment_location IS NULL))
  AND ((Ward_spec_adj_date >= var_max_tx_date) OR (var_max_tx_date IS NULL) OR (Ward_spec_adj_date IS NULL))
  AND (Ward_spec_adj_date <= par_in_date)
  AND (Hospital_code = par_hosp_code);
--				
--				    ELSE
--				        SELECT
--				            COALESCE(SUM(Canc_admission), 0),
--				            COALESCE(SUM(Canc_discharge), 0),
--				            COALESCE(SUM(Canc_transfer_in), 0),
--				            COALESCE(SUM(Canc_transfer_out), 0),
--				            COALESCE(SUM(Canc_transfer_in_from_TD), 0),
--				            COALESCE(SUM(Canc_transfer_out_to_TD), 0),
--				            COALESCE(SUM(Canc_death), 0)
--				        INTO result_Canc_admission, result_Canc_discharge, result_Canc_transfer_in, result_Canc_transfer_out, result_Canc_transfer_in_from_TD, result_Canc_transfer_out_to_TD, result_Canc_death
--				        FROM Ward_spec_adj
--				        WHERE (Ward_code = var_ward_code) 
--				              AND (Specialty_code = var_spec_code)
--				              AND (Treatment_location = var_tr_loc)
--				              AND ((Ward_spec_adj_date >= var_max_tx_date) OR (var_max_tx_date IS NULL) OR (Ward_spec_adj_date IS NULL))
--				              AND (Ward_spec_adj_date <= par_in_date)
--				              AND (Hospital_code = par_hosp_code);
--				    END IF;

IF FOUND THEN
				        var_c_adm := result_Canc_admission;
				        var_c_dsch := result_Canc_discharge;
				        var_c_transfer_in := result_Canc_transfer_in;
				        var_c_transfer_out := result_Canc_transfer_out;
				        var_c_td_transfer_in := result_Canc_transfer_in_from_TD;
				        var_c_td_transfer_out := result_Canc_transfer_out_to_TD;
				        var_c_death := result_Canc_death;
END IF;
END;

GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
IF (sql$rowcount = 1) THEN
BEGIN
SELECT
    var_previous_remaining - var_c_adm + var_c_dsch - var_c_transfer_in + var_c_transfer_out + var_c_death - var_c_td_transfer_in + var_c_td_transfer_out
INTO var_previous_remaining;
RAISE NOTICE 'update after : var_previous_remaining: %, var_remain: %', var_previous_remaining, var_remain;
END;
END IF;
END;
END IF;
END;
ELSE
		        EXIT;
END IF;
		    
		    RAISE NOTICE '-----------------------------';
END LOOP; /* end while */
CLOSE ward_spec_tx;
/* --- Add hospital code for HPI by ML on 26.07.1999 */

BEGIN
SELECT
    COALESCE(SUM(Admission), 0), COALESCE(SUM(Discharge), 0), COALESCE(SUM(Transfer_in_from_TD), 0), COALESCE(SUM(Transfer_out_to_TD), 0), COALESCE(SUM(Death), 0), COALESCE(SUM(AE_day_discharge), 0), COALESCE(SUM(AE_day_death), 0)
INTO var_admission, var_discharge, var_td_transfer_in, var_td_transfer_out, var_death, var_ae_day_dsch, var_ae_day_deth
FROM Ward_spec_tx
WHERE Ward_spec_tx_date = par_in_date AND Hospital_code = par_hosp_code;
EXCEPTION
	        WHEN others THEN
BEGIN
SELECT
    0
INTO var_admission;
SELECT
    0
INTO var_discharge;
SELECT
    0
INTO var_td_transfer_in;
SELECT
    0
INTO var_td_transfer_out;
SELECT
    0
INTO var_death;
SELECT
    0
INTO var_ae_day_dsch;
SELECT
    0
INTO var_ae_day_deth;
END;
END;
	/* --- Add hospital code for HPI by ML on 26.07.1999 */

BEGIN
SELECT
    COALESCE(SUM(Canc_admission), 0), COALESCE(SUM(Canc_discharge), 0), COALESCE(SUM(Canc_transfer_in_from_TD), 0), COALESCE(SUM(Canc_transfer_out_to_TD), 0), COALESCE(SUM(Canc_death), 0), COALESCE(SUM(Canc_AE_day_discharge), 0), COALESCE(SUM(Canc_AE_day_death), 0)
INTO var_canc_admission, var_canc_discharge, var_canc_td_transfer_in, var_canc_td_transfer_out, var_canc_death, var_canc_ae_day_dsch, var_canc_ae_day_deth
FROM Ward_spec_adj
WHERE Ward_spec_adj_date = par_in_date AND Hospital_code = par_hosp_code;
EXCEPTION
	        WHEN others THEN
BEGIN
SELECT
    0
INTO var_canc_admission;
SELECT
    0
INTO var_canc_discharge;
SELECT
    0
INTO var_canc_td_transfer_in;
SELECT
    0
INTO var_canc_td_transfer_out;
SELECT
    0
INTO var_canc_death;
SELECT
    0
INTO var_canc_ae_day_dsch;
SELECT
    0
INTO var_canc_ae_day_deth;
END;
END;

OPEN p_refcur FOR
SELECT
    var_no_of_ae01_bed, var_no_of_total_bed, var_previous_remaining, var_admission, var_discharge, var_td_transfer_in, var_td_transfer_out, var_death, var_canc_admission, var_canc_discharge, var_canc_td_transfer_in, var_canc_td_transfer_out, var_canc_death, par_in_date, var_prev_date, var_ae_day_dsch, var_ae_day_deth, var_canc_ae_day_dsch, var_canc_ae_day_deth;
return next p_refcur;

END;
$function$
;

;ALTER FUNCTION "hasp_bed_statistics" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
