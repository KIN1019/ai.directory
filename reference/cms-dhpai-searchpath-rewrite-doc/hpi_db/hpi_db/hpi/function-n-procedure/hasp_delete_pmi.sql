-- DROP PROCEDURE hpi.hasp_delete_pmi(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_delete_pmi(INOUT pas_return_code integer, IN par_input_hkid character varying, IN par_input_hosp_code character varying, IN par_input_name character varying, IN par_input_sex character varying, IN par_input_dob timestamp without time zone, IN par_input_ccc1 character varying, IN par_input_ccc2 character varying, IN par_input_ccc3 character varying, IN par_input_ccc4 character varying, IN par_input_ccc5 character varying, IN par_input_ccc6 character varying, IN par_input_exact_dob_flag character varying, IN par_input_patient_key character varying, IN par_system_datetime timestamp without time zone, IN par_user_id character varying, IN par_source_system character varying, IN par_update_hosp character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_retcode INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_cpi_flag VARCHAR(1);
    var_error_msg VARCHAR(48);
    sql$rowcount BIGINT;
BEGIN
    <<end_error>>
    BEGIN
        /* --- get cpi flag --- */
        SELECT
            Text_value
            INTO var_cpi_flag
            FROM Hospital_control
            WHERE Hospital_code = par_input_hosp_code AND Type = 'cpi_server';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_retcode;
                EXIT end_error;
            END;
        END IF;

        IF var_rowcount <> 1 THEN
            BEGIN
                SELECT
                    29999
                    INTO var_retcode;
                RAISE EXCEPTION '% ', 'Incorrect stored proc for CPI server' USING ERRCODE := var_retcode;
                EXIT end_error;
            END;
        END IF;
        CALL hasp_validate_del_pmi(var_retcode, par_input_hkid, par_input_hosp_code);

        IF var_retcode <> 0 THEN
            BEGIN
                EXIT end_error;
            END;
        END IF;
        CALL cpi_del_pmi(var_retcode, par_input_hkid, par_input_hosp_code, par_input_name, par_input_sex, par_input_dob, par_input_ccc1, par_input_ccc2, par_input_ccc3, par_input_ccc4, par_input_ccc5, par_input_ccc6, par_input_exact_dob_flag, par_input_patient_key, par_system_datetime, par_user_id, par_source_system, par_update_hosp);

        IF var_retcode <> 0 THEN
            BEGIN
                SELECT
                    messages
                    INTO var_error_msg
                    FROM error_msgs
                    WHERE error_code = var_retcode;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Call cpi function failed with return code',
                            CASE CAST (var_retcode AS VARCHAR(8))
                                WHEN '' THEN ''
                                ELSE CAST (var_retcode AS VARCHAR(8))
                            END)
                            INTO var_error_msg;
                    END;
                END IF;
                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := '29999';
                EXIT end_error;
            END;
        END IF;
        /* --- insert Event_log --- */
        CALL hasp_insert_event_log(pas_return_code => var_retcode, par_hosp => par_input_hosp_code, "par_System_datetime" => par_system_datetime, "par_Type" => '250', "par_HKID" => par_input_hkid, "par_Name" => par_input_name, "par_Sex" => par_input_sex, "par_DOB" => par_input_dob, "par_Exact_DOB_flag" => par_input_exact_dob_flag, "par_CCC_1" => par_input_ccc1, "par_CCC_2" => par_input_ccc2, "par_CCC_3" => par_input_ccc3, "par_CCC_4" => par_input_ccc4, "par_CCC_5" => par_input_ccc5, "par_CCC_6" => par_input_ccc6, "par_Martial_status" => NULL, "par_Race_code" => NULL, "par_Other_document_no" => NULL, "par_Medical_record_number" => NULL, "par_Building" => NULL, "par_Room" => NULL, "par_Floor" => NULL, "par_Block" => NULL, "par_District_code" => NULL, "par_Religion_code" => NULL, par_phone1 => NULL, par_phone2 => NULL, par_address_indicator => NULL, par_mobile_phone => NULL, par_sms_language => NULL, "par_Death_indicator" => NULL, "par_Death_date" => NULL, "par_T_PRK" => par_input_patient_key, "par_NOK_name" => NULL, "par_NOK_HKID" => NULL, "par_NOK_relation_code" => NULL, "par_NOK_building" => NULL, "par_NOK_room" => NULL, "par_NOK_floor" => NULL, "par_NOK_block" => NULL, "par_NOK_district_code" => NULL, "par_NOK_phone1" => NULL, "par_NOK_phone2" => NULL, "par_NOK_address_indicator" => NULL, "par_NOK_mobile_phone" => NULL, "par_NOK_sms_language" => NULL, "par_Case_no" => NULL, "par_Admission_datetime" => NULL, "par_Source_indicator" => NULL, "par_Source_code" => NULL, "par_Pay_code" => NULL, "par_Discharge_code" => NULL, "par_Discharge_datetime" => NULL, "par_Destination_code" => NULL, "par_Case_type" => NULL, "par_Movement_count" => NULL, "par_Security_count" => NULL, "par_Case_access_code" => NULL, "par_PMI_access_code" => NULL, "par_Ambulance_no" => NULL, "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL, "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL, "par_Ward_code" => NULL, "par_Specialty_code" => NULL, "par_Bed_no" => NULL, "par_Ward_class" => NULL, "par_Old_name" => NULL, "par_Old_HKID" => NULL, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => NULL, "par_Old_ward_code" => NULL, "par_Old_specialty_code" => NULL, "par_Old_bed_no" => NULL, "par_User_ID" => par_user_id, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL);

        IF var_retcode != 0 THEN
            BEGIN
                RAISE EXCEPTION '% ', 'Fail to insert Event_log, PMI delete rejected' USING ERRCODE := '29999';
                EXIT end_error;
            END;
        END IF;
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_delete_pmi" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
