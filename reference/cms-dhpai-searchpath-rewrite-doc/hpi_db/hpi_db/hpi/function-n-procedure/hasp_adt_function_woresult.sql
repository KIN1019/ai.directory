-- DROP PROCEDURE hpi.hasp_adt_function_woresult(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_adt_function_woresult(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_type character varying, IN par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_t_prk character varying, IN par_nok_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_case_no character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_pay_code character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_case_type character varying, IN par_movement_count integer, IN par_security_count integer, IN par_case_access_code integer, IN par_pmi_access_code integer, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_bed_no character varying, IN par_ward_class character varying, IN par_transfer_datetime timestamp without time zone, IN par_old_name character varying, IN par_old_hkid character varying, IN par_old_sex character varying, IN par_old_dob timestamp without time zone, IN par_old_ward_class character varying, IN par_old_ward_code character varying, IN par_old_specialty_code character varying, IN par_old_bed_no character varying, IN par_user_id character varying, IN par_doctor_code character varying, IN par_old_doctor_code character varying, IN par_old_t_prk character varying, IN par_pp_code character varying, IN par_last_update_datetime timestamp without time zone, IN par_terminal_id character varying, IN par_old_nok_name character varying, IN par_document_flag character varying DEFAULT NULL::bpchar, IN par_eh_code character varying DEFAULT NULL::bpchar, IN par_source_hosp_code character varying DEFAULT NULL::bpchar, IN par_source_case_no character varying DEFAULT NULL::bpchar, IN par_hkic_symbol character varying DEFAULT NULL::bpchar, IN par_hkic_symbol_clear character varying DEFAULT 'N'::bpchar, IN par_move_episode_status character varying DEFAULT NULL::bpchar, IN par_me_info_source_code character varying DEFAULT NULL::bpchar, IN par_me_reason_code character varying DEFAULT NULL::bpchar, IN par_me_other_reason character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* -- add hosp_code as iput parm by WL on 27 July 1999 --- */
DECLARE
    var_update_type VARCHAR(01);
    /* --@hosp_code			char(03), */
    var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_error_msg VARCHAR(255);
    var_movement_count INTEGER;
    var_old_user_id VARCHAR(08);
    var_old_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_chi_name VARCHAR(12);
    var_reference VARCHAR(20);
    var_remark VARCHAR(255);
    var_death_code VARCHAR(04);
    var_card_holder INTEGER;
    var_case_access_code INTEGER;
    var_pmi_access_code INTEGER;
    var_sub_specialty VARCHAR(04);
    var_case_type VARCHAR(01);
    var_security INTEGER;
    var_upd_hkid VARCHAR(12);
    var_eis_code VARCHAR(3);
    sql$rowcount BIGINT;
BEGIN
    <<error>>
    BEGIN
        /* -- remark hosp_code because it is input parm by WL 27-7-99-- */

        /* variable declared for cpi */
        /* -- remark by WL on 27 July 1999 for HPI --- */

        /* get hospital code */

        /*
        select @hosp_code = Text_value from Hospital_control
              where Type = hospital_code

        	select @rowcount = @@rowcount
        	if @rowcount != 1
        	begin
              select @retcode = 200016
              raiserror @retcode
              goto error
           end
        */

        /* **************************** */

        /* Cancellation of Admission */

        /* **************************** */
        raise notice '[hasp_adt_function_woresult]-test';
        IF par_Type = '200' OR /* Cancellation of A&E Case */ par_Type = '201' OR /* Cancellation of In-patient Case */ par_Type = '080' THEN /* Cancellation of Old Case */
            BEGIN
                /* Update ADT database */
                IF par_Type = '200' OR par_Type = '201' THEN
                    SELECT
                        1
                        INTO var_movement_count;
                ELSE
                    SELECT
                        2
                        INTO var_movement_count;
                END IF;
                /* ------------------------------------------------------------------------- */
                /* 20160420 Philip : */

                /* ------------------------------------------------------------------------- */

                /* --declare @linked_hospital char(3),@linked_case char(12),@return_result char(1),@return_code int */
                CALL hasp_get_linked_case(var_retcode, par_HKID, par_hosp_code, par_Case_no, NULL, NULL, NULL, NULL);

                IF var_retcode > 0 THEN /* -----LinkEpisode Records Found */
                    BEGIN
                        SELECT
                            CONCAT(CASE CAST (par_Case_no AS VARCHAR(12))
                                WHEN '' THEN ' '
                                ELSE CAST (par_Case_no AS VARCHAR(12))
                            END, ' was linked by other case.  Please check and remove the linkage!')
                            INTO var_error_msg;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200039';
                    END;
                END IF;
                /* ------------------------------------------------------------------------- */
                /* -- Remove all local update for HPI by WL on 27 July 99 -- */

                /* --	Delete ADT_Case */

                /* --	where Case_no = @Case_no */

                /* --	and Movement_count = @movement_count */

                /* --	and System_datetime = @Last_update_datetime */

                /* --	select @error = @@error, @rowcount = @@rowcount */

                /* --	if @error != 0 */

                /* --	begin */

                /* --		select @retcode = @error */

                /* --		goto error */

                /* --	end */

                /* --	if @rowcount != 1 */

                /* --	begin */

                /* --		select @error_msg = Cannot delete row from Case table */

                /* --		select @retcode = @error */

                /* --		raiserror 200026, @error_msg */

                /* --		goto error */

                /* --	end */
                /* -- Remove all local update for HPI by WL on 27 Jul 99 -- */

                /* --if @Type = '200' or @Type = '201' */

                /* --begin */

                /* --	Delete Ward_list */

                /* --	where Case_no = @Case_no */

                /* --	select @error = @@error, @rowcount = @@rowcount */

                /* --	if @error != 0 */

                /* --	begin */

                /* --		select @retcode = @error */

                /* --		goto error */

                /* --	end */

                /* --	if @rowcount != 1 */

                /* --	begin */

                /* --		select @error_msg = Cannot delete row from Ward_list table */

                /* --		select @retcode = @error */

                /* --		raiserror 200026, @error_msg */

                /* --		goto error */

                /* --	end */

                /* --	end */

                /* Update CPI database */
                IF par_Type = '200' THEN
                    SELECT
                        'A'
                        INTO var_case_type;
                ELSE
                    SELECT
                        'I'
                        INTO var_case_type;
                END IF;
                /* --- remove cpi.. by WL on 27 Jul 99 -- */

                /* --exec @retcode = cpi..cpi_cancel_admission */
                CALL cpi_cancel_admission(var_retcode, par_hosp_code, par_Case_no, par_HKID, par_Ward_code, par_Ward_class, par_Bed_no, par_Specialty_code, NULL, var_case_type, par_Type, par_System_datetime, par_User_ID, 'ADT');

                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 Jul 99 -- */

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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                        
                    END;
                END IF;
            END;
        END IF;
        /* ***************************** */
        /* Patient demographic update */
        /* ***************************** */
        IF par_Type = '030' then

            begin
	           raise notice '[hasp_adt_function_woresult]-030';

                /* --- remove cpi.. by WL on 27 Jul 99 --- */
                SELECT
                    chi_name, reference, death_code, card_holder, access_code, security
                    INTO var_chi_name, var_reference, var_death_code, var_card_holder, var_pmi_access_code, var_security
                    /* --from cpi..cpi_patient */
                    FROM cpi_patient
                    WHERE hkid = par_HKID;
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
                        RAISE exception '';
                    END;
                END IF;

                IF var_rowcount = 0 THEN
                    BEGIN
                        SELECT
                            2147483647
                            INTO var_pmi_access_code;
                        SELECT
                            0
                            INTO var_security;
                    END;
                END IF;

                IF par_Old_HKID = par_HKID OR (par_Old_HKID is NULL AND var_rowcount = 0) THEN
                    BEGIN
                        SELECT
                            par_HKID
                            INTO var_upd_hkid;
                    END;
                ELSE
                    BEGIN
                        IF par_Old_HKID != par_HKID THEN
                            BEGIN
                                SELECT
                                    par_Old_HKID
                                    INTO var_upd_hkid;
                            END;
                        END IF;
                    END;
                END IF;
                /* --- Remove cpi.. by WL on 27 Jul 99 --- */

                /* --exec @retcode = cpi..cpi_patient_update */
                     raise notice '[hasp_adt_function_woresult]-cpi_patient_update';
                CALL cpi_patient_update(var_retcode, par_hosp_code, var_upd_hkid, par_Name, par_Sex, par_DOB, par_Exact_DOB_flag, par_CCC_1, par_CCC_2, par_CCC_3, par_CCC_4, par_CCC_5, par_CCC_6, var_chi_name, par_Marital_status, par_Race_code, par_Other_document_no, var_reference, par_Medical_record_number, var_remark, par_Building, par_Room, par_Floor, par_Block, par_District_code, par_Religion_code, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_Death_indicator, par_Death_date, var_death_code, var_card_holder, par_T_PRK, par_NOK_priority, par_NOK_name, par_NOK_HKID, par_NOK_relation_code, par_NOK_building, par_NOK_room, par_NOK_floor, par_NOK_block, par_NOK_district_code, par_NOK_phone1, par_NOK_phone2, par_NOK_address_indicator, par_NOK_mobile_phone, par_NOK_sms_language, par_Type, var_pmi_access_code, var_security, par_System_datetime, par_hosp_code, par_User_ID, par_Last_update_datetime, 'ADT', par_Document_flag, par_hkic_symbol, par_hkic_symbol_clear);
					 raise notice '[hasp_adt_function_woresult]-030--var_retcode=%',var_retcode;

                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 Jul 99 -- */

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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                    END;
                END IF;

                IF par_Old_HKID = par_HKID OR (par_Old_HKID is NULL AND var_rowcount = 0) THEN
                    begin
	                    raise notice '[hasp_adt_function_woresult]-par_Old_HKID = par_HKID';
                        SELECT
                            var_rowcount
                            INTO var_rowcount;
                    END;
                ELSE
                    BEGIN
                        /* -- remove cpi.. by WL on 27 Jul 9 -- */
	                    raise notice '[hasp_adt_function_woresult]-par_Old_HKID != par_HKID';
                        SELECT
                            update_dtm
                            INTO par_Last_update_datetime
                            /* --from cpi..cpi_patient */
                            FROM cpi_patient
                            WHERE hkid = par_Old_HKID;
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
                                pas_return_code := var_error;
                                RETURN;
                            END;
                        END IF;

                        IF var_rowcount = 0 THEN
                            BEGIN
                                SELECT
                                    'Cannot get cpi_patient'
                                    INTO var_error_msg;
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                            END;
                        END IF;
                        /* -- remove cpi.. by WL on 27 Jul 99 -- */

                        /* --exec @retcode = cpi..cpi_change_hkid */
                        CALL cpi_change_hkid(var_retcode, par_hosp_code, par_Old_HKID, par_T_PRK, par_HKID, '031', par_System_datetime, par_User_ID, par_Last_update_datetime, 'ADT');

                        IF var_retcode != 0 THEN
                            BEGIN
                                /* -- remove cpi.. by WL on 27 Jul 99 -- */

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
                                                WHEN '' THEN ' '
                                                ELSE CAST (var_retcode AS VARCHAR(8))
                                            END)
                                            INTO var_error_msg;
                                    END;
                                END IF;
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                            END;
                        END IF;
                        /* Update the new HKID */
                        SELECT
                            update_dtm
                            INTO par_Last_update_datetime
                            FROM cpi_patient
                            WHERE hkid = par_HKID;
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
                                pas_return_code := var_error;
                                RETURN;
                            END;
                        END IF;

                        IF var_rowcount = 0 THEN
                            BEGIN
                                SELECT
                                    'Cannot get cpi_patient'
                                    INTO var_error_msg;
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                            END;
                        END IF;
                        CALL cpi_patient_update(var_retcode, par_hosp_code, par_HKID, par_Name, par_Sex, par_DOB, par_Exact_DOB_flag, par_CCC_1, par_CCC_2, par_CCC_3, par_CCC_4, par_CCC_5, par_CCC_6, var_chi_name, par_Marital_status, par_Race_code, par_Other_document_no, var_reference, par_Medical_record_number, var_remark, par_Building, par_Room, par_Floor, par_Block, par_District_code, par_Religion_code, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_Death_indicator, par_Death_date, var_death_code, var_card_holder, par_T_PRK, par_NOK_priority, par_NOK_name, par_NOK_HKID, par_NOK_relation_code, par_NOK_building, par_NOK_room, par_NOK_floor, par_NOK_block, par_NOK_district_code, par_NOK_phone1, par_NOK_phone2, par_NOK_address_indicator, par_NOK_mobile_phone, par_NOK_sms_language, par_Type, var_pmi_access_code, var_security, par_System_datetime, par_hosp_code, par_User_ID, par_Last_update_datetime, 'ADT', par_Document_flag, par_hkic_symbol, par_hkic_symbol_clear);

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
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* ************************ */
        /* Patient registration */
        /* ************************ */
        IF par_Type = '010' THEN
            BEGIN
                SELECT
                    2147483647
                    INTO var_pmi_access_code;
                SELECT
                    0
                    INTO var_security;
                /* -- remove cpi.. by WL on 27 Jul 99 --- */
                raise notice '[hasp_adt_function_woresult]---010';
                /* --exec @retcode = cpi..cpi_patient_update */
                CALL cpi_patient_update(pas_return_code => var_retcode, par_hospital_code => par_hosp_code, par_hkid => par_HKID, par_patient_name => par_Name, par_sex => par_Sex, par_dob => par_DOB, par_exact_dob_flag => par_Exact_DOB_flag, par_ccc_1 => par_CCC_1, par_ccc_2 => par_CCC_2, par_ccc_3 => par_CCC_3, par_ccc_4 => par_CCC_4, par_ccc_5 => par_CCC_5, par_ccc_6 => par_CCC_6, par_chi_name => var_chi_name, par_marital_status => par_Marital_status, par_race_code => par_Race_code, par_other_document_no => par_Other_document_no, par_reference => var_reference, par_medical_record_number => par_Medical_record_number, par_remark => var_remark, par_building => par_Building, par_room => par_Room, par_floor => par_Floor, par_block => par_Block, par_district_code => par_District_code, par_religion_code => par_Religion_code, par_phone1 => par_phone1, par_phone2 => par_phone2, par_address_indicator => par_address_indicator, par_mobile_phone => par_mobile_phone, par_sms_language => par_sms_language, par_death_indicator => par_Death_indicator, par_death_date => par_Death_date, par_death_code => var_death_code, par_card_holder => var_card_holder, par_patient_key => par_T_PRK, par_priority => par_NOK_priority, par_nok_name => par_NOK_name, par_nok_hkid => par_NOK_HKID, par_nok_relation_code => par_NOK_relation_code, par_nok_building => par_NOK_building, par_nok_room => par_NOK_room, par_nok_floor => par_NOK_floor, par_nok_block => par_NOK_block, par_nok_district_code => par_NOK_district_code, par_nok_phone1 => par_NOK_phone1, par_nok_phone2 => par_NOK_phone2, par_nok_address_indicator => par_NOK_address_indicator, par_nok_mobile_phone => par_NOK_mobile_phone, par_nok_sms_language => par_NOK_sms_language, par_txn_type => par_Type, par_access_code => var_pmi_access_code, par_security => var_security, par_transaction_datetime => par_System_datetime, par_update_hospital => par_hosp_code, par_update_by => par_User_ID, par_last_update_datetime => par_Last_update_datetime, par_source_system => 'ADT', par_document_flag => par_Document_flag, par_hkic_symbol => par_hkic_symbol, par_hkic_symbol_clear => par_hkic_symbol_clear);
                raise notice '[hasp_adt_function_woresult]---var_retcode=%',var_retcode;
                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 Jul 99 -- */
                        SELECT
                            messages
                            INTO var_error_msg
                            /* --from cpi..error_msgs */
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
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                    END;
                END IF;
            END;
        END IF;
        /* ******************************** */
        /* Update admission registration */
        /* ******************************** */
        IF par_Type = '121' OR /* In-patient Admission Update */ par_Type = '341' THEN /* A&E Admission Update */
            BEGIN
                IF par_Type = '121' THEN
                    SELECT
                        'I'
                        INTO var_case_type;
                ELSE
                    SELECT
                        'A'
                        INTO var_case_type;
                END IF;
                SELECT
                    par_NOK_relation_code
                    INTO var_update_type;

                IF var_case_type = 'I' THEN
                    BEGIN
                        SELECT
                            IMIS_code
                            INTO var_eis_code
                            FROM (SELECT
                                IMIS_code, Specialty_code, Effective_date, Active_status
                                FROM Specialty) AS ungrouped_query
                            INNER JOIN (SELECT
                                Specialty_code, MAX(Effective_date) AS max_1
                                FROM Specialty
                                WHERE Specialty_code = par_Specialty_code AND Effective_date <= par_Admission_datetime
                                GROUP BY Specialty_code) AS grouped_query
                                ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                            WHERE Effective_date = max_1 AND Active_status = 'A';
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        BEGIN
                            var_rowcount := sql$rowcount;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;

                        IF var_error != 0 OR var_rowcount != 1 THEN
                            BEGIN
                                SELECT
                                    200026
                                    INTO var_retcode;
                                /* YL PasCr-2016/00191 */
                                RAISE EXCEPTION '% ', 'Invalid/Inactive specialty code is selected!' USING ERRCODE := var_retcode;
                            END;
                        END IF;

                        IF par_Admission_datetime >= '20161101' THEN
                            BEGIN
                                IF var_eis_code = 'MIX' THEN
                                    BEGIN
                                        SELECT
                                            29999
                                            INTO var_retcode;
                                        SELECT
                                            'Patient admission to EIS MIX specialty is not allowed'
                                            INTO var_error_msg;
                                           
                                        	RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
                                    END;
                                END IF;

                                IF var_eis_code = 'SKD' AND par_hosp_code NOT IN ('PYN', 'QEH', 'PWH') THEN
                                    BEGIN
                                        SELECT
                                            29999
                                            INTO var_retcode;
                                        SELECT
                                            'Patient admission to EIS SKD specialty is not allowed'
                                            INTO var_error_msg;
                                        RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
                                    END;
                                END IF;

                                IF var_eis_code = 'OTH' AND par_hosp_code NOT IN ('PWH', 'OLM', 'PYN') THEN
                                    BEGIN
                                        SELECT
                                            29999
                                            INTO var_retcode;
                                        SELECT
                                            'Patient admission to EIS OTH specialty is not allowed'
                                            INTO var_error_msg;
                                        RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
                /* -- remove cpi.. by WL on 27 Jul 99 --- */
				 raise notice 'xxxxxxxxxxxxxxxxxx par_case_no=x%x',par_case_no;
                /* --exec @retcode = cpi..cpi_update_adm_registration */
                CALL cpi_update_adm_registration(pas_return_code => var_retcode, par_hospital_code => par_hosp_code, par_case_no => par_Case_no, par_hkid => par_HKID, par_admission_datetime => par_Admission_datetime, par_source_indicator => par_Source_indicator, par_source_code => par_Source_code, par_patient_type => par_Pay_code, par_discharge_code => par_Discharge_code, par_discharge_datetime => par_Discharge_datetime, par_destination_code => par_Destination_code, par_ambulance_no => par_Ambulance_no, par_police_case => par_Police_case, par_labour_case => par_Labour_case, par_ae_case_type => par_AE_case_type, par_dba_flag => par_DBA_flag, par_follow_up_datetime => par_Follow_up_datetime, par_ward_code => par_Ward_code, par_ward_class => par_Ward_class, par_bed_no => par_Bed_no, par_specialty_code => par_Specialty_code, par_sub_specialty => NULL, par_pp_code => par_PP_code, par_case_type => var_case_type, par_txn_type => par_Type, par_transaction_datetime => par_System_datetime, par_update_by => par_User_ID, par_source_system => 'ADT', par_update_type => var_update_type, par_document_flag => par_Document_flag, par_eh_code => par_eh_code, par_source_hosp_code => par_source_hosp_code, par_source_case_no => par_source_case_no);

				 raise notice 'hasp_adt_function_woresult[call]cpi_update_adm_registration var_retcode=%',var_retcode;
                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 Jul 99 -- */

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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                    END;
                END IF;
            END;
        END IF;
        /* ****************** */
        /* Move episode */
        /* ****************** */
        IF par_Type = '040' THEN
            BEGIN
                /*
                ---20050901 ---
                --- Ensure ONLY one records for eache Baby HKID ---
                if exists(select * from mother_baby_case_view
                	where baby_hkid = @Old_HKID)
                begin
                	if exists(select * from mother_baby_case_view
                		where baby_hkid = @HKID)
                	begin
                		select @retcode = 200026
                		select @error_msg = 'The Mother Baby Relationship already exists for the Patient !'
                		raiserror 200026 @error_msg
                		goto error
                	end
                end
                ---20050901 ---
                */

                /* ---add hosp code by WL on 27 Jul 99 --- */
                SELECT
                    User_ID, System_datetime
                    INTO var_old_user_id, var_old_system_datetime
                    FROM ADT_Case
                    WHERE Case_no = par_Case_no AND Hospital_code = par_hosp_code;
                /* Update ADT database */
                /* --- remove local update by WL on 27 Jul 99 --- */

                /* --	update ADT_Case */

                /* --	set T_PRK = @T_PRK, */

                /* --		User_ID = @User_ID, */

                /* --		System_datetime = @System_datetime */

                /* --	where Case_no = @Case_no */

                /* --	and T_PRK = @Old_T_PRK */

                /* --		select @rowcount = @@rowcount, @error = @@error */

                /* --		if @error != 0 */

                /* --		begin */

                /* --		  return @error */

                /* --		end */

                /* --		if @rowcount != 1 */

                /* --		begin */

                /* --		   raiserror 200014,Update,Case,@Case_no */

                /* --		   return */

                /* --		end */

                /* --		if ( select count(*) from Case_key_changed where */
                /* Case_no = @Case_no ) = 0 */
                /* begin */
                /* Insert Case_key_changed */
                /* (Case_no, */
                /* Old_HKID, */
                /* User_ID, */
                /* System_datetime) */
                /* values */
                /* (@Case_no, */
                /* @Old_HKID, */
                /* @old_user_id, */
                /* @old_system_datetime) */
                /* select @rowcount = @@rowcount, @error = @@error */
                /* if @error != 0 */
                /* begin */
                /* select @retcode = @error */
                /* goto error */
                /* end */
                /* if @rowcount != 1 */
                /* begin */
                /* select @retcode = 200026 */
                /* raiserror @retcode, Cannot insert Case_key_changed Table */
                /* goto error */

                /* --end */
                /* end */
                /* Insert Case_key_changed */
                /* (Case_no, */
                /* Old_HKID, */
                /* User_ID, */
                /* System_datetime) */

                /* --values */
                /* (@Case_no, */
                /* @HKID, */
                /* @User_ID, */
                /* @System_datetime) */

                /* --	   select @rowcount = @@rowcount, @error = @@error */
                /* if @error != 0 */

                /* --	   begin */
                /* select @retcode = @error */

                /* --	      goto error */
                /* end */

                /* --		if @rowcount != 1 */

                /* --		begin */
                /* select @retcode = 200026 */
                /* raiserror @retcode, Cannot insert Case_key_changed Table */
                /* goto error */

                /* --	end */

                /* Update CPI datebase */
                IF SUBSTRING(par_Case_no, 2, 2) = 'HN' THEN
                    SELECT
                        'I'
                        INTO var_case_type;
                END IF;

                IF SUBSTRING(par_Case_no, 2, 2) = 'AE' THEN
                    SELECT
                        'A'
                        INTO var_case_type;
                END IF;
                /* -- remove cpi.. by WL on 27 Jul 99--- */

                /* --exec @retcode = cpi..cpi_move_episodes */
                CALL cpi_move_episodes(var_retcode, par_hosp_code, par_Case_no, par_Old_HKID, par_Old_T_PRK, par_HKID, par_T_PRK, var_case_type, par_Type, par_System_datetime, par_User_ID, 'ADT', par_move_episode_status, par_me_info_source_code, par_me_reason_code, par_me_other_reason);

                IF var_retcode != 0 THEN
                    BEGIN
                        /* --- remove cpi.. by WL on 27 Jul 99 --- */

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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                    END;
                END IF;
            END;
        END IF;
        /* ************** */
        /* update NOK */
        /* ************** */
        IF par_Type = '050' THEN
            begin
	             raise notice '[hasp_adt_function_woresult]---050';
                /* -- remove cpi.. by WL on 27 Jul 99 -- */

                /* --exec @retcode = cpi..cpi_nok_update */
                -- CALL cpi_nok_update(par_hosp_code, par_T_PRK, par_NOK_priority, par_NOK_name, par_NOK_HKID, par_NOK_relation_code, par_NOK_building, par_NOK_room, par_NOK_floor, par_NOK_block, par_NOK_district_code, par_NOK_phone1, par_NOK_phone2, par_NOK_address_indicator, par_NOK_mobile_phone, par_NOK_sms_language, par_Type, par_System_datetime, par_User_ID, 'ADT', var_case_type, par_Type, par_System_datetime, par_User_ID, 'ADT',var_retcode);
	            CALL cpi_nok_update(var_retcode, par_hosp_code, par_T_PRK, par_NOK_priority, par_NOK_name, par_NOK_HKID, par_NOK_relation_code, par_NOK_building, par_NOK_room, par_NOK_floor, par_NOK_block, par_NOK_district_code, par_NOK_phone1, par_NOK_phone2, par_NOK_address_indicator, par_NOK_mobile_phone, par_NOK_sms_language, par_Type, par_System_datetime, par_User_ID, 'ADT'::character varying);
				raise notice '[hasp_adt_function_woresult]---050-var_retcode=%',var_retcode;
                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 Jul 99 -- */

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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                    END;
                END IF;
            END;
        END IF;
        /* --	select @T_PRK */
    END;
	EXCEPTION
		WHEN OTHERS then
		BEGIN
			RAISE NOTICE 'hasp_adt_function_woresult execute error => %',SQLERRM;
			pas_return_code := var_retcode;
			RAISE EXCEPTION '%', SQLERRM USING ERRCODE := '03000';
		END;	
   
    RETURN;

END;
$procedure$
;

;ALTER PROCEDURE "hasp_adt_function_woresult" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
