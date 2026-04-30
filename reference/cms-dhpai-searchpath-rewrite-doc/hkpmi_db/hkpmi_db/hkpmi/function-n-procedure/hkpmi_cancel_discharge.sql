-- DROP PROCEDURE hkpmi.hkpmi_cancel_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_cancel_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_doctor_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_case_type VARCHAR(01);
    var_patient_key VARCHAR(08);
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
    var_other_doc_no VARCHAR(12);
    var_building VARCHAR(47);
    var_room VARCHAR(5);
    var_floor VARCHAR(2);
    var_block VARCHAR(2);
    var_district_code VARCHAR(5);
    var_religion_code VARCHAR(3);
    var_phone1_no VARCHAR(10);
    var_phone2 VARCHAR(10);
    var_address_indicator VARCHAR(4);
    var_mobile_phone_no VARCHAR(10);
    var_sms_language VARCHAR(4);
    var_patient_type VARCHAR(03);
    var_patient_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_patient_timestamp timestamp(6);
    var_begin_tran VARCHAR(01);
    var_priority INTEGER;
    var_major_nok VARCHAR(01);
    var_nok_name VARCHAR(48);
    var_nok_hkid VARCHAR(12);
    var_nok_relation_code VARCHAR(2);
    var_nok_building VARCHAR(47);
    var_nok_room VARCHAR(5);
    var_nok_floor VARCHAR(2);
    var_nok_block VARCHAR(2);
    var_nok_district_code VARCHAR(5);
    var_nok_phone1 VARCHAR(10);
    var_nok_phone2 VARCHAR(10);
    var_nok_address_indicator VARCHAR(4);
    var_nok_mobile_phone_no VARCHAR(10);
    var_nok_sms_language VARCHAR(4);
    var_case_patient_key VARCHAR(08);
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_case_timestamp timestamp(6);
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(01);
    var_case_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_case_hkid VARCHAR(12);
    var_case_ward_code VARCHAR(04);
    var_case_ward_class VARCHAR(01);
    var_case_bed_no VARCHAR(05);
    var_case_specialty_code VARCHAR(04);
    var_discharge_code VARCHAR(01);
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_destination_code VARCHAR(05);
    var_valid_flag VARCHAR(01);
    var_success_flag VARCHAR(01);
    var_exit_flag VARCHAR(01);
    var_treatment_location VARCHAR(04);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_error_code INTEGER;
    var_movement_count INTEGER;
    var_status_code VARCHAR(2);
    var_disc_description VARCHAR(05);
    var_return_code INTEGER;
    sql$rowcount BIGINT;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
              SELECT  'Y'
                INTO var_begin_tran;
            IF NOT ((par_source_system IN ('ADT', 'DNL') AND (par_txn_type LIKE '21%' OR par_txn_type LIKE '35%')) OR
            /* --(@source_system like 'OPAS%' and @txn_type = '21A')) */
            (par_source_system LIKE 'OPAS%' AND par_txn_type LIKE '21%')) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            BEGIN
                SELECT
                    patient_key, adm_dtm, case_type, discharge_code, discharge_dtm, destination_code, last_ward_code, last_ward_class, last_specialty_code, last_bed_no, movement_count, row_update_datetime
                    INTO var_patient_key, var_adm_dtm, var_case_type, var_discharge_code, var_discharge_dtm, var_destination_code, var_case_ward_code, var_case_ward_class, var_case_specialty_code, var_case_bed_no, var_movement_count, var_case_timestamp
                    FROM pmi_case
                    WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;

            IF var_rowcount = 0 THEN
                BEGIN
                    SELECT
                        200123
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF par_source_system = 'DNL' AND var_case_type = 'O' THEN
                BEGIN
                    SELECT
                        var_case_specialty_code
                        INTO par_specialty_code;
                END;
            END IF;

            IF ((par_source_system IN ('ADT') AND var_case_type NOT IN ('A', 'I')) OR (par_source_system LIKE 'OPAS%' AND var_case_type != 'O')) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200130
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_discharge_code is NULL AND (par_source_system != 'DNL' OR var_case_type != 'O') THEN
                BEGIN
                    SELECT
                        200134
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    EXIT return_error;
                END;
            END IF;
            /*
            do not check specialty and ward code if they are null
            in pmi_case
            */
            IF (var_case_ward_code != par_ward_code AND var_case_ward_code IS NOT NULL) OR
            /* --		@case_ward_class != @ward_class or */
            (var_case_specialty_code != par_specialty_code AND var_case_specialty_code IS NOT NULL) THEN
                /* --		@case_bed_no != @bed_no */
                BEGIN
                    SELECT
                        200139
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                hkid, source_system_dtm, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, patient_type, row_update_datetime
                INTO var_case_hkid, var_patient_source_system_dtm, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_doc_no, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1_no, var_phone2, var_address_indicator, var_mobile_phone_no, var_sms_language, var_patient_type, var_patient_timestamp
                FROM patient
                WHERE patient_key = var_patient_key;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        200126
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_case_hkid != par_hkid THEN
                BEGIN
                    SELECT
                        200125
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_case_type = 'O' THEN
                SELECT
                    NULL
                    INTO par_doctor_code;
            END IF;

            IF var_movement_count is not NULL THEN
                SELECT
                    var_movement_count - 1
                    INTO var_movement_count;
            END IF;
            SELECT
                localtimestamp
                INTO var_system_dtm;

            BEGIN
                UPDATE pmi_case
                SET discharge_code = NULL, discharge_dtm = NULL, destination_code = NULL, mrt_indicator = NULL, movement_count = var_movement_count, update_by = par_update_by, source_system_dtm = par_source_system_dtm
                    WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND row_update_datetime = var_case_timestamp;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
            END;
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

            IF var_rowcount = 0 THEN
                BEGIN
                    SELECT
                        200127
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_discharge_code = '1' THEN
                BEGIN
                    IF var_patient_source_system_dtm > par_source_system_dtm THEN
                        BEGIN
                            SELECT
                                200110
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;

                    BEGIN
                        UPDATE patient
                        SET death_indicator = NULL, death_date = NULL, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm
                            WHERE patient_key = var_patient_key AND row_update_datetime = var_patient_timestamp;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;
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
                            /* Patient has been updated between retrieved and update." */
                            SELECT
                                200016
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* delete death_transaction */
                    BEGIN
                        DELETE FROM death_transaction
                            WHERE discharge_dtm = discharge_dtm AND hospital_code = par_hospital_code AND case_no = par_case_no AND patient_key = var_patient_key;
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;
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
                END;
            END IF;
            SELECT
                'Y'
                INTO var_major_nok;
            SELECT
                priority, relationship, nok_name, hkid, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
                INTO var_priority, var_nok_relation_code, var_nok_name, var_nok_hkid, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone_no, var_nok_sms_language
                FROM nok
                WHERE patient_key = var_patient_key AND major_nok = var_major_nok;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_major_nok, var_priority, var_nok_relation_code, var_nok_name, var_nok_hkid, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone_no, var_nok_sms_language;
                END;
            END IF;
            SELECT
                var_system_dtm, 'P'
                INTO var_tran_system_dtm, var_upload_status;

            WHILE 1 = 1 LOOP
                BEGIN
                    INSERT INTO download.transaction_log (system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no,
                    /* --			 building, room, floor, */
                    /* --		 	 block, district, */
                    religion,
                    /* --			 phone1, */
                    /* --		 	 phone2, address_indicator, mobile_phone, */
                    /* --			 sms_language, priority, major_nok, */
                    /* --			 nok_name, nok_hkid, nok_relationship, */
                    /* --			 nok_building, nok_room, nok_floor, nok_block, */
                    /* --			 nok_district, nok_phone1, nok_phone2, */
                    /* --			 nok_address_indicator, nok_mobile_phone, */
                    /* --			 nok_sms_language, */
                    case_no, patient_type, discharge_code, destination_code, case_type, ward_code, specialty_code, bed_no, ward_class, update_by, source_system, source_system_dtm, update_hospital, upload_status, doctor_code, discharge_dtm)
                    VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, var_adm_dtm, par_hkid, var_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_doc_no,
                    /* --			 @building, @room, @floor, */
                    /* --			 @block, @district_code, */
                    var_religion_code,
                    /* --			 @phone1_no, */
                    /* --			 @phone2, @address_indicator, @mobile_phone_no, */
                    /* --			 @sms_language, @priority, @major_nok, */
                    /* --		 	 @nok_name, @nok_hkid, @nok_relation_code, */
                    /* --			 @nok_building, @nok_room, @nok_floor, @nok_block, */
                    /* --			 @nok_district_code, @nok_phone1, @nok_phone2, */
                    /* --			 @nok_address_indicator, @nok_mobile_phone_no, */
                    /* --			 @nok_sms_language, */
                    par_case_no, var_patient_type, var_discharge_code, var_destination_code, var_case_type, par_ward_code, par_specialty_code, par_bed_no, par_ward_class, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status, par_doctor_code, var_discharge_dtm);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            GET STACKED diagnostics var_error = RETURNED_SQLSTATE; 
                END;

                IF var_error = 23505 THEN
                    BEGIN
                        SELECT
                            3 * INTERVAL '1 millisecond' + var_tran_system_dtm::TIMESTAMP
                            INTO var_tran_system_dtm;
                        CONTINUE;
                    END;
                END IF;

                IF var_error != 0 THEN
                    BEGIN
                        /* Fail to insert into transaction_log. */
                        SELECT
                            var_error
                            INTO var_return_error_code;
                        EXIT return_system_error;
                    END;
                END IF;
                EXIT;
            END LOOP;

            IF var_discharge_code = '1' THEN
                BEGIN
                    CALL hkpmi_patient_death_tx(var_return_code, par_hospital_code, '033', par_hkid, 'Y');

                    IF var_return_code != 0 THEN
                        BEGIN
                            SELECT
                                200121
                                INTO var_return_error_code;
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
        pas_return_code := var_return_error_code;
        RETURN;
    END;

    IF var_begin_tran = 'Y' THEN
        BEGIN
            ROLLBACK;
        END;
    END IF;
    pas_return_code := var_return_error_code;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_cancel_discharge" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
