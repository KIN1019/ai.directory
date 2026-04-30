-- DROP PROCEDURE hpi.cpi_transfer(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_transfer(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_from_ward_code character varying, IN par_from_ward_class character varying, IN par_from_bed_no character varying, IN par_from_specialty_code character varying, IN par_from_doctor_code character varying, IN par_to_ward_code character varying, IN par_to_ward_class character varying, IN par_to_bed_no character varying, IN par_to_specialty_code character varying, IN par_to_doctor_code character varying, IN par_to_treatment_location character varying, IN par_transfer_datetime timestamp without time zone, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_isolation_status character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt               INTEGER;
    var_valid_flag        VARCHAR(01);
    var_last_ward_code    VARCHAR(04);
    var_last_ward_class   VARCHAR(01);
    var_last_specialty    VARCHAR(04);
    var_last_bed_no       VARCHAR(05);
    var_success_flag      VARCHAR(01);
    var_exit_flag         VARCHAR(01);
    var_movement_type     VARCHAR(01);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error             INTEGER;
    var_rowcount          INTEGER;
    var_return_error_code INTEGER;
    var_movement_count    INTEGER;
    var_bed_status        VARCHAR(1);
    var_return_code       int;
    sql$rowcount          BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */
        IF txid_current() IS NULL THEN
            begin
                RAISE EXCEPTION '%', 'N' USING ERRCODE = 20000;
            end;
        END IF;
        /* Assign the transaction_datetime of source system to source_system_dtm */
        SELECT par_transaction_datetime
        INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        /* use system date/time of ADT and LRRDT as update_dtm */
        IF par_source_system NOT IN ('ADT', 'LRRDT') THEN
            SELECT timestamp_convert(localtimestamp)
            INTO par_transaction_datetime;
        END IF;
        /* Set flags */
        SELECT 'Y'
        INTO var_success_flag;
        /* Validate key fields */
        CALL cpi_pq_validate_ward(var_return_code, par_hospital_code, par_to_ward_code, par_to_ward_class,
                                               par_transfer_datetime, var_valid_flag);

        IF (var_valid_flag = 'N') THEN
            BEGIN
                /* print "Ward transfer to does not exist in Ward table, transfer is rejected!" */
                SELECT 3001
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        CALL cpi_pq_validate_spec(var_return_code, par_hospital_code, par_to_specialty_code, par_case_type,
                                               par_transfer_datetime, var_valid_flag);

        IF (var_valid_flag = 'N') THEN
            BEGIN
                /* print "Specialty does not exist in Specialty table, transfer is rejected!" */
                SELECT 3002
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        /* Check existence of case */
        SELECT COUNT(*) INTO var_cnt
        FROM cpi_case
        WHERE hospital_code = par_hospital_code
          AND case_no = par_case_no
          AND status_code != 'CC';

        IF var_cnt = 0 THEN
            BEGIN
                /* print "Case does not exist in cpi_case, transfer is rejected!" */
                SELECT 3003
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Case does not exist in cpi_case, transfer is rejected!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        /* Check transfer information */
        SELECT last_ward_code,
               last_ward_class,
               last_specialty,
               last_bed_no,
               movement_count
        INTO var_last_ward_code, var_last_ward_class, var_last_specialty, var_last_bed_no, var_movement_count
        FROM cpi_case
        WHERE hospital_code = par_hospital_code
          AND case_no = par_case_no;

        IF NOT ((var_last_ward_code = par_from_ward_code) AND (var_last_ward_class = par_from_ward_class) AND
                (var_last_specialty = par_from_specialty_code) AND (var_last_bed_no = par_from_bed_no)) THEN
            BEGIN
                /* print "Transfer from information is not correct, transfer is rejected!" */
                SELECT 3004
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Transfer from information is not correct, transfer is rejected!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        SELECT var_movement_count + 1 INTO var_movement_count;

        BEGIN
            UPDATE cpi_case
            SET last_specialty  = par_to_specialty_code,
                last_bed_no     = par_to_bed_no,
                last_ward_code  = par_to_ward_code,
                last_ward_class = par_to_ward_class,
                update_by       = par_update_by,
                update_dtm      = par_transaction_datetime,
                movement_count  = var_movement_count
            WHERE hospital_code = par_hospital_code
              AND case_no = par_case_no;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to update cpi_case, transfer is rejected!" */
                SELECT 3005
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Fail to update cpi_case, transfer is rejected!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        /* insert cpi_movement */
        IF par_txn_type IN ('140', '160', '170') THEN
            SELECT 'T' INTO var_movement_type;
        ELSE
            IF par_txn_type = '700' THEN
                SELECT 'B' INTO var_movement_type;
            END IF;
        END IF;

        BEGIN
            INSERT INTO cpi_movement (hospital_code, case_no, movement_count, ward_code, bed_no, specialty,
                                                   ward_class, movement_type, movement_dtm, treatment_location,
                                                   update_dtm, update_by, doctor_code)
            VALUES (par_hospital_code, par_case_no, var_movement_count, par_to_ward_code, par_to_bed_no,
                    par_to_specialty_code, par_to_ward_class, var_movement_type, par_transfer_datetime,
                    par_to_treatment_location, par_transaction_datetime, par_update_by, par_to_doctor_code);
            var_error := 0;
        /*EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;*/
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT 14004 INTO var_return_error_code;
                SELECT 'N' INTO var_success_flag;
                RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;

        BEGIN
            UPDATE Ward_list
            SET Ward_code      = par_to_ward_code,
                Specialty_code = par_to_specialty_code,
                Bed_no         = par_to_bed_no
            WHERE Hospital_code = par_hospital_code
              AND Case_no = par_case_no;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT 3007
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;

        IF par_to_bed_no IS NOT NULL AND par_from_bed_no <> par_to_bed_no THEN
            BEGIN
                BEGIN
                    SELECT Status
                    INTO var_bed_status
                    FROM Bed
                    WHERE Hospital_code = par_hospital_code
                      AND Ward_code = par_to_ward_code
                      AND Bed_no = par_to_bed_no;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 3008
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;

                IF var_bed_status <> 'V' THEN
                    BEGIN
                        SELECT 3009
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;

                BEGIN
                    raise notice '111111111';
                    UPDATE Bed
                    SET Status = 'O'
                    WHERE Hospital_code = par_hospital_code
                      AND Ward_code = par_to_ward_code
                      AND Bed_no = par_to_bed_no;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 3010
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        raise notice 'par_from_bed_no=% par_from_bed_no=% par_to_bed_no=%',par_from_bed_no,par_from_bed_no,par_to_bed_no;
        IF (par_from_bed_no IS NOT NULL AND par_from_bed_no <> par_to_bed_no) or (par_from_bed_no IS NOT NULL and par_to_bed_no is null) THEN
            BEGIN
                BEGIN
                    raise notice '22222222';
                    UPDATE Bed
                    SET Status = 'V'
                    WHERE Hospital_code = par_hospital_code
                      AND Ward_code = par_from_ward_code
                      AND Bed_no = par_from_bed_no;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 3010
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* Yorky LEUNG 20160426 - Update patient isolation status */
        IF par_isolation_status IS NOT NULL THEN
            BEGIN
                /* Create a isolation case record */
                BEGIN
                    INSERT INTO isolation_case (hospital_code, case_no, movement_count, iso_status,
                                                             update_datetime, update_by)
                    VALUES (par_hospital_code, par_case_no, var_movement_count, par_isolation_status,
                            par_transfer_datetime, par_update_by);
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;

                IF var_error != 0 THEN
                    BEGIN
                        SELECT var_error INTO var_return_error_code;
                        RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /*
        Prevent transaction time of different source system is the same.  Add seconds to the transaction time.
        */
        SELECT COUNT(*)
        INTO var_cnt
        FROM cpi_transaction
        WHERE hospital_code = par_hospital_code
          AND transaction_datetime = par_transaction_datetime;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT 'N'
                INTO var_exit_flag;

                WHILE (var_exit_flag = 'N')
                    LOOP
                        SELECT 1 * INTERVAL '1 second' + par_transaction_datetime::TIMESTAMP
                        INTO par_transaction_datetime;
                        SELECT COUNT(*)
                        INTO var_cnt
                        FROM cpi_transaction
                        WHERE hospital_code = par_hospital_code
                          AND transaction_datetime = par_transaction_datetime;

                        IF (var_cnt = 0) THEN
                            SELECT 'Y' INTO var_exit_flag;
                        END IF;
                    END LOOP;
            END;
        END IF;

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid,
                                                      patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2,
                                                      ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code,
                                                      other_document_no, reference, medical_record_number, remark,
                                                      building, room, floor, block, district_code, religion_code,
                                                      phone1, phone2, address_indicator,
                                                      mobile_phone, sms_language, death_indicator, death_date,
                                                      death_code, card_holder, priority, major_nok, nok_name, nok_hkid,
                                                      nok_relation_code, nok_building, nok_room, nok_floor, nok_block,
                                                      nok_district_code, nok_phone1, nok_phone2,
                                                      nok_address_indicator, nok_mobile_phone,
                                                      nok_sms_language, case_no, admission_datetime,
                                                      source_indicator, source_code, patient_type, discharge_code,
                                                      discharge_datetime, destination_code, doctor_code, case_type,
                                                      security_count, case_access_code, pmi_access_code, ambulance_no,
                                                      police_case, labour_case, ae_case_type, dba_flag,
                                                      follow_up_datetime, ward_code, specialty_code, sub_specialty_code,
                                                      bed_no, ward_class, transfer_datetime, old_patient_key, old_name,
                                                      old_hkid, old_sex, old_dob, old_ward_class, old_ward_code,
                                                      old_specialty_code, old_bed_no, old_doctor_code, pp_code,
                                                      update_hospital, update_by, update_datetime, source_system,
                                                      success_indicator, upload_status, source_system_dtm)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_hkid, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_case_no, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, par_to_doctor_code, par_case_type, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, par_to_ward_code, par_to_specialty_code, NULL, par_to_bed_no, par_to_ward_class,
                    par_transfer_datetime, NULL, NULL, NULL, NULL, NULL, par_from_ward_class, par_from_ward_code,
                    par_from_specialty_code, par_from_bed_no, par_from_doctor_code, NULL, par_hospital_code,
                    par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, 'Y', var_source_system_dtm);
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert cpi_transaction for transfer!" */
                SELECT 3006
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Fail to insert cpi_transaction for transfer!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;

    END;

    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_transfer" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
