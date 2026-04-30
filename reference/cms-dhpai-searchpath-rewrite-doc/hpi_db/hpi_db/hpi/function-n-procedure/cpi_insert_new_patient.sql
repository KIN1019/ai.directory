-- DROP PROCEDURE hpi.cpi_insert_new_patient(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, inout varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_insert_new_patient(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_chi_name character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_reference character varying, IN par_medical_record_number character varying, IN par_remark character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_home_phone_no character varying, IN par_other_phone_no_1 character varying, IN par_other_phone_ext_1 character varying, IN par_other_phone_no_2 character varying, IN par_other_phone_ext_2 character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_death_code character varying, IN par_card_holder integer, INOUT par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_home_phone character varying, IN par_nok_other_phone_no_1 character varying, IN par_nok_other_phone_ext_1 character varying, IN par_nok_other_phone_no_2 character varying, IN par_nok_other_phone_ext_2 character varying, IN par_txn_type character varying, IN par_access_code integer, IN par_security integer, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character varying, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_new_patient_key VARCHAR(8);
    var_return_status SMALLINT;
    var_n_prior INTEGER;
    var_major_nok VARCHAR(1);
    var_tmp_mrn VARCHAR(8);
    var_patient_no INTEGER;
    var_rep_hospital INTEGER;
    var_rep_clusters INTEGER;
    var_success_flag VARCHAR(1);
    var_exit_flag VARCHAR(1);
    var_tmp_phonetic VARCHAR(48);
    var_chk_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code INTEGER;
    var_download_err_string VARCHAR(255);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_upload_status VARCHAR(1);
    var_cpi_filler VARCHAR(30);
    var_is_schi_name VARCHAR(01);
    var_return_code int;
    sql$rowcount BIGINT;
BEGIN
    <<return_error>>
    BEGIN
        /* Declaration */ /* 2006-12-12 Addeded by HK Fong SMR20015887 */

        SELECT
            'N'
            INTO var_upload_status;
        /* Set flags and variables */
        SELECT
            'Y'
            INTO var_success_flag;
        /* Get chinese name from ccc_big5 table */
        CALL cpi_get_phonetic_chin_name(var_return_code, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, var_tmp_phonetic, par_chi_name);
        /* 2006-12-12 Addeded by HK Fong SMR20015887 - Start */
        IF COALESCE(par_chi_name, '') <> '' THEN
            BEGIN
                CALL cpi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => par_ccc_1, par_ccc2 => par_ccc_2, par_ccc3 => par_ccc_3, par_ccc4 => par_ccc_4, par_ccc5 => par_ccc_5, par_ccc6 => par_ccc_6, par_is_schi_name => var_is_schi_name);

                IF var_is_schi_name = 'Y' THEN
                    SELECT
                        NULL
                        INTO par_chi_name;
                END IF;
            END;
        END IF;
        /* 2006-12-12 Addeded by HK Fong SMR20015887 - End */
        /* Validate key fields */
        /* Get replicate bit values */
        SELECT
            bit_value
            INTO var_rep_hospital
            FROM rep_cluster_bits
            WHERE hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF (sql$rowcount = 0) THEN
            BEGIN
                /* print "Fail to get bit values from rep_cluster_bits, patient insertion is rejected!" */
                SELECT
                    13001
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /*
        select	@init_source = bit_value
        	from	source_bits
        	where	source_system = @source_system
        
        	if (@@rowcount = 0)
        	begin
        /*		print "Fail to get init. bit values from source_bits, patient insertion is rejected!" */
        		select	@success_flag = "N"
        		goto return_error
        	end
        */
        /*
        Check whether the HKID/patient_key exists in cpi_patient.
        If Yes, return Error.
        */
        SELECT
            COUNT(*)
            INTO var_cnt
            FROM cpi_patient
            WHERE hkid = par_hkid OR patient_key = par_patient_key;

        IF (var_cnt != 0) THEN
            BEGIN
                /* print "Patient already exists in cpi_patient, patient insertion is rejected!" */
                SELECT
                    13002
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* check hkid if it is an used unhkid for PMI registration 20040914 by Leo Lee */
        IF EXISTS (SELECT
            *
            FROM cpi_used_unhkid
            WHERE hkid = par_hkid) THEN
            BEGIN
                SELECT
                    200033
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* If patient key is not given */
        IF (par_patient_key IS NULL) THEN
            BEGIN
                /* Patient_key given is null, New patient generated by CPI */
                /* --		save transaction ins_patient */
                CALL cpi_pu_get_patient_key(var_return_status, par_hospital_code, var_new_patient_key );

                IF (var_return_status != 0) THEN
                    BEGIN
                        /* print "Fail to get a new patient key, patient insertion is rejected!" */
                        SELECT
                            13003
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
                SELECT
                    var_new_patient_key
                    INTO par_patient_key;
            END;
        END IF;
        SELECT
            var_rep_hospital
            INTO var_rep_clusters;
        SELECT
            CAST (par_patient_key AS INTEGER)
            INTO var_patient_no;
        /* insert a new patient record */
        BEGIN
            INSERT INTO cpi_patient (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, reference, building, room, floor, block, district, religion, phone1,phone2,address_indicator,mobile_phone,sms_language, death_indicator, death_date, death_code, card_holder, access_code, security, patient_no, create_hospital, create_by, create_dtm, update_hospital, update_by, update_dtm, rep_clusters, hkic_symbol)
            VALUES (par_patient_key, par_hkid, par_patient_name, par_sex, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_dob, par_exact_dob_flag, par_marital_status, par_race_code, par_other_document_no, par_reference, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_home_phone_no, par_other_phone_no_1, par_other_phone_ext_1, par_other_phone_no_2, par_other_phone_ext_2, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_access_code, par_security, var_patient_no, par_hospital_code, par_update_by, par_transaction_datetime, par_hospital_code, par_update_by, par_transaction_datetime, var_rep_clusters, par_hkic_symbol);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert a new patient record, patient insertion is rejected!" */
                /* --		rollback transaction ins_patient */
                SELECT
                    13004
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* insert nok record */
        SELECT
            1
            INTO var_n_prior;
        SELECT
            var_n_prior
            INTO par_priority;
        SELECT
            'Y'
            INTO var_major_nok;

        IF (par_nok_name IS NOT NULL) THEN
            BEGIN
                BEGIN
                    INSERT INTO cpi_nok (patient_key, priority, major_nok, hkid, relationship, nok_name, building, room, floor, block, district, phone1,phone2,address_indicator,mobile_phone,sms_language, update_hospital, update_by, update_dtm)
                    VALUES (par_patient_key, var_n_prior, var_major_nok, par_nok_hkid, par_nok_relation_code, par_nok_name, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2, par_hospital_code, par_update_by, par_transaction_datetime);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /* print "Fail to insert into cpi_nok, patient insertion is rejected!" */
                        /* --			rollback transaction ins_patient */
                        SELECT
                            13005
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;

        IF (par_medical_record_number IS NOT NULL) THEN
            BEGIN
                SELECT
                    COUNT(*)
                    INTO var_cnt
                    FROM cpi_patient_hospital_data
                    WHERE hospital_code = par_hospital_code AND mrn = par_medical_record_number;

                IF (var_cnt != 0) THEN
                    BEGIN
                        /* print "Duplicate mrn is found, patient insertion is rejected!" */
                        /* --			rollback transaction ins_patient */
                        SELECT
                            13006
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;

        BEGIN
            INSERT INTO cpi_patient_hospital_data (patient_key, hospital_code, mrn, remark, create_by, create_dtm, update_by, update_dtm)
            VALUES (par_patient_key, par_hospital_code, par_medical_record_number, par_remark, par_update_by, par_transaction_datetime, par_update_by, par_transaction_datetime);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert cpi_patient_hospital_data, patient insertion is rejected!" */
                /* --		rollback transaction ins_patient */
                SELECT
                    20000
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
        /* 20100928  SL */
        SELECT
            CONCAT(REPEAT(' ', 28), SUBSTRING(CONCAT(par_hkic_symbol, REPEAT(' ', 1)), 1, 1))
            INTO var_cpi_filler; /* --hkic_symbol=cpi_filler(29,1) */

        IF (LTRIM(RTRIM(var_cpi_filler)) = '') OR (LTRIM(RTRIM(var_cpi_filler)) is NULL) THEN
            SELECT
                NULL
                INTO var_cpi_filler;
        END IF;

        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, marital_status, race_code, other_document_no, reference, medical_record_number, remark, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, destination_code, doctor_code, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key, old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code, old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm, cpi_filler)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no, par_reference, par_medical_record_number, par_remark, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_home_phone_no, par_other_phone_no_1, par_other_phone_ext_1, par_other_phone_no_2, par_other_phone_ext_2, par_death_indicator, par_death_date, par_death_code, par_card_holder, par_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_home_phone, par_nok_other_phone_no_1, par_nok_other_phone_ext_1, par_nok_other_phone_no_2, par_nok_other_phone_ext_2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_update_hospital, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, par_transaction_datetime, var_cpi_filler);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert into cpi_transaction for patient update!" */
                SELECT
                    7015
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;

        IF par_access_code & 1 = 0 THEN /* patient is confidential */
            BEGIN
                SELECT
                    3 * INTERVAL '1 millisecond' + par_transaction_datetime::TIMESTAMP
                    INTO par_transaction_datetime;
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
                    INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, pmi_access_code, update_hospital, update_by, update_datetime, source_system, success_indicator, upload_status, source_system_dtm)
                    VALUES (par_hospital_code, par_transaction_datetime, '034', par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_access_code, par_update_hospital, par_update_by, timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status, par_transaction_datetime);
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
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
		exception
			when others then
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

;ALTER PROCEDURE "cpi_insert_new_patient" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
