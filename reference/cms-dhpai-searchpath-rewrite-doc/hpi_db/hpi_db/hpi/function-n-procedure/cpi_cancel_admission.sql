-- DROP PROCEDURE cpi_cancel_admission(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_cancel_admission(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_valid_flag VARCHAR(1);
    var_patient_key VARCHAR(8);
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_success_flag VARCHAR(1);
    var_exit_flag VARCHAR(1);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_error_code INTEGER;
    var_pp_code VARCHAR(8);
    var_upload_status VARCHAR(1);
    var_return_code int;
    sql$rowcount BIGINT;

BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */
        /*
        if @@trancount = 0
           begin
              select   @return_error_code = 20000
              select   @success_flag = "N"
              goto return_error
           end
        */
--	SAVEPOINT cpi_cancel_admission;
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
        Assign the transaction datetime of source system
        to source_sytem_dtm
        */
        SELECT
            par_transaction_datetime
            INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        /* use system date/time from ADT as update_dtm */
        IF par_source_system <> 'ADT' THEN
            SELECT
                timestamp_convert(localtimestamp)
                INTO par_transaction_datetime;
        END IF;
        /* Set flags */
        SELECT
            'Y'
            INTO var_success_flag;
        /* Validate key fields */
        SELECT
            admission_dtm
            INTO var_admission_datetime
            FROM cpi_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no;


--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_cpi_pq_validate_ward BGN','[cpi_cancel_admission:71]');

        IF (par_case_type = 'I') THEN
            BEGIN
                CALL cpi_pq_validate_ward(var_return_code, par_hospital_code, par_ward_code, par_ward_class, var_admission_datetime, var_valid_flag);

--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CALL_cpi_pq_validate_ward END','[cpi_cancel_admission:78]');

                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /* print "Invalid ward information!" */
                        SELECT
                            2001
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;


                CALL cpi_pq_validate_spec(var_return_code, par_hospital_code, par_specialty_code, par_case_type, var_admission_datetime, var_valid_flag);



                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /* print "Invalid specialty code!" */
                        SELECT
                            2002
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* Check the existence of case */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_case
            WHERE rtrim(hospital_code)  = rtrim(par_hospital_code) AND case_no = par_case_no AND status_code != 'CC';


--           insert into gjp_test(id,msg) values(to_char(current_timestamp,'YYMMDDHH24MISS') || '-CHK_CPI_CASE_EXIST,rtrim(par_hospital_code)=[' || rtrim(par_hospital_code)|| '],par_case_no=['||par_case_no||'],var_cnt=>' || var_cnt, '[cpi_cancel_admission:125]');

        IF var_cnt = 0 THEN
            BEGIN
                /*
                print "Case does not exist in cpi_case,
                cancel admission is rejected!"
                */
                SELECT
                    2003
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;

        /* Check the matching of HKID and case */
        SELECT
            patient_key
            INTO var_patient_key
            FROM cpi_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_patient
            WHERE patient_key = var_patient_key AND hkid = par_hkid;


        IF var_cnt = 0 THEN
            BEGIN
                /*
                print "Case and HKID does not match,
                cancel admission is rejected!"
                */
                SELECT
                    2004
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;





        BEGIN
            UPDATE cpi_case
            SET status_code = 'CC', update_by = par_update_by, update_dtm = par_transaction_datetime
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            raise notice '[179]cpi_cancel_admission[UPDATE cpi_case]par_case_no=%',par_case_no;
            var_error := 0;
            /*
             * EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
                   raise notice 'cpi_cancel_admission,err_msg=>%',sqlerrm;
                   */
        END;






        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /*
                print "Fail to update cpi_case,
                cancel admission is rejected!"
                */
                SELECT
                    2005
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* delete cpi_movement */
        BEGIN
            DELETE FROM cpi_movement
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            raise notice '[215]cpi_cancel_admission[DELETE FROM cpi_movement]par_case_no=%',par_case_no;
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
                    14006
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* delete ae_case_detail */
        IF (par_case_type = 'A') THEN
            BEGIN
                BEGIN
                    DELETE FROM cpi_ae_case_detail
                        WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                     raise notice '[241]cpi_cancel_admission[DELETE FROM cpi_ae_case_detail]par_case_no=%',par_case_no;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) THEN
                    BEGIN
                        SELECT
                            14006
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* delete HN_case_detail */
        IF par_case_type = 'I' THEN
            BEGIN
                IF EXISTS (SELECT
                    *
                    FROM HN_case_detail
                    WHERE Hospital_code = par_hospital_code AND Case_no = par_case_no) THEN
                    BEGIN
                        BEGIN
                            DELETE FROM HN_case_detail
                                WHERE Hospital_code = par_hospital_code AND Case_no = par_case_no;
                             raise notice '[274]cpi_cancel_admission[DELETE FROM HN_case_detail]par_case_no=%',par_case_no;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) THEN
                            BEGIN
                                SELECT
                                    2007
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
        /* delete Ward_list and cpi_active_case */
        IF par_case_type IN ('I', 'A') THEN
            BEGIN
                BEGIN
                    DELETE FROM Ward_list
                        WHERE Hospital_code = par_hospital_code AND Case_no = par_case_no;
                    raise notice '[274]cpi_cancel_admission[DELETE FROM Ward_list]par_case_no=%',par_case_no;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) THEN
                    BEGIN
                        SELECT
                            2008
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;

                IF EXISTS (SELECT
                    *
                    FROM cpi_active_case
                    WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
                    BEGIN
                        BEGIN
                            DELETE FROM cpi_active_case
                                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                            raise notice '[274]cpi_cancel_admission[DELETE FROM cpi_active_case]par_case_no=%',par_case_no;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) THEN
                            BEGIN
                                SELECT
                                    2009
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

        /*
        20020726 SL
        * delete from cpi_case_detail
        * error_msgs.error_code=14007 - "Fail to delete cpi_case_detail, tx is rejected!"
        */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_case_detail
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no;

        IF (var_cnt = 1) THEN
            BEGIN
                BEGIN
                    DELETE FROM cpi_case_detail
                        WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                    raise notice '[274]cpi_cancel_admission[DELETE FROM cpi_case_detail]par_case_no=%',par_case_no;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) THEN
                    BEGIN
                        SELECT
                            14007
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        /* -------- 20050713 -------- */
        SELECT
            0
            INTO var_cnt;
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM mother_baby_case
            WHERE (mother_hospital_code = par_hospital_code AND mother_case_no = par_case_no) OR (baby_hospital_code = par_hospital_code AND baby_case_no = par_case_no);

        IF var_cnt > 0 THEN
            BEGIN
                /* ---select @return_error_code = 2003 */
                SELECT
                    200030
                    INTO var_return_error_code;
                /* ---- New born information already exists */
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* -------- 20050713 -------- */

        /* ---20070712 SL --- */
        IF EXISTS (SELECT
            *
            FROM cpi_linked_case
            WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
            begin
	             raise notice 'into one,par_hospital_code=%,par_case_no=%',par_hospital_code,par_case_no;

                /* ----May del Multi records --- */
                BEGIN
                    DELETE FROM cpi_linked_case
                        WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                    raise notice '[432]cpi_cancel_admission[DELETE FROM cpi_linked_case]par_case_no=%',par_case_no;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) THEN
                    BEGIN
                        SELECT
                            200038
                            INTO var_return_error_code; /* ---"failed to update cpi_linked_case " */
                        SELECT
                            'N'
                            INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        /* ---------reject  cancel admision  ---- */
        IF EXISTS (SELECT
            *
            FROM cpi_linked_case
            WHERE previous_hospital = par_hospital_code AND previous_case = par_case_no) THEN
            begin
	           raise notice 'into two,par_hospital_code=%,par_case_no=%',par_hospital_code,par_case_no;

                SELECT
                    200038
                    INTO var_return_error_code; /* ---"failed to update cpi_linked_case " */
                SELECT
                    'N'
                    INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* ---20070712 SL --- */
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
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_case_no, var_admission_datetime, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_case_type, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_ward_code, par_specialty_code, par_sub_specialty, par_bed_no, par_ward_class, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hospital_code, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, var_source_system_dtm);
           	raise notice '[509]cpi_cancel_admission[ INSERT INTO cpi_transaction]par_case_no=%',par_case_no;
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
                print "Fail to insert cpi_transaction
                for cancel admission!"
                */
                SELECT
                    2006
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
            rollback cpi_cancel_admission
            */
--	    ROLLBACK TO SAVEPOINT cpi_cancel_admission;
	    	RAISE EXCEPTION 'ROLLBACK';
	    	EXCEPTION
                WHEN OTHERS THEN
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

;ALTER PROCEDURE "cpi_cancel_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
