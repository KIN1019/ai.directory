-- DROP PROCEDURE hasp_insert_event_log(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_insert_event_log(INOUT pas_return_code integer, IN par_hosp character varying, IN "par_System_datetime" timestamp without time zone, IN "par_Type" character varying, IN "par_HKID" character varying, IN "par_Name" character varying, IN "par_Sex" character varying, IN "par_DOB" timestamp without time zone, IN "par_Exact_DOB_flag" character varying, IN "par_CCC_1" character varying, IN "par_CCC_2" character varying, IN "par_CCC_3" character varying, IN "par_CCC_4" character varying, IN "par_CCC_5" character varying, IN "par_CCC_6" character varying, IN "par_Martial_status" character varying, IN "par_Race_code" character varying, IN "par_Other_document_no" character varying, IN "par_Medical_record_number" character varying, IN "par_Building" character varying, IN "par_Room" character varying, IN "par_Floor" character varying, IN "par_Block" character varying, IN "par_District_code" character varying, IN "par_Religion_code" character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN "par_Death_indicator" character varying, IN "par_Death_date" timestamp without time zone, IN "par_T_PRK" character varying, IN "par_NOK_name" character varying, IN "par_NOK_HKID" character varying, IN "par_NOK_relation_code" character varying, IN "par_NOK_building" character varying, IN "par_NOK_room" character varying, IN "par_NOK_floor" character varying, IN "par_NOK_block" character varying, IN "par_NOK_district_code" character varying, IN "par_NOK_phone1" character varying, IN "par_NOK_phone2" character varying, IN "par_NOK_address_indicator" character varying, IN "par_NOK_mobile_phone" character varying, IN "par_NOK_sms_language" character varying, IN "par_Case_no" character varying, IN "par_Admission_datetime" timestamp without time zone, IN "par_Source_indicator" character varying, IN "par_Source_code" character varying, IN "par_Pay_code" character varying, IN "par_Discharge_code" character varying, IN "par_Discharge_datetime" timestamp without time zone, IN "par_Destination_code" character varying, IN "par_Case_type" character varying, IN "par_Movement_count" integer, IN "par_Security_count" integer, IN "par_Case_access_code" integer, IN "par_PMI_access_code" integer, IN "par_Ambulance_no" character varying, IN "par_Police_case" character varying, IN "par_Labour_case" character varying, IN "par_AE_case_type" character varying, IN "par_DBA_flag" character varying, IN "par_Follow_up_datetime" timestamp without time zone, IN "par_Ward_code" character varying, IN "par_Specialty_code" character varying, IN "par_Bed_no" character varying, IN "par_Ward_class" character varying, IN "par_Old_name" character varying, IN "par_Old_HKID" character varying, IN "par_Old_sex" character varying, IN "par_Old_DOB" timestamp without time zone, IN "par_Old_ward_class" character varying, IN "par_Old_ward_code" character varying, IN "par_Old_specialty_code" character varying, IN "par_Old_bed_no" character varying, IN "par_User_ID" character varying, IN "par_Doctor_code" character varying, IN "par_Old_doctor_code" character varying, IN "par_Old_T_PRK" character varying, IN "par_MRT_indicator" character varying DEFAULT NULL::bpchar, IN "par_Upload_status" character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
/* added by WL for hpi */ /* temp. set to NULL */ /* temp. set to NULL */
/* Return values   Meaning */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_t_ward_code CHAR(04);
    var_t_class CHAR(1);
    var_t_bed CHAR(5);
    var_t_specialty_code CHAR(4);
    var_t_type CHAR(03);
begin
    <<error>>
    begin
	   
        /* @MRT_indicator  char(01) */
        /* ** Due to MRT indicator not implement in ADT yet, so ** */
        /* ** assign null value to it first by Winnie ** */
        /* select @MRT_indicator = NULL */
        /* -- added by WL on 14 Feb 2000 --- */
	    
        IF "par_Upload_status" is NULL THEN
            SELECT
                'N'
                INTO "par_Upload_status";
        END IF;

        WHILE 1 = 1 loop
	     

            BEGIN
                INSERT INTO Event_log (hospital_code, /* add by WL for HPI */ system_datetime, type, hkid, name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, martial_status, race_code, other_document_no, medical_record_number, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, t_prk, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, pay_code, discharge_code, discharge_datetime, destination_code, case_type, movement_count, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, bed_no, ward_class, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, user_id, upload_status, doctor_code, old_doctor_code, old_t_prk, mrt_indicator)
                VALUES (par_hosp, /* add by WL for HPI */ "par_System_datetime", "par_Type", "par_HKID", "par_Name", "par_Sex", "par_DOB", "par_Exact_DOB_flag", "par_CCC_1", "par_CCC_2", "par_CCC_3", "par_CCC_4", "par_CCC_5", "par_CCC_6", "par_Martial_status", "par_Race_code", "par_Other_document_no", "par_Medical_record_number", "par_Building", "par_Room", "par_Floor", "par_Block", "par_District_code", "par_Religion_code", "par_phone1", "par_phone2", "par_address_indicator", "par_mobile_phone", "par_sms_language", "par_Death_indicator", "par_Death_date", "par_T_PRK", "par_NOK_name", "par_NOK_HKID", "par_NOK_relation_code", "par_NOK_building", "par_NOK_room", "par_NOK_floor", "par_NOK_block", "par_NOK_district_code", "par_NOK_phone1", "par_NOK_phone2", "par_NOK_address_indicator", "par_NOK_mobile_phone", "par_NOK_sms_language", "par_Case_no", "par_Admission_datetime", "par_Source_indicator", "par_Source_code", "par_Pay_code", "par_Discharge_code", "par_Discharge_datetime", "par_Destination_code", "par_Case_type", "par_Movement_count", "par_Security_count", "par_Case_access_code", "par_PMI_access_code", "par_Ambulance_no", "par_Police_case", "par_Labour_case", "par_AE_case_type", "par_DBA_flag", "par_Follow_up_datetime", "par_Ward_code", "par_Specialty_code", "par_Bed_no", "par_Ward_class", "par_Old_name", "par_Old_HKID", "par_Old_sex", "par_Old_DOB", "par_Old_ward_class", "par_Old_ward_code", "par_Old_specialty_code", "par_Old_bed_no", "par_User_ID",
                /* --'N'                    , */
                "par_Upload_status", "par_Doctor_code", "par_Old_doctor_code", "par_Old_T_PRK", "par_MRT_indicator");
                raise notice 'hasp_insert_event_log[INSERT]Event_log,hkid=%',"par_HKID";  
               var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        raise notice '[hasp_insert_event_log:35]err_msg=>%',sqlerrm;
                        var_error := 1;
            END;

            IF var_error != 0 THEN
                BEGIN
                    EXIT error;
                END;
            END IF;

            IF "par_Type" = '220' THEN
                BEGIN
                    SELECT
                        '221',
                        /* @System_datetime = getdate(), */
                        3 * INTERVAL '1 millisecond' + "par_System_datetime"::TIMESTAMP, "par_Old_ward_code", "par_Old_ward_class", "par_Old_bed_no", "par_Old_specialty_code"
                        INTO "par_Type", "par_System_datetime", var_t_ward_code, var_t_class, var_t_bed, var_t_specialty_code;
                    SELECT
                        "par_Ward_code", "par_Ward_class", "par_Bed_no", "par_Specialty_code"
                        INTO "par_Old_ward_code", "par_Old_ward_class", "par_Old_bed_no", "par_Old_specialty_code";
                    SELECT
                        var_t_ward_code, var_t_class, var_t_bed, var_t_specialty_code
                        INTO "par_Ward_code", "par_Ward_class", "par_Bed_no", "par_Specialty_code";
                    CONTINUE;
                END;
            ELSE
                IF "par_Type" = '140' THEN
                    BEGIN
                        SELECT
                            '141',
                            /* @System_datetime = getdate(), */
                            3 * INTERVAL '1 millisecond' + "par_System_datetime"::TIMESTAMP, "par_Old_ward_code", "par_Old_ward_class", "par_Old_bed_no", "par_Old_specialty_code"
                            INTO "par_Type", "par_System_datetime", var_t_ward_code, var_t_class, var_t_bed, var_t_specialty_code;
                        SELECT
                            "par_Ward_code", "par_Ward_class", "par_Bed_no", "par_Specialty_code"
                            INTO "par_Old_ward_code", "par_Old_ward_class", "par_Old_bed_no", "par_Old_specialty_code";
                        SELECT
                            var_t_ward_code, var_t_class, var_t_bed, var_t_specialty_code
                            INTO "par_Ward_code", "par_Ward_class", "par_Bed_no", "par_Specialty_code";
                        CONTINUE;
                    END;
                ELSE
                    EXIT;
                END IF;
            END IF;
        END LOOP;
        pas_return_code := 0;
        RETURN;
    END;
    /* rollback transaction */
    /* return 99 */
    pas_return_code := var_error;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_insert_event_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
