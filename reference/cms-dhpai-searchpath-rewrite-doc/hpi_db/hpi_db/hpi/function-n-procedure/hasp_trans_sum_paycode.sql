-- DROP FUNCTION hasp_trans_sum_paycode(varchar, varchar, timestamp, timestamp, varchar, varchar);

CREATE OR REPLACE FUNCTION hasp_trans_sum_paycode(par_hosp_code character varying, par_pay_code character varying, par_start_date timestamp without time zone, par_end_date timestamp without time zone, par_input_ward character varying, par_input_spec character varying)
 RETURNS TABLE(pay_adm integer, total_adm integer, cadm integer, cadm_tot integer, disc integer, disc_tot integer, death integer, death_tot integer, tr_disc integer, tr_disc_tot integer, return_from_trial integer, return_from_trial_tot integer, day_disc integer, day_disc_tot integer, day_death integer, day_death_tot integer, total_ae_attend integer, total_ae_attend_tot integer, dba_at_ae integer, dba_at_ae_tot integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_pay_adm               INTEGER;
    var_total_adm             INTEGER;
    var_cadm                  INTEGER;
    var_cadm_tot              INTEGER;
    var_disc                  INTEGER;
    var_disc_tot              INTEGER;
    var_death                 INTEGER;
    var_death_tot             INTEGER;
    var_tr_disc               INTEGER;
    var_tr_disc_tot           INTEGER;
    var_return_from_trial     INTEGER;
    var_return_from_trial_tot INTEGER;
    var_day_disc              INTEGER;
    var_day_disc_tot          INTEGER;
    var_day_death             INTEGER;
    var_day_death_tot         INTEGER;
    var_total_ae_attend       INTEGER;
    var_total_ae_attend_tot   INTEGER;
    var_DBA_at_ae             INTEGER;
    var_DBA_at_ae_tot         INTEGER;
BEGIN
    -- Adjust end date
    par_end_date := par_end_date + INTERVAL '1 day';

    -- Retrieve A&E Admission for selected paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_pay_adm
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE cv.source_indicator = '3'
      AND cv.pay_code LIKE par_pay_code
      AND tl.transaction_type = '100'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total A&E Admission
    SELECT COUNT(*)
    INTO var_total_adm
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE cv.source_indicator = '3'
      AND tl.transaction_type = '100'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve clinical Admission for selected paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_cadm
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE cv.source_indicator <> '3'
      AND cv.pay_code LIKE par_pay_code
      AND tl.transaction_type = '100'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total clinical Admission
    SELECT COUNT(*)
    INTO var_cadm_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE cv.source_indicator <> '3'
      AND tl.transaction_type = '100'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve Discharge for selected paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_disc
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type LIKE '13_'
      AND tl.transaction_type <> '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total Discharge
    SELECT COUNT(*)
    INTO var_disc_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type LIKE '13_'
      AND tl.transaction_type <> '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve Death for selected paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_death
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total Death
    SELECT COUNT(*)
    INTO var_death_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve Trial Discharge for selected paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_tr_disc
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '160'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total Trial Discharge
    SELECT COUNT(*)
    INTO var_tr_disc_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '160'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve Return from trial discharge for selected paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_return_from_trial
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '171'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total Return from trial discharge
    SELECT COUNT(*)
    INTO var_return_from_trial_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '171'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve discharge for day patient by paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_day_disc
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type LIKE '13_'
      AND tl.transaction_type <> '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND DATE(cv.admission_datetime) = DATE(cv.discharge_datetime)
      AND cv.source_indicator <> '3'
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total discharge for day patient
    SELECT COUNT(*)
    INTO var_day_disc_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type LIKE '13_'
      AND tl.transaction_type <> '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.source_indicator <> '3'
      AND DATE(cv.admission_datetime) = DATE(cv.discharge_datetime)
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve Death for day patient by paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_day_death
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND DATE(cv.admission_datetime) = DATE(cv.discharge_datetime)
      AND cv.source_indicator <> '3'
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total Death for day patient
    SELECT COUNT(*)
    INTO var_day_death_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '131'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.source_indicator <> '3'
      AND DATE(cv.admission_datetime) = DATE(cv.discharge_datetime)
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve A&E attendance for paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_total_ae_attend
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '300'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve total A&E attendance
    SELECT COUNT(*)
    INTO var_total_ae_attend_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
    WHERE tl.transaction_type = '300'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code;

    -- Retrieve Death before arrival by paycode, ward & specialty
    SELECT COUNT(*)
    INTO var_DBA_at_ae
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
             JOIN ae_case_detail acd ON cv.case_no = acd.case_no
    WHERE tl.transaction_type = '300'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND cv.pay_code LIKE par_pay_code
      AND acd.dba_flag = 'Y'
      AND tl.cancel_flag IS NULL
      AND tl.from_ward_code LIKE par_input_ward
      AND tl.from_specialty_code LIKE par_input_spec
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code
      AND acd.hospital_code = par_hosp_code;

    -- Retrieve total Death before arrival
    SELECT COUNT(*)
    INTO var_DBA_at_ae_tot
    FROM case_view cv
             JOIN transaction_log tl ON cv.case_no = tl.case_no
             JOIN ae_case_detail acd ON cv.case_no = acd.case_no
    WHERE tl.transaction_type = '300'
      AND tl.transaction_datetime >= par_start_date
      AND tl.transaction_datetime < par_end_date
      AND acd.dba_flag = 'Y'
      AND tl.cancel_flag IS NULL
      AND tl.hospital_code = par_hosp_code
      AND cv.hospital_code = par_hosp_code
      AND acd.hospital_code = par_hosp_code;

    -- Return results
    RETURN QUERY SELECT var_pay_adm,
                        var_total_adm,
                        var_cadm,
                        var_cadm_tot,
                        var_disc,
                        var_disc_tot,
                        var_death,
                        var_death_tot,
                        var_tr_disc,
                        var_tr_disc_tot,
                        var_return_from_trial,
                        var_return_from_trial_tot,
                        var_day_disc,
                        var_day_disc_tot,
                        var_day_death,
                        var_day_death_tot,
                        var_total_ae_attend,
                        var_total_ae_attend_tot,
                        var_DBA_at_ae,
                        var_DBA_at_ae_tot;
END;
$function$
;

;ALTER FUNCTION "hasp_trans_sum_paycode" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
