CREATE OR REPLACE FUNCTION hasp_inpatient_statistic(IN par_hosp_code VARCHAR, IN par_input_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_input_to_date TIMESTAMP WITHOUT TIME ZONE)
RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_average_bed_complement REAL;
    var_available_bed_day REAL;
    var_inpatient_remaining REAL;
    var_emergency_day_admission REAL;
    var_vacant_bed_days REAL;
    var_excess_bed_days REAL;
    var_average_daily_bed_occupancy REAL;
    var_percentage_of_occupancy REAL;
    var_no_of_in_day_treated REAL;
    var_no_of_day_treated REAL;
    var_length_of_stay REAL;
    var_turnover REAL;
    var_turnover_day_in_btn_patient REAL;
    var_turnover_day_bed_period REAL;
    var_gross_death_per_1000 REAL;
    var_death_per_1000_less_24 REAL;
    var_death_per_1000_less_48 REAL;
    var_p_average_bed_complement REAL;
    var_p_available_bed_day REAL;
    var_p_inpatient_remaining REAL;
    var_p_emergency_day_admission REAL;
    var_p_vacant_bed_days REAL;
    var_p_excess_bed_days REAL;
    var_p_average_daily_bed_occupancy REAL;
    var_p_percentage_of_occupancy REAL;
    var_p_no_of_in_day_treated REAL;
    var_p_no_of_day_treated REAL;
    var_p_length_of_stay REAL;
    var_p_turnover REAL;
    var_p_turnover_day_in_btn_patient REAL;
    var_p_turnover_day_bed_period REAL;
    var_p_gross_death_per_1000 REAL;
    var_p_death_per_1000_less_24 REAL;
    var_p_death_per_1000_less_48 REAL;
    p_refcur refcursor;
    var_return_code int;
BEGIN
    SELECT
        CONCAT(to_char(par_input_to_date,'YYYYMMDD'), ' 23:59:59.999')::TIMESTAMP
        INTO par_input_to_date;
    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
    CALL hasp_hospital_inpatient_tx(var_return_code, par_input_from_date, par_input_to_date, par_hosp_code, var_average_bed_complement, var_available_bed_day, var_inpatient_remaining, var_emergency_day_admission, var_vacant_bed_days, var_excess_bed_days, var_average_daily_bed_occupancy, var_percentage_of_occupancy, var_no_of_in_day_treated, var_no_of_day_treated, var_length_of_stay, var_turnover, var_turnover_day_in_btn_patient, var_turnover_day_bed_period, var_gross_death_per_1000, var_death_per_1000_less_24, var_death_per_1000_less_48);
    SELECT
        - 1 * INTERVAL '1 year' + par_input_from_date::TIMESTAMP, - 1 * INTERVAL '1 year' + par_input_to_date::TIMESTAMP
        INTO par_input_from_date, par_input_to_date;
    /* --- Add hosp code for HPI by ML on 26.07.1999 --- */
    CALL hasp_hospital_inpatient_tx(var_return_code, par_input_from_date, par_input_to_date, par_hosp_code, var_p_average_bed_complement, var_p_available_bed_day, var_p_inpatient_remaining, var_p_emergency_day_admission, var_p_vacant_bed_days, var_p_excess_bed_days, var_p_average_daily_bed_occupancy, var_p_percentage_of_occupancy, var_p_no_of_in_day_treated, var_p_no_of_day_treated, var_p_length_of_stay, var_p_turnover, var_p_turnover_day_in_btn_patient, var_p_turnover_day_bed_period, var_p_gross_death_per_1000, var_p_death_per_1000_less_24, var_p_death_per_1000_less_48);
    OPEN p_refcur FOR
    SELECT
        var_average_bed_complement, var_p_average_bed_complement, var_available_bed_day, var_p_available_bed_day, var_inpatient_remaining, var_p_inpatient_remaining, var_emergency_day_admission, var_p_emergency_day_admission, var_vacant_bed_days, var_p_vacant_bed_days, var_excess_bed_days, var_p_excess_bed_days, var_average_daily_bed_occupancy, var_p_average_daily_bed_occupancy, var_percentage_of_occupancy, var_p_percentage_of_occupancy, var_no_of_in_day_treated, var_p_no_of_in_day_treated, var_no_of_day_treated, var_p_no_of_day_treated, var_length_of_stay, var_p_length_of_stay, var_turnover, var_p_turnover, var_turnover_day_in_btn_patient, var_p_turnover_day_in_btn_patient, var_turnover_day_bed_period, var_p_turnover_day_bed_period, var_gross_death_per_1000, var_p_gross_death_per_1000, var_death_per_1000_less_24, var_p_death_per_1000_less_24, var_death_per_1000_less_48, var_p_death_per_1000_less_48;
    return next p_refcur;
END;
$function$
;

;ALTER FUNCTION "hasp_inpatient_statistic" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
