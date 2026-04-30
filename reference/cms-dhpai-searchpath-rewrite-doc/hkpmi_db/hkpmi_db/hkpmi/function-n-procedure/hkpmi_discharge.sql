-- DROP PROCEDURE hkpmi.hkpmi_discharge(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_discharge_code character varying, IN par_discharge_dtm timestamp without time zone, IN par_destination_code character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_doctor_code character varying, IN par_mrt_indicator character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_body_category character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* YL 200708 Add body_category */DECLARE
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
    var_case_discharge_code VARCHAR(01);
    var_case_hkid VARCHAR(12);
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
    var_case_ward_class VARCHAR(01);
    var_death_ind VARCHAR(04);
    var_death_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_dr_deth_date TIMESTAMP WITHOUT TIME ZONE;
    var_dr_dsch_date TIMESTAMP WITHOUT TIME ZONE;
    var_filler VARCHAR(30);
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
            IF NOT ((par_source_system IN ('ADT', 'DNL') AND (par_txn_type LIKE '13%' OR par_txn_type LIKE '33%')) OR
            /* (@source_system like 'OPAS%' and @txn_type = '13A')) */
            
            /* --			(@source_system like 'OPAS%' and @txn_type = '13%')) */
            (par_source_system LIKE 'OPAS%' AND par_txn_type LIKE '13%')) THEN
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
                    patient_key, adm_dtm, case_type, discharge_code, last_ward_class, movement_count, row_update_datetime
                    INTO var_patient_key, var_adm_dtm, var_case_type, var_case_discharge_code, var_case_ward_class, var_movement_count, var_case_timestamp
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

            IF var_case_type IN ('I', 'A') THEN
                BEGIN
                    IF par_ward_code is NULL THEN
                        BEGIN
                            SELECT
                                200135
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* do not reject, if ward class is also null in pmi_case */
            IF var_case_type IN ('I') THEN
                BEGIN
                    IF par_ward_class is NULL AND var_case_ward_class IS NOT NULL THEN
                        BEGIN
                            SELECT
                                200137
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;

            IF par_specialty_code is NULL AND par_source_system != 'DNL' THEN
                BEGIN
                    SELECT
                        200136
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                hkid, source_system_dtm, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, patient_type, row_update_datetime, death_indicator, death_date, filler
                INTO var_case_hkid, var_patient_source_system_dtm, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_doc_no, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1_no, var_phone2, var_address_indicator, var_mobile_phone_no, var_sms_language, var_patient_type, var_patient_timestamp, var_death_ind, var_death_dtm, var_filler
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
            /* Check whether Case has been discharged or not */
            IF var_case_discharge_code is not NULL THEN
                BEGIN
                    SELECT
                        200132
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    EXIT return_error;
                END;
            END IF;
            /* Check discharge dtm against death dtm by WL on 19981202 */
            /* --	if (@death_ind != null) and */
            /* --		(@discharge_dtm > @death_dtm) and */
            /* --		(@case_type in ("I", "A")) */
            /* --	begin */
            /* --		select	@return_error_code = 200173 */
            /* --		goto return_error */
            /* --	end */
            /*
            Add special handling for DR death patient because DR only
            provide death date without time by L. S. Chu on 19990802
            */
            IF var_death_ind IS NOT NULL AND var_case_type IN ('I', 'A') THEN
                BEGIN
                    IF par_discharge_code = '1' AND var_death_ind <> 'ADT' THEN
                        SELECT
                            to_char(var_death_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), to_char(par_discharge_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                            INTO var_dr_deth_date, var_dr_dsch_date;
                    ELSE
                        SELECT
                            var_death_dtm, par_discharge_dtm
                            INTO var_dr_deth_date, var_dr_dsch_date;
                    END IF;

                    IF var_dr_dsch_date > var_dr_deth_date THEN
                        BEGIN
                            SELECT
                                200173
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* 20181009 - OPAS-46 Add OPAS discharge codes (K, L) for the validation on close case by Freda */
            IF (par_discharge_code NOT IN ('B', 'C', 'D', 'E', 'F', 'R', 'G', 'H', 'I', 'J', 'K', 'L')) THEN
                BEGIN
                    SELECT
                        short_description
                        INTO var_disc_description
                        FROM discharge_type
                        WHERE discharge_code = par_discharge_code;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        BEGIN
                            SELECT
                                200031
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;

            IF par_discharge_code IN ('0', '4', '9') THEN
                BEGIN
                    IF NOT EXISTS (SELECT
                        *
                        FROM destination
                        WHERE destination_code = par_destination_code) THEN
                        BEGIN
                            SELECT
                                200028
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            ELSE
                SELECT
                    var_disc_description
                    INTO par_destination_code;
            END IF;

            IF var_case_type = 'O' THEN
                SELECT
                    NULL, NULL, NULL, NULL
                    INTO par_mrt_indicator, par_bed_no, par_ward_class, par_doctor_code;
            END IF;

            IF var_movement_count is not NULL THEN
                SELECT
                    var_movement_count + 1
                    INTO var_movement_count;
            END IF;
            SELECT
                localtimestamp
                INTO var_system_dtm;

            BEGIN
                UPDATE pmi_case
                SET last_ward_code = par_ward_code, last_specialty_code = par_specialty_code, last_ward_class = par_ward_class, last_bed_no = par_bed_no, discharge_code = par_discharge_code, discharge_dtm = par_discharge_dtm, destination_code = par_destination_code, mrt_indicator = par_mrt_indicator, movement_count = var_movement_count, update_by = par_update_by, source_system = par_source_system, source_system_dtm = par_source_system_dtm
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

            IF par_discharge_code = '1' THEN
                BEGIN
                    IF var_patient_source_system_dtm > par_source_system_dtm THEN
                        BEGIN
                            SELECT
                                200110
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;

                    IF par_body_category IS NOT NULL THEN
                        SELECT
                            CONCAT(COALESCE(SUBSTRING(var_filler, 1, 1), REPEAT(' ', 1)), par_body_category, + SUBSTRING(var_filler, 3, 28))
                            INTO var_filler;
                    ELSE
                        IF var_filler IS NOT NULL THEN
                            SELECT
                                CONCAT(SUBSTRING(var_filler, 1, 1), REPEAT(' ', 1), SUBSTRING(var_filler, 3, 28))
                                INTO var_filler;
                        END IF;
                    END IF;

                    BEGIN
                        UPDATE patient
                        SET death_indicator = par_source_system, death_date = par_discharge_dtm, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm, filler = var_filler
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
                    /* insert death_transaction */
                    BEGIN
                        INSERT INTO death_transaction (hospital_code, discharge_dtm, patient_key, case_no)
                        VALUES (par_hospital_code, par_discharge_dtm, var_patient_key, par_case_no);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
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
                    case_no, patient_type, discharge_code, destination_code, case_type, ward_code, specialty_code, bed_no, ward_class, update_by, source_system, source_system_dtm, update_hospital, upload_status, doctor_code, mrt_indicator, discharge_dtm)
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
                    par_case_no, var_patient_type, par_discharge_code, par_destination_code, var_case_type, par_ward_code, par_specialty_code, par_bed_no, par_ward_class, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status, par_doctor_code, par_mrt_indicator, par_discharge_dtm);
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
            /*
            if @discharge_code = '1'
            	begin
                  exec @return_code = hkpmi_patient_death_tx
                        @hospital_code, "033", @hkid, "Y"
            
                  if @return_code != 0
                  begin
                     select   @return_error_code = 200121
                     goto return_error
                  end
            	end
            */

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


ALTER PROCEDURE "hkpmi_discharge" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";