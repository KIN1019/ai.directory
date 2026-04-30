-- DROP PROCEDURE web_hasp_move_episodes(inout int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE web_hasp_move_episodes(INOUT pas_return_code integer, IN par_system_datetime timestamp without time zone, IN par_hkid character varying, IN par_patient_key character varying, IN par_case_no character varying, IN par_user_id character varying, IN par_old_hkid character varying, IN par_old_patient_key character varying, IN par_move_episode_status character varying DEFAULT NULL::character varying, IN par_me_info_source_code character varying DEFAULT NULL::character varying, IN par_me_reason_code character varying DEFAULT NULL::character varying, IN par_me_other_reason character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_hosp_code VARCHAR(03);
    var_transaction_type VARCHAR(03);
    var_case_type VARCHAR(01);
    var_old_user_id VARCHAR(08);
    var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_error_msg VARCHAR(255);
    var_old_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
    var_selected_error_msg VARCHAR(255);
BEGIN
    <<error>>
    begin
	select substring(par_me_other_reason, 1, 255) into par_me_other_reason;

        /* Assign parameters */
        var_transaction_type := '040';
        /* Get hospital code */
        SELECT
            Text_value
            INTO var_hosp_code
            FROM Hospital_control
            WHERE Type = 'hospital_code';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount != 1 THEN
            begin
                var_retcode := 200016;
                var_error_msg := 'Fail to get hospital code';
                RAISE exception '';
            END;
        END IF;
        /* End - Get hospital code */
        /* Verify patient */
        IF (SELECT
            COUNT(*)
            FROM cpi_patient
            WHERE hkid = par_hkid AND patient_key = par_patient_key) = 0 THEN
            begin
                var_retcode := 29999;
                var_error_msg := 'To patient not found';
                RAISE exception '';
            END;
        END IF;

        IF (SELECT
            COUNT(*)
            FROM cpi_patient
            WHERE hkid = par_old_hkid AND patient_key = par_old_patient_key) = 0 THEN
            begin
                var_retcode := 29999;
                var_error_msg := 'From patient not found';
                RAISE exception '';
            END;
        END IF;
        /* End - Verify patient */
        /* Get case from ADT database */
        SELECT
            User_ID, System_datetime
            INTO var_old_user_id, var_old_system_datetime
            FROM ADT_Case
            WHERE Case_no = par_case_no;

        /* End - Get case from ADT database */
        /* Open transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        		begin transaction
        */
        /* Update ADT database */
        /* --	update ADT_Case */
        /* --	set	T_PRK			= @patient_key, */
        /* --		User_ID			= @user_id, */
        /* --		System_datetime	= @system_datetime */
        /* --	where Case_no = @case_no */
        /* --	and T_PRK = @old_patient_key */
        /* --	select @rowcount = @@rowcount, @error = @@error */
        /* Error throws when update ADT_Case */
        
        /* --	if @error != 0 */
        
        /* --	begin */
        
        /* --		if @@trancount > 0 */
        
        /* --			rollback transaction */
        
        /* --		return */
        
        /* --	end */
        /* More than one active cases are existed */
        
        /* --	if @rowcount != 1 */
        
        /* --	begin */
        
        /* --		select @retcode = 200014 */
        
        /* --		goto error */
        
        /* --	end */
        IF (SELECT
            COUNT(*)
            FROM Case_key_changed
            WHERE Case_no = par_case_no) = 0 THEN
            begin

                INSERT INTO Case_key_changed (hospital_code, case_no, old_hkid, user_id, system_datetime)
                VALUES (var_hosp_code, par_case_no, par_old_hkid, var_old_user_id, var_old_system_datetime);
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
                        pas_return_code := 0;
                        RETURN;
                    END;
                END IF;

                IF var_rowcount != 1 THEN
                    begin

                        var_retcode := 29999;
                        var_error_msg := 'Cannot insert Case_key_changed Table';
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;

        INSERT INTO Case_key_changed (hospital_code, case_no, old_hkid, user_id, system_datetime)
        VALUES (var_hosp_code, par_case_no, par_hkid, par_user_id, par_system_datetime);
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
                pas_return_code := 0;
                RETURN;
            END;
        END IF;

        IF var_rowcount != 1 THEN
            begin

                var_retcode := 29999;
                var_error_msg := 'Cannot insert Case_key_changed Table';
                RAISE exception '';
            END;
        END IF;
        /* End - Update ADT database */
        /* Update CPI database */
        IF SUBSTRING(par_case_no, 2, 2) = 'HN' THEN
            SELECT
                'I'
                INTO var_case_type;
        END IF;

        IF SUBSTRING(par_case_no, 2, 2) = 'AE' THEN
            SELECT
                'A'
                INTO var_case_type;
        END IF;
		
       	RAISE NOTICE 'call cpi_move_episodes start';
        CALL cpi_move_episodes(var_retcode, var_hosp_code, par_case_no, par_old_hkid, par_old_patient_key, par_hkid, par_patient_key, var_case_type, var_transaction_type, par_system_datetime, par_user_id, 'ADT', par_move_episode_status, par_me_info_source_code, par_me_reason_code, par_me_other_reason);

        IF var_retcode != 0 THEN
        	RAISE NOTICE 'call cpi_move_episodes error! var_retcode => %',var_retcode;
            RAISE exception '';
        END IF;
       	RAISE NOTICE 'call cpi_move_episodes done';
        /* End - Update CPI database */
        /* Insert Event_log */

		CALL hasp_insert_event_log(pas_return_code => var_retcode, par_hosp => var_hosp_code, "par_System_datetime" => par_system_datetime, "par_Type" => var_transaction_type,"par_HKID" => par_old_hkid, "par_Name" => NULL, "par_Sex" => NULL, "par_DOB" => NULL, "par_Exact_DOB_flag" => NULL, "par_CCC_1" => NULL, "par_CCC_2" => NULL, "par_CCC_3" => NULL, "par_CCC_4" => NULL, "par_CCC_5" => NULL, "par_CCC_6" => NULL, "par_Martial_status" => NULL, "par_Race_code" => NULL, "par_Other_document_no" => NULL, "par_Medical_record_number" => NULL, "par_Building" => NULL, "par_Room" => NULL, "par_Floor" => NULL, "par_Block" => NULL, "par_District_code" => NULL, "par_Religion_code" => NULL, "par_phone1" => NULL, "par_phone2" => NULL, "par_address_indicator" => NULL, "par_mobile_phone" => NULL, "par_sms_language" => NULL, "par_Death_indicator" => NULL, "par_Death_date" => NULL, "par_T_PRK" => NULL, "par_NOK_name" => NULL, "par_NOK_HKID" => NULL, "par_NOK_relation_code" => NULL, "par_NOK_building" => NULL, "par_NOK_room" => NULL, "par_NOK_floor" => NULL, "par_NOK_block" => NULL, "par_NOK_district_code" => NULL, "par_NOK_phone1" => NULL, "par_NOK_phone2" => NULL, "par_NOK_address_indicator" => NULL, "par_NOK_mobile_phone" => NULL, "par_NOK_sms_language" => NULL, "par_Case_no" => par_case_no, "par_Admission_datetime" => NULL, "par_Source_indicator" => NULL, "par_Source_code" => NULL, "par_Pay_code" => NULL, "par_Discharge_code" => NULL, "par_Discharge_datetime" => NULL, "par_Destination_code" => NULL, "par_Case_type" => NULL, "par_Movement_count" => 0, "par_Security_count" => 0, "par_Case_access_code" => 0, "par_PMI_access_code" => 0, "par_Ambulance_no" => NULL, "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL, "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL, "par_Ward_code" => NULL, "par_Specialty_code" => NULL, "par_Bed_no" => NULL, "par_Ward_class" => NULL, "par_Old_name" => NULL, "par_Old_HKID" => par_hkid, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => NULL, "par_Old_ward_code" => NULL, "par_Old_specialty_code" => NULL, "par_Old_bed_no" => NULL, "par_User_ID" => par_user_id, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL);

        IF var_retcode != 0 THEN
            BEGIN
                var_retcode := 29999;
                var_error_msg := 'Fail to insert Event_log';
                RAISE exception '';
            END;
        END IF;
        /* End - Insert Event_log */
        /* Commit transaction */
        pas_return_code := 0;
        RETURN;
    END;
    /* Find the error message by error code */
	EXCEPTION
		WHEN OTHERS THEN
			BEGIN
				IF var_retcode IS NULL THEN
					RAISE EXCEPTION '%', SQLERRM ;
				END IF;
				
				SELECT
					messages
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
							CASE CAST (var_retcode AS VARCHAR(8))
								WHEN '' THEN ' '
								ELSE CAST (var_retcode AS VARCHAR(8))
							END);
						END IF;
					END;
				END IF;
				/* End - Find the error message by error code */
				RAISE EXCEPTION '%', var_error_msg USING ERRCODE := var_retcode;
				/*RAISE EXCEPTION '%', var_error_msg ;*/
			end;
    
    pas_return_code := 99;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_move_episodes" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
