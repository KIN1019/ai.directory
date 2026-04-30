-- DROP PROCEDURE hpi.hasp_discharge_ae_case(inout int4, in varchar, in varchar, in timestamp, in timestamp, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_discharge_ae_case(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_ae_case_no character varying, IN par_ae_discharge_datetime timestamp without time zone, IN par_system_datetime timestamp without time zone, IN par_user_id character varying, IN par_discharge_code character varying, IN par_destination character varying, IN par_death_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* --- add hospital code as input parm on 29 Jul 99--- */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    /* -- remarked by WL on 29 Jul 99 --- */
    
    /* --@hospital_code  			char(03), */
    var_errarg VARCHAR(80);
    var_transaction_type CHAR(03);
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_hkid CHAR(12);
    var_pay_code CHAR(03);
    var_case_type CHAR(01);
    var_case_movement_count INTEGER;
    var_security_count INTEGER;
    var_case_access_code INTEGER;
    var_timestamp varchar(8000);
    var_disc_code CHAR(01);
    var_temp_bit CHAR(32);
    var_temp_int INTEGER;
    var_temp_val INTEGER;
    var_last_upd_pmi_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_security_flag CHAR(1);
    var_tx_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_last_update_hosp CHAR(03);
    var_last_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
    var_pmi_name CHAR(48);
    var_sex CHAR(1);
    var_ccc_1 CHAR(5);
    var_ccc_2 CHAR(5);
    var_ccc_3 CHAR(5);
    var_ccc_4 CHAR(5);
    var_ccc_5 CHAR(5);
    var_ccc_6 CHAR(5);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag CHAR(1);
    var_marital_status CHAR(1);
    var_race_code CHAR(2);
    var_other_document_no CHAR(12);
    var_medical_record_number CHAR(8);
    var_pmi_building CHAR(47);
    var_pmi_room CHAR(5);
    var_pmi_floor CHAR(2);
    var_pmi_block CHAR(2);
    var_pmi_district_code CHAR(5);
    var_religion_code CHAR(3);
    var_pmi_phone1 CHAR(10);
    var_pmi_phone2 CHAR(10);
    var_pmi_address_indicator CHAR(4);
    var_pmi_mobile_phone CHAR(10);
    var_pmi_sms_language CHAR(4);
    var_death_indicator CHAR(1);
    var_pmi_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_t_prk CHAR(08);
    var_pmi_access_code INTEGER;
    var_movement_count INTEGER;
    var_ward_code CHAR(4);
    var_treatment_location CHAR(4);
    var_bed_no CHAR(5);
    var_specialty_code CHAR(4);
    var_ward_class CHAR(1);

BEGIN
    <<error>>
    BEGIN
        /* ----- Added by PP on 20040223 ----- */
        /* -- Remarked by WL on 29 Jul 99 --- */
        
        /*
        select @hospital_code = Hospital_code
          from Hospital
        
        if @@rowcount != 1
        begin
            raiserror 200012, "Read", "Hospital_code", "record"
            select @retcode = 200012
            goto error
        end
        */
        SELECT
            CONCAT('33', par_discharge_code)
            INTO var_transaction_type;
        /* --- add hospital code for HPI by WL on 29 Jul 99 -- */
        SELECT
            Admission_datetime, HKID, Pay_code, Case_type, Movement_count, Security_count, Access_code, Discharge_code, timestamp
            INTO var_admission_datetime, var_hkid, var_pay_code, var_case_type, var_case_movement_count, var_security_count, var_case_access_code, var_disc_code, var_timestamp
            FROM Case_view
            WHERE Case_no = par_ae_case_no AND Hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount != 1 THEN
            BEGIN
                RAISE EXCEPTION '% % % ', 'Read', 'Case', par_ae_case_no USING ERRCODE := '200012';
                SELECT
                    200012
                    INTO var_retcode;
                RAISE exception '';
            END;
        END IF;
        SELECT
            Name, Sex, CCC_1, CCC_2, CCC_3, CCC_4, CCC_5, CCC_6, DOB, Exact_DOB_flag, Marital_status, Race_code, Other_document_no, Medical_record_number, Building, Room, Floor, Block, District_code, Religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, Death_indicator, Death_date, T_PRK, Access_code, System_datetime
            INTO var_pmi_name, var_sex, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_dob, var_exact_dob_flag, var_marital_status, var_race_code, var_other_document_no, var_medical_record_number, var_pmi_building, var_pmi_room, var_pmi_floor, var_pmi_block, var_pmi_district_code, var_religion_code, var_pmi_phone1, var_pmi_phone2, var_pmi_address_indicator, var_pmi_mobile_phone, var_pmi_sms_language, var_death_indicator, var_pmi_death_date, var_t_prk, var_pmi_access_code, var_last_upd_pmi_dtm
            FROM PMI
            WHERE PMI_hospital_code = par_hospital_code AND HKID = var_hkid;

        IF var_disc_code != NULL THEN
            BEGIN
                RAISE EXCEPTION '% ', par_ae_case_no USING ERRCODE := '200029';
                SELECT
                    200026
                    INTO var_retcode;
                RAISE exception '';
            END;
        END IF;

        BEGIN
            IF par_discharge_code = '1' THEN
                BEGIN
                    /*
                    update PMI
                    set Death_indicator = 'Y',
                        Death_date = @ae_discharge_datetime,
                        System_datetime = @system_datetime,
                        User_ID = @user_id
                    where HKID = @hkid
                    */
                    IF par_death_date IS NULL THEN
                        SELECT
                            par_ae_discharge_datetime
                            INTO par_death_date;
                    END IF;
                    SELECT
                        'Y'
                        INTO var_death_indicator;
                END;
            END IF;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                RAISE exception '';
            END;
        END IF;
        /* -----------20140401 ------------- */
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support SAVE TRAN adt_discharge command. Perform a manual conversion.]
        save transaction adt_discharge
        */
        /* --------------------------------- */
        /* ----- check the security flag is set on or not --- */
        IF par_discharge_code <> '9' THEN
            BEGIN
                SELECT
                    'YNNNNNNNNNYYYNNYYYNNNNNNNNNNNNNN'
                    INTO var_temp_bit;
                CALL hasp_get_int_by_bin(pas_return_code, var_temp_bit, var_temp_int);
                SELECT
                    var_temp_int & var_pmi_access_code
                    INTO var_temp_val;

                IF var_temp_val > 0 THEN /* not set on */
                    SELECT
                        'N'
                        INTO var_security_flag;
                ELSE
                    /* set on */
                    SELECT
                        'Y'
                        INTO var_security_flag;
                END IF;
                /* --- automatic set off secufity flag if it is on --- */

                IF EXISTS (SELECT
                    *
                    FROM cpi_access_changed
                    WHERE patient_key = var_t_prk) THEN
                    BEGIN
                        SELECT
                            MAX(update_dtm)
                            INTO var_last_update_dtm
                            FROM cpi_access_changed
                            WHERE patient_key = var_t_prk;
                        SELECT
                            update_hospital
                            INTO var_last_update_hosp
                            FROM cpi_access_changed
                            WHERE original_hkid = var_hkid AND update_dtm = var_last_update_dtm;
                    END;
                ELSE
                    SELECT
                        '   '
                        INTO var_last_update_hosp;
                END IF;

                IF ((var_security_flag = 'Y') AND (par_hospital_code = var_last_update_hosp)) THEN
                    BEGIN
                        SELECT
                            var_pmi_access_code | var_temp_int
                            INTO var_pmi_access_code;
                        SELECT
                            timestamp_convert(localtimestamp)
                            INTO var_tx_dtm;
                        CALL hasp_update_access(pas_return_code, par_hospital_code, var_hkid, var_t_prk, var_pmi_access_code, var_tx_dtm, par_user_id, var_last_upd_pmi_dtm, var_retcode);

                        IF var_retcode <> 0 THEN
                            BEGIN
                                SELECT
                                    'Cannot Update Access Code in PMI table'
                                    INTO var_error_msg;
                                SELECT
                                    200026
                                    INTO var_retcode;
                                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := '200026';
                                RAISE exception '';
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* ----- check the confidentiality flag is set on or not --- */
        /* ---- remove local update by WL on 29 Jul 99 --- */
        /***** update MRT_indicator to null by Winnie ****/
        /*
        
            update Case
              set Discharge_code     = @discharge_code,
                  Discharge_datetime = @ae_discharge_datetime,
                  Destination_code   = @destination,
                  Movement_count     = @case_movement_count + 1,
                  System_datetime    = @system_datetime,
                  User_ID            = @user_id,
        			 MRT_indicator 	  = null
            where Case_no = @ae_case_no and
        			 timestamp = @timestamp
        
            select @error = @@error, @rowcount = @@rowcount
            if @error != 0
            begin
               goto error
            end
        
            if @rowcount != 1
            begin
                raiserror 200026, "Row changed between retrieved and update, please retry again"
                select @retcode = 200026
                goto error
            end
        */
        /* -- add hospital code by WL on 29 Jul 99-- */
        SELECT
            Movement_count, Ward_code, Treatment_location, Bed_no, Specialty_code, Ward_class
            INTO var_movement_count, var_ward_code, var_treatment_location, var_bed_no, var_specialty_code, var_ward_class
            FROM Movement
            WHERE Case_no = par_ae_case_no AND Movement_count = var_case_movement_count AND Hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount != 1 THEN
            BEGIN
                SELECT
                    CONCAT(par_ae_case_no, ' ', CAST (var_case_movement_count AS CHAR(10)))
                    INTO var_errarg;
                RAISE EXCEPTION '% % % ', 'Read', 'Movement', var_errarg USING ERRCODE := '200012';
                SELECT
                    200012
                    INTO var_retcode;
                RAISE exception '';
            END;
        END IF;
        /* -- remove local update by WL on 29 Jul 1999 --- */
        
        /*
        insert Movement
              (Case_no,
               Movement_count,
               Ward_code,
               Bed_no,
               Specialty_code,
               Ward_class,
               Movement_type,
               Movement_datetime,
               Treatment_location,
               System_datetime,
               User_ID)
        values(@ae_case_no,
               @case_movement_count + 1,
               @ward_code,
               @bed_no,
               @specialty_code,
               @ward_class,
               "D",
               @ae_discharge_datetime,
               @treatment_location,
               @system_datetime,
               @user_id)
        
        Delete Ward_list
          where Case_no = @ae_case_no
        
        select @error = @@error
        if @error != 0
        begin
            goto error
        end
        */
        
        /* add hosp code for HPI by ML on 07.09.1999 */
        CALL hasp_insert_transaction_log(par_hosp => par_hospital_code, "par_System_datetime" => par_system_datetime, "par_Case_no" => par_ae_case_no, "par_From_ward_code" => var_ward_code, "par_From_treatment_location" => var_treatment_location, "par_From_class" => var_ward_class, "par_From_bed" => var_bed_no, "par_From_specialty_code" => var_specialty_code, "par_To_ward_code" => NULL, "par_To_treatment_location" => NULL, "par_To_class" => NULL, "par_To_bed" => NULL, "par_To_specialty_code" => NULL, "par_Transaction_datetime" => par_ae_discharge_datetime, "par_Transaction_type" => var_transaction_type, "par_Post_datetime" => NULL, "par_User_ID" => par_user_id, "par_Post_flag" => NULL, "par_Prev_system_datetime" => NULL, pas_return_code =>  var_retcode);


        IF var_retcode != 0 THEN
            BEGIN
                RAISE exception '';
            END;
        END IF;
        SELECT
            var_case_movement_count + 1
            INTO var_case_movement_count;
        /* add mrt_indicator by Winnie Lau */
        CALL hasp_insert_event_log
        /* add hosp code for HPI by ML on 07.09.1999 */(par_hosp => par_hospital_code, "par_System_datetime" => par_system_datetime, "par_Type" => var_transaction_type, "par_HKID" => var_hkid, "par_Name" => var_pmi_name, "par_Sex" => var_sex, "par_DOB" => var_dob, "par_Exact_DOB_flag" => var_exact_dob_flag, "par_CCC_1" => var_ccc_1, "par_CCC_2" => var_ccc_2, "par_CCC_3" => var_ccc_3, "par_CCC_4" => var_ccc_4, "par_CCC_5" => var_ccc_5, "par_CCC_6" => var_ccc_6, "par_Martial_status" => var_marital_status, "par_Race_code" => var_race_code, "par_Other_document_no" => var_other_document_no, "par_Medical_record_number" => var_medical_record_number, "par_Building" => var_pmi_building, "par_Room" => var_pmi_room, "par_Floor" => var_pmi_floor, "par_Block" => var_pmi_block, "par_District_code" => var_pmi_district_code, "par_Religion_code" => var_religion_code, "par_phone1" => var_pmi_phone1, "par_phone2" => var_pmi_phone2, "par_address_indicator" => var_pmi_address_indicator, "par_mobile_phone" => var_pmi_mobile_phone, "par_sms_language" => var_pmi_sms_language, "par_Death_indicator" => var_death_indicator, "par_Death_date" => par_death_date, "par_T_PRK" => var_t_prk, "par_NOK_name" => NULL, "par_NOK_HKID" => NULL, "par_NOK_relation_code" => NULL, "par_NOK_building" => NULL, "par_NOK_room" => NULL, "par_NOK_floor" => NULL, "par_NOK_block" => NULL, "par_NOK_district_code" => NULL, "par_NOK_phone1" => NULL, "par_NOK_phone2" => NULL, "par_NOK_address_indicator" => NULL, "par_NOK_mobile_phone" => NULL, "par_NOK_sms_language" => NULL, "par_Case_no" => par_ae_case_no, "par_Admission_datetime" => var_admission_datetime, "par_Source_indicator" => NULL, "par_Source_code" => NULL, "par_Pay_code" => var_pay_code, "par_Discharge_code" => par_discharge_code, "par_Discharge_datetime" => par_ae_discharge_datetime, "par_Destination_code" => par_destination, "par_Case_type" => var_case_type, "par_Movement_count" => var_case_movement_count, "par_Security_count" => var_security_count, "par_Case_access_code" => var_case_access_code, "par_PMI_access_code" => var_pmi_access_code, "par_Ambulance_no" => NULL, "par_Police_case" => NULL, "par_Labour_case" => NULL, "par_AE_case_type" => NULL, "par_DBA_flag" => NULL, "par_Follow_up_datetime" => NULL, "par_Ward_code" => var_ward_code, "par_Specialty_code" => var_specialty_code, "par_Bed_no" => var_bed_no, "par_Ward_class" => var_ward_class, "par_Old_name" => NULL, "par_Old_HKID" => NULL, "par_Old_sex" => NULL, "par_Old_DOB" => NULL, "par_Old_ward_class" => NULL, "par_Old_ward_code" => NULL, "par_Old_specialty_code" => NULL, "par_Old_bed_no" => NULL, "par_User_ID" => par_user_id, "par_Doctor_code" => NULL, "par_Old_doctor_code" => NULL, "par_Old_T_PRK" => NULL, "par_MRT_indicator" => NULL,pas_return_code=> var_retcode); /* by Winnie on 19FEb98 */

        IF var_retcode != 0 THEN
            BEGIN
                RAISE exception '';
            END;
        END IF;
        /* * add mrt_indicator by Winnie Lau * */
        /* -- remove cpi.. by WL on 29 Jul 99--- */
        
        /* --exec @retcode =  cpi..cpi_discharge */
        CALL cpi_discharge(par_hospital_code := par_hospital_code, par_case_no := par_ae_case_no, par_hkid := var_hkid, par_discharge_code := par_discharge_code, par_discharge_datetime := par_ae_discharge_datetime, par_destination_code := par_destination, par_ward_code := var_ward_code, par_ward_class := var_ward_class, par_bed_no := var_bed_no, par_specialty_code := var_specialty_code, par_sub_specialty := NULL, par_doctor_code := NULL, par_case_type := 'A', par_txn_type := var_transaction_type, par_transaction_datetime := par_system_datetime, par_update_by := par_user_id, par_source_system := 'ADT', par_mrt_indicator := NULL, par_followup_datetime := NULL, /* by Philip on 27Aug09 */ par_death_datetime := par_death_date,pas_return_code=>var_retcode); /* by Philip on 27Aug09 */

        IF var_retcode != 0 THEN
            BEGIN
                /* -- remove cpi.. by WL on 29 Jul 99 -- */
                
                /* --select @error_msg = messages from cpi..error_msgs */
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
                                WHEN '' THEN ''
                                ELSE CAST (var_retcode AS VARCHAR(8))
                            END)
                            INTO var_error_msg;
                    END;
                END IF;
                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                RAISE exception '';
            END;
        END IF;
        EXCEPTION
			WHEN OTHERS then
			begin
				EXIT error;
			end;
        pas_return_code := 0;
        RETURN;
    END;
    /*
    [3057 - Severity CRITICAL - PostgreSQL does not support ROLLBACK TRAN adt_discharge command. Perform a manual conversion.]
    rollback adt_discharge
    */ /* ---20140401 -- */
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_discharge_ae_case" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
