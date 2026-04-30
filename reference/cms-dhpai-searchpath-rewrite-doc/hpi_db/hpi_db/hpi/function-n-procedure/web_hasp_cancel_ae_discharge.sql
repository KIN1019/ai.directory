-- DROP PROCEDURE hpi.web_hasp_cancel_ae_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in int4);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_cancel_ae_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_user_id character varying, IN par_transaction_type character varying, IN par_terminal_id character varying, IN par_case_no character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_pay_code character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_discharge_destination character varying, IN par_movement_count integer, IN par_security_count integer, IN par_case_access_code integer, IN par_adt_case_update_datetime timestamp without time zone, IN par_mrt_indicator character varying, IN par_ae_case_type character varying, IN par_ambulance_no character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_labour_case character varying, IN par_police_case character varying, IN par_last_ward_code character varying, IN par_last_ward_class character varying, IN par_last_specialty character varying, IN par_last_bed_no character varying, IN par_last_treatment_location character varying, IN par_last_movement_tran_datetime timestamp without time zone, IN par_last_movement_system_datetime timestamp without time zone, IN par_last_prev_ward_code character varying, IN par_last_prev_ward_class character varying, IN par_last_prev_specialty character varying, IN par_last_prev_bed_no character varying, IN par_last_prev_treatment_location character varying, IN par_last_prev_movement_count integer, IN par_hkid character varying, IN par_patient_key character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_religion_code character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_building character varying, IN par_home_phone character varying, IN par_office_phone character varying, IN par_office_phone_ext character varying, IN par_other_phone character varying, IN par_other_phone_ext character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_pmi_access_code integer)
 LANGUAGE plpgsql
AS $procedure$
/* --Case data */
/* --AE case detail */
/* --Last movement data */
/* --Last previous movement data */
/* --Patient major keys */
/* --Patient data (others) */
DECLARE
    var_return_code INTEGER;
    var_error_msg VARCHAR(48);
    var_trancount INTEGER;
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    <<sp_return>>
    BEGIN
        SELECT
            0
            INTO var_return_code;
        /* --jConnect 7 upgrade handling: begin tran in Sybase instead of Java */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        select @trancount = @@trancount
        */
        /* --Get current system datetime */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_system_datetime;
        /* --Call the stored proc. used in jConnect 6 version (SP + EJB) */
        CALL hasp_td_function(pas_return_code => var_return_code, par_hosp_code => par_hospital_code, par_Type => par_transaction_type, par_HKID => par_hkid, par_Case_no => par_case_no, par_Discharge_code => par_discharge_code, par_Destination_code => NULL, /* --set null to align with legacy jConnect 6 */ par_Movement_count => par_last_prev_movement_count, par_Ward_code => par_last_prev_ward_code, par_Specialty_code => par_last_prev_specialty, par_Bed_no => par_last_prev_bed_no, par_Ward_class => par_last_prev_ward_class, par_Doctor_code => NULL, par_Old_ward_code => par_last_ward_code, par_Old_specialty_code => par_last_specialty, par_Old_bed_no => par_last_bed_no, par_Old_ward_class => par_last_ward_class, par_Old_doctor_code => NULL, par_Treatment_location => par_last_prev_treatment_location, par_Follow_up_datetime => NULL, /* --set null to align with legacy jConnect 6 */ par_Discharge_datetime => NULL, /* --set null to align with legacy jConnect 6 */ par_Transfer_datetime => NULL, par_User_ID => par_user_id, par_System_datetime => var_system_datetime, par_Last_update_datetime => par_adt_case_update_datetime, par_Terminal_ID => par_terminal_id, par_MRT_indicator => NULL);

        IF var_return_code != 0 THEN
            BEGIN
                SELECT
                    299999
                    INTO var_return_code;
                SELECT
                    'Error when calling hasp_td_function'
                    INTO var_error_msg;
                raise exception '%',var_error_msg;
            END;
        END IF;
        /* --End - Call the stored proc. used in jConnect 6 version (SP + EJB) */
        /* --Insert Event_log */
        -- CALL hasp_insert_event_log(pas_return_code => var_return_code, par_hosp => par_hospital_code, "par_System_datetime" => var_system_datetime, "par_Type" => par_transaction_type, "par_HKID" => par_hkid, "par_Name" => par_name, "par_Sex" => par_sex, "par_DOB" => par_dob, "par_Exact_DOB_flag" => par_exact_dob_flag, "par_CCC_1" => par_ccc1, "par_CCC_2" => par_ccc2, "par_CCC_3" => par_ccc3, "par_CCC_4" => par_ccc4, "par_CCC_5" => par_ccc5, "par_CCC_6" => par_ccc6, "par_Martial_status" => par_marital_status, "par_Race_code" => par_race_code, "par_Other_document_no" => par_other_document_no, "par_Medical_record_number" => par_medical_record_number, "par_Building" => par_building, "par_Room" => par_room, "par_Floor" => par_floor, "par_Block" => par_block, "par_District_code" => par_district_code, "par_Religion_code" => par_religion_code, "par_Home_phone_no" => par_home_phone, "par_Other_phone_no_1" => par_office_phone, "par_Other_phone_ext_1" => par_office_phone_ext, "par_Other_phone_no_2" => par_other_phone, "par_Other_phone_ext_2" => par_other_phone_ext, "par_Death_indicator" => par_death_indicator, "par_Death_date" => par_death_date, "par_T_PRK" => par_patient_key, "par_NOK_name" => NULL, "par_NOK_HKID" => NULL, "par_NOK_relation_code" => NULL, "par_NOK_building" => NULL, "par_NOK_room" => NULL, "par_NOK_floor" => NULL, "par_NOK_block" => NULL, "par_NOK_district_code" => NULL, "par_NOK_home_phone" => NULL, "par_NOK_other_phone_no_1" => NULL, "par_NOK_other_phone_ext_1" => NULL, "par_NOK_other_phone_no_2" => NULL, "par_NOK_other_phone_ext_2" => NULL, "par_Case_no" => par_case_no, "par_Admission_datetime" => par_admission_datetime, "par_Source_indicator" => par_source_indicator, "par_Source_code" => par_source_code, "par_Pay_code" => par_pay_code, "par_Discharge_code" => par_discharge_code, "par_Discharge_datetime" => par_discharge_datetime, "par_Destination_code" => par_discharge_destination, "par_Case_type" => 'A', "par_Movement_count" => par_movement_count, "par_Security_count" => par_security_count, "par_Case_access_code" => par_case_access_code, "par_PMI_access_code" => par_pmi_access_code, "par_Ambulance_no" => par_ambulance_no, "par_Police_case" => par_police_case, "par_Labour_case" => par_labour_case, "par_AE_case_type" => par_ae_case_type, "par_DBA_flag" => par_dba_flag, "par_Follow_up_datetime" => par_follow_up_datetime, "par_Ward_code" => par_last_prev_ward_code, "par_Specialty_code" => par_last_prev_specialty, "par_Bed_no" => par_last_prev_bed_no, "par_Ward_class" => par_last_prev_ward_class, "par_Old_name" => NULL, "par_Old_HKID" => NULL, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => par_last_prev_ward_class, "par_Old_ward_code" => par_last_prev_ward_code, "par_Old_specialty_code" => par_last_prev_specialty, "par_Old_bed_no" => par_last_prev_bed_no, "par_User_ID" => par_user_id, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL); /* --set null to align with legacy jConnect 6 */
	   CALL hasp_insert_event_log(pas_return_code => var_return_code, par_hosp => par_hospital_code, "par_System_datetime" => var_system_datetime, "par_Type" => par_transaction_type, "par_HKID" => par_hkid, "par_Name" => par_name, "par_Sex" => par_sex, "par_DOB" => par_dob, "par_Exact_DOB_flag" => par_exact_dob_flag, "par_CCC_1" => par_ccc1, "par_CCC_2" => par_ccc2, "par_CCC_3" => par_ccc3, "par_CCC_4" => par_ccc4, "par_CCC_5" => par_ccc5, "par_CCC_6" => par_ccc6, "par_Martial_status" => par_marital_status, "par_Race_code" => par_race_code, "par_Other_document_no" => par_other_document_no, "par_Medical_record_number" => par_medical_record_number, "par_Building" => par_building, "par_Room" => par_room, "par_Floor" => par_floor, "par_Block" => par_block, "par_District_code" => par_district_code, "par_Religion_code" => par_religion_code, par_phone1 => par_home_phone, par_phone2 => par_office_phone, par_address_indicator => par_office_phone_ext, par_mobile_phone => par_other_phone, par_sms_language => par_other_phone_ext, "par_Death_indicator" => par_death_indicator, "par_Death_date" => par_death_date, "par_T_PRK" => par_patient_key, "par_NOK_name" => NULL, "par_NOK_HKID" => NULL, "par_NOK_relation_code" => NULL, "par_NOK_building" => NULL, "par_NOK_room" => NULL, "par_NOK_floor" => NULL, "par_NOK_block" => NULL, "par_NOK_district_code" => NULL, "par_NOK_phone1" => NULL, "par_NOK_phone2" => NULL, "par_NOK_address_indicator" => NULL, "par_NOK_mobile_phone" => NULL, "par_NOK_sms_language" => NULL, "par_Case_no" => par_case_no, "par_Admission_datetime" => par_admission_datetime, "par_Source_indicator" => par_source_indicator, "par_Source_code" => par_source_code, "par_Pay_code" => par_pay_code, "par_Discharge_code" => par_discharge_code, "par_Discharge_datetime" => par_discharge_datetime, "par_Destination_code" => par_discharge_destination, "par_Case_type" => 'A', "par_Movement_count" => par_movement_count, "par_Security_count" => par_security_count, "par_Case_access_code" => par_case_access_code, "par_PMI_access_code" => par_pmi_access_code, "par_Ambulance_no" => par_ambulance_no, "par_Police_case" => par_police_case, "par_Labour_case" => par_labour_case, "par_AE_case_type" => par_ae_case_type, "par_DBA_flag" => par_dba_flag, "par_Follow_up_datetime" => par_follow_up_datetime, "par_Ward_code" => par_last_prev_ward_code, "par_Specialty_code" => par_last_prev_specialty, "par_Bed_no" => par_last_prev_bed_no, "par_Ward_class" => par_last_prev_ward_class, "par_Old_name" => NULL, "par_Old_HKID" => NULL, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => par_last_prev_ward_class, "par_Old_ward_code" => par_last_prev_ward_code, "par_Old_specialty_code" => par_last_prev_specialty, "par_Old_bed_no" => par_last_prev_bed_no, "par_User_ID" => par_user_id, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL); /* --set null to align with legacy jConnect 6 */
       IF var_return_code != 0 THEN
            BEGIN
                SELECT
                    299999
                    INTO var_return_code;
                SELECT
                    'Fail to insert Event_log'
                    INTO var_error_msg;
                raise exception '%',var_error_msg;
            END;
        END IF;
        /* --End - Insert Event_log */
        /* --Insert Transaction_log */
		CALL hasp_insert_transaction_log(pas_return_code => var_return_code, par_hosp => par_hospital_code, "par_System_datetime" => var_system_datetime, "par_Case_no" => par_case_no, "par_From_ward_code" => par_last_ward_code, "par_From_treatment_location" => par_last_treatment_location, "par_From_class" => par_last_ward_class, "par_From_specialty_code" => par_last_specialty, "par_From_bed" => par_last_bed_no, "par_To_ward_code" => NULL, "par_To_treatment_location" => NULL, "par_To_class" => NULL, "par_To_bed" => NULL, "par_To_specialty_code" => NULL, "par_Transaction_datetime" => par_last_movement_tran_datetime, "par_Transaction_type" => par_transaction_type, "par_Post_datetime" => NULL, "par_User_ID" => par_user_id, "par_Post_flag" => 'Y', "par_Prev_system_datetime" => par_last_movement_system_datetime);
        
		IF var_return_code != 0 THEN
            BEGIN
                SELECT
                    299999
                    INTO var_return_code;
                SELECT
                    'Fail to insert Transaction_log'
                    INTO var_error_msg;
                raise exception '%',var_error_msg;
            END;
        END IF;
        /* --End - Insert Transaction_log */
    END;

    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_cancel_ae_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
