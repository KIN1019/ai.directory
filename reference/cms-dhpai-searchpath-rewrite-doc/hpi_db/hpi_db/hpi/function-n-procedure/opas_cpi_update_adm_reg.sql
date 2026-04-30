-- DROP FUNCTION hpi.opas_cpi_update_adm_reg(varchar, varchar, varchar, timestamp, varchar, varchar, varchar, varchar, timestamp, varchar, varchar, varchar, varchar, varchar, varchar, timestamp, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, varchar, timestamp, varchar, varchar);

CREATE OR REPLACE FUNCTION opas_cpi_update_adm_reg(par_hospital_code character varying, par_case_no character varying, par_hkid character varying, par_admission_datetime timestamp without time zone, par_source_indicator character varying, par_source_code character varying, par_patient_type character varying, par_discharge_code character varying, par_discharge_datetime timestamp without time zone, par_destination_code character varying, par_ambulance_no character varying, par_police_case character varying, par_labour_case character varying, par_ae_case_type character varying, par_dba_flag character varying, par_follow_up_datetime timestamp without time zone, par_ward_code character varying, par_ward_class character varying, par_bed_no character varying, par_specialty_code character varying, par_sub_specialty character varying, par_pp_code character varying, par_case_type character varying, par_txn_type character varying, par_update_type character varying, par_transaction_datetime timestamp without time zone, par_update_by character varying, par_source_system character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
/* 2007-10-16 Shelley SMR20016548 Change From RPC to DC */
DECLARE
    var_return_code INTEGER;
    var_return_message VARCHAR(255);
    p_refcur refcursor;

BEGIN
    SELECT
        LTRIM(RTRIM(par_ward_code))
        INTO par_ward_code;
    SELECT
        LTRIM(RTRIM(par_bed_no))
        INTO par_bed_no;
    SELECT
        LTRIM(RTRIM(par_sub_specialty))
        INTO par_sub_specialty;
    SELECT
        LTRIM(RTRIM(par_ward_class))
        INTO par_ward_class;
    SELECT
        LTRIM(RTRIM(par_dba_flag))
        INTO par_dba_flag;
    SELECT
        LTRIM(RTRIM(par_labour_case))
        INTO par_labour_case;
    SELECT
        LTRIM(RTRIM(par_police_case))
        INTO par_police_case;
    SELECT
        LTRIM(RTRIM(par_ambulance_no))
        INTO par_ambulance_no;
    SELECT
        LTRIM(RTRIM(par_destination_code))
        INTO par_destination_code;

    IF par_discharge_code IS NULL THEN
        BEGIN
            SELECT
                NULL
                INTO par_discharge_datetime;
        END;
    END IF;
    SELECT
        LTRIM(RTRIM(par_discharge_code))
        INTO par_discharge_code;
    SELECT
        LTRIM(RTRIM(par_source_code))
        INTO par_source_code;
    SELECT
        LTRIM(RTRIM(par_source_indicator))
        INTO par_source_indicator;
    SELECT
        NULL
        INTO par_follow_up_datetime;
    CALL cpi_update_adm_registration(var_return_code,par_hospital_code, par_case_no, par_hkid, par_admission_datetime, par_source_indicator, par_source_code, par_patient_type, par_discharge_code, par_discharge_datetime, par_destination_code, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba_flag, par_follow_up_datetime, par_ward_code, par_ward_class, par_bed_no, par_specialty_code, par_sub_specialty, par_pp_code, par_case_type, par_txn_type, par_update_type, par_transaction_datetime, par_update_by, par_source_system);


    IF var_return_code = 0 THEN
        BEGIN
            SELECT
                ''
                INTO var_return_message;
        END;
    ELSE
        BEGIN
            SELECT
                CONCAT(messages, ' - CPI Error!')
                INTO var_return_message
                FROM error_msgs
                WHERE error_code = var_return_code;
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        var_return_code, var_return_message;
      RETURN
    NEXT p_refcur;
END;
$function$
;


;ALTER FUNCTION "opas_cpi_update_adm_reg" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
