-- DROP PROCEDURE cpi_change_hkid(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_change_hkid(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_new_hkid character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_upd_hosp_code character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* add to record actual update hosp */DECLARE
    var_cnt INTEGER;
    var_chk_patient_key VARCHAR(8);
    var_init_hospital INTEGER;
    var_init_source INTEGER;
    var_success_flag VARCHAR(1);
    var_exit_flag VARCHAR(1);
    var_chk_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code INTEGER;
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(01);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(01);
    var_ccc_1 VARCHAR(5);
    var_ccc_2 VARCHAR(5);
    var_ccc_3 VARCHAR(5);
    var_ccc_4 VARCHAR(5);
    var_ccc_5 VARCHAR(5);
    var_ccc_6 VARCHAR(5);
    var_chi_name VARCHAR(12);
    var_marital_status VARCHAR(1);
    var_race_code VARCHAR(2);
    var_other_document_no VARCHAR(12);
    var_reference VARCHAR(20);
    var_medical_record_number VARCHAR(8);
    var_remark VARCHAR(255);
    var_building VARCHAR(47);
    var_room VARCHAR(5);
    var_floor VARCHAR(2);
    var_block VARCHAR(2);
    var_district_code VARCHAR(5);
    var_religion_code VARCHAR(3);
    var_phone1 VARCHAR(10);
    var_phone2 VARCHAR(10);
    var_address_indicator VARCHAR(4);
    var_mobile_phone VARCHAR(10);
    var_sms_language VARCHAR(4);
    var_death_indicator VARCHAR(1);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_death_code VARCHAR(4);
    var_card_holder INTEGER;
    var_access_code INTEGER;
    var_security INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_upload_status VARCHAR(1);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_actual_upd_hosp VARCHAR(3); /* add to store update hospital */
    var_hkic_symbol VARCHAR(1);
    var_cpi_filler VARCHAR(30);
    var_hkpmi_patient_name VARCHAR(48);
    var_hkpmi_sex VARCHAR(1);
    var_hkpmi_ccc1 VARCHAR(5);
    var_hkpmi_ccc2 VARCHAR(5);
    var_hkpmi_ccc3 VARCHAR(5);
    var_hkpmi_ccc4 VARCHAR(5);
    var_hkpmi_ccc5 VARCHAR(5);
    var_hkpmi_ccc6 VARCHAR(5);
    var_hkpmi_dob TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_exact_dob_flag VARCHAR(1);
    var_hkpmi_marital VARCHAR(1);
    var_hkpmi_race VARCHAR(2);
    var_hkpmi_other_doc_no VARCHAR(12);
    var_hkpmi_mrn VARCHAR(8);
    var_hkpmi_building VARCHAR(47);
    var_hkpmi_room VARCHAR(5);
    var_hkpmi_floor VARCHAR(2);
    var_hkpmi_block VARCHAR(2);
    var_hkpmi_district VARCHAR(5);
    var_hkpmi_religion VARCHAR(3);
    var_hkpmi_phone1 VARCHAR(10);
    var_hkpmi_death_ind VARCHAR(4);
    var_hkpmi_patient_key VARCHAR(8);
    var_hkpmi_nok_name VARCHAR(48);
    var_hkpmi_nok_hkid VARCHAR(12);
    var_hkpmi_nok_building VARCHAR(47);
    var_hkpmi_nok_room VARCHAR(5);
    var_hkpmi_nok_floor VARCHAR(2);
    var_hkpmi_nok_block VARCHAR(2);
    var_hkpmi_nok_district VARCHAR(5);
    var_hkpmi_nok_phone1 VARCHAR(10);
    var_hkpmi_nok_mobile_phone VARCHAR(10);
    var_hkpmi_nok_sms_language VARCHAR(4);
    var_hkpmi_nok_relation VARCHAR(2);
    var_hkpmi_access_code INTEGER;
    var_hkpmi_chi_name VARCHAR(12);
    var_hkpmi_phone2 VARCHAR(10);
    var_hkpmi_address_indicator VARCHAR(4);
    var_hkpmi_mobile_phone VARCHAR(10);
    var_hkpmi_sms_language VARCHAR(10);
    var_hkpmi_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_hkpmi_death_diagnosis VARCHAR(4);
    var_hkpmi_death_external_cause VARCHAR(4);
    var_hkpmi_patient_type VARCHAR(3);
    var_hkpmi_pcs_count INTEGER;
    var_hkpmi_nok_phone2 VARCHAR(10);
    var_hkpmi_nok_address_indicator VARCHAR(4);
    var_hkpmi_server_name VARCHAR(20);
    var_hkpmi_prg_name VARCHAR(60);
    var_hkpmi_hkic_symbol VARCHAR(1);
    var_insert_event_log_prg VARCHAR(35);
    var_insert_event_log_type VARCHAR(3);
    var_insert_event_log_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_insert_event_log_ret_code INTEGER;
    var_nok_name VARCHAR(48);
    var_nok_hkid VARCHAR(12);
    var_nok_relation_code VARCHAR(2);
    var_nok_bldg VARCHAR(47);
    var_nok_room VARCHAR(5);
    var_nok_floor VARCHAR(2);
    var_nok_block VARCHAR(2);
    var_nok_district_code VARCHAR(5);
    var_nok_phone1 VARCHAR(10);
    var_nok_mobile_phone_1 VARCHAR(10);
    var_nok_address_indicator VARCHAR(4);
    var_nok_mobile_phone_2 VARCHAR(10);
    var_nok_sms_language VARCHAR(4);
    var_hkpmi_srvr varchar;
    var_error_msg VARCHAR(255);
    var_pmi_prk VARCHAR(8);
    var_pmi_name VARCHAR(48);
    var_pmi_sex VARCHAR(1);
    var_pmi_dob TIMESTAMP WITHOUT TIME ZONE;
    var_pmi_exact_dob VARCHAR(1);
    var_pmi_ccc_1 VARCHAR(5);
    var_pmi_ccc_2 VARCHAR(5);
    var_pmi_ccc_3 VARCHAR(5);
    var_pmi_ccc_4 VARCHAR(5);
    var_pmi_ccc_5 VARCHAR(5);
    var_pmi_ccc_6 VARCHAR(5);
    var_pmi_update_by VARCHAR(8);
    var_pmi_src_system VARCHAR(5);
    var_pmi_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_pmi_hosp_code VARCHAR(3);
    var_pmi_document_flag VARCHAR(1);
    var_pgm_name VARCHAR(30);
    var_rpc_call VARCHAR(60);
    var_retcode INTEGER;
    var_pmi_error INTEGER;
    sql$rowcount BIGINT;
    var_return_code int;
    err_msg text;
    db_sql text;    
    var_pgm VARCHAR(80);
BEGIN
    <<return_error>>
    begin 
	    SET search_path TO hpi, public;

        /* Declaration */
        /* ---------- Added by WL on 22 Feb 99 ------------ */
        /* ---- added by WL for insert event log -- */
        
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
         begin
         select @return_error_code = 20000
          select @success_flag = "N"
         goto return_error
          end
        */
        --raise notice 'cpi_change_hkid[0] par_source_system=% par_txn_type=%',par_source_system,par_txn_type;
        /* ---------------------Begin of 20051102 SL -------------------------------------------- */
        IF par_source_system <> 'DNL' AND par_txn_type = '031' THEN
            BEGIN
                /* ---1) If HKID is changed reject update if primary HKPMI server is not available */
                SELECT
                    NULL
                    INTO var_hkpmi_srvr;
                /* ---cis rpc ---- */
                --raise notice 'cpi_change_hkid[1] cpi_get_rpc_server start';
--                CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr);
               
			    SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;
                --raise notice 'cpi_change_hkid[1] cpi_get_rpc_server end pas_return_code=%',pas_return_code;
                IF var_hkpmi_srvr IS NULL THEN
                    BEGIN
                        SELECT
                            'Primary HKPMI server is not available, PMI Registration, Change HKID, Move Episode and Merge Patient functions are prohibited.'
                            INTO var_error_msg;
                        /* ---raiserror 200034 @error_msg */
                        pas_return_code := 200034;
                        RETURN;
                    END;
                END IF;
                --raise notice 'cpi_change_hkid[2] par_new_hkid=%',par_new_hkid;
                /* ---2).If HKID is changed, reject update if Change To HKID is already exist in local or HKPMI */
                IF EXISTS (SELECT
                    *
                    FROM cpi_patient
                    WHERE hkid = par_new_hkid) THEN
                    BEGIN
                        SELECT
                            'HKID already exist !'
                            INTO var_error_msg;
                        /* ---raiserror 9002 @error_msg */
                        pas_return_code := 9002;
                        RETURN
                        /* --- ??? --- error_msg: 9002 New HKID already exists in CPI, change HKID is rejected! */
                        ;
                    END;
                END IF;
               
                /* --- check HKPMI patient -- */
                SELECT
                    NULL
                    INTO var_pmi_prk;
                
               
--                CALL cpi_get_hkpmi_major_key(var_return_code, par_new_hkid, var_pmi_prk, var_pmi_name, var_pmi_sex, var_pmi_dob, var_pmi_exact_dob, var_pmi_ccc_1, var_pmi_ccc_2, var_pmi_ccc_3, var_pmi_ccc_4, var_pmi_ccc_5, var_pmi_ccc_6,
--               var_pmi_update_by, var_pmi_src_system, var_pmi_update_dtm, var_pmi_hosp_code, var_pmi_document_flag);
	
	               
			       
				BEGIN
			         /*perform public.dblink_connect('hkpmi'::text, var_hkpmi_srvr);
			        RAISE NOTICE 'dblink connection established';
			   
			        SELECT '.hkpmi_get_major_key'
			            INTO var_pgm; /* ---Default DB =download for HKPMI2 !!! */
			        SELECT
			            concat(schema_name, var_pgm)  
			        INTO var_rpc_call
			        FROM hkpmi_control;

		       
		         begin
			        perform public.dblink_connect('hkpmi'::text, var_hkpmi_srvr);

		           db_sql := 'call ' || var_rpc_call || '('
			        || case when var_return_code is null then 0 else var_return_code end || ','
			        || case when par_new_hkid is null then 'null::varchar' else concat('''', par_new_hkid, '''::varchar') end || ','
			        || case when var_pmi_prk is null then 'null::varchar' else concat('''', var_pmi_prk, '''::varchar') end || ','
			        || case when var_pmi_name is null then 'null::varchar' else concat('''', var_pmi_name, '''::varchar') end || ','
			        || case when var_pmi_sex is null then 'null::varchar' else concat('''', var_pmi_sex, '''::varchar') end || ','
			        || case when var_pmi_dob is null then 'null::timestamp without time zone' else concat('''', to_char(var_pmi_dob,'YYYY-MM-DD HH24:MI:SS'), '''::timestamp without time zone') end || ','
			        || case when var_pmi_exact_dob is null then 'null::varchar' else concat('''', var_pmi_exact_dob, '''::varchar') end || ','
			        || case when var_pmi_ccc_1 is null then 'null::varchar' else concat('''', var_pmi_ccc_1, '''::varchar') end || ','
			        || case when var_pmi_ccc_2 is null then 'null::varchar' else concat('''', var_pmi_ccc_2, '''::varchar') end || ','
			        || case when var_pmi_ccc_3 is null then 'null::varchar' else concat('''', var_pmi_ccc_3, '''::varchar') end || ','
			        || case when var_pmi_ccc_4 is null then 'null::varchar' else concat('''', var_pmi_ccc_4, '''::varchar') end || ','
			        || case when var_pmi_ccc_5 is null then 'null::varchar' else concat('''', var_pmi_ccc_5, '''::varchar') end || ','
			        || case when var_pmi_ccc_6 is null then 'null::varchar' else concat('''', var_pmi_ccc_6, '''::varchar') end || ','
			        || case when var_pmi_update_by is null then 'null::varchar' else concat('''', var_pmi_update_by, '''::varchar') end || ','
			        || case when var_pmi_src_system is null then 'null::varchar' else concat('''', var_pmi_src_system, '''::varchar') end || ','
			        || case when var_pmi_update_dtm is null then 'null::timestamp without time zone' else concat('''', to_char(var_pmi_update_dtm,'YYYY-MM-DD HH24:MI:SS'), '''::timestamp without time zone') end || ','
			        || case when var_pmi_hosp_code is null then 'null::varchar' else concat('''', var_pmi_hosp_code, '''::varchar') end || ','
			        || case when var_pmi_document_flag is null then 'null::varchar' else concat('''', var_pmi_document_flag, '''::varchar') end || ');';
			 
		 select * from public.dblink('hkpmi'::text, db_sql::text)
					 as t1(var_return_code INTEGER,var_pmi_prk varchar,var_pmi_name varchar,var_pmi_sex varchar,var_pmi_dob timestamp without time zone,var_pmi_exact_dob  varchar,var_pmi_ccc_1 varchar,var_pmi_ccc_2 varchar,var_pmi_ccc_3 varchar,var_pmi_ccc_4 varchar,var_pmi_ccc_5 varchar,var_pmi_ccc_6 varchar
			          	,par_update_by varchar,par_src_system varchar,par_update_dtm timestamp without time zone,par_hosp_code varchar,par_document_flag varchar) into
			          var_return_code,var_pmi_prk ,var_pmi_name ,var_pmi_sex ,var_pmi_dob  ,var_pmi_exact_dob ,var_pmi_ccc_1 ,var_pmi_ccc_2 ,var_pmi_ccc_3 ,var_pmi_ccc_4 ,var_pmi_ccc_5 ,var_pmi_ccc_6 
			          	,var_pmi_update_by ,var_pmi_src_system ,var_pmi_update_dtm ,var_pmi_hosp_code ,var_pmi_document_flag;
          perform public.dblink_disconnect('hkpmi'::text);
		        exception
		            when others then
		            perform public.dblink_disconnect('hkpmi'::text);
		           --RAISE NOTICE 'dblink error: %', SQLERRM;
		        end;*/
					
				-- replace_dblink_by_fdw
				CALL hkpmi.hkpmi_get_major_key(var_return_code, par_new_hkid, var_pmi_prk, var_pmi_name, var_pmi_sex, 
				var_pmi_dob, var_pmi_exact_dob, var_pmi_ccc_1, var_pmi_ccc_2, var_pmi_ccc_3, var_pmi_ccc_4, var_pmi_ccc_5, var_pmi_ccc_6, 
				var_pmi_update_by, var_pmi_src_system, var_pmi_update_dtm, var_pmi_hosp_code, var_pmi_document_flag);
				SET search_path TO hpi,public;
               
               --raise notice 'cpi_get_hkpmi_major_key end var_return_code=% var_pmi_prk=%', var_return_code,var_pmi_prk;
                IF var_pmi_prk IS NOT NULL THEN
                    /* --- HKPMI patient exist.. */
                    BEGIN
                        SELECT
                            'HKID already exist !'
                            INTO var_error_msg;
                        /* ---raiserror 9002 @error_msg */
                        pas_return_code := 9002;
                        RETURN;
                    END;
                END IF;

			        /*EXCEPTION
			        WHEN OTHERS THEN
			            RAISE NOTICE 'dblink connection failed: %', SQLERRM;*/
			    END;
			               
                /* ---------20081205 SL : Check UID ---------- */
                
                /*SELECT
                       concat(schema_name,'.hkpmi_check_merge')  
                INTO var_rpc_call
                from hkpmi_control;

                db_sql := 'call ' || var_rpc_call || '(0,'
                || case when par_hospital_code is null then 'null::varchar' else concat('''', par_hospital_code, '''::varchar') end || ','
				|| case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end || ','
				|| case when par_new_hkid is null then 'null::varchar' else concat('''', par_new_hkid, '''::varchar') end || ','
				||'0,''CHANG'');';
			    --raise notice 'cpi_change_hkid[5] %',db_sql;
                perform dblink_connect('HKPMI_SERVER',var_hkpmi_srvr);
				select * from dblink('HKPMI_SERVER', db_sql) as t1(retcode int) into var_retcode;				
				perform dblink_disconnect('HKPMI_SERVER');
                --raise notice 'cpi_change_hkid[5] hkpmi.hkpmi_check_merge end var_retcode=%',var_retcode;*/
			   
			   	-- replace_dblink_by_fdw
			   	CALL hkpmi.hkpmi_check_merge(var_retcode, par_hospital_code, par_hkid, par_new_hkid, 0::INTEGER, 'CHANG'::VARCHAR);
			   	SET search_path TO hpi,public;
			   
                IF var_retcode != 0 THEN
                    BEGIN
                        IF var_retcode = 6 THEN
                            SELECT
                                'Claimed HKID linkage exists for the patient, update HKID is not allowed. Please verify the patient identity and clear the linkage before proceeding'
                                INTO var_error_msg;
                        END IF;
                        pas_return_code := 210004;
                        RETURN;
                    END;
                END IF;
            END;
        END IF; /* --if @source_system <> 'DNL' */
        /* ---------------------End OF : 20051102 SL --------------------------------------- */
        /*
        Check whether the patient has been updated after
        processing this transaction. If so, reject the transaction.
        This makes sure the patient information is the most
        up-to-date.
        */
        SELECT
            NULL
            INTO var_chk_update_datetime;
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_patient
            WHERE patient_key = par_patient_key;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT
                    update_dtm
                    INTO var_chk_update_datetime
                    FROM cpi_patient
                    WHERE patient_key = par_patient_key;
            END;
        ELSE
            BEGIN
                SELECT
                    COUNT(*)
                    INTO var_cnt
                    FROM cpi_patient
                    WHERE hkid = par_hkid;

                IF (var_cnt != 0) THEN
                    BEGIN
                        SELECT
                            update_dtm
                            INTO var_chk_update_datetime
                            FROM cpi_patient
                            WHERE hkid = par_hkid;
                    END;
                END IF;
            END;
        END IF;
       
		--raise notice  'line->376var_chk_update_datetime=% par_last_update_datetime=%',var_chk_update_datetime,par_last_update_datetime;
        IF (var_chk_update_datetime IS NOT NULL) AND (date_trunc('second',var_chk_update_datetime) != date_trunc('second',par_last_update_datetime)) THEN
            begin
	           -- raise notice 'line->373-do their';
                /* print "Patient has been updated after transaction, patient update is rejected!" */
                SELECT
                    7016
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* Assign the transaction_datetime of source system to source_system_dtm */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        SELECT
            clock_timestamp()
            INTO par_transaction_datetime;
        /* Set flags */
        SELECT
            'Y'
            INTO var_success_flag;

        IF (par_source_system = 'DNL') THEN
            SELECT
                'N'
                INTO var_upload_status;
        ELSE
            SELECT
                'Y'
                INTO var_upload_status;
        END IF;
        /* Validate key fields */
        /* Get initiate bit values */
        /*
        select @init_hospital = bit_value
         from hospital_bits
         where hospital_code = @hospital_code
        
         if (@@rowcount = 0)
         begin
        /* print "Fail to get init. bit values from hospital_bits, change hkid is rejected!" */
         select @success_flag = "N"
         goto return_error
         end
        
         select @init_source = bit_value
         from source_bits
         where source_system = @source_system
        
         if (@@rowcount = 0)
         begin
        /* print "Fail to get init. bit values from source_bits, change hkid is rejected!" */
         select @success_flag = "N"
         goto return_error
         end
        */
        /* Check the existence of patient */
        IF par_patient_key IS NULL THEN
            BEGIN
                SELECT
                    COUNT(*)
                    INTO var_cnt
                    FROM cpi_patient
                    WHERE hkid = par_hkid;

                IF (var_cnt = 0) THEN
                    BEGIN
                        /* print "Patient does not exist in cpi_patient, change HKID is rejected!" */
                        SELECT
                            9001
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                SELECT
                    patient_key
                    INTO var_chk_patient_key
                    FROM cpi_patient
                    WHERE hkid = par_hkid;
                SELECT
                    var_chk_patient_key
                    INTO par_patient_key;
            END;
        END IF;
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_patient
            WHERE patient_key = par_patient_key;

        IF (var_cnt = 0) THEN
            BEGIN
                /* print "Patient does not exist in cpi_patient, change HKID is rejected!" */
                SELECT
                    9001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* Check the existence of New HKID in patient table */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_patient
            WHERE hkid = par_new_hkid;

        IF var_cnt != 0 THEN
            BEGIN
                /* print "New HKID already exists in CPI, change HKID is rejected!" */
                SELECT
                    9002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* check hkid whether it is an used unhkid 20040914 by Leo Lee */
        /* skip checking if source system is "DNL" 20070904 by Leo Lee */
        IF par_source_system <> 'DNL' THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM cpi_used_unhkid
                    WHERE hkid = par_new_hkid) THEN
                    BEGIN
                        SELECT
                            200033
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* ---- Move here by WL on 22 Feb 99 ---- */
        
        /*
        Get data from cpi_patient and cpi_patient_hospital_data
        for transaction
        */
        SELECT
            patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, reference, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, access_code, security, hkic_symbol
            INTO var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1, var_phone2, var_address_indicator, var_mobile_phone, var_sms_language, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_access_code, var_security, var_hkic_symbol /* ---20100928 HKIC --just retrieve from hasp_adt_function->cpi_patient_update) */
            FROM cpi_patient
            WHERE patient_key = par_patient_key;
        SELECT
            mrn, remark
            INTO var_medical_record_number, var_remark
            FROM cpi_patient_hospital_data
            WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;
        /* ------ End of Move by WL on 22 Feb 99 --------- */
        /* ---- added by WL for extract NOK info to insert event log-- */
        SELECT
            nok_name, hkid, relationship, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
            INTO var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_bldg, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_mobile_phone_1, var_nok_address_indicator, var_nok_mobile_phone_2, var_nok_sms_language
            FROM cpi_nok
            WHERE patient_key = par_patient_key AND major_nok = 'Y';
        /* ------ Get HKPMI demographic data by WL on 22 Feb 99 ---- */

          
        IF par_source_system = 'PBRC' THEN
            BEGIN
                SELECT
                    hkpmi_server
                    INTO var_hkpmi_server_name
                    FROM hkpmi_control;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            GET STACKED DIAGNOSTICS err_msg = MESSAGE_TEXT;
                            --raise notice 'cpi_change_hkid error %',err_msg;
                        	var_error := 1;
                END;

                IF (var_rowcount = 1) AND (var_error = 0) THEN
                    BEGIN

                        /*SELECT
     			 			concat(schema_name,'.hkpmi_r_pmi_parm_1')  
						INTO var_hkpmi_prg_name
						from hkpmi_control;
						perform dblink_connect('HKPMI_SERVER',var_hkpmi_server_name);				




select * from dblink('HKPMI_SERVER','CALL '
||var_hkpmi_prg_name ||'('
 || case when par_hospital_code is null then 0 else 0 end|| ','
|| case when par_hospital_code is null then 'null::varchar' else concat('''', par_hospital_code, '''::varchar') end|| ','
|| case when par_new_hkid is null then 'null::varchar' else concat('''', par_new_hkid, '''::varchar') end|| ','
||'''P'''||','
|| case when var_hkpmi_patient_name is null then 'null::varchar' else concat('''', var_hkpmi_patient_name, '''::varchar') end|| ','
|| case when var_hkpmi_sex is null then 'null::varchar' else concat('''', var_hkpmi_sex, '''::varchar') end|| ','
|| case when var_hkpmi_ccc1 is null then 'null::varchar' else concat('''', var_hkpmi_ccc1, '''::varchar') end|| ','
|| case when var_hkpmi_ccc2 is null then 'null::varchar' else concat('''', var_hkpmi_ccc2, '''::varchar') end|| ','
|| case when var_hkpmi_ccc3 is null then 'null::varchar' else concat('''', var_hkpmi_ccc3, '''::varchar') end|| ','
|| case when var_hkpmi_ccc4 is null then 'null::varchar' else concat('''', var_hkpmi_ccc4, '''::varchar') end|| ','
|| case when var_hkpmi_ccc5 is null then 'null::varchar' else concat('''', var_hkpmi_ccc5, '''::varchar') end|| ','
|| case when var_hkpmi_ccc6 is null then 'null::varchar' else concat('''', var_hkpmi_ccc6, '''::varchar') end|| ','
|| case when var_hkpmi_dob is null then 'null::varchar' else concat('''', var_hkpmi_dob, '''::varchar') end|| ','
|| case when var_hkpmi_exact_dob_flag is null then 'null::varchar' else concat('''', var_hkpmi_exact_dob_flag, '''::varchar') end|| ','
|| case when var_hkpmi_marital is null then 'null::varchar' else concat('''', var_hkpmi_marital, '''::varchar') end|| ','
|| case when var_hkpmi_race is null then 'null::varchar' else concat('''', var_hkpmi_race, '''::varchar') end|| ','
|| case when var_hkpmi_other_doc_no is null then 'null::varchar' else concat('''', var_hkpmi_other_doc_no, '''::varchar') end|| ','
|| case when var_hkpmi_mrn is null then 'null::varchar' else concat('''', var_hkpmi_mrn, '''::varchar') end|| ','
|| case when var_hkpmi_building is null then 'null::varchar' else concat('''', var_hkpmi_building, '''::varchar') end|| ','
|| case when var_hkpmi_room is null then 'null::varchar' else concat('''', var_hkpmi_room, '''::varchar') end|| ','
|| case when var_hkpmi_floor is null then 'null::varchar' else concat('''', var_hkpmi_floor, '''::varchar') end|| ','
|| case when var_hkpmi_block is null then 'null::varchar' else concat('''', var_hkpmi_block, '''::varchar') end|| ','
|| case when var_hkpmi_district is null then 'null::varchar' else concat('''', var_hkpmi_district, '''::varchar') end|| ','
|| case when var_hkpmi_religion is null then 'null::varchar' else concat('''', var_hkpmi_religion, '''::varchar') end|| ','
|| case when var_hkpmi_phone1 is null then 'null::varchar' else concat('''', var_hkpmi_phone1, '''::varchar') end|| ','
|| case when var_hkpmi_death_ind is null then 'null::varchar' else concat('''', var_hkpmi_death_ind, '''::varchar') end|| ','
|| case when var_hkpmi_patient_key is null then 'null::varchar' else concat('''', var_hkpmi_patient_key, '''::varchar') end|| ','
|| case when var_hkpmi_nok_name is null then 'null::varchar' else concat('''', var_hkpmi_nok_name, '''::varchar') end|| ','
|| case when var_hkpmi_nok_hkid is null then 'null::varchar' else concat('''', var_hkpmi_nok_hkid, '''::varchar') end|| ','
|| case when var_hkpmi_nok_building is null then 'null::varchar' else concat('''', var_hkpmi_nok_building, '''::varchar') end|| ','
|| case when var_hkpmi_nok_room is null then 'null::varchar' else concat('''', var_hkpmi_nok_room, '''::varchar') end|| ','
|| case when var_hkpmi_nok_floor is null then 'null::varchar' else concat('''', var_hkpmi_nok_floor, '''::varchar') end|| ','
|| case when var_hkpmi_nok_block is null then 'null::varchar' else concat('''', var_hkpmi_nok_block, '''::varchar') end|| ','
|| case when var_hkpmi_nok_district is null then 'null::varchar' else concat('''', var_hkpmi_nok_district, '''::varchar') end|| ','
|| case when var_hkpmi_nok_phone1 is null then 'null::varchar' else concat('''', var_hkpmi_nok_phone1, '''::varchar') end|| ','
|| case when var_hkpmi_nok_mobile_phone is null then 'null::varchar' else concat('''', var_hkpmi_nok_mobile_phone, '''::varchar') end|| ','
|| case when var_hkpmi_nok_sms_language is null then 'null::varchar' else concat('''', var_hkpmi_nok_sms_language, '''::varchar') end|| ','
|| case when var_hkpmi_nok_relation is null then 'null::varchar' else concat('''', var_hkpmi_nok_relation, '''::varchar') end|| ','
|| case when var_hkpmi_access_code is null then 'null::varchar' else concat('''', var_hkpmi_access_code, '''::varchar') end|| ','
|| case when var_hkpmi_chi_name is null then 'null::varchar' else concat('''', var_hkpmi_chi_name, '''::varchar') end|| ','
|| case when var_hkpmi_phone2 is null then 'null::varchar' else concat('''', var_hkpmi_phone2, '''::varchar') end|| ','
|| case when var_hkpmi_address_indicator is null then 'null::varchar' else concat('''', var_hkpmi_address_indicator, '''::varchar') end|| ','
|| case when var_hkpmi_mobile_phone is null then 'null::varchar' else concat('''', var_hkpmi_mobile_phone, '''::varchar') end|| ','
|| case when var_hkpmi_sms_language is null then 'null::varchar' else concat('''', var_hkpmi_sms_language, '''::varchar') end|| ','
|| case when var_hkpmi_death_date is null then 'null::varchar' else concat('''', var_hkpmi_death_date, '''::varchar') end|| ','
|| case when var_hkpmi_death_diagnosis is null then 'null::varchar' else concat('''', var_hkpmi_death_diagnosis, '''::varchar') end|| ','
|| case when var_hkpmi_death_external_cause is null then 'null::varchar' else concat('''', var_hkpmi_death_external_cause, '''::varchar') end|| ','
|| case when var_hkpmi_patient_type is null then 'null::varchar' else concat('''', var_hkpmi_patient_type, '''::varchar') end|| ','
|| case when var_hkpmi_pcs_count is null then 'null::varchar' else concat('''', var_hkpmi_pcs_count, '''::varchar') end|| ','
|| case when var_hkpmi_nok_phone2 is null then 'null::varchar' else concat('''', var_hkpmi_nok_phone2, '''::varchar') end|| ','
|| case when var_hkpmi_nok_address_indicator is null then 'null::varchar' else concat('''', var_hkpmi_nok_address_indicator, '''::varchar') end|| ','
||'''N'''||','
|| case when par_source_system is null then 'null::varchar' else concat('''', par_source_system, '''::varchar') end|| ','
|| case when par_update_by is null then 'null::varchar' else concat('''', par_update_by, '''::varchar') end|| ','
|| case when var_hkpmi_hkic_symbol is null then 'null::varchar' else concat('''', var_hkpmi_hkic_symbol, '''::varchar') end|| ','
||0||');')
 as t1(return_code integer,par_patient_name character varying,par_sex character varying,par_ccc1 character varying,par_ccc2 character varying,par_ccc3 character varying,par_ccc4 character varying,par_ccc5 character varying,par_ccc6 character varying,par_dob timestamp without time zone,par_exact_dob_flag character varying,par_marital character varying,par_race character varying,par_other_doc_no character varying,par_mrn character varying,par_building character varying,par_room character varying,par_floor character varying,par_block character varying,par_district character varying,par_religion character varying, par_phone1 character varying, par_death_ind character varying, par_patient_key character varying, par_nok_name character varying, par_nok_hkid character varying, par_nok_building character varying, par_nok_room character varying, par_nok_floor character varying, par_nok_block character varying, par_nok_district character varying, par_nok_phone1 character varying, par_nok_mobile_phone character varying, par_nok_sms_language character varying, par_nok_relation character varying, par_access_code integer, par_chi_name character varying, par_phone2 character varying, par_address_indicator character varying, par_mobile_phone character varying, par_sms_language character varying, par_death_date timestamp without time zone, par_death_diagnosis character varying, par_death_external_cause character varying, par_patient_type character varying, par_pcs_count integer, par_nok_phone2 character varying, par_nok_address_indicator character varying, par_hkic_symbol character varying) into
		pas_return_code,var_hkpmi_patient_name, var_hkpmi_sex, var_hkpmi_ccc1, var_hkpmi_ccc2, var_hkpmi_ccc3, var_hkpmi_ccc4, var_hkpmi_ccc5, var_hkpmi_ccc6, var_hkpmi_dob, var_hkpmi_exact_dob_flag, var_hkpmi_marital, var_hkpmi_race, var_hkpmi_other_doc_no,var_hkpmi_mrn, var_hkpmi_building, var_hkpmi_room, var_hkpmi_floor, var_hkpmi_block, var_hkpmi_district,var_hkpmi_religion, var_hkpmi_phone1, var_hkpmi_death_ind, var_hkpmi_patient_key, var_hkpmi_nok_name,var_hkpmi_nok_hkid, var_hkpmi_nok_building, var_hkpmi_nok_room,var_hkpmi_nok_floor, var_hkpmi_nok_block, var_hkpmi_nok_district, var_hkpmi_nok_phone1,var_hkpmi_nok_mobile_phone, var_hkpmi_nok_sms_language, var_hkpmi_nok_relation, var_hkpmi_access_code, 			var_hkpmi_chi_name, var_hkpmi_phone2, var_hkpmi_address_indicator, 			var_hkpmi_mobile_phone, var_hkpmi_sms_language, var_hkpmi_death_date, 							var_hkpmi_death_diagnosis, var_hkpmi_death_external_cause, var_hkpmi_patient_type, var_hkpmi_pcs_count, 				var_hkpmi_nok_phone2, var_hkpmi_nok_address_indicator,var_hkpmi_hkic_symbol; 
	perform dblink_disconnect('HKPMI_SERVER');
						IF var_error = 0 THEN
                            BEGIN
                                IF (var_hkpmi_patient_name <> var_patient_name) OR (var_hkpmi_sex <> var_sex) OR (var_hkpmi_dob <> var_dob) OR (COALESCE(RTRIM(var_hkpmi_ccc1), 'null') <> COALESCE(RTRIM(var_ccc_1), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc2), 'null') <> COALESCE(RTRIM(var_ccc_2), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc3), 'null') <> COALESCE(RTRIM(var_ccc_3), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc4), 'null') <> COALESCE(RTRIM(var_ccc_4), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc5), 'null') <> COALESCE(RTRIM(var_ccc_5), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc6), 'null') <> COALESCE(RTRIM(var_ccc_6), 'null')) THEN
                                    BEGIN
                                        /* print "Major Key not match!" */
                                        SELECT
                                            200003
                                            INTO var_return_error_code;
                                        SELECT
                                            'N'
                                            INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                        END IF;*/
	                    -- replace_dblink_by_fdw	
	                    CALL hkpmi.hkpmi_r_pmi_parm_1(var_retcode, par_hospital_code, par_new_hkid, 'P'::VARCHAR, 
	                    var_hkpmi_patient_name, var_hkpmi_sex, var_hkpmi_ccc1, var_hkpmi_ccc2, var_hkpmi_ccc3, var_hkpmi_ccc4, var_hkpmi_ccc5, var_hkpmi_ccc6, 
	                    var_hkpmi_dob, var_hkpmi_exact_dob_flag, var_hkpmi_marital, var_hkpmi_race, var_hkpmi_other_doc_no, var_hkpmi_mrn, var_hkpmi_building,
	                    var_hkpmi_room, var_hkpmi_floor, var_hkpmi_block, var_hkpmi_district, var_hkpmi_religion, var_hkpmi_phone1, var_hkpmi_death_ind, 
	                    var_hkpmi_patient_key, var_hkpmi_nok_name, var_hkpmi_nok_hkid, var_hkpmi_nok_building, var_hkpmi_nok_room, var_hkpmi_nok_floor,
	                    var_hkpmi_nok_block, var_hkpmi_nok_district, var_hkpmi_nok_phone1, var_hkpmi_nok_mobile_phone, var_hkpmi_nok_sms_language,
	                    var_hkpmi_nok_relation, var_hkpmi_access_code, var_hkpmi_chi_name, var_hkpmi_phone2, var_hkpmi_address_indicator, var_hkpmi_mobile_phone,
	                    var_hkpmi_sms_language, var_hkpmi_death_date, var_hkpmi_death_diagnosis, var_hkpmi_death_external_cause, var_hkpmi_patient_type, 
	                    var_hkpmi_pcs_count, var_hkpmi_nok_phone2, var_hkpmi_nok_address_indicator, 'N'::VARCHAR, par_source_system, 
	                    par_update_by, var_hkpmi_hkic_symbol) ;
	                   	SET search_path TO hpi,public;
	                   	IF var_error = 0 THEN
                            BEGIN
                                IF (var_hkpmi_patient_name <> var_patient_name) OR (var_hkpmi_sex <> var_sex) OR (var_hkpmi_dob <> var_dob) OR (COALESCE(RTRIM(var_hkpmi_ccc1), 'null') <> COALESCE(RTRIM(var_ccc_1), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc2), 'null') <> COALESCE(RTRIM(var_ccc_2), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc3), 'null') <> COALESCE(RTRIM(var_ccc_3), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc4), 'null') <> COALESCE(RTRIM(var_ccc_4), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc5), 'null') <> COALESCE(RTRIM(var_ccc_5), 'null')) OR (COALESCE(RTRIM(var_hkpmi_ccc6), 'null') <> COALESCE(RTRIM(var_ccc_6), 'null')) THEN
                                    BEGIN
                                        /* print "Major Key not match!" */
                                        SELECT
                                            200003
                                            INTO var_return_error_code;
                                        SELECT
                                            'N'
                                            INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* added to get actual update hospital code on 02.07.1999 by ML */
        IF COALESCE(RTRIM(par_upd_hosp_code), '') = '' THEN
            SELECT
                par_hospital_code
                INTO var_actual_upd_hosp;
        ELSE
            SELECT
                par_upd_hosp_code
                INTO var_actual_upd_hosp;
        END IF;
        /* end 02.07.1999 */
        /* ---20120908 --clear HKIC symbol for HKID changed to UnHKID--- */
        BEGIN
            IF SUBSTRING(par_new_hkid, 1, 1) = 'U' then
            	--raise notice '[kkkkk]%,%,%,%',par_new_hkid, par_update_by, par_transaction_datetime, var_actual_upd_hosp;
                BEGIN
                    UPDATE cpi_patient
                    SET hkid = par_new_hkid, update_by = par_update_by, update_dtm = par_transaction_datetime, update_hospital = var_actual_upd_hosp, hkic_symbol = NULL
                        /* ----- 20120908 : clear HKIC symbol for HKID change to UNHKID */
                        WHERE patient_key = par_patient_key AND hkid = par_hkid;
                    --raise notice '[602]cpi_change_hkid[UPDATE cpi_patient]par_patient_key=%',par_patient_key;
                END;
            ELSE
                BEGIN
                    UPDATE cpi_patient
                    SET hkid = par_new_hkid, update_by = par_update_by, update_dtm = par_transaction_datetime,
                    /* update_hospital = @hospital_code */
                    update_hospital = var_actual_upd_hosp
                        WHERE patient_key = par_patient_key AND hkid = par_hkid;
                    --raise notice '[611]cpi_change_hkid[UPDATE cpi_patient]par_patient_key=%',par_patient_key;
                END;
            END IF;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    GET STACKED DIAGNOSTICS err_msg = MESSAGE_TEXT;
                    
                   -- raise notice 'cpi_change_hkid error %',err_msg;
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to update cpi_patient, change hkid is rejected!" */
                SELECT
                    9003
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* -- added by WL for insert event log -- */

        IF par_source_system <> 'ADT' THEN
            BEGIN
                SELECT
                    '031'
                    INTO var_insert_event_log_type;
                SELECT
                    'hasp_insert_event_log'
                    INTO var_insert_event_log_prg;
                SELECT
                    timestamp_convert(localtimestamp)
                    INTO var_insert_event_log_dtm;
                /* -- avoid duplicat when insert event log, check first-- */
                CALL hasp_get_event_log_dtm(var_return_code, par_hospital_code, var_insert_event_log_dtm);
                CALL hasp_insert_event_log(var_insert_event_log_ret_code, par_hospital_code, var_insert_event_log_dtm, var_insert_event_log_type, par_new_hkid, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_marital_status, var_race_code, var_other_document_no, var_medical_record_number, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1, var_phone2, var_address_indicator, var_mobile_phone, var_sms_language, var_death_indicator, var_death_date, par_patient_key, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_bldg, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_mobile_phone_1, var_nok_address_indicator, var_nok_mobile_phone_2, var_nok_sms_language, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, var_access_code, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, var_patient_name, par_hkid, var_sex, var_dob, NULL, NULL, NULL, NULL, par_update_by, NULL, NULL, NULL, NULL, 'P');
				IF var_insert_event_log_ret_code <> 0 THEN
                    BEGIN
                        /* print "Fail to insert into event log for change hkid!" */
                        SELECT
                            200023
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* ------- Moved to upper part by WL on 22 Feb 99 ----------- */
        /*
        select @patient_name = patient_name,
         @sex = sex,
         @dob =dob,
         @exact_dob_flag = exact_dob_flag,
         @ccc_1 = cccode1,
         @ccc_2 = cccode2,
         @ccc_3 = cccode3,
         @ccc_4 = cccode4,
         @ccc_5 = cccode5,
         @ccc_6 = cccode6,
         @chi_name = chi_name,
         @marital_status = marital_status,
         @race_code = race,
         @other_document_no = other_doc_no,
         @reference = reference,
         @building = building,
         @room = room,
         @floor = floor,
         @block = block,
         @district_code = district,
         @religion_code = religion,
         @phone1 = phone1,
         @phone2 = phone2,
         @address_indicator = address_indicator,
         @mobile_phone = mobile_phone,
         @sms_language = sms_language,
         @death_indicator = death_indicator,
         @death_date = death_date,
         @death_code = death_code,
         @card_holder = card_holder,
        -- @access_code = access_code,
         @security = security
         from cpi_patient
         where patient_key = @patient_key
        
         select @medical_record_number = mrn,
         @remark = remark
         from cpi_patient_hospital_data
         where patient_key = @patient_key
         and hospital_code = @hospital_code
        */
        
        /*
        Prevent transaction time of different source
        system is the same. Add seconds to the transaction time.
        */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_transaction
            WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT
                    'N'
                    INTO var_exit_flag;

                WHILE (var_exit_flag = 'N') LOOP
                    SELECT
                        1 * INTERVAL '1 second' + par_transaction_datetime::TIMESTAMP
                        INTO par_transaction_datetime;
                    SELECT
                        COUNT(*)
                        INTO var_cnt
                        FROM cpi_transaction
                        WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

                    IF (var_cnt = 0) THEN
                        SELECT
                            'Y'
                            INTO var_exit_flag;
                    END IF;
                END LOOP;
            END;
        END IF;
        /* 20100928 SL */
        SELECT
            CONCAT(REPEAT(' ', 28), SUBSTRING(CONCAT(var_hkic_symbol, REPEAT(' ', 1)), 1, 1))
            INTO var_cpi_filler; /* --hkic_symbol=cpi_filler(29,1) */

        IF (LTRIM(RTRIM(var_cpi_filler)) = '') OR (LTRIM(RTRIM(var_cpi_filler)) is NULL) THEN
            SELECT
                NULL
                INTO var_cpi_filler;
        END IF;

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm, cpi_filler)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_new_hkid, par_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, var_medical_record_number, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1, var_phone2, var_address_indicator, var_mobile_phone, var_sms_language, var_death_indicator, var_death_date, var_death_code, var_card_holder, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, var_security, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hkid, NULL, NULL, NULL, NULL, NULL,
            /* NULL, NULL, NULL, @hospital_code, */
            NULL, NULL, NULL, var_actual_upd_hosp, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, var_source_system_dtm, var_cpi_filler);
           -- raise notice '[758]cpi_change_hkid[INSERT INTO cpi_transaction]par_patient_key=%',par_patient_key; 
           var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                	GET STACKED DIAGNOSTICS err_msg = MESSAGE_TEXT;
                    --raise notice 'cpi_change_hkid error %',err_msg;    
                	var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert into cpi_transaction for change hkid!" */
                SELECT
                    9004
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* ---20120908 --- */
        /* ---- patient_key carry to new_hkid --- */
        BEGIN
            INSERT INTO cpi_pin_change_log (hosp_code, txn_dtm, txn_type, hkid, patient_key, old_hkid, old_patient_key, update_by, source_sys, source_sys_dtm, update_hosp)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_new_hkid, par_patient_key, par_hkid, par_patient_key, par_update_by, par_source_system, var_source_system_dtm, var_actual_upd_hosp);
            var_error := 0;
            --raise notice '[785]cpi_change_hkid[INSERT INTO cpi_pin_change_log]par_patient_key=%',par_patient_key;  
           EXCEPTION
                WHEN OTHERS THEN
                    GET STACKED DIAGNOSTICS err_msg = MESSAGE_TEXT;
        	        --raise notice 'cpi_change_hkid error %',err_msg;
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
        /* --- the uniqe key = hosp_code + txn_dtm + hkid --> 2601 SHOULD NOT occurred */
        
        /*
        if @error = 2601
        begin
         select @update_dtm = dateadd(ms,3,@update_dtm)
         continue
        end
        */
        IF var_error != 0 THEN
            BEGIN
                /* Fail to insert into cpi_pin_change_log. */
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    9004
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
        /* ---- END 20120908 --- */
		EXCEPTION
			WHEN OTHERS then
			begin
				GET STACKED DIAGNOSTICS err_msg = MESSAGE_TEXT;
                --raise notice 'cpi_change_hkid error %',err_msg;
				EXIT return_error;
			end;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN
            /*
            [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
            rollback cpi_change_hkid
            */
	        RAISE exception '';
--            pas_return_code := var_return_error_code;
--            RETURN;
        END;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
    EXCEPTION
		WHEN OTHERS then
		begin
			pas_return_code := var_return_error_code;
            RETURN;
		end;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_change_hkid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
