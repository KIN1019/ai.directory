-- DROP PROCEDURE web_hasp_discharge_ae(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in int4);

CREATE OR REPLACE PROCEDURE web_hasp_discharge_ae(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_user_id character varying, IN par_transaction_type character varying, IN par_terminal_id character varying, IN par_case_no character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_pay_code character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_discharge_destination character varying, IN par_movement_count integer, IN par_security_count integer, IN par_case_access_code integer, IN par_adt_case_update_datetime timestamp without time zone, IN par_mrt_indicator character varying, IN par_ae_case_type character varying, IN par_ambulance_no character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_labour_case character varying, IN par_police_case character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_specialty character varying, IN par_bed_no character varying, IN par_treatment_location character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_religion_code character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_building character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_pmi_access_code integer)
 LANGUAGE plpgsql
AS $procedure$
/* --Case data */
/* --AE case detail */
/* --Last movement data */
/* --Patient major keys */
/* --Patient data (others) */
DECLARE
    var_return_code                      INTEGER;
    var_error_msg                        VARCHAR(48);
    var_trancount                        INTEGER;
    var_system_datetime                  TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    BEGIN
		IF par_discharge_datetime < '1753-01-01'::TIMESTAMP OR par_discharge_datetime > '9999-12-31'::TIMESTAMP THEN
        -- 抛出自定义的错误，类似 Sybase 的错误
        RAISE EXCEPTION 
            'DB error 247 : Arithmetic overflow during implicit conversion of BIGDATETIME value ''%'' to a DATETIME field. SQL state: ZZZZZ',
            par_discharge_datetime;
		END IF;
		
		IF par_follow_up_datetime < '1753-01-01'::TIMESTAMP OR par_follow_up_datetime > '9999-12-31'::TIMESTAMP THEN
        -- 抛出自定义的错误，类似 Sybase 的错误
        RAISE EXCEPTION 
            'DB error 247 : Arithmetic overflow during implicit conversion of BIGDATETIME value ''%'' to a DATETIME field. SQL state: ZZZZZ',
            par_follow_up_datetime;
		END IF;
		
		
        SELECT 0
        INTO var_return_code;

        /* --Get current system datetime */
        SELECT timestamp_convert(localtimestamp)
        INTO var_system_datetime;
        /* --Call the stored proc. used in jConnect 6 version (SP + EJB) */
       raise notice 'par_hkid=>%',par_hkid;
        CALL hasp_td_function(par_hosp_code => par_hospital_code,
                                           par_type => par_transaction_type,
                                           par_hkid => par_hkid,
                                           par_case_no => par_case_no,
                                           par_discharge_code => par_discharge_code,
                                           par_destination_code => par_discharge_destination,
                                           par_movement_count => par_movement_count,
                                           par_ward_code => par_ward_code,
                                           par_specialty_code => par_specialty,
                                           par_bed_no => par_bed_no,
                                           par_ward_class => par_ward_class,
                                           par_doctor_code => NULL,
                                           par_old_ward_code => NULL,
                                           par_old_specialty_code => NULL,
                                           par_old_bed_no => NULL,
                                           par_old_ward_class => NULL,
                                           par_old_doctor_code => NULL,
                                           par_treatment_location => par_treatment_location,
                                           par_follow_up_datetime => par_follow_up_datetime,
                                           par_discharge_datetime => par_discharge_datetime,
                                           par_transfer_datetime => NULL,
                                           par_user_id => par_user_id,
                                           par_system_datetime => timestamp_convert(localtimestamp),
                                           par_last_update_datetime => par_adt_case_update_datetime,
                                           par_terminal_id => par_terminal_id,
                                           par_mrt_indicator => par_mrt_indicator,
                                           pas_return_code => var_return_code);

        IF var_return_code != 0 THEN
            BEGIN
                SELECT 299999
                INTO var_return_code;
                SELECT 'Error when calling hasp_td_function'
                INTO var_error_msg;
                RAISE EXCEPTION '%', var_error_msg; --USING ERRCODE = var_return_code;
            END;
        END IF;       
		
		IF NOT EXISTS (SELECT
            1
            FROM cpi_case
            WHERE patient_key = par_patient_key AND (case_type = 'I' OR case_type = 'A') AND status_code = 'AC' AND ((discharge_code IS NULL OR discharge_code = '') AND discharge_dtm IS NULL) AND case_no != par_case_no /* --filter away this case no because the above update transaction */)
        /* --(to update discharge code) might not be committed yet */
        THEN
            BEGIN
	            RAISE NOTICE '-- prepare to update privacy flag --';
                call cpi_update_patient_privacy(pas_return_code => var_return_code,
				par_hospital_code => par_hospital_code,
				par_patient_key => par_patient_key,
				par_privacy => 'N',
				par_case_no => par_case_no,
				par_source_system => 'IPAS',
				par_function_id => 10270,
				par_update_by => par_user_id,
				par_return_code => var_return_code,
				par_return_message => var_error_msg);
                /* --Comment below (don't goto return_error) so that if the updating privacy flag failed, */
                /* --the original discharge function is still not affected. */
                /*
                if (return_error_code != 0) begin
                	select	@success_flag = "N"
                	goto return_error
                end
                */
				RAISE NOTICE '-- finish to update privacy flag --';
            END;
        END IF;
		
		IF NOT EXISTS (SELECT
            1
            FROM cpi_case
            WHERE patient_key = par_patient_key AND (case_type = 'I' OR case_type = 'A') AND status_code = 'AC' AND ((discharge_code IS NULL OR discharge_code = '') AND discharge_dtm IS NULL) AND case_no != par_case_no /* --filter away this case no because the above update transaction */)
        /* --(to update discharge code) might not be committed yet */
        THEN
            BEGIN
                call cpi_update_patient_privacy(pas_return_code => var_return_code,
				par_hospital_code => par_hospital_code,
				par_patient_key => par_patient_key,
				par_privacy => 'N',
				par_case_no => par_case_no,
				par_source_system => 'IPAS',
				par_function_id => 10270,
				par_update_by => par_user_id,
				par_return_code => var_return_code,
				par_return_message => var_error_msg);
                /* --Comment below (don't goto return_error) so that if the updating privacy flag failed, */
                /* --the original discharge function is still not affected. */
                /*
                if (return_error_code != 0) begin
                	select	@success_flag = "N"
                	goto return_error
                end
                */
            END;
        END IF;
        /* --End - Call the stored proc. used in jConnect 6 version (SP + EJB) */
        /* --Insert Event_log */
       --raise notice 'par_hosp is %,par_System_datetime is %',par_hospital_code,timestamp_convert(localtimestamp);
       CALL hasp_insert_event_log(pas_return_code => var_return_code,
                                                par_hosp => par_hospital_code,
                                                "par_System_datetime" => timestamp_convert(clock_timestamp()::timestamp),
                                                "par_Type" => par_transaction_type,
                                                "par_HKID" => par_hkid,
                                                "par_Name" => par_name,
                                                "par_Sex" => par_sex,
                                                "par_DOB" => par_dob,
                                                "par_Exact_DOB_flag" => par_exact_dob_flag,
                                                "par_CCC_1" => par_ccc1,
                                                "par_CCC_2" => par_ccc2,
                                                "par_CCC_3" => par_ccc3,
                                                "par_CCC_4" => par_ccc4,
                                                "par_CCC_5" => par_ccc5,
                                                "par_CCC_6" => par_ccc6,
                                                "par_Martial_status" => par_marital_status,
                                                "par_Race_code" => par_race_code,
                                                "par_Other_document_no" => par_other_document_no,
                                                "par_Medical_record_number" => par_medical_record_number,
                                                "par_Building" => par_building,
                                                "par_Room" => par_room,
                                                "par_Floor" => par_floor,
                                                "par_Block" => par_block,
                                                "par_District_code" => par_district_code,
                                                "par_Religion_code" => par_religion_code,
                                                par_phone1 => par_phone1,
                                                par_phone2 => par_phone2,
                                                par_address_indicator => par_address_indicator,
                                                par_mobile_phone => par_mobile_phone,
                                                par_sms_language => par_sms_language,
                                                "par_Death_indicator" => par_death_indicator,
                                                "par_Death_date" => par_death_date,
                                                "par_T_PRK" => par_patient_key,
                                                "par_NOK_name" => NULL,
                                                "par_NOK_HKID" => NULL,
                                                "par_NOK_relation_code" => NULL,
                                                "par_NOK_building" => NULL,
                                                "par_NOK_room" => NULL,
                                                "par_NOK_floor" => NULL,
                                                "par_NOK_block" => NULL,
                                                "par_NOK_district_code" => NULL,
                                                "par_NOK_phone1" => NULL,
                                                "par_NOK_phone2" => NULL,
                                                "par_NOK_address_indicator" => NULL,
                                                "par_NOK_mobile_phone" => NULL,
                                                "par_NOK_sms_language" => NULL,
                                                "par_Case_no" => par_case_no,
                                                "par_Admission_datetime" => par_admission_datetime,
                                                "par_Source_indicator" => par_source_indicator,
                                                "par_Source_code" => par_source_code,
                                                "par_Pay_code" => par_pay_code,
                                                "par_Discharge_code" => par_discharge_code,
                                                "par_Discharge_datetime" => par_discharge_datetime,
                                                "par_Destination_code" => par_discharge_destination,
                                                "par_Case_type" => 'A',
                                                "par_Movement_count" => par_movement_count,
                                                "par_Security_count" => par_security_count,
                                                "par_Case_access_code" => par_case_access_code,
                                                "par_PMI_access_code" => par_pmi_access_code,
                                                "par_Ambulance_no" => NULL,
                                                "par_Police_case" => NULL,
                                                "par_Labour_case" => NULL,
                                                "par_AE_case_type" => NULL,
                                                "par_DBA_flag" => NULL,
                                                "par_Follow_up_datetime" => NULL,
                                                "par_Ward_code" => par_ward_code,
                                                "par_Specialty_code" => par_specialty,
                                                "par_Bed_no" => par_bed_no,
                                                "par_Ward_class" => par_ward_class,
                                                "par_Old_name" => NULL,
                                                "par_Old_HKID" => NULL,
                                                "par_Old_sex" => NULL,
                                                "par_Old_DOB" => NULL,
                                                "par_Old_ward_class" => NULL,
                                                "par_Old_ward_code" => NULL,
                                                "par_Old_specialty_code" => NULL,
                                                "par_Old_bed_no" => NULL,
                                                "par_User_ID" => par_user_id,
                                                "par_Doctor_code" => NULL,
                                                "par_Old_doctor_code" => NULL,
                                                "par_Old_T_PRK" => NULL,
                                                "par_MRT_indicator" => NULL);

        IF var_return_code != 0 THEN
            BEGIN
                SELECT 299999
                INTO var_return_code;
                SELECT 'Fail to insert Event_log'
                INTO var_error_msg;
                RAISE EXCEPTION '%', var_error_msg; --USING ERRCODE = var_return_code;
            END;
        END IF;
        /* --End - Insert Event_log */
        /* --Insert Transaction_log */
        CALL hasp_insert_transaction_log(pas_return_code => var_return_code,
                                                       par_hosp => par_hospital_code,
                                                      "par_System_datetime" => timestamp_convert(localtimestamp),
                                                      "par_Case_no" => par_case_no,
                                                      "par_From_ward_code" => par_ward_code,
                                                      "par_From_treatment_location" => par_treatment_location,
                                                      "par_From_class" => par_ward_class,
                                                      "par_From_specialty_code" => par_specialty,
                                                      "par_From_bed" => par_bed_no,
                                                      "par_To_ward_code" => NULL,
                                                      "par_To_treatment_location" => NULL,
                                                      "par_To_class" => NULL,
                                                      "par_To_specialty_code" => NULL,
                                                      "par_To_bed" => NULL,
                                                      "par_Transaction_datetime" => par_discharge_datetime,
                                                      "par_Transaction_type" => par_transaction_type,
                                                      "par_Post_datetime" => NULL,
                                                      "par_User_ID" => par_user_id,
                                                      "par_Post_flag" => NULL,
                                                      "par_Prev_system_datetime" => NULL);

        IF var_return_code != 0 THEN
            BEGIN
                SELECT 299999
                INTO var_return_code;
                SELECT 'Fail to insert Transaction_log'
                INTO var_error_msg;
               RAISE NOTICE 'Fail to insert Transaction_log';
                RAISE EXCEPTION '%', var_error_msg; --USING ERRCODE = var_return_code;
            END;
        END IF;
        /* --End - Insert Transaction_log */
    END;
    
    	
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_discharge_ae" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
