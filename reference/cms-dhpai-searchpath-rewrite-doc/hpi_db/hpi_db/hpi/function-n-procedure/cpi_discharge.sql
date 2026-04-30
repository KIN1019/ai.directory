-- DROP PROCEDURE hpi.cpi_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.cpi_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_doctor_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_mrt_indicator character varying, IN par_followup_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_death_datetime timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_patient_key VARCHAR(08);
    var_valid_flag VARCHAR(2);
    var_success_flag VARCHAR(01);
    var_exit_flag VARCHAR(01);
    var_treatment_location VARCHAR(04);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_error_code INTEGER;
    var_movement_count INTEGER;
    var_patient_name VARCHAR(48);
    var_sex VARCHAR(01);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_discharge_code VARCHAR(01);
    var_last_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_status_code VARCHAR(2);
    var_return_code INTEGER;
    var_upload_status VARCHAR(1);
    var_check_death_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_body_category VARCHAR(1);
    var_cpi_filler VARCHAR(30);
    sql$rowcount BIGINT;
   var_err_msg text;
    cpi_patient_upd_death$refcur_1 refcursor;
BEGIN
    <<return_error>>
    begin
        /* Declaration */
        SELECT
            - 1
            INTO var_return_error_code; /* ----20140407 */
        IF par_source_system = 'DNL' THEN
            SELECT
                'N'
                INTO var_upload_status;
        ELSE
            SELECT
                'Y'
                INTO var_upload_status;
        END IF;
        /*
        Assign the transaction_datetime of source system
        to source_system_dtm
        */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        /* use system date/time of ADT and LRRDT as update_dtm */
        IF par_source_system NOT IN ('ADT', 'LRRDT') THEN
            SELECT
                timestamp_convert(localtimestamp)
                INTO par_transaction_datetime;
        END IF;
        /* Set flags */
        SELECT
            'Y'
            INTO var_success_flag;
        /* Check existence of case */
        begin
	        
            SELECT
                patient_key, discharge_code, movement_count, status_code
                INTO var_patient_key, var_old_discharge_code, var_movement_count, var_status_code
                FROM cpi_case
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
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
                print "Case does not exist in cpi_case,
                discharge is rejected!"
                */
                select 5003
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
--                raise  exception  'a5003';
            END;
        END IF;
        /* Cross-check patient key with hkid */
        SELECT
            update_dtm
            INTO var_last_update_datetime
            FROM cpi_patient
            WHERE patient_key = var_patient_key AND hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        IF (sql$rowcount = 0) THEN
            BEGIN
                SELECT
                    7013
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
--                raise  exception  'a7013';
            END;
        END IF;
       raise notice 'var_old_discharge_code IS NOT';
        /* Check whether Case has been discharged or not */
        IF var_old_discharge_code IS NOT NULL then
     
            BEGIN
                /*
                print "Case already discharged,
                duplicated discharge is rejected!"
                */
                SELECT
                    5004
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                 raise notice '128';
                EXIT return_error;
               --raise exception 'a5004';
            END;
        END IF;
        /* Validate key fields */
        IF (par_source_system <> 'OPAS') OR
        /* 201810 - modified by freda, HK request OPAS-46 Add discharge code (K, L) */
        (par_discharge_code NOT IN ('B', 'C', 'D', 'E', 'F', 'G', 'R', 'H', 'I', 'J', 'K', 'L')) THEN
            BEGIN
                CALL cpi_pq_validate_discharge_code(var_return_code, par_discharge_code, var_valid_flag);
            END;
        END IF;
        IF (var_valid_flag = 'N') THEN
            BEGIN
                /* print "Invalid Discharge code, discharge is rejected!" */
                SELECT
                    5001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
               --raise  exception  'a5001';
            END;
        END IF;
        IF (par_discharge_code = '0' OR par_discharge_code = '4') THEN
            CALL cpi_pq_validate_destination(var_return_code, par_destination_code, var_valid_flag);
        END IF;

        IF (var_valid_flag = 'N') THEN
            BEGIN
                /*
                print "Destination code does not exist
                in Destination table, discharge is rejected!"
                */
                SELECT
                    5002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
               --raise  exception  'a5002';
            END;
        END IF;
        /* if In-patient case, check Ward and Specialty */
        IF (par_case_type = 'I') THEN
            BEGIN
                CALL cpi_pq_validate_ward(var_return_code, par_hospital_code, par_ward_code, par_ward_class, par_discharge_datetime, var_valid_flag);

                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /* print "Invalid ward information,discharge is rejected!" */
                        SELECT
                            5007
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                       --raise  exception  'a5007';
                    END;
                END IF;
                CALL cpi_pq_validate_spec(var_return_code, par_hospital_code, par_specialty_code, par_case_type, par_discharge_datetime, var_valid_flag);

                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /* print "Invalid specialty code, discharge is rejected!" */
                        SELECT
                            5008
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                       --raise  exception  'a5008';
                    END;
                END IF;
            END;
        END IF;
        SELECT
            var_movement_count + 1
            INTO var_movement_count;

        BEGIN
            UPDATE cpi_case
            SET discharge_dtm = par_discharge_datetime, discharge_code = par_discharge_code, destination_code = par_destination_code, update_by = par_update_by, update_dtm = par_transaction_datetime, movement_count = var_movement_count, mrt_indicator = par_mrt_indicator
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            raise notice 'cpi_discharge[UPDATE]cpi_case,case_no=%',par_case_no;   
            var_error := 0;
            EXCEPTION
                WHEN OTHERS then
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to update cpi_case, discharge is rejected!" */
                SELECT
                    5005
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
               --raise  exception  'a5005';
            END;
        END IF;
        SELECT
            treatment_location
            INTO var_treatment_location
            FROM cpi_movement
            WHERE (ward_code = par_ward_code or (ward_code is null and par_ward_code is null)) AND specialty = par_specialty_code AND (bed_no = par_bed_no or (par_bed_no is null and bed_no is null)) AND (ward_class = par_ward_class or (par_ward_class is null and ward_class is null)) AND case_no = par_case_no AND movement_count = var_movement_count - 1 AND hospital_code = par_hospital_code;
  
           GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
         IF (var_rowcount != 1) OR (var_error != 0) THEN
             BEGIN
                 SELECT
                     5011
                     INTO var_return_error_code;
                 SELECT
                     'N'
                     INTO var_success_flag;
                 EXIT return_error;
                --raise  exception  'a5011';
             END;
         END IF;

        begin
	                    raise notice 'INSERT INTO cpi_movement ';  

            INSERT INTO cpi_movement (hospital_code, case_no, movement_count, ward_code, bed_no, specialty, ward_class, movement_type, movement_dtm, treatment_location, update_dtm, update_by, doctor_code)
            VALUES (par_hospital_code, par_case_no, var_movement_count, par_ward_code, par_bed_no, par_specialty_code, par_ward_class, 'D', par_discharge_datetime, var_treatment_location, par_transaction_datetime, par_update_by, par_doctor_code);
            raise notice 'cpi_discharge[INSERT]cpi_movement,par_case_no=%',par_case_no;  
            var_error := 0;
        
            EXCEPTION
                WHEN OTHERS  then 
                IF POSITION('20017' IN SQLERRM) > 0 THEN
		            RAISE EXCEPTION 'Movement datetime should be greater than last Movement datetime' using errcode:=20017;
		            return;
		        ELSE
		            RAISE NOTICE 'INSERT INTO cpi_movement-error %', SQLERRM; 
		        END IF;
                    var_error := 1;
					
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
		
        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                SELECT
                    14005
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
               --raise  exception  'a14005';
            END;
        END IF;

        IF par_case_type IN ('I', 'A') THEN
            BEGIN
                BEGIN
                    DELETE FROM Ward_list
                        WHERE Hospital_code = par_hospital_code AND Case_no = par_case_no;
                       raise notice 'cpi_discharge-[DELETE]Ward_list Case_no=%',par_case_no;
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
                            5012
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                       --raise  exception  'a5012';
                    END;
                END IF;

                IF par_bed_no IS NOT NULL THEN
                    BEGIN
                        BEGIN
                            UPDATE Bed
                            SET Status = 'V'
                                WHERE Hospital_code = par_hospital_code AND Ward_code = par_ward_code AND Bed_no = par_bed_no;
                             raise notice 'cpi_discharge[UPDATE]Bed,Bed_no=%',par_bed_no;  
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
                                    5013
                                    INTO var_return_error_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                EXIT return_error;
                               --raise  exception  'a5013';
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF par_case_type = 'A' AND par_followup_datetime IS NOT NULL THEN
            BEGIN
                BEGIN
                    UPDATE cpi_ae_case_detail
                    SET follow_up_datetime = par_followup_datetime
                        WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                    raise notice 'cpi_discharge[UPDATE]cpi_ae_case_detail,case_no=%',par_case_no;  
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
                            5014
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                       --raise  exception  'a5014';
                    END;
                END IF;
            END;
        END IF;
        /* 20160426 - CR31244 Insert an entry for isolation_case to set-off the isolation status by Yorky Leung */
        IF EXISTS (SELECT
            1
            FROM isolation_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
            BEGIN
                BEGIN
                    INSERT INTO isolation_case (hospital_code, case_no, movement_count, update_datetime, update_by)
                    VALUES (par_hospital_code, par_case_no, var_movement_count, par_transaction_datetime, par_update_by);
                    raise notice 'cpi_discharge[INSERT]isolation_case,case_no=%',par_case_no;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount != 1) THEN
                    BEGIN
                        SELECT
                            17000
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                       --raise  exception  'a17000';
                    END;
                END IF;
            END;
        END IF;
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
        /* YL : Add body_cateogry to cpi_filler */
        IF (par_discharge_code = '1') THEN /* Set patient to dead */
            BEGIN
                SELECT
                    body_category
                    INTO var_body_category
                    FROM cpi_patient
                    WHERE patient_key = var_patient_key;
            END;
        END IF;

        IF var_body_category IS NOT NULL THEN
            SELECT
                CONCAT(COALESCE(par_mrt_indicator, REPEAT(' ', 1)), REPEAT(' ', 28), var_body_category)
                INTO var_cpi_filler;
        ELSE
            SELECT
                par_mrt_indicator
                INTO var_cpi_filler;
        END IF;
                 

        begin
	        INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm, cpi_filler)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_case_no, NULL, NULL, NULL, NULL, par_discharge_code, par_discharge_datetime, par_destination_code, par_doctor_code, par_case_type, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_ward_code, par_specialty_code, par_sub_specialty, par_bed_no, par_ward_class, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hospital_code, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, var_source_system_dtm, var_cpi_filler);
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;
            raise notice 'cpi_discharge[INSERT]cpi_transaction,hkid=%',par_hkid;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS then
                	GET STACKED DIAGNOSTICS var_err_msg = MESSAGE_TEXT;
            	raise notice 'error: %',var_err_msg;
                    var_error := 1;
        END;
       
        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert cpi_transaction for discharge!" */
                SELECT
                    5006
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
               --raise  exception  'a5006';
            END;
        END IF;

        IF (par_discharge_code = '1') THEN /* Set patient to dead */
            BEGIN
                IF (par_death_datetime IS NOT NULL) AND (par_death_datetime <> par_discharge_datetime) THEN
                    SELECT
                        par_death_datetime
                        INTO var_check_death_dtm;
                ELSE
                    SELECT
                        par_discharge_datetime
                        INTO var_check_death_dtm;
                END IF;
                CALL cpi_patient_upd_death(var_return_code, par_hospital_code, par_hkid, var_patient_key, var_check_death_dtm, 'Y', var_source_system_dtm, par_hospital_code, par_update_by, var_last_update_datetime, par_source_system, 'Y', var_body_category);


                IF (var_return_code != 0) THEN
                    BEGIN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                       --raise  exception  '';
                    END;
                END IF;
            END;
        END IF;
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


;ALTER PROCEDURE "cpi_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
