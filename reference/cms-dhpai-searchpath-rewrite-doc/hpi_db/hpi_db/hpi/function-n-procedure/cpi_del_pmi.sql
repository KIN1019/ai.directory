-- DROP PROCEDURE cpi_del_pmi(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_del_pmi(INOUT pas_return_code integer, IN par_input_hkid character varying, IN par_input_hosp_code character varying, IN par_input_name character varying, IN par_input_sex character varying, IN par_input_dob timestamp without time zone, IN par_input_ccc1 character varying, IN par_input_ccc2 character varying, IN par_input_ccc3 character varying, IN par_input_ccc4 character varying, IN par_input_ccc5 character varying, IN par_input_ccc6 character varying, IN par_input_exact_dob_flag character varying, IN par_input_patient_key character varying, IN par_transaction_datetime timestamp without time zone, IN par_user_id character varying, IN par_source_system character varying, IN par_update_hosp character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_success_flag VARCHAR(1);
    var_txn_type VARCHAR(3);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code INTEGER;
    var_upload_status VARCHAR(1);
    var_cnt INTEGER;
    var_exit_flag VARCHAR(1);
    var_rowcount INTEGER;
    var_error INTEGER;
    var_pmi_last_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
   	error_message text;
BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */
		
        IF NOT EXISTS (SELECT
            *
            FROM hospital
            WHERE hospital_code = par_input_hosp_code) THEN
            BEGIN
                SELECT
                    200002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        SELECT
            '250'
            INTO var_txn_type;
        /* -- check patient existance -- */
        
        /* --if not exists ( select * */
        
        /* --					from	cpi_patient */
        
        /* --	where	patient_key = @input_patient_key and */
        
        /* --			hkid = @input_hkid) */
        SELECT
            update_dtm
            INTO var_pmi_last_upd_dtm
            FROM cpi_patient
            WHERE patient_key = par_input_patient_key AND hkid = par_input_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF (sql$rowcount <> 1) THEN
            BEGIN
                SELECT
                    7013
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;

        IF var_pmi_last_upd_dtm > par_transaction_datetime THEN
            BEGIN
                SELECT
                    7016
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /*
        Assign the transaction_datetime of source
        system to source_system_dtm
        */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_update_datetime;
        SELECT
            var_update_datetime
            INTO par_transaction_datetime;
        /* Set flags and variables */
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
        /* -- begin to delete-- */
        /* --- cpi_unmatch_hkid -- */
        BEGIN
       	DELETE FROM cpi_unmatch_hkid
            WHERE hkid = par_input_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF (var_error != 0) OR (var_rowcount > 1) THEN
            BEGIN
                SELECT
                    200027
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* -- delete cpi_nok-- */
        BEGIN
        DELETE FROM cpi_nok
            WHERE patient_key = par_input_patient_key;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF (var_error != 0) THEN
            BEGIN
                SELECT
                    200026
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        BEGIN
        /* -- delete cpi_patient_hospital_data -- */
        DELETE FROM cpi_patient_hospital_data
            WHERE hospital_code = par_input_hosp_code AND patient_key = par_input_patient_key;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF (var_error <> 0) OR (var_rowcount > 1) THEN
            BEGIN
                SELECT
                    200025
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        BEGIN
        /* -- delete cpi_patient--- */
        DELETE FROM cpi_patient
            WHERE hkid = par_input_hkid AND patient_key = par_input_patient_key;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF (var_error <> 0) OR (var_rowcount <> 1) THEN
            BEGIN
                SELECT
                    200024
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* insert transaction record */
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
        */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_transaction
            WHERE hospital_code = par_input_hosp_code AND transaction_datetime = par_transaction_datetime;

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
                        WHERE hospital_code = par_input_hosp_code AND transaction_datetime = par_transaction_datetime;

                    IF (var_cnt = 0) THEN
                        SELECT
                            'Y'
                            INTO var_exit_flag;
                    END IF;
                END LOOP;
            END;
        END IF;

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm)
            VALUES (par_input_hosp_code, par_transaction_datetime, var_txn_type, par_input_hkid, par_input_patient_key, par_input_name, par_input_sex, par_input_dob, par_input_exact_dob_flag, par_input_ccc1, par_input_ccc2, par_input_ccc3, par_input_ccc4, par_input_ccc5, par_input_ccc6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_update_hosp, par_user_id, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, var_source_system_dtm);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS then
                	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                	raise notice 'error_message=%',error_message;
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount <> 1) THEN
            BEGIN
                SELECT
                    200028
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* ---20120908 --- */
        BEGIN
            INSERT INTO cpi_pin_change_log (hosp_code, txn_dtm, txn_type, hkid, patient_key, old_hkid, old_patient_key, update_by, source_sys, source_sys_dtm, update_hosp)
            VALUES (par_input_hosp_code, par_transaction_datetime, var_txn_type, par_input_hkid, par_input_patient_key, NULL, NULL, par_user_id, par_source_system, var_source_system_dtm, par_update_hosp);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
        /* --- the uniqe key = hosp_code + txn_dtm + hkid  --> 2601 SHOULD NOT occurred */
        
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
                raise exception '';
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    200028
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* ---- END 20120908 --- */
		exception
			when others then
				RAISE NOTICE '1111%', SQLERRM; 
				EXIT return_error;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN
            pas_return_code := var_return_error_code;
            RETURN;
        END;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_del_pmi" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
