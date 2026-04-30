-- DROP PROCEDURE hpi.cpi_cancel_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_cancel_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_doctor_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt                        INTEGER;
    var_success_flag               VARCHAR(1);
    var_exit_flag                  VARCHAR(1);
    var_discharge_code             VARCHAR(1);
    var_discharge_datetime         TIMESTAMP WITHOUT TIME ZONE;
    var_destination_code           VARCHAR(3);
    var_patient_key                VARCHAR(8);
    var_valid_flag                 VARCHAR(1);
    var_source_system_dtm          TIMESTAMP WITHOUT TIME ZONE;
    var_error                      INTEGER;
    var_rowcount                   INTEGER;
    var_return_error_code          INTEGER;
    var_movement_count             INTEGER;
    var_patient_name               VARCHAR(48);
    var_sex                        VARCHAR(01);
    var_dob                        TIMESTAMP WITHOUT TIME ZONE;
    var_status_code                VARCHAR(2);
    var_last_update_datetime       TIMESTAMP WITHOUT TIME ZONE;
    var_return_code                INTEGER;
    var_bed_status                 VARCHAR(1);
    var_pp_code                    VARCHAR(8);
    var_eh_code                    VARCHAR(8);
    var_upload_status              VARCHAR(1);
    var_body_category              VARCHAR(1);
    sql$rowcount                   BIGINT;
BEGIN
    <<return_error>>
    begin
	    select 0 into var_return_code;
        /* Declaration */
        IF txid_current() IS NULL THEN
            begin
                RAISE EXCEPTION '%', 'N' USING ERRCODE = 20000;
            end;
        END IF;

        IF par_source_system = 'DNL' THEN
            SELECT 'N' INTO var_upload_status;
        ELSE
            SELECT 'Y' INTO var_upload_status;
        END IF;
        /*
        Assign the transaction datetime of source system to source_system_dtm
        */
        SELECT par_transaction_datetime INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        /* use system date/time from ADT and LRRDT as update_dtm */
        IF par_source_system NOT IN ('ADT', 'LRRDT') THEN
            SELECT timestamp_convert(localtimestamp) INTO par_transaction_datetime;
        END IF;
        /* Set flags */
        SELECT 'Y' INTO var_success_flag;
        /* Validate key fields */
        SELECT NULL INTO var_discharge_code;
        /* Check existence of case */
        BEGIN
            SELECT patient_key,
                   discharge_dtm,
                   discharge_code,
                   destination_code,
                   movement_count,
                   status_code
            INTO var_patient_key, var_discharge_datetime, var_discharge_code, var_destination_code, var_movement_count, var_status_code
            FROM cpi_case
            WHERE hospital_code = par_hospital_code
              AND case_no = par_case_no;
       
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
		
        IF (var_error != 0) OR (var_rowcount = 0) OR var_status_code = 'CC' THEN
            BEGIN
                /*
                print "Case does not exist in cpi_case, cancel discharge is rejected!"
                */
                SELECT 6001
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Case does not exist in cpi_case, cancel discharge is rejected!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        /* Cross-check patient key with hkid */
        SELECT update_dtm
        INTO var_last_update_datetime
        FROM cpi_patient
        WHERE patient_key = var_patient_key
          AND hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
		
        IF (sql$rowcount = 0) THEN
            BEGIN
                SELECT 7013
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', var_success_flag USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
    
        /* Check whether Case has been discharged or not */
        IF var_discharge_datetime IS NULL AND var_discharge_code IS NULL THEN
            BEGIN
                /*
                print "Case has not been discharged, cancel discharge is rejected!"
                */
                SELECT 6002
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Case has not been discharged, cancel discharge is rejected!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        /* if In-patient case, check Ward and Specialty */
        IF (par_case_type = 'I') THEN
            BEGIN
                CALL cpi_pq_validate_ward(var_return_code,par_hospital_code, par_ward_code, par_ward_class,
                                                       var_discharge_datetime, var_valid_flag );

                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /*
                        print "Invalid ward information, cancel discharge is rejected!"
                        */
                        SELECT 6005
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', 'Invalid ward information, cancel discharge is rejected!' USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
                CALL cpi_pq_validate_spec(var_return_code,par_hospital_code, par_specialty_code, par_case_type,
                                                       var_discharge_datetime, var_valid_flag);

                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /*
                        print "Invalid specialty code, cancel discharge is rejected!"
                        */
                        SELECT 6006
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', 'Invalid specialty code, cancel discharge is rejected!' USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        SELECT var_movement_count - 1 INTO var_movement_count;

        BEGIN
            UPDATE cpi_case
            SET discharge_dtm    = NULL,
                discharge_code   = NULL,
                destination_code = NULL,
                update_by        = par_update_by,
                update_dtm       = par_transaction_datetime,
                movement_count   = var_movement_count
            WHERE hospital_code = par_hospital_code
              AND case_no = par_case_no;
             raise notice 'cpi_cancel_discharge,[UPDATE]cpi_case case_no=%',par_case_no;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /*
                print "Fail to update cpi_case, cancel discharge is rejected!"
                */
                SELECT 6003
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Fail to update cpi_case, cancel discharge is rejected!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        /* Delete entry from cpi_movement table */
        BEGIN
            DELETE
            FROM cpi_movement
            WHERE hospital_code = par_hospital_code
              AND case_no = par_case_no
              AND movement_count = (var_movement_count + 1);
              raise notice 'cpi_cancel_discharge,[DELETE]cpi_movement case_no=%',par_case_no;
            var_error := 0;
       EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT 14006
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;
        /* Update HN_case_detail, Ward_list, Bed */
        IF par_case_type = 'I' THEN
            BEGIN
                SELECT PP_code, EH_code
                INTO var_pp_code, var_eh_code
                FROM HN_case_detail
                WHERE Hospital_code = par_hospital_code
                  AND Case_no = par_case_no;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 0 THEN
                    SELECT NULL, NULL
                    INTO var_pp_code, var_eh_code;
                ELSE
                    BEGIN
                        BEGIN
                            IF var_pp_code IS NULL AND var_eh_code IS NULL THEN
                                DELETE
                                FROM HN_case_detail
                                WHERE Hospital_code = par_hospital_code
                                  AND Case_no = par_case_no;
                             raise notice 'cpi_cancel_discharge,[DELETE]HN_case_detail case_no=%',par_case_no;
                            ELSE
                                UPDATE HN_case_detail
                                SET Internal_ICD9_code = NULL,
                                    External_ICD9_code = NULL
                                WHERE Hospital_code = par_hospital_code
                                  AND Case_no = par_case_no;
                                    raise notice 'cpi_cancel_discharge,[UPDATE]HN_case_detail case_no=%',par_case_no;
                            END IF;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                SELECT 6010
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF par_case_type IN ('I', 'A') THEN
            BEGIN
                BEGIN
                    INSERT INTO Ward_list (hospital_code, case_no, ward_code, bed_no, specialty_code)
                    VALUES (par_hospital_code, par_case_no, par_ward_code, par_bed_no, par_specialty_code);
                    var_error := 0;
                    raise notice 'cpi_cancel_discharge,[INSERT]Ward_list case_no=%',par_case_no;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 6011
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;

                IF par_bed_no IS NOT NULL THEN
                    BEGIN
                        SELECT Status
                        INTO var_bed_status
                        FROM Bed
                        WHERE Hospital_code = par_hospital_code
                          AND Ward_code = par_ward_code
                          AND Bed_no = par_bed_no;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount = 0 THEN
                            BEGIN
                                SELECT 6012
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;

                        IF var_bed_status <> 'V' THEN
                            BEGIN
                                SELECT 6013
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;

                        BEGIN
                            UPDATE Bed
                            SET Status = 'O'
                            WHERE Hospital_code = par_hospital_code
                              AND Ward_code = par_ward_code
                              AND Bed_no = par_bed_no;
                               raise notice 'cpi_cancel_discharge,[UPDATE]Bed case_no=%',par_case_no;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                SELECT 6014
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;

                BEGIN
                    IF EXISTS (SELECT *
                               FROM cpi_active_case
                               WHERE hospital_code = par_hospital_code
                                 AND case_no = par_case_no) THEN
                        UPDATE cpi_active_case
                        SET active_indicator = 'Y'
                        WHERE hospital_code = par_hospital_code
                          AND case_no = par_case_no;
                         raise notice 'cpi_cancel_discharge[UPDATE]cpi_active_case case_no=%',par_case_no;
                    ELSE
                        INSERT INTO cpi_active_case (hospital_code, case_no, active_indicator)
                        VALUES (par_hospital_code, par_case_no, 'Y');
                        raise notice 'cpi_cancel_discharge[INSERT]cpi_active_case case_no=%',par_case_no;
                    END IF;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 6015
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* 20160426 - CR31244 Remove an entry for isolation_case to set-off the isolation status by Yorky Leung */
        IF EXISTS (SELECT 1
                   FROM isolation_case
                   WHERE hospital_code = par_hospital_code
                     AND case_no = par_case_no
                     AND movement_count = (var_movement_count + 1)
                     AND iso_status IS NULL) THEN
            BEGIN
                BEGIN
                    DELETE
                    FROM isolation_case
                    WHERE hospital_code = par_hospital_code
                      AND case_no = par_case_no
                      AND movement_count = (var_movement_count + 1)
                      AND iso_status IS NULL;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount != 1) THEN
                    BEGIN
                        SELECT 17000
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
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
                        SELECT 3 * INTERVAL '1 millisecond' + par_transaction_datetime::TIMESTAMP
                        INTO par_transaction_datetime;
                        SELECT COUNT(*)
                        INTO var_cnt
                        FROM cpi_transaction
                        WHERE hospital_code = par_hospital_code
                          AND transaction_datetime = par_transaction_datetime;

                        IF (var_cnt = 0) THEN
                            SELECT 'Y'
                            INTO var_exit_flag;
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
                    NULL, var_discharge_code, var_discharge_datetime, var_destination_code, par_doctor_code,
                    par_case_type, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_ward_code,
                    par_specialty_code, par_sub_specialty, par_bed_no, par_ward_class, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hospital_code, par_update_by, timestamp_convert(localtimestamp),
                    par_source_system, var_success_flag, var_upload_status, var_source_system_dtm);
            var_error := 0;
           raise notice 'cpi_cancel_discharge,[INSERT]cpi_transaction case_no=%',par_case_no;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert transaction for cancel discharge!" */
                SELECT 6004
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE EXCEPTION '%', 'Fail to insert transaction for cancel discharge!' USING ERRCODE = var_return_error_code;
                EXIT return_error;
            END;
        END IF;

        IF (var_discharge_code = '1') THEN /* Reset patient dead info */
            BEGIN
                SELECT body_category
                INTO var_body_category
                FROM cpi_patient
                WHERE patient_key = var_patient_key;
                CALL cpi_patient_upd_death(var_return_code,par_hospital_code, par_hkid, var_patient_key, NULL, 'N',
                                                        var_source_system_dtm, par_hospital_code, par_update_by,
                                                        var_last_update_datetime, par_source_system, 'P',
                                                        var_body_category);

                IF (var_return_code != 0) THEN
                    BEGIN
                        SELECT var_return_code
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE EXCEPTION '%', 'N' USING ERRCODE = var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

    END;

    pas_return_code := var_return_code;
    RETURN;
END;
$procedure$
;



;ALTER PROCEDURE "cpi_cancel_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
