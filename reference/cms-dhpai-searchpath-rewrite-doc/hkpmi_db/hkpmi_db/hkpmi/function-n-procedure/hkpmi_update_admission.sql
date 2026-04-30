-- DROP PROCEDURE hkpmi.hkpmi_update_admission(inout int4, in varchar, in varchar, in timestamp, in varchar, in varchar, inout varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_update_admission(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_source_system_dtm timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, INOUT par_patient_key character varying, IN par_hkid character varying, IN par_case_no character varying, IN par_adm_dtm timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_patient_type character varying, IN par_adm_ward_code character varying, IN par_adm_specialty_code character varying, IN par_adm_ward_class character varying, IN par_old_ward_code character varying, IN par_old_specialty_code character varying, IN par_old_ward_class character varying, IN par_pp_code character varying, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_eh_code character varying DEFAULT NULL::character varying, IN par_source_hosp_code character varying DEFAULT NULL::character varying, IN par_source_case_no character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* transaction information */
/* patient information */
/* case information */
/* AE case detail */
DECLARE
    var_major_nok VARCHAR(01);
    var_tmp_phonetic VARCHAR(48);
    var_return_error_code INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_tmp_hospital_code VARCHAR(03);
    var_tran_hospital_code VARCHAR(03);
    var_process_local_hospital VARCHAR(01);
    var_demo_changed VARCHAR(01);
    var_tmp_case_no VARCHAR(12);
    var_begin_tran VARCHAR(01);
    var_tran_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_chi_name VARCHAR(12);
    var_old_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_upload_status VARCHAR(01);
    var_old_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_case_old_timestamp TIMESTAMP WITHOUT TIME ZONE;
    /* patient information */
    var_old_patient_key VARCHAR(08);
    var_old_patient_name VARCHAR(48);
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
    var_old_phone1_ext VARCHAR(10);
    var_old_phone2 VARCHAR(10);
    var_old_address_indicator VARCHAR(04);
    var_old_mobile_phone VARCHAR(10);
    var_old_sms_language VARCHAR(04);
    var_old_death_indicator VARCHAR(04);
    var_old_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_old_patient_type VARCHAR(03);
    /* nok information */
    var_old_nok_name VARCHAR(48);
    var_old_nok_priority SMALLINT;
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
    /* case information */
    var_case_patient_type VARCHAR(03);
    var_case_patient_key VARCHAR(08);
    var_case_case_type VARCHAR(01);
    var_case_hkid VARCHAR(12);
    var_case_adm_ward_code VARCHAR(04);
    var_case_adm_specialty_code VARCHAR(04);
    var_case_adm_ward_class VARCHAR(01);
    var_case_last_ward_code VARCHAR(04);
    var_case_last_specialty_code VARCHAR(04);
    var_case_last_ward_class VARCHAR(01);
    var_case_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_case_movement_count INTEGER;
    var_case_discharge_code VARCHAR(01);
    var_case_pp_code VARCHAR(08);
    var_case_source_code VARCHAR(03);
    var_case_source_indicator VARCHAR(01);
    var_max_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_mrn VARCHAR(08);
    var_temp_mrn VARCHAR(08);
    var_old_document_flag VARCHAR(01);
    var_old_eh_code VARCHAR(08);
    var_old_pmi_case_filler VARCHAR(30);
    var_pmi_case_filler VARCHAR(30);
    var_tran_log_filler VARCHAR(30);
    var_lnk_case_patient_key VARCHAR(12);
    var_old_source_hosp_code VARCHAR(3);
    var_old_source_case_no VARCHAR(12);
    var_old_filler VARCHAR(30); /* YL: Preserve filler information */
    var_update_filler VARCHAR(30);
    var_txn_type_ind VARCHAR(1);
    var_tran_log_filler_030 VARCHAR(30); /* ---20130515 */
    var_old_hkic_symbol VARCHAR(1);
    var_is_schi_name VARCHAR(01);
    sql$rowcount BIGINT;
    var_return_code int;
    found_code INTEGER;
    hosp_cursor CURSOR FOR
    SELECT DISTINCT
        hospital_code
        FROM pmi_case
        WHERE patient_key = par_patient_key AND hospital_code != par_hospital_code;
begin
	SET search_path TO hkpmi, public;
    <<return_system_error>>
    BEGIN
        <<return_error>>
        BEGIN
            /* Declaration */
            /* 2006-12-11 Added by HK Fong SMR20015887 - Start */
            /* 2006-12-11 Added by HK Fong SMR20015887 - End */
            select  'Y' into var_begin_tran;
            /* initalize the variable */
            SELECT
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                /* nok information */
                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                INTO var_old_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district, var_old_religion, var_old_phone1, var_old_phone2, var_old_address_indicator, var_old_mobile_phone, var_old_sms_language, var_old_death_indicator, var_old_death_date, var_old_patient_type, var_old_nok_name, var_old_nok_hkid, var_old_nok_relationship, var_old_nok_building, var_old_nok_room, var_old_nok_floor, var_old_nok_block, var_old_nok_district, var_old_nok_phone1, var_old_nok_phone2, var_old_nok_address_indicator, var_old_nok_mobile_phone, var_old_nok_sms_language, var_mrn, var_temp_mrn, var_old_document_flag, var_old_eh_code, var_old_pmi_case_filler, var_pmi_case_filler, var_tran_log_filler;
            /* update nok record */
            SELECT
                'Y'
                INTO var_major_nok;
            /* Validate key fields */
            IF NOT ((par_source_system = 'ADT' AND par_txn_type IN ('121', '341')) OR (par_source_system = 'PBRC' AND par_txn_type IN ('121', '341')) OR (par_source_system = 'OPAS' AND par_txn_type IN ('121')) OR (par_source_system = 'OPAS2' AND par_txn_type IN ('121')) OR (par_source_system = 'DNL' AND par_txn_type IN ('121', '341'))) THEN
                BEGIN
                    /* Invalid transaction type. */
                    SELECT
                        200014
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* check source system dtm */
            IF par_source_system != 'DNL' AND par_source_system != 'PBRC' THEN
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
            SELECT
                patient_type, patient_key, case_type, adm_dtm, adm_ward_code, adm_specialty_code, adm_ward_class, last_ward_code, last_specialty_code, last_ward_class, pp_code, source_indicator, source_code, discharge_code, movement_count, row_update_datetime, filler
                INTO var_case_patient_type, var_case_patient_key, var_case_case_type, var_case_adm_dtm, var_case_adm_ward_code, var_case_adm_specialty_code, var_case_adm_ward_class, var_case_last_ward_code, var_case_last_specialty_code, var_case_last_ward_class, var_case_pp_code, var_case_source_indicator, var_case_source_code, var_case_discharge_code, var_case_movement_count, var_case_old_timestamp, var_old_pmi_case_filler
                FROM pmi_case
                WHERE case_no = par_case_no AND hospital_code = par_hospital_code;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /*
                    print "Case does not exist in pmi_case,
                    admission update is rejected!"
                    */
                    SELECT
                        200123
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            ELSE
                BEGIN
                    /*
                    for old data specialty and ward may not exists
                    the upload data will use to update case
                    */
                    /*
                    if source system is PBRC, the adm spec will not be
                    set as upload adm spec if adm spec in pmi_case
                    is null
                    */
                    IF var_case_adm_specialty_code IS NULL AND par_old_specialty_code IS NULL AND par_old_ward_code IS NULL AND par_old_ward_class IS NULL AND par_source_system <> 'PBRC' THEN
                        SELECT
                            par_adm_specialty_code, par_adm_ward_code, par_adm_ward_class
                            INTO var_case_adm_specialty_code, var_case_adm_ward_code, var_case_adm_ward_class;
                    END IF;
                    /* PBRC may not contain adm information */
                    IF par_source_system = 'PBRC' THEN
                        BEGIN
                            SELECT
                                var_case_adm_dtm,
                                /*
                                set all old ward,spec,class to null,
                                it will not update adm and last ward,spec,class
                                */
                                NULL, NULL, NULL, var_case_pp_code, var_case_source_indicator, var_case_source_code
                                INTO par_adm_dtm, par_old_ward_code, par_old_specialty_code, par_old_ward_class, par_pp_code, par_source_indicator, par_source_code;
                        END;
                    END IF;
                    /* OPAS and OPAS2 only contain adt_dtm */
                    IF par_source_system = 'OPAS' OR par_source_system = 'OPAS2' THEN
                        BEGIN
                            SELECT
                                NULL,
                                /* @old_specialty_code = null  --- 20030123 SL : enable upd Spec. for 121 */
                                NULL, var_case_pp_code, var_case_source_indicator, var_case_source_code, var_case_patient_type
                                INTO par_old_ward_code, par_old_ward_class, par_pp_code, par_source_indicator, par_source_code, par_patient_type;
                        END;
                    END IF;
                    /* check case type and format input parameter */
                    IF var_case_case_type = 'A' THEN
                        BEGIN
                            SELECT
                                NULL, NULL,
                                /* ----		@pp_code = null, /*20040315 SL*/ */
                                NULL, NULL, NULL
                                INTO par_source_indicator, par_source_code, par_old_ward_code, par_old_ward_class, par_old_specialty_code;
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                NULL, NULL, NULL, NULL, NULL
                                INTO par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba;
                        END;
                    END IF;
                    /* check case information */
                    IF par_old_ward_code IS NOT NULL OR par_old_ward_class IS NOT NULL OR par_old_specialty_code IS NOT NULL THEN
                        BEGIN
                            IF var_case_movement_count IS NOT NULL AND var_case_movement_count <> 1 AND (par_source_system <> 'OPAS' AND par_source_system <> 'OPAS2') THEN /* 20070521 CHULS - remove checking for admission date/time update for OPAS */
                                BEGIN
                                    /*
                                    print "Admission cannot be updated
                                    after movement occured"
                                    */
                                    SELECT
                                        200131
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            ELSE
                                BEGIN
                                    IF var_case_adm_specialty_code IS NOT NULL AND (par_old_ward_code <> var_case_adm_ward_code OR (par_old_ward_class <> var_case_adm_ward_class AND var_case_adm_ward_class IS NOT NULL) OR
                                    /* @old_specialty_code <> @case_adm_specialty_code */
                                    (par_old_specialty_code <> var_case_adm_specialty_code AND
                                    /* 20030123 SL : enable Upd. Spec for Opas */
                                    par_source_system <> 'OPAS' AND par_source_system <> 'OPAS2')) THEN
                                        BEGIN
                                            /* case information not match */
                                            SELECT
                                                200141
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
            /* check case and hkid match */
            SELECT
                hkid
                INTO var_case_hkid
                FROM patient
                WHERE patient_key = var_case_patient_key;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /* case's patient not found */
                    SELECT
                        200126
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;

            IF var_case_hkid <> par_hkid THEN
                BEGIN
                    /* case hkid do not match with case */
                    SELECT
                        200125
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* set input patient_key */
            SELECT
                var_case_patient_key
                INTO par_patient_key;
            /* get mrn for the patient */
            SELECT
                mrn
                INTO var_mrn
                FROM patient_hospital_data
                WHERE hospital_code = par_hospital_code AND patient_key = par_patient_key;
            /* get patient  information by HKID */
            SELECT
                patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, other_doc_no, marital_status, religion, patient_type, exact_dob_flag, race,
                /* address */
                building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language,
                /* other */
                source_system_dtm, row_update_datetime, SUBSTRING(filler, 1, 1), SUBSTRING(filler, 3, 1),
                /* ---- HKIC symbol for 030 txn log filler */
                filler
                INTO var_old_patient_name, var_old_sex, var_old_dob, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_old_other_doc_no, var_old_marital_status, var_old_religion, var_old_patient_type, var_old_exact_dob_flag, var_old_race, var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district, var_old_phone1, var_old_phone2, var_old_address_indicator, var_old_mobile_phone, var_old_sms_language, var_old_source_system_dtm, var_old_timestamp, var_old_document_flag, var_old_hkic_symbol, var_old_filler
                FROM patient
                WHERE hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount = 0 THEN
                BEGIN
                    /* patient not exists */
                    /* admission update is rejected!" */
                    SELECT
                        200012
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            ELSE
                BEGIN
                    /* move from section before get patient info by Leo 050131 */
                    /* check patient type changed */
                    IF (var_case_patient_type <> par_patient_type) THEN
                        BEGIN
                            /* comment checking lastest case */
                            /*
                            select @max_adm_dtm = max(adm_dtm)
                            	from pmi_case
                            	where  patient_key = @patient_key
                            
                            if @adm_dtm >= @max_adm_dtm
                            */
                            /* new added logic to check source system dtm by Leo 050131 */
                            IF var_old_source_system_dtm > par_source_system_dtm THEN
                                SELECT
                                    'N'
                                    INTO var_demo_changed;
                            ELSE
                                SELECT
                                    'Y'
                                    INTO var_demo_changed;
                            END IF;
                            /*
                            else
                            select @demo_changed = "N"
                            */
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                'N'
                                INTO var_demo_changed;
                        END;
                    END IF;

                    -- IF (par_document_flag IS NULL OR par_document_flag = 'Z') AND par_source_system <> 'PBRC' THEN
                    IF (par_document_flag IS NULL OR par_document_flag = 'Z') THEN
                        SELECT
                            var_old_document_flag
                            INTO par_document_flag;
                    END IF;
                    /* check document type changed */
                    IF (var_old_document_flag <> par_document_flag) AND par_source_system <> 'PBRC' THEN
                        BEGIN
                            SELECT
                                'Y'
                                INTO var_demo_changed;
                        END;
                    END IF;
                    SELECT
                        timestamp_convert(localtimestamp)
                        INTO var_system_dtm;
                    /* Patient exists */
                    IF var_demo_changed = 'Y' THEN
                        BEGIN
                            /* Get chinese name from ccc_big5 table */
                            CALL cpi_get_phonetic_chin_name(var_return_code, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_tmp_phonetic, var_chi_name);
                            /* 2006-12-11 Addeded by HK Fong SMR20015887 - Start */
                            IF COALESCE(var_chi_name, '') <> '' THEN
                                BEGIN
                                    CALL hkpmi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => var_old_cccode1, par_ccc2 => var_old_cccode2, par_ccc3 => var_old_cccode3, par_ccc4 => var_old_cccode4, par_ccc5 => var_old_cccode5, par_ccc6 => var_old_cccode6, par_is_schi_name => var_is_schi_name);

                                    IF var_is_schi_name = 'Y' THEN
                                        SELECT
                                            NULL
                                            INTO var_chi_name;
                                    END IF;
                                END;
                            END IF;
                            /* 2006-12-11 Addeded by HK Fong SMR20015887 - End */
                            /* get patient nok information */
                            SELECT
                                nok_name, hkid, priority, relationship, phone1, phone2, address_indicator, mobile_phone, sms_language, district, building, room, floor, block
                                INTO var_old_nok_name, var_old_nok_hkid, var_old_nok_priority, var_old_nok_relationship, var_old_nok_phone1, var_old_nok_phone2, var_old_nok_address_indicator, var_old_nok_mobile_phone, var_old_nok_sms_language, var_old_nok_district, var_old_nok_building, var_old_nok_room, var_old_nok_floor, var_old_nok_block
                                FROM nok
                                WHERE patient_key = par_patient_key AND major_nok = var_major_nok;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF sql$rowcount = 0 THEN
                                BEGIN
                                    SELECT
                                        NULL
                                        INTO var_major_nok;
                                END;
                            END IF;
                            /* update patient information */
                            IF var_old_source_system_dtm > par_source_system_dtm THEN
                                BEGIN
                                    /* Patient's last_source_system_dtm is later than */
                                    /* upload's source_system_dtm. */
                                    SELECT
                                        200013
                                        INTO var_return_error_code;
                                    EXIT return_error;
                                END;
                            END IF;
                            /* YL: Preserve the filler */
                            SELECT
                                CONCAT(COALESCE(par_document_flag, REPEAT(' ', 1)), SUBSTRING(var_old_filler, 2, 30))
                                INTO var_update_filler;

                            IF RTRIM(LTRIM(var_update_filler)) = '' THEN
                                SELECT
                                    NULL
                                    INTO var_update_filler;
                            END IF;
                            /* update patient information */
                            BEGIN
                                UPDATE patient
                                SET patient_type = par_patient_type, update_hospital = par_hospital_code, source_system = par_source_system, update_by = par_update_by, source_system_dtm = par_source_system_dtm, system_dtm = var_system_dtm, filler = var_update_filler
                                    WHERE patient_key = par_patient_key AND row_update_datetime = var_old_timestamp;
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
            END IF;
            /* update pmi_case */
            IF par_old_specialty_code IS NULL AND par_old_ward_code IS NULL AND par_old_ward_class IS NULL THEN
                BEGIN
                    SELECT
                        var_case_adm_specialty_code, var_case_adm_ward_code, var_case_adm_ward_class
                        INTO par_adm_specialty_code, par_adm_ward_code, par_adm_ward_class;
                END;
            ELSE
                BEGIN
                    /* if old ward, specialty, class found */
                    /*
                    both adm and last ward, specialty, class needed to be
                    updated
                    */
                    SELECT
                        par_adm_specialty_code, par_adm_ward_code, par_adm_ward_class
                        INTO var_case_last_specialty_code, var_case_last_ward_code, var_case_last_ward_class;
                END;
            END IF;
            /*
            *	20020726 SL: eh_code - filler(2,8) -
            *   format pmi_case.filler &transaction_log.filler
            *	pmi_case_filler(2,8)		=eh_code
            *	tran_log_filler(2,8)		=eh_code
            *	tran_log_filler(1,1)		=document_flag
            *
            * NOTE: pmi_case.filler include eh_code ONLY now..
            * if More field included, need to rewrite to ensure the other info in pmi_case.filler will not be overwrite
            */
            IF RTRIM(LTRIM(var_old_pmi_case_filler)) is NULL THEN
                BEGIN
                    SELECT
                        NULL
                        INTO var_old_pmi_case_filler;
                    SELECT
                        NULL
                        INTO var_old_eh_code;
                END;
            ELSE
                BEGIN
                    SELECT
                        SUBSTRING(var_old_pmi_case_filler, 2, 8)
                        INTO var_old_eh_code;

                    IF RTRIM(LTRIM(var_old_eh_code)) is NULL THEN
                        SELECT
                            NULL
                            INTO var_old_eh_code;
                    ELSE
                        IF par_source_system = 'PBRC' AND RTRIM(LTRIM(par_eh_code)) IS NULL THEN
                            SELECT
                                var_old_eh_code
                                INTO par_eh_code;
                        END IF;
                    END IF;
                END;
            END IF;

            IF RTRIM(LTRIM(var_old_document_flag)) is NULL THEN
                SELECT
                    NULL
                    INTO var_old_document_flag;
            END IF;

            IF RTRIM(LTRIM(par_eh_code)) is NULL OR RTRIM(LTRIM(par_eh_code)) = '' THEN
                SELECT
                    NULL
                    INTO par_eh_code;
            END IF;
            /* format pmi_case_filler */
            IF (par_eh_code != var_old_eh_code) THEN
                IF (par_eh_code is NULL) THEN
                    SELECT
                        NULL
                        INTO var_pmi_case_filler;
                ELSE
                    SELECT
                        CONCAT(REPEAT(' ', 1), par_eh_code)
                        INTO var_pmi_case_filler;
                END IF;
            ELSE
                SELECT
                    var_old_pmi_case_filler
                    INTO var_pmi_case_filler;
            END IF;
            /* format tran_log_filler */
            /*
            if (@eh_code=null)
            begin
            	if (@document_flag =null)
            		select @tran_log_filler=null
            	else
            		select @tran_log_filler=@document_flag
            end
            else
            begin
            	if (@document_flag =null)
            		select @tran_log_filler=space(1)+@eh_code
            	else
            		select @tran_log_filler=@document_flag+@eh_code
            end
            */
            /* === END : format/update pmi_case.filler &transaction_log.filler */
            /* 20070331 SL Tx=100/300/121/341 : source_hosp_code = tran_log.filler(12,3), source_case_no=tran_log.filler(15,12) */
            SELECT
                CONCAT(SUBSTRING(CONCAT(par_document_flag, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(par_eh_code, REPEAT(' ', 8)), 1, 8), REPEAT(' ', 2), SUBSTRING(CONCAT(par_source_hosp_code, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(par_source_case_no, REPEAT(' ', 12)), 1, 12))
                INTO var_tran_log_filler;

            IF (LTRIM(RTRIM(var_tran_log_filler)) = '') OR (LTRIM(RTRIM(var_tran_log_filler)) is NULL) THEN
                SELECT
                    NULL
                    INTO var_tran_log_filler;
            END IF;
            /* ---20130515 -------- */
            SELECT
                CONCAT(SUBSTRING(CONCAT(par_document_flag, REPEAT(' ', 1)), 1, 1), SUBSTRING(CONCAT(par_eh_code, REPEAT(' ', 8)), 1, 8), REPEAT(' ', 2), SUBSTRING(CONCAT(par_source_hosp_code, REPEAT(' ', 3)), 1, 3), SUBSTRING(CONCAT(par_source_case_no, REPEAT(' ', 12)), 1, 12), REPEAT(' ', 3), SUBSTRING(CONCAT(var_old_hkic_symbol, REPEAT(' ', 1)), 1, 1))
                INTO var_tran_log_filler_030;

            IF (LTRIM(RTRIM(var_tran_log_filler_030)) = '') OR (LTRIM(RTRIM(var_tran_log_filler_030)) is NULL) THEN
                SELECT
                    NULL
                    INTO var_tran_log_filler_030;
            END IF;
            /* *************20070331 SL****************** */
            BEGIN
                UPDATE pmi_case
                SET adm_dtm = par_adm_dtm, patient_type = par_patient_type, adm_specialty_code = par_adm_specialty_code, adm_ward_code = par_adm_ward_code, adm_ward_class = par_adm_ward_class, last_specialty_code = var_case_last_specialty_code, last_ward_code = var_case_last_ward_code, last_ward_class = var_case_last_ward_class, source_indicator = par_source_indicator, source_code = par_source_code, pp_code = par_pp_code, update_by = par_update_by, source_system = par_source_system, source_system_dtm = par_source_system_dtm, filler = var_pmi_case_filler
                    WHERE case_no = par_case_no AND hospital_code = par_hospital_code AND row_update_datetime = var_case_old_timestamp;
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
                    /* Case not found or Case has been updated between */
                    /* retrieved and update." */
                    SELECT
                        200127
                        INTO var_return_error_code;
                    EXIT return_error;
                END;
            END IF;
            /* update AE case detail */
            /* --	if @case_case_type = "A" */
            /* no update to ae_case_detail if updated by PBRC */
            IF var_case_case_type = 'A' AND par_source_system <> 'PBRC' THEN
                BEGIN
                    BEGIN
                        UPDATE ae_case_detail
                        SET ambulance_no = par_ambulance_no, police_case = par_police_case, labour_case = par_labour_case, ae_case_type = par_ae_case_type, dba = par_dba
                            WHERE case_no = par_case_no::VARCHAR AND hospital_code = par_hospital_code::VARCHAR;
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
                            /*
                            ae case detail may not exists for update
                            insert will perform if one of the field
                            is not null
                            */
                            IF par_ambulance_no IS NOT NULL OR par_police_case IS NOT NULL OR par_labour_case IS NOT NULL OR par_ae_case_type IS NOT NULL OR par_dba IS NOT NULL THEN
                                BEGIN
                                    BEGIN
                                        INSERT INTO ae_case_detail (hospital_code, case_no, ambulance_no, police_case, labour_case, ae_case_type, dba)
                                        VALUES (par_hospital_code, par_case_no, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba);
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
                        END;
                    END IF;
                END;
            END IF;
            /* ***************20070329 SL hkpmi_linked_case ********************** */
            /* ---local cpi_update_adm_registration already updated cpi_filler (linked case info) for OPAS/PBRC---- */
            /* ---if @source_system ='ADT' */
            IF var_case_case_type IN ('A', 'I') THEN
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
                    /* --- insert / update mode --- */

                    IF (par_source_hosp_code IS NOT NULL) AND (par_source_case_no IS NOT NULL) THEN
                        BEGIN
                            SELECT
                                NULL, NULL
                                INTO var_old_source_hosp_code, var_old_source_case_no;
                            SELECT
                                previous_hospital, previous_case
                                INTO var_old_source_hosp_code, var_old_source_case_no
                                FROM hkpmi_linked_case
                                WHERE hospital_code = par_hospital_code::VARCHAR AND case_no = par_case_no::VARCHAR;
                            /* Validate the Linked case if the source case changed for Insert/Update */
                            IF (par_source_hosp_code <> var_old_source_hosp_code) OR (par_source_case_no <> var_old_source_case_no) THEN
                                BEGIN
                                    /* Check the input Source_case belong to same patient or not */
                                    /* NOTE: No checking in cpi_update_adm_reg : may cause cpi_upload problem */
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
                                    END IF;
                                END;
                            END IF; /* END of : Validate the Linked case if the source case changed for Insert/Update */
                            /* -----insert mode ---------- */
                            IF NOT EXISTS (SELECT
                                *
                                FROM hkpmi_linked_case
                                WHERE hospital_code = par_hospital_code::VARCHAR AND case_no = par_case_no::VARCHAR) THEN
                                BEGIN
                                    BEGIN
                                        INSERT INTO hkpmi_linked_case (hospital_code, case_no, previous_hospital, previous_case, create_by, create_dtm, update_by, update_dtm)
                                        VALUES (par_hospital_code, par_case_no, par_source_hosp_code, par_source_case_no, par_update_by, par_source_system_dtm, par_update_by, par_source_system_dtm);
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
                                                200038
                                                INTO var_return_error_code;
                                            EXIT return_system_error;
                                        END;
                                    END IF;
                                END;
                            /* -----update mode ---------- */
                            ELSE
                                BEGIN
                                    IF (par_source_hosp_code <> var_old_source_hosp_code) OR (par_source_case_no <> var_old_source_case_no) THEN
                                        BEGIN
                                            BEGIN
                                                UPDATE hkpmi_linked_case
                                                SET previous_hospital = par_source_hosp_code, previous_case = par_source_case_no, update_by = par_update_by, update_dtm = par_source_system_dtm
                                                    WHERE hospital_code = par_hospital_code::VARCHAR AND case_no = par_case_no::VARCHAR;
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
                                                        200038
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
                        /* --- delete mode --- */
                        BEGIN
                            IF EXISTS (SELECT
                                *
                                FROM hkpmi_linked_case
                                WHERE hospital_code = par_hospital_code::VARCHAR AND case_no = par_case_no::VARCHAR) THEN
                                BEGIN
                                    BEGIN
                                        DELETE FROM hkpmi_linked_case
                                            WHERE hospital_code = par_hospital_code::VARCHAR AND case_no = par_case_no::VARCHAR;
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
                                                200038
                                                INTO var_return_error_code;
                                            EXIT return_system_error;
                                        END;
                                    END IF;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
            /* ***************** 20070329 SL ***************************** */
            /* insert transaction_log for admission */
            SELECT
                'P'
                INTO var_upload_status;
            SELECT
                var_system_dtm
                INTO var_tran_system_dtm;
            /*
            since the PBRC upload may not contain adm_spec and some old
            data do not have adm_spec, the transaction may contain null
            adm spec in 121.
            */
            IF NOT (par_source_system = 'PBRC' AND par_adm_specialty_code IS NULL) THEN
                BEGIN
                    WHILE 1 = 1 LOOP
                        BEGIN
                            INSERT INTO download.transaction_log (system_dtm, hospital_code, type, adm_dtm, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, religion,
                            /* case information */
                            case_no, source_indicator, source_code, patient_type, case_type, pp_code, ambulance_no, police_case, labour_case, ae_case_type, dba, ward_code, specialty_code, ward_class, old_ward_code, old_specialty_code, old_ward_class, update_by, update_hospital, source_system, source_system_dtm, upload_status, filler)
                            VALUES (var_tran_system_dtm, par_hospital_code, par_txn_type, par_adm_dtm, par_hkid, par_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_chi_name, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_religion,
                            /* case information */
                            par_case_no, par_source_indicator, par_source_code, par_patient_type, var_case_case_type, par_pp_code, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba, par_adm_ward_code, par_adm_specialty_code, par_adm_ward_class, par_old_ward_code, par_old_specialty_code, par_old_ward_class, par_update_by, par_hospital_code, par_source_system, par_source_system_dtm, var_upload_status, /* @document_flag */ var_tran_log_filler);
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
                    END LOOP /* end insert transaction_log from admission */;
                END;
            END IF; /* check PBRC and adm_spec_code */
            /* ---------------------------------------------------------- */
            /* --- to indicate the 121/update adm without Movment history */
            /* ---20130108 -- hkpmi_pas_bar_ind  : transaction_log.system_dtm == hkpmi_pas_bar_ind.system_dtm */
            /* --- for HN case only  (OP case need A/O type as well according to PBRC support )-- */
            
            /* ------------------------------------- */
            IF par_txn_type = '121' AND var_case_movement_count = 1 THEN /* ----and @case_case_type ='I' */
                BEGIN
                    SELECT
                        'A'
                        INTO var_txn_type_ind;
                    INSERT INTO hkpmi_pas_bar_ind (hospital_code, system_dtm, txn_type, hkid, patient_key, case_no, txn_type_ind)
                    VALUES (par_hospital_code, var_tran_system_dtm, par_txn_type, par_hkid, par_patient_key, par_case_no, var_txn_type_ind);

                    IF var_error != 0 THEN
                        BEGIN
                            /* Fail to insert */
                            SELECT
                                var_error
                                INTO var_return_error_code;
                            EXIT return_system_error;
                        END;
                    END IF;
                END;
            END IF;
            /* ---------------------------------------------------------------- */
            /* insert transaction_log for demo updated */
            IF var_demo_changed = 'Y' THEN
                BEGIN
                    SELECT
                        '030'
                        INTO par_txn_type;
                    OPEN hosp_cursor;
                    FETCH hosp_cursor INTO var_tmp_hospital_code;
                    select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                    SELECT
                        'N', var_system_dtm
                        INTO var_process_local_hospital, var_tran_system_dtm;

                    WHILE (found_code = 0 OR var_process_local_hospital = 'N') LOOP
                        SELECT
                            3 * INTERVAL '1 millisecond' + var_tran_system_dtm::TIMESTAMP
                            INTO var_tran_system_dtm;

                        IF var_process_local_hospital = 'N' THEN
                            BEGIN
                                SELECT
                                    par_case_no
                                    INTO var_tmp_case_no;
                                SELECT
                                    var_mrn
                                    INTO var_temp_mrn;
                                SELECT
                                    par_hospital_code
                                    INTO var_tran_hospital_code;

                                IF par_source_system = 'DNL' THEN
                                    SELECT
                                        'P'
                                        INTO var_upload_status;
                                ELSE
                                    SELECT
                                        'Y'
                                        INTO var_upload_status;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                SELECT
                                    NULL
                                    INTO var_tmp_case_no;
                                SELECT
                                    NULL
                                    INTO var_temp_mrn;
                                SELECT
                                    var_tmp_hospital_code, 'P'
                                    INTO var_tran_hospital_code, var_upload_status;
                            END;
                        END IF;

                        WHILE 1 = 1 LOOP
                            BEGIN
                                INSERT INTO download.transaction_log (system_dtm, hospital_code, type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, priority, major_nok, nok_name, nok_hkid, nok_relationship, nok_building, nok_room, nok_floor, nok_block, nok_district, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, old_hkid, patient_type, old_patient_key, old_patient_name, old_sex, old_dob, mrn, case_no, update_by, source_system, source_system_dtm, update_hospital, upload_status, filler)
                                VALUES (var_tran_system_dtm, var_tran_hospital_code, par_txn_type, par_hkid, par_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_old_exact_dob_flag, var_old_cccode1, var_old_cccode2, var_old_cccode3, var_old_cccode4, var_old_cccode5, var_old_cccode6, var_chi_name, var_old_marital_status, var_old_race, var_old_other_doc_no, var_old_building, var_old_room, var_old_floor, var_old_block, var_old_district, var_old_religion, var_old_phone1, var_old_phone2, var_old_address_indicator, var_old_mobile_phone, var_old_sms_language, var_old_nok_priority, var_major_nok, var_old_nok_name, var_old_nok_hkid, var_old_nok_relationship, var_old_nok_building, var_old_nok_room, var_old_nok_floor, var_old_nok_block, var_old_nok_district, var_old_nok_phone1, var_old_nok_phone2, var_old_nok_address_indicator, var_old_nok_mobile_phone, var_old_nok_sms_language, par_hkid, par_patient_type, par_patient_key, var_old_patient_name, var_old_sex, var_old_dob, var_temp_mrn, var_tmp_case_no, par_update_by, par_source_system, par_source_system_dtm, par_hospital_code, var_upload_status, /* @document_flag */
                                /* ---@tran_log_filler */
                                var_tran_log_filler_030);
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

                        IF var_process_local_hospital = 'N' THEN
                            BEGIN
                                SELECT
                                    'Y'
                                    INTO var_process_local_hospital;
                            END;
                        ELSE
                            BEGIN
                                FETCH hosp_cursor INTO var_tmp_hospital_code;
                                select case WHEN FOUND THEN 0 WHEN NOT FOUND THEN 2 ELSE 1 end into found_code;
                            END;
                        END IF;
                    END LOOP;
                END;
            END IF; /* end insert transaction_log from demo updated */
            /* 20050720 - LSCHU update for mother_baby_case table */
            IF var_case_case_type IN ('I', 'A') THEN
                BEGIN
                    CALL hkpmi_check_mother_baby_case(pas_return_code, par_hospital_code, par_patient_key, par_source_system_dtm, par_update_by, par_source_system, var_error);

                    IF var_error <> 0 THEN
                        BEGIN
                            SELECT
                                var_error
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
END; /* end the procedure */
$procedure$
;


ALTER PROCEDURE "hkpmi_update_admission" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
