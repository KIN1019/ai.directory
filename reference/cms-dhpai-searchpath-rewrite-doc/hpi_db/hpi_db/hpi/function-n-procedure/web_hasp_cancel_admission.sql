-- DROP PROCEDURE hpi.web_hasp_cancel_admission(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in int4);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_cancel_admission(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_user_id character varying, IN par_transaction_type character varying, IN par_case_no character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_pay_code character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_discharge_destination character varying, IN par_movement_count integer, IN par_security_count integer, IN par_case_access_code integer, IN par_ae_case_type character varying, IN par_ambulance_no character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_labour_case character varying, IN par_police_case character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_specialty character varying, IN par_bed_no character varying, IN par_treatment_location character varying, IN par_last_movement_tran_datetime timestamp without time zone, IN par_last_movement_system_datetime timestamp without time zone, IN par_hkid character varying, IN par_patient_key character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_religion_code character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_building character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_pmi_access_code integer)
 LANGUAGE plpgsql
AS $procedure$
/* --Case data */
/* --AE case detail */
/* --Last movement data */
/* --Patient major keys */
/* --Patient data (others) */
DECLARE
    var_return_code INTEGER;
    var_error_msg VARCHAR(48);
    var_trancount INTEGER;
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_case_type VARCHAR(01);
    gjp_text text;
   	error_code text;
   	message text;
BEGIN

    begin 
              gjp_text := '[' || coalesce(par_hospital_code,'NULL-par_hospital_code') || '#@#' || 
					coalesce(par_user_id,'NULL-par_user_id') || '#@#' || 
					coalesce(par_transaction_type,'NULL-par_transaction_type') || '#@#' || 
					coalesce(par_case_no,'NULL-par_case_no') || '#@#' || 
					to_char(coalesce(par_admission_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_source_indicator,'NULL-par_source_indicator') || '#@#' || 
					coalesce(par_source_code,'NULL-par_source_code') || '#@#' || 
					coalesce(par_pay_code,'NULL-par_pay_code') || '#@#' || 
					coalesce(par_discharge_code,'NULL-par_discharge_code') || '#@#' || 
					to_char(coalesce(par_discharge_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_discharge_destination,'NULL-par_discharge_destination') || '#@#' || 
					coalesce(par_movement_count::text,'NULL-par_movement_count') || '#@#' || 
					coalesce(par_security_count::text,'NULL-par_security_count') || '#@#' || 
					coalesce(par_case_access_code::text,'NULL-par_case_access_code') || '#@#' || 
					coalesce(par_ae_case_type,'NULL-par_ae_case_type') || '#@#' || 
					coalesce(par_ambulance_no,'NULL-par_ambulance_no') || '#@#' || 
					coalesce(par_dba_flag,'NULL-par_dba_flag') || '#@#' ||  
					to_char(coalesce(par_follow_up_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_labour_case,'NULL-par_labour_case') || '#@#' || 
					coalesce(par_police_case, 'NULL-par_police_case') || '#@#' || 
					coalesce(par_ward_code,'NULL-par_ward_code') || '#@#' || 
					coalesce(par_ward_class,'NULL-par_ward_class') || '#@#' || 
					coalesce(par_specialty,'NULL-par_specialty') || '#@#' || 
					coalesce(par_bed_no,'NULL-par_bed_no') || '#@#' || 
					coalesce(par_treatment_location,'NULL-par_treatment_location') || '#@#' || 
					to_char(coalesce(par_last_movement_tran_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					to_char(coalesce(par_last_movement_system_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_hkid,'NULL-par_hkid') || '#@#' || 
					coalesce(par_patient_key,'NULL-par_patient_key') || '#@#' || 
					coalesce(par_name,'NULL-par_name') || '#@#' || 
					coalesce(par_sex,'NULL-par_sex') || '#@#' ||  
					to_char(coalesce(par_dob,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_exact_dob_flag,'NULL-par_exact_dob_flag') || '#@#' || 
					coalesce(par_ccc1,'NULL-par_ccc1') || '#@#' || 
					coalesce(par_ccc2,'NULL-par_ccc2') || '#@#' || 
					coalesce(par_ccc3,'null-par_ccc3') || '#@#' || 
					coalesce(par_ccc4,'NULL-par_ccc4') || '#@#' || 
					coalesce(par_ccc5,'null-par_ccc5') || '#@#' || 
					coalesce(par_ccc6,'null-par_ccc6') || '#@#' || 
					coalesce(par_marital_status,'NULL-par_marital_status') || '#@#' || 
					coalesce(par_race_code,'null-par_race_code') || '#@#' || 
					coalesce(par_other_document_no,'null-par_other_document_no') || '#@#' || 
					coalesce(par_medical_record_number,'NULL-par_medical_record_number') || '#@#' || 
					coalesce(par_religion_code,'null-par_religion_code') || '#@#' || 
					coalesce(par_room,'null-par_room') || '#@#' || 
					coalesce(par_floor,'NULL-par_floor') || '#@#' || 
					coalesce(par_block,'NULL-par_block') || '#@#' || 
					coalesce(par_district_code,'NULL-par_district_code') || '#@#' || 
					coalesce(par_building,'NULL-par_building') || '#@#' || 
					coalesce(par_phone1,'null-par_phone1') || '#@#' || 
					coalesce(par_phone2,'NULL-par_phone2') || '#@#' || 
					coalesce(par_address_indicator,'null-par_address_indicator') || '#@#' || 
					coalesce(par_mobile_phone,'null-par_mobile_phone') || '#@#' || 
					coalesce(par_sms_language,'NULL-par_sms_language') || '#@#' || 
					coalesce(par_death_indicator,'null-par_death_indicator') || '#@#' || 
					to_char(coalesce(par_death_date,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_pmi_access_code::text,'null-par_pmi_access_code') || '#@#' || 
					coalesce(pas_return_code::text,'NULL-return_code') || ']';
--                    insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CANCEL-COMMIT',gjp_text);
--                	commit;
      end;

    <<sp_return>>
    begin
	    
	    /*
	    	        gjp_text := '[' || coalesce(par_hospital_code,'NULL-par_hospital_code') || '#@#' || 
					coalesce(par_user_id,'NULL-par_user_id') || '#@#' || 
					coalesce(par_transaction_type,'NULL-par_transaction_type') || '#@#' || 
					coalesce(par_case_no,'NULL-par_case_no') || '#@#' || 
					to_char(coalesce(par_admission_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_source_indicator,'NULL-par_source_indicator') || '#@#' || 
					coalesce(par_source_code,'NULL-par_source_code') || '#@#' || 
					coalesce(par_pay_code,'NULL-par_pay_code') || '#@#' || 
					coalesce(par_discharge_code,'NULL-par_discharge_code') || '#@#' || 
					to_char(coalesce(par_discharge_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_discharge_destination,'NULL-par_discharge_destination') || '#@#' || 
					coalesce(par_movement_count::text,'NULL-par_movement_count') || '#@#' || 
					coalesce(par_security_count::text,'NULL-par_security_count') || '#@#' || 
					coalesce(par_case_access_code::text,'NULL-par_case_access_code') || '#@#' || 
					coalesce(par_ae_case_type,'NULL-par_ae_case_type') || '#@#' || 
					coalesce(par_ambulance_no,'NULL-par_ambulance_no') || '#@#' || 
					coalesce(par_dba_flag,'NULL-par_dba_flag') || '#@#' ||  
					to_char(coalesce(par_follow_up_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_labour_case,'NULL-par_labour_case') || '#@#' || 
					coalesce(par_police_case, 'NULL-par_police_case') || '#@#' || 
					coalesce(par_ward_code,'NULL-par_ward_code') || '#@#' || 
					coalesce(par_ward_class,'NULL-par_ward_class') || '#@#' || 
					coalesce(par_specialty,'NULL-par_specialty') || '#@#' || 
					coalesce(par_bed_no,'NULL-par_bed_no') || '#@#' || 
					coalesce(par_treatment_location,'NULL-par_treatment_location') || '#@#' || 
					to_char(coalesce(par_last_movement_tran_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					to_char(coalesce(par_last_movement_system_datetime,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_hkid,'NULL-par_hkid') || '#@#' || 
					coalesce(par_patient_key,'NULL-par_patient_key') || '#@#' || 
					coalesce(par_name,'NULL-par_name') || '#@#' || 
					coalesce(par_sex,'NULL-par_sex') || '#@#' ||  
					to_char(coalesce(par_dob,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_exact_dob_flag,'NULL-par_exact_dob_flag') || '#@#' || 
					coalesce(par_ccc1,'NULL-par_ccc1') || '#@#' || 
					coalesce(par_ccc2,'NULL-par_ccc2') || '#@#' || 
					coalesce(par_ccc3,'null-par_ccc3') || '#@#' || 
					coalesce(par_ccc4,'NULL-par_ccc4') || '#@#' || 
					coalesce(par_ccc5,'null-par_ccc5') || '#@#' || 
					coalesce(par_ccc6,'null-par_ccc6') || '#@#' || 
					coalesce(par_marital_status,'NULL-par_marital_status') || '#@#' || 
					coalesce(par_race_code,'null-par_race_code') || '#@#' || 
					coalesce(par_other_document_no,'null-par_other_document_no') || '#@#' || 
					coalesce(par_medical_record_number,'NULL-par_medical_record_number') || '#@#' || 
					coalesce(par_religion_code,'null-par_religion_code') || '#@#' || 
					coalesce(par_room,'null-par_room') || '#@#' || 
					coalesce(par_floor,'NULL-par_floor') || '#@#' || 
					coalesce(par_block,'NULL-par_block') || '#@#' || 
					coalesce(par_district_code,'NULL-par_district_code') || '#@#' || 
					coalesce(par_building,'NULL-par_building') || '#@#' || 
					coalesce(par_phone1,'null-par_phone1') || '#@#' || 
					coalesce(par_phone2,'NULL-par_phone2') || '#@#' || 
					coalesce(par_address_indicator,'null-par_address_indicator') || '#@#' || 
					coalesce(par_mobile_phone,'null-par_mobile_phone') || '#@#' || 
					coalesce(par_sms_language,'NULL-par_sms_language') || '#@#' || 
					coalesce(par_death_indicator,'null-par_death_indicator') || '#@#' || 
					to_char(coalesce(par_death_date,current_timestamp), 'YYYY-MM-DD HH24:MI:SS.MS') || '#@#' || 
					coalesce(par_pmi_access_code::text,'null-par_pmi_access_code') || '#@#' || 
					coalesce(return_code::text,'NULL-return_code') || ']';
                    insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CANCEL',gjp_text);
        */
        SELECT
            0
            INTO var_return_code;
        /* --jConnect 7 upgrade handling: begin tran in Sybase instead of Java */    
        /* --Get current system datetime */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_system_datetime;
        /* --Handle case_type like hasp_adt_function for better data integrity */
        IF par_transaction_type = '200' THEN
            SELECT
                'A'
                INTO var_case_type;
        ELSE
            SELECT
                'I'
                INTO var_case_type;
        END IF;
        /* --Run "set nocount on" to suppress the selected string from hasp_adt_function, but in vain */
        /* --set nocount on */
        /* --Call hasp_adt_function */
       raise notice 'begin hasp_adt_function';
        --call gjp_log_record('CALL_hasp_adt_function BEGEIN','[web_hasp_cancel_admission:170]');
        CALL hasp_adt_function(par_hosp_code := par_hospital_code, "par_System_datetime" := var_system_datetime, "par_Type" := par_transaction_type, "par_HKID" := par_hkid, 
        "par_Name" := null::bpchar, "par_Sex" := NULL::bpchar, "par_DOB" := null::TIMESTAMP WITHOUT TIME ZONE, "par_Exact_DOB_flag" := NULL::bpchar, "par_CCC_1" := NULL::bpchar, "par_CCC_2" := NULL::bpchar, 
        "par_CCC_3" := NULL::bpchar, "par_CCC_4" := NULL::bpchar, "par_CCC_5" := NULL::bpchar, "par_CCC_6" := NULL::bpchar, "par_Marital_status" := null::bpchar, "par_Race_code" := null::bpchar, 
        "par_Other_document_no" := null::bpchar, "par_Medical_record_number" := null::bpchar, "par_Building" := NULL::bpchar, "par_Room" := NULL::bpchar, "par_Floor" := NULL::bpchar, "par_Block" := NULL::bpchar, 
        "par_District_code" := NULL::bpchar, "par_Religion_code" := NULL::bpchar, "par_phone1" := NULL::bpchar, "par_phone2" := NULL::bpchar, "par_address_indicator" := NULL::bpchar, 
        "par_mobile_phone" := NULL::bpchar, "par_sms_language" := NULL::bpchar, "par_Death_indicator" := NULL::bpchar, "par_Death_date" := NULL::timestamp without time zone, "par_T_PRK" := par_patient_key::bpchar, 
        "par_NOK_priority" := NULL::integer, "par_NOK_name" := NULL::bpchar, "par_NOK_HKID" := NULL::bpchar, "par_NOK_relation_code" := NULL::bpchar, "par_NOK_building" := NULL::bpchar, "par_NOK_room" := NULL::bpchar,
        "par_NOK_floor" := NULL::bpchar, "par_NOK_block" := NULL::bpchar, "par_NOK_district_code" := NULL::bpchar, "par_NOK_phone1" := NULL::bpchar, "par_NOK_phone2" := NULL::bpchar, 
        "par_NOK_address_indicator" := NULL::bpchar, "par_NOK_mobile_phone" := NULL::bpchar, "par_NOK_sms_language" := NULL::bpchar, "par_Case_no" := par_case_no, "par_Admission_datetime" := NULL::timestamp without time zone, 
        "par_Source_indicator" := NULL::bpchar, "par_Source_code" := NULL::bpchar, "par_Pay_code" := NULL::bpchar, "par_Discharge_code" := NULL::bpchar, "par_Discharge_datetime" := NULL::timestamp without time zone, "par_Destination_code" := NULL::bpchar, 
        "par_Case_type" := NULL::bpchar, "par_Movement_count" := NULL::integer, "par_Security_count" := NULL::integer, "par_Case_access_code" := NULL::integer, "par_PMI_access_code" := NULL::integer, "par_Ambulance_no" := NULL::bpchar, 
        "par_Police_case" := NULL::bpchar, "par_Labour_case" := NULL::bpchar, "par_AE_case_type" := NULL::bpchar, "par_DBA_flag" := NULL::bpchar, "par_Follow_up_datetime" := NULL::timestamp without time zone, "par_Ward_code" := par_ward_code, 
        "par_Specialty_code" := par_specialty, "par_Bed_no" := par_bed_no, "par_Ward_class" := par_ward_class, "par_Transfer_datetime" := NULL::timestamp without time zone, "par_Old_name" := NULL::bpchar, "par_Old_HKID" := NULL::bpchar, 
        "par_Old_sex" := NULL::bpchar, "par_Old_DOB" := NULL::timestamp without time zone, "par_Old_ward_class" := NULL::bpchar, "par_Old_ward_code" := NULL::bpchar, "par_Old_specialty_code" := NULL::bpchar, "par_Old_bed_no" := NULL::bpchar, 
        "par_User_ID" := par_user_id, "par_Doctor_code" := NULL::bpchar, "par_Old_doctor_code" := NULL::bpchar, "par_Old_T_PRK" := NULL::bpchar, "par_PP_code" := NULL::bpchar, "par_Last_update_datetime" := NULL::timestamp without time zone, 
        "par_Terminal_id" := NULL::bpchar, "par_Old_NOK_name" := NULL::bpchar, "par_Document_flag" := NULL::bpchar, par_eh_code := NULL::bpchar, par_source_hosp_code := NULL::bpchar, par_source_case_no := NULL::bpchar, 
        par_hkic_symbol := NULL::bpchar, par_hkic_symbol_clear := 'N'::bpchar, pas_return_code => var_return_code);
        /* --set nocount off */
--       commit;

       raise notice '[61]web_hasp_cancel_admission';
       raise notice 'end hasp_adt_function=>%',var_return_code;
--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_hasp_adt_function END','[web_hasp_cancel_admission:194]');

        IF var_return_code != 0 THEN
            BEGIN
                /* --Below shows how PB handles 7205 error in f_adt_function: */
                /* -- */
                /* --// add checking for sqldbcode, if 7205 means HKPMI server is down, proceed as normal */
                /* --//If gsql_adt_01.SqlCode = 0  or gsql_adt_01.SQLDBCode = 7205 Then */
                /* --If gsql_adt_01.SqlCode = 0 or & */
                /* --(gsql_adt_01.SQLDBCode = 7205 and (Left(as_hkid, 1) ='U' or lb_local_patient)) Then */
                /* -- */
                /* --In Cancellation of Admission, the target patient must exist in cpi_patient */
                /* --(i.e. must be a local patient instead of a hkpmi patient), so "lb_local_patient" is always true, */
                /* --so below only need to check @@error = 7205 without handling (Left(as_hkid, 1) ='U' or lb_local_patient)) */
                /* -- */
                /* --Later found cpi..cpi_cancel_admission would not call HKPMI, so this 7205 error would happen only */
                /* --in Registration functions, so remark below 7205 handling */
                /* --if @@error != 7205 */
                /* --begin */
                SELECT
                    29999
                    INTO var_return_code;
                SELECT
                    'Error when calling hasp_adt_function'
                    INTO var_error_msg;
                EXIT sp_return;
                /* --end */
            END;
        END IF;
       raise notice '[90]web_hasp_cancel_admission';
        /* --End - Call hasp_adt_function */
        /* --Insert Transaction_log */

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_hasp_insert_transaction_log BGN','[web_hasp_cancel_admission:228]');

        CALL hasp_insert_transaction_log(par_hosp => par_hospital_code, "par_System_datetime" => var_system_datetime, "par_Case_no" => par_case_no, "par_From_ward_code" => par_ward_code, "par_From_treatment_location" => par_treatment_location, "par_From_class" => par_ward_class, "par_From_specialty_code" => par_specialty, "par_From_bed" => par_bed_no, "par_To_ward_code" => NULL, "par_To_treatment_location" => NULL, "par_To_class" => NULL, "par_To_specialty_code" => NULL, "par_To_bed" => NULL, "par_Transaction_datetime" => par_last_movement_tran_datetime, /* --this is admission datetime */ "par_Transaction_type" => par_transaction_type, "par_Post_datetime" => NULL, "par_User_ID" => par_user_id, "par_Post_flag" => 'Y', "par_Prev_system_datetime" => par_last_movement_system_datetime, pas_return_code=>var_return_code);
	 /* --this is admission system datetime */
raise notice '[95]web_hasp_cancel_admission';

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_hasp_insert_transaction_log END','[web_hasp_cancel_admission:235]');

        IF var_return_code != 0 THEN
            BEGIN
                SELECT
                    29999
                    INTO var_return_code;
                SELECT
                    'Fail to insert Transaction_log'
                    INTO var_error_msg;
                EXIT sp_return;
            END;
        END IF;
       raise notice '[107]web_hasp_cancel_admission';
        /* --End - Insert Transaction_log */
        /* --Insert Event_log */
        /* --(copied from hasp_delete_pmi on 201708) */

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_hasp_insert_event_log BGN','[web_hasp_cancel_admission:254]');

        CALL hasp_insert_event_log(par_hosp => par_hospital_code, "par_System_datetime" => var_system_datetime, "par_Type" => par_transaction_type, "par_HKID" => par_hkid, "par_Name" => par_name, "par_Sex" => par_sex, "par_DOB" => par_dob, "par_Exact_DOB_flag" => par_exact_dob_flag, "par_CCC_1" => par_ccc1, "par_CCC_2" => par_ccc2, "par_CCC_3" => par_ccc3, "par_CCC_4" => par_ccc4, "par_CCC_5" => par_ccc5, "par_CCC_6" => par_ccc6, "par_Martial_status" => par_marital_status, "par_Race_code" => par_race_code, "par_Other_document_no" => par_other_document_no, "par_Medical_record_number" => par_medical_record_number, "par_Building" => par_building, "par_Room" => par_room, "par_Floor" => par_floor, "par_Block" => par_block, "par_District_code" => par_district_code, "par_Religion_code" => par_religion_code, "par_phone1" => par_phone1, "par_phone2" => par_phone2, "par_address_indicator" => par_address_indicator, "par_mobile_phone" => par_mobile_phone, "par_sms_language" => par_sms_language, "par_Death_indicator" => par_death_indicator, "par_Death_date" => par_death_date, "par_T_PRK" => par_patient_key, "par_NOK_name" => NULL, "par_NOK_HKID" => NULL, "par_NOK_relation_code" => NULL, "par_NOK_building" => NULL, "par_NOK_room" => NULL, "par_NOK_floor" => NULL, "par_NOK_block" => NULL, "par_NOK_district_code" => NULL, "par_NOK_phone1" => NULL, "par_NOK_phone2" => NULL, "par_NOK_address_indicator" => NULL, "par_NOK_mobile_phone" => NULL, "par_NOK_sms_language" => NULL, "par_Case_no" => par_case_no, "par_Admission_datetime" => par_admission_datetime, "par_Source_indicator" => par_source_indicator, "par_Source_code" => par_source_code, "par_Pay_code" => par_pay_code, "par_Discharge_code" => par_discharge_code, "par_Discharge_datetime" => par_discharge_datetime, "par_Destination_code" => par_discharge_destination, "par_Case_type" => var_case_type, "par_Movement_count" => par_movement_count, "par_Security_count" => par_security_count, "par_Case_access_code" => par_case_access_code, "par_PMI_access_code" => par_pmi_access_code, "par_Ambulance_no" => par_ambulance_no, "par_Police_case" => par_police_case, "par_Labour_case" => par_labour_case, "par_AE_case_type" => par_ae_case_type, "par_DBA_flag" => par_dba_flag, "par_Follow_up_datetime" => par_follow_up_datetime, "par_Ward_code" => par_ward_code, "par_Specialty_code" => par_specialty, "par_Bed_no" => par_bed_no, "par_Ward_class" => par_ward_class, "par_Old_name" => NULL, "par_Old_HKID" => NULL, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => NULL, "par_Old_ward_code" => NULL, "par_Old_specialty_code" => NULL, "par_Old_bed_no" => NULL, "par_User_ID" => par_user_id, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL, pas_return_code =>  var_return_code);
raise notice '[112]web_hasp_cancel_admission';

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_hasp_insert_event_log END','[web_hasp_cancel_admission:260]');

        IF var_return_code != 0 THEN
            begin
	            raise notice '[115]web_hasp_cancel_admission';
                /* --if the above SP really got error, e.g. error happened when updating table, */
                /* --then most likely the original error message would show instead of below error message, */
                /* --because Sybase raiserror obeys first-in-first-out rule. */
                /* --Below error message I think is to cater a very rare scenario: the above SP returns a */
                /* --non-zero return code due to a checked error but doesn't fire raiserror due to programmer's fault */
                SELECT
                    29999
                    INTO var_return_code;
                SELECT
                    'Fail to insert Event_log'
                    INTO var_error_msg;
                EXIT sp_return;
            END;
        END IF;
        /* --End - Insert Event_log */
--		EXCEPTION
--			WHEN OTHERS then
--				begin
--				GET STACKED DIAGNOSTICS error_code = RETURNED_SQLSTATE, message = MESSAGE_TEXT;
--				if message = 'rollback' then
--					EXIT sp_return;
--				end if;
--				RAISE EXCEPTION '%', message USING ERRCODE = error_code;
--				raise notice '[274]err_msg=>%',sqlerrm;
--				end;
    END;
raise notice '[279]web_hasp_cancel_admission';
    IF (var_return_code <> 0) THEN
        BEGIN
            /* --no worry raiserror here would override 2nd SP's raiserror or system error due to, say, updating table incorrectly, */
            /* --because Sybase raiserror obeys first-in-first-out rule. */
            RAISE EXCEPTION '%', var_error_msg USING ERRCODE = var_return_code;
        END;
    END IF;
    /* --@return_code is only useful in PB (legacy). PB would trigger rollback if @return_code is not 0 */
    /* --@return_code is not used in Java, as JDBC would throw exception upon Sybase raiserror (see SPManager.java), */
    /* --and PASServiceFacadeBean.java triggers rollback in case of any exception. */
    /* --That might be why SPManager.java doesn't catch and process @return_code at all. */
    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_cancel_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
