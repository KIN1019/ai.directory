-- DROP PROCEDURE hkpmi.hkpmi_admission(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, inout varchar, inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_admission(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, INOUT par_patient_key character varying, INOUT par_access_code integer, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_cccode1 character varying, IN par_cccode2 character varying, IN par_cccode3 character varying, IN par_cccode4 character varying, IN par_cccode5 character varying, IN par_cccode6 character varying, IN par_marital_status character varying, IN par_race character varying, IN par_other_doc_no character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district character varying, IN par_religion character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relationship character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_mrn character varying, IN par_case_no character varying, IN par_case_type character varying, IN par_security_count integer, IN par_adm_dtm timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_patient_type character varying, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_ward_class character varying, IN par_pp_code character varying, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba character varying, IN par_discharge_code character varying DEFAULT NULL::character varying, IN par_discharge_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_destination_code character varying DEFAULT NULL::character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying, IN par_source_hosp_code character varying DEFAULT NULL::character varying, IN par_source_case_no character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* transaction information */
/* patient information */
/* nok information */
/* patient hospital data */
/* case information */
/* AE case detail */ /* for convert old case */ /* for convert old case */ /* for convert old case */ /* document verification flag */ /* linked episode */
DECLARE
    var_new_patient_key VARCHAR(08);
    var_return_status INTEGER;
    var_priority SMALLINT;
    var_major_nok VARCHAR(01);
    var_tmp_mrn VARCHAR(08);
    var_tmp_phonetic VARCHAR(48);
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_tmp_hospital_code VARCHAR(03);
    var_tran_hospital_code VARCHAR(03);
    var_process_local_hospital VARCHAR(01);
    var_demo_changed VARCHAR(01);
    var_demo_created VARCHAR(01);
    var_nok_found VARCHAR(01);
    var_begin_tran VARCHAR(01);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_tran_mrn VARCHAR(08);
    var_chi_name VARCHAR(12);
    var_old_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(01);
    var_old_timestamp timestamp(6);
    var_movement_count INTEGER;
    var_pcs_count INTEGER;
    var_initial_access_code INTEGER;
    /* patient information */
    var_old_patient_key VARCHAR(08);
    var_old_patient_name VARCHAR(48);
    var_old_acess_code INTEGER;
    var_old_sex VARCHAR(01);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_exact_dob_flag VARCHAR(01);
    var_old_cccode1 VARCHAR(05);
    var_old_cccode2 VARCHAR(05);
    var_old_cccode3 VARCHAR(05);
    var_old_cccode4 VARCHAR(05);
    var_old_cccode5 VARCHAR(05);
    var_old_cccode6 VARCHAR(05);
    var_old_marital_status VARCHAR(01);
    var_old_race VARCHAR(02);
    var_old_other_doc_no VARCHAR(12);
    var_old_building VARCHAR(47);
    var_old_room VARCHAR(05);
    var_old_floor VARCHAR(02);
    var_old_block VARCHAR(02);
    var_old_district VARCHAR(05);
    var_old_religion VARCHAR(03);
    var_old_phone1 VARCHAR(10);
    var_old_phone2 VARCHAR(10);
    var_old_address_indicator VARCHAR(04);
    var_old_mobile_phone VARCHAR(10);
    var_old_sms_language VARCHAR(04);
    var_old_death_indicator VARCHAR(04);
    var_old_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_old_patient_type VARCHAR(03);
    var_old_access_code INTEGER;
    /* nok information */
    var_old_nok_name VARCHAR(48);
    var_old_nok_hkid VARCHAR(12);
    var_old_nok_relationship VARCHAR(02);
    var_old_nok_building VARCHAR(47);
    var_old_nok_room VARCHAR(05);
    var_old_nok_floor VARCHAR(02);
    var_old_nok_block VARCHAR(02);
    var_old_nok_district VARCHAR(05);
    var_old_nok_phone1 VARCHAR(10);
    var_old_nok_phone2 VARCHAR(10);
    var_old_nok_address_indicator VARCHAR(04);
    var_old_nok_mobile_phone VARCHAR(10);
    var_old_nok_sms_language VARCHAR(04);
    /* mrn information */
    var_old_mrn VARCHAR(08);
    var_old_document_flag VARCHAR(01);
    var_pmi_case_filler VARCHAR(30);
    var_tran_log_filler VARCHAR(30);
    var_lnk_case_patient_key VARCHAR(12);
    var_body_category VARCHAR(1);
    var_filler VARCHAR(30);
    var_rtn_code INTEGER;
    var_old_hkic_symbol VARCHAR(1);
    var_patient_filler VARCHAR(30);
    var_is_schi_name VARCHAR(01);
    var_tmp_date VARCHAR(30);
    var_disc_description VARCHAR(05);
    sql$rowcount BIGINT;
    var_return_code int;
    p_refcur refcursor;
    var_return_hkid VARCHAR;
    var_return_msg varchar;
    error_message text;
    found_code INTEGER;
    hosp_cursor CURSOR FOR
    SELECT
        h.hospital_code
        FROM hospital AS h, patient_detail_1 AS p
        WHERE p.patient_key = par_patient_key AND (p.hosp_byte_1 & h.byte_value_1 > 0 OR p.hosp_byte_2 & h.byte_value_2 > 0 OR p.hosp_byte_3 & h.byte_value_3 > 0) AND h.hospital_code != par_hospital_code
    UNION
    SELECT DISTINCT
        hospital_code
        FROM pmi_case
        WHERE patient_key = par_patient_key AND hospital_code != par_hospital_code
    ;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        begin
	         
	        
            /* Declaration */
            /*
            @mo_hosp						char(3),
            @mo_case						char(12),
            @mo_hosp_2					char(3),
            @mo_case_2					char(12),
            @mo_hosp_hn					char(3),
            @mo_case_hn					char(12),
            @nb_hosp						char(3),
            @nb_case						char(12),
            @nb_hosp_2					char(3),
            @nb_case_2					char(12),
            @nb_hosp_hn					char(3),
            @nb_case_hn					char(12),
            @nb_dob						datetime,
            @birth_place				char(1),
            @birth_loc					char(3),
            @birth_order				int,
            @preg_no						int,
            @days							int,
            @days2						int,
            @days_hn						int
            */
            /* 2006-12-11 Added by HK Fong SMR20015887 - Start */
            /* 2006-12-11 Added by HK Fong SMR20015887 - End */ /* * for convert old case */
        
            /* initalize the variable */
             SELECT  'Y'
                INTO var_begin_tran;
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                /* nok information */
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                /* mrn information */
                NULL,
                /* convert old case by Winnie LAU */
                NULL, NULL, NULL, NULL, NULL
                INTO var_old_patient_key, var_old_patient_name, var_old_sex, var_old_access_code, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district, var_old_religion, var_old_phone1, var_old_phone2, var_old_address_indicator, var_old_mobile_phone, var_old_sms_language, var_old_death_indicator, var_old_death_date, var_old_patient_type, var_priority, var_old_nok_name, var_old_nok_hkid, var_old_nok_relationship, var_old_nok_building, var_old_nok_room, var_old_nok_floor, var_old_nok_block, var_old_nok_district, var_old_nok_phone1, var_old_nok_phone2, var_old_nok_address_indicator, var_old_nok_mobile_phone, var_old_nok_sms_language, var_chi_name, var_old_mrn, var_disc_description, var_old_document_flag, var_pmi_case_filler, var_tran_log_filler, var_old_hkic_symbol;
            /* update nok record */
            SELECT
                'Y'
                INTO var_major_nok;
            /* update patient record */
            SELECT
                1, 0, 2147483647
                INTO var_movement_count, var_pcs_count, var_initial_access_code;
            /* if nok_name is null, set all nok value to null */
            IF par_nok_name IS NULL THEN
                BEGIN
                    SELECT
                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                        INTO par_nok_relationship, par_nok_name, par_nok_hkid, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language;
                END;
            END IF;
            /* moved to lower position */
            /* select   @system_dtm = getdate() */
            /* Validate key fields - add 090 for convert old case */
            IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('100', '300', '090')) OR (par_source_system = 'OPAS' AND par_txn_type IN ('100')) OR (par_source_system = 'OPAS2' AND par_txn_type IN ('100')) OR (par_source_system = 'DNL' AND par_txn_type IN ('100', '300'))) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* check source system dtm */
            IF par_source_system != 'DNL' AND par_source_system != 'OPAS' AND par_source_system != 'OPAS2' THEN
                BEGIN
                    IF par_adm_dtm > par_source_system_dtm THEN
                        BEGIN
                            SELECT
                                200146
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* Check the existence of the case */
           raise notice '1par_hospital_code=%,par_case_no=%',par_hospital_code,par_case_no;
            IF EXISTS (SELECT
                *
                FROM pmi_case
                WHERE case_no = par_case_no AND hospital_code = par_hospital_code) THEN
                BEGIN
                    /*
                    print "Case already exists in pmi_case,
                    duplicate admission is rejected!"
                    */
                    SELECT
                        200075
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* 20061108 YL - Reject duplicate admission of a same patient with source indicator = 8 */
            IF par_source_indicator = '8' THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM patient AS p, pmi_case AS c
                        WHERE p.hkid = par_hkid AND p.patient_key = c.patient_key AND c.source_indicator = '8') THEN
                        BEGIN
                            /*
                            print 'Registration for one patient with more than one case with
                            Source Indicator = "8" is not allowed, admission is rejected!'
                            */
                            SELECT
                                200176
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* * Add by WL on 19981210 - do not allow discharge to death * */
            /* * for convert old case * */
            IF (par_txn_type = '090') AND (par_discharge_code = '1') THEN
                BEGIN
                    /*
                    print "Convert Old Case cannot be discharged to death,
                    admission is rejected!"
                    */
                    SELECT
                        200174
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* get patient  information by HKID */
            SELECT
                patient_key, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, other_doc_no, marital_status, religion, race, patient_type, exact_dob_flag, death_indicator, death_date, access_code,
                /* address */
                building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language,
                /* other */
                source_system_dtm, row_update_datetime, SUBSTRING(filler, 1, 1), SUBSTRING(filler, 2, 1), filler, SUBSTRING(filler, 3, 1)
                INTO var_old_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_other_doc_no, var_old_marital_status, var_old_religion, var_old_race, var_old_patient_type, var_old_exact_dob_flag, var_old_death_indicator, var_old_death_date, var_old_access_code, var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district, var_old_phone1, var_old_phone2, var_old_address_indicator, var_old_mobile_phone, var_old_sms_language, var_old_source_system_dtm, var_old_timestamp, var_old_document_flag, var_body_category, var_filler, var_old_hkic_symbol
                FROM patient
                WHERE hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount <> 0 THEN
                /* Patient already exists */
                BEGIN
                    IF par_document_flag IS NULL OR par_document_flag = 'Z' THEN
                        SELECT
                            var_old_document_flag
                            INTO par_document_flag;
                    END IF;

                    IF par_hkic_symbol IS NULL OR LTRIM(RTRIM(par_hkic_symbol)) = '' THEN /* if pass-in hkic is null or N/A */
                        SELECT
                            var_old_hkic_symbol
                            INTO par_hkic_symbol;
                    END IF;
                    SELECT
                        'N'
                        INTO var_demo_created;
                    SELECT
                        var_old_patient_key
                        INTO par_patient_key;
                    SELECT
                        var_old_access_code
                        INTO par_access_code;
                    /* check the death indicator of the patient */
                    /* only for the out patient case */
                    IF var_old_death_indicator IS NOT NULL AND par_adm_dtm > var_old_death_date AND par_case_type = 'O' AND par_source_system <> 'DNL' THEN
                        BEGIN
                            /* admission is not allow for a death patient */
                            SELECT
                                200098
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* * Add by Winnie Lau to check death dtm against adm. ** */
                    /* * and discharge dtm for convert old case * */
                    IF var_old_death_indicator IS NOT NULL AND par_adm_dtm > var_old_death_date AND par_txn_type = '090' THEN
                        BEGIN
                            /* admission is not allow for a death patient */
                            SELECT
                                200098
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;

                    IF var_old_death_indicator IS NOT NULL AND par_discharge_dtm > var_old_death_date AND par_txn_type = '090' THEN
                        BEGIN
                            /* discharge is not allow for a death patient */
                            SELECT
                                200173
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                    /* get patient nok information */
                    SELECT
                        nok_name, hkid, priority, relationship, phone1, phone2, address_indicator, mobile_phone, sms_language, district, building, room, floor, block
                        INTO var_old_nok_name, var_old_nok_hkid, var_priority, var_old_nok_relationship, var_old_nok_phone1, var_old_nok_phone2, var_old_nok_address_indicator, var_old_nok_mobile_phone, var_old_nok_sms_language, var_old_nok_district, var_old_nok_building, var_old_nok_room, var_old_nok_floor, var_old_nok_block
                        FROM nok
                        WHERE patient_key = par_patient_key AND major_nok = var_major_nok;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            'N'
                            INTO var_nok_found;
                    ELSE
                        SELECT
                            'Y'
                            INTO var_nok_found;
                    END IF;
                    /* By Goya 19981022 */
                    /* get mrn information */
                    SELECT
                        mrn
                        INTO var_old_mrn
                        FROM patient_hospital_data
                        WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            NULL
                            INTO var_old_mrn;
                    END IF;
                    /* ----- Add by Winnie on 19981215, convert old case ---- */
                    /* ----- do not need to update demo---------------------- */

                    IF (var_old_source_system_dtm > par_source_system_dtm) OR (par_txn_type = '090') THEN
                        BEGIN
                            /* Patient's last_source_system_dtm is later than */
                            /* upload's source_system_dtm. */
                            /* do not update patient demo */
                            SELECT
                                var_old_patient_name, var_old_sex, var_old_dob, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_race, var_old_other_doc_no, var_old_marital_status, var_old_religion, var_old_exact_dob_flag,
                                /* address */
                                var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district, var_old_phone1, var_old_phone2, var_old_address_indicator, var_old_mobile_phone, var_old_sms_language,
                                /* nok information */
                                var_old_nok_name, var_old_nok_hkid, var_old_nok_relationship, var_old_nok_phone1, var_old_nok_phone2, var_old_nok_address_indicator, var_old_nok_mobile_phone, var_old_nok_sms_language, var_old_nok_district, var_old_nok_building, var_old_nok_room, var_old_nok_floor, var_old_nok_block, var_old_mrn, var_old_document_flag, var_old_hkic_symbol
                                INTO par_patient_name, par_sex, par_dob, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, par_race, par_other_doc_no, par_marital_status, par_religion, par_exact_dob_flag, par_building, par_room, par_floor, par_block, par_district, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_nok_name, par_nok_hkid, par_nok_relationship, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_nok_district, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_mrn, par_document_flag, par_hkic_symbol;
                            /* the patient of the case must be used */
                            /*
                            to avoid the difference in demo comparsion
                            and demo update
                            */
                            SELECT
                                par_patient_type
                                INTO var_old_patient_type;

                            IF var_nok_found = 'N' THEN
                                SELECT
                                    NULL
                                    INTO var_major_nok;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            /* check nok home number */
                            IF par_nok_phone1 IS NOT NULL AND par_source_system <> 'DNL' AND par_source_system <> 'ADT' AND par_source_system <> 'OPAS' AND par_nok_phone1 NOT SIMILAR TO '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9 ][0-9 ][0-9 ]' THEN
                                BEGIN
                                    /* invalid phone number */
                                    SELECT
                                        200147
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                            /* OPAS does not have nok other phone */
                            IF par_source_system IN ('OPAS', 'DNL') THEN
                                BEGIN
                                    /*
                                    @nok_mobile_phone = @old_mobile_phone,
                                    @nok_sms_language = @old_sms_language
                                    */
                                    SELECT
                                        var_old_nok_mobile_phone, var_old_nok_sms_language
                                        INTO par_nok_mobile_phone, par_nok_sms_language;
                                END;
                            END IF;

                            IF par_source_system = 'OPAS2' THEN
                                BEGIN
                                    IF (par_building is NULL OR par_building = REPEAT(' ', 01)) AND (par_room is NULL OR par_room = REPEAT(' ', 01)) AND (par_floor is NULL OR par_floor = REPEAT(' ', 01)) AND (par_block is NULL OR par_block = REPEAT(' ', 01)) AND (par_district is NULL) THEN
                                        BEGIN
                                            SELECT
                                                var_old_building, var_old_room, var_old_block, var_old_district
                                                INTO par_building, par_room, par_block, par_district;

                                            IF NOT EXISTS (SELECT
                                                *
                                                FROM district
                                                WHERE district_code = par_district) THEN
                                                BEGIN
                                                    SELECT
                                                        'UNK'
                                                        INTO par_district;
                                                END;
                                            END IF;
                                        END;
                                    END IF;
                                    SELECT
                                        var_old_nok_relationship, var_old_nok_name, var_old_nok_hkid, var_old_nok_building, var_old_nok_room, var_old_nok_floor, var_old_nok_block, var_old_nok_district, var_old_nok_phone1, var_old_nok_phone2, var_old_nok_address_indicator, var_old_nok_mobile_phone, var_old_nok_sms_language
                                        INTO par_nok_relationship, par_nok_name, par_nok_hkid, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language;
                                END;
                            END IF;

                            IF par_source_system = 'DNL' THEN
                                BEGIN
                                    SELECT
                                        var_old_phone2, var_old_address_indicator, var_old_mobile_phone, var_old_sms_language
                                        INTO par_phone2, par_address_indicator, par_mobile_phone, par_sms_language;
                                END;
                            END IF;
                        END;
                    END IF;

                    IF var_old_patient_name <> par_patient_name OR var_old_sex <> par_sex OR var_old_dob <> par_dob OR var_old_cccode1 <> par_cccode1 OR var_old_cccode2 <> par_cccode2 OR var_old_cccode3 <> par_cccode3 OR var_old_cccode4 <> par_cccode4 OR var_old_cccode5 <> par_cccode5 OR var_old_cccode6 <> par_cccode6 OR var_old_other_doc_no <> par_other_doc_no OR var_old_marital_status <> par_marital_status OR var_old_religion <> par_religion OR var_old_patient_type <> par_patient_type OR var_old_exact_dob_flag <> par_exact_dob_flag OR var_old_race <> par_race OR
                    /* address */
                    var_old_building <> par_building OR var_old_room <> par_room OR var_old_floor <> par_floor OR var_old_block <> par_block OR var_old_district <> par_district OR var_old_phone1 <> par_phone1 OR var_old_phone2 <> par_phone2 OR var_old_address_indicator <> par_address_indicator OR var_old_mobile_phone <> par_mobile_phone OR var_old_sms_language <> par_sms_language OR
                    /* nok information */
                    var_old_nok_name <> par_nok_name OR var_old_nok_hkid <> par_nok_hkid OR var_old_nok_relationship <> par_nok_relationship OR var_old_nok_phone1 <> par_nok_phone1 OR var_old_nok_phone2 <> par_nok_phone2 OR var_old_nok_address_indicator <> par_nok_address_indicator OR var_old_nok_mobile_phone <> par_nok_mobile_phone OR var_old_nok_sms_language <> par_nok_sms_language OR var_old_nok_district <> par_nok_district OR var_old_nok_building <> par_nok_building OR var_old_nok_room <> par_nok_room OR var_old_nok_floor <> par_nok_floor OR var_old_nok_block <> par_nok_block OR
                    /* by Goya */
                    var_old_mrn <> par_mrn OR var_old_document_flag <> par_document_flag OR var_old_hkic_symbol <> par_hkic_symbol THEN
                        SELECT
                            'Y'
                            INTO var_demo_changed;
                    ELSE
                        SELECT
                            'N'
                            INTO var_demo_changed;
                    END IF;
                    /* Get chinese name from ccc_big5 table */
                    CALL cpi_get_phonetic_chin_name(var_return_code, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, var_tmp_phonetic, var_chi_name);
                    /* 2006-12-11 Addeded by HK Fong SMR20015887 - Start */
                    IF COALESCE(var_chi_name, '') <> '' THEN
                        BEGIN
                            CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => par_cccode1, par_ccc2 => par_cccode2, par_ccc3 => par_cccode3, par_ccc4 => par_cccode4, par_ccc5 => par_cccode5, par_ccc6 => par_cccode6, par_is_schi_name => var_is_schi_name);

                            IF var_is_schi_name = 'Y' THEN
                                SELECT
                                    NULL
                                    INTO var_chi_name;
                            END IF;
                        END;
                    END IF;
                    /* 2006-12-11 Addeded by HK Fong SMR20015887 - End */
                    /* get system datetime for the whole program */
                    SELECT
                        localtimestamp
                        INTO var_system_dtm;

                    IF (var_demo_changed = 'Y') THEN
                        BEGIN
                            /* YL: Preserve body category in filler */
                            /* --select @filler = isnull(@document_flag, space(1)) + isnull(@body_category, space(1)) + substring(@filler,3,28) */
                            SELECT
                                CONCAT(COALESCE(par_document_flag, REPEAT(' ', 1)), COALESCE(var_body_category, REPEAT(' ', 1)), COALESCE(par_hkic_symbol, REPEAT(' ', 1)), SUBSTRING(var_filler, 4, 27))
                                INTO var_filler;
                            /* update patient information */
                            BEGIN
                                UPDATE patient
                                SET patient_name = par_patient_name, sex = par_sex, cccode1 = par_cccode1, cccode2 = par_cccode2, cccode3 = par_cccode3, cccode4 = par_cccode4, cccode5 = par_cccode5, cccode6 = par_cccode6, chi_name = var_chi_name, dob = par_dob, exact_dob_flag = par_exact_dob_flag, marital_status = par_marital_status, race = par_race, other_doc_no = par_other_doc_no, building = par_building, room = par_room, floor = par_floor, block = par_block, district = par_district, religion = par_religion, phone1 = par_phone1, phone2 = par_phone2, address_indicator = par_address_indicator, mobile_phone = par_mobile_phone, sms_language = par_sms_language, patient_type = par_patient_type, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm, filler = var_filler
                                    WHERE patient_key = par_patient_key AND row_update_datetime = var_old_timestamp;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
                                    /* Patient not found or Patient has been updated between */
                                    /* retrieved and update." */
                                    SELECT
                                        200016
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            ELSE
                BEGIN
                    /* patient do not exists, insert needed */
                    /* check patient key */
                    /* do not create patient key for DNL */
	                raise notice '525';
                    IF (par_patient_key IS NULL OR par_patient_key < '40000001' OR par_patient_key > '99999999') AND par_source_system <> 'DNL' THEN
                        BEGIN
                            /* get new patient key, insert a new patient */
                            CALL hkpmi_get_patient_key(var_return_status, var_new_patient_key);
raise notice '530,var_return_status:%', var_return_status;
                            IF (var_return_status != 0) THEN
                                BEGIN
                                    /*
                                    print "Fail to get a new patient key,
                                    admission with a new patient is rejected!"
                                    */
	                                raise notice '537';
                                    SELECT
                                        200082
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                            SELECT
                                var_new_patient_key
                                INTO par_patient_key;
                        END;
                    ELSE
                        BEGIN
                            /* check paitent key exist or not */
                            IF EXISTS (SELECT
                                *
                                FROM patient
                                WHERE patient_key = par_patient_key) THEN
                                BEGIN
                                    /* patient key already used by other patient */
                                    SELECT
                                        200100
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    END IF;
                    /* Get chinese name from ccc_big5 table */
                    raise notice '566'; 
                    CALL cpi_get_phonetic_chin_name(var_return_code, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, var_tmp_phonetic, var_chi_name);
                    /* 2006-12-11 Addeded by HK Fong SMR20015887 - Start */
                   raise notice '568'; 
                   IF COALESCE(var_chi_name, '') <> '' THEN
                        BEGIN
                            CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => par_cccode1, par_ccc2 => par_cccode2, par_ccc3 => par_cccode3, par_ccc4 => par_cccode4, par_ccc5 => par_cccode5, par_ccc6 => par_cccode6, par_is_schi_name => var_is_schi_name);

                            IF var_is_schi_name = 'Y' THEN
                                SELECT
                                    NULL
                                    INTO var_chi_name;
                            END IF;
                        END;
                    END IF;
                    /* 2006-12-11 Addeded by HK Fong SMR20015887 - End */
                    /*
                    set update demo to false for not writing demo changed
                    to own hospital where new patient created
                    */
                    SELECT
                        'N', 'N'
                        INTO var_demo_changed, var_nok_found;
                    /* a new patient is create */
                    SELECT
                        'Y'
                        INTO var_demo_created;
                    SELECT
                        var_initial_access_code
                        INTO par_access_code;
                    /* get system datetime for the whole program */
                    SELECT
                        localtimestamp
                        INTO var_system_dtm;
                    SELECT
                        CONCAT(COALESCE(par_document_flag, REPEAT(' ', 1)), COALESCE(var_body_category, REPEAT(' ', 1)), COALESCE(par_hkic_symbol, REPEAT(' ', 1)), SUBSTRING(var_filler, 4, 27))
                        INTO var_patient_filler;
                    /* insert a new patient record */
                       raise notice '604';
                    BEGIN
                        INSERT INTO patient (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, patient_type, access_code, pcs_count, update_hospital, source_system, update_by, source_system_dtm, system_dtm, filler)
                        VALUES (par_patient_key, par_hkid, par_patient_name, par_sex, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, var_chi_name, par_dob, par_exact_dob_flag, par_marital_status, par_race, par_other_doc_no, par_building, par_room, par_floor, par_block, par_district, par_religion, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, par_patient_type, par_access_code, var_pcs_count, par_hospital_code, par_source_system, par_update_by, par_source_system_dtm, var_system_dtm, var_patient_filler /* @document_flag */);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS then
                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
                                GET STACKED DIAGNOSTICS error_message  = MESSAGE_TEXT;
                                raise notice 'Message_error:%',error_message;
                    END;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;
raise notice '615,var_error:%', var_error;
                    IF var_error != 0 THEN
                        BEGIN
                            SELECT
                                var_error
                                INTO var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;
                END;
            END IF; /* end insert new patient */
            /* update nok information */
            IF par_nok_name IS NOT NULL THEN
                BEGIN
                    IF var_demo_changed = 'Y' OR var_demo_created = 'Y' THEN
                        /* update is needed */
                        BEGIN
                            IF var_nok_found = 'N' THEN
                                BEGIN
                                    SELECT
                                        1
                                        INTO var_priority;
                                    /* NOK do not exists, insert needed */
                                    BEGIN
                                        INSERT INTO nok (patient_key, priority, major_nok, hkid, relationship, nok_name, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language, update_hospital, update_by, source_system_dtm)
                                        VALUES (par_patient_key, var_priority, var_major_nok, par_nok_hkid, par_nok_relationship, par_nok_name, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_hospital_code, par_update_by, par_source_system_dtm);
                                        var_error := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
                                    /* nok exists, update */
                                    BEGIN
                                        UPDATE nok
                                        SET relationship = par_nok_relationship, nok_name = par_nok_name, hkid = par_nok_hkid, building = par_nok_building, room = par_nok_room, floor = par_nok_floor, block = par_nok_block, district = par_nok_district, phone1 = par_nok_phone1, phone2 = par_nok_phone2, address_indicator = par_nok_address_indicator, mobile_phone = par_nok_mobile_phone, sms_language = par_nok_sms_language, update_hospital = par_hospital_code, update_by = par_update_by, source_system_dtm = par_source_system_dtm
                                            WHERE patient_key = par_patient_key AND major_nok = var_major_nok;
                                        var_error := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
                    END IF /* end nok found = N(else) */;
                END; /* end nok is not null */
            ELSE
                BEGIN
                    /*
                    if no nok or delete nok, reset
                    @major_nok, priority to null
                    */
                    SELECT
                        NULL, NULL
                        INTO var_major_nok, var_priority;
                    /* the nok_name is null , delete nok if demo changed */
                    /* except "OPAS2" */
                    IF par_source_system <> 'OPAS2' AND var_demo_changed = 'Y' THEN
                        BEGIN
                            BEGIN
                                DELETE FROM nok
                                    WHERE patient_key = par_patient_key AND major_nok = 'Y';
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
            END IF;
            /* insert or update patient_hospital_data (MRN) */
            IF par_mrn IS NOT NULL THEN
                BEGIN
                    /* by Goya 19981023 */
                    IF var_demo_changed = 'Y' OR var_demo_created = 'Y' THEN
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
                                        SET mrn = par_mrn, update_by = par_update_by, source_system_dtm = par_source_system_dtm
                                            WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;
                                        var_error := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
                                    BEGIN
                                        INSERT INTO patient_hospital_data (patient_key, hospital_code, mrn, update_by, source_system_dtm)
                                        VALUES (par_patient_key, par_hospital_code, par_mrn, par_update_by, par_source_system_dtm);
                                        var_error := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
                END;
            ELSE
                BEGIN
                    /* mrn is null */
                    /* by Goya 19981023 */
                    IF var_demo_changed = 'Y' THEN
                        BEGIN
                            BEGIN
                                DELETE FROM patient_hospital_data
                                    WHERE hospital_code = par_hospital_code AND patient_key = par_patient_key;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
            /* * Add by Winnie LAU due to upload convert old case * */
            IF par_txn_type = '090' THEN
                BEGIN
                    /* -- validate discharge code -- */
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
                    /* --validate destination code -- */
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
                        /* -- discharge code not in 0,4 or 9 -- */
                        SELECT
                            var_disc_description
                            INTO par_destination_code;
                    END IF;
                    SELECT
                        2
                        INTO var_movement_count;
                END;
            ELSE
                /* type <> 090 */
                SELECT
                    NULL, NULL, NULL
                    INTO par_discharge_code, par_destination_code, par_discharge_dtm;
            END IF;
            /*
            20020726 SL: eh_code - filler(2,8) -
            *  format pmi_case.filler &transaction_log.filler
            *	pmi_case_filler(2,8)		=eh_code
            *	tran_log_filler(2,8)		=eh_code
            *	tran_log_filler(1,1)		=document_flag
            *
            */
            /*
            if @eh_code=null
            begin
            	select @pmi_case_filler=null
            	if @document_flag=null
            		select @tran_log_filler=null
            	else
            		select @tran_log_filler=@document_flag
            end
            else
            begin
            	select @pmi_case_filler=space(1)+@eh_code
            	if @document_flag=null
            		select @tran_log_filler=space(1)+@eh_code
            	else
            		select @tran_log_filler=@document_flag+@eh_code
            end
            */
            /* == END 20020726 SL */
            /* 20070331 SL Tx=100/300/121/341 : source_hosp_code = tran_log.filler(12,3), source_case_no=tran_log.filler(15,12) */
            SELECT
                CONCAT(REPEAT(' ', 1), /* NON-Using */ SUBSTRING(CONCAT(par_eh_code, REPEAT(' ', 8)), 1, 8))
                INTO var_pmi_case_filler;
            SELECT
                CONCAT(SUBSTRING(CONCAT(par_document_flag, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(par_eh_code, REPEAT(' ', 8)), 1, 8), REPEAT(' ', 2), SUBSTRING(CONCAT(par_source_hosp_code, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(par_source_case_no, REPEAT(' ', 12)), 1, 12), REPEAT(' ', 3), SUBSTRING(CONCAT(par_hkic_symbol, REPEAT(' ', 1)), 1, 1))
                INTO var_tran_log_filler; /* ---/* hkic_symbol = transaction_log.filler(30,1)*/ */

            IF (LTRIM(RTRIM(var_pmi_case_filler)) = '') OR (LTRIM(RTRIM(var_pmi_case_filler)) is NULL) THEN
                SELECT
                    NULL
                    INTO var_pmi_case_filler;
            END IF;

            IF (LTRIM(RTRIM(var_tran_log_filler)) = '') OR (LTRIM(RTRIM(var_tran_log_filler)) is NULL) THEN
                SELECT
                    NULL
                    INTO var_tran_log_filler;
            END IF;
            /* 20070331 SL */
            /* insert pmi_case */
           	raise notice '2par_hospital_code=%,par_case_no=%',par_hospital_code,par_case_no;
            IF EXISTS (SELECT
                *
                FROM pmi_case
                WHERE hospital_code = par_hospital_code AND case_no = par_case_no) THEN
                BEGIN
                    /* Case no already exists. */
                    SELECT
                        200075
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            ELSE
                BEGIN
                    /* insert case into pmi_case */
                    /* insert discharge info. because of convert old case */
                    BEGIN
                        INSERT INTO pmi_case (hospital_code, case_no, patient_key, case_type, adm_dtm, source_indicator, source_code, patient_type, adm_specialty_code, adm_ward_code, adm_ward_class, last_specialty_code, last_ward_code, last_ward_class, pp_code, access_code, create_by, create_dtm, update_by, source_system_dtm, district, movement_count, security_count, source_system, discharge_code, discharge_dtm, destination_code, filler)
                        VALUES (par_hospital_code, par_case_no, par_patient_key, par_case_type, par_adm_dtm, par_source_indicator, par_source_code, par_patient_type, par_specialty_code, par_ward_code, par_ward_class, par_specialty_code, par_ward_code, par_ward_class, par_pp_code, par_access_code, par_update_by, par_source_system_dtm, par_update_by, par_source_system_dtm, par_district, var_movement_count, par_security_count, par_source_system, par_discharge_code, par_discharge_dtm, par_destination_code, var_pmi_case_filler);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
            /* insert ae_case_detail */
            IF (par_case_type = 'A') THEN
                BEGIN
                    BEGIN
                        INSERT INTO ae_case_detail (case_no, hospital_code, ambulance_no, police_case, labour_case, ae_case_type, dba)
                        VALUES (par_case_no, par_hospital_code, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba);
                        var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
            /* 19981106 GL - set patient off from patient_detail_1 */
            CALL hkpmi_check_patient_detail_1(var_return_status, par_hkid, par_hospital_code );


            IF var_return_status = 0 THEN
                BEGIN
                    CALL hkpmi_set_off_patient_hosp(var_return_status, par_hkid, par_hospital_code, par_update_by, par_source_system);
     

                    IF var_return_status != 0 THEN
                        BEGIN
                            IF var_return_status > 200000 THEN
                                SELECT
                                    var_return_status
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
            /*
            20050713 LSCHU - update mother_baby_case if admitted case
            affect the table
            */
            IF par_case_type IN ('I', 'A') THEN
                BEGIN
                    /* mother case exist */
                    CALL hkpmi_check_mother_baby_case(var_return_status, par_hospital_code, par_patient_key, par_source_system_dtm, par_update_by, par_source_system);

                    IF var_return_status <> 0 THEN
                        BEGIN
                            SELECT
                                var_return_status
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* ***************20070331 SL hkpmi_linked_case ********************** */
            /* Only enabled for IPAS, exclude OPAS/PBRC/DNL,etc */
            /* ---if @source_system = 'ADT' */
            IF par_case_type IN ('I', 'A') THEN
                BEGIN
                    IF (LTRIM(RTRIM(par_source_hosp_code)) = '') OR (LTRIM(RTRIM(par_source_hosp_code)) is NULL) THEN
                        SELECT
                            NULL
                            INTO par_source_hosp_code;
                    END IF;

                    IF (LTRIM(RTRIM(par_source_case_no)) = '') OR (LTRIM(RTRIM(par_source_case_no)) is NULL) THEN
                        SELECT
                            NULL
                            INTO par_source_case_no;
                    END IF;
                    /* --- if Linked episode found ---- */

                    IF (par_source_hosp_code IS NOT NULL) AND (par_source_case_no IS NOT NULL) THEN
                        BEGIN
                            /*
                            may delay caused by upload problem
                            	if not exists (select * from pmi_case where case_no = @case_no and hospital_code =@hospital_code )
                            	begin
                               	select @return_error_code = 200038
                               	goto return_error
                            	end
                            */
                            IF EXISTS (SELECT
                                *
                                FROM hkpmi_linked_case
                                WHERE hospital_code = par_hospital_code AND case_no = par_case_no)
                            /* ---	and previous_hospital = @source_hosp_code */
                            /* --- 	and previous_case = @source_case_no */
                            THEN
                                BEGIN
                                    SELECT
                                        200038
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                            /* Check the input Source_case belong to same patient or not */
                            /* NOTE : No checking in cpi_admission : may cause cpi_upload problem */
                            SELECT
                                patient_key
                                INTO var_lnk_case_patient_key
                                FROM pmi_case
                                WHERE hospital_code = par_source_hosp_code AND case_no = par_source_case_no;

                            IF var_lnk_case_patient_key <> par_patient_key THEN
                                BEGIN
                                    SELECT
                                        200038
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            ELSE
                                BEGIN
                                    BEGIN
                                        INSERT INTO hkpmi_linked_case (hospital_code, case_no, previous_hospital, previous_case, create_by, create_dtm, update_by, update_dtm)
                                        VALUES (par_hospital_code, par_case_no, par_source_hosp_code, par_source_case_no, par_update_by, par_source_system_dtm, par_update_by, par_source_system_dtm);
                                        var_error := 0;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
                                    END;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                    var_rowcount := sql$rowcount;

                                    IF (var_error != 0) OR (var_rowcount = 0) THEN
                                        BEGIN
                                            SELECT
                                                200038
                                                INTO var_return_error_code;
                                            EXIT return_error;
                                        END;
                                    END IF;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            /* ***************** 20070331 SL ***************************** */
            /* **************20081128 SL : UID linkage********************** */
            /* UID_HKID = hkid ; Link_HKID = other_doc_no */
            /* --- new error code 210003 Fail to insert hkpmi_uid_table */
            IF par_source_system = 'ADT' AND par_txn_type IN ('100', '300') AND par_patient_type = 'UID' AND SUBSTRING(par_hkid, 1, 1) = 'U' THEN
                BEGIN
                    CALL hkpmi_update_uid_table(pas_return_code, 'AL', par_hospital_code, par_hkid, par_other_doc_no, 'L',
                    /* ---@adm_dtm,@hospital_code,@update_by,@source_system, */
                    par_source_system_dtm, par_hospital_code, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, par_update_by, par_source_system, var_return_hkid,var_rtn_code,var_return_msg, p_refcur);


                    IF var_rtn_code < 0 THEN
                        BEGIN
                            SELECT
                                210003
                                INTO var_return_error_code;
                            EXIT return_error;
                        END;
                    END IF;
                END;
            END IF;
            /* **************20081128 SL : UID linkage********************** */
            /* insert transaction_log for admission */
            SELECT
                var_system_dtm
                INTO var_tran_system_dtm;

            IF par_source_system = 'DNL' THEN
                SELECT
                    'P'
                    INTO var_upload_status;
            ELSE
                BEGIN
                    /* do not upload the death patient demo update */
                    IF var_old_death_indicator IS NULL THEN
                        SELECT
                            'Y'
                            INTO var_upload_status;
                    ELSE
                        SELECT
                            'P'
                            INTO var_upload_status;
                    END IF;
                END;
            END IF;

            WHILE 1 = 1 LOOP
                begin
	                raise notice 'INSERT INTO download.transaction_log';
                    INSERT INTO download.transaction_log (system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language,
                    /* nok information */
                    priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language,
                    /* case information */
                    case_no, source_indicator, source_code, patient_type, case_type, security_count, case_access_code, pmi_access_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, ward_class, pp_code, old_hkid, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler,
                    /* convert old case */
                    discharge_code, destination_code, discharge_dtm)
                    VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, par_adm_dtm, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, var_chi_name, par_marital_status, par_race, par_other_doc_no, par_mrn, par_building, par_room, par_floor, par_block, par_district, par_religion, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language,
                    /* nok information */
                    var_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relationship, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language,
                    /* case information */
                    par_case_no, par_source_indicator, par_source_code, par_patient_type, par_case_type, par_security_count, par_access_code, par_access_code, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba, par_ward_code, par_specialty_code, par_ward_class, par_pp_code, par_hkid, par_update_by, par_hospital_code, par_source_system, par_source_system_dtm, var_upload_status, /* @document_flag, */ var_tran_log_filler,
                    /* convert old case */
                    par_discharge_code, par_destination_code, par_discharge_dtm);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS then
                        	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                        	raise notice '%',error_message;
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
            END LOOP; /* end insert transaction_log from admission */
            /*
            try to check hkid exist in unmatch hkid list, if exists
            force to set the @demo_change to Y to write tranaction
            */
            /* -------- no need to check unmatch hkid list if type = 090 --- */
            /* -------- by WL on 19981216 ---------------------------------- */
            IF (var_demo_changed = 'N') AND (par_txn_type <> '090') THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM unmatch_hkid
                        WHERE hkid = par_hkid) THEN
                        BEGIN
                            SELECT
                                'Y'
                                INTO var_demo_changed;

                            BEGIN
                                DELETE FROM unmatch_hkid
                                    WHERE hkid = par_hkid;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        GET STACKED DIAGNOSTICS var_error  = RETURNED_SQLSTATE;
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
            END IF;
            /* insert transaction_log for demo updated */
            IF var_demo_changed = 'Y' THEN
                BEGIN
                    SELECT
                        '030'
                        INTO par_txn_type;
                    /*
                    19981106 GL - write 030 transaction for these hospital having this
                    patient's demo.
                    */
                    /* --		declare hosp_cursor cursor for */
                    /* --			select distinct hospital_code */
                    /* --				from pmi_case */
                    /* --				where patient_key = @patient_key and */
                    /* --						hospital_code != @hospital_code */
                    /* --				for read only */
                    OPEN hosp_cursor;
                    FETCH hosp_cursor INTO var_tmp_hospital_code;
                    select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                    SELECT
                        var_system_dtm
                        INTO var_tran_system_dtm;
-- and var_tmp_hospital_code is not null
                    WHILE found_code =0   LOOP
                        SELECT
                            3 * INTERVAL '1 millisecond' + var_tran_system_dtm::TIMESTAMP
                            INTO var_tran_system_dtm;
                        SELECT
                            var_tmp_hospital_code, NULL, 'P'
                            INTO var_tran_hospital_code, var_tran_mrn, var_upload_status;

                        WHILE 1 = 1 LOOP
                            /* ---@hospital_code, @upload_status,@tran_log_filler) */
                            begin
	                            
                                INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, patient_type, old_patient_key, old_patient_name, old_hkid, old_sex, old_dob, update_by, source_system, source_system_dtm, update_hospital, upload_status, filler)
                                VALUES (var_tran_system_dtm, var_tran_hospital_code, par_txn_type, par_hkid, par_patient_key, par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_cccode1, par_cccode2, par_cccode3, par_cccode4, par_cccode5, par_cccode6, var_chi_name, par_marital_status, par_race, par_other_doc_no, var_tran_mrn, par_building, par_room, par_floor, par_block, par_district, par_religion, par_phone1, par_phone2, par_address_indicator, par_mobile_phone, par_sms_language, var_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relationship, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_patient_type, par_patient_key, var_old_patient_name, par_hkid, var_old_sex, var_old_dob, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status, /* @document_flag */ var_tran_log_filler);
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS then
                                    	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                        				raise notice '%',error_message;
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
                       	
                        FETCH hosp_cursor INTO var_tmp_hospital_code;
                       	select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                    END LOOP;
                END;
            END IF; /* end insert transaction_log from demo updated */
            /* --	select @tmp_date = convert(char(30), getdate(), 109) */
            /* --	print "end %1! %2!", @case_no, @tmp_date */
            /*
            check this case of this patient is the first case.
            if 1st case, write a death and confidential transaction
            to local hospital.
            
            This secton is only for the use of other system
            */
            SELECT
                COUNT(*)
                INTO var_rowcount
                FROM pmi_case
                WHERE hospital_code = par_hospital_code AND patient_key = par_patient_key;
            /* --	select @tmp_date = convert(char(30), getdate(), 109) */
            /* --	print "end select %1! %2!", @case_no, @tmp_date */
            IF (var_rowcount = 1) THEN
                BEGIN
                    /* write a death transaction */
                    IF (var_old_death_indicator IS NOT NULL) THEN
                        BEGIN
                            CALL hkpmi_patient_death_tx(var_return_status, par_hospital_code, '033', par_hkid, 'Y' );

                            IF (var_return_status != 0) THEN
                                BEGIN
                                    SELECT
                                        var_return_status
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    END IF;
                    /*
                    if old access code is not as initial access code
                    a 034 tranaction will be create
                    */
                    IF var_old_access_code <> var_initial_access_code AND var_old_access_code IS NOT NULL THEN
                        BEGIN
                            CALL hkpmi_access_code_update(var_return_status, par_hospital_code, '034', par_source_system_dtm, par_update_by, par_source_system, par_patient_key, par_hkid, par_patient_name, par_sex, par_dob, par_access_code, 'N');

                            IF (var_return_status != 0) THEN
                                BEGIN
                                    SELECT
                                        var_return_status
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            /*
            if @case_type in ('I', 'A')
            begin
            	declare mo_csr cursor for
            		select mother_hospital_code, mother_case_no, mother_hospital_2,
            			mother_case_2, mother_hospital_hn, mother_case_hn,
            			baby_hospital_code, baby_case_no, baby_hospital_2,
            			baby_case_2, baby_hospital_hn, baby_case_hn,
            			birth_order, pregnancy_number, birth_place, birth_location
            			from pmi_case c, mother_baby_case m
            			where c.patient_key = @patient_key
            			and c.hospital_code = m.mother_hospital_code
            			and c.case_no = m.mother_case_no
            			and (m.mother_case_no <> @case_no
            			or m.mother_hospital_code <> @hospital_code)
            			and c.adm_dtm <= @adm_dtm
            			and active_status = 'Y'
            		for read only
            	open mo_csr
            	fetch mo_csr into @mo_hosp, @mo_case, @mo_hosp_2, @mo_case_2,
            		@mo_hosp_hn, @mo_case_hn, @nb_hosp, @nb_case, @nb_hosp_2,
            		@nb_case_2, @nb_hosp_hn, @nb_case_hn, @birth_order, @preg_no,
            		@birth_place, @birth_loc
            	while @@sqlstatus = 0
            	begin
            		select @nb_dob = dob
            			from pmi_case c, patient p
            			where c.hospital_code = @nb_hosp
            			and c.case_no = @nb_case
            			and c.patient_key = p.patient_key
            		select @days = datediff(hh,@nb_dob,@adm_dtm)
            		if @days >= 0 and @days <= 48
            		begin
            			if @mo_hosp_2 is not null and @mo_case_2 is not null
            				select @days2 = datediff(hh,@nb_dob,adm_dtm)
            					from pmi_case
            					where hospital_code = @mo_hosp_2
            					and case_no = @mo_case_2
            			else
            				select @days2 = 49
            			if @mo_hosp_hn is not null and @mo_case_hn is not null
            				select @days_hn = datediff(hh,@nb_dob,adm_dtm)
            					from pmi_case
            					where hospital_code = @mo_hosp_hn
            					and case_no = @mo_case_hn
            			else
            				select @days_hn = 49
            			if @days < @days2 or
            				(@case_type = 'I' and @days < @days_hn)
            			begin
            				exec @return_status = hkpmi_update_mother_baby_case
            					@mo_hosp, @mo_hosp, @mo_case, @nb_hosp, @nb_case,
            					@birth_order, @preg_no, @birth_place, @birth_loc,
            					@update_by, '261', @source_system, @source_system_dtm,
            					@mo_hosp, @mo_case, @nb_hosp, @nb_case,
            					null, null, null, null, null
            				if (@return_status != 0)
            				begin
            					select @return_error_code = @return_status
            					goto return_error
            				end
            			end
            		end
            		fetch mo_csr into @mo_hosp, @mo_case, @mo_hosp_2, @mo_case_2,
            			@mo_hosp_hn, @mo_case_hn, @nb_hosp, @nb_case, @nb_hosp_2,
            			@nb_case_2, @nb_hosp_hn, @nb_case_hn, @birth_order, @preg_no,
            			@birth_place, @birth_loc
            	end
            	close mo_csr
            	deallocate cursor mo_csr
            */
            /* baby case exist */
            /*
            declare nb_csr cursor for
            		select mother_hospital_code, mother_case_no, mother_hospital_2,
            			mother_case_2, mother_hospital_hn, mother_case_hn,
            			baby_hospital_code, baby_case_no, baby_hospital_2,
            			baby_case_2, baby_hospital_hn, baby_case_hn,
            			birth_order, pregnancy_number, birth_place, birth_location
            			from pmi_case c, mother_baby_case m
            			where c.patient_key = @patient_key
            			and c.hospital_code = m.baby_hospital_code
            			and c.case_no = m.baby_case_no
            			and (m.baby_case_no <> @case_no
            			or m.baby_hospital_code <> @hospital_code)
            			and c.adm_dtm <= @adm_dtm
            			and active_status = 'Y'
            		for read only
            	open nb_csr
            	fetch nb_csr into @mo_hosp, @mo_case, @mo_hosp_2, @mo_case_2,
            		@mo_hosp_hn, @mo_case_hn, @nb_hosp, @nb_case, @nb_hosp_2,
            		@nb_case_2, @nb_hosp_hn, @nb_case_hn, @birth_order, @preg_no,
            		@birth_place, @birth_loc
            	while @@sqlstatus = 0
            	begin
            		select @nb_dob = dob
            			from pmi_case c, patient p
            			where c.hospital_code = @nb_hosp
            			and c.case_no = @nb_case
            			and c.patient_key = p.patient_key
            		select @days = datediff(hh,@nb_dob,@adm_dtm)
            		if @days >= 0 and @days <= 48
            		begin
            			if @nb_hosp_2 is not null and @nb_case_2 is not null
            				select @days2 = datediff(hh,@nb_dob,adm_dtm)
            					from pmi_case
            					where hospital_code = @nb_hosp_2
            					and case_no = @nb_case_2
            			else
            				select @days2 = 49
            			if @nb_hosp_hn is not null and @nb_case_hn is not null
            				select @days_hn = datediff(hh,@nb_dob,adm_dtm)
            					from pmi_case
            					where hospital_code = @nb_hosp_hn
            					and case_no = @nb_case_hn
            			else
            				select @days_hn = 49
            			if @days < @days2 or
            				(@case_type = 'I' and @days < @days_hn)
            			begin
            				exec @return_status = hkpmi_update_mother_baby_case
            					@mo_hosp, @mo_hosp, @mo_case, @nb_hosp, @nb_case,
            					@birth_order, @preg_no, @birth_place, @birth_loc,
            					@update_by, '261', @source_system, @source_system_dtm,
            					@mo_hosp, @mo_case, @nb_hosp, @nb_case,
            					null, null, null, null, null
            				if (@return_status != 0)
            				begin
            					select @return_error_code = @return_status
            					goto return_error
            				end
            			end
            		end
            		fetch nb_csr into @mo_hosp, @mo_case, @mo_hosp_2, @mo_case_2,
            			@mo_hosp_hn, @mo_case_hn, @nb_hosp, @nb_case, @nb_hosp_2,
            			@nb_case_2, @nb_hosp_hn, @nb_case_hn, @birth_order, @preg_no,
            			@birth_place, @birth_loc
            	end
            	close nb_csr
            	deallocate cursor nb_csr
            end
            */

            pas_return_code := 0;
            RETURN;

            <<normal_end>>
            BEGIN
            END;
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
END; /* end the procedure */
$procedure$
;


ALTER PROCEDURE "hkpmi_admission" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";