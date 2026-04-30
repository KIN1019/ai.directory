CREATE OR REPLACE PROCEDURE cpi_change_major_nok(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_patient_key VARCHAR, IN par_priority INTEGER, IN par_txn_type VARCHAR, IN par_transaction_datetime TIMESTAMP WITHOUT TIME ZONE, IN par_update_by VARCHAR, IN par_source_system VARCHAR)
AS 
$BODY$
DECLARE
    var_cnt INTEGER;
    var_exit_flag VARCHAR(2);
    var_return_error_code INTEGER;
    var_success_flag VARCHAR(2);
    var_major_nok VARCHAR(2);
    var_nok_name VARCHAR(96);
    var_nok_hkid VARCHAR(24);
    var_nok_relation_code VARCHAR(4);
    var_nok_building VARCHAR(94);
    var_nok_room VARCHAR(10);
    var_nok_floor VARCHAR(4);
    var_nok_block VARCHAR(4);
    var_nok_district_code VARCHAR(10);
    var_nok_home_phone VARCHAR(20);
    var_nok_other_phone_no_1 VARCHAR(20);
    var_nok_other_phone_ext_1 VARCHAR(8);
    var_nok_other_phone_no_2 VARCHAR(20);
    var_nok_other_phone_ext_2 VARCHAR(8);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
           begin
              select   @return_error_code = 20000
              select   @success_flag = "N"
              goto return_error
           end
        */
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support SAVE TRAN cpi_change_major_nok command. Perform a manual conversion.]
        save tran cpi_change_major_nok
        */
        /* Assign the transaction_datetime of source system to source_system_dtm */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        SELECT
            localtimestamp
            INTO par_transaction_datetime;
        SELECT
            'Y'
            INTO var_success_flag;
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_nok
            WHERE patient_key = par_patient_key AND priority = par_priority;

        IF (var_cnt = 0) THEN
            BEGIN
                /* print "NOK does not exist, change major NOK is rejected!" */
                SELECT
                    12001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        BEGIN
            UPDATE cpi_nok
            SET major_nok = 'Y'
                WHERE patient_key = par_patient_key AND priority = par_priority;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to update cpi_nok, change major NOK is rejected!" */
                SELECT
                    12002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        BEGIN
            UPDATE cpi_nok
            SET major_nok = 'N'
                WHERE patient_key = par_patient_key AND priority != par_priority;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        /* No need to check @@rowcount because it may not have any rows */
        IF (var_error != 0) THEN
            BEGIN
                /* print "Fail to update cpi_nok, change major NOK is rejected!" */
                SELECT
                    12002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        SELECT
            major_nok, nok_name, hkid, relationship, building, room, floor, block, district, home_phone, office_phone, office_phone_ext, other_phone, other_phone_ext
            INTO var_major_nok, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2
            FROM cpi_nok
            WHERE patient_key = par_patient_key AND priority = par_priority;
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
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, home_phone_no, other_phone_no_1, other_phone_ext_1, other_phone_no_2, other_phone_ext_2, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_home_phone, nok_other_phone_no_1, nok_other_phone_ext_1, nok_other_phone_no_2, nok_other_phone_ext_2, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, NULL, par_patient_key, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_priority, var_major_nok, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hospital_code, par_update_by, localtimestamp, par_source_system, var_success_flag, 'Y', var_source_system_dtm);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        <<insert_transaction>>
        BEGIN
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF (var_error != 0) OR (var_rowcount = 0) THEN
                BEGIN
                    /* print "Fail to insert cpi_transaction for change major NOK!" */
                    SELECT
                        12003
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    EXIT return_error;
                END;
            END IF;
        END;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN
            /*
            [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
            rollback cpi_change_major_nok
            */
            pas_return_code := var_return_error_code;
            RETURN;
        END;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
END;
$BODY$
LANGUAGE plpgsql;