-- DROP PROCEDURE hpi.hasp_web_ae_ip_admission(inout int4, in varchar, in timestamp, in varchar, inout varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, inout varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, inout varchar, in timestamp, in varchar, in varchar, in varchar, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in varchar, in _varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_web_ae_ip_admission(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_case_type character varying, INOUT par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, INOUT par_t_prk character varying, IN par_nok_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_nok2_priority integer DEFAULT NULL::integer, IN par_nok2_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok3_priority integer DEFAULT NULL::integer, IN par_nok3_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok4_priority integer DEFAULT 4, IN par_nok4_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok5_priority integer DEFAULT 5, IN par_nok5_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok6_priority integer DEFAULT 6, IN par_nok6_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok7_priority integer DEFAULT 7, IN par_nok7_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok8_priority integer DEFAULT 8, IN par_nok8_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok9_priority integer DEFAULT 9, IN par_nok9_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok10_priority integer DEFAULT 10, IN par_nok10_arr character varying[] DEFAULT NULL::bpchar[], INOUT par_case_no character varying DEFAULT NULL::bpchar, IN par_admission_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_source_indicator character varying DEFAULT NULL::bpchar, IN par_source_code character varying DEFAULT NULL::bpchar, IN par_pay_code character varying DEFAULT NULL::bpchar, IN par_movement_count integer DEFAULT NULL::integer, IN par_security_count integer DEFAULT NULL::integer, IN par_case_access_code integer DEFAULT NULL::integer, IN par_pmi_access_code integer DEFAULT NULL::integer, IN par_ambulance_no character varying DEFAULT NULL::bpchar, IN par_police_case character varying DEFAULT NULL::bpchar, IN par_labour_case character varying DEFAULT NULL::bpchar, IN par_ae_case_type character varying DEFAULT NULL::bpchar, IN par_dba_flag character varying DEFAULT NULL::bpchar, IN par_ward_class character varying DEFAULT NULL::bpchar, IN par_ward_code character varying DEFAULT NULL::bpchar, IN par_specialty_code character varying DEFAULT NULL::bpchar, IN par_user_id character varying DEFAULT NULL::bpchar, IN par_pp_code character varying DEFAULT NULL::bpchar, IN par_eh_code character varying DEFAULT NULL::bpchar, IN par_document_flag character varying DEFAULT NULL::bpchar, IN par_source_hosp_code character varying DEFAULT NULL::bpchar, IN par_source_case_no character varying DEFAULT NULL::bpchar, IN par_previous_case character varying DEFAULT NULL::bpchar, IN par_hkic_symbol character varying DEFAULT NULL::bpchar, IN par_mother_baby_action character varying DEFAULT NULL::bpchar, IN par_mother_hosp character varying DEFAULT NULL::character varying, IN par_mother_case character varying DEFAULT NULL::character varying, IN par_baby_hosp character varying DEFAULT NULL::character varying, IN par_birth_order integer DEFAULT NULL::integer, IN par_preg_number integer DEFAULT NULL::integer, IN par_birth_location character varying DEFAULT NULL::character varying, IN par_birth_place character varying DEFAULT NULL::character varying, IN par_old_mother_case character varying DEFAULT NULL::character varying, IN par_arr character varying[] DEFAULT NULL::character varying[])
 LANGUAGE plpgsql
AS $procedure$
declare
    var_transaction_type     VARCHAR(03);
    var_retcode              INTEGER;
    var_rowcount             INTEGER;
    var_error                INTEGER;
    var_error_msg            VARCHAR(255);
    var_tmp_hkid             VARCHAR(9);
    var_current_datetime     TIMESTAMP without TIME zone;
    var_treatment_location   VARCHAR(04);
    var_baby_case            VARCHAR(12);
    var_old_t_prk            VARCHAR(08);
    var_old_hkid             VARCHAR(12);
    var_old_name             VARCHAR(48);
    var_old_sex              VARCHAR(01);
    var_old_dob              TIMESTAMP without TIME zone;
    var_last_update_datetime TIMESTAMP without TIME zone;
    var_last_update_by       VARCHAR(08);
    var_default_access_code  INTEGER;
    sql$rowcount             BIGINT;

    var_next_case_no         VARCHAR(16);
    var_check_digit          VARCHAR(2);

    -- hasp_admission_woresult$refcur_1 refcursor;
    -- hasp_admission_woresult$refcur_2 refcursor;
    -- hasp_insert_transaction_log$refcur_1 refcursor;
    -- hasp_insert_transaction_log$refcur_2 refcursor;
    -- web_hasp_update_mo_bb$refcur_1 refcursor;

    var_disc_code            VARCHAR(01);
    var_return_code          int;

    -- hasp_discharge_ae_case$refcur_1 refcursor;

    var_selected_error_msg   VARCHAR(255);
	error_msg text;
    par_old_baby_case varchar(50) := par_arr[1];
    par_hkic_symbol_clear VARCHAR(50) := COALESCE(par_arr[2], 'N');
    par_is_express VARCHAR(50) := COALESCE(par_arr[3], 'N');
begin
    <<error>>
    begin
        if par_case_type = 'A' then
            var_transaction_type := '300';
        else
            if par_case_type = 'I' then
                var_transaction_type := '100';
            end if;
        end if;

                /* IPAS-764 Cathy Chen Enhance A&E Express Registration Phase3 : default N when hkic_symbol_clear not equal to Y */
        IF par_hkic_symbol_clear <> 'Y' THEN
            SELECT
                'N'
                INTO par_hkic_symbol_clear;
        END IF;
        /* IPAS-764 Cathy Chen Enhance A&E Express Registration Phase3 : default N when is_express not equal to Y */
        IF par_is_express <> 'Y' THEN
            SELECT
                'N'
                INTO par_is_express;
        END IF;

        /* --	set @current_datetime = getdate() */
        var_current_datetime := 3 * interval '1 millisecond' + par_system_datetime::TIMESTAMP;

        var_default_access_code := 2147483647;

        /* Get treatment location */
        if par_case_type = 'I' then
            begin
                select Treatment_location
                into
                    var_treatment_location
                from (select Treatment_location,
                             Ward_code,
                             Effective_date,
                             Active_status
                      from Ward) as ungrouped_query
                         inner join (select Ward_code,
                                            MAX(Effective_date) as max_1
                                     from Ward
                                     where Hospital_code = par_hosp_code
                                       and Ward_code = par_ward_code
                                       and Effective_date <= par_admission_datetime
                                     group by Ward_code) as grouped_query
                                    on
                                        (ungrouped_query.Ward_code = grouped_query.Ward_code
                                            or (ungrouped_query.Ward_code is null
                                                and grouped_query.Ward_code is null))
                where Effective_date = max_1
                  and Active_status = 'A';

                get diagnostics sql$rowcount = ROW_COUNT;

                if sql$rowcount = 0 then
                    begin
                        raise notice '[hasp_web_ae_ip_admission:86]';
                        var_retcode := 299999;

                        var_error_msg := CONCAT('Unable to retrieve treatment location of Ward:', par_ward_code);
                    end;
                end if;
            end;
        end if;
        /* End - Get treatment location */

        /* Open transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
            begin transaction
        */
		
        /* Get a pseudo ID from Hospital table when HKID is empty */
        if par_t_prk is null then
            begin
                if par_hkid is null
                    or par_hkid = ''
                    or par_hkid = 'UN' then
                    begin
                        call hasp_get_next_un(var_retcode,par_hosp_code,
                                                           var_tmp_hkid);

                        if var_retcode != 0 then
                            exit error;
                        end if;

                        call web_hasp_get_hkid_check_digit(var_retcode,var_tmp_hkid,
                                                                        par_hkid);

                        if var_retcode != 0 then
                            exit error;
                        end if;
                    end;
                end if;

                var_old_t_prk := null;

                var_old_name := null;

                var_old_hkid := null;

                var_old_sex := null;

                var_old_dob := null;
            end;
        else
            begin
                select patient_key,
                       hkid,
                       patient_name,
                       sex,
                       dob,
                       update_dtm,
                       update_by
                into
                    var_old_t_prk,
                    var_old_hkid,
                    var_old_name,
                    var_old_sex,
                    var_old_dob,
                    var_last_update_datetime,
                    var_last_update_by
                from cpi_patient
                where patient_key = par_t_prk;
            end;
        end if;

        /* End - Get a pseudo ID from Hospital table when HKID is empty */
        /* Start -IPAS-764 Cathy Chen Enhance A&E Express Registration Phase3 : update patient info and gen 030 cpi_transaction */
        IF par_is_express = 'Y' THEN
            BEGIN
                CALL web_hasp_update_patient(
                        pas_return_code => var_retcode,
                        par_hosp_code => par_hosp_code,
                        par_System_datetime => par_system_datetime,
                        par_HKID => par_hkid,
                        par_Name => par_name,
                        par_Sex => par_sex,
                        par_DOB => par_dob,
                        par_Exact_DOB_flag => par_exact_dob_flag,
                        par_CCC_1 => par_ccc1,
                        par_CCC_2 => par_ccc2,
                        par_CCC_3 => par_ccc3,
                        par_CCC_4 => par_ccc4,
                        par_CCC_5 => par_ccc5,
                        par_CCC_6 => par_ccc6,
                        par_Marital_status => par_marital_status,
                        par_Race_code => par_race_code,
                        par_Other_document_no => par_other_document_no,
                        par_Medical_record_number => par_medical_record_number,
                        par_Building => par_building,
                        par_Room => par_room,
                        par_Floor => par_floor,
                        par_Block => par_block,
                        par_District_code => par_district_code,
                        par_Religion_code => par_religion_code,
                        par_Home_phone_no => par_phone1,
                        par_Other_phone_no_1 => par_phone2,
                        par_Other_phone_ext_1 => par_address_indicator,
                        par_Other_phone_no_2 => par_mobile_phone,
                        par_Other_phone_ext_2 => par_sms_language,
                        par_Death_indicator => par_death_indicator,
                        par_Death_date => par_death_date,
                        par_T_PRK => par_t_prk,
                        par_NOK_priority => par_nok_priority,
                        par_NOK_name => par_nok_name,
                        par_NOK_HKID => par_nok_hkid,
                        par_NOK_relation_code => par_nok_relation_code,
                        par_NOK_building => par_nok_building,
                        par_NOK_room => par_nok_room,
                        par_NOK_floor => par_nok_floor,
                        par_NOK_block => par_nok_block,
                        par_NOK_district_code => par_nok_district_code,
                        par_NOK_home_phone => par_nok_phone1,
                        par_NOK_other_phone_no_1 => par_nok_phone2,
                        par_NOK_other_phone_ext_1 => par_nok_address_indicator,
                        par_NOK_other_phone_no_2 => par_nok_mobile_phone,
                        par_NOK_other_phone_ext_2 => par_nok_sms_language,
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
                        par_NOK10_arr => par_NOK10_arr,
                        par_PMI_access_code => par_pmi_access_code,
                        par_Old_name => var_old_name,
                        par_Old_HKID => var_old_hkid,
                        par_Old_sex => var_old_sex,
                        par_Old_DOB => var_old_dob,
                        par_User_ID => par_user_id,
                        par_Old_T_PRK => var_old_t_prk,
                        par_Last_update_datetime => var_last_update_datetime,
                        par_Document_flag => par_document_flag,
                        par_hkic_symbol => par_hkic_symbol,
                        par_hkic_symbol_clear => par_hkic_symbol_clear,
                        par_mother_baby_action => NULL,
                        /* update motherbaby case in below sp web_hasp_update_mo_bb no need to update again */
                        par_mother_hosp => par_mother_hosp,
                        par_mother_case => par_mother_case,
                        par_baby_hosp => par_baby_hosp,
                        par_baby_case => var_baby_case,
                        par_birth_order => par_birth_order,
                        par_preg_number => par_preg_number,
                        par_birth_location => par_birth_location,
                        par_birth_place => par_birth_place,
                        par_Old_mother_case => par_old_mother_case,
                        par_Old_baby_case => par_old_baby_case,
                        par_is_express => par_is_express
                    );
                -- CLOSE web_hasp_update_patient$refcur_1;
                -- CLOSE web_hasp_update_patient$refcur_2;

                IF var_retcode <> 0 THEN
                    EXIT error;
                END IF;
                /* get last_update_datetime after update patient */
                IF par_t_prk <> '' AND par_t_prk IS NOT NULL THEN
                    BEGIN
                        SELECT
                            update_dtm
                            INTO var_last_update_datetime
                            FROM cpi_patient
                            WHERE patient_key = par_t_prk;
                    END;
                END IF;
                SELECT
                    localtimestamp
                    INTO par_system_datetime;
            END;
        END IF;
        /* End -IPAS-764 Cathy Chen Enhance A&E Express Registration Phase3 : update patient info and gen 030 cpi_transaction */
        /* Start - 20191016/Jessica/ get case no. inside admission stored proc */
        if par_case_no = ''
            or par_case_no is null then
            begin
                if par_case_type = 'A' then
                    begin
	                    raise notice 'par_admission_datetime=%,par_ae_no=%',par_admission_datetime,var_next_case_no;
                        call hasp_get_next_ae(par_hosp_code => par_hosp_code,
                                                           par_ae_no_2 => null,
                                                           par_adm_datetime => par_admission_datetime,
                                                           par_ae_no => var_next_case_no,
                                                           pas_return_code => var_retcode);

                        select CONCAT(' AE', var_next_case_no)
                        into par_case_no;
                       	raise notice '[hasp_web_ae_ip_admission:174]ppar_case_no=%',par_case_no;
                    end;
                else
                    if par_case_type = 'I' then
                        begin
                            call hasp_get_next_hn(par_hosp_code => par_hosp_code,
                                                               par_hn_no_2 => null,
                                                               par_adm_datetime => par_admission_datetime,
                                                               par_hn_no => var_next_case_no,
                                                               pas_return_code => var_retcode);

                            select CONCAT(' HN', var_next_case_no)
                            into par_case_no;
                        end;
                    end if;
                end if;

                if var_retcode <> 0 then
                    exit error;
                end if;
				raise notice 'par_case_no=%,var_check_digit=%',par_case_no,var_check_digit;
                call cpi_pq_get_caseno_chk_digit(par_caseno := par_case_no,
                                                 par_hospital_code := par_hosp_code,
                                                 par_check_digit := var_check_digit,
                                                 pas_return_code => var_retcode);

                select CONCAT(RTRIM(par_case_no), var_check_digit)
                into par_case_no;
                raise notice '[hasp_web_ae_ip_admission:216]par_case_no=>%',par_case_no;
            end;
        end if;

        /* End - 20191016/Jessica/ get case no. inside admission stored proc */
        /* delete all non-major contact persons before update patient */
        call web_hasp_update_noks(par_hosp_code => par_hosp_code,
                                               par_System_datetime => par_system_datetime,
                                               par_HKID => var_old_hkid,
                                               par_T_PRK => var_old_t_prk,
                                               par_User_ID => par_user_id,
                                               pas_return_code => var_retcode);
		raise notice 'par_t_prk=%',par_t_prk;
        if var_retcode <> 0 then
            exit error;
        end if;
        /* End - delete all non-major contact persons before update patient */

        call hasp_admission_woresult(pas_return_code => var_retcode,
                                     par_hosp_code => par_hosp_code,
                                     par_system_datetime => par_system_datetime,
                                     par_transaction_type => var_transaction_type,
                                     par_hkid => par_hkid,
                                     par_name => par_name,
                                     par_sex => par_sex,
                                     par_dob => par_dob,
                                     par_exact_dob_flag => par_exact_dob_flag,
                                     par_ccc1 => par_ccc1,
                                     par_ccc2 => par_ccc2,
                                     par_ccc3 => par_ccc3,
                                     par_ccc4 => par_ccc4,
                                     par_ccc5 => par_ccc5,
                                     par_ccc6 => par_ccc6,
                                     par_marital_status => par_marital_status,
                                     par_race_code => par_race_code,
                                     par_other_document_no => par_other_document_no,
                                     par_medical_record_number => par_medical_record_number,
                                     par_building => par_building,
                                     par_room => par_room,
                                     par_floor => par_floor,
                                     par_block => par_block,
                                     par_district_code => par_district_code,
                                     par_religion_code => par_religion_code,
                                     par_phone1 => par_phone1,
                                     par_phone2 => par_phone2,
                                     par_address_indicator => par_address_indicator,
                                     par_mobile_phone => par_mobile_phone,
                                     par_sms_language => par_sms_language,
                                     par_nok_name => par_nok_name,
                                     par_nok_hkid => par_nok_hkid,
                                     par_nok_relation_code => par_nok_relation_code,
                                     par_nok_building => par_nok_building,
                                     par_nok_room => par_nok_room,
                                     par_nok_floor => par_nok_floor,
                                     par_nok_block => par_nok_block,
                                     par_nok_district_code => par_nok_district_code,
                                     par_nok_phone1 => par_nok_phone1,
                                     par_nok_phone2 => par_nok_phone2,
                                     par_nok_address_indicator => par_nok_address_indicator,
                                     par_nok_mobile_phone => par_nok_mobile_phone,
                                     par_nok_sms_language => par_nok_sms_language,
                                     par_death_indicator => par_death_indicator,
                                     par_death_date => par_death_date,
                                     par_t_prk => par_t_prk,
                                     par_case_no => par_case_no,
                                     par_admission_datetime => par_admission_datetime,
                                     par_source_indicator => par_source_indicator,
                                     par_source_code => par_source_code,
                                     par_pay_code => par_pay_code,
                                     par_discharge_code => null,
                                     par_discharge_datetime => null,
                                     par_destination_code => null,
                                     par_case_type => par_case_type,
                                     par_movement_count => par_movement_count,
                                     par_security_count => par_security_count,
                                     par_case_access_code => par_case_access_code,
                                     par_pmi_access_code => var_default_access_code,
                                     par_ambulance_no => par_ambulance_no,
                                     par_police_case => par_police_case,
                                     par_labour_case => par_labour_case,
                                     par_ae_case_type => par_ae_case_type,
                                     par_dba_flag => par_dba_flag,
                                     par_follow_up_datetime => null,
                                     par_ward_code => par_ward_code,
                                     par_specialty_code => par_specialty_code,
                                     par_bed_no => null,
                                     par_ward_class => par_ward_class,
                                     par_user_id => par_user_id,
                                     par_pp_code => par_pp_code,
                                     par_last_system_datetime => var_last_update_datetime,
                                     par_last_updated_by => var_last_update_by,
                                     par_terminal_id => null,
                                     par_eh_code => par_eh_code,
                                     par_document_flag => par_document_flag,
                                     par_source_hosp_code => par_source_hosp_code,
                                     par_source_case_no => par_source_case_no,
                                     par_hkic_symbol => par_hkic_symbol
             );
			raise notice 'par_t_prk=%',par_t_prk;
--        EXCEPTION
--	    WHEN others THEN
--	        BEGIN
--	            GET STACKED DIAGNOSTICS error_msg = MESSAGE_TEXT;
--	         	raise notice 'call hasp_admission_woresult error_msg: %', error_msg;
--	         	exit error;
--	        END;
	    raise notice '[hasp_web_ae_ip_admission:306]var_retcode=>%',var_retcode;
        if var_retcode != 0 then
            exit error;
        end if;

        /* Insert Transaction_log */
        call hasp_insert_transaction_log(par_hosp => par_hosp_code,
                                                      "par_System_datetime" => par_system_datetime,
                                                      "par_Case_no" => par_case_no,
                                                      "par_From_ward_code" => par_ward_code,
                                                      "par_From_treatment_location" => var_treatment_location,
                                                      "par_From_class" => par_ward_class,
                                                      "par_From_bed" => null,
                                                      "par_From_specialty_code" => par_specialty_code,
                                                      "par_To_ward_code" => null,
                                                      "par_To_treatment_location" => null,
                                                      "par_To_class" => null,
                                                      "par_To_bed" => null,
                                                      "par_To_specialty_code" => null,
                                                      "par_Transaction_datetime" => par_admission_datetime,
                                                      "par_Transaction_type" => var_transaction_type,
                                                      "par_Post_datetime" => null,
                                                      "par_User_ID" => par_user_id,
                                                      "par_Post_flag" => null,
                                                      "par_Prev_system_datetime" => null,
                                                      pas_return_code => var_retcode);

        -- close hasp_insert_transaction_log$refcur_1;
        -- close hasp_insert_transaction_log$refcur_2;

        if var_retcode <> 0 then
            begin
                raise notice '[hasp_web_ae_ip_admission:334]';
                var_retcode := 299999;

                var_error_msg := 'Fail to insert Transaction_log';

                exit error;
            end;
        end if;
        /* End - Insert Transaction_log */

        if par_t_prk is null then
            begin
                select patient_key
                into
                    par_t_prk
                from cpi_case
                where hospital_code = par_hosp_code
                  and case_no = par_case_no;
            end;
        end if;
		raise notice 'par_t_prk=%',par_t_prk;	
        if par_document_flag = 'F' then
            begin
                select hkid,
                       patient_name,
                       sex,
                       dob
                into
                    var_old_hkid,
                    var_old_name,
                    var_old_sex,
                    var_old_dob
                from cpi_patient
                where hkid = par_other_document_no;
            end;
        end if;

        /* Insert Event_log */
        call hasp_insert_event_log(par_hosp => par_hosp_code,
                                                "par_System_datetime" => par_system_datetime,
                                                "par_Type" => var_transaction_type,
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
                                                "par_phone1" => par_phone1,
                                                "par_phone2" => par_phone2,
                                                "par_address_indicator" => par_address_indicator,
                                                "par_mobile_phone" => par_mobile_phone,
                                                "par_sms_language" => par_sms_language,
                                                "par_Death_indicator" => par_death_indicator,
                                                "par_Death_date" => par_death_date,
                                                "par_T_PRK" => par_t_prk,
                                                "par_NOK_name" => par_nok_name,
                                                "par_NOK_HKID" => par_nok_hkid,
                                                "par_NOK_relation_code" => par_nok_relation_code,
                                                "par_NOK_building" => par_nok_building,
                                                "par_NOK_room" => par_nok_room,
                                                "par_NOK_floor" => par_nok_floor,
                                                "par_NOK_block" => par_nok_block,
                                                "par_NOK_district_code" => par_nok_district_code,
                                                "par_NOK_phone1" => par_nok_phone1,
                                                "par_NOK_phone2" => par_nok_phone2,
                                                "par_NOK_address_indicator" => par_nok_address_indicator,
                                                "par_NOK_mobile_phone" => par_nok_mobile_phone,
                                                "par_NOK_sms_language" => par_nok_sms_language,
                                                "par_Case_no" => par_case_no,
                                                "par_Admission_datetime" => par_admission_datetime,
                                                "par_Source_indicator" => par_source_indicator,
                                                "par_Source_code" => par_source_code,
                                                "par_Pay_code" => par_pay_code,
                                                "par_Discharge_code" => null,
                                                "par_Discharge_datetime" => null,
                                                "par_Destination_code" => null,
                                                "par_Case_type" => par_case_type,
                                                "par_Movement_count" => par_movement_count,
                                                "par_Security_count" => par_security_count,
                                                "par_Case_access_code" => par_case_access_code,
                                                "par_PMI_access_code" => var_default_access_code,
                                                "par_Ambulance_no" => par_ambulance_no,
                                                "par_Police_case" => par_police_case,
                                                "par_Labour_case" => par_labour_case,
                                                "par_AE_case_type" => par_ae_case_type,
                                                "par_DBA_flag" => par_dba_flag,
                                                "par_Follow_up_datetime" => null,
                                                "par_Ward_code" => par_ward_code,
                                                "par_Specialty_code" => par_specialty_code,
                                                "par_Bed_no" => null,
                                                "par_Ward_class" => par_ward_class,
                                                "par_Old_name" => var_old_name,
                                                "par_Old_HKID" => var_old_hkid,
                                                "par_Old_sex" => var_old_sex,
                                                "par_Old_DOB" => var_old_dob,
                                                "par_Old_ward_class" => null,
                                                "par_Old_ward_code" => null,
                                                "par_Old_specialty_code" => null,
                                                "par_Old_bed_no" => null,
                                                "par_User_ID" => par_user_id,
                                                "par_Doctor_code" => null,
                                                "par_Old_doctor_code" => null,
                                                "par_Old_T_PRK" => null,
                                                "par_MRT_indicator" => null,
                                                "par_Upload_status" => null,
                                                pas_return_code => var_retcode);
        raise notice '[hasp_web_ae_ip_admission:455]var_retcode=>%',var_retcode;
       raise notice 'par_t_prk=%',par_t_prk;
        if var_retcode <> 0 then
            begin
                if exists (select 1
                           from Event_log
                           where System_datetime = par_system_datetime) then
                    begin
                        /* Retry Insert Event_log */
                        call hasp_insert_event_log(par_hosp => par_hosp_code,
                                                                "par_System_datetime" => var_current_datetime,
                                                                /* set @current_datetime = dateadd(ms, 3, @system_datetime) */
                                                                "par_Type" => var_transaction_type,
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
                                                                "par_phone1" => par_phone1,
                                                                "par_phone2" => par_phone2,
                                                                "par_address_indicator" => par_address_indicator,
                                                                "par_mobile_phone" => par_mobile_phone,
                                                                "par_sms_language" => par_sms_language,
                                                                "par_Death_indicator" => par_death_indicator,
                                                                "par_Death_date" => par_death_date,
                                                                "par_T_PRK" => par_t_prk,
                                                                "par_NOK_name" => par_nok_name,
                                                                "par_NOK_HKID" => par_nok_hkid,
                                                                "par_NOK_relation_code" => par_nok_relation_code,
                                                                "par_NOK_building" => par_nok_building,
                                                                "par_NOK_room" => par_nok_room,
                                                                "par_NOK_floor" => par_nok_floor,
                                                                "par_NOK_block" => par_nok_block,
                                                                "par_NOK_district_code" => par_nok_district_code,
                                                                "par_NOK_phone1" => par_nok_phone1,
                                                                "par_NOK_phone2" => par_nok_phone2,
                                                                "par_NOK_address_indicator" => par_nok_address_indicator,
                                                                "par_NOK_mobile_phone" => par_nok_mobile_phone,
                                                                "par_NOK_sms_language" => par_nok_sms_language,
                                                                "par_Case_no" => par_case_no,
                                                                "par_Admission_datetime" => par_admission_datetime,
                                                                "par_Source_indicator" => par_source_indicator,
                                                                "par_Source_code" => par_source_code,
                                                                "par_Pay_code" => par_pay_code,
                                                                "par_Discharge_code" => null,
                                                                "par_Discharge_datetime" => null,
                                                                "par_Destination_code" => null,
                                                                "par_Case_type" => par_case_type,
                                                                "par_Movement_count" => par_movement_count,
                                                                "par_Security_count" => par_security_count,
                                                                "par_Case_access_code" => par_case_access_code,
                                                                "par_PMI_access_code" => var_default_access_code,
                                                                "par_Ambulance_no" => par_ambulance_no,
                                                                "par_Police_case" => par_police_case,
                                                                "par_Labour_case" => par_labour_case,
                                                                "par_AE_case_type" => par_ae_case_type,
                                                                "par_DBA_flag" => par_dba_flag,
                                                                "par_Follow_up_datetime" => null,
                                                                "par_Ward_code" => par_ward_code,
                                                                "par_Specialty_code" => par_specialty_code,
                                                                "par_Bed_no" => null,
                                                                "par_Ward_class" => par_ward_class,
                                                                "par_Old_name" => var_old_name,
                                                                "par_Old_HKID" => var_old_hkid,
                                                                "par_Old_sex" => var_old_sex,
                                                                "par_Old_DOB" => var_old_dob,
                                                                "par_Old_ward_class" => null,
                                                                "par_Old_ward_code" => null,
                                                                "par_Old_specialty_code" => null,
                                                                "par_Old_bed_no" => null,
                                                                "par_User_ID" => par_user_id,
                                                                "par_Doctor_code" => null,
                                                                "par_Old_doctor_code" => null,
                                                                "par_Old_T_PRK" => null,
                                                                "par_MRT_indicator" => null,
                                                                "par_Upload_status" => null,
                                                                pas_return_code => var_retcode);
						raise notice 'par_t_prk=%',par_t_prk;
                        if var_retcode <> 0 then
                            begin
                                raise notice '[hasp_web_ae_ip_admission:550]';
                                var_retcode := 299999;

                                var_error_msg := 'Fail to insert Event_log';

                                exit error;
                            end;
                        end if;
                    end;
                else
                    begin
                        raise notice '[hasp_web_ae_ip_admission:561]';
                        var_retcode := 299999;

                        var_error_msg := 'Fail to insert Event_log';

                        exit error;
                    end;
                end if;
            end;
        end if;
        raise notice '[hasp_web_ae_ip_admission:571]';
        /* End - Insert Event_log */
        /* Insert non-major contact persons */
        begin
	    raise notice '|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|%|',var_retcode,
par_hosp_code,
par_system_datetime,
par_t_prk,
par_hkid,
par_user_id,
par_nok2_priority,
par_NOK2_arr,
par_nok3_priority,
par_NOK3_arr,
par_nok4_priority,
par_NOK4_arr,
par_nok5_priority,
par_NOK5_arr,
par_nok6_priority,
par_NOK6_arr,
par_nok7_priority,
par_NOK7_arr,
par_nok8_priority,
par_NOK8_arr,
par_nok9_priority,
par_NOK9_arr,
par_nok10_priority,
par_NOK10_arr;
        call web_hasp_update_noks(pas_return_code => var_retcode,
        							par_hosp_code => par_hosp_code,
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
                                    par_NOK10_arr=> par_NOK10_arr
                                               );
        exception
        	when others then
        	begin
		        raise notice '[hasp_web_ae_ip_admission:598]%,%',var_retcode,sqlerrm;
		        if var_retcode <> 0 then
		        	
		            exit error;
		        end if;
		    end;
		end;
		raise notice '[hasp_web_ae_ip_admission:641]';
        /* End - Insert non-major contact persons */
        /* Update mother baby linkage */
        if par_mother_baby_action in ('A', 'U', 'D') then
            begin
                if par_mother_baby_action = 'D' then
                    begin
                        par_mother_hosp := par_hosp_code;

                        par_mother_case := par_old_mother_case;

                        par_baby_hosp := par_hosp_code;

                        var_baby_case := par_old_baby_case;

                        par_birth_order := null;

                        par_preg_number := null;

                        par_birth_location := null;

                        par_birth_place := null;
                    end;
                else
                    var_baby_case := par_case_no;
                end if;
                raise notice 'mo bb hkid=%', par_hkid;
                call web_hasp_update_mo_bb(var_retcode,par_mother_baby_action,par_mother_hosp,par_mother_case,par_baby_hosp,var_baby_case,par_old_mother_case,
                				par_old_baby_case,par_birth_order,par_preg_number,par_birth_location,par_birth_place,par_user_id,par_system_datetime,par_hkid);

                -- close web_hasp_update_mo_bb$refcur_1;

                if var_retcode <> 0 then
                	 raise notice '[hasp_web_ae_ip_admission:656]';
                    exit error;
                end if;
            end;
        end if;

        /* End - Update mother baby linkage */
        /* Set off problem address indicator if this set on */
        if par_pmi_access_code & 2 <= 0 then
            begin
                call hasp_set_problem_address_ind(var_retcode,par_hkid,'N',par_user_id);

                if var_retcode <> 0 then
                    exit error;
                end if;
            end;
        end if;

        /* End - Set off problem address indicator if this set on */
        /* Auto discharge A&E case */
        if par_case_type = 'I' then
            begin
                if par_previous_case is not null then
                    begin
                        select Discharge_code
                        into var_disc_code
                        from Case_view
                        where Hospital_code = par_hosp_code
                          and Case_no = par_previous_case;

                        if var_disc_code is null then
                            begin
                                var_current_datetime := timestamp_convert(localtimestamp);

                                call hasp_discharge_ae_case(var_retcode,par_hosp_code,par_previous_case,par_admission_datetime,var_current_datetime,par_user_id,'9',par_hosp_code);
                                -- close hasp_discharge_ae_case$refcur_1;
                            end;
                        end if;
                    end;
                end if;
            end;
        end if;

        /* End - Auto discharge A&E case */
        /* Commit transaction */
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount > 0
        	begin
        		commit transaction
        	end
        */
        pas_return_code := 0;

        return;
    end;

    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
    if @@trancount > 0
        rollback transaction
    */
    
    /* Find the error message by error code */
    if var_retcode != 299999 then
        begin
            select messages
            into
                var_selected_error_msg
            from error_msgs
            where error_code = var_retcode;

            get diagnostics sql$rowcount = ROW_COUNT;

            if sql$rowcount = 1 then
                var_error_msg := var_selected_error_msg;
            else
                begin
                    /* Error from web_hasp_update_mo_bb */
                    if var_retcode = 300001 then
                        var_error_msg := 'Case no Cannot be null !';
                    else
                        if var_retcode = 300002 then
                            var_error_msg := 'Invalid Action Type !';
                        else
                            if var_retcode = 300003 then
                                var_error_msg := 'No Patient Found !';
                            else
                                if var_retcode = 300004 then
                                    var_error_msg := 'No Patient HKID Found !';
                                else
                                    if var_retcode = 300005 then
                                        var_error_msg := 'The Baby Case MUST belong to same patient !';
                                    else
                                        if var_retcode = 300006 then
                                            var_error_msg :=
                                                    'If birth location is OTH, birth place must be Born before arrival !';
                                        else
                                            if var_retcode = 300007 then
                                                var_error_msg :=
                                                        'If birth place is Labour room, birth location must be own hospital !';
                                            else
                                                if var_retcode = 300008 then
                                                    var_error_msg := 'Duplicate Birth Order is not allowed !';
                                                else
                                                    if var_retcode = 300011 then
                                                        var_error_msg := 'Insert mother_baby_case error !';
                                                    else
                                                        if var_retcode = 300012 then
                                                            var_error_msg := 'Delete mother_baby_case error !';
                                                        else
                                                            if var_retcode = 300013 then
                                                                var_error_msg := 'Delete cpi_new_born error !';
                                                            else
                                                                if var_retcode = 300014 then
                                                                    var_error_msg := 'Update mother_baby_case error !';
                                                                else
                                                                    if var_retcode = 300021 then
                                                                        var_error_msg :=
                                                                                'The Mother Baby Relationship already exists for the Patient !';
                                                                        /* End - Error from web_hasp_update_mo_bb */
                                                                    else
                                                                        var_error_msg := CONCAT(
                                                                                'Call cpi function failed with return code ',
                                                                                case
                                                                                    cast(var_retcode as VARCHAR(8))
                                                                                    when '' then ''
                                                                                    else cast(var_retcode as VARCHAR(8))
                                                                                    end);
                                                                    end if;
                                                                end if;
                                                            end if;
                                                        end if;
                                                    end if;
                                                end if;
                                            end if;
                                        end if;
                                    end if;
                                end if;
                            end if;
                        end if;
                    end if;
                end;
            end if;
        end;
    end if;
   
--    exception when others then
--	    begin
--		   raise notice 'error test % % % %',var_retcode, var_error_msg, sqlstate, sqlerrm;
--	    end;

    /* End - Find the error message by error code */
    raise notice '[hasp_web_ae_ip_admission:807] %', var_error_msg;
    var_retcode := 29999;
--
    raise exception '% ',
        var_error_msg
        using ERRCODE := var_retcode;

    pas_return_code := var_retcode;

--    return;
end;
$procedure$
;

;ALTER PROCEDURE "hasp_web_ae_ip_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";