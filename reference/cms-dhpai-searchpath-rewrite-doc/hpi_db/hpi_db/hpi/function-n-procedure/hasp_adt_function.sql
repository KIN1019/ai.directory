-- DROP PROCEDURE hasp_adt_function(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_adt_function(INOUT pas_return_code integer, IN par_hosp_code character varying, IN "par_System_datetime" timestamp without time zone, IN "par_Type" character varying, IN "par_HKID" character varying, IN "par_Name" character varying, IN "par_Sex" character varying, IN "par_DOB" timestamp without time zone, IN "par_Exact_DOB_flag" character varying, IN "par_CCC_1" character varying, IN "par_CCC_2" character varying, IN "par_CCC_3" character varying, IN "par_CCC_4" character varying, IN "par_CCC_5" character varying, IN "par_CCC_6" character varying, IN "par_Marital_status" character varying, IN "par_Race_code" character varying, IN "par_Other_document_no" character varying, IN "par_Medical_record_number" character varying, IN "par_Building" character varying, IN "par_Room" character varying, IN "par_Floor" character varying, IN "par_Block" character varying, IN "par_District_code" character varying, IN "par_Religion_code" character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN "par_Death_indicator" character varying, IN "par_Death_date" timestamp without time zone, IN "par_T_PRK" character varying, IN "par_NOK_priority" integer, IN "par_NOK_name" character varying, IN "par_NOK_HKID" character varying, IN "par_NOK_relation_code" character varying, IN "par_NOK_building" character varying, IN "par_NOK_room" character varying, IN "par_NOK_floor" character varying, IN "par_NOK_block" character varying, IN "par_NOK_district_code" character varying, IN "par_NOK_phone1" character varying, IN "par_NOK_phone2" character varying, IN "par_NOK_address_indicator" character varying, IN "par_NOK_mobile_phone" character varying, IN "par_NOK_sms_language" character varying, IN "par_Case_no" character varying, IN "par_Admission_datetime" timestamp without time zone, IN "par_Source_indicator" character varying, IN "par_Source_code" character varying, IN "par_Pay_code" character varying, IN "par_Discharge_code" character varying, IN "par_Discharge_datetime" timestamp without time zone, IN "par_Destination_code" character varying, IN "par_Case_type" character varying, IN "par_Movement_count" integer, IN "par_Security_count" integer, IN "par_Case_access_code" integer, IN "par_PMI_access_code" integer, IN "par_Ambulance_no" character varying, IN "par_Police_case" character varying, IN "par_Labour_case" character varying, IN "par_AE_case_type" character varying, IN "par_DBA_flag" character varying, IN "par_Follow_up_datetime" timestamp without time zone, IN "par_Ward_code" character varying, IN "par_Specialty_code" character varying, IN "par_Bed_no" character varying, IN "par_Ward_class" character varying, IN "par_Transfer_datetime" timestamp without time zone, IN "par_Old_name" character varying, IN "par_Old_HKID" character varying, IN "par_Old_sex" character varying, IN "par_Old_DOB" timestamp without time zone, IN "par_Old_ward_class" character varying, IN "par_Old_ward_code" character varying, IN "par_Old_specialty_code" character varying, IN "par_Old_bed_no" character varying, IN "par_User_ID" character varying, IN "par_Doctor_code" character varying, IN "par_Old_doctor_code" character varying, IN "par_Old_T_PRK" character varying, IN "par_PP_code" character varying, IN "par_Last_update_datetime" timestamp without time zone, IN "par_Terminal_id" character varying, IN "par_Old_NOK_name" character varying, IN "par_Document_flag" character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying, IN par_source_hosp_code character varying DEFAULT NULL::character varying, IN par_source_case_no character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_hkic_symbol_clear character varying DEFAULT 'N'::character varying, IN par_move_episode_status character varying DEFAULT NULL::character varying, IN par_me_info_source_code character varying DEFAULT NULL::character varying, IN par_me_reason_code character varying DEFAULT NULL::character varying, IN par_me_other_reason character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_update_type VARCHAR(01);
    /* --@hosp_code char(03), */
    var_retcode integer;
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
    var_hkpmi_srvr TEXT;
    var_pgm VARCHAR(80);
    var_hkpmi_down_flag VARCHAR(1);
    var_local_hosp VARCHAR(3);
    var_rpc_call VARCHAR(800);
    sql$rowcount BIGINT;
    var_unuse_return_code integer;

BEGIN
    <<error>>
    begin
	    
	    raise notice '[33]hasp_adt_function';
        /* -- remark hosp_code because it is input parm by WL 27-7-99-- */
        
        /* variable declared for cpi */
        /* -- remark by WL on 27 July 1999 for HPI --- */
        
        /* get hospital code */
        
        /*
        select @hosp_code = Text_value from Hospital_control
        where Type = "hospital_code"
        
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
	    raise notice '[57]hasp_adt_function par_Type==>%',"par_Type";

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-par_Type=>' || "par_Type",'[hasp_adt_function:63]');

        IF "par_Type" = '200' OR /* Cancellation of A&E Case */ "par_Type" = '201' OR /* Cancellation of In-patient Case */ "par_Type" = '080' THEN /* Cancellation of Old Case */
            BEGIN
                /* Update ADT database */
                IF "par_Type" = '200' OR "par_Type" = '201' THEN
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
                raise notice '[74]hasp_adt_function';

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_hasp_get_linked_case BGN','[hasp_adt_function:84]');

                /* --declare @linked_hospital char(3),@linked_case char(12),@return_result char(1),@return_code int */
--                call hasp_get_linked_case(var_retcode, "par_HKID", par_hosp_code, "par_Case_no", null::varchar, null::varchar, null::varchar, var_unuse_return_code);
               
               
                /*SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;

				BEGIN
			         perform public.dblink_connect('hkpmi'::text, var_hkpmi_srvr);
			        RAISE NOTICE 'dblink connection established';
			   
			        SELECT '.hkpmi_get_linked_case'
			            INTO var_pgm; /* ---Default DB =download for HKPMI2 !!! */
			        SELECT
			            concat(schema_name, var_pgm)  
			        INTO var_rpc_call
			        FROM hkpmi_control;
					RAISE NOTICE 'call hkpmi_get_linked_case %,%,%,%',var_retcode,"par_HKID",par_hosp_code,"par_Case_no";

			        BEGIN
			            SELECT * FROM public.dblink('hkpmi'::text, 'call ' 
			            || var_rpc_call || '(' 
			            || case when var_retcode is null then 0 else 0 end || ','
			            || case when "par_HKID" is null then 'null::bpchar' else concat('''', "par_HKID", '''::bpchar') end || ','
			            || case when par_hosp_code is null then 'null::bpchar' else concat('''', par_hosp_code, '''::bpchar') end || ','
			            || case when "par_Case_no" is null then 'null::bpchar' else concat('''', "par_Case_no", '''::bpchar') end || ','
			            || 'null::bpchar,' -- par_linked_hospital
			            || 'null::bpchar,' -- par_linked_case
			            || 'null::bpchar)' -- par_return_result
			            ) as t1(var_retcode INTEGER) into var_retcode;
			            perform public.dblink_disconnect('hkpmi'::text);
			        exception
			            when others then
			            perform public.dblink_disconnect('hkpmi'::text);
			           RAISE NOTICE 'dblink error: %', SQLERRM;
			        end;
			       SET SEARCH_PATH TO HPI;
			       raise notice 'var_retcode:%',var_retcode;
               

				raise notice '[77]hasp_adt_function';*/
               BEGIN 
	               
	           		-- replace_dblink_by_fdw
	       			CALL hkpmi.hkpmi_get_linked_case(var_retcode,"par_HKID",par_hosp_code,"par_Case_no",null::varchar,null::varchar,null::varchar);
	       			SET search_path TO hpi,public;
	       			RAISE NOTICE 'CALL hkpmi.hkpmi_get_linked_case done ,var_retcode => %',var_retcode;
	
	--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_hasp_get_linked_case END','[hasp_adt_function:91]');
	
	                IF var_retcode > 0 THEN /* -----LinkEpisode Records Found */
	                    BEGIN
	                        SELECT
	                            CONCAT(CASE CAST ("par_Case_no" AS VARCHAR(12))
	                                WHEN '' THEN ' '
	                                ELSE CAST ("par_Case_no" AS VARCHAR(12))
	                            END, ' was linked by other case. Please check and remove the linkage!')
	                            INTO var_error_msg;
	                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '20039';
	                        EXIT error;
	                    END;
	                END IF;
			    END;
					   
                /* ------------------------------------------------------------------------- */
                /* -- Remove all local update for HPI by WL on 27 July 99 -- */
                /* Delete ADT_Case */
                /* where Case_no = @Case_no */
                /* and Movement_count = @movement_count */
                /* and System_datetime = @Last_update_datetime */
                /* select @error = @@error, @rowcount = @@rowcount */
                /* if @error != 0 */
                /* begin */
                /* select @retcode = @error */
                /* goto error */
                /* end */
                /* if @rowcount != 1 */
                /* begin */
                /* select @error_msg = "Cannot delete row from Case table" */
                /* select @retcode = @error */
                /* raiserror 20026, @error_msg */
                /* goto error */
                /* end */
                /* -- Remove all local update for HPI by WL on 27 Jul 99 -- */
                
                /* --if @Type = '200' or @Type = '201' */
                
                /* --begin */
                /* Delete Ward_list */
                /* where Case_no = @Case_no */
                /* select @error = @@error, @rowcount = @@rowcount */
                /* if @error != 0 */
                /* begin */
                /* select @retcode = @error */
                /* goto error */
                /* end */
                /* if @rowcount != 1 */
                /* begin */
                /* select @error_msg = "Cannot delete row from Ward_list table" */
                /* select @retcode = @error */
                /* raiserror 20026, @error_msg */
                /* goto error */
                /* end */
                /* end */
                raise notice '[130]hasp_adt_function';
                /* Update CPI database */
                IF "par_Type" = '200' THEN
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
               raise notice 'begin cpi_cancel_admission';

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_cpi_cancel_admission BGN','[hasp_adt_function:162]');

                CALL cpi_cancel_admission(var_retcode, par_hosp_code, "par_Case_no", "par_HKID", "par_Ward_code", "par_Ward_class", "par_Bed_no", "par_Specialty_code", NULL, var_case_type, "par_Type", "par_System_datetime", "par_User_ID", 'ADT');
raise notice 'end cpi_cancel_admission=>%',var_retcode;

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_cpi_cancel_admission END','[hasp_adt_function:168]');

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
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ***************************** */
        /* Patient demographic update */
        /* ***************************** */
        IF "par_Type" = '030' THEN
            BEGIN
                /* --- remove cpi.. by WL on 27 Jul 99 --- */
                SELECT
                    chi_name, reference, death_code, card_holder, access_code, security
                    INTO var_chi_name, var_reference, var_death_code, var_card_holder, var_pmi_access_code, var_security
                    /* --from cpi..cpi_patient */
                    FROM cpi_patient
                    WHERE hkid = "par_HKID";
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
                        EXIT error;
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

                IF "par_Old_HKID" = "par_HKID" OR ("par_Old_HKID" = NULL AND var_rowcount = 0) THEN
                    BEGIN
                        SELECT
                            "par_HKID"
                            INTO var_upd_hkid;
                    END;
                ELSE
                    BEGIN
                        IF "par_Old_HKID" != "par_HKID" THEN
                            BEGIN
                                SELECT
                                    "par_Old_HKID"
                                    INTO var_upd_hkid;
                            END;
                        END IF;
                    END;
                END IF;
                /* --- Remove cpi.. by WL on 27 Jul 99 --- */
                
                /* --exec @retcode = cpi..cpi_patient_update */
                CALL cpi_patient_update(var_retcode, par_hosp_code, var_upd_hkid, "par_Name", "par_Sex", "par_DOB", "par_Exact_DOB_flag", "par_CCC_1", "par_CCC_2", "par_CCC_3", "par_CCC_4", "par_CCC_5", "par_CCC_6", var_chi_name, "par_Marital_status", "par_Race_code", "par_Other_document_no", var_reference, "par_Medical_record_number", var_remark, "par_Building", "par_Room", "par_Floor", "par_Block", "par_District_code", "par_Religion_code", "par_phone1", "par_phone2", "par_address_indicator", "par_mobile_phone", "par_sms_language", "par_Death_indicator", "par_Death_date", var_death_code, var_card_holder, "par_T_PRK", "par_NOK_priority", "par_NOK_name", "par_NOK_HKID", "par_NOK_relation_code", "par_NOK_building", "par_NOK_room", "par_NOK_floor", "par_NOK_block", "par_NOK_district_code", "par_NOK_phone1", "par_NOK_phone2", "par_NOK_address_indicator", "par_NOK_mobile_phone", "par_NOK_sms_language", "par_Type", var_pmi_access_code, var_security, "par_System_datetime", par_hosp_code, "par_User_ID", "par_Last_update_datetime", 'ADT', "par_Document_flag", par_hkic_symbol, par_hkic_symbol_clear);

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
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                        EXIT error;
                    END;
                END IF;

                IF "par_Old_HKID" = "par_HKID" OR ("par_Old_HKID" = NULL AND var_rowcount = 0) THEN
                    BEGIN
                        SELECT
                            var_rowcount
                            INTO var_rowcount;
                    END;
                ELSE
                    BEGIN
                        /* -- remove cpi.. by WL on 27 Jul 9 -- */
                        SELECT
                            update_dtm
                            INTO "par_Last_update_datetime"
                            /* --from cpi..cpi_patient */
                            FROM cpi_patient
                            WHERE hkid = "par_Old_HKID";
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
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                                EXIT error;
                            END;
                        END IF;
                        /* -- remove cpi.. by WL on 27 Jul 99 -- */
                        
                        /* --exec @retcode = cpi..cpi_change_hkid */
                        CALL cpi_change_hkid(var_retcode, par_hosp_code, "par_Old_HKID", "par_T_PRK", "par_HKID", '031', "par_System_datetime", "par_User_ID", "par_Last_update_datetime", 'ADT');

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
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                                EXIT error;
                            END;
                        END IF;
                        /* Update the new HKID */
                        SELECT
                            update_dtm
                            INTO "par_Last_update_datetime"
                            FROM cpi_patient
                            WHERE hkid = "par_HKID";
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
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                                EXIT error;
                            END;
                        END IF;
                        CALL cpi_patient_update(var_retcode, par_hosp_code, "par_HKID", "par_Name", "par_Sex", "par_DOB", "par_Exact_DOB_flag", "par_CCC_1", "par_CCC_2", "par_CCC_3", "par_CCC_4", "par_CCC_5", "par_CCC_6", var_chi_name, "par_Marital_status", "par_Race_code", "par_Other_document_no", var_reference, "par_Medical_record_number", var_remark, "par_Building", "par_Room", "par_Floor", "par_Block", "par_District_code", "par_Religion_code", "par_phone1", "par_phone2", "par_address_indicator", "par_mobile_phone", "par_sms_language", "par_Death_indicator", "par_Death_date", var_death_code, var_card_holder, "par_T_PRK", "par_NOK_priority", "par_NOK_name", "par_NOK_HKID", "par_NOK_relation_code", "par_NOK_building", "par_NOK_room", "par_NOK_floor", "par_NOK_block", "par_NOK_district_code", "par_NOK_phone1", "par_NOK_phone2", "par_NOK_address_indicator", "par_NOK_mobile_phone", "par_NOK_sms_language", "par_Type", var_pmi_access_code, var_security, "par_System_datetime", par_hosp_code, "par_User_ID", "par_Last_update_datetime", 'ADT', "par_Document_flag", par_hkic_symbol, par_hkic_symbol_clear,var_retcode);

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
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* ************************ */
        /* Patient registration */
        /* ************************ */
        IF "par_Type" = '010' THEN
            BEGIN
                SELECT
                    2147483647
                    INTO var_pmi_access_code;
                SELECT
                    0
                    INTO var_security;
                /* -- remove cpi.. by WL on 27 Jul 99 --- */
                
                /* --exec @retcode = cpi..cpi_patient_update */
                CALL cpi_patient_update(var_retcode, par_hosp_code, "par_HKID", "par_Name", "par_Sex", "par_DOB", "par_Exact_DOB_flag", "par_CCC_1", "par_CCC_2", "par_CCC_3", "par_CCC_4", "par_CCC_5", "par_CCC_6", var_chi_name, "par_Marital_status", "par_Race_code", "par_Other_document_no", var_reference, "par_Medical_record_number", var_remark, "par_Building", "par_Room", "par_Floor", "par_Block", "par_District_code", "par_Religion_code", "par_phone1", "par_phone2", "par_address_indicator", "par_mobile_phone", "par_sms_language", "par_Death_indicator", "par_Death_date", var_death_code, var_card_holder, "par_T_PRK", "par_NOK_priority", "par_NOK_name", "par_NOK_HKID", "par_NOK_relation_code", "par_NOK_building", "par_NOK_room", "par_NOK_floor", "par_NOK_block", "par_NOK_district_code", "par_NOK_phone1", "par_NOK_phone2", "par_NOK_address_indicator", "par_NOK_mobile_phone", "par_NOK_sms_language", "par_Type", var_pmi_access_code, var_security, "par_System_datetime", par_hosp_code, "par_User_ID", "par_Last_update_datetime", 'ADT', "par_Document_flag", par_hkic_symbol, par_hkic_symbol_clear);

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
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ******************************** */
        /* Update admission registration */
        /* ******************************** */
        IF "par_Type" = '121' OR /* In-patient Admission Update */ "par_Type" = '341' THEN /* A&E Admission Update */
            BEGIN
                IF "par_Type" = '121' THEN
                    SELECT
                        'I'
                        INTO var_case_type;
                ELSE
                    SELECT
                        'A'
                        INTO var_case_type;
                END IF;
                SELECT
                    "par_NOK_relation_code"
                    INTO var_update_type;

                IF var_case_type = 'I' THEN
                    BEGIN
                        SELECT
                            "IMIS_code"
                            INTO var_eis_code
                            FROM (SELECT
                                "IMIS_code", "Specialty_code", "Effective_date", "Active_status"
                                FROM "Specialty") AS ungrouped_query
                            INNER JOIN (SELECT
                                "Specialty_code", MAX("Effective_date") AS max_1
                                FROM "Specialty"
                                WHERE "Specialty_code" = "par_Specialty_code" AND "Effective_date" <= "par_Admission_datetime"
                                GROUP BY "Specialty_code") AS grouped_query
                                ON (ungrouped_query."Specialty_code" = grouped_query."Specialty_code" OR (ungrouped_query."Specialty_code" IS NULL AND grouped_query."Specialty_code" IS NULL))
                            WHERE "Effective_date" = max_1 AND "Active_status" = 'A';
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
                                /* YL PasCr-2016/00191 */
                                RAISE EXCEPTION '% ', 'Invalid/Inactive specialty code is selected!' USING ERRCODE = 20026;
                                EXIT error;
                            END;
                        END IF;

                        IF "par_Admission_datetime" >= '20161101' THEN
                            BEGIN
                                IF var_eis_code = 'MIX' THEN
                                    BEGIN
                                        SELECT
                                            'Patient admission to EIS MIX specialty is not allowed'
                                            INTO var_error_msg;
                                        RAISE EXCEPTION '% ', var_error_msg USING ERRCODE = 299999;
                                        EXIT error;
                                    END;
                                END IF;

                                IF var_eis_code = 'SKD' AND par_hosp_code NOT IN ('PYN', 'QEH', 'PWH') THEN
                                    BEGIN
                                        SELECT
                                            'Patient admission to EIS SKD specialty is not allowed'
                                            INTO var_error_msg;
                                        RAISE EXCEPTION '% ', var_error_msg USING ERRCODE = 299999;
                                        EXIT error;
                                    END;
                                END IF;

                                IF var_eis_code = 'OTH' AND par_hosp_code NOT IN ('PWH', 'OLM', 'PYN') THEN
                                    BEGIN
                                        SELECT
                                            'Patient admission to EIS OTH specialty is not allowed'
                                            INTO var_error_msg;
                                        RAISE EXCEPTION '% ', var_error_msg USING ERRCODE = 299999;
                                        EXIT error;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
                /* -- remove cpi.. by WL on 27 Jul 99 --- */
                
                /* --exec @retcode = cpi..cpi_update_adm_registration */
                CALL cpi_update_adm_registration(par_hospital_code => par_hosp_code, par_case_no => "par_Case_no", par_hkid => "par_HKID", par_admission_datetime => "par_Admission_datetime", par_source_indicator => "par_Source_indicator", par_source_code => "par_Source_code", par_patient_type => "par_Pay_code", par_discharge_code => "par_Discharge_code", par_discharge_datetime => "par_Discharge_datetime", par_destination_code => "par_Destination_code", par_ambulance_no => "par_Ambulance_no", par_police_case => "par_Police_case", par_labour_case => "par_Labour_case", par_ae_case_type => "par_AE_case_type", par_dba_flag => "par_DBA_flag", par_follow_up_datetime => "par_Follow_up_datetime", par_ward_code => "par_Ward_code", par_ward_class => "par_Ward_class", par_bed_no => "par_Bed_no", par_specialty_code => "par_Specialty_code", par_sub_specialty => NULL, par_pp_code => "par_PP_code", par_case_type => var_case_type, par_txn_type => "par_Type", par_transaction_datetime => "par_System_datetime", par_update_by => "par_User_ID", par_source_system => 'ADT', par_update_type => var_update_type, par_document_flag => "par_Document_flag", par_eh_code => par_eh_code, par_source_hosp_code => par_source_hosp_code, par_source_case_no => par_source_case_no, pas_return_code =>  var_retcode);


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
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ****************** */
        /* Move episode */
        /* ****************** */
        IF "par_Type" = '040' THEN
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
                select @retcode = 20026
                select @error_msg = 'The Mother Baby Relationship already exists for the Patient !'
                raiserror 20026 @error_msg
                goto error
                end
                end
                ---20050901 ---
                */
                
                /* ---add hosp code by WL on 27 Jul 99 --- */
                SELECT
                    "User_ID", "System_datetime"
                    INTO var_old_user_id, var_old_system_datetime
                    FROM "ADT_Case"
                    WHERE "Case_no" = "par_Case_no" AND "Hospital_code" = par_hosp_code;
                /* Update ADT database */
                /* --- remove local update by WL on 27 Jul 99 --- */
                /* update ADT_Case */
                /* set T_PRK = @T_PRK, */
                /* User_ID = @User_ID, */
                /* System_datetime = @System_datetime */
                /* where Case_no = @Case_no */
                /* and T_PRK = @Old_T_PRK */
                /* select @rowcount = @@rowcount, @error = @@error */
                /* if @error != 0 */
                /* begin */
                /* return @error */
                /* end */
                /* if @rowcount != 1 */
                /* begin */
                /* raiserror 200014,"Update","Case",@Case_no */
                /* return */
                /* end */
                /* if ( select count(*) from Case_key_changed where */
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
                /* select @retcode = 20026 */
                /* raiserror @retcode, "Cannot insert Case_key_changed Table" */
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
                /* select @rowcount = @@rowcount, @error = @@error */
                /* if @error != 0 */
                /* begin */
                /* select @retcode = @error */
                /* goto error */
                /* end */
                /* if @rowcount != 1 */
                /* begin */
                /* select @retcode = 20026 */
                /* raiserror @retcode, "Cannot insert Case_key_changed Table" */
                /* goto error */
                /* end */
                
                /* Update CPI datebase */
                IF SUBSTRING("par_Case_no", 2, 2) = 'HN' THEN
                    SELECT
                        'I'
                        INTO var_case_type;
                END IF;

                IF SUBSTRING("par_Case_no", 2, 2) = 'AE' THEN
                    SELECT
                        'A'
                        INTO var_case_type;
                END IF;
                /* -- remove cpi.. by WL on 27 Jul 99--- */
                
                /* --exec @retcode = cpi..cpi_move_episodes */
                CALL cpi_move_episodes(var_retcode, par_hosp_code, "par_Case_no", "par_Old_HKID", "par_Old_T_PRK", "par_HKID", "par_T_PRK", var_case_type, "par_Type", "par_System_datetime", "par_User_ID", 'ADT', par_move_episode_status, par_me_info_source_code, par_me_reason_code, par_me_other_reason);

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
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ************** */
        /* update NOK */
        /* ************** */
        IF "par_Type" = '050' THEN
            BEGIN
                /* -- remove cpi.. by WL on 27 Jul 99 -- */
                
                /* --exec @retcode = cpi..cpi_nok_update */
                CALL cpi_nok_update(var_retcode, par_hosp_code, "par_T_PRK", "par_NOK_priority", "par_NOK_name", "par_NOK_HKID", "par_NOK_relation_code", "par_NOK_building", "par_NOK_room", "par_NOK_floor", "par_NOK_block", "par_NOK_district_code", "par_NOK_phone1", "par_NOK_phone2", "par_NOK_address_indicator", "par_NOK_mobile_phone", "par_NOK_sms_language", "par_Type", "par_System_datetime", "par_User_ID", 'ADT', var_case_type, "par_Type", "par_System_datetime", "par_User_ID", 'ADT');

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
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '20026';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
       /*
        OPEN p_refcur FOR
        SELECT
            "par_T_PRK";
            */
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_adt_function" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
