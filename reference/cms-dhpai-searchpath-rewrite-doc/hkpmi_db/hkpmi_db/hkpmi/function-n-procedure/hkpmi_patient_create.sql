-- DROP PROCEDURE hkpmi.hkpmi_patient_create(inout int4, in varchar, inout varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_patient_create(INOUT pas_return_code integer, IN par_hospital_code character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_doc_no character varying, IN par_mrn character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1_no character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone_no character varying, IN par_sms_language character varying, IN par_patient_type character varying, INOUT par_access_code integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone_no character varying, IN par_nok_sms_language character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_return_status SMALLINT;
    var_return_code INTEGER;
    var_major_nok VARCHAR(1);
    var_tmp_phonetic VARCHAR(48);
    var_return_error_code INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_upload_status VARCHAR(1);
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_chi_name VARCHAR(12);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_priority SMALLINT;
    var_begin_tran VARCHAR(01);
    var_death_indicator VARCHAR(04);
    var_set_nok_null VARCHAR(01);
    var_pcs_count INTEGER;
    var_patient_filler VARCHAR(30);
    var_tran_log_filler VARCHAR(30);
    var_is_schi_name VARCHAR(01);
    sql$rowcount BIGINT;
   	error_message text;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            <<normal_return>>
            BEGIN
                /* Declaration */
                /* 2006-12-11 Added by HK Fong SMR20015887 - Start */
                /* 2006-12-11 Added by HK Fong SMR20015887 - End */
				raise notice 'start';
				SELECT  'Y'
					INTO var_begin_tran;
                /* Validate key fields */
                IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('010')) OR (par_source_system = 'OPAS' AND par_txn_type IN ('010')) OR (par_source_system = 'OPAS2' AND par_txn_type IN ('010')) OR (par_source_system = 'DNL' AND par_txn_type IN ('010'))) THEN
                    BEGIN
                        /* Invalid transaction type. */
                        SELECT
                            200014
                            INTO var_return_error_code;
                        EXIT return_error;
                    END;
                END IF;

                IF EXISTS (SELECT
                    *
                    FROM patient
                    WHERE hkid = par_hkid) THEN
                    BEGIN
                        /* patient already exists */
                        CALL hkpmi_patient_update_1(var_return_code, par_hospital_code, par_patient_key, par_hkid, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_marital_status, par_race_code, par_other_doc_no, par_mrn, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1_no, par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language, par_patient_type, par_access_code, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language, '030', par_source_system_dtm, par_update_by, par_source_system, par_hkid, par_document_flag, par_hkic_symbol, 'N');
						/* Clear hkic_symbol flag */
						
                        IF var_return_code != 0 THEN
                            BEGIN
                                IF var_return_code > 200000 THEN
                                    SELECT
                                        var_return_code
                                        INTO var_return_error_code;
                                ELSE
                                    SELECT
                                        200128
                                        INTO var_return_error_code;
                                END IF;
                                EXIT return_error;
                            END;
                        END IF;
                        SELECT
                            localtimestamp
                            INTO var_system_dtm;
                        /* isert pmi registration exception log */
                        /* do not insert pmi_reg_exception if rows already exists */
                        /* 20000310 ML */
                        IF NOT EXISTS (SELECT
                            *
                            FROM pmi_reg_exception
                            WHERE hkid = par_hkid AND hospital_code = par_hospital_code AND source_system_dtm = par_source_system_dtm) THEN
                            BEGIN
                                BEGIN
                                    INSERT INTO pmi_reg_exception
                                    VALUES (par_hkid, par_hospital_code, par_source_system_dtm, par_source_system, var_system_dtm);
                                    var_error := 0;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE; 
                                           raise notice '95error_message =%',error_message ;
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
                        EXIT normal_return;
                        /*
                        comment by Leo for using demo update instead of reject
                        select @return_error_code = 200099
                        goto return_error
                        */
                    END;
                END IF;
                /*
                if ( @building != null and @building != space(01) or
                	  @room  != null and @room != space(01) or
                	  @floor != null and @floor != space(01) or
                	  @block != null and @block != space(01)
                	) and
                	( @district_code = null and @district_code = space(01))
                begin
                   /* District code cannot be blank */
                	select @return_error_code = 200015
                	goto return_error
                end
                */
                /* Get chinese name from ccc_big5 table */
                CALL cpi_get_phonetic_chin_name(var_return_code, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, var_tmp_phonetic, var_chi_name);
                /* 2006-12-11 Addeded by HK Fong SMR20015887 - Start */
                IF COALESCE(var_chi_name, '') <> '' THEN
                    BEGIN
                        CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => par_ccc_1, par_ccc2 => par_ccc_2, par_ccc3 => par_ccc_3, par_ccc4 => par_ccc_4, par_ccc5 => par_ccc_5, par_ccc6 => par_ccc_6, par_is_schi_name => var_is_schi_name);

                        IF var_is_schi_name = 'Y' THEN
                            SELECT
                                NULL
                                INTO var_chi_name;
                        END IF;
                    END;
                END IF;
                /* 2006-12-11 Addeded by HK Fong SMR20015887 - End */
                SELECT
                    2147483647, 0
                    INTO par_access_code, var_pcs_count;

                IF (par_patient_key IS NULL OR par_patient_key < '40000001' OR par_patient_key > '99999999') AND (par_source_system != 'DNL') THEN
                    BEGIN
                        /* get new patient key, insert a new patient */
                        CALL hkpmi_get_patient_key(pas_return_code, par_patient_key);

                        IF (pas_return_code != 0) THEN
                            BEGIN
                                /* Fail to get a new patient key */
                                SELECT
                                    200082
                                    INTO var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        /* check paitent key exist or not */
                        IF EXISTS (SELECT
                            *
                            FROM patient
                            WHERE patient_key = par_patient_key) THEN
                            BEGIN
                                SELECT
                                    200100
                                    INTO var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
                SELECT
                    localtimestamp
                    INTO var_system_dtm;
                /* --- 20100928 hkic -- */
                SELECT
                    CONCAT(COALESCE(par_document_flag, REPEAT(' ', 1)), REPEAT(' ', 1), COALESCE(par_hkic_symbol, REPEAT(' ', 1)))
                    INTO var_patient_filler;
                SELECT
                    CONCAT(SUBSTRING(CONCAT(par_document_flag, REPEAT(' ', 1)), 1, 1), REPEAT(' ', 28), SUBSTRING(CONCAT(par_hkic_symbol, REPEAT(' ', 1)), 1, 1))
                    INTO var_tran_log_filler; /* ---/* hkic_symbol = transaction_log.filler(30,1)*/ */

                IF (LTRIM(RTRIM(var_patient_filler)) = '') OR (LTRIM(RTRIM(var_patient_filler)) is NULL) THEN
                    SELECT
                        NULL
                        INTO var_patient_filler;
                END IF;

                IF (LTRIM(RTRIM(var_tran_log_filler)) = '') OR (LTRIM(RTRIM(var_tran_log_filler)) is NULL) THEN
                    SELECT
                        NULL
                        INTO var_tran_log_filler;
                END IF;
                /* insert a new patient record */
                BEGIN
                    INSERT INTO patient (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, patient_type, pcs_count, access_code, update_hospital, source_system, update_by, source_system_dtm, system_dtm, filler)
                    VALUES (par_patient_key, par_hkid, par_patient_name, par_sex, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, var_chi_name, par_dob, par_exact_dob_flag, par_marital_status, par_race_code, par_other_doc_no, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1_no, par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language, par_patient_type, var_pcs_count, par_access_code, par_hospital_code, par_source_system, par_update_by, par_source_system_dtm, var_system_dtm, var_patient_filler /* @document_flag */);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE; 
                           raise notice '211error_message =%',error_message ;
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
                /* create nok record */
                SELECT
                    1, 'Y'
                    INTO var_priority, var_major_nok;

                IF par_nok_name IS NOT NULL THEN
                    BEGIN
                        BEGIN
                            INSERT INTO nok (patient_key, priority, major_nok, hkid, relationship, nok_name, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language, update_hospital, update_by, source_system_dtm)
                            VALUES (par_patient_key, var_priority, var_major_nok, par_nok_hkid, par_nok_relation_code, par_nok_name, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language, par_hospital_code, par_update_by, par_source_system_dtm);
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE; 
                                   raise notice '238error_message =%',error_message ;
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
                ELSE
                    BEGIN
                        SELECT
                            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                            INTO var_priority, var_major_nok, par_nok_relation_code, par_nok_name, par_nok_hkid, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language;
                    END;
                END IF;

                IF par_mrn IS NOT NULL THEN
                    BEGIN
                        IF EXISTS (SELECT
                            *
                            FROM patient_hospital_data
                            WHERE hospital_code = par_hospital_code AND mrn = par_mrn AND patient_key != par_patient_key) THEN
                            BEGIN
                                /* MRN is used by other patient. */
                                SELECT
                                    200018
                                    INTO var_return_error_code;
                                EXIT return_error;
                            END;
                        END IF;

                        BEGIN
                            INSERT INTO patient_hospital_data (patient_key, hospital_code, mrn, update_by, source_system_dtm)
                            VALUES (par_patient_key, par_hospital_code, par_mrn, par_update_by, par_source_system_dtm);
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE; 
                                   raise notice '282error_message =%',error_message ;
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
                /* Goya 19981023, set this hospital on for this patient */
                CALL hkpmi_set_on_patient_hosp(var_return_code, par_hkid, par_hospital_code, par_update_by, par_source_system);
				raise notice 'hkpmi_set_on_patient_hosp=%',var_return_code;

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
                SELECT
                    var_system_dtm, 'Y'
                    INTO var_tran_system_dtm, var_upload_status;

                WHILE 1 = 1 LOOP
                    BEGIN
                        INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, pcs_count, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, patient_type, pmi_access_code, old_hkid, update_by, source_system, source_system_dtm, update_hospital, upload_status, filler)
                        VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, var_chi_name, par_marital_status, par_race_code, par_other_doc_no, par_mrn, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1_no, par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language, var_pcs_count, var_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language, par_patient_type, par_access_code, par_hkid, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status, var_tran_log_filler /* @document_flag */);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE; 
                               raise notice '321error_message =%',error_message ;
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
            END;
			
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

ALTER PROCEDURE "hkpmi_patient_create" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";