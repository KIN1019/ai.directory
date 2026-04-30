CREATE OR REPLACE PROCEDURE hpi.web_hasp_adt_function(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_type character varying, INOUT par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_arr character varying[], IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_home_phone_no character varying, IN par_other_phone1 character varying[], IN par_other_phone2 character varying[], IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_t_prk character varying, IN par_nok_priority integer, IN par_nok_arr character varying[], IN par_nok2_priority integer, IN par_nok2_arr character varying[], IN par_nok3_priority integer, IN par_nok3_arr character varying[], IN par_nok4_priority integer, IN par_nok4_arr character varying[], IN par_nok5_priority integer, IN par_nok5_arr character varying[], IN par_nok6_priority integer, IN par_nok6_arr character varying[], IN par_nok7_priority integer, IN par_nok7_arr character varying[], IN par_nok8_priority integer, IN par_nok8_arr character varying[], IN par_nok9_priority integer, IN par_nok9_arr character varying[], IN par_nok10_priority integer, IN par_nok10_arr character varying[], IN par_case_no character varying DEFAULT NULL::character varying, IN par_admission_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_source_indicator character varying DEFAULT NULL::character varying, IN par_source_code character varying DEFAULT NULL::character varying, IN par_pay_code character varying DEFAULT NULL::character varying, IN par_discharge_code character varying DEFAULT NULL::character varying, IN par_discharge_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_destination_code character varying DEFAULT NULL::character varying, IN par_case_type character varying DEFAULT NULL::character varying, IN par_movement_count integer DEFAULT NULL::integer, IN par_security_count integer DEFAULT NULL::integer, IN par_case_access_code integer DEFAULT NULL::integer, IN par_pmi_access_code integer DEFAULT NULL::integer, IN par_ambulance_no character varying DEFAULT NULL::character varying, IN par_police_case character varying DEFAULT NULL::character varying, IN par_labour_case character varying DEFAULT NULL::character varying, IN par_ae_case_type character varying DEFAULT NULL::character varying, IN par_dba_flag character varying DEFAULT NULL::character varying, IN par_follow_up_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_ward_code character varying DEFAULT NULL::character varying, IN par_specialty_code character varying DEFAULT NULL::character varying, IN par_bed_no character varying DEFAULT NULL::character varying, IN par_ward_class character varying DEFAULT NULL::character varying, IN par_transfer_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_old_name character varying DEFAULT NULL::character varying, IN par_old_hkid character varying DEFAULT NULL::character varying, IN par_old_sex character varying DEFAULT NULL::character varying, IN par_old_dob timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_old_ward_class character varying DEFAULT NULL::character varying, IN par_old_ward_code character varying DEFAULT NULL::character varying, IN par_old_specialty_code character varying DEFAULT NULL::character varying, IN par_old_bed_no character varying DEFAULT NULL::character varying, IN par_user_id character varying DEFAULT NULL::character varying, IN par_doctor_code character varying DEFAULT NULL::character varying, IN par_old_doctor_code character varying DEFAULT NULL::character varying, IN par_old_t_prk character varying DEFAULT NULL::character varying, IN par_pp_code character varying DEFAULT NULL::character varying, IN par_last_update_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_terminal_id character varying DEFAULT NULL::character varying, IN par_old_nok_name character varying DEFAULT NULL::character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying, IN par_source_hosp_code character varying DEFAULT NULL::character varying, IN par_source_case_no character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_hkic_symbol_clear character varying DEFAULT 'N'::character varying, IN par_move_episode_status character varying DEFAULT NULL::character varying, IN par_me_info_source_code character varying DEFAULT NULL::character varying, IN par_me_reason_code character varying DEFAULT NULL::character varying, IN par_me_other_reason character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* major NOK */
/* NOK 2 */
/* NOK 3 */
/* NOK 4 */
/* NOK 5 */
/* NOK 6 */
/* NOK 7 */
/* NOK 8 */
/* NOK 9 */
/* NOK 10 */
/* Case */
DECLARE
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_tmp_hkid VARCHAR(9);
    var_current_datetime TIMESTAMP WITHOUT TIME ZONE;
--    hasp_get_next_un$refcur_1 refcursor;
BEGIN
    <<error>>
    BEGIN
        /* --	set @current_datetime = getdate() */
        var_current_datetime := 3 * INTERVAL '1 millisecond' + par_System_datetime::TIMESTAMP;
        /* Open transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        		begin transaction
        */
        /* ******************************************************** */
        /* Get a pseudo ID from Hospital table when HKID is empty */
        /* Patient registration */
        /* ******************************************************** */
        IF par_T_PRK IS NULL THEN
            BEGIN
                IF par_HKID IS NULL OR par_HKID = '' OR par_HKID = 'UN' THEN
                    BEGIN
                        CALL hasp_get_next_un(var_retcode, par_hosp_code, var_tmp_hkid);
                        -- CLOSE hasp_get_next_un$refcur_1;

                        IF var_retcode != 0 THEN
                            raise exception '';
                        END IF;
                        CALL web_hasp_get_hkid_check_digit(var_retcode, var_tmp_hkid, par_HKID);

                        IF var_retcode != 0 THEN
                            raise exception '';
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* delete all non-major contact persons before update patient */
        CALL web_hasp_update_noks(pas_return_code => var_retcode,par_hosp_code => par_hosp_code, par_System_datetime => par_System_datetime, par_HKID => par_Old_HKID, par_T_PRK => par_Old_T_PRK, par_User_ID => par_User_ID);
        IF var_retcode <> 0 THEN
            raise exception '';
        END IF;
        /* End - delete all non-major contact persons before update patient */
        /* make sure the return is HKID */
        /* --	select @HKID */
        CALL hasp_adt_function_woresult(pas_return_code => var_retcode,par_hosp_code => par_hosp_code, par_System_datetime => par_System_datetime, par_Type => par_Type, par_HKID => par_HKID, par_Name => par_Name, par_Sex => par_Sex, par_DOB => par_DOB, par_Exact_DOB_flag => par_Exact_DOB_flag, par_CCC_1 => par_CCC_arr[1] , par_CCC_2 => par_CCC_arr[2], par_CCC_3 => par_CCC_arr[3], par_CCC_4 => par_CCC_arr[4], par_CCC_5 => par_CCC_arr[5], par_CCC_6 => par_CCC_arr[6], par_Marital_status => par_Marital_status, par_Race_code => par_Race_code, par_Other_document_no => par_Other_document_no, par_Medical_record_number => par_Medical_record_number, par_Building => par_Building, par_Room => par_Room, par_Floor => par_Floor, par_Block => par_Block, par_District_code => par_District_code, par_Religion_code => par_Religion_code, par_phone1 => par_Home_phone_no, par_phone2 => par_Other_phone1[1], par_address_indicator => par_Other_phone1[2], par_mobile_phone => par_Other_phone2[1], par_sms_language => par_Other_phone2[2], par_Death_indicator => par_Death_indicator, par_Death_date => par_Death_date, par_T_PRK => par_T_PRK, par_NOK_priority => par_NOK_priority, par_NOK_name => par_nok_arr[1], par_NOK_HKID => par_nok_arr[2], par_NOK_relation_code => par_nok_arr[3], par_NOK_building => par_nok_arr[4], par_NOK_room => par_nok_arr[5], par_NOK_floor => par_nok_arr[6], par_NOK_block => par_nok_arr[7], par_NOK_district_code => par_nok_arr[8], par_NOK_phone1 => par_nok_arr[9], par_NOK_phone2 => par_nok_arr[10], par_NOK_address_indicator => par_nok_arr[11], par_NOK_mobile_phone => par_nok_arr[12], par_NOK_sms_language => par_nok_arr[13], par_Case_no => par_Case_no, par_Admission_datetime => par_Admission_datetime, par_Source_indicator => par_Source_indicator, par_Source_code => par_Source_code, par_Pay_code => par_Pay_code, par_Discharge_code => par_Discharge_code, par_Discharge_datetime => par_Discharge_datetime, par_Destination_code => par_Destination_code, par_Case_type => par_Case_type, par_Movement_count => par_Movement_count, par_Security_count => par_Security_count, par_Case_access_code => par_Case_access_code, par_PMI_access_code => par_PMI_access_code, par_Ambulance_no => par_Ambulance_no, par_Police_case => par_Police_case, par_Labour_case => par_Labour_case, par_AE_case_type => par_AE_case_type, par_DBA_flag => par_DBA_flag, par_Follow_up_datetime => par_Follow_up_datetime, par_Ward_code => par_Ward_code, par_Specialty_code => par_Specialty_code, par_Bed_no => par_Bed_no, par_Ward_class => par_Ward_class, par_Transfer_datetime => par_Transfer_datetime, par_Old_name => par_Old_name, par_Old_HKID => par_Old_HKID, par_Old_sex => par_Old_sex, par_Old_DOB => par_Old_DOB, par_Old_ward_class => par_Old_ward_class, par_Old_ward_code => par_Old_ward_code, par_Old_specialty_code => par_Old_specialty_code, par_Old_bed_no => par_Old_bed_no, par_User_ID => par_User_ID, par_Doctor_code => par_Doctor_code, par_Old_doctor_code => par_Old_doctor_code, par_Old_T_PRK => par_Old_T_PRK, par_PP_code => par_PP_code, par_Last_update_datetime => par_Last_update_datetime, par_Terminal_id => par_Terminal_id, par_Old_NOK_name => par_Old_NOK_name, par_Document_flag => par_Document_flag, par_eh_code => par_eh_code, par_source_hosp_code => par_source_hosp_code, par_source_case_no => par_source_case_no, par_hkic_symbol => par_hkic_symbol, par_hkic_symbol_clear => par_hkic_symbol_clear, par_move_episode_status => par_move_episode_status, par_me_info_source_code => par_me_info_source_code, par_me_reason_code => par_me_reason_code, par_me_other_reason => par_me_other_reason);
        /* ************************ */
        /* Patient registration */
        /* ************************ */
        IF par_Type = '010' THEN
            BEGIN
                SELECT
                    patient_key
                    INTO par_T_PRK
                    FROM cpi_patient
                    WHERE hkid = par_HKID;

                IF par_T_PRK IS NULL OR CAST (par_T_PRK AS INTEGER) = 0 THEN
                    BEGIN
                        var_retcode := 299999;
                        var_error_msg := 'Fail to create PMI record';
                        raise exception '';
                    END;
                END IF;
--                CALL web_hasp_update_noks(pas_return_code => var_retcode, par_hosp_code => par_hosp_code, par_System_datetime => par_System_datetime, par_T_PRK => par_T_PRK, par_HKID => par_HKID, par_User_ID => par_User_ID, par_NOK2_priority => par_NOK2_priority, par_NOK2_name => par_nok2_arr[1], par_NOK2_HKID => par_nok2_arr[2], par_NOK2_relation_code => par_nok2_arr[3], par_NOK2_building => par_nok2_arr[4], par_NOK2_room => par_nok2_arr[5], par_NOK2_floor => par_nok2_arr[6], par_NOK2_block => par_nok2_arr[7], par_NOK2_district_code => par_nok2_arr[8], par_NOK2_home_phone => par_nok2_arr[9], par_NOK2_other_phone_no_1 => par_nok2_arr[10], par_NOK2_other_phone_ext_1 => par_nok2_arr[11], par_NOK2_other_phone_no_2 => par_nok2_arr[12], par_NOK2_other_phone_ext_2 => par_nok2_arr, par_NOK3_priority => par_NOK3_priority, par_NOK3_name => par_nok3_arr[1], par_NOK3_HKID => par_nok3_arr[2], par_NOK3_relation_code => par_nok3_arr[3], par_NOK3_building => par_nok3_arr[4], par_NOK3_room => par_nok3_arr[5], par_NOK3_floor => par_nok3_arr[6], par_NOK3_block => par_nok3_arr[7], par_NOK3_district_code => par_nok3_arr[8], par_NOK3_home_phone => par_nok3_arr[9], par_NOK3_other_phone_no_1 => par_nok3_arr[10], par_NOK3_other_phone_ext_1 => par_nok3_arr[11], par_NOK3_other_phone_no_2 => par_nok3_arr[12], par_NOK3_other_phone_ext_2 => par_nok3_arr[13], par_NOK4_priority => par_NOK4_priority, par_NOK4_name => par_nok4_arr[1], par_NOK4_HKID => par_nok4_arr[2], par_NOK4_relation_code => par_nok4_arr[3], par_NOK4_building => par_nok4_arr[4], par_NOK4_room => par_nok4_arr[5], par_NOK4_floor => par_nok4_arr[6], par_NOK4_block => par_nok4_arr[7], par_NOK4_district_code => par_nok4_arr[8], par_NOK4_home_phone => par_nok4_arr[9], par_NOK4_other_phone_no_1 => par_nok4_arr[10], par_NOK4_other_phone_ext_1 => par_nok4_arr[11], par_NOK4_other_phone_no_2 => par_nok4_arr[12], par_NOK4_other_phone_ext_2 => par_nok4_arr[13], par_NOK5_priority => par_NOK5_priority, par_NOK5_name => par_nok5_arr[1], par_NOK5_HKID => par_nok5_arr[2], par_NOK5_relation_code => par_nok5_arr[3], par_NOK5_building => par_nok5_arr[4], par_NOK5_room => par_nok5_arr[5], par_NOK5_floor => par_nok5_arr[6], par_NOK5_block => par_nok5_arr[7], par_NOK5_district_code => par_nok5_arr[8], par_NOK5_home_phone => par_nok5_arr[9], par_NOK5_other_phone_no_1 => par_nok5_arr[10], par_NOK5_other_phone_ext_1 => par_nok5_arr[11], par_NOK5_other_phone_no_2 => par_nok5_arr[12], par_NOK5_other_phone_ext_2 => par_nok5_arr[13], par_NOK6_priority => par_NOK6_priority, par_NOK6_name => par_nok6_arr[1], par_NOK6_HKID => par_nok6_arr[2], par_NOK6_relation_code => par_nok6_arr[3], par_NOK6_building => par_nok6_arr[4], par_NOK6_room => par_nok6_arr[5], par_NOK6_floor => par_nok6_arr[6], par_NOK6_block => par_nok6_arr[7], par_NOK6_district_code => par_nok6_arr[8], par_NOK6_home_phone => par_nok6_arr[9], par_NOK6_other_phone_no_1 => par_nok6_arr[10], par_NOK6_other_phone_ext_1 => par_nok6_arr[11], par_NOK6_other_phone_no_2 => par_nok6_arr[12], par_NOK6_other_phone_ext_2 => par_nok6_arr[13], par_NOK7_priority => par_NOK7_priority, par_NOK7_name => par_nok7_arr[1], par_NOK7_HKID => par_nok7_arr[2], par_NOK7_relation_code => par_nok7_arr[3], par_NOK7_building => par_nok7_arr[4], par_NOK7_room => par_nok7_arr[5], par_NOK7_floor => par_nok7_arr[6], par_NOK7_block => par_nok7_arr[7], par_NOK7_district_code => par_nok7_arr[8], par_NOK7_home_phone => par_nok7_arr[9], par_NOK7_other_phone_no_1 => par_nok7_arr[10], par_NOK7_other_phone_ext_1 => par_nok7_arr[11], par_NOK7_other_phone_no_2 => par_nok7_arr[12], par_NOK7_other_phone_ext_2 => par_nok7_arr[13], par_NOK8_priority => par_NOK8_priority, par_NOK8_name => par_nok8_arr[1], par_NOK8_HKID => par_nok8_arr[2], par_NOK8_relation_code => par_nok8_arr[3], par_NOK8_building => par_nok8_arr[4], par_NOK8_room => par_nok8_arr[5], par_NOK8_floor => par_nok8_arr[6], par_NOK8_block => par_nok8_arr[7], par_NOK8_district_code => par_nok8_arr[8], par_NOK8_home_phone => par_nok8_arr[9], par_NOK8_other_phone_no_1 => par_nok8_arr[10], par_NOK8_other_phone_ext_1 => par_nok8_arr[11], par_NOK8_other_phone_no_2 => par_nok8_arr[12], par_NOK8_other_phone_ext_2 => par_nok8_arr[13], par_NOK9_priority => par_NOK9_priority, par_NOK9_name => par_nok9_arr[1], par_NOK9_HKID => par_nok9_arr[2], par_NOK9_relation_code => par_nok9_arr[3], par_NOK9_building => par_nok9_arr[4], par_NOK9_room => par_nok9_arr[5], par_NOK9_floor => par_nok9_arr[6], par_NOK9_block => par_nok9_arr[7], par_NOK9_district_code => par_nok9_arr[8], par_NOK9_home_phone => par_nok9_arr[9], par_NOK9_other_phone_no_1 => par_nok9_arr[10], par_NOK9_other_phone_ext_1 => par_nok9_arr[11], par_NOK9_other_phone_no_2 => par_nok9_arr[12], par_NOK9_other_phone_ext_2 => par_nok9_arr[13], par_NOK10_priority => par_NOK10_priority, par_NOK10_name => par_nok10_arr[1], par_NOK10_HKID => par_nok10_arr[2], par_NOK10_relation_code => par_nok10_arr[3], par_NOK10_building => par_nok10_arr[4], par_NOK10_room => par_nok10_arr[5], par_NOK10_floor => par_nok10_arr[6], par_NOK10_block => par_nok10_arr[7], par_NOK10_district_code => par_nok10_arr[8], par_NOK10_home_phone => par_nok10_arr[9], par_NOK10_other_phone_no_1 => par_nok10_arr[10], par_NOK10_other_phone_ext_1 => par_nok10_arr[11], par_NOK10_other_phone_no_2 => par_nok10_arr[12], par_NOK10_other_phone_ext_2 => par_nok10_arr[13]);
				call web_hasp_update_noks(pas_return_code => var_retcode, par_hosp_code => par_hosp_code,

                                               par_System_datetime => par_system_datetime,

                                               par_T_PRK => par_t_prk,

                                               par_HKID => par_hkid,

                                               par_User_ID => par_user_id,

                                               par_NOK2_priority => par_nok2_priority,

                                               par_NOK2_arr => par_NOK2_arr,

                                               par_NOK3_priority => par_nok3_priority,

                                               par_NOK3_arr => par_NOK3_arr,

                                               par_NOK4_priority => par_nok4_priority,

                                               par_NOK4_arr => par_NOK4_arr,

                                               par_NOK5_priority => par_nok5_priority,

                                               par_NOK5_arr => par_NOK5_arr,

                                               par_NOK6_priority => par_nok6_priority,

                                               par_NOK6_arr => par_NOK6_arr,

                                               par_NOK7_priority => par_nok7_priority,

                                               par_NOK7_arr => par_NOK7_arr,

                                               par_NOK8_priority => par_nok8_priority,

                                               par_NOK8_arr => par_NOK8_arr,

                                               par_NOK9_priority => par_nok9_priority,

                                               par_NOK9_arr => par_NOK9_arr,

                                               par_NOK10_priority => par_nok10_priority,

                                               par_NOK10_arr=> par_NOK10_arr);

                IF var_retcode != 0 THEN
                    BEGIN
                        var_retcode := 299999;
                        var_error_msg := 'Fail to update NOKs';
                        raise exception '';
                    END;
                END IF;
                /* Insert Event_log */
                CALL hasp_insert_event_log(pas_return_code => var_retcode, par_hosp => par_hosp_code, "par_System_datetime" => par_System_datetime, "par_Type" => par_Type, "par_HKID" => par_HKID, "par_Name" => par_Name, "par_Sex" => par_Sex, "par_DOB" => par_DOB, "par_Exact_DOB_flag" => par_Exact_DOB_flag, "par_CCC_1" => par_CCC_arr[1], "par_CCC_2" => par_CCC_arr[2], "par_CCC_3" => par_CCC_arr[3], "par_CCC_4" => par_CCC_arr[4], "par_CCC_5" => par_CCC_arr[5], "par_CCC_6" => par_CCC_arr[6], "par_Martial_status" => par_Marital_status, "par_Race_code" => par_Race_code, "par_Other_document_no" => par_Other_document_no, "par_Medical_record_number" => par_Medical_record_number, "par_Building" => par_Building, "par_Room" => par_Room, "par_Floor" => par_Floor, "par_Block" => par_Block, "par_District_code" => par_District_code, "par_Religion_code" => par_Religion_code, par_phone1 => par_Home_phone_no, par_phone2 => par_Other_phone1[1], par_address_indicator => par_Other_phone1[2], par_mobile_phone => par_Other_phone2[1], par_sms_language => par_Other_phone2[2], "par_Death_indicator" => 'N', "par_Death_date" => NULL, "par_T_PRK" => par_T_PRK, "par_NOK_name" => par_nok_arr[1], "par_NOK_HKID" => par_nok_arr[2], "par_NOK_relation_code" => par_nok_arr[3], "par_NOK_building" => par_nok_arr[4], "par_NOK_room" => par_nok_arr[5], "par_NOK_floor" => par_nok_arr[6], "par_NOK_block" => par_nok_arr[7], "par_NOK_district_code" => par_nok_arr[8], "par_NOK_phone1" => par_nok_arr[9], "par_NOK_phone2" => par_nok_arr[10], "par_NOK_address_indicator" => par_nok_arr[11], "par_NOK_mobile_phone" => par_nok_arr[12], "par_NOK_sms_language" => par_nok_arr[13], "par_Case_no" => NULL, "par_Admission_datetime" => NULL, "par_Source_indicator" => NULL, "par_Source_code" => NULL, "par_Pay_code" => NULL, "par_Discharge_code" => NULL, "par_Discharge_datetime" => NULL, "par_Destination_code" => NULL, "par_Case_type" => NULL, "par_Movement_count" => NULL, "par_Security_count" => NULL, "par_Case_access_code" => NULL, "par_PMI_access_code" => par_PMI_access_code, "par_Ambulance_no" => NULL, "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL, "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL, "par_Ward_code" => NULL, "par_Specialty_code" => NULL, "par_Bed_no" => NULL, "par_Ward_class" => NULL, "par_Old_name" => NULL, "par_Old_HKID" => NULL, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => NULL, "par_Old_ward_code" => NULL, "par_Old_specialty_code" => NULL, "par_Old_bed_no" => NULL, "par_User_ID" => par_User_ID, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL, "par_Upload_status" => 'N');

                IF var_retcode <> 0 THEN
                    BEGIN
                        IF EXISTS (SELECT
                            1
                            FROM Event_log
                            WHERE System_datetime = par_System_datetime) THEN
                            BEGIN
                                /* Retry Insert Event_log */
                                CALL hasp_insert_event_log(pas_return_code => var_retcode, par_hosp => par_hosp_code, "par_System_datetime" => var_current_datetime, /* ----set @current_datetime = dateadd(ms, 3, @System_datetime) */ "par_Type" => par_Type, "par_HKID" => par_HKID, "par_Name" => par_Name, "par_Sex" => par_Sex, "par_DOB" => par_DOB, "par_Exact_DOB_flag" => par_Exact_DOB_flag, "par_CCC_1" => par_CCC_arr[1], "par_CCC_2" => par_CCC_arr[2], "par_CCC_3" => par_CCC_arr[3], "par_CCC_4" => par_CCC_arr[4], "par_CCC_5" => par_CCC_arr[5], "par_CCC_6" => par_CCC_arr[6], "par_Martial_status" => par_Marital_status, "par_Race_code" => par_Race_code, "par_Other_document_no" => par_Other_document_no, "par_Medical_record_number" => par_Medical_record_number, "par_Building" => par_Building, "par_Room" => par_Room, "par_Floor" => par_Floor, "par_Block" => par_Block, "par_District_code" => par_District_code, "par_Religion_code" => par_Religion_code, par_phone1 => par_Home_phone_no, par_phone2 => par_Other_phone1[1], par_address_indicator => par_Other_phone1[2], par_mobile_phone => par_Other_phone2[1], par_sms_language => par_Other_phone2[2], "par_Death_indicator" => 'N', "par_Death_date" => NULL, "par_T_PRK" => par_T_PRK, "par_NOK_name" => par_nok_arr[1], "par_NOK_HKID" => par_nok_arr[2], "par_NOK_relation_code" => par_nok_arr[3], "par_NOK_building" => par_nok_arr[4], "par_NOK_room" => par_nok_arr[5], "par_NOK_floor" => par_nok_arr[6], "par_NOK_block" => par_nok_arr[7], "par_NOK_district_code" => par_nok_arr[8], "par_NOK_phone1" => par_nok_arr[9], "par_NOK_phone2" => par_nok_arr[10], "par_NOK_address_indicator" => par_nok_arr[11], "par_NOK_mobile_phone" => par_nok_arr[12], "par_NOK_sms_language" => par_nok_arr[13], "par_Case_no" => NULL, "par_Admission_datetime" => NULL, "par_Source_indicator" => NULL, "par_Source_code" => NULL, "par_Pay_code" => NULL, "par_Discharge_code" => NULL, "par_Discharge_datetime" => NULL, "par_Destination_code" => NULL, "par_Case_type" => NULL, "par_Movement_count" => NULL, "par_Security_count" => NULL, "par_Case_access_code" => NULL, "par_PMI_access_code" => par_PMI_access_code, "par_Ambulance_no" => NULL, "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL, "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL, "par_Ward_code" => NULL, "par_Specialty_code" => NULL, "par_Bed_no" => NULL, "par_Ward_class" => NULL, "par_Old_name" => NULL, "par_Old_HKID" => NULL, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => NULL, "par_Old_ward_code" => NULL, "par_Old_specialty_code" => NULL, "par_Old_bed_no" => NULL, "par_User_ID" => par_User_ID, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL, "par_Upload_status" => 'N');

                                IF var_retcode <> 0 THEN
                                    BEGIN
                                        var_retcode := 299999;
                                        var_error_msg := 'Fail to insert Event_log';
                                        raise exception '';
                                    END;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                var_retcode := 299999;
                                var_error_msg := 'Fail to insert Event_log';
                                raise exception '';
                            END;
                        END IF;
                    END;
                END IF;
                /* End - Insert Event_log */
                /* Commit transaction */
                /*
                [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
                if @@trancount > 0
                		begin
                			select @HKID
                			commit transaction
                		end
                */
            END;
        END IF;
        pas_return_code := 0;
        RETURN;
    END;
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
    if @@trancount > 0
    		rollback transaction
    */
    
    pas_return_code := var_retcode;
END;
$procedure$
;

-- DROP PROCEDURE hpi.web_hasp_cancel_admission(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in int4);


;ALTER PROCEDURE "web_hasp_adt_function" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
