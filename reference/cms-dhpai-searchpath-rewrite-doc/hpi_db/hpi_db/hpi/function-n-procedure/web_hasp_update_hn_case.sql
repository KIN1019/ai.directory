-- DROP PROCEDURE hpi.web_hasp_update_hn_case(inout int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in int4, in varchar, in timestamp, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE web_hasp_update_hn_case(INOUT pas_return_code integer, IN par_system_datetime timestamp without time zone, IN par_hospital_code character varying, IN par_t_prk character varying, IN par_hkid character varying, IN par_district_code character varying, IN par_death_indicator character varying, IN par_death_datetime timestamp without time zone, IN par_old_document_flag character varying DEFAULT NULL::character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_other_document_no character varying DEFAULT NULL::character varying, IN par_case_no character varying DEFAULT NULL::character varying, IN par_admission_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_source_indicator character varying DEFAULT NULL::character varying, IN par_source_hosp_code character varying DEFAULT NULL::character varying, IN par_source_case_no character varying DEFAULT NULL::character varying, IN par_pay_code character varying DEFAULT NULL::character varying, IN par_ward_class character varying DEFAULT NULL::character varying, IN par_ward_code character varying DEFAULT NULL::character varying, IN par_specialty_code character varying DEFAULT NULL::character varying, IN par_bed_no character varying DEFAULT NULL::character varying, IN par_pp_code character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying, IN par_treatment_location character varying DEFAULT NULL::character varying, IN par_old_admission_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_old_source_indicator character varying DEFAULT NULL::character varying, IN par_old_source_hosp_code character varying DEFAULT NULL::character varying, IN par_old_source_case_no character varying DEFAULT NULL::character varying, IN par_old_pay_code character varying DEFAULT NULL::character varying, IN par_old_ward_class character varying DEFAULT NULL::character varying, IN par_old_ward_code character varying DEFAULT NULL::character varying, IN par_old_specialty_code character varying DEFAULT NULL::character varying, IN par_old_bed_no character varying DEFAULT NULL::character varying, IN par_old_pp_code character varying DEFAULT NULL::character varying, IN par_old_eh_code character varying DEFAULT NULL::character varying, IN par_old_treatment_location character varying DEFAULT NULL::character varying, IN par_old_update_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_old_movement_count integer DEFAULT NULL::integer, IN par_old_discharge_code character varying DEFAULT NULL::character varying, IN par_old_discharge_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_old_discharge_destination character varying DEFAULT NULL::character varying, IN par_active_indicator character varying DEFAULT NULL::character varying, IN par_security_count integer DEFAULT NULL::integer, IN par_case_access_code integer DEFAULT NULL::integer, IN par_update_type character varying DEFAULT NULL::character varying, IN par_user_id character varying DEFAULT NULL::character varying, IN par_allow_update_specific character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
    /* updated case detail */
/* original case */
/* non-editable fields */
/* others */
DECLARE
    var_case_type               VARCHAR(01);
    var_transaction_type        VARCHAR(03);
    var_retcode                 INTEGER;
    var_rowcount                INTEGER;
    var_error                   INTEGER;
    var_error_msg               VARCHAR(255);
    var_current_datetime        TIMESTAMP WITHOUT TIME ZONE;
    var_pmi_access_code         INTEGER;
    var_name                    VARCHAR(48);
    var_hkic_symbol             VARCHAR(01);
    var_sex                     VARCHAR(01);
    var_dob                     TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag          CHAR(01);
    var_ccc_1                   VARCHAR(05);
    var_ccc_2                   VARCHAR(05);
    var_ccc_3                   VARCHAR(05);
    var_ccc_4                   VARCHAR(05);
    var_ccc_5                   VARCHAR(05);
    var_ccc_6                   VARCHAR(05);
    var_marital_status          VARCHAR(01);
    var_race_code               VARCHAR(02);
    var_old_other_document_no   VARCHAR(12);
    var_mrn                     VARCHAR(08);
    var_building                VARCHAR(47);
    var_room                    VARCHAR(05);
    var_floor                   VARCHAR(02);
    var_block                   VARCHAR(02);
    var_religion_code           VARCHAR(03);
    var_phone1                  VARCHAR(10);
    var_phone2                  VARCHAR(10);
    var_address_indicator       VARCHAR(04);
    var_mobile_phone            VARCHAR(10);
    var_sms_language            VARCHAR(04);
    var_last_update_datetime    TIMESTAMP WITHOUT TIME ZONE;
    var_nok_priority            SMALLINT;
    var_nok_name                VARCHAR(48);
    var_nok_hkid                VARCHAR(12);
    var_nok_relation_code       VARCHAR(2);
    var_nok_building            VARCHAR(47);
    var_nok_room                VARCHAR(5);
    var_nok_floor               VARCHAR(2);
    var_nok_block               VARCHAR(2);
    var_nok_district_code       VARCHAR(5);
    var_nok_phone1              VARCHAR(10);
    var_nok_phone2              VARCHAR(10);
    var_nok_address_indicator   VARCHAR(4);
    var_nok_mobile_phone        VARCHAR(10);
    var_nok_sms_language        VARCHAR(4);
    var_yrDiff                  INTEGER;
    var_monDiff                 INTEGER;
    var_tmp_movement_datetime   TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount                BIGINT;
    var_Post_datetime           TIMESTAMP WITHOUT TIME ZONE;
    var_From_treatment_location VARCHAR(4);
    var_Post_flag               VARCHAR(1);
    var_movementIsUpdated       VARCHAR(01);
    var_tmp_ward_class          VARCHAR(01);
    var_tmp_ward_code           VARCHAR(04);
    var_tmp_specialty_code      VARCHAR(04);
    var_tmp_bed_no              VARCHAR(05);
    var_selected_error_msg      VARCHAR(255);
BEGIN
    <<error>>
    BEGIN
        var_case_type := 'I';
        var_transaction_type := '121';
        var_current_datetime := 10 * INTERVAL '1 millisecond' + par_system_datetime::TIMESTAMP;
        /* retrieve patient and major nok for event log */
        SELECT access_code,
               patient_name,
               sex,
               dob,
               exact_dob_flag,
               cccode1,
               cccode2,
               cccode3,
               cccode4,
               cccode5,
               cccode6,
               marital_status,
               race,
               other_doc_no,
               building,
               room,
               floor,
               block,
               district,
               religion,
               phone1,
               phone2,
               address_indicator,
               mobile_phone,
               sms_language,
               hkic_symbol,
               update_dtm
        INTO var_pmi_access_code, var_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_marital_status, var_race_code, var_old_other_document_no, var_building, var_room, var_floor, var_block, par_district_code, var_religion_code, var_phone1, var_phone2, var_address_indicator, var_mobile_phone, var_sms_language, var_hkic_symbol, var_last_update_datetime
        FROM cpi_patient
        WHERE patient_key = par_t_prk;
        /* 20200616/JL/ to prevent pseudo ID patient with age > 11 register with paycode EP1 - START */
        IF SUBSTRING(par_hkid, 1, 1) = 'U'
            AND (par_other_document_no IS NULL OR par_other_document_no = '')
            AND par_pay_code = 'EP1' AND par_document_flag != 'F'
        THEN
            var_yrDiff := EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM var_dob);
            var_monDiff := EXTRACT(MONTH FROM CURRENT_DATE) - EXTRACT(MONTH FROM var_dob);

            IF EXTRACT(DAY FROM CURRENT_DATE) - EXTRACT(DAY FROM var_dob) < 0 THEN
                var_monDiff := var_monDiff - 1;
            END IF;
            IF var_monDiff < 0 THEN
                var_yrDiff := var_yrDiff - 1;
            END IF;

            IF var_dob IS NULL OR var_yrDiff > 11 THEN
                var_retcode := 299999;
                var_error_msg :=
                        'Patient with Pseudo HKID, age > 11 and without other documents must not have pay code EP1.';
                RAISE EXCEPTION '';
            END IF;
        END IF;
        /* 20200616/JL/ to prevent pseudo ID patient with age > 11 register with paycode EP1 - END */
        SELECT mrn
        INTO var_mrn
        FROM cpi_patient_hospital_data
        WHERE patient_key = par_t_prk
          AND hospital_code = par_hospital_code;

        SELECT priority,
               nok_name,
               hkid,
               relationship,
               building,
               room,
               floor,
               block,
               district,
               phone1,
               phone2,
               address_indicator,
               mobile_phone,
               sms_language
        INTO var_nok_priority, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone, var_nok_sms_language
        FROM cpi_nok
        WHERE patient_key = par_t_prk
          AND major_nok = 'Y';
        /* End - retrieve patient and major nok for event log */

        /* update case */
        CALL hasp_adt_function_woresult(
                pas_return_code => var_retcode, par_hosp_code => par_hospital_code,
                par_System_datetime => par_system_datetime,
                par_Type => var_transaction_type, par_HKID => par_hkid, par_Name => NULL,
                par_Sex => NULL, par_DOB => NULL, par_Exact_DOB_flag => NULL,
                par_CCC_1 => NULL, par_CCC_2 => NULL, par_CCC_3 => NULL,
                par_CCC_4 => NULL, par_CCC_5 => NULL, par_CCC_6 => NULL,
                par_Marital_status => NULL, par_Race_code => NULL,
                par_Other_document_no => NULL, par_Medical_record_number => NULL,
                par_Building => NULL, par_Room => NULL, par_Floor => NULL,
                par_Block => NULL, par_District_code => NULL, par_Religion_code => NULL,
                par_phone1 => NULL, par_phone2 => NULL, par_address_indicator => NULL,
                par_mobile_phone => NULL, par_sms_language => NULL,
                par_Death_indicator => par_death_indicator,
                par_Death_date => par_death_datetime, par_T_PRK => par_t_prk,
                par_NOK_priority => NULL, par_NOK_name => NULL, par_NOK_HKID => NULL,
                par_NOK_relation_code => par_update_type, par_NOK_building => NULL,
                par_NOK_room => NULL, par_NOK_floor => NULL, par_NOK_block => NULL,
                par_NOK_district_code => NULL, par_NOK_phone1 => NULL,
                par_NOK_phone2 => NULL, par_NOK_address_indicator => NULL,
                par_NOK_mobile_phone => NULL, par_NOK_sms_language => NULL,
                par_Case_no => par_case_no,
                par_Admission_datetime => par_admission_datetime,
                par_Source_indicator => par_source_indicator,
                par_Source_code => par_source_hosp_code, par_Pay_code => par_pay_code,
                par_Discharge_code => par_old_discharge_code,
                par_Discharge_datetime => par_old_discharge_datetime,
                par_Destination_code => par_old_discharge_destination,
                par_Case_type => var_case_type, par_Movement_count => NULL,
                par_Security_count => NULL, par_Case_access_code => NULL,
                par_PMI_access_code => NULL, par_Ambulance_no => NULL,
                par_Police_case => NULL, par_Labour_case => NULL,
                par_AE_case_type => NULL, par_DBA_flag => NULL,
                par_Follow_up_datetime => NULL, par_Ward_code => par_ward_code,
                par_Specialty_code => par_specialty_code, par_Bed_no => par_bed_no,
                par_Ward_class => par_ward_class, par_Transfer_datetime => NULL,
                par_Old_name => NULL, par_Old_HKID => NULL, par_Old_sex => NULL,
                par_Old_DOB => NULL, par_Old_ward_class => NULL,
                par_Old_ward_code => NULL, par_Old_specialty_code => NULL,
                par_Old_bed_no => NULL, par_User_ID => par_user_id,
                par_Doctor_code => NULL, par_Old_doctor_code => NULL,
                par_Old_T_PRK => par_t_prk, par_PP_code => par_pp_code,
                par_Last_update_datetime => par_old_update_datetime,
                par_Terminal_id => NULL, par_Old_NOK_name => NULL,
                par_Document_flag => par_document_flag, par_eh_code => par_eh_code,
                par_source_hosp_code => par_source_hosp_code,
                par_source_case_no => par_source_case_no, par_hkic_symbol => NULL,
                par_hkic_symbol_clear => 'N',
                par_move_episode_status => NULL,
                par_me_info_source_code => NULL,
                par_me_reason_code => NULL,
                par_me_other_reason => NULL);

        IF var_retcode != 0 THEN
            RAISE EXCEPTION 'CALL hasp_adt_function_woresult failed';
        END IF;
        /* End - update case */
        /* -- Remarked by WL on 27 July 1999, becasue hasp_update_case -- */
        /* -- is obsolete for HPI --- */

        /* update ADT_Case table by stored proc hasp_update_case */
        /* exec @retcode = hasp_update_case */
        /* @update_flag = 'U', */
        /* @case_no = @case_no, */
        /* @admission_datetime = @admission_datetime, */
        /* @source_indicator = @source_indicator, */
        /* @source_code = @source_hosp_code, */
        /* @hkid = @hkid, */
        /* @district_code = @district_code, */
        /* @pay_code = @pay_code, */
        /* @discharge_code = @old_discharge_code, */
        /* @discharge_datetime = @old_discharge_datetime, */
        /* @destination_code = @old_discharge_destination, */
        /* @case_type = @case_type, */
        /* @active_indicator = @active_indicator, */
        /* @movement_count = @old_movement_count, */
        /* @security_count = @security_count, */
        /* @access_code = @case_access_code, */
        /* @system_datetime = @system_datetime, */
        /* @user_id = @user_id, */
        /* @t_prk = @t_prk, */
        /* @last_system_datetime = @old_update_datetime */
        /* if @retcode != 0 */
        /* goto error */

        /* End - update ADT_Case table by stored proc hasp_update_case */

        /* update patient when document flag was changed */
        IF par_old_document_flag IS NULL OR par_old_document_flag != par_document_flag THEN
            BEGIN
                CALL hasp_adt_function_woresult(
                        pas_return_code => var_retcode, par_hosp_code => par_hospital_code,
                        par_System_datetime => par_system_datetime, par_Type => '030',
                        par_HKID => par_hkid, par_Name => var_name, par_Sex => var_sex,
                        par_DOB => var_dob, par_Exact_DOB_flag => var_exact_dob_flag,
                        par_CCC_1 => var_ccc_1, par_CCC_2 => var_ccc_2,
                        par_CCC_3 => var_ccc_3, par_CCC_4 => var_ccc_4,
                        par_CCC_5 => var_ccc_5, par_CCC_6 => var_ccc_6,
                        par_Marital_status => var_marital_status,
                        par_Race_code => var_race_code,
                        par_Other_document_no => par_other_document_no,
                        par_Medical_record_number => var_mrn, par_Building => var_building,
                        par_Room => var_room, par_Floor => var_floor,
                        par_Block => var_block, par_District_code => par_district_code,
                        par_Religion_code => var_religion_code, par_phone1 => var_phone1,
                        par_phone2 => var_phone2,
                        par_address_indicator => var_address_indicator,
                        par_mobile_phone => var_mobile_phone,
                        par_sms_language => var_sms_language,
                        par_Death_indicator => par_death_indicator,
                        par_Death_date => par_death_datetime, par_T_PRK => par_t_prk,
                        par_NOK_priority => var_nok_priority, par_NOK_name => var_nok_name,
                        par_NOK_HKID => var_nok_hkid,
                        par_NOK_relation_code => var_nok_relation_code,
                        par_NOK_building => var_nok_building, par_NOK_room => var_nok_room,
                        par_NOK_floor => var_nok_floor, par_NOK_block => var_nok_block,
                        par_NOK_district_code => var_nok_district_code,
                        par_NOK_phone1 => var_nok_phone1, par_NOK_phone2 => var_nok_phone2,
                        par_NOK_address_indicator => var_nok_address_indicator,
                        par_NOK_mobile_phone => var_nok_mobile_phone,
                        par_NOK_sms_language => var_nok_sms_language, par_Case_no => NULL,
                        par_Admission_datetime => NULL, par_Source_indicator => NULL,
                        par_Source_code => NULL, par_Pay_code => NULL,
                        par_Discharge_code => NULL, par_Discharge_datetime => NULL,
                        par_Destination_code => NULL, par_Case_type => NULL,
                        par_Movement_count => NULL, par_Security_count => NULL,
                        par_Case_access_code => NULL, par_PMI_access_code => NULL,
                        par_Ambulance_no => NULL, par_Police_case => NULL,
                        par_Labour_case => NULL, par_AE_case_type => NULL,
                        par_DBA_flag => NULL, par_Follow_up_datetime => NULL,
                        par_Ward_code => NULL, par_Specialty_code => NULL,
                        par_Bed_no => NULL, par_Ward_class => NULL,
                        par_Transfer_datetime => NULL, par_Old_name => var_name,
                        par_Old_HKID => par_hkid, par_Old_sex => var_sex,
                        par_Old_DOB => var_dob, par_Old_ward_class => NULL,
                        par_Old_ward_code => NULL, par_Old_specialty_code => NULL,
                        par_Old_bed_no => NULL, par_User_ID => par_user_id,
                        par_Doctor_code => NULL, par_Old_doctor_code => NULL,
                        par_Old_T_PRK => par_t_prk, par_PP_code => NULL,
                        par_Last_update_datetime => var_last_update_datetime,
                        par_Terminal_id => NULL, par_Old_NOK_name => var_nok_name,
                        par_Document_flag => par_document_flag, par_eh_code => NULL,
                        par_source_hosp_code => NULL, par_source_case_no => NULL,
                        par_hkic_symbol => var_hkic_symbol, par_hkic_symbol_clear => 'N',
                        par_move_episode_status => NULL,
                        par_me_info_source_code => NULL,
                        par_me_reason_code => NULL,
                        par_me_other_reason => NULL);

                IF var_retcode != 0 THEN
                    RAISE EXCEPTION 'CALL hasp_adt_function_woresult failed';
                END IF;
            END;
        END IF;
        /* End - update patient when document flag was changed */
        /* CPI */
        /* Update Movement table */
        SELECT Movement_datetime
        INTO var_tmp_movement_datetime
        FROM Movement
        WHERE Case_no = par_case_no
          AND Movement_count = 1
          AND Hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 1 THEN
            BEGIN
                UPDATE Movement
                SET System_datetime = par_system_datetime
                WHERE Case_no = par_case_no
                  AND Movement_count = 1
                  AND Hospital_code = par_hospital_code;

                IF par_admission_datetime != var_tmp_movement_datetime THEN
                    BEGIN
                        UPDATE Movement
                        SET Movement_datetime = par_admission_datetime,
                            User_ID           = par_user_id
                        WHERE Case_no = par_case_no
                          AND Movement_count = 1
                          AND Hospital_code = par_hospital_code;
                    END;
                END IF;
            END;
        END IF;
        /* End - Update Movement table */
        /* ********************************************************** */
        /* Update case details */
        /* Update Ward_list table */
        IF par_allow_update_specific = 'Y' THEN
            BEGIN
                IF EXISTS (SELECT *
                           FROM Ward_list
                           WHERE Case_no = par_case_no
                             AND Hospital_code = par_hospital_code) THEN
                    BEGIN
                        UPDATE Ward_list
                        SET Specialty_code = par_specialty_code,
                            Ward_code      = par_ward_code
                        WHERE Case_no = par_case_no
                          AND Hospital_code = par_hospital_code;
                    END;
                END IF;
            END;
        END IF;
        /* End - Update Ward_list table */
        /* Update HN_case_detail table */
        IF EXISTS (SELECT *
                   FROM HN_case_detail
                   WHERE Case_no = par_case_no
                     AND Hospital_code = par_hospital_code) THEN
            BEGIN
                UPDATE HN_case_detail
                SET EH_code = par_eh_code,
                    PP_code = par_pp_code
                WHERE Case_no = par_case_no
                  AND Hospital_code = par_hospital_code;
            END;
        END IF;
        /* End - Update HN_case_detail table */
        /* End - Update case details */
        /* ********************************************************** */
        /* update 100, insert 120 and insert 121 */
        /* (even if report date > admission date thus allowUpdateSpecific is false. Unlike A&E Register Update) */
        IF par_source_indicator != par_old_source_indicator OR par_source_hosp_code != par_old_source_hosp_code OR
           par_admission_datetime != par_old_admission_datetime OR par_ward_class != par_old_ward_class OR
           par_ward_code != par_old_ward_code OR par_specialty_code != par_old_specialty_code OR
           par_old_movement_count = 1 OR par_old_discharge_code = NULL THEN
            BEGIN
                /* --Update Transaction_log 100 */
                SELECT Post_datetime,
                       From_treatment_location
                INTO var_Post_datetime, var_From_treatment_location
                FROM Transaction_log
                WHERE Hospital_code = par_hospital_code
                  AND Case_no = par_case_no
                  AND Transaction_type = '100'
                  AND Transaction_datetime = par_old_admission_datetime
                  AND (Cancel_flag <> 'Y' OR Cancel_flag IS NULL);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 1 THEN
                    BEGIN
                        /* Update Transaction_log 100 */
                        UPDATE Transaction_log
                        SET User_ID                 = par_user_id,
                            System_datetime         = par_system_datetime,
                            Transaction_datetime    = par_admission_datetime,
                            From_ward_code          = par_ward_code,
                            From_class              = par_ward_class,
                            From_specialty_code     = par_specialty_code,
                            From_treatment_location = par_treatment_location
                        WHERE Hospital_code = par_hospital_code
                          AND Case_no = par_case_no
                          AND Transaction_type = '100'
                          AND Transaction_datetime = par_old_admission_datetime
                          AND (Cancel_flag <> 'Y' OR Cancel_flag IS NULL);
                    END;
                ELSE
                    BEGIN
                        RAISE NOTICE 'Cannot find Admission Transaction_log 100';
                        var_retcode := 299999;
                        var_error_msg := 'Cannot find Admission Transaction_log 100';
                        RAISE EXCEPTION '';
                    END;
                END IF;

                IF var_Post_datetime IS NOT NULL THEN
                    BEGIN
                        var_Post_flag := 'Y';
                    END;
                END IF;
                /* Insert Transaction_log 120 */
                CALL hasp_insert_transaction_log(
                        pas_return_code => var_retcode,
                        par_hosp => par_hospital_code,
                        "par_System_datetime" => par_system_datetime,
                        "par_Case_no" => par_case_no,
                        "par_From_ward_code" => par_old_ward_code,
                        "par_From_treatment_location" => var_From_treatment_location,
                        "par_From_class" => par_old_ward_class,
                        "par_From_bed" => NULL,
                        "par_From_specialty_code" => par_old_specialty_code,
                        "par_To_ward_code" => NULL,
                        "par_To_treatment_location" => NULL,
                        "par_To_class" => NULL,
                        "par_To_bed" => NULL,
                        "par_To_specialty_code" => NULL,
                        "par_Transaction_datetime" => par_old_admission_datetime,
                        "par_Transaction_type" => '120',
                        "par_Post_datetime" => NULL,
                        "par_User_ID" => par_user_id,
                        "par_Post_flag" => var_Post_flag,
                        "par_Prev_system_datetime" => NULL);

                IF var_retcode <> 0 THEN
                    BEGIN
                        RAISE NOTICE 'Fail to insert Transaction_log (120)';
                        var_retcode := 299999;
                        var_error_msg := 'Fail to insert Transaction_log 120';
                        RAISE NOTICE 'var_retcode => [%]',var_retcode;
                        RAISE EXCEPTION '';
                    END;
                END IF;
                /* Insert Transaction_log 121 */
                CALL hasp_insert_transaction_log(
                        pas_return_code => var_retcode,
                        par_hosp => par_hospital_code,
                        "par_System_datetime" => par_system_datetime,
                        "par_Case_no" => par_case_no,
                        "par_From_ward_code" => par_ward_code,
                        "par_From_treatment_location" => par_treatment_location,
                        "par_From_class" => par_ward_class,
                        "par_From_bed" => NULL,
                        "par_From_specialty_code" => par_specialty_code,
                        "par_To_ward_code" => NULL,
                        "par_To_treatment_location" => NULL,
                        "par_To_class" => NULL,
                        "par_To_bed" => NULL,
                        "par_To_specialty_code" => NULL,
                        "par_Transaction_datetime" => par_admission_datetime,
                        "par_Transaction_type" => '121',
                        "par_Post_datetime" => NULL,
                        "par_User_ID" => par_user_id,
                        "par_Post_flag" => var_Post_flag,
                        "par_Prev_system_datetime" => NULL);

                IF var_retcode <> 0 THEN
                    BEGIN
                        RAISE NOTICE 'Fail to insert Transaction_log (121)';
                        var_retcode := 299999;
                        var_error_msg := 'Fail to insert Transaction_log 121';
                        RAISE NOTICE 'var_retcode => [%]',var_retcode;
                        RAISE EXCEPTION '';
                    END;
                END IF;
            END;
        END IF;
        /* --determine whether ward class, ward code or specialty code is changed */
        var_movementIsUpdated := 'N';

        IF par_ward_class != par_old_ward_class OR par_ward_code != par_old_ward_code OR
           par_specialty_code != par_old_specialty_code THEN
            BEGIN
                var_movementIsUpdated := 'Y';
            END;
        END IF;
        var_tmp_ward_class := NULL;
        var_tmp_ward_code := NULL;
        var_tmp_specialty_code := NULL;
        var_tmp_bed_no := NULL;

        IF var_movementIsUpdated = 'Y' THEN
            BEGIN
                var_tmp_ward_class := par_old_ward_class;
                var_tmp_ward_code := par_old_ward_code;
                var_tmp_specialty_code := par_old_specialty_code;
                var_tmp_bed_no := par_old_bed_no;
            END;
        END IF;
        /* Insert Event_log */
        CALL hasp_insert_event_log(
                pas_return_code => var_retcode, par_hosp => par_hospital_code,
                "par_System_datetime" => par_system_datetime,
                "par_Type" => '120', "par_HKID" => par_hkid, "par_Name" => var_name,
                "par_Sex" => var_sex, "par_DOB" => var_dob,
                "par_Exact_DOB_flag" => var_exact_dob_flag, "par_CCC_1" => var_ccc_1,
                "par_CCC_2" => var_ccc_2, "par_CCC_3" => var_ccc_3, "par_CCC_4" => var_ccc_4,
                "par_CCC_5" => var_ccc_5, "par_CCC_6" => var_ccc_6,
                "par_Martial_status" => var_marital_status, "par_Race_code" => var_race_code,
                "par_Other_document_no" => var_old_other_document_no,
                "par_Medical_record_number" => var_mrn, "par_Building" => var_building,
                "par_Room" => var_room, "par_Floor" => var_floor, "par_Block" => var_block,
                "par_District_code" => par_district_code, "par_Religion_code" => var_religion_code,
                "par_phone1" => var_phone1, "par_phone2" => var_phone2,
                "par_address_indicator" => var_address_indicator,
                "par_mobile_phone" => var_mobile_phone, "par_sms_language" => var_sms_language,
                "par_Death_indicator" => par_death_indicator, "par_Death_date" => par_death_datetime,
                "par_T_PRK" => par_t_prk, "par_NOK_name" => var_nok_name,
                "par_NOK_HKID" => var_nok_hkid, "par_NOK_relation_code" => var_nok_relation_code,
                "par_NOK_building" => var_nok_building, "par_NOK_room" => var_nok_room,
                "par_NOK_floor" => var_nok_floor, "par_NOK_block" => var_nok_block,
                "par_NOK_district_code" => var_nok_district_code, "par_NOK_phone1" => var_nok_phone1,
                "par_NOK_phone2" => var_nok_phone2,
                "par_NOK_address_indicator" => var_nok_address_indicator,
                "par_NOK_mobile_phone" => var_nok_mobile_phone,
                "par_NOK_sms_language" => var_nok_sms_language, "par_Case_no" => par_case_no,
                "par_Admission_datetime" => par_old_admission_datetime,
                "par_Source_indicator" => par_old_source_indicator,
                "par_Source_code" => par_old_source_hosp_code, "par_Pay_code" => par_old_pay_code,
                "par_Discharge_code" => par_old_discharge_code,
                "par_Discharge_datetime" => par_old_discharge_datetime,
                "par_Destination_code" => par_old_discharge_destination,
                "par_Case_type" => var_case_type, "par_Movement_count" => par_old_movement_count,
                "par_Security_count" => par_security_count,
                "par_Case_access_code" => par_case_access_code,
                "par_PMI_access_code" => var_pmi_access_code, "par_Ambulance_no" => NULL,
                "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL,
                "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL,
                "par_Ward_code" => var_tmp_ward_code, "par_Specialty_code" => var_tmp_specialty_code,
                "par_Bed_no" => var_tmp_bed_no, "par_Ward_class" => var_tmp_ward_class,
                "par_Old_name" => var_name, "par_Old_HKID" => par_hkid, "par_Old_sex" => var_sex,
                "par_Old_DOB" => var_dob, "par_Old_ward_class" => par_ward_class,
                "par_Old_ward_code" => par_ward_code, "par_Old_specialty_code" => par_specialty_code,
                "par_Old_bed_no" => par_bed_no, "par_User_ID" => par_user_id,
                "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL,
                "par_MRT_indicator" => NULL, "par_Upload_status" => 'N');

        IF var_retcode != 0 THEN
            BEGIN
                RAISE NOTICE 'Fail to insert Event_log (120)';
                var_retcode := 299999;
                var_error_msg := 'Fail to insert Event_log (120)';
                RAISE NOTICE ' var_retcode => [%]',var_retcode;
                RAISE EXCEPTION '';
            END;
        END IF;
        CALL hasp_insert_event_log(
                pas_return_code => var_retcode, par_hosp => par_hospital_code,
                "par_System_datetime" => var_current_datetime, /* use @current_datetime to prevent duplicate key index */
                "par_Type" => '121', "par_HKID" => par_hkid, "par_Name" => var_name,
                "par_Sex" => var_sex, "par_DOB" => var_dob,
                "par_Exact_DOB_flag" => var_exact_dob_flag, "par_CCC_1" => var_ccc_1,
                "par_CCC_2" => var_ccc_2, "par_CCC_3" => var_ccc_3, "par_CCC_4" => var_ccc_4,
                "par_CCC_5" => var_ccc_5, "par_CCC_6" => var_ccc_6,
                "par_Martial_status" => var_marital_status, "par_Race_code" => var_race_code,
                "par_Other_document_no" => par_other_document_no,
                "par_Medical_record_number" => var_mrn, "par_Building" => var_building,
                "par_Room" => var_room, "par_Floor" => var_floor, "par_Block" => var_block,
                "par_District_code" => par_district_code, "par_Religion_code" => var_religion_code,
                "par_phone1" => var_phone1, "par_phone2" => var_phone2,
                "par_address_indicator" => var_address_indicator,
                "par_mobile_phone" => var_mobile_phone, "par_sms_language" => var_sms_language,
                "par_Death_indicator" => par_death_indicator, "par_Death_date" => par_death_datetime,
                "par_T_PRK" => par_t_prk, "par_NOK_name" => var_nok_name,
                "par_NOK_HKID" => var_nok_hkid, "par_NOK_relation_code" => var_nok_relation_code,
                "par_NOK_building" => var_nok_building, "par_NOK_room" => var_nok_room,
                "par_NOK_floor" => var_nok_floor, "par_NOK_block" => var_nok_block,
                "par_NOK_district_code" => var_nok_district_code, "par_NOK_phone1" => var_nok_phone1,
                "par_NOK_phone2" => var_nok_phone2,
                "par_NOK_address_indicator" => var_nok_address_indicator,
                "par_NOK_mobile_phone" => var_nok_mobile_phone,
                "par_NOK_sms_language" => var_nok_sms_language, "par_Case_no" => par_case_no,
                "par_Admission_datetime" => par_admission_datetime,
                "par_Source_indicator" => par_source_indicator,
                "par_Source_code" => par_source_hosp_code, "par_Pay_code" => par_pay_code,
                "par_Discharge_code" => par_old_discharge_code,
                "par_Discharge_datetime" => par_old_discharge_datetime,
                "par_Destination_code" => par_old_discharge_destination,
                "par_Case_type" => var_case_type, "par_Movement_count" => par_old_movement_count,
                "par_Security_count" => par_security_count,
                "par_Case_access_code" => par_case_access_code,
                "par_PMI_access_code" => var_pmi_access_code, "par_Ambulance_no" => NULL,
                "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL,
                "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL,
                "par_Ward_code" => par_ward_code, "par_Specialty_code" => par_specialty_code,
                "par_Bed_no" => par_bed_no, "par_Ward_class" => par_ward_class,
                "par_Old_name" => var_name, "par_Old_HKID" => par_hkid, "par_Old_sex" => var_sex,
                "par_Old_DOB" => var_dob, "par_Old_ward_class" => var_tmp_ward_class,
                "par_Old_ward_code" => var_tmp_ward_code,
                "par_Old_specialty_code" => var_tmp_specialty_code,
                "par_Old_bed_no" => var_tmp_bed_no, "par_User_ID" => par_user_id,
                "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL,
                "par_MRT_indicator" => NULL, "par_Upload_status" => 'N');

        IF var_retcode != 0 THEN
            BEGIN
                RAISE NOTICE 'Fail to insert Event_log (121) ';
                var_retcode := 299999;
                var_error_msg := 'Fail to insert Event_log (121)';
                RAISE NOTICE 'var_retcode => [%]',var_retcode;
                RAISE EXCEPTION '';
            END;
        END IF;
        /* End - Insert Event_log */
        /* Commit transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount > 0
         begin
                select @t_prk
         commit transaction
            end
        */
        pas_return_code := 0;
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                IF var_error_msg IS NULL THEN
                    var_error_msg := SQLERRM;
                ELSE
                    var_error_msg := CONCAT(var_error_msg, ' ', SQLERRM);
                END IF;
                RAISE NOTICE 'var_error_msg => [%]', var_error_msg;
                EXIT error;
            END;
    END;
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
    if @@trancount > 0
     rollback transaction
    */
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
                    IF var_error_msg IS NULL OR LENGTH(var_error_msg) = 0 THEN
                        var_error_msg := CONCAT('Call cpi function failed with return code ',
                                                CASE CAST(var_retcode AS VARCHAR(8))
                                                    WHEN '' THEN ' '
                                                    ELSE CAST(var_retcode AS VARCHAR(8))
                                                    END);
                    END IF;
                END;
            END IF;
        END;
    END IF;
    /* End - Find the error message by error code */
    var_retcode := 299999;
    pas_return_code := var_retcode;
    RAISE EXCEPTION '%', var_error_msg;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_update_hn_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
