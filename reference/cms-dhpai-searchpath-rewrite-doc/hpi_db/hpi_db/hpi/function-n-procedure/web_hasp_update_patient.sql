-- DROP PROCEDURE web_hasp_update_patient(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE web_hasp_update_patient(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_home_phone_no character varying, IN par_other_phone_no_1 character varying, IN par_other_phone_ext_1 character varying, IN par_other_phone_no_2 character varying, IN par_other_phone_ext_2 character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_t_prk character varying, IN par_nok_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_home_phone character varying, IN par_nok_other_phone_no_1 character varying, IN par_nok_other_phone_ext_1 character varying, IN par_nok_other_phone_no_2 character varying, IN par_nok_other_phone_ext_2 character varying, IN par_nok2_priority integer DEFAULT NULL::integer, IN par_nok2_arr character varying[] DEFAULT NULL::character varying[], IN par_nok3_priority integer DEFAULT NULL::integer, IN par_nok3_arr character varying[] DEFAULT NULL::character varying[], IN par_nok4_priority integer DEFAULT NULL::integer, IN par_nok4_arr character varying[] DEFAULT NULL::character varying[], IN par_nok5_priority integer DEFAULT NULL::integer, IN par_nok5_arr character varying[] DEFAULT NULL::character varying[], IN par_nok6_priority integer DEFAULT NULL::integer, IN par_nok6_arr character varying[] DEFAULT NULL::character varying[], IN par_nok7_priority integer DEFAULT NULL::integer, IN par_nok7_arr character varying[] DEFAULT NULL::character varying[], IN par_nok8_priority integer DEFAULT NULL::integer, IN par_nok8_arr character varying[] DEFAULT NULL::character varying[], IN par_nok9_priority integer DEFAULT NULL::integer, IN par_nok9_arr character varying[] DEFAULT NULL::character varying[], IN par_nok10_priority integer DEFAULT NULL::integer, IN par_nok10_arr character varying[] DEFAULT NULL::character varying[], IN par_pmi_access_code integer DEFAULT NULL::integer, IN par_old_name character varying DEFAULT NULL::character varying, IN par_old_hkid character varying DEFAULT NULL::character varying, IN par_old_sex character varying DEFAULT NULL::character varying, IN par_old_dob timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_user_id character varying DEFAULT NULL::character varying, IN par_old_t_prk character varying DEFAULT NULL::character varying, IN par_last_update_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_hkic_symbol_clear character varying DEFAULT 'N'::character varying, IN par_mother_baby_action character varying DEFAULT NULL::character varying, IN par_mother_hosp character varying DEFAULT NULL::character varying, IN par_mother_case character varying DEFAULT NULL::character varying, IN par_baby_hosp character varying DEFAULT NULL::character varying, IN par_baby_case character varying DEFAULT NULL::character varying, IN par_birth_order integer DEFAULT NULL::integer, IN par_preg_number integer DEFAULT NULL::integer, IN par_birth_location character varying DEFAULT NULL::character varying, IN par_birth_place character varying DEFAULT NULL::character varying, IN par_old_mother_case character varying DEFAULT NULL::character varying, IN par_old_baby_case character varying DEFAULT NULL::character varying, IN par_is_express character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2024-11 Cathy Chen IPAS-764 Enhance A&E Express Registration Phase3:add is_ae_reg to control commit transaction,N-commit transaction in current SP,Y-commit transaction will be in hasp_ae_ip_admission */
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
/* Mother baby linkage */
/* IPAS-764 Cathy Chen Enhance A&E Express Registration Phase3 : N-commit transaction in current SP,Y-commit transaction will be in hasp_ae_ip_admission */
DECLARE
    var_retcode            INTEGER;
    var_error_msg          VARCHAR(255);
    var_tmp_hkid           VARCHAR(9);
    var_current_datetime   TIMESTAMP WITHOUT TIME ZONE;
    var_transaction_type   VARCHAR(3);
    var_has_non_major_nok  VARCHAR(1);
    var_selected_error_msg VARCHAR(255);
    sql$rowcount           BIGINT;
BEGIN
    <<error>>
    begin
       
        /* --	set @current_datetime 	= getdate() */
        var_current_datetime := 3 * INTERVAL '1 millisecond' + par_System_datetime::TIMESTAMP;
        var_transaction_type := '030';
        /* IPAS-764 Cathy Chen Enhance A&E Express Registration Phase3 : N-commit transaction in current SP,Y-commit transaction will be in hasp_ae_ip_admission */
        IF par_is_express <> 'Y' THEN
            SELECT
                'N'
                INTO par_is_express;
        END IF;

        /* ******************************************************** */
        /* Get a pseudo ID from Hospital table when HKID is empty */
        /* Change HKID */
        /* ******************************************************** */
        IF par_HKID IS NULL OR par_HKID = 'UN' THEN
            BEGIN
                CALL hasp_get_next_un(var_retcode, par_hosp_code, var_tmp_hkid);


                IF var_retcode <> 0 THEN
                    RAISE EXCEPTION 'CALL hasp_get_next_un failed';
                END IF;
                CALL web_hasp_get_hkid_check_digit(var_retcode, var_tmp_hkid, par_HKID);

                IF var_retcode <> 0 THEN
                    RAISE EXCEPTION 'CALL web_hasp_get_hkid_check_digit failed';
                END IF;
            END;
        END IF;

        /* delete all non-major contact persons before update patient */
        RAISE NOTICE '[web_hasp_update_Patient] flag1';
        CALL web_hasp_update_noks(pas_return_code => var_retcode, par_hosp_code => par_hosp_code,
                                  par_System_datetime => par_system_datetime,
                                  par_T_PRK => par_Old_T_PRK,
                                  par_HKID => par_Old_HKID,
                                  par_User_ID => par_user_id);
        RAISE NOTICE '[web_hasp_update_Patient] flag2-1015';
        IF var_retcode <> 0 THEN
            RAISE EXCEPTION '';
        END IF;
        /* End - delete all non-major contact persons before update patient */

        /* update patient */
        RAISE NOTICE '[web_hasp_update_Patient]-call-hasp_adt_function_woresult';
        CALL hasp_adt_function_woresult(pas_return_code => var_retcode
            , par_hosp_code => par_hosp_code
            , par_System_datetime => par_System_datetime
            , par_Type => var_transaction_type
            , par_HKID => par_HKID
            , par_Name => par_Name
            , par_Sex => par_Sex
            , par_DOB => par_DOB
            , par_Exact_DOB_flag => par_Exact_DOB_flag
            , par_CCC_1 => par_CCC_1
            , par_CCC_2 => par_CCC_2
            , par_CCC_3 => par_CCC_3
            , par_CCC_4 => par_CCC_4
            , par_CCC_5 => par_CCC_5
            , par_CCC_6 => par_CCC_6
            , par_Marital_status => par_Marital_status
            , par_Race_code => par_Race_code
            , par_Other_document_no => par_Other_document_no
            , par_Medical_record_number => par_Medical_record_number
            , par_Building => par_Building
            , par_Room => par_Room
            , par_Floor => par_Floor
            , par_Block => par_Block
            , par_District_code => par_District_code
            , par_Religion_code => par_Religion_code
            , par_phone1 => par_Home_phone_no
            , par_phone2 => par_Other_phone_no_1
            , par_address_indicator => par_Other_phone_ext_1
            , par_mobile_phone => par_Other_phone_no_2
            , par_sms_language => par_Other_phone_ext_2
            , par_Death_indicator => par_Death_indicator
            , par_Death_date => par_Death_date
            , par_T_PRK => par_T_PRK
            , par_NOK_priority => par_NOK_priority
            , par_NOK_name => par_NOK_name
            , par_NOK_HKID => par_NOK_HKID
            , par_NOK_relation_code => par_NOK_relation_code
            , par_NOK_building => par_NOK_building
            , par_NOK_room => par_NOK_room
            , par_NOK_floor => par_NOK_floor
            , par_NOK_block => par_NOK_block
            , par_NOK_district_code => par_NOK_district_code
            , par_nok_phone1 => par_NOK_home_phone
            , par_nok_phone2 => par_NOK_other_phone_no_1
            , par_nok_address_indicator => par_NOK_other_phone_ext_1
            , par_nok_mobile_phone => par_NOK_other_phone_no_2
            , par_nok_sms_language => par_NOK_other_phone_ext_2
            , par_Case_no => NULL
            , par_Admission_datetime => NULL
            , par_Source_indicator => NULL
            , par_Source_code => NULL
            , par_Pay_code => NULL
            , par_Discharge_code => NULL
            , par_Discharge_datetime => NULL
            , par_Destination_code => NULL
            , par_Case_type => NULL
            , par_Movement_count => NULL
            , par_Security_count => NULL
            , par_Case_access_code => NULL
            , par_PMI_access_code => par_PMI_access_code
            , par_Ambulance_no => NULL
            , par_Police_case => NULL
            , par_Labour_case => NULL
            , par_AE_case_type => NULL
            , par_DBA_flag => NULL
            , par_Follow_up_datetime => NULL
            , par_Ward_code => NULL
            , par_Specialty_code => NULL
            , par_Bed_no => NULL
            , par_Ward_class => NULL
            , par_Transfer_datetime => NULL
            , par_Old_name => par_Old_name
            , par_Old_HKID => par_Old_HKID
            , par_Old_sex => par_Old_sex
            , par_Old_DOB => par_Old_DOB
            , par_Old_ward_class => NULL
            , par_Old_ward_code => NULL
            , par_Old_specialty_code => NULL
            , par_Old_bed_no => NULL
            , par_User_ID => par_User_ID
            , par_Doctor_code => NULL
            , par_Old_doctor_code => NULL
            , par_Old_T_PRK => par_Old_T_PRK
            , par_PP_code => NULL
            , par_Last_update_datetime => par_Last_update_datetime
            , par_Terminal_id => NULL
            , par_Old_NOK_name => NULL
            , par_Document_flag => par_Document_flag
            , par_eh_code => NULL
            , par_source_hosp_code => NULL
            , par_source_case_no => NULL
            , par_hkic_symbol => par_hkic_symbol
            , par_hkic_symbol_clear => par_hkic_symbol_clear);

        IF var_retcode <> 0 THEN
            RAISE EXCEPTION 'CALL hasp_adt_function_woresult failed';
        END IF;
        /* End - update patient */

        /* Insert Event_log */
        RAISE NOTICE '[web_hasp_update_patient]--hasp_insert_event_log';
        CALL hasp_insert_event_log(var_retcode,
                                   par_hosp_code,
                                   par_System_datetime,
                                   var_transaction_type,
                                   par_HKID,
                                   par_Name,
                                   par_Sex,
                                   par_DOB,
                                   par_Exact_DOB_flag,
                                   par_CCC_1,
                                   par_CCC_2,
                                   par_CCC_3,
                                   par_CCC_4,
                                   par_CCC_5,
                                   par_CCC_6,
                                   par_Marital_status,
                                   par_Race_code,
                                   par_Other_document_no,
                                   par_Medical_record_number,
                                   par_Building,
                                   par_Room,
                                   par_Floor,
                                   par_Block,
                                   par_District_code,
                                   par_Religion_code,
                                   par_Home_phone_no,
                                   par_Other_phone_no_1,
                                   par_Other_phone_ext_1,
                                   par_Other_phone_no_2,
                                   par_Other_phone_ext_2,
                                   par_Death_indicator,
                                   par_death_date,
                                   par_T_PRK,
                                   par_NOK_name,
                                   par_NOK_HKID,
                                   par_NOK_relation_code,
                                   par_NOK_building,
                                   par_NOK_room,
                                   par_NOK_floor,
                                   par_NOK_block,
                                   par_NOK_district_code,
                                   par_NOK_home_phone,
                                   par_NOK_other_phone_no_1,
                                   par_NOK_other_phone_ext_1,
                                   par_NOK_other_phone_no_2,
                                   par_NOK_other_phone_ext_2,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   par_PMI_access_code,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   par_Old_name,
                                   par_Old_HKID,
                                   par_Old_sex,
                                   par_Old_DOB,
                                   NULL,
                                   NULL,
                                   NULL,
                                   NULL,
                                   par_User_ID,
                                   NULL,
                                   NULL,
            /* --		@Old_T_PRK                = @Old_T_PRK,
               */
                                   NULL,
                                   NULL,
                                   'N');
        RAISE NOTICE '[web_hasp_update_patient]--hasp_insert_event_log-var_retcode=%',var_retcode;
        IF var_retcode <> 0 THEN
            BEGIN
                IF EXISTS (SELECT 1
                           FROM Event_log
                           WHERE System_datetime = par_System_datetime) THEN
                    BEGIN
                        /* Retry Insert Event_log */

                        CALL hasp_insert_event_log(var_retcode,
                                                   par_hosp_code,
                                                   par_System_datetime,
                                                   var_transaction_type,
                                                   par_HKID,
                                                   par_Name,
                                                   par_Sex,
                                                   par_DOB,
                                                   par_Exact_DOB_flag,
                                                   par_CCC_1,
                                                   par_CCC_2,
                                                   par_CCC_3,
                                                   par_CCC_4,
                                                   par_CCC_5,
                                                   par_CCC_6,
                                                   par_Marital_status,
                                                   par_Race_code,
                                                   par_Other_document_no,
                                                   par_Medical_record_number,
                                                   par_Building,
                                                   par_Room,
                                                   par_Floor,
                                                   par_Block,
                                                   par_District_code,
                                                   par_Religion_code,
                                                   par_Home_phone_no,
                                                   par_Other_phone_no_1,
                                                   par_Other_phone_ext_1,
                                                   par_Other_phone_no_2,
                                                   par_Other_phone_ext_2,
                                                   par_Death_indicator,
                                                   par_death_date,
                                                   par_T_PRK,
                                                   par_NOK_name,
                                                   par_NOK_HKID,
                                                   par_NOK_relation_code,
                                                   par_NOK_building,
                                                   par_NOK_room,
                                                   par_NOK_floor,
                                                   par_NOK_block,
                                                   par_NOK_district_code,
                                                   par_NOK_home_phone,
                                                   par_NOK_other_phone_no_1,
                                                   par_NOK_other_phone_ext_1,
                                                   par_NOK_other_phone_no_2,
                                                   par_NOK_other_phone_ext_2,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   par_PMI_access_code,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   par_Old_name,
                                                   par_Old_HKID,
                                                   par_Old_sex,
                                                   par_Old_DOB,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   par_User_ID,
                                                   NULL,
                                                   NULL,
                            /* --		@Old_T_PRK                = @Old_T_PRK,
                               */
                                                   NULL,
                                                   NULL,
                                                   'N');
                        IF var_retcode <> 0 THEN
                            BEGIN
                                var_retcode := 299999;
                                var_error_msg := 'Fail to insert Event_log';
                                RAISE EXCEPTION 'Fail to insert Event_log';
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        var_retcode := 299999;
                        var_error_msg := 'Fail to insert Event_log';
                        RAISE EXCEPTION 'Fail to insert Event_log';
                    END;
                END IF;
            END;
        END IF;
        /* End - Insert Event_log */

        /* Insert non-major contact persons */
        CALL web_hasp_update_noks(pas_return_code => var_retcode, par_hosp_code => par_hosp_code,
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
                                  par_NOK10_arr => par_NOK10_arr
             );
        IF var_retcode <> 0 THEN
            RAISE EXCEPTION 'Insert non-major contact persons failed';
        END IF;
        /* End - Insert non-major contact persons */

        /* Update mother baby linkage */
        IF par_mother_baby_action IN ('A', 'U', 'D') THEN
            BEGIN
                IF par_mother_baby_action = 'D' THEN
                    BEGIN
                        par_mother_hosp := par_hosp_code;
                        par_mother_case := par_Old_mother_case;
                        par_baby_hosp := par_hosp_code;
                        par_baby_case := par_Old_baby_case;
                        /* --			set @birth_order	= null */
                        /* --			set @preg_number	= null */
                        /* --			set @birth_location	= null */
                        /* --			set @birth_place	= null */
                        SELECT birth_order,
                               pregnancy_number,
                               birth_location,
                               birth_place
                        INTO par_birth_order, par_preg_number, par_birth_location, par_birth_place
                        FROM mother_baby_case_view
                        WHERE baby_hospital_code = par_hosp_code
                          AND baby_case_no = par_Old_baby_case;
                    END;
                END IF;
                CALL web_hasp_update_mo_bb(pas_return_code => var_retcode, par_action => par_mother_baby_action,
                                           par_mo_hosp => par_mother_hosp, par_mo_case => par_mother_case,
                                           par_nb_hosp => par_baby_hosp, par_nb_case => par_baby_case,
                                           par_mo_case_org => par_Old_mother_case, par_nb_case_org => par_Old_baby_case,
                                           par_birth_order => par_birth_order, par_preg_number => par_preg_number,
                                           par_birth_loc => par_birth_location, par_birth_place => par_birth_place,
                                           par_user_id => par_User_ID, par_system_dtm => par_System_datetime,
                                           par_baby_hkid => par_HKID);

                IF var_retcode <> 0 THEN
                    RAISE EXCEPTION 'CALL web_hasp_update_mo_bb failed';
                END IF;
            END;
        END IF;
        /* End - Update mother baby linkage */

        /* Set off problem address indicator if this set on */
        IF par_PMI_access_code & 2 <= 0 THEN
            BEGIN
                CALL hasp_set_problem_address_ind(pas_return_code => var_retcode, par_hkid => par_HKID,
                                                  par_set_type => 'N', par_user_id => par_User_ID);

                IF var_retcode <> 0 THEN
                    RAISE EXCEPTION 'CALL hasp_set_problem_address_ind failed';
                END IF;
            END;
        END IF;
        /* End - Set off problem address indicator if this set on */

        pas_return_code := 0;
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
	            RAISE NOTICE 'var_retcode => [%]',var_retcode;
--                if sqlstate is not null then
--                        RAISE EXCEPTION '% ', SQLERRM USING ERRCODE := sqlstate;
--                        return;
--                end if;
                /* Find the error message by error code */
                IF var_retcode != 299999 THEN
                    BEGIN
                        SELECT messages
                        INTO var_selected_error_msg
                        FROM error_msgs
                        WHERE error_code = var_retcode;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 1 THEN
                            var_error_msg := var_selected_error_msg;
                        ELSE
                            BEGIN
                                /* Error from web_hasp_update_mo_bb */
                                IF var_retcode = 300001 THEN
                                    var_error_msg := 'Case no Cannot be null !';
                                ELSE
                                    IF var_retcode = 300002 THEN
                                        var_error_msg := 'Invalid Action Type !';
                                    ELSE
                                        IF var_retcode = 300003 THEN
                                            var_error_msg := 'No Patient Found !';
                                        ELSE
                                            IF var_retcode = 300004 THEN
                                                var_error_msg := 'No Patient HKID Found !';
                                            ELSE
                                                IF var_retcode = 300005 THEN
                                                    var_error_msg := 'The Baby Case MUST belong to same patient !';
                                                ELSE
                                                    IF var_retcode = 300006 THEN
                                                        var_error_msg :=
                                                                'If birth location is OTH, birth place must be Born before arrival !';
                                                    ELSE
                                                        IF var_retcode = 300007 THEN
                                                            var_error_msg :=
                                                                    'If birth place is Labour room, birth location must be own hospital !';
                                                        ELSE
                                                            IF var_retcode = 300008 THEN
                                                                var_error_msg := 'Duplicate Birth Order is not allowed !';
                                                            ELSE
                                                                IF var_retcode = 300011 THEN
                                                                    var_error_msg := 'Insert mother_baby_case error !';
                                                                ELSE
                                                                    IF var_retcode = 300012 THEN
                                                                        var_error_msg := 'Delete mother_baby_case error !';
                                                                    ELSE
                                                                        IF var_retcode = 300013 THEN
                                                                            var_error_msg := 'Delete cpi_new_born error !';
                                                                        ELSE
                                                                            IF var_retcode = 300014 THEN
                                                                                var_error_msg := 'Update mother_baby_case error !';
                                                                            ELSE
                                                                                IF var_retcode = 300021 THEN
                                                                                    var_error_msg :=
                                                                                            'The Mother Baby Relationship already exists for the Patient !';
                                                                                    /* End - Error from web_hasp_update_mo_bb */
                                                                                ELSE
                                                                                    var_error_msg := CONCAT(
                                                                                            'Call cpi function failed with return code ',
                                                                                            CASE CAST(var_retcode AS VARCHAR(8))
                                                                                                WHEN '' THEN ' '
                                                                                                ELSE CAST(var_retcode AS VARCHAR(8))
                                                                                                END);
                                                                                END IF;
                                                                            END IF;
                                                                        END IF;
                                                                    END IF;
                                                                END IF;
                                                            END IF;
                                                        END IF;
                                                    END IF;
                                                END IF;
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
                /* End - Find the error message by error code */
            END;
    END;

    var_retcode := 29999;
    pas_return_code := var_retcode;
    RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_update_patient" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
