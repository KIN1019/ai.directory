-- DROP PROCEDURE hpi.opas_cpi_admission(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in int4, in int4, inout varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in timestamp, in varchar, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.opas_cpi_admission(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_chi_name character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_reference character varying, IN par_medical_record_number character varying, IN par_remark character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_home_phone_no character varying, IN par_other_phone_no_1 character varying, IN par_other_phone_ext_1 character varying, IN par_other_phone_no_2 character varying, IN par_other_phone_ext_2 character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_death_code character varying, IN par_card_holder integer, IN par_case_access_code integer, IN par_pmi_access_code integer, IN par_security_count integer, INOUT par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_home_phone character varying, IN par_nok_other_phone_no_1 character varying, IN par_nok_other_phone_ext_1 character varying, IN par_nok_other_phone_no_2 character varying, IN par_nok_other_phone_ext_2 character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_patient_type character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_bed_no character varying, IN par_ward_class character varying, IN par_pp_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* 2004-12-7 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number */
/* 2004-12-7 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - Start */
/* 2004-12-7 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - End */
DECLARE
    var_return_code INTEGER;
    var_return_message VARCHAR(255);
    var_real_last_update_dt TIMESTAMP WITHOUT TIME ZONE;

BEGIN
    SELECT
        update_dtm
        INTO var_real_last_update_dt
        FROM cpi_patient
        WHERE patient_key = par_patient_key;
    /* Check the date and the time without mini-second as PB datetime type not store mini-second */
    IF TO_CHAR(var_real_last_update_dt, 'YYYYMMDD') = TO_CHAR(par_last_update_datetime, 'YYYYMMDD')
       AND TO_CHAR(var_real_last_update_dt, 'HH24MISS') = TO_CHAR(par_last_update_datetime, 'HH24MISS') THEN
       BEGIN
            CALL cpi_admission( var_return_code,par_hospital_code, par_case_no, par_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_medical_record_number, par_remark, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_home_phone_no, par_other_phone_no_1, par_other_phone_ext_1, par_other_phone_no_2, par_other_phone_ext_2, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_case_access_code, par_pmi_access_code, par_security_count, par_patient_key, par_priority, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2, par_admission_datetime, par_source_indicator, par_source_code, par_patient_type, par_discharge_code, par_discharge_datetime, par_destination_code, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba_flag, par_follow_up_datetime, par_ward_code, par_specialty_code, par_sub_specialty, par_bed_no, par_ward_class, par_pp_code, par_case_type, par_txn_type, par_transaction_datetime, par_update_by, var_real_last_update_dt, par_source_system,
            /* 2004-12-7 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - Start */
            par_document_flag, par_eh_code);

            /* 2004-12-7 Noel Chan SMR20013770 PAS -- Add a Document Type for user to put the Identity Document type & number - End */
        END;
    ELSE
        BEGIN
            /* 7016 - Patient has been updated after transaction */
            SELECT
                7016
                INTO var_return_code;
        END;
    END IF;

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
END;
$procedure$
;

;ALTER PROCEDURE "opas_cpi_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
