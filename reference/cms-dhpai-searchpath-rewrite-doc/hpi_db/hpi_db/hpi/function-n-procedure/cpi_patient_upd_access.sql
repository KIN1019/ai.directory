-- DROP PROCEDURE cpi_patient_upd_access(inout int4, in varchar, in varchar, in varchar, in int4, in timestamp, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE cpi_patient_upd_access(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_key character varying, IN par_access_code integer, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character varying, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_success_flag VARCHAR(1);
    var_exit_flag VARCHAR(1);
    var_chk_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code INTEGER;
    var_download_err_string VARCHAR(255);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_rep_hospital INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(01);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(1);
    var_txn_type VARCHAR(3);
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */
		RAISE NOTICE 'select hospital  =%',par_hospital_code;
        IF NOT EXISTS (SELECT
            *
            FROM hospital
            WHERE hospital_code = par_hospital_code) THEN
            BEGIN
                SELECT
                    200002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        RAISE NOTICE 'select hospital  =%',par_hospital_code;
        SELECT
            '034'
            INTO var_txn_type;
        SELECT
            update_dtm, patient_name, sex, dob
            INTO var_chk_update_datetime, var_patient_name, var_sex, var_dob
            FROM cpi_patient
            WHERE patient_key = par_patient_key AND hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
		RAISE NOTICE 'select cpi_patient sql$rowcount=%', sql$rowcount;
        IF (sql$rowcount != 1) THEN
            BEGIN
                SELECT
                    7013
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /*
        if (@source_system = "DNL")
        begin
        	if (@chk_update_datetime >= @transaction_datetime)
        	begin
        		select @download_err_string =
        			"Patient has been updated after transaction, patient update is rejected! - <Update Hospital code> = " +
        			@update_hospital + " <transaction datetime> = " +
        			convert(char(20),@transaction_datetime,109)
        		print	@download_err_string
        		select	@return_error_code = 7016
        		select	@success_flag = "N"
        		goto return_error
        	end
        end
        else
        */
        RAISE NOTICE 'var_chk_update_datetime=%,par_last_update_datetime=%', to_char(var_chk_update_datetime, 'YYYYMMDD HH24:MI:SS.MS'), to_char(par_last_update_datetime, 'YYYYMMDD HH24:MI:SS.MS');
        IF (to_char(var_chk_update_datetime, 'YYYYMMDD HH24:MI:SS.MS') != to_char(par_last_update_datetime, 'YYYYMMDD HH24:MI:SS.MS')) THEN
            BEGIN
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
        /*
        if (@source_system = "DNL")
        begin
        	select	@update_datetime = @transaction_datetime
        	select	@transaction_datetime = getdate()
        end
        else
        begin
        	select	@update_datetime = getdate()
        	select	@transaction_datetime = @update_datetime
        end
        */
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
        /* Validate key fields */
        /* Get replicate bit values */
        SELECT
            bit_value
            INTO var_rep_hospital
            FROM rep_cluster_bits
            WHERE hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        RAISE NOTICE 'select rep_cluster_bits sql$rowcount=%', sql$rowcount;
        IF (sql$rowcount = 0) THEN
            BEGIN
                /* print "Fail to get bit values from rep_cluster_bits, patient update is rejected!" */
                SELECT
                    7001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        BEGIN
            var_error := 0;
            raise notice 'cpi_patient_upd_access(166)[UPDATE]cpi_patient,par_patient_key=%',par_patient_key;
            UPDATE cpi_patient
            SET access_code = par_access_code, update_hospital = par_update_hospital, update_by = par_update_by, update_dtm = var_update_datetime, rep_clusters = rep_clusters | var_rep_hospital
                WHERE patient_key = par_patient_key AND to_char(update_dtm, 'YYYYMMDD HH24:MI:SS.MS') = to_char(par_last_update_datetime, 'YYYYMMDD HH24:MI:SS.MS');
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        	var_rowcount := sql$rowcount;
            EXCEPTION
                WHEN OTHERS THEN
                    raise notice 'update cpi_patient error %', sqlerrm;
                	var_error := 1;
            
        END;
        

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    7003
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
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

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm)
            VALUES (par_hospital_code, par_transaction_datetime, var_txn_type, par_hkid, par_patient_key, var_patient_name, var_sex, var_dob, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_access_code, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_update_hospital, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, var_source_system_dtm);
            raise notice 'cpi_patient_upd_access(225)[INSERT]cpi_transaction,par_patient_key=%',par_patient_key;
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
                    7015
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        <<insert_transaction>>
        BEGIN
        END;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN
            /*
            rollback cpi_patient_upd_access
            */
	    --ROLLBACK TO SAVEPOINT cpi_patient_upd_access;
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

;ALTER PROCEDURE "cpi_patient_upd_access" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
