CREATE OR REPLACE PROCEDURE web_hasp_patient_merge(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_from_hkid VARCHAR, IN par_to_hkid VARCHAR, IN par_user_id VARCHAR, IN par_system_datetime TIMESTAMP WITHOUT TIME ZONE, IN par_insert_event_log VARCHAR)
 LANGUAGE plpgsql
AS 
$procedure$
/*
Return code      Meaning
0              OK
99             error
*/
DECLARE
    var_error INTEGER;
    /* --			@hospital_code		char(03),  /*-- since hospital code is input parm --*/ */
    var_from_patient_key VARCHAR(08);
    var_from_name VARCHAR(48);
    var_from_sex VARCHAR(01);
    var_from_dob TIMESTAMP WITHOUT TIME ZONE;
    var_to_patient_key VARCHAR(08);
    var_to_name VARCHAR(48);
    var_to_sex VARCHAR(01);
    var_to_dob TIMESTAMP WITHOUT TIME ZONE;
    var_to_edob_flag VARCHAR(1);
    var_error_msg VARCHAR(255);
    var_retcode INTEGER;
    var_rowcount INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<error>>
    BEGIN
        /* -- since hospital code is input parm -- */
        
        /* --	select @hospital_code = Hospital_code */
        
        /* --	from Hospital */
        
        /* --	if @@rowcount <> 1 */
        
        /* --	begin */
        
        /* --		set @retcode	= 29999 */
        
        /* --		set @error_msg	= 'Hospital not found, patient merge is rejected!' */
        
        /* --		goto error */
        
        /* --	end */
        SELECT
            patient_key, patient_name, sex, dob, exact_dob_flag
            INTO var_to_patient_key, var_to_name, var_to_sex, var_to_dob, var_to_edob_flag
            FROM cpi_patient
            WHERE hkid = par_to_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount <> 1 THEN
            BEGIN
                var_retcode := 29999;
                var_error_msg := 'To Patient not found, patient merge is rejected!';
                EXIT error;
            END;
        END IF;
        SELECT
            patient_key, patient_name, sex, dob
            INTO var_from_patient_key, var_from_name, var_from_sex, var_from_dob
            FROM cpi_patient
            WHERE hkid = par_from_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount <> 1 THEN
            BEGIN
                var_retcode := 29999;
                var_error_msg := 'From Patient not found, patient merge is rejected!';
                EXIT error;
            END;
        END IF;

        IF par_from_hkid = par_to_hkid THEN
            BEGIN
                var_retcode := 29999;
                var_error_msg := 'From Patient HKID is equal to To Patient HKID, patient merge is rejected!';
                EXIT error;
            END;
        END IF;
        /* Open transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        		begin transaction
        */
        CALL cpi_patient_merge(var_retcode, par_from_hkid, par_to_hkid, par_user_id, 'ADT', par_system_datetime, par_hospital_code, '020');

        IF var_retcode != 0 THEN
            BEGIN
                SELECT
                    messages
                    INTO var_error_msg
                    FROM error_msgs
                    WHERE error_code = var_retcode;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Call cpi function failed with return code ',
                            CASE CAST (var_retcode AS VARCHAR(8))
                                WHEN '' THEN ' '
                                ELSE CAST (var_retcode AS VARCHAR(8))
                            END)
                            INTO var_error_msg;
                    END;
                END IF;
                var_retcode := 29999;
                var_error_msg := var_error_msg;
                EXIT error;
            END;
        END IF;
        /* Insert Event_log */
        IF par_insert_event_log = 'Y' THEN
            BEGIN
                CALL hasp_insert_event_log(pas_return_code => var_retcode, par_hosp => par_hospital_code, "par_System_datetime" => par_system_datetime, "par_Type" => '020', "par_HKID" => par_to_hkid, "par_Name" => var_to_name, "par_Sex" => var_to_sex, "par_DOB" => var_to_dob, "par_Exact_DOB_flag" => var_to_edob_flag, "par_CCC_1" => NULL, "par_CCC_2" => NULL, "par_CCC_3" => NULL, "par_CCC_4" => NULL, "par_CCC_5" => NULL, "par_CCC_6" => NULL, "par_Martial_status" => NULL, "par_Race_code" => NULL, "par_Other_document_no" => NULL, "par_Medical_record_number" => NULL, "par_Building" => NULL, "par_Room" => NULL, "par_Floor" => NULL, "par_Block" => NULL, "par_District_code" => NULL, "par_Religion_code" => NULL, "par_phone1" => NULL, "par_phone2" => NULL, "par_address_indicator" => NULL, "par_mobile_phone" => NULL, "par_sms_language" => NULL, "par_Death_indicator" => NULL, "par_Death_date" => NULL, "par_T_PRK" => NULL, "par_NOK_name" => NULL, "par_NOK_HKID" => NULL, "par_NOK_relation_code" => NULL, "par_NOK_building" => NULL, "par_NOK_room" => NULL, "par_NOK_floor" => NULL, "par_NOK_block" => NULL, "par_NOK_district_code" => NULL, "par_NOK_phone1" => NULL, "par_NOK_phone2" => NULL, "par_NOK_address_indicator" => NULL, "par_NOK_mobile_phone" => NULL, "par_NOK_sms_language" => NULL, "par_Case_no" => NULL, "par_Admission_datetime" => NULL, "par_Source_indicator" => NULL, "par_Source_code" => NULL, "par_Pay_code" => NULL, "par_Discharge_code" => NULL, "par_Discharge_datetime" => NULL, "par_Destination_code" => NULL, "par_Case_type" => NULL, "par_Movement_count" => NULL, "par_Security_count" => NULL, "par_Case_access_code" => NULL, "par_PMI_access_code" => NULL, "par_Ambulance_no" => NULL, "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL, "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL, "par_Ward_code" => NULL, "par_Specialty_code" => NULL, "par_Bed_no" => NULL, "par_Ward_class" => NULL, "par_Old_name" => var_from_name, "par_Old_HKID" => par_from_hkid, "par_Old_sex" => var_from_sex, "par_Old_DOB" => var_from_dob, "par_Old_ward_class" => NULL, "par_Old_ward_code" => NULL, "par_Old_specialty_code" => NULL, "par_Old_bed_no" => NULL, "par_User_ID" => par_user_id, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL);

                IF var_retcode != 0 THEN
                    BEGIN
                        var_retcode := 29999;
                        var_error_msg := 'Fail to insert Event_log';
                        EXIT error;
                    END;
                END IF;
                /* End - Insert Event_log */
            END;
        END IF;
        /* Commit transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount > 0
        		commit transaction
        */
        pas_return_code := 0;
        RETURN;
    END;
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
    if @@trancount > 0
    		rollback transaction
    */
    RAISE EXCEPTION '%', var_error_msg USING ERRCODE := var_retcode;
    pas_return_code := 99;
    RETURN;
END;
$procedure$;

;ALTER PROCEDURE "web_hasp_patient_merge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
