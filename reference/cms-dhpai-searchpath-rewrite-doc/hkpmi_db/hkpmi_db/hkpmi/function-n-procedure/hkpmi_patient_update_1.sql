-- DROP PROCEDURE hkpmi.hkpmi_patient_update_1(inout int4, in varchar, inout varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_patient_update_1(INOUT pas_return_code integer, IN par_hospital_code character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_doc_no character varying, IN par_mrn character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1_no character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone_no character varying, IN par_sms_language character varying, IN par_patient_type character varying, INOUT par_access_code integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone_no character varying, IN par_nok_sms_language character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_new_hkid character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, IN par_hkic_symbol_clear character varying DEFAULT 'N'::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_new_patient_key VARCHAR(8);
    var_return_status SMALLINT;
    var_major_nok VARCHAR(1);
    var_tmp_mrn VARCHAR(8);
    var_exit_flag VARCHAR(1);
    var_tmp_phonetic varchar;
    var_old_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_upload_status VARCHAR(1);
    var_old_patient_name VARCHAR(48);
    var_old_sex VARCHAR(01);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_old_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_chi_name varchar;
    var_old_patient_type VARCHAR(03);
    var_tmp_hospital_code VARCHAR(03);
    var_process_local_hospital VARCHAR(01);
    var_tran_hospital_code VARCHAR(03);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tran_mrn VARCHAR(12);
    var_priority SMALLINT;
    var_begin_tran VARCHAR(01);
    var_death_indicator VARCHAR(04);
    var_set_nok_null VARCHAR(01);
    var_old_doc_flag VARCHAR(1);
    var_return_code INTEGER;
    var_old_c1 VARCHAR(5);
    var_old_c2 VARCHAR(5);
    var_old_c3 VARCHAR(5);
    var_old_c4 VARCHAR(5);
    var_old_c5 VARCHAR(5);
    var_old_c6 VARCHAR(5);
    var_min_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_body_category VARCHAR(1);
    var_filler VARCHAR(30);
    var_old_hkic_symbol VARCHAR(1);
    var_tran_log_filler VARCHAR(30);
    var_is_schi_name VARCHAR(01);
    var_min_hospital_code VARCHAR(03);
    var_case_no VARCHAR(12);
    var_exception_flag VARCHAR(1);
    sql$rowcount BIGINT;
	error_sqlstate BIGINT;
	error_message varchar;
	my_conn varchar;
	my_sql varchar;
	found_code INTEGER;
    var_start_time timestamp(6);
    hosp_cursor CURSOR FOR
    SELECT
        h.hospital_code
        FROM hospital AS h, patient_detail_1 AS p
        WHERE p.patient_key = par_patient_key AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0) AND h.hospital_code != par_hospital_code
    UNION
    SELECT DISTINCT
        hospital_code
        FROM pmi_case
        WHERE patient_key = par_patient_key AND hospital_code != par_hospital_code;
BEGIN
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
            /* 2006-12-11 Added by HK Fong SMR20015887 - Start */
            /* 2006-12-11 Added by HK Fong SMR20015887 - End */

            /* Validate key fields */

			select 'Y' into var_begin_tran;
            IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('031', '030')) OR (par_source_system = 'PBRC' AND par_txn_type IN ('031', '030')) OR (par_source_system = 'OPAS' AND par_txn_type IN ('031', '030')) OR (par_source_system = 'OPAS2' AND par_txn_type IN ('030', '031')) OR (par_source_system = 'DNL' AND par_txn_type IN ('030'))) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            
            SELECT
                patient_key, death_indicator, access_code, source_system_dtm, patient_name, sex, dob, patient_type, row_update_datetime, SUBSTRING(filler, 1, 1), cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, SUBSTRING(filler, 2, 1), filler, SUBSTRING(filler, 3, 1)
                INTO par_patient_key, var_death_indicator, par_access_code, var_old_source_system_dtm, var_old_patient_name, var_old_sex, var_old_dob, var_old_patient_type, var_old_timestamp, var_old_doc_flag, var_old_c1, var_old_c2, var_old_c3, var_old_c4, var_old_c5, var_old_c6, var_body_category, var_filler, var_old_hkic_symbol
                FROM patient
                WHERE hkid = par_hkid;

            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
			
            IF sql$rowcount = 0 THEN
                BEGIN
                    /* Patient not found. */
                    SELECT
                        200012
                        INTO var_return_error_code;
                      
                    EXIT return_error;
                END;
            END IF;
			
            IF par_document_flag IS NULL OR par_document_flag = 'Z' THEN
                SELECT
                    var_old_doc_flag
                    INTO par_document_flag;
            END IF;

            IF par_hkic_symbol IS NULL OR LTRIM(RTRIM(par_hkic_symbol)) = '' THEN /* if pass-in hkic is null or N/A */
                SELECT
                    var_old_hkic_symbol
                    INTO par_hkic_symbol;
            END IF;
            /*
            20060804
            if (@death_indicator is not null) and
            	(@source_system = 'OPAS' or @source_system = 'OPAS2')
            begin
            	select @return_error_code = 200090
            	goto return_error
            end
            */
            /*
            20060804 - release checking for OPAS upload 030 for dead patient
            with checking of major keys by LSCHU
            */
            IF (var_death_indicator IS NOT NULL) AND (par_source_system = 'OPAS' OR par_source_system = 'OPAS2') AND (COALESCE(var_old_c1, 'null') <> COALESCE(par_ccc_1, 'null') OR COALESCE(var_old_c2, 'null') <> COALESCE(par_ccc_2, 'null') OR COALESCE(var_old_c3, 'null') <> COALESCE(par_ccc_3, 'null') OR COALESCE(var_old_c4, 'null') <> COALESCE(par_ccc_4, 'null') OR COALESCE(var_old_c5, 'null') <> COALESCE(par_ccc_5, 'null') OR COALESCE(var_old_c6, 'null') <> COALESCE(par_ccc_6, 'null') OR par_patient_name <> var_old_patient_name OR par_sex <> var_old_sex OR par_dob <> var_old_dob) THEN
                BEGIN
                    SELECT
                        200090
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            /*
            20061109 - reject update of DOB when DOB is later than anyone registration
            date/time of the patient by Philip
            */
            IF (par_dob IS NOT NULL AND par_txn_type = '030') THEN
                BEGIN
                    /* select @min_adm_dtm=min(adm_dtm) from pmi_case where patient_key=@patient_key */
                    /* handle for old OPAS case */
                    SELECT
                        MIN(adm_dtm)
                        INTO var_min_adm_dtm
                        FROM pmi_case
                        WHERE patient_key = par_patient_key AND NOT (case_type = 'O' AND adm_dtm < '19950101');

                    IF (var_min_adm_dtm IS NOT NULL) AND (par_dob > var_min_adm_dtm) THEN
                        BEGIN
                            /* 20110513 EC */
                            SELECT
                                hospital_code, case_no
                                INTO var_min_hospital_code, var_case_no
                                FROM pmi_case
                                WHERE patient_key = par_patient_key AND NOT (case_type = 'O' AND adm_dtm < '19950101') AND adm_dtm = var_min_adm_dtm;
                            /* handle for dob > adm_dtm to write exception */
                            CALL hkpmi_chk_exception_case(pas_return_code, var_min_hospital_code, var_case_no, var_exception_flag);
                            IF var_return_code <> 0 OR var_exception_flag = 'N' THEN
                                BEGIN
                                    SELECT
                                        200177
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
				
            IF par_txn_type = '031' AND (par_new_hkid is NULL OR par_new_hkid = par_hkid) THEN
                BEGIN
                    SELECT
                        200080
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
			
            IF par_txn_type = '031' AND (par_patient_name != var_old_patient_name OR par_sex != var_old_sex OR par_dob != var_old_dob) THEN
                BEGIN
                    SELECT
                        200081
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
			
            IF par_new_hkid is NULL THEN
                BEGIN
                    SELECT
                        par_hkid
                        INTO par_new_hkid;
                END;
            END IF;

            IF var_old_source_system_dtm > par_source_system_dtm THEN
                BEGIN
                    /* Patient's last_update_dtm is later than upload's update_dtm. */
                    SELECT
                        200013
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* check nok home number */
            IF par_nok_phone1 IS NOT NULL AND par_source_system <> 'DNL' AND par_source_system <> 'ADT' AND par_source_system <> 'PBRC' AND par_source_system <> 'OPAS' AND par_txn_type <> '031' AND /* added by WL on 3 Mar 99 */ par_nok_phone1 NOT SIMILAR TO '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 ][0-9 ][0-9 ]' THEN
                BEGIN
                    /* invalid phone number */
                    SELECT
                        200147
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
			
            IF (par_building is not NULL AND par_building != REPEAT(' ', 01) OR par_room is not NULL AND par_room != REPEAT(' ', 01) OR par_floor is not NULL AND par_floor != REPEAT(' ', 01) OR par_block is not NULL AND par_block != REPEAT(' ', 01)) AND (par_district_code is NULL) THEN
                BEGIN
                    /* District code cannot be blank */
                    SELECT
                        200015
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
   
            /* Get chinese name from ccc_unicode table */
            CALL cpi_get_phonetic_chin_name(var_return_code, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, var_tmp_phonetic, var_chi_name);
            /* 2006-12-11 Addeded by HK Fong SMR20015887 - Start */
            IF COALESCE(var_chi_name, '') <> '' THEN
                begin 
	               CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => par_ccc_1, par_ccc2 => par_ccc_2, par_ccc3 => par_ccc_3, par_ccc4 => par_ccc_4, par_ccc5 => par_ccc_5, par_ccc6 => par_ccc_6, par_is_schi_name => var_is_schi_name);
                    IF var_is_schi_name = 'Y' THEN
                        SELECT
                            NULL
                            INTO var_chi_name;
                    END IF;
                END;
            END IF;
            /* 2006-12-11 Addeded by HK Fong SMR20015887 - End */
            IF par_patient_type is NULL THEN
                BEGIN
                    SELECT
                        var_old_patient_type
                        INTO par_patient_type;
                END;
            END IF;

            IF par_source_system = 'PBRC' THEN
                BEGIN
                    SELECT
                        race, phone2, address_indicator, mobile_phone, sms_language, religion
                        INTO par_race_code, par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language, par_religion_code
                        FROM patient
                        WHERE hkid = par_hkid;
                END;
            END IF;

            IF par_source_system = 'DNL' THEN
                BEGIN
                    SELECT
                        phone2, address_indicator, mobile_phone, sms_language
                        INTO par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language
                        FROM patient
                        WHERE hkid = par_hkid;
                END;
            END IF;

            IF par_source_system = 'OPAS2' AND (par_building is NULL OR par_building = REPEAT(' ', 01)) AND (par_room is NULL OR par_room = REPEAT(' ', 01)) AND (par_floor is NULL OR par_floor = REPEAT(' ', 01)) AND (par_block is NULL OR par_block = REPEAT(' ', 01)) AND (par_district_code is NULL) THEN
                BEGIN
                    SELECT
                        building, room, floor, block, district
                        INTO par_building, par_room, par_floor, par_block, par_district_code
                        FROM patient
                        WHERE hkid = par_hkid;

                    IF NOT EXISTS (SELECT
                        *
                        FROM district
                        WHERE district_code = par_district_code) THEN
                        BEGIN
                            SELECT
                                'UNK'
                                INTO par_district_code;
                        END;
                    END IF;
                END;
            END IF;

            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_dtm;
            /* YL: Preserve body category in filler */
            /* --select @filler = isnull(@document_flag, space(1)) + isnull(@body_category, space(1)) + substring(@filler,3,28) */
            IF par_hkic_symbol_clear = 'Y' THEN /* Reset HKIC symbol */
                SELECT
                    NULL
                    INTO par_hkic_symbol;
            END IF;
            /* ---20120908 --clear HKIC symbol for HKID changed to UnHKID--- */
            IF par_txn_type = '031' AND SUBSTRING(par_new_hkid, 1, 1) = 'U' THEN
                BEGIN
                    SELECT
                        NULL
                        INTO par_hkic_symbol;
                END;
            END IF;
            /* ------------------------------------------------------ */
            /* --20100928 SL */
            SELECT
                CONCAT(COALESCE(par_document_flag, REPEAT(' ', 1)), COALESCE(var_body_category, REPEAT(' ', 1)), COALESCE(par_hkic_symbol, REPEAT(' ', 1)), SUBSTRING(var_filler, 4, 27))
                INTO var_filler;
            SELECT
                CONCAT(SUBSTRING(CONCAT(par_document_flag, REPEAT(' ', 1)), 1, 1), REPEAT(' ', 28), SUBSTRING(CONCAT(par_hkic_symbol, REPEAT(' ', 1)), 1, 1))
                INTO var_tran_log_filler; /* ---/* hkic_symbol = transaction_log.filler(30,1)*/ */
            /* update a patient record */
            begin
	            UPDATE patient
                SET hkid = par_new_hkid, patient_name = par_patient_name, sex = par_sex, cccode1 = par_ccc_1, cccode2 = par_ccc_2, cccode3 = par_ccc_3, cccode4 = par_ccc_4, cccode5 = par_ccc_5, cccode6 = par_ccc_6, chi_name = var_chi_name, dob = par_dob, exact_dob_flag = par_exact_dob_flag, marital_status = par_marital_status, race = par_race_code, other_doc_no = par_other_doc_no, building = par_building, room = par_room, floor = par_floor, block = par_block, district = par_district_code, religion = par_religion_code, phone1 = par_phone1_no, phone2 = par_phone2, address_indicator = par_address_indicator, mobile_phone = par_mobile_phone_no, sms_language = par_sms_language, patient_type = par_patient_type, update_hospital = par_hospital_code, update_by = par_update_by, source_system_dtm = timestamp_convert(par_source_system_dtm), source_system = par_source_system, system_dtm = timestamp_convert(var_system_dtm), filler = var_filler
                    WHERE patient_key = par_patient_key AND row_update_datetime = var_old_timestamp;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS then
                    	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                                
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
                    /* Patient not found or Patient has been updated between retrieved and update." */
                    SELECT
                        200016
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
 
            /* update nok record */
            SELECT
                1, 'Y'
                INTO var_priority, var_major_nok;
            /* PBRC does not have nok other phone */
            /* 2023-11-13 OPAS-871 ODC AikenYu Remove parameter judgment for 'OPAS' and 'DNL' Start */
            IF par_source_system IN ('PBRC') THEN
                /* 2023-11-13 OPAS-871 ODC AikenYu Remove parameter judgment for 'OPAS' and 'DNL' End */
                BEGIN
                    SELECT
                        mobile_phone, sms_language
                        INTO par_nok_mobile_phone_no, par_nok_sms_language
                        FROM nok
                        WHERE patient_key = par_patient_key AND priority = var_priority;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        BEGIN
                            SELECT
                                NULL, NULL
                                INTO par_nok_mobile_phone_no, par_nok_sms_language;
                        END;
                    END IF;
                END;
            END IF;

            IF par_source_system = 'OPAS2' THEN
                BEGIN
                    SELECT
                        priority, major_nok, relationship, nok_name, hkid, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
                        INTO var_priority, var_major_nok, par_nok_relation_code, par_nok_name, par_nok_hkid, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language
                        FROM nok
                        WHERE patient_key = par_patient_key AND priority = var_priority;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        BEGIN
                            SELECT
                                NULL
                                INTO par_nok_name;
                        END;
                    END IF;
                END;
            END IF;
			
            IF par_nok_name IS NOT NULL THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM nok
                        WHERE patient_key = par_patient_key) THEN
                        BEGIN
                            BEGIN
                                UPDATE nok
                                SET relationship = par_nok_relation_code, nok_name = par_nok_name, hkid = par_nok_hkid, building = par_nok_building, room = par_nok_room, floor = par_nok_floor, block = par_nok_block, district = par_nok_district_code, phone1 = par_nok_phone1, phone2 = par_nok_phone2, address_indicator = par_nok_address_indicator, mobile_phone = par_nok_mobile_phone_no, sms_language = par_nok_sms_language, update_hospital = par_hospital_code, update_by = par_update_by, source_system_dtm = timestamp_convert(par_source_system_dtm)
                                    WHERE patient_key = par_patient_key AND priority = var_priority;
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
                                    /* Nok is updated between retrieved and update. */
                                    SELECT
                                        200017
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            BEGIN
                                INSERT INTO nok (patient_key, priority, major_nok, hkid, relationship, nok_name, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language, update_hospital, update_by, source_system_dtm,row_update_datetime)
                                VALUES (par_patient_key, var_priority, var_major_nok, par_nok_hkid, par_nok_relation_code, par_nok_name, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language, par_hospital_code, par_update_by, timestamp_convert(par_source_system_dtm),timestamp_convert(localtimestamp));
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                                       	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
										
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
                END;
            ELSE
                BEGIN
                    BEGIN
                        DELETE FROM nok
                            WHERE patient_key = par_patient_key AND priority = var_priority;
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
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO var_priority, var_major_nok, par_nok_relation_code, par_nok_name, par_nok_hkid, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language;
                END;
            END IF;
			
            IF par_source_system = 'PBRC' THEN
                BEGIN
                    SELECT
                        mrn
                        INTO par_mrn
                        FROM patient_hospital_data
                        WHERE hospital_code = par_hospital_code AND patient_key = par_patient_key;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        BEGIN
                            SELECT
                                NULL
                                INTO par_mrn;
                        END;
                    END IF;
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

                    IF EXISTS (SELECT
                        *
                        FROM patient_hospital_data
                        WHERE hospital_code = par_hospital_code AND patient_key = par_patient_key) THEN
                        BEGIN
                            BEGIN
                                UPDATE patient_hospital_data
                                SET mrn = par_mrn, update_by = par_update_by, source_system_dtm = timestamp_convert(par_source_system_dtm)
                                    WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;
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
                                    /* Patient hospital data has been updated between retrieved and update. */
                                    SELECT
                                        200019
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            BEGIN
                                INSERT INTO patient_hospital_data (patient_key, hospital_code, mrn, update_by, source_system_dtm)
                                VALUES (par_patient_key, par_hospital_code, par_mrn, par_update_by, timestamp_convert(par_source_system_dtm));
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
                END;
            ELSE
                BEGIN
                    BEGIN
                        DELETE FROM patient_hospital_data
                            WHERE hospital_code = par_hospital_code AND patient_key = par_patient_key;
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
           	
            /* check unmatch hkid list, if it exists delete it */
            /* For 031, the from hkid is used for checking by LeoLee */
            IF EXISTS (SELECT
                *
                FROM unmatch_hkid
                WHERE hkid = par_hkid) THEN
                BEGIN
                    BEGIN
                        DELETE FROM unmatch_hkid
                            WHERE hkid = par_hkid;
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
           	
            /* Check old hkid exist in sars_hkid_list or not, update the new id in sars_hkid_list by YorkyLenug */
            IF par_new_hkid <> par_hkid THEN
                BEGIN
                    IF EXISTS (SELECT
                        hkid
                        FROM sars_hkid_list
                        WHERE hkid = par_hkid) THEN
                        BEGIN
                            BEGIN
                                IF EXISTS (SELECT
                                    hkid
                                    FROM sars_hkid_list
                                    WHERE hkid = par_new_hkid) THEN
                                    BEGIN
                                        DELETE FROM sars_hkid_list
                                            WHERE hkid = par_hkid;
                                    END;
                                ELSE
                                    BEGIN
                                        UPDATE sars_hkid_list
                                        SET hkid = par_new_hkid
                                            WHERE hkid = par_hkid;
                                    END;
                                END IF;
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
                END;
            END IF;
           	
            /* --	declare hosp_cursor cursor for */
            /* --		select distinct hospital_code */
            /* --			from pmi_case */
            /* --			where patient_key = @patient_key and */
            /* --					hospital_code != @hospital_code */
            /* --			for read only */
            /* by Goya 19981024 */
	        CALL hkpmi_check_patient_detail_1(var_return_code, par_hkid, par_hospital_code);
			 
            IF var_return_code != 0 THEN
                begin
	        	    CALL hkpmi_set_on_patient_hosp(var_return_code, par_new_hkid, par_hospital_code, par_update_by, par_source_system);
                   
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
           
            /*
            19981106 GL, select hospital from patient_patient_1 and pmi_case for
            transaction '030'
            */
            OPEN hosp_cursor;
            FETCH hosp_cursor INTO var_tmp_hospital_code;
			select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
            SELECT
                'N', var_system_dtm
                INTO var_process_local_hospital, var_tran_system_dtm;
			
            WHILE (found_code =0 OR var_process_local_hospital = 'N') LOOP
                IF var_process_local_hospital = 'N' THEN
                    BEGIN
                        SELECT
                            par_hospital_code, par_mrn, 'Y'
                            INTO var_tran_hospital_code, var_tran_mrn, var_upload_status;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            var_tmp_hospital_code, NULL, 'P'
                            INTO var_tran_hospital_code, var_tran_mrn, var_upload_status;
                    END;
                END IF;
               
                WHILE 1 = 1 loop
	                begin
--		            my_conn := 'dbname=hkpmi';
					INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, patient_type, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, update_by, source_system, source_system_dtm, update_hospital, upload_status, filler, ward_class) /* ward_class = hkic_symbol_clear for txn 030 ONLY used by cpi_download */
                        VALUES (timestamp_convert(var_tran_system_dtm), var_tran_hospital_code, par_txn_type, par_new_hkid, par_patient_key, par_patient_name, par_sex, timestamp_convert(par_dob), par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, var_chi_name, par_marital_status, par_race_code, par_other_doc_no, var_tran_mrn, par_building, par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1_no, par_phone2, par_address_indicator, par_mobile_phone_no, par_sms_language, var_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone_no, par_nok_sms_language, par_patient_type, par_patient_key, var_old_patient_name, par_hkid, var_old_sex, timestamp_convert(var_old_dob), par_update_by, par_source_system, timestamp_convert(par_source_system_dtm), par_hospital_code, var_upload_status, var_tran_log_filler, /* @document_flag */ par_hkic_symbol_clear);
                        
--					
					/* ward_class = hkic_symbol_clear for txn 030 ONLY used by cpi_download */
			
                    EXCEPTION  
						WHEN  OTHERS THEN  
							GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,error_sqlstate = RETURNED_SQLSTATE;  
							
						IF error_sqlstate = 23505 THEN  
							select var_tran_system_dtm + INTERVAL '3 milliseconds' into var_tran_system_dtm;  
							CONTINUE;	
						ELSE  
							select error_sqlstate into  var_return_error_code;
							
							EXIT return_system_error;
						END IF;
                   end;
                   EXIT;
                END LOOP;
				
                IF var_process_local_hospital = 'N' THEN
                    BEGIN
                        select 'Y' into var_process_local_hospital;
                    END;
                ELSE
                    BEGIN
                        FETCH hosp_cursor INTO var_tmp_hospital_code;
                        select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                        
                    END;
                END IF;
            END LOOP;
           	
            /* update mother_baby_case table if DOB is changed */
            IF COALESCE(var_old_dob, '99990101') <> COALESCE(par_dob, '99990101') THEN
                begin
	        	    CALL hkpmi_check_mother_baby_case(var_return_code, par_hospital_code, par_patient_key, par_source_system_dtm, par_update_by, par_source_system);
                    IF var_return_code <> 0 THEN
                        BEGIN
                            select var_return_code into var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
           
            /* ---20120908 --- */
            /* ---- patient_key carry to new_hkid --- */
            IF par_txn_type = '031' THEN
                BEGIN
                    INSERT INTO hkpmi_pin_change_log (hosp_code, txn_dtm, txn_type, hkid, patient_key, old_hkid, old_patient_key, update_by, source_sys, source_sys_dtm, update_hosp)
                    VALUES (par_hospital_code, timestamp_convert(var_tran_system_dtm), par_txn_type, par_new_hkid, par_patient_key, par_hkid, par_patient_key, par_update_by, par_source_system, timestamp_convert(par_source_system_dtm), par_hospital_code);
                    
					GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                    var_rowcount := sql$rowcount;

                    /* --- the uniqe key = hosp_code + txn_dtm + hkid  --> 2601 SHOULD NOT occurred */
                    EXCEPTION  
					WHEN  OTHERS THEN  
							GET STACKED DIAGNOSTICS 
												error_sqlstate = RETURNED_SQLSTATE;  
                            /* Fail to insert into hkpmi_pin_change_log. */

							select	error_sqlstate into var_return_error_code;
                            EXIT return_system_error;
                    
                    

                    IF var_rowcount != 1 THEN
                        BEGIN
                            select	200118 into var_return_error_code;

                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* --- end of txn_type='031' */
            /* ---- END 20120908 --- */

            
            pas_return_code := 0;
            RETURN;
        END;
       	raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN  
--						RAISE EXCEPTION USING ERRCODE := var_return_error_code;
    					pas_return_code := var_return_error_code;
        RETURN;
    END;

    raise exception '';
		EXCEPTION  
			WHEN  OTHERS THEN 
    				pas_return_code := var_return_error_code;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_patient_update_1" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
