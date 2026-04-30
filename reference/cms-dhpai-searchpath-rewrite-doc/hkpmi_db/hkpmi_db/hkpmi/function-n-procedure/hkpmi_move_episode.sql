-- DROP PROCEDURE hkpmi.hkpmi_move_episode(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_move_episode(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_from_hkid character varying, IN par_to_hkid character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_txn_type character varying, IN par_move_episode_status character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_error_code INTEGER;
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
    var_death_indicator VARCHAR(4);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_pcs_count INTEGER;
    var_patient_type VARCHAR(03);
    var_access_code INTEGER;
    var_discharge_code VARCHAR(01);
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_old_patient_name VARCHAR(48);
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
    var_case_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_from_patient_key VARCHAR(08);
    var_from_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_from_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_to_patient_key VARCHAR(08);
    var_to_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_to_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_case_type VARCHAR(01);
    var_mrn VARCHAR(08);
    var_upload_status VARCHAR(01);
    var_case_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_return_code INTEGER;
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_body_category VARCHAR(1);
    var_from_filler VARCHAR(30);
    var_to_filler VARCHAR(30);
    var_chk_exception_code INTEGER;
    var_exception_flag VARCHAR(1);
    sql$rowcount BIGINT;

begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN /* ---20120619 */
            select  'Y' into var_begin_tran;
            /* Validate key fields */
            IF NOT (par_source_system IN ('ADT', 'DNL', 'OPAS', 'OPAS2') AND par_txn_type IN ('040')) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* Check the existence of case */
            SELECT
                patient_key, adm_dtm, discharge_code, discharge_dtm, case_type, source_system_dtm, row_update_datetime, patient_type
                INTO var_case_patient_key, var_adm_dtm, var_discharge_code, var_discharge_datetime, var_case_type, var_case_source_system_dtm, var_case_timestamp, var_patient_type
                FROM pmi_case
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        200123
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF (par_source_system = 'ADT' AND NOT var_case_type IN ('A', 'I')) OR (par_source_system IN ('OPAS', 'OPAS2') AND var_case_type != 'O') THEN
                BEGIN
                    SELECT
                        200130
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_case_source_system_dtm > par_source_system_dtm THEN
                BEGIN
                    SELECT
                        200110
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* Check matching of patient key */
            SELECT
                patient_key, source_system_dtm, row_update_datetime, filler, SUBSTRING(filler, 2, 1)
                INTO var_from_patient_key, var_from_source_system_dtm, var_from_timestamp, var_from_filler, var_body_category
                FROM patient
                WHERE hkid = par_from_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        200112
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
			raise notice 'var_from_patient_key=%,var_case_patient_key=%',var_from_patient_key,var_case_patient_key;
            IF (var_from_patient_key != var_case_patient_key) THEN
                BEGIN
                    SELECT
                        200125
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* Check the existence of new patient moved to */
            SELECT
                source_system_dtm, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, pcs_count, access_code,
                /* --		@patient_type = patient_type, */
                row_update_datetime, filler
                INTO var_to_source_system_dtm, var_to_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_doc_no, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1_no, var_phone2, var_address_indicator, var_mobile_phone_no, var_sms_language, var_death_indicator, var_death_date, var_pcs_count, var_access_code, var_to_timestamp, var_to_filler
                FROM patient
                WHERE hkid = par_to_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        200113
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* ---if (@dob is not null) */
            IF (var_dob IS NOT NULL AND var_dob > var_adm_dtm) THEN
                BEGIN
                    /* -------------20120619----------------- */
                    /* handle for dob > adm_dtm to write exception */
                    CALL hkpmi_chk_exception_case(pas_return_code, par_hospital_code, par_case_no, var_exception_flag);

                    IF var_chk_exception_code <> 0 OR var_exception_flag = 'N' THEN
                        BEGIN
                            SELECT
                                200177
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* ------------------------------ */
                END;
            END IF;
            /* reject move a dealth case to death patient */
            IF var_death_indicator IS NOT NULL AND var_discharge_code = '1' THEN
                BEGIN
                    SELECT
                        200165
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                localtimestamp
                INTO var_system_dtm;

            IF var_discharge_code = '1' THEN
                BEGIN
                    IF var_from_source_system_dtm > par_source_system_dtm OR var_to_source_system_dtm > par_source_system_dtm THEN
                        BEGIN
                            SELECT
                                200110
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* Reset the body_category filler(2,1) */
                    IF var_from_filler IS NOT NULL AND var_body_category IS NOT NULL AND var_body_category <> REPEAT(' ', 1) THEN
                        SELECT
                            CONCAT(SUBSTRING(var_from_filler, 1, 1), REPEAT(' ', 1), + SUBSTRING(var_from_filler, 3, 28))
                            INTO var_from_filler;
                    END IF;

                    BEGIN
                        UPDATE patient
                        SET death_indicator = NULL, death_date = NULL, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm, filler = var_from_filler
                            WHERE patient_key = var_from_patient_key AND row_update_datetime = var_from_timestamp;
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
                    /* Move body_category to target patient */
                    IF var_body_category IS NOT NULL THEN
                        SELECT
                            CONCAT(COALESCE(SUBSTRING(var_to_filler, 1, 1), REPEAT(' ', 1)), var_body_category, SUBSTRING(var_to_filler, 3, 28))
                            INTO var_to_filler;
                    END IF;

                    BEGIN
                        UPDATE patient
                        SET death_indicator = par_source_system, death_date = var_discharge_datetime, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm, filler = var_to_filler
                            WHERE patient_key = var_to_patient_key AND row_update_datetime = var_to_timestamp;
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
                END;
            END IF;

            BEGIN
                UPDATE pmi_case
                SET patient_key = var_to_patient_key, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm
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

            IF var_rowcount != 1 THEN
                BEGIN
                    /* Case has been updated between retrieved and update." */
                    SELECT
                        200127
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            SELECT
                mrn
                INTO var_mrn
                FROM patient_hospital_data
                WHERE patient_key = var_to_patient_key AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                SELECT
                    NULL
                    INTO var_mrn;
            END IF;
            SELECT
                'Y'
                INTO var_major_nok;
            SELECT
                priority, relationship, nok_name, hkid, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
                INTO var_priority, var_nok_relation_code, var_nok_name, var_nok_hkid, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone_no, var_nok_sms_language
                FROM nok
                WHERE patient_key = var_to_patient_key AND major_nok = var_major_nok;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_major_nok, var_priority, var_nok_relation_code, var_nok_name, var_nok_hkid, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone_no, var_nok_sms_language;
                END;
            END IF;
            SELECT
                var_system_dtm, 'N'
                INTO var_tran_system_dtm, var_upload_status;
            /*
            By Goya 19981106, set this patient in this hospital on in
            patient_detail_1 if this patient doesn't have any more cases in
            this hospital. And set to_patient off in patient_detail_1 if it is on
            (hkpmi_set_on_patient_hosp will check exsitence of case before
            process)
            */
            CALL hkpmi_check_patient_detail_1(var_return_code, par_to_hkid, par_hospital_code);

            IF var_return_code = 0 THEN
                BEGIN
                    CALL hkpmi_set_off_patient_hosp(var_return_code, par_to_hkid, par_hospital_code, par_update_by, par_source_system);


                    IF var_return_code != 0 THEN
                        BEGIN
                            IF var_return_code > 200000 THEN
                                SELECT
                                    var_return_code
                                    INTO var_return_error_code;
                            ELSE
                                SELECT
                                    200159
                                    INTO var_return_error_code;
                            END IF;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;

            IF NOT EXISTS (SELECT
                *
                FROM pmi_case
                WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code) THEN
                BEGIN
                    CALL hkpmi_set_on_patient_hosp(var_return_code, par_from_hkid, par_hospital_code, par_update_by, par_source_system);


                    IF var_return_code != 0 THEN
                        BEGIN
                            IF var_return_code > 200000 THEN
                                SELECT
                                    var_return_code
                                    INTO var_return_error_code;
                            ELSE
                                SELECT
                                    200158
                                    INTO var_return_error_code;
                            END IF;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;

            WHILE 1 = 1 LOOP
                BEGIN
                    INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, patient_type, old_patient_key, old_hkid, update_by, source_system, source_system_dtm, update_hospital, upload_status)
                    VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, par_to_hkid, var_to_patient_key, var_patient_name, var_sex, var_dob, var_exact_dob_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_status, var_race_code, var_other_doc_no, var_mrn, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_phone1_no, var_phone2, var_address_indicator, var_mobile_phone_no, var_sms_language, var_priority, var_major_nok, var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_phone2, var_nok_address_indicator, var_nok_mobile_phone_no, var_nok_sms_language, par_case_no, var_patient_type, var_from_patient_key, par_from_hkid, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status);
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
                    CALL hkpmi_patient_death_tx(var_return_code, par_hospital_code, '033', par_from_hkid, 'Y');

                    IF var_return_code != 0 THEN
                        BEGIN
                            SELECT
                                200121
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    CALL hkpmi_patient_death_tx(var_return_code, par_hospital_code, '033', par_to_hkid, 'Y');

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
            /* 20050720 LSCHU - update for mother_baby_case table */
            CALL hkpmi_check_mother_baby_case(var_return_code, par_hospital_code, var_from_patient_key, par_source_system_dtm, par_update_by, par_source_system);

            IF var_return_code != 0 THEN
                BEGIN
                    IF var_return_code > 200000 THEN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                    ELSE
                        SELECT
                            200158
                            INTO var_return_error_code;
                    END IF;
                    EXIT return_error;
                END;
            END IF;
            CALL hkpmi_check_mother_baby_case(var_return_code, par_hospital_code, var_to_patient_key, par_source_system_dtm, par_update_by, par_source_system);

            IF var_return_code != 0 THEN
                BEGIN
                    IF var_return_code > 200000 THEN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                    ELSE
                        SELECT
                            200158
                            INTO var_return_error_code;
                    END IF;
                    EXIT return_error;
                END;
            END IF;
            /* 20050920 YL - update for inserting record to move_episode_indicator table */
            /* 20140404 YL - update for inserting record only before move episode reason implementation date/time */
            IF NOT EXISTS (SELECT
                1
                FROM move_episode_indicator
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no AND create_dtm = par_source_system_dtm) THEN
                BEGIN
                    IF par_move_episode_status is NULL OR (par_move_episode_status <> 'O' AND par_move_episode_status <> 'S') THEN
                        BEGIN
                            SELECT
                                'O'
                                INTO par_move_episode_status;
                        END;
                    END IF;

                    BEGIN
                        INSERT INTO move_episode_indicator (hospital_code, case_no, create_dtm, from_patient_key, to_patient_key, create_user, create_system, move_status, update_dtm, update_user, update_system)
                        VALUES (par_hospital_code, par_case_no, var_tran_system_dtm, var_from_patient_key, var_to_patient_key, par_update_by, par_source_system, par_move_episode_status, par_source_system_dtm, par_update_by, par_source_system);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                    END;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;

                    IF var_rowcount <> 1 OR var_error != 0 THEN
                        BEGIN
                            SELECT
                                var_error
                                INTO var_return_error_code;
                            EXIT return_system_error;
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


ALTER PROCEDURE "hkpmi_move_episode" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
