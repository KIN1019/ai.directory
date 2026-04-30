-- DROP PROCEDURE hpi.web_hasp_admission(inout int4, in varchar, in timestamp, in varchar, inout varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, inout varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, inout varchar, in timestamp, in varchar, in varchar, in varchar, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_admission(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_case_type character varying, INOUT par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_home_phone_no character varying, IN par_other_phone_no_1 character varying, IN par_other_phone_ext_1 character varying, IN par_other_phone_no_2 character varying, IN par_other_phone_ext_2 character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, INOUT par_t_prk character varying, IN par_nok_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_home_phone character varying, IN par_nok_other_phone_no_1 character varying, IN par_nok_other_phone_ext_1 character varying, IN par_nok_other_phone_no_2 character varying, IN par_nok_other_phone_ext_2 character varying, IN par_nok2_priority integer DEFAULT NULL::integer, IN par_nok2_arr character varying[] DEFAULT NULL::character varying[], IN par_nok3_priority integer DEFAULT NULL::integer, IN par_nok3_arr character varying[] DEFAULT NULL::character varying[], IN par_nok4_priority integer DEFAULT NULL::integer, IN par_nok4_arr character varying[] DEFAULT NULL::character varying[], IN par_nok5_priority integer DEFAULT NULL::integer, IN par_nok5_arr character varying[] DEFAULT NULL::character varying[], IN par_nok6_priority integer DEFAULT NULL::integer, IN par_nok6_arr character varying[] DEFAULT NULL::character varying[], IN par_nok7_priority integer DEFAULT NULL::integer, IN par_nok7_arr character varying[] DEFAULT NULL::character varying[], IN par_nok8_priority integer DEFAULT NULL::integer, IN par_nok8_arr character varying[] DEFAULT NULL::character varying[], IN par_nok9_priority integer DEFAULT NULL::integer, IN par_nok9_arr character varying[] DEFAULT NULL::character varying[], IN par_nok10_priority integer DEFAULT NULL::integer, IN par_nok10_arr character varying[] DEFAULT NULL::character varying[], INOUT par_case_no character varying DEFAULT NULL::character varying, IN par_admission_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_source_indicator character varying DEFAULT NULL::character varying, IN par_source_code character varying DEFAULT NULL::character varying, IN par_pay_code character varying DEFAULT NULL::character varying, IN par_movement_count integer DEFAULT NULL::integer, IN par_security_count integer DEFAULT NULL::integer, IN par_case_access_code integer DEFAULT NULL::integer, IN par_pmi_access_code integer DEFAULT NULL::integer, IN par_ambulance_no character varying DEFAULT NULL::character varying, IN par_police_case character varying DEFAULT NULL::character varying, IN par_labour_case character varying DEFAULT NULL::character varying, IN par_ae_case_type character varying DEFAULT NULL::character varying, IN par_dba_flag character varying DEFAULT NULL::character varying, IN par_ward_class character varying DEFAULT NULL::character varying, IN par_ward_code character varying DEFAULT NULL::character varying, IN par_specialty_code character varying DEFAULT NULL::character varying, IN par_user_id character varying DEFAULT NULL::character varying, IN par_pp_code character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_source_hosp_code character varying DEFAULT NULL::character varying, IN par_source_case_no character varying DEFAULT NULL::character varying, IN par_previous_case character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_mother_baby_action character varying DEFAULT NULL::character varying, IN par_mother_hosp character varying DEFAULT NULL::character varying, IN par_mother_case character varying DEFAULT NULL::character varying, IN par_baby_hosp character varying DEFAULT NULL::character varying, IN par_birth_order integer DEFAULT NULL::integer, IN par_preg_number integer DEFAULT NULL::integer, IN par_birth_location character varying DEFAULT NULL::character varying, IN par_birth_place character varying DEFAULT NULL::character varying, IN par_old_mother_case character varying DEFAULT NULL::character varying, IN par_old_baby_case character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
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
/* case detail */
/* Mother baby linkage */
DECLARE
    var_transaction_type VARCHAR(03);
    var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_error_msg VARCHAR(255);
    var_tmp_hkid VARCHAR(9);
    var_current_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_treatment_location VARCHAR(04);
    var_baby_case VARCHAR(12);
    var_old_t_prk VARCHAR(08);
    var_old_hkid VARCHAR(12);
    var_old_name VARCHAR(48);
    var_old_sex VARCHAR(01);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_last_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_last_update_by VARCHAR(08);
    hasp_get_next_un$refcur_1 refcursor;
    sql$rowcount BIGINT;
    var_return_code int;
    var_selected_error_msg VARCHAR(255);
BEGIN
    <<error>>
    BEGIN
        IF par_case_type = 'A' THEN
            var_transaction_type := '300';
        ELSE
            IF par_case_type = 'I' THEN
                var_transaction_type := '100';
            END IF;
        END IF;
        var_current_datetime := timestamp_convert(localtimestamp);
        /* Open transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        		begin transaction
        */
        /* Get a pseudo ID from Hospital table when HKID is empty */
        IF par_t_prk IS NULL THEN
            BEGIN
                IF par_hkid IS NULL OR par_hkid = '' OR par_hkid = 'UN' THEN
                    BEGIN
                        CALL hasp_get_next_un(var_retcode,par_hosp_code, var_tmp_hkid );


                        IF var_retcode != 0 THEN
                            EXIT error;
                        END IF;
                        CALL web_hasp_get_hkid_check_digit(var_retcode, var_tmp_hkid, par_hkid);

                        IF var_retcode != 0 THEN
                            EXIT error;
                        END IF;
                    END;
                END IF;
                var_old_t_prk := NULL;
                var_old_name := NULL;
                var_old_hkid := NULL;
                var_old_sex := NULL;
                var_old_dob := NULL;
            END;
        ELSE
            BEGIN
                SELECT
                    patient_key, hkid, patient_name, sex, dob, update_dtm, update_by
                    INTO var_old_t_prk, var_old_hkid, var_old_name, var_old_sex, var_old_dob, var_last_update_datetime, var_last_update_by
                    FROM cpi_patient
                    WHERE patient_key = par_t_prk;
            END;
        END IF;
        /* End - Get a pseudo ID from Hospital table when HKID is empty */
        /* Get treatment location */
        IF par_case_type = 'I' THEN
            BEGIN
                SELECT
                    Treatment_location
                    INTO var_treatment_location
                    FROM (SELECT
                        Treatment_location, Ward_code, Effective_date, Active_status
                        FROM Ward) AS ungrouped_query
                    INNER JOIN (SELECT
                        Ward_code, MAX(Effective_date) AS max_1
                        FROM Ward
                        WHERE Hospital_code = par_hosp_code AND Ward_code = par_ward_code AND Effective_date <= par_admission_datetime
                        GROUP BY Ward_code) AS grouped_query
                        ON (ungrouped_query.Ward_code = grouped_query.Ward_code OR (ungrouped_query.Ward_code IS NULL AND grouped_query.Ward_code IS NULL))
                    WHERE Effective_date = max_1 AND Active_status = 'A';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    BEGIN
                        var_retcode := 299999;
                        var_error_msg := CONCAT('Unable to retrieve treatment location of Ward:', par_ward_code);
                    END;
                END IF;
            END;
        END IF;
        /* End - Get treatment location */
        /* delete all non-major contact persons before update patient */
        CALL hpi.web_hasp_update_noks(var_retcode, par_hosp_code,par_System_datetime, par_T_PRK, par_HKID, par_User_ID, par_NOK2_priority, par_NOK2_arr, par_NOK3_priority,
        				par_NOK3_arr, par_NOK4_priority, par_NOK4_arr, par_NOK5_priority, par_NOK5_arr, par_NOK6_priority, par_NOK6_arr, par_NOK7_priority, par_NOK7_arr,
       					par_NOK8_priority, par_NOK8_arr, par_NOK9_priority, par_NOK9_arr, par_NOK10_priority, par_NOK10_arr);
         
        IF var_retcode <> 0 THEN
            EXIT error;
        END IF;
        /* End - delete all non-major contact persons before update patient */
        CALL hasp_admission_woresult(var_retcode,par_hosp_code, par_system_datetime, var_transaction_type, par_hkid, par_name, par_sex, par_dob, par_exact_dob_flag,
       					par_ccc1, par_ccc2, par_ccc3, par_ccc4, par_ccc5, par_ccc6, par_marital_status, par_race_code, par_other_document_no, par_medical_record_number,
       					par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_home_phone_no, par_other_phone_no_1, par_other_phone_ext_1,
       					par_other_phone_no_2, par_other_phone_ext_2, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor,
       					par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2,
       					par_nok_other_phone_ext_2, par_death_indicator, par_death_date, par_t_prk, par_case_no, par_admission_datetime, par_source_indicator, par_source_code,
       					par_pay_code, NULL, NULL, NULL, par_case_type, par_movement_count, par_security_count, par_case_access_code, par_pmi_access_code, par_ambulance_no,
       					par_police_case, par_labour_case, par_ae_case_type, par_dba_flag, NULL, par_ward_code, par_specialty_code, NULL, par_ward_class, par_user_id,
       					par_pp_code, var_last_update_datetime, var_last_update_by, NULL, par_eh_code, par_document_flag, par_source_hosp_code, par_source_case_no, par_hkic_symbol);


        IF var_retcode != 0 THEN
            EXIT error;
        END IF;
        /* Insert Transaction_log */
        CALL hasp_insert_transaction_log(var_retcode,par_hosp_code, par_system_datetime, par_case_no, par_ward_code, var_treatment_location, par_ward_class, NULL,
       					par_specialty_code, NULL, NULL, NULL, NULL, NULL, par_admission_datetime, var_transaction_type, NULL, par_user_id, NULL, NULL);


        IF var_retcode <> 0 THEN
            BEGIN
                var_retcode := 299999;
                var_error_msg := 'Fail to insert Transaction_log';
                EXIT error;
            END;
        END IF;
        /* End - Insert Transaction_log */
        IF par_t_prk IS NULL THEN
            BEGIN
                SELECT
                    patient_key
                    INTO par_t_prk
                    FROM cpi_case
                    WHERE hospital_code = par_hosp_code AND case_no = par_case_no;
            END;
        END IF;

        IF par_document_flag = 'F' THEN
            BEGIN
                SELECT
                    hkid, patient_name, sex, dob
                    INTO var_old_hkid, var_old_name, var_old_sex, var_old_dob
                    FROM cpi_patient
                    WHERE hkid = par_other_document_no;
            END;
        END IF;
        /* Insert Event_log */
        CALL hasp_insert_event_log(var_retcode,par_hosp_code, var_current_datetime, var_transaction_type, par_hkid, par_name, par_sex, par_dob, par_exact_dob_flag,
       					par_ccc1, par_ccc2, par_ccc3, par_ccc4, par_ccc5, par_ccc6, par_marital_status, par_race_code, par_other_document_no, par_medical_record_number,
       					par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_home_phone_no, par_other_phone_no_1, par_other_phone_ext_1,
       					par_other_phone_no_2, par_other_phone_ext_2, par_death_indicator, par_death_date, par_t_prk, par_nok_name, par_nok_hkid, par_nok_relation_code,
       					par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, 
       					par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2, par_case_no, par_admission_datetime, par_source_indicator,
       					par_source_code, par_pay_code, NULL, NULL, NULL, par_case_type, par_movement_count, par_security_count, par_case_access_code, par_pmi_access_code,
       					par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba_flag, NULL, par_ward_code, par_specialty_code, NULL, par_ward_class,
       					var_old_name, var_old_hkid, var_old_sex, var_old_dob, NULL, NULL, NULL, NULL, par_user_id, NULL, NULL, NULL, NULL, NULL);

        IF var_retcode <> 0 THEN
            BEGIN
                var_retcode := 299999;
                var_error_msg := 'Fail to insert Event_log';
                EXIT error;
            END;
        END IF;
        /* End - Insert Event_log */
        /* Insert non-major contact persons */
        CALL hpi.web_hasp_update_noks(var_retcode, par_hosp_code,par_System_datetime, par_T_PRK, par_HKID, par_User_ID, par_NOK2_priority, par_NOK2_arr, par_NOK3_priority,
				par_NOK3_arr, par_NOK4_priority, par_NOK4_arr, par_NOK5_priority, par_NOK5_arr, par_NOK6_priority, par_NOK6_arr, par_NOK7_priority, par_NOK7_arr,
				par_NOK8_priority, par_NOK8_arr, par_NOK9_priority, par_NOK9_arr, par_NOK10_priority, par_NOK10_arr);
        IF var_retcode <> 0 THEN
            EXIT error;
        END IF;
        /* End - Insert non-major contact persons */
        /* Update mother baby linkage */
        IF par_mother_baby_action IN ('A', 'U', 'D') THEN
            BEGIN
                IF par_mother_baby_action = 'D' THEN
                    BEGIN
                        par_mother_hosp := par_hosp_code;
                        par_mother_case := par_old_mother_case;
                        par_baby_hosp := par_hosp_code;
                        var_baby_case := par_old_baby_case;
                        par_birth_order := NULL;
                        par_preg_number := NULL;
                        par_birth_location := NULL;
                        par_birth_place := NULL;
                    END;
                ELSE
                    var_baby_case := par_case_no;
                END IF;
                CALL web_hasp_update_mo_bb(var_retcode,par_mother_baby_action, par_mother_hosp, par_mother_case, par_baby_hosp, var_baby_case, par_old_mother_case,
               				par_old_baby_case, par_birth_order, par_preg_number, par_birth_location, par_birth_place, par_user_id, par_system_datetime, par_hkid);
               			

                IF var_retcode <> 0 then
                    EXIT error;
                END IF;
            END;
        END IF;
        /* End - Update mother baby linkage */
        /* Set off problem address indicator if this set on */
        IF par_pmi_access_code % 2 = 0 THEN
            BEGIN
                CALL hasp_set_problem_address_ind(var_retcode,par_hkid, 'N', par_user_id);

                IF var_retcode <> 0 THEN
                    EXIT error;
                END IF;
            END;
        END IF;
        /* End - Set off problem address indicator if this set on */
        /* Auto discharge A&E case */
        IF par_case_type = 'I' THEN
            BEGIN
                IF par_previous_case IS NOT NULL THEN
                    BEGIN
                        CALL hasp_discharge_ae_case(var_retcode,par_hosp_code, par_previous_case, par_admission_datetime, par_system_datetime, par_user_id, '9', par_hosp_code);

                    END;
                END IF;
            END;
        END IF;
        /* End - Auto discharge A&E case */
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
    END;
	/*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
    if @@trancount > 0
    		rollback transaction
    */
	rollback;

    
    /* Find the error message by error code */

    IF var_retcode != 299999 THEN
        BEGIN
            SELECT
                messages
                INTO var_selected_error_msg
                FROM error_msgs
                WHERE error_code = var_retcode;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 1 THEN
                var_error_msg := var_selected_error_msg;
            else
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
                                            var_error_msg := 'If birth location is OTH, birth place must be Born before arrival !';
                                        ELSE
                                            IF var_retcode = 300007 THEN
                                                var_error_msg := 'If birth place is Labour room, birth location must be own hospital !';
                                            ELSE
                                                IF var_retcode = 300008 then
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
                                                                        var_error_msg := 'The Mother Baby Relationship already exists for the Patient !';
                                                                    /* End - Error from web_hasp_update_mo_bb */
                                                                    ELSE
                                                                        var_error_msg := CONCAT('Call cpi function failed with return code ',
                                                                        CASE CAST (var_retcode AS VARCHAR(8))
                                                                            WHEN '' THEN ' '
                                                                            ELSE CAST (var_retcode AS VARCHAR(8))
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
       else
       	var_retcode := 299999;
    END IF;
    /* End - Find the error message by error code */
	pas_return_code := var_retcode;

    RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := 'P0001';
    return;
END;
$procedure$
;

;ALTER PROCEDURE "web_hasp_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
