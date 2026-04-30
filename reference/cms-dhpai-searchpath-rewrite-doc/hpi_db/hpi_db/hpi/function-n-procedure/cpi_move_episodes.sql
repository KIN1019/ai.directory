-- DROP PROCEDURE hpi.cpi_move_episodes(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_move_episodes(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_new_hkid character varying, IN par_new_patient_key character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_move_episode_status character varying DEFAULT NULL::character varying, IN par_info_source_code character varying DEFAULT NULL::character varying, IN par_reason_code character varying DEFAULT NULL::character varying, IN par_other_reason character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	var_check_type VARCHAR(8);
    var_cnt INTEGER;
    var_chk_patient_key VARCHAR(8);
    var_success_flag VARCHAR(1);
    var_exit_flag VARCHAR(1);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
	var_return_error_code INTEGER;
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(1);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_exact_dob_flag VARCHAR(1);
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
    var_discharge_code VARCHAR(01);
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_old_patient_name VARCHAR(48);
    var_old_sex VARCHAR(1);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_old_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_return INTEGER;
    var_old_case_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_old_case_update_by VARCHAR(12);
    var_upload_status VARCHAR(1);
    var_nb_prk VARCHAR(8);
    var_nb_hkid VARCHAR(12);
    var_preg_number INTEGER;
    var_birth_order INTEGER;
    var_admission_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_body_category VARCHAR(1);
    var_hkpmi_srvr VARCHAR(300);
    var_error_msg VARCHAR(255);
    var_return_code int;
    var_pgm_name VARCHAR(30);
    var_rpc_call VARCHAR(360);
    var_retcode INTEGER;
    var_pmi_error INTEGER;
    sql$rowcount BIGINT;
   	dblink_sql text;
    mo_csr CURSOR FOR
    SELECT
        new_born_patient_key, pregnancy_number, birth_order
        FROM cpi_new_born
        WHERE hospital_code = par_hospital_code AND mother_patient_key = par_patient_key AND mother_case_no = par_case_no;

BEGIN
    <<return_error>>
    BEGIN
        /*
        if @@trancount = 0
           begin
              select   @return_error_code = 20000
              select   @success_flag = "N"
              goto return_error
           end
        */
        /* ---------------------Begin of 20051102 SL  -------------------------------------------- */
        IF par_source_system <> 'DNL' then
        raise notice 'into select';
            BEGIN
                SELECT
                    NULL
                    INTO var_hkpmi_srvr;
                /* ---cis rpc --- */
                CALL cpi_get_rpc_server(var_return_code, 'HKPMI_SERVER', var_hkpmi_srvr,null );
					raise notice '%',var_hkpmi_srvr;

                IF var_hkpmi_srvr IS NULL THEN
                    BEGIN
                        SELECT
                            'Primary HKPMI server is not available, PMI Registration, Change HKID, Move Episode and Merge Patient fun
ctions are prohibited.'
                            INTO var_error_msg;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200034';
                        pas_return_code := 200034;
                        RETURN;
                    END;
                END IF;
                /* ---------20081205 SL : Check UID ---------- */

                /*SELECT
     				 concat(schema_name,'.hkpmi_check_merge')  
				INTO var_pgm_name
					from hkpmi_control;*/
                
                /*
                exec @retcode = @rpc_call @hospital_code, @hkid,@new_hkid,@pmi_error,"MOVE"
                */
				/*begin
				raise notice '%',var_hkpmi_srvr;
                  perform public.dblink_connect('rpc_server'::text, var_hkpmi_srvr);
                  dblink_sql := 'call ' 
			|| var_pgm_name || '('
            || case when var_retcode is null then 0 else var_retcode end || ','
            || case when par_hospital_code is null then 'null::varchar' else concat('''', par_hospital_code, '''::varchar') end || ','
			|| case when par_hkid is null then 'null::varchar' else concat('''', par_hkid, '''::varchar') end || ','
			|| case when par_new_hkid is null then 'null::varchar' else concat('''', par_new_hkid, '''::varchar') end || ','
			|| case when var_pmi_error is null then 0 else var_pmi_error end || ','
			|| concat('''', 'MOVE', '''::varchar') ||');';
			raise notice 'dblink_sql=%',dblink_sql;
                  select * from public.dblink('rpc_server'::text,dblink_sql::text)
			as t1(var_retcode integer) into var_retcode;
					raise notice 'var_retcode1=%',var_retcode;

			perform public.dblink_disconnect('rpc_server'::text);
			exception
				when others then
						perform public.dblink_disconnect('rpc_server'::text);  
			end;*/
				
				-- replace_dblink_by_fdw
               	var_check_type := 'MOVE';
               	CALL hkpmi.hkpmi_check_merge(var_retcode, par_hospital_code, par_hkid, par_new_hkid, var_pmi_error, var_check_type) ;
               	SET search_path TO hpi,public;
				raise notice 'var_retcode2=%',var_retcode;
				IF var_retcode != 0 THEN
                    BEGIN
                        IF var_retcode = 5 THEN
                            SELECT
                                'UID linkage problem, Move Episodes  is rejected!'
                                INTO var_error_msg;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200034';
                        pas_return_code := 200035;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;
       			raise notice 'return code 1';

        /* ---------------------End OF : 20051102 SL --------------------------------------- */
        /*
        save transaction cpi_move_episodes
        */
--	SAVEPOINT cpi_move_episodes;
        IF par_source_system = 'DNL' THEN
            SELECT
                'N'
                INTO var_upload_status;
        ELSE
            SELECT
                'Y'
                INTO var_upload_status;
        END IF;
        /* Assign the transaction_datetime of source system to source_system_dtm */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        SELECT
            timestamp_convert(localtimestamp)
            INTO par_transaction_datetime;
        /* Set flags */
        SELECT
            'Y'
            INTO var_success_flag;
        /* Validate key fields */
        /* Check the existence of case */
        SELECT
            admission_dtm, discharge_code, discharge_dtm
            INTO var_admission_dtm, var_discharge_code, var_discharge_datetime
            FROM cpi_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND status_code != 'CC';
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
       			raise notice 'return code 2';

        IF sql$rowcount = 0 THEN
            begin

                /* print "Given episode does not exist, move episode is rejected!" */
                SELECT
                    8001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                          	                raise notice 'return code 3,%',var_return_error_code;
                
                RAISE exception '';
            END;
        END IF;

        /* Check matching of patient key */
        SELECT
            patient_key, update_dtm, update_by
            INTO var_chk_patient_key, var_old_case_update_dtm, var_old_case_update_by
            FROM cpi_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND status_code != 'CC';
	
        IF (var_chk_patient_key != par_patient_key) THEN
            begin
	           

                /* print "The patient key does not match, move episode is rejected!" */
                SELECT
                    8002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                                         	                raise notice 'return code 5,%',var_return_error_code;

                RAISE exception '';
            END;
        END IF;
        /* Check the existence of new patient moved to */
        SELECT
            update_dtm, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, reference, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, access_code, security
            INTO var_update_dtm, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1, var_phone2, var_address_indicator, var_mobile_phone, var_sms_language, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_access_code, var_security
            FROM cpi_patient
            WHERE patient_key = par_new_patient_key AND hkid = par_new_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount = 0 THEN
            begin
                /* print "The new patient does not exist,  move episode is rejected!" */
                SELECT
                    8003
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                                          	                raise notice 'return code 6,%',var_return_error_code;

                RAISE exception '';
            END;
        END IF;

        IF (var_dob IS NOT NULL) THEN
            IF (var_admission_dtm < var_dob) THEN
                begin
                    SELECT
                        200037
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                       	                raise notice 'return code 7,%',var_return_error_code;

                    RAISE exception '';
                END;
            END IF;
        END IF;
        /*
        if @discharge_code = '1'
        	begin
              update   cpi_patient
              	set death_indicator = 'N',
        		       death_date = null,
        				 update_hospital = @hospital_code,
              		 update_by = @update_by,
        		       update_dtm = @transaction_datetime
              	where patient_key = @patient_key
        
              select   @error = @@error, @rowcount = @@rowcount
              if (@error != 0) or (@@rowcount = 0)
              begin
                 select   @return_error_code = 8006
                 select   @success_flag = "N"
                 goto return_error
              end
        
              update   cpi_patient
              	set death_indicator = "Y",
        		       death_date = @discharge_datetime,
        				 update_hospital = @hospital_code,
              		 update_by = @update_by,
        		       update_dtm = @transaction_datetime
              	where patient_key = @new_patient_key
        
              select   @error = @@error, @rowcount = @@rowcount
              if (@error != 0) or (@@rowcount = 0)
              begin
                 select   @return_error_code = 8006
                 select   @success_flag = "N"
                 goto return_error
              end
        	end
        */
        OPEN mo_csr;
        FETCH mo_csr INTO var_nb_prk, var_preg_number, var_birth_order;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                hkid
                INTO var_nb_hkid
                FROM cpi_patient
                WHERE patient_key = var_nb_prk;
            CALL cpi_update_new_born(var_return, 'U', par_hospital_code, par_new_hkid, var_nb_hkid, par_case_no, var_birth_order, var_preg_number, par_update_by, par_transaction_datetime, NULL, NULL);

            IF var_return <> 0 THEN
                BEGIN
                    SELECT
                        var_return
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    RAISE exception '';
                END;
            END IF;
            FETCH mo_csr INTO var_nb_prk, var_preg_number, var_birth_order;
        END LOOP;

        CLOSE mo_csr;

        BEGIN
            UPDATE cpi_case
            SET patient_key = par_new_patient_key, update_by = par_update_by, update_dtm = par_transaction_datetime
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND patient_key = par_patient_key;
            raise notice 'cpi_move_episodes[UPDATE cpi_case]case_no=%,patient_key=%',par_case_no,par_new_patient_key; 
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to update cpi_case, move episode is rejected!" */
                SELECT
                    8004
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;

        IF NOT EXISTS (SELECT
            *
            FROM cpi_case_key_changed
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
            BEGIN
                BEGIN
                    INSERT INTO cpi_case_key_changed (hospital_code, case_no, update_dtm, hkid, update_by)
                    VALUES (par_hospital_code, par_case_no, var_old_case_update_dtm, par_hkid, var_old_case_update_by);
                    raise notice 'cpi_move_episodes[INSERT]  cpi_case_key_changed case_no=%',par_case_no; 
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT
                            8007
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;

        BEGIN
            INSERT INTO cpi_case_key_changed (hospital_code, case_no, update_dtm, hkid, update_by)
            VALUES (par_hospital_code, par_case_no, par_transaction_datetime, par_new_hkid, par_update_by);
            raise notice 'cpi_move_episodes[INSERT]  cpi_case_key_changed case_no=%',par_case_no; 
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    8007
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
        /* Get data from cpi_patient for transaction */
        /*
        select  @patient_name = patient_name,
        		@sex = sex,
         		@dob = dob,
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
         		@access_code = access_code,
         		@security = security
         	from    cpi_patient
        	where   patient_key = @new_patient_key
        */
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
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
                        3 * INTERVAL '1 millisecond' + par_transaction_datetime::TIMESTAMP
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

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm, cpi_filler)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_new_hkid, par_new_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_document_no, var_reference, NULL, NULL, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1, var_phone2, var_address_indicator, var_mobile_phone, var_sms_language, var_death_indicator, var_death_date, var_death_code, var_card_holder, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_case_no, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_case_type, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_patient_key, NULL, par_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hospital_code, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, var_source_system_dtm, par_move_episode_status);
            raise notice 'cpi_move_episodes[INSERT]cpi_transaction case_no=%',par_case_no; 
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert record into cpi_transaction!" */
                SELECT
                    8005
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
        /* Reset the status of Patients */
        IF (var_discharge_code = '1') THEN
            BEGIN
                /* YL: move body_category to target patient */
                BEGIN
                    SELECT
                        update_dtm, body_category
                        INTO var_old_update_dtm, var_body_category
                        FROM cpi_patient
                        WHERE patient_key = par_patient_key;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT
                            8005
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
                /* Set To-patient to dead */
                CALL cpi_patient_upd_death(var_return, par_hospital_code, par_new_hkid, par_new_patient_key, var_discharge_datetime, 'Y', var_source_system_dtm, par_hospital_code, par_update_by, var_update_dtm, par_source_system, 'P', var_body_category);
                

                IF var_return != 0 THEN
                    BEGIN
                        SELECT
                            var_return
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
                /* Resume From-patient to alive */
                CALL cpi_patient_upd_death(var_return, par_hospital_code, par_hkid, par_patient_key, NULL, 'N', var_source_system_dtm, par_hospital_code, par_update_by, var_old_update_dtm, par_source_system);
                

                IF var_return != 0 THEN
                    BEGIN
                        SELECT
                            var_return
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;
        /* 20140404 Yorky add move episode info_source_code, reason_code and other_reason input parameters - Start */
      
       /* change to Java call
       RAISE NOTICE 'call cpi_set_move_episode_indicator start';
      CALL cpi_set_move_episode_indicator(var_return, par_hospital_code, par_case_no, par_transaction_datetime, par_patient_key, par_new_patient_key, par_update_by, par_source_system, par_move_episode_status, par_update_by, par_source_system, par_info_source_code, par_reason_code, par_other_reason, var_error_msg);
		raise notice 'var_return=%',var_return;
        IF var_return != 0 THEN
            BEGIN
                SELECT
                    var_return
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
        /* 20140404 Yorky add move episode info_source_code, reason_code and other_reason input parameters - End */
        <<insert_transaction>>
        BEGIN
        END;
        */
    END;
	pas_return_code:=0;
	EXCEPTION
		WHEN OTHERS THEN
			BEGIN
				IF var_return_error_code IS NULL THEN
					RAISE NOTICE 'call cpi_move_episodes error :%',SQLERRM ;
					RAISE EXCEPTION 'call cpi_move_episodes error :%',SQLERRM ;
				END IF;
				pas_return_code := var_return_error_code;
			END;
        RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_move_episodes" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
