-- DROP PROCEDURE hkpmi.hkpmi_patient_merge(inout int4, in varchar, in varchar, in varchar, inout varchar, inout int4, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_patient_merge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_from_hkid character varying, IN par_to_hkid character varying, INOUT par_to_patient_key character varying, INOUT par_to_access_code integer, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_txn_type character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return_error_code INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_upload_status VARCHAR(1);
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_from_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_from_patient_key VARCHAR(08);
    var_from_patient_name VARCHAR(48);
    var_from_sex VARCHAR(01);
    var_from_dob TIMESTAMP WITHOUT TIME ZONE;
    var_from_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_from_patient_type VARCHAR(03);
    var_from_mrn VARCHAR(8);
    var_from_death_indicator VARCHAR(4);
    var_from_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_from_death_diagnosis VARCHAR(4);
    var_from_death_external_cause VARCHAR(4);
    var_from_cccode1 VARCHAR(5);
    var_from_cccode2 VARCHAR(5);
    var_from_cccode3 VARCHAR(5);
    var_from_cccode4 VARCHAR(5);
    var_from_cccode5 VARCHAR(5);
    var_from_cccode6 VARCHAR(5);
    var_tmp_hospital_code VARCHAR(03);
    var_process_local_hospital VARCHAR(01);
    var_tran_hospital_code VARCHAR(03);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_begin_tran VARCHAR(01);
    var_return_code INTEGER;
    var_to_patient_name VARCHAR(48);
    var_to_sex VARCHAR(01);
    var_to_dob TIMESTAMP WITHOUT TIME ZONE;
    var_to_death_indicator VARCHAR(4);
    var_to_death_external_cause VARCHAR(4);
    var_to_death_diagnosis VARCHAR(4);
    var_to_cccode1 VARCHAR(5);
    var_to_cccode2 VARCHAR(5);
    var_to_cccode3 VARCHAR(5);
    var_to_cccode4 VARCHAR(5);
    var_to_cccode5 VARCHAR(5);
    var_to_cccode6 VARCHAR(5);
    var_to_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_death_case VARCHAR(1);
    var_update_patient_detail VARCHAR(1);
    var_mrn VARCHAR(8);
    /* @all_case_moved	char(1), */
    /* @demo_exists      VARCHAR(1), */
    var_from_patient_exists VARCHAR(1);
    var_patient_remove_flag VARCHAR(1);
    var_tran_log_filler VARCHAR(30);
    var_from_body_category VARCHAR(1);
    var_to_body_category VARCHAR(1);
    var_from_filler VARCHAR(30);
    var_to_filler VARCHAR(30);
    var_rtn_code INTEGER;
    var_from_access_code INTEGER; /* ---20090702 */
    var_confidential_patient VARCHAR(1);
    var_confidential_code INTEGER;
    var_nok_priority INTEGER;
    var_major_nok VARCHAR(1);
    var_nok_hkid VARCHAR(12);
    var_nok_name VARCHAR(48);
    var_nok_relation VARCHAR(2);
    var_nok_building VARCHAR(47);
    var_nok_room VARCHAR(5);
    var_nok_floor VARCHAR(2);
    var_nok_block VARCHAR(2);
    var_nok_district VARCHAR(5);
    var_nok_phone1 VARCHAR(10);
    var_nok_phone2 VARCHAR(10);
    var_nok_address_indicator VARCHAR(4);
    var_nok_mobile_phone VARCHAR(10);
    var_nok_sms_language VARCHAR(4);
    var_link_hkid VARCHAR(12);
    var_update_link_status VARCHAR(2);
    var_to_hkic_symbol VARCHAR(1);
    sql$rowcount BIGINT;
    error_sqlstate BIGINT;
   	p_refcur refcursor;
    found_code INTEGER;
	my_conn varchar;
	error_message text;
    var_prt VARCHAR(08);
    hosp_cursor CURSOR FOR
    SELECT
        h.hospital_code
        FROM hospital AS h, patient_detail_1 AS p
        WHERE p.patient_key = var_from_patient_key AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0) AND h.hospital_code != par_hospital_code
    UNION
    SELECT DISTINCT
        hospital_code
        FROM pmi_case
        WHERE patient_key = var_from_patient_key AND hospital_code != par_hospital_code;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
            SELECT
                NULL
                INTO var_patient_remove_flag;

			select 'Y' into var_begin_tran;
            /* Validate key fields */
            IF NOT (par_source_system IN ('ADT', 'DNL', 'OPAS', 'OPAS2', 'PBRC') AND par_txn_type IN ('020')) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF par_from_hkid = par_to_hkid THEN
                BEGIN
                    SELECT
                        200114
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                patient_key, death_indicator, death_date, death_diagnosis, death_external_cause, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, source_system_dtm, row_update_datetime, filler, SUBSTRING(filler, 2, 1), access_code
                INTO var_from_patient_key, var_from_death_indicator, var_from_death_date, var_from_death_diagnosis, var_from_death_external_cause, var_from_patient_name, var_from_sex, var_from_dob, var_from_cccode1, var_from_cccode2, var_from_cccode3, var_from_cccode4, var_from_cccode5, var_from_cccode6, var_from_source_system_dtm, var_from_timestamp, var_from_filler, var_from_body_category, var_from_access_code
                FROM patient
                WHERE hkid = par_from_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
			
            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        200112
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                mrn
                INTO var_from_mrn
                FROM patient_hospital_data
                WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
			raise notice 'patient_hospital_datasql$rowcount=%',sql$rowcount;
            IF sql$rowcount = 0 THEN
                SELECT
                    NULL
                    INTO var_from_mrn;
            END IF;
            SELECT
                patient_key, access_code, death_indicator, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, row_update_datetime, filler, SUBSTRING(filler, 2, 1), SUBSTRING(filler, 3, 1)
                INTO par_to_patient_key, par_to_access_code, var_to_death_indicator, var_to_patient_name, var_to_sex, var_to_dob, var_to_cccode1, var_to_cccode2, var_to_cccode3, var_to_cccode4, var_to_cccode5, var_to_cccode6, var_to_timestamp, var_to_filler, var_to_body_category, var_to_hkic_symbol
                FROM patient
                WHERE hkid = par_to_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
			raise notice 'patientsql$rowcount=%',sql$rowcount;
            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        200113
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_from_sex <> var_to_sex OR var_from_patient_name <> var_to_patient_name OR var_from_dob <> var_to_dob OR var_from_cccode1 <> var_to_cccode1 OR var_from_cccode2 <> var_to_cccode2 OR var_from_cccode3 <> var_to_cccode3 OR var_from_cccode4 <> var_to_cccode4 OR var_from_cccode5 <> var_to_cccode5 OR var_from_cccode6 <> var_to_cccode6 THEN
                BEGIN
                    SELECT
                        200115
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* update */
            IF EXISTS (SELECT
                *
                FROM pmi_case
                WHERE hospital_code = par_hospital_code AND patient_key = var_from_patient_key AND discharge_code = '1') THEN
                SELECT
                    'Y'
                    INTO var_death_case;
            ELSE
                SELECT
                    'N'
                    INTO var_death_case;
            END IF;
           	
            /* --	print "death case %1!", @death_case */
            /* 19981111 GL - Check from patient existence */
            IF (EXISTS (SELECT
                *
                FROM pmi_case
                WHERE patient_key = var_from_patient_key AND hospital_code != par_hospital_code) OR EXISTS (SELECT
                h.hospital_code
                FROM hospital AS h, patient_detail_1 AS p
                WHERE p.patient_key = var_from_patient_key AND h.hospital_code != par_hospital_code AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0))) THEN
                SELECT
                    'Y'
                    INTO var_from_patient_exists;
            ELSE
                SELECT
                    'N'
                    INTO var_from_patient_exists;
            END IF;
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_dtm;
            /* --	print "all case moved %1!", @all_case_moved */
            /*
            if @death_case = 'Y' or
            (@all_case_moved = 'Y' and
             @from_death_indicator != null)
            */
            IF var_death_case = 'Y' THEN
                BEGIN
                    /* YL Move body_category */
                    IF var_to_body_category IS NULL OR var_to_body_category = ' ' THEN
                        SELECT
                            CONCAT(COALESCE(SUBSTRING(var_to_filler, 1, 1), REPEAT(' ', 1)), var_from_body_category, + SUBSTRING(var_to_filler, 3, 28))
                            INTO var_to_filler;
                    END IF;
                    UPDATE patient
                    SET death_indicator = var_from_death_indicator, death_date = var_from_death_date, death_diagnosis = var_from_death_diagnosis, death_external_cause = var_from_death_external_cause, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm, filler = var_to_filler
                        WHERE patient_key = par_to_patient_key AND row_update_datetime = var_to_timestamp;
					GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;
                    /* select @error = @@error, @rowcount = @@rowcount */
					var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                               GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                var_error
                                INTO var_return_error_code;
                               raise notice  '1var_return_error_code=%',var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;

                    IF var_rowcount != 1 THEN
                        BEGIN
                            /* Patient has been updated between retrieved and update." */
                            SELECT
                                200016
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    SELECT
                        row_update_datetime
                        INTO var_to_timestamp
                        FROM patient
                        WHERE patient_key = par_to_patient_key;
                END;
            END IF;
			raise notice 'var_death_case=%',var_death_case;
            IF var_death_case = 'Y' AND var_from_patient_exists = 'Y' THEN
                /* --		(@all_case_moved = 'N' or @demo_exists = 'Y') */
                BEGIN
                    /* Reset the body_category filler(2,1) */
                    IF var_from_body_category IS NOT NULL THEN
                        SELECT
                            CONCAT(SUBSTRING(var_from_filler, 1, 1), REPEAT(' ', 1), + SUBSTRING(var_from_filler, 3, 28))
                            INTO var_from_filler;
                    END IF;
                    UPDATE patient
                    SET death_indicator = NULL, death_date = NULL, death_diagnosis = NULL, death_external_cause = NULL, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm, filler = var_from_filler
                        WHERE patient_key = var_from_patient_key AND row_update_datetime = var_from_timestamp;
                    /* select @error = @@error, @rowcount = @@rowcount */
					GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;
					var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                var_error
                                INTO var_return_error_code;
                                raise notice  '2var_return_error_code=%',var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;

                    IF var_rowcount != 1 THEN
                        BEGIN
                            /* Patient has been updated between retrieved and update." */
                            SELECT
                                200016
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    SELECT
                        row_update_datetime
                        INTO var_from_timestamp
                        FROM patient
                        WHERE patient_key = var_from_patient_key;
                END;
            END IF;
            /* add update for new_born */
            /*
            update new_born set
            	mother_patient_key = @to_patient_key,
            	update_by = @update_by,
            	update_datetime = @source_system_dtm
            	where mother_patient_key = @from_patient_key
            	and hospital_code = @hospital_code
            
            select @error = @@error, @rowcount = @@rowcount
            
            if @error != 0
            	begin
            		select	@return_error_code = @error
            		goto return_system_error
            	end
            
            update new_born set
            	new_born_patient_key = @to_patient_key,
            	update_by = @update_by,
            	update_datetime = @source_system_dtm
            	where new_born_patient_key = @from_patient_key
            	and hospital_code = @hospital_code
            
            select @error = @@error, @rowcount = @@rowcount
            
            if @error != 0
            	begin
            		select	@return_error_code = @error
            		goto return_system_error
            	end
            */
           	begin
           
            UPDATE pmi_case
            SET patient_key = par_to_patient_key, update_by = par_update_by, source_system_dtm = par_source_system_dtm
                WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
            
            /* select @error = @@error, @rowcount = @@rowcount */
			GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;
			var_error := 0;
            EXCEPTION
                  WHEN OTHERS then
                  		begin
                         	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                        	raise notice 'error_message=%',error_message;
                        end;
            end;
                                   
            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                        raise notice  '3var_return_error_code=%',var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;
            /*
            19981111 GL - if more than one case are moved, set to_patient off;
            otherwise, set to_patient on (only demo merge)
            */
           	raise notice 'var_rowcount=%',var_rowcount;    
            IF var_rowcount = 0 THEN
                BEGIN
                    CALL hkpmi_set_on_patient_hosp(var_return_code, par_to_hkid, par_hospital_code, par_update_by, par_source_system);


                    IF var_return_code != 0 THEN
                        BEGIN
                            IF var_return_code > 200000 THEN
                                SELECT
                                    var_return_code
                                    INTO var_return_error_code;
                                    raise notice  '4var_return_error_code=%',var_return_error_code;
                            ELSE
                                SELECT
                                    200158
                                    INTO var_return_error_code;
                            END IF;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            ELSE
                BEGIN
                    CALL hkpmi_set_off_patient_hosp(var_return_code, par_to_hkid, par_hospital_code, par_update_by, par_source_system);


                    IF var_return_code != 0 THEN
                        BEGIN
                            IF var_return_code > 200000 THEN
                                SELECT
                                    var_return_code
                                    INTO var_return_error_code;
                                    raise notice  '5var_return_error_code=%',var_return_error_code;
                            ELSE
                                SELECT
                                    200158
                                    INTO var_return_error_code;
                            END IF;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* 19981106 GL - set from_patient off from patient_detail_1 */
            CALL hkpmi_check_patient_detail_1(var_return_code, par_from_hkid, par_hospital_code);


            IF var_return_code = 0 THEN
                BEGIN
                    CALL hkpmi_set_off_patient_hosp(var_return_code, par_from_hkid, par_hospital_code, par_update_by, par_source_system);


                    IF var_return_code != 0 THEN
                        BEGIN
                            IF var_return_code > 200000 THEN
                                SELECT
                                    var_return_code
                                    INTO var_return_error_code;
                                    raise notice  '6var_return_error_code=%',var_return_error_code;
                            ELSE
                                SELECT
                                    200159
                                    INTO var_return_error_code;
                            END IF;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* move critical data */
            SELECT
                'N'
                INTO var_update_patient_detail;

            IF EXISTS (SELECT
                source_system_dtm
                FROM patient_detail
                WHERE patient_key = var_from_patient_key) AND var_from_patient_exists = 'N' THEN
                /* --		@all_case_moved = 'Y' and @demo_exists = 'N' /* 19981106 GL */ */
                BEGIN
                    IF EXISTS (SELECT
                        source_system_dtm
                        FROM patient_detail
                        WHERE patient_key = par_to_patient_key) THEN
                        BEGIN
                            IF (SELECT
                                source_system_dtm
                                FROM patient_detail
                                WHERE patient_key = var_from_patient_key) > (SELECT
                                source_system_dtm
                                FROM patient_detail
                                WHERE patient_key = par_to_patient_key) THEN
                                BEGIN
                                    DELETE FROM patient_detail
                                        WHERE patient_key = par_to_patient_key;
									var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                                    /* select @error = @@error, @rowcount = @@rowcount */
                                    IF var_error != 0 THEN
                                        BEGIN
                                            SELECT
                                                var_error
                                                INTO var_return_error_code;
                                                raise notice  '7var_return_error_code=%',var_return_error_code;
                                            EXIT return_system_error;
                                        END;
                                    END IF;
                                    SELECT
                                        'Y'
                                        INTO var_update_patient_detail;
                                END;
                            END IF;
                        END;
                    ELSE
                        SELECT
                            'Y'
                            INTO var_update_patient_detail;
                    END IF;
                END;
            END IF;

            IF var_update_patient_detail = 'Y' THEN
                BEGIN
                    UPDATE patient_detail
                    SET patient_key = par_to_patient_key
                        WHERE patient_key = var_from_patient_key;
					GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;
					var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                    /* select @error = @@error, @rowcount = @@rowcount */
                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                var_error
                                INTO var_return_error_code;
                                raise notice  '8var_return_error_code=%',var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;

                    IF var_rowcount != 1 THEN
                        BEGIN
                            SELECT
                                200122
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* if @all_case_moved = 'Y' and @demo_exists = 'N' */
            
            /* 20061031 */
            SELECT
                'Y'
                INTO var_patient_remove_flag;
            /* ---- should always set to 'Y' because : @from_hkid will be del. */
            /*
            --------- 20060313 SL move to last section of SP to del --
               if @from_patient_exists = 'N'
            	begin
            		select @patient_remove_flag = 'Y'
            		delete patient
            			where patient_key = @from_patient_key and
            					timestamp = @from_timestamp
            
            		select @error = @@error, @rowcount = @@rowcount
            
            		if @error != 0
            			begin
            				select	@return_error_code = @error
            				goto return_system_error
            			end
            
            		if @rowcount != 1
            		begin
            				Patient has been updated between retrieved and update."
            			select	@return_error_code = 200016
            			goto return_error
            		end
            	end
            
            	if @from_mrn != null
            	begin
            
            		delete patient_hospital_data
            			where	patient_key = @from_patient_key and
            					hospital_code = @hospital_code
            
            		select @error = @@error, @rowcount = @@rowcount
            
            		if @error != 0
            			begin
            				select	@return_error_code = @error
            				goto return_system_error
            			end
            	end
            -----20060313----------------
            */
            
            /*
            comment for using from mrn instead of to mrn by Leo Lee
            if exists (select * from patient_hospital_data
            				where patient_key = @to_patient_key and
            						hospital_code = @hospital_code)
            begin
            	update patient_hospital_data
            		set mrn = @from_mrn,
            			 update_by = @update_by,
            			 source_system_dtm = @source_system_dtm
            		where	patient_key = @to_patient_key and
            			hospital_code = @hospital_code
            
            	select @error = @@error, @rowcount = @@rowcount
            
            	if @error != 0
            		begin
            			select	@return_error_code = @error
            			goto return_system_error
            		end
            
            	if @rowcount != 1
            	begin
            		select	@return_error_code = 200019
            		goto return_error
            	end
            end
            else
            begin
            	insert patient_hospital_data
            			(patient_key, hospital_code, mrn,
            				update_by, source_system_dtm)
            		values
            			(@to_patient_key, @hospital_code, @from_mrn,
            				@update_by, @source_system_dtm)
            
            	select	@error = @@error
            
            	if @error != 0
            		begin
            			select	@return_error_code = @error
            			goto return_system_error
            		end
            end
            */
            
            /* ---end */
            
            /* Check old hkid exist in sars_hkid_list or not, update the new id in sars_hkid_list by YorkyLeung */
            IF EXISTS (SELECT
                hkid
                FROM sars_hkid_list
                WHERE hkid = par_from_hkid) THEN
                BEGIN
                    /* only update sars_hkid_list if from_hkid was deleted */
                    IF var_patient_remove_flag = 'Y' THEN
                        BEGIN
                            BEGIN
                                IF EXISTS (SELECT
                                    hkid
                                    FROM sars_hkid_list
                                    WHERE hkid = par_to_hkid) THEN
                                    BEGIN
                                        DELETE FROM sars_hkid_list
                                            WHERE hkid = par_from_hkid;
                                    END;
                                ELSE
                                    BEGIN
                                        UPDATE sars_hkid_list
                                        SET hkid = par_to_hkid
                                            WHERE hkid = par_from_hkid;
                                    END;
                                END IF;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                            END;

                            IF var_error != 0 THEN
                                BEGIN
                                    SELECT
                                        var_error
                                        INTO var_return_error_code;
                                    EXIT return_system_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            /* 20061023 SL: pp_opt_out & hkpmi_patient_address_list */
            /* ************************************************************************************ */
            IF EXISTS (SELECT
                patient_key
                FROM pp_opt_out
                WHERE patient_key = var_from_patient_key) THEN
                BEGIN
                    IF var_patient_remove_flag = 'Y' THEN
                        BEGIN
                            BEGIN
                                IF EXISTS (SELECT
                                    patient_key
                                    FROM pp_opt_out
                                    WHERE patient_key = par_to_patient_key) THEN
                                    BEGIN
                                        DELETE FROM pp_opt_out
                                            WHERE patient_key = var_from_patient_key;
                                    END;
                                ELSE
                                    BEGIN
                                        UPDATE pp_opt_out
                                        SET patient_key = par_to_patient_key
                                            WHERE patient_key = var_from_patient_key;
                                    END;
                                END IF;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                            END;

                            IF var_error != 0 THEN
                                BEGIN
                                    SELECT
                                        var_error
                                        INTO var_return_error_code;
                                    EXIT return_system_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;

            IF EXISTS (SELECT
                patient_key
                FROM hkpmi_patient_address_list
                WHERE patient_key = var_from_patient_key) THEN
                BEGIN
                    IF var_patient_remove_flag = 'Y' THEN
                        BEGIN
                            BEGIN
                                IF EXISTS (SELECT
                                    patient_key
                                    FROM hkpmi_patient_address_list
                                    WHERE patient_key = par_to_patient_key) THEN
                                    BEGIN
                                        DELETE FROM hkpmi_patient_address_list
                                            WHERE patient_key = var_from_patient_key;
                                    END;
                                ELSE
                                    BEGIN
                                        UPDATE hkpmi_patient_address_list
                                        SET patient_key = par_to_patient_key
                                            WHERE patient_key = var_from_patient_key;
                                    END;
                                END IF;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                            END;

                            IF var_error != 0 THEN
                                BEGIN
                                    SELECT
                                        var_error
                                        INTO var_return_error_code;
                                    EXIT return_system_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;

            IF EXISTS (SELECT
                patient_key
                FROM hkpmi_patient_address_log
                WHERE patient_key = var_from_patient_key) THEN
                BEGIN
                    IF var_patient_remove_flag = 'Y' THEN
                        BEGIN
                            BEGIN
                                UPDATE hkpmi_patient_address_log
                                SET patient_key = par_to_patient_key
                                    WHERE patient_key = var_from_patient_key;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                            END;

                            IF var_error != 0 THEN
                                BEGIN
                                    SELECT
                                        var_error
                                        INTO var_return_error_code;
                                    EXIT return_system_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            /* ************************************************************************************ */
            /* Merge patient_key_changed */
            /*
            update patient_key_changed
                   set original_hkid = @to_hkid
                   where patient_key = @from_patient_key and
            	     original_hkid = @from_hkid
            
               select @error = @@error, @rowcount = @@rowcount
            
               if @error != 0
            		begin
            			select	@return_error_code = @error
            			goto return_system_error
            		end
            
               if @rowcount = 0
               begin
                  insert patient_key_changed
            	   (patient_key, original_hkid, source_system_dtm,
            				hkid, patient_name, sex, cccode1,
            				cccode2, cccode3, cccode4,
            				cccode5, cccode6, dob,
            	    update_hospital, update_by)
            	 values
            	   (@from_patient_key, @to_hkid, @from_source_system_dtm,
            				@from_hkid, @from_patient_name, @from_sex, @from_cccode1,
            				@from_cccode2, @from_cccode3, @from_cccode4,
            				@from_cccode5, @from_cccode6, @from_dob,
            	    @hospital_code, @update_by)
            
                  select @error = @@error
            
                if @error != 0
            		begin
            			select	@return_error_code = @error
            			goto return_system_error
            		end
               end
            */
            BEGIN
                INSERT INTO patient_key_changed (old_hkid, system_dtm, old_patient_name, old_sex, old_dob, new_hkid, new_patient_name, new_sex, new_dob, new_patient_key, update_by, hospital_code)
                VALUES (par_from_hkid, timestamp_convert(var_system_dtm), var_from_patient_name, var_from_sex, timestamp_convert(var_from_dob), par_to_hkid, var_to_patient_name, var_to_sex, timestamp_convert(var_to_dob), par_to_patient_key, par_update_by, par_hospital_code);
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
            END;
			raise notice 'var_error=%',var_error;
            IF var_error != 0 THEN
                BEGIN
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;
            SELECT
                mrn
                INTO var_mrn
                FROM patient_hospital_data
                WHERE patient_key = par_to_patient_key AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                SELECT
                    NULL
                    INTO var_mrn;
            END IF;
            SELECT
                var_system_dtm, 'Y'
                INTO var_tran_system_dtm, var_upload_status;
            /*
            if @patient_remove_flag is null
            	select @tran_log_filler = null
            else
            	select @filler = space(10) + @patient_remove_flag
            */
            /* --20100928 HKIC */
            SELECT
                CONCAT(REPEAT(' ', 10), COALESCE(var_patient_remove_flag, REPEAT(' ', 1)), REPEAT(' ', 18), COALESCE(var_to_hkic_symbol, REPEAT(' ', 1)))
                INTO var_tran_log_filler;

            IF (LTRIM(RTRIM(var_tran_log_filler)) = '') OR (LTRIM(RTRIM(var_tran_log_filler)) is NULL) THEN
                SELECT
                    NULL
                    INTO var_tran_log_filler;
            END IF;
            /* --------- Begin of 20060313 ----------------------- */
            SELECT
                priority, major_nok, hkid, nok_name, relationship, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
                INTO var_nok_priority, var_major_nok, var_nok_hkid, var_nok_name, var_nok_relation, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone, var_nok_sms_language
                FROM nok
                WHERE patient_key = par_to_patient_key AND major_nok = 'Y';
            /* ---- 20070131 SL :  set on patient hosps  for To_HKID IF From_HKID already set on for other hosps */
            OPEN hosp_cursor;
            FETCH hosp_cursor INTO var_tmp_hospital_code;
			select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            WHILE found_code = 0 LOOP
                IF var_tmp_hospital_code <> par_hospital_code THEN
                    BEGIN
                        CALL hkpmi_set_on_patient_hosp(var_return_code, par_to_hkid, var_tmp_hospital_code, par_update_by, par_source_system);


                        IF var_return_code != 0 THEN
                            BEGIN
                                IF var_return_code > 200000 THEN
                                    SELECT
                                        var_return_code
                                        INTO var_return_error_code;
                                       	raise notice  '13var_return_error_code=%',var_return_error_code;
                                       
                                ELSE
                                    SELECT
                                        200158
                                        INTO var_return_error_code;
                                END IF;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
                FETCH hosp_cursor INTO var_tmp_hospital_code;
                select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            END LOOP;
            CLOSE hosp_cursor;
            /* ----End 20070131----------------------------------- */
            OPEN hosp_cursor;
            FETCH hosp_cursor INTO var_tmp_hospital_code;
           	select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            SELECT
                'N', var_system_dtm
                INTO var_process_local_hospital, var_tran_system_dtm;

            WHILE (found_code = 0 OR var_process_local_hospital = 'N')  LOOP
                IF var_process_local_hospital = 'N' THEN
                    BEGIN
                        SELECT
                            par_hospital_code,
                            /* ---@tran_mrn = @mrn, */
                            'Y'
                            INTO var_tran_hospital_code, var_upload_status;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            var_tmp_hospital_code,
                            /* ---@tran_mrn = null, */
                            'P'
                            INTO var_tran_hospital_code, var_upload_status;
                    END;
                END IF;
                /* --------------- */
                WHILE 1 = 1 loop
	                begin
                    INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, /* security_count, */ pmi_access_code, patient_type, old_patient_key, old_hkid, update_by, source_system, source_system_dtm, update_hospital, upload_status, filler)
                        /* ----@tran_system_dtm, @hospital_code, @txn_type, */
                        SELECT
                            timestamp_convert(var_tran_system_dtm), var_tran_hospital_code, par_txn_type,
                            /* ---- 20060313 --- */
                            hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, var_mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, var_nok_priority, var_major_nok, var_nok_name, var_nok_hkid, var_nok_relation, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone, var_nok_sms_language, /* security_count, */ access_code, patient_type, var_from_patient_key, par_from_hkid, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status, var_tran_log_filler
                            FROM patient
                            WHERE patient_key = par_to_patient_key;
					 GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;
                    EXCEPTION  
					WHEN unique_violation OR OTHERS THEN  
						
						GET STACKED DIAGNOSTICS error_sqlstate = RETURNED_SQLSTATE;  
						raise notice 'error_sqlstate=%',error_sqlstate;
						 
						IF error_sqlstate = 23505 THEN  
							select var_tran_system_dtm + INTERVAL '3 milliseconds' into var_tran_system_dtm;  
							CONTINUE;
							
						ELSE  

							BEGIN
                                    SELECT
                                        error_sqlstate
                                        INTO var_return_error_code;
                                    EXIT return_system_error;
                            END;
						END IF;

                    IF var_rowcount != 1 THEN
                        BEGIN

							SELECT 200118 into var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    
                   end;
                  	EXIT;
                END LOOP;
                /* --- while 1=1 */
                
                /* -------------------- */
                IF var_process_local_hospital = 'N' THEN
                    BEGIN
                        SELECT 'Y' into var_process_local_hospital;
                    END;
                ELSE
                    BEGIN
                        FETCH hosp_cursor INTO var_tmp_hospital_code;
                        select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                    END;
                END IF;
            END LOOP; /* ----while @@sqlstatus = 0 or  @process_local_hospital = 'N' */
            CLOSE hosp_cursor;
            /* -----------------End of 20060313 --------------------------------- */
            /*
            if @death_case = 'Y' or
            (@all_case_moved = 'Y' and
             @from_death_indicator != null)
            */
            IF var_death_case = 'Y' THEN
                BEGIN
                    CALL hkpmi_patient_death_tx(var_return_code, par_hospital_code, '033', par_to_hkid, 'Y');

                    IF var_return_code != 0 THEN
                        BEGIN

							SELECT 200121 into var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;

            IF var_death_case = 'Y' AND var_from_patient_exists = 'Y' THEN
                /* --		(@all_case_moved = 'N' or @demo_exists = 'Y') */
                BEGIN
					CALL hkpmi_patient_death_tx(var_return_code, par_hospital_code, '033', par_from_hkid, 'N');


                    IF var_return_code != 0 THEN
                        BEGIN
                            SELECT 200121 into var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* 20050720 LSCHU - update mother_baby_case if merge case is affected */
            CALL hkpmi_check_mother_baby_case(var_return_code, par_hospital_code, var_from_patient_key, par_source_system_dtm, par_update_by, par_source_system);

            IF var_return_code != 0 THEN
                BEGIN
                    IF var_return_code > 200000 THEN

                        BEGIN
							SELECT var_return_code into var_return_error_code;
							raise notice  '14var_return_error_code=%',var_return_error_code;
                        END;
                    ELSE

                        BEGIN
							SELECT 200158 into var_return_error_code;
                        END;
                    END IF;
                    EXIT return_error;
                END;
            END IF;
            CALL hkpmi_check_mother_baby_case(var_return_code, par_hospital_code,par_to_patient_key, par_source_system_dtm, par_update_by, par_source_system);

            IF var_return_code != 0 THEN
                BEGIN
                    IF var_return_code > 200000 THEN
                        BEGIN
							SELECT var_return_code into var_return_error_code;
							raise notice  '15var_return_error_code=%',var_return_error_code;
                        END;
                    ELSE
                        BEGIN
							SELECT 200158 into var_return_error_code;
                        END;
                    END IF;
                    EXIT return_error;
                END;
            END IF;
            /* --------------- Begin of 20060313 -------------------- */
            
            /*
            if @from_patient_exists = 'N'
            begin
            	select @patient_remove_flag = 'Y'
            */
            IF var_patient_remove_flag = 'Y' THEN
                BEGIN
                    DELETE FROM patient
                        WHERE patient_key = var_from_patient_key AND row_update_datetime = var_from_timestamp;
                    /* select @error = @@error, @rowcount = @@rowcount */
					var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
					GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;
                    IF var_error != 0 THEN
                                BEGIN
                                    SELECT
                                        var_error
                                        INTO var_return_error_code;
                                    EXIT return_system_error;
                                END;
                            END IF;

                            IF var_rowcount != 1 THEN
                                BEGIN
                                    /* Insert new_born fail" */
                                    SELECT
                                        200016
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;

                    IF var_from_mrn is not NULL THEN
                        BEGIN
                            DELETE FROM patient_hospital_data
                                WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
                            /* select @error = @@error, @rowcount = @@rowcount */
							var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                            IF var_error = 0 THEN
                                BEGIN
                                    SELECT
                                        var_error
                                        INTO var_return_error_code;
                                    EXIT return_system_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            /* -----------------End of 20060313 --------------------------------- */
            /* ---- Patient merged from [FROM_HKID] to [TO_HKID] */
            IF EXISTS (SELECT
                *
                FROM move_episode_indicator
                WHERE from_patient_key = var_from_patient_key AND to_patient_key = par_to_patient_key) THEN
                BEGIN
                    IF var_patient_remove_flag = 'Y' THEN
                        UPDATE move_episode_indicator
                        SET move_status = 'M', update_dtm = timestamp_convert(par_source_system_dtm), /* ---20130521 */ update_user = par_update_by, update_system = par_source_system
                            WHERE from_patient_key = var_from_patient_key AND to_patient_key = par_to_patient_key;
                    ELSE
                        UPDATE move_episode_indicator
                        SET move_status = 'M', update_dtm = timestamp_convert(par_source_system_dtm), /* ---20130521 */ update_user = par_update_by, update_system = par_source_system
                            WHERE from_patient_key = var_from_patient_key AND to_patient_key = par_to_patient_key AND hospital_code = par_hospital_code;
                    END IF;
                    var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                        var_error
                                        INTO var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;
                END;
            END IF;
            /* --- 20130205 :   Patient merged from [TO_HKID] to [FROM_HKID] */

            IF EXISTS (SELECT
                *
                FROM move_episode_indicator
                WHERE from_patient_key = par_to_patient_key AND to_patient_key = var_from_patient_key) THEN
                BEGIN
                    IF var_patient_remove_flag = 'Y' THEN
                        UPDATE move_episode_indicator
                        SET move_status = 'M', update_dtm = timestamp_convert(par_source_system_dtm), /* ---20130521 */ update_user = par_update_by, update_system = par_source_system
                            WHERE from_patient_key = par_to_patient_key AND to_patient_key = var_from_patient_key;
                    ELSE
                        UPDATE move_episode_indicator
                        SET move_status = 'M', update_dtm = timestamp_convert(par_source_system_dtm), /* ---20130521 */ update_user = par_update_by, update_system = par_source_system
                            WHERE from_patient_key = par_to_patient_key AND to_patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
                    END IF;

					var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                        var_error
                                        INTO var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;
                END;
            END IF;
            /* **************20081205 SL : UID linkage********************** */
            /* UID_HKID = hkid ; Link_HKID = other_doc_no */
            /* --- new error code 210003 Fail to insert hkpmi_uid_table */
            
            /* ---Only linked HKIDs merge together will update status to CS. */
            IF substring(par_from_hkid, 1, 1) = 'U' AND EXISTS (SELECT
                1
                FROM hkpmi_uid_table
                WHERE uid_hkid = par_from_hkid) THEN
                BEGIN
                    select  link_hkid from hkpmi_uid_table into var_link_hkid where uid_hkid =par_from_hkid;
                    /* --print "from_id[%1!] to_hkid[%2!] link_hkid[%3!] link_status[%4!] ",@from_hkid,@to_hkid,@link_hkid,@update_link_status */
                    IF par_to_hkid = par_from_hkid THEN
						

                        BEGIN
							select 'CS' into var_update_link_status;
                        END;
                    /* --- 1).  merge to link ID :  set link status = CS from 'L'/'PS' */
                    ELSE

                        BEGIN
							select 'CD' into var_update_link_status;
                        END;
                    END IF; /* --2 ). merge to other ID: set link status = CD */
                    CALL hkpmi_update_uid_table(pas_return_code, 'U', par_hospital_code, par_from_hkid, var_link_hkid, var_update_link_status, NULL, NULL, NULL, NULL, par_source_system_dtm, par_hospital_code, par_update_by, par_source_system, NULL, NULL, NULL,var_rtn_code);

                    IF var_rtn_code < 0 THEN
                        BEGIN
                            /*
                           [9996 - Severity CRITICAL - Transformer error occurred in userVariable. Please submit report to developers.]
                            
                            */
							select 210003 into var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* **************20081205 SL : UID linkage********************** */
            /* ** 20111026 EC : Update Death_transaction table ** */
            IF EXISTS (SELECT
                *
                FROM death_transaction
                WHERE hospital_code = par_hospital_code AND patient_key = var_from_patient_key) THEN
                BEGIN
                    UPDATE death_transaction
                    SET patient_key = par_to_patient_key
                        WHERE hospital_code = par_hospital_code AND patient_key = var_from_patient_key;
                    var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;
                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                        var_error
                                        INTO var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;
                END;
            END IF;
            /* ** 20111026 EC : Update Death_transaction table ** */
            /* ---20120908 --- */
           	begin
			INSERT INTO hkpmi_pin_change_log (hosp_code, txn_dtm, txn_type, hkid, patient_key, old_hkid, old_patient_key, update_by, source_sys, source_sys_dtm, update_hosp)
                VALUES (par_hospital_code, var_tran_system_dtm, par_txn_type, par_to_hkid, par_to_patient_key, par_from_hkid, var_from_patient_key, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code);
            /* select @error = @@error, @rowcount = @@rowcount */
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;
			var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                  	GET STACKED diagnostics var_error = RETURNED_SQLSTATE; 
                  	raise notice 'var_error=%',var_error;
			end;
			/* --- the uniqe key = hosp_code + txn_dtm + hkid  --> 2601 SHOULD NOT occurred */
            IF var_error != 0 THEN
                BEGIN
                    /* Fail to insert into hkpmi_pin_change_log. */
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    EXIT return_system_error;
                END;
            END IF;

            IF var_rowcount != 1 THEN
                BEGIN

					SELECT
                    200118
                    INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* ---- END 20120908 --- */
   
            SELECT
                patient_key into var_prt
                FROM non_ha_patient_status
                WHERE patient_key = var_from_patient_key;
			GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;
            IF var_rowcount > 0 THEN
                BEGIN
                    CALL hkpmi_set_nonha_pat_status(par_patient_key := var_from_patient_key, par_status := 'Merged', par_source_system := par_source_system, par_update_hospital := par_hospital_code, par_update_datetime := var_tran_system_dtm, par_update_by := par_update_by, par_action := 'U',pas_return_code :=var_rtn_code);

                    IF var_rtn_code != 0 THEN
                        BEGIN
                            IF var_rtn_code > 500000 THEN

                                BEGIN
									SELECT var_rtn_code into var_return_error_code;
								 raise notice  '9var_return_error_code=%',var_return_error_code;
                                END;
                            ELSE
 
                                BEGIN
									SELECT 500035 into var_return_error_code;
                                END;
                            END IF;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;

            pas_return_code := 0;
            RETURN;
        END;

        IF var_begin_tran = 'Y' THEN
            BEGIN
                ROLLBACK;
            END;
        END IF;
--        RAISE EXCEPTION USING ERRCODE := var_return_error_code;
        raise notice  '12var_return_error_code=%',var_return_error_code;
        pas_return_code := var_return_error_code;
        RETURN;
        
    END;
	
    IF var_begin_tran = 'Y' THEN
            BEGIN
                ROLLBACK;
            END;
        END IF;
	raise notice  '11var_return_error_code=%',var_return_error_code;
    pas_return_code := var_return_error_code;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_patient_merge" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";