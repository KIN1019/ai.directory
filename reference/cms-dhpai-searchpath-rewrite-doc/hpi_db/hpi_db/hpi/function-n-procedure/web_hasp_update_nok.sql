-- DROP PROCEDURE hpi.web_hasp_update_nok(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_update_nok(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_t_prk character varying, IN par_hkid character varying, IN par_user_id character varying, IN par_nok_priority integer, IN par_nok_name character varying DEFAULT NULL::bpchar, IN par_nok_hkid character varying DEFAULT NULL::bpchar, IN par_nok_relation_code character varying DEFAULT NULL::bpchar, IN par_nok_building character varying DEFAULT NULL::bpchar, IN par_nok_room character varying DEFAULT NULL::bpchar, IN par_nok_floor character varying DEFAULT NULL::bpchar, IN par_nok_block character varying DEFAULT NULL::bpchar, IN par_nok_district_code character varying DEFAULT NULL::bpchar, IN par_nok_phone1 character varying DEFAULT NULL::bpchar, IN par_nok_phone2 character varying DEFAULT NULL::bpchar, IN par_nok_address_indicator character varying DEFAULT NULL::bpchar, IN par_nok_mobile_phone character varying DEFAULT NULL::bpchar, IN par_nok_sms_language character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
BEGIN
    <<error>>
    BEGIN
        /* ******************************************************** */
        /* Delete contact person before update */
        /* ******************************************************** */
        IF EXISTS (SELECT
            *
            FROM cpi_nok
            WHERE patient_key = par_T_PRK AND priority = par_NOK_priority) THEN
            BEGIN
                CALL hasp_adt_function_woresult(par_hosp_code => par_hosp_code, par_System_datetime => par_System_datetime, par_Type => '050', par_HKID => par_HKID, par_Name => NULL, par_Sex => NULL, par_DOB => NULL, par_Exact_DOB_flag => NULL, par_CCC_1 => NULL, par_CCC_2 => NULL, par_CCC_3 => NULL, par_CCC_4 => NULL, par_CCC_5 => NULL, par_CCC_6 => NULL, par_Marital_status => NULL, par_Race_code => NULL, par_Other_document_no => NULL, par_Medical_record_number => NULL, par_Building => NULL, par_Room => NULL, par_Floor => NULL, par_Block => NULL, par_District_code => NULL, par_Religion_code => NULL, par_phone1 => NULL, par_phone2 => NULL, par_address_indicator => NULL, par_mobile_phone => NULL, par_sms_language => NULL, par_Death_indicator => NULL, par_Death_date => NULL, par_T_PRK => par_T_PRK, par_NOK_priority => par_NOK_priority, par_NOK_name => NULL, par_NOK_HKID => NULL, par_NOK_relation_code => NULL, par_NOK_building => NULL, par_NOK_room => NULL, par_NOK_floor => NULL, par_NOK_block => NULL, par_NOK_district_code => NULL, par_NOK_phone1 => NULL, par_NOK_phone2 => NULL, par_NOK_address_indicator => NULL, par_NOK_mobile_phone => NULL, par_NOK_sms_language => NULL, par_Case_no => NULL, par_Admission_datetime => NULL, par_Source_indicator => NULL, par_Source_code => NULL, par_Pay_code => NULL, par_Discharge_code => NULL, par_Discharge_datetime => NULL, par_Destination_code => NULL, par_Case_type => NULL, par_Movement_count => NULL, par_Security_count => NULL, par_Case_access_code => NULL, par_PMI_access_code => NULL, par_Ambulance_no => NULL, par_Police_case => NULL, par_Labour_case => NULL, par_AE_case_type => NULL, par_DBA_flag => NULL, par_Follow_up_datetime => NULL, par_Ward_code => NULL, par_Specialty_code => NULL, par_Bed_no => NULL, par_Ward_class => NULL, par_Transfer_datetime => NULL, par_Old_name => NULL, par_Old_HKID => NULL, par_Old_sex => NULL, par_Old_DOB => NULL, par_Old_ward_class => NULL, par_Old_ward_code => NULL, par_Old_specialty_code => NULL, par_Old_bed_no => NULL, par_User_ID => par_User_ID, par_Doctor_code => NULL, par_Old_doctor_code => NULL, par_Old_T_PRK => NULL, par_PP_code => NULL, par_Last_update_datetime => NULL, par_Terminal_id => NULL, par_Old_NOK_name => NULL, par_Document_flag => NULL, par_eh_code => NULL, par_source_hosp_code => NULL, par_source_case_no => NULL, par_hkic_symbol => NULL, par_hkic_symbol_clear => 'N', par_move_episode_status => NULL, par_me_info_source_code => NULL, par_me_reason_code => NULL, par_me_other_reason => NULL, pas_return_code =>  var_retcode);

                IF var_retcode != 0 THEN
                    BEGIN
                        var_retcode := 299999;
                        var_error_msg := 'Fail to remove contact person';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF par_NOK_name IS NOT NULL THEN
            BEGIN
                CALL hasp_adt_function_woresult(par_hosp_code => par_hosp_code, par_System_datetime => par_System_datetime, par_Type => '050', par_HKID => par_HKID, par_Name => NULL, par_Sex => NULL, par_DOB => NULL, par_Exact_DOB_flag => NULL, par_CCC_1 => NULL, par_CCC_2 => NULL, par_CCC_3 => NULL, par_CCC_4 => NULL, par_CCC_5 => NULL, par_CCC_6 => NULL, par_Marital_status => NULL, par_Race_code => NULL, par_Other_document_no => NULL, par_Medical_record_number => NULL, par_Building => NULL, par_Room => NULL, par_Floor => NULL, par_Block => NULL, par_District_code => NULL, par_Religion_code => NULL, par_phone1 => NULL, par_phone2 => NULL, par_address_indicator => NULL, par_mobile_phone => NULL, par_sms_language => NULL, par_Death_indicator => NULL, par_Death_date => NULL, par_T_PRK => par_T_PRK, par_NOK_priority => par_NOK_priority, par_NOK_name => par_NOK_name, par_NOK_HKID => par_NOK_HKID, par_NOK_relation_code => par_NOK_relation_code, par_NOK_building => par_NOK_building, par_NOK_room => par_NOK_room, par_NOK_floor => par_NOK_floor, par_NOK_block => par_NOK_block, par_NOK_district_code => par_NOK_district_code, par_NOK_phone1 => par_NOK_phone1, par_NOK_phone2 => par_NOK_phone2, par_NOK_address_indicator => par_NOK_address_indicator, par_NOK_mobile_phone => par_NOK_mobile_phone, par_NOK_sms_language => par_NOK_sms_language, par_Case_no => NULL, par_Admission_datetime => NULL, par_Source_indicator => NULL, par_Source_code => NULL, par_Pay_code => NULL, par_Discharge_code => NULL, par_Discharge_datetime => NULL, par_Destination_code => NULL, par_Case_type => NULL, par_Movement_count => NULL, par_Security_count => NULL, par_Case_access_code => NULL, par_PMI_access_code => NULL, par_Ambulance_no => NULL, par_Police_case => NULL, par_Labour_case => NULL, par_AE_case_type => NULL, par_DBA_flag => NULL, par_Follow_up_datetime => NULL, par_Ward_code => NULL, par_Specialty_code => NULL, par_Bed_no => NULL, par_Ward_class => NULL, par_Transfer_datetime => NULL, par_Old_name => NULL, par_Old_HKID => NULL, par_Old_sex => NULL, par_Old_DOB => NULL, par_Old_ward_class => NULL, par_Old_ward_code => NULL, par_Old_specialty_code => NULL, par_Old_bed_no => NULL, par_User_ID => par_User_ID, par_Doctor_code => NULL, par_Old_doctor_code => NULL, par_Old_T_PRK => NULL, par_PP_code => NULL, par_Last_update_datetime => NULL, par_Terminal_id => NULL, par_Old_NOK_name => NULL, par_Document_flag => NULL, par_eh_code => NULL, par_source_hosp_code => NULL, par_source_case_no => NULL, par_hkic_symbol => NULL, par_hkic_symbol_clear => 'N', par_move_episode_status => NULL, par_me_info_source_code => NULL, par_me_reason_code => NULL, par_me_other_reason => NULL, pas_return_code =>  var_retcode);

                IF var_retcode != 0 THEN
                    BEGIN
                        var_retcode := 299999;
                        var_error_msg := 'Fail to insert contact person';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        pas_return_code := 0;
        RETURN;
    END;
    RAISE EXCEPTION '%', var_error_msg USING ERRCODE := var_retcode;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_update_nok" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
