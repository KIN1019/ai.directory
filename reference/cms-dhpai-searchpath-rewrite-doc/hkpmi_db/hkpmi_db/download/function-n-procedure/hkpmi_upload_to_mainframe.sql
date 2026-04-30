-- DROP FUNCTION download.hkpmi_upload_to_mainframe();

CREATE OR REPLACE FUNCTION download.hkpmi_upload_to_mainframe()
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    p_refcur refcursor;
    var_upload_enable VARCHAR(02);
    var_rpc_name VARCHAR(16);
    var_gateway_id VARCHAR(16);
    var_cics_id VARCHAR(16);
    var_adt_cics_id VARCHAR(16);
    var_gateway_cics VARCHAR(38);
    var_syup_gateway_cics VARCHAR(38);
    "var_RU_flag" INTEGER;
    var_return_code INTEGER;
    var_failure_code INTEGER;
    var_org_type VARCHAR(6);
    var_system_date VARCHAR(16);
    var_system_time VARCHAR(08);
    var_type VARCHAR(06);
    var_case_no VARCHAR(24);
    var_hkid VARCHAR(24);
    var_patient_name VARCHAR(96);
    var_sex VARCHAR(02);
    var_dob VARCHAR(16);
    var_dob_exact_flag VARCHAR(02);
    var_marital_status VARCHAR(02);
    var_patient_type VARCHAR(06);
    var_nationality VARCHAR(04);
    var_other_docu_no VARCHAR(24);
    var_address_room VARCHAR(10);
    var_address_floor VARCHAR(04);
    var_address_block VARCHAR(04);
    var_address_building VARCHAR(74);
    var_address_dist VARCHAR(30);
    var_address_area VARCHAR(02);
    var_phone VARCHAR(20);
    var_t_prk VARCHAR(16);
    var_nok_name VARCHAR(96);
    var_nok_hkid VARCHAR(24);
    var_nok_relation VARCHAR(06);
    var_nok_address_room VARCHAR(10);
    var_nok_address_floor VARCHAR(04);
    var_nok_address_block VARCHAR(04);
    var_nok_address_building VARCHAR(74);
    var_nok_address_dist VARCHAR(30);
    var_nok_address_area VARCHAR(02);
    var_nok_phone VARCHAR(20);
    var_nok_bus_phone VARCHAR(20);
    var_nok_bus_phone_ext VARCHAR(08);
    var_adm_date VARCHAR(16);
    var_adm_time VARCHAR(08);
    var_source_indicator VARCHAR(02);
    var_source_code VARCHAR(06);
    var_dis_date VARCHAR(16);
    var_dis_time VARCHAR(08);
    var_ae_case_type VARCHAR(02);
    var_ae_labour_case VARCHAR(02);
    var_ae_ambulance VARCHAR(08);
    var_ae_police VARCHAR(02);
    var_cccode1 VARCHAR(10);
    var_cccode2 VARCHAR(10);
    var_cccode3 VARCHAR(10);
    var_cccode4 VARCHAR(10);
    var_cccode5 VARCHAR(10);
    var_cccode6 VARCHAR(10);
    var_mrn VARCHAR(16);
    var_religion VARCHAR(06);
    var_old_patient_name VARCHAR(96);
    var_old_sex VARCHAR(02);
    var_old_dob VARCHAR(16);
    var_old_hkid VARCHAR(24);
    var_old_ward_code VARCHAR(08);
    var_old_bed_no VARCHAR(10);
    var_old_specialty_code VARCHAR(08);
    var_old_ward_class VARCHAR(02);
    var_tmp_ward_code VARCHAR(08);
    var_tmp_bed_no VARCHAR(10);
    var_tmp_specialty_code VARCHAR(08);
    var_tmp_ward_class VARCHAR(2);
    var_ward_code VARCHAR(8);
    var_bed_no VARCHAR(10);
    var_specialty_code VARCHAR(8);
    var_ward_class VARCHAR(2);
    var_discharge_code VARCHAR(2);
    var_destination_code VARCHAR(10);
    var_case_type VARCHAR(2);
    var_user_id VARCHAR(16);
    var_db_id VARCHAR(2);
    var_provider_id VARCHAR(6);
    var_hosp_code VARCHAR(6);
    var_doctor_code VARCHAR(16);
    var_security_count INTEGER;
    var_pmi_access_code INTEGER;
    var_dba_flag VARCHAR(2);
    var_death_indicator VARCHAR(8);
    var_mrt_indicator VARCHAR(2);
    var_comm_parm1 VARCHAR(510);
    var_comm_parm2 VARCHAR(510);
    var_comm_parm3 VARCHAR(510);
    var_comm_parm4 VARCHAR(510);
    var_host_parm VARCHAR(510);
    var_ws_adm_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_dis_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_tr_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_death_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_dob_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_old_dob_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_time_colon VARCHAR(16);
    var_ws_event_type VARCHAR(4);
    var_ws_log VARCHAR(140);
    var_ws_org_hkid VARCHAR(24);
    var_ws_temp_hkid VARCHAR(24);
    var_ws_org_old_hkid VARCHAR(24);
    var_cnt INTEGER;
    var_stop_upload VARCHAR(2);
    var_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_source_system VARCHAR(10);
    var_office_phone VARCHAR(20);
    var_office_ext VARCHAR(8);
    var_update_date VARCHAR(16);
    var_update_time VARCHAR(12);
    var_upload_errmsg VARCHAR(100);
    var_reg_parm1 VARCHAR(456);
    var_reg_parm2 VARCHAR(440);
    var_check_patient_key VARCHAR(02);
    var_error_msg VARCHAR(510);
    var_comm_tran_date VARCHAR(16);
    var_comm_tran_time VARCHAR(12);
    var_comm_sys_date VARCHAR(16);
    var_comm_sys_time VARCHAR(12);
    sql$rowcount BIGINT;
    hkpmi_check_patient_key$refcur_1 refcursor;
    pas_return_code INTEGER;
BEGIN
    /* --- Instance variables for host interface --- */ 
    /* * add mrt indicator ** */
    /* --- Variables for formulating parameters --- */
    /* --- Working variables --- */
    /* ---------------------------------------------------------- */
    SELECT
        'N'
        INTO var_stop_upload;

    WHILE (var_stop_upload = 'N') LOOP
        <<next_record>>
        BEGIN
            <<check_patient_key>>
            BEGIN
                <<process_ops_upload>>
                BEGIN
                    <<process_adt_upload>>
                    BEGIN
                        SELECT
                            COUNT(*)
                            INTO var_cnt
                            FROM upload_control
                            WHERE upload_enable = 'N';

                        IF (var_cnt > 0) THEN
                            BEGIN
                                RAISE NOTICE 'Upload process is disable!!!';
                                EXIT;
                            END;
                        END IF;

                        SELECT
                            system_dtm, source_system, hospital_code
                            INTO var_ws_system_datetime, var_source_system, var_hosp_code
                            FROM transaction_log
                            WHERE upload_status = 'Y'
                            LIMIT 1;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_cnt := sql$rowcount;

                        IF var_cnt = 0 THEN
                            BEGIN /* nothing in transaction_log, wait */
                                CONTINUE;
                            END;
                        END IF;
                        /* --- Get Gateway info --- */

                        IF (var_source_system != 'ADT') AND (var_source_system != 'LRRDT') AND (var_source_system != 'PBRC') AND (var_source_system != 'OPAS') AND (var_source_system != 'OPAS2') THEN
                            BEGIN
                                UPDATE transaction_log
                                SET upload_status = 'P'
                                    WHERE system_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                                /* --www if @@error != 0 or @@rowcount != 1 */
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount != 1 THEN
                                    INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                    VALUES (var_hosp_code, var_ws_system_datetime, 'Update Transaction_log error', var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                                END IF;
                                SELECT
                                    CONCAT(var_source_system, ' ', var_type, ' ', var_hkid)
                                    INTO var_ws_log;
                                RAISE NOTICE 'DNL CASE: %', var_ws_log;
                                CONTINUE;
                            END;
                        END IF;
                        /* get the @adt_cics_id for gobal use */
                        SELECT
                            adt_cics_id, check_patient_key
                            INTO var_adt_cics_id, var_check_patient_key
                            FROM upload_control
                            WHERE hospital_code = var_hosp_code;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_cnt := sql$rowcount;

                        IF var_cnt != 1 THEN
                            BEGIN
                                RAISE NOTICE 'Error in getting info. from upload_control %', var_hosp_code;
                                RETURN;
                            END;
                        END IF;

                        IF (var_source_system = 'ADT') OR (var_source_system = 'LRRDT') OR (var_source_system = 'PBRC') THEN
                            BEGIN
                                SELECT
                                    provider_id, gateway_id, adt_cics_id, upload_enable
                                    INTO var_provider_id, var_gateway_id, var_cics_id, var_upload_enable
                                    FROM upload_control
                                    WHERE hospital_code = var_hosp_code;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount != 1 THEN
                                    BEGIN
                                        RAISE NOTICE 'Each hospital can only have one upload control';
                                        EXIT;
                                    END;
                                END IF;
                                SELECT
                                    SUBSTRING(var_provider_id, 1, 1)
                                    INTO var_db_id;
                                SELECT
                                    CONCAT(RTRIM(var_gateway_id), '...', RTRIM(var_cics_id))
                                    INTO var_gateway_cics;
                                SELECT
                                    CONCAT(RTRIM(var_gateway_id), '...SYUP', RIGHT(RTRIM(var_cics_id), 4))
                                    INTO var_syup_gateway_cics;
                                EXIT process_adt_upload;
                            END;
                        ELSE
                            BEGIN
                                /* OPAS Cases */
                                SELECT
                                    provider_id, gateway_id, ops_cics_id, upload_enable
                                    INTO var_provider_id, var_gateway_id, var_cics_id, var_upload_enable
                                    FROM upload_control
                                    WHERE hospital_code = var_hosp_code;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount != 1 THEN
                                    BEGIN
                                        RAISE NOTICE 'Each hospital can only have one upload control';
                                        EXIT;
                                    END;
                                END IF;
                                SELECT
                                    SUBSTRING(var_provider_id, 1, 1)
                                    INTO var_db_id;
                                SELECT
                                    CONCAT(RTRIM(var_gateway_id), '...', RTRIM(var_cics_id))
                                    INTO var_gateway_cics;
                                EXIT process_ops_upload;
                            END;
                        END IF;
                        /* End if (@source_system = "ADT" or "LRRDT" or "PBRC") */
                        /* ---------------------------------------------------------- */
                    END;

                    <<check_status>>
                    BEGIN
                        <<common_upload>>
                        BEGIN
                            IF (var_upload_enable = 'N') THEN
                                CONTINUE;
                            END IF;
                            SELECT
                                type, hkid, patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, marital_status, race, other_doc_no, mrn, building, room, floor, block, CONCAT(COALESCE(CAST (district AS CHAR(5)), REPEAT(' ', 5)), SUBSTRING(building, 38, 10)), religion, phone1, patient_key, nok_name, nok_hkid, nok_relationship, nok_room, nok_floor, nok_block, nok_building, CONCAT(COALESCE(CAST (nok_district AS CHAR(5)), REPEAT(' ', 5)), SUBSTRING(nok_building, 38, 10)), nok_phone1, nok_phone2, nok_address_indicator, source_system_dtm,
                                /*
                                19980709 - case no need not be upload, only demo information is
                                required by MF
                                */
                                NULL, adm_dtm, source_indicator, source_code, patient_type, discharge_code, discharge_dtm, transfer_dtm, death_date, destination_code, NULL, labour_case, police_case, ambulance_no, ae_case_type, ward_code, specialty_code, bed_no, ward_class, old_patient_name, old_hkid, old_sex, old_dob, old_ward_code, old_bed_no, old_specialty_code, old_ward_class, update_by, doctor_code, security_count, pmi_access_code, dba, death_indicator, mrt_indicator
                                INTO var_type, var_hkid, var_patient_name, var_sex, var_ws_dob_datetime, var_dob_exact_flag, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_marital_status, var_nationality, var_other_docu_no, var_mrn, var_address_building, var_address_room, var_address_floor, var_address_block, var_address_dist, var_religion, var_phone, var_t_prk, var_nok_name, var_nok_hkid, var_nok_relation, var_nok_address_room, var_nok_address_floor, var_nok_address_block, var_nok_address_building, var_nok_address_dist, var_nok_phone, var_nok_bus_phone, var_nok_bus_phone_ext, var_source_system_dtm, var_case_no, var_ws_adm_datetime, var_source_indicator, var_source_code, var_patient_type, var_discharge_code, var_ws_dis_datetime, var_ws_tr_datetime, var_ws_death_datetime, var_destination_code, var_case_type, var_ae_labour_case, var_ae_police, var_ae_ambulance, var_ae_case_type, var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_old_patient_name, var_old_hkid, var_old_sex, var_ws_old_dob_datetime, var_old_ward_code, var_old_bed_no, var_old_specialty_code, var_old_ward_class, var_user_id, var_doctor_code, var_security_count, var_pmi_access_code, var_dba_flag, var_death_indicator, var_mrt_indicator
                                FROM transaction_log
                                WHERE hospital_code = var_hosp_code AND system_dtm = var_ws_system_datetime;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF sql$rowcount != 1 THEN
                                BEGIN
                                    RAISE NOTICE 'Error - Retrieving from transaction_log';
                                    INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                    VALUES (var_hosp_code, var_ws_system_datetime, 'Error - Retrieving from transaction_log', var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                                    CONTINUE;
                                END;
                            END IF;
                            SELECT
                                REPEAT(' ', 8)
                                INTO var_rpc_name;
                            SELECT
                                CONCAT(var_user_id, REPEAT(' ', 8))
                                INTO var_user_id;
                            SELECT
                                var_hkid
                                INTO var_ws_org_hkid;
                            SELECT
                                var_old_hkid
                                INTO var_ws_org_old_hkid;
                            SELECT
                                SUBSTRING(CONCAT(LTRIM(var_hkid), REPEAT(' ', 12)), 1, 12)
                                INTO var_hkid;
                            SELECT
                                SUBSTRING(CONCAT(LTRIM(var_old_hkid), REPEAT(' ', 12)), 1, 12)
                                INTO var_old_hkid;
                            SELECT
                                to_char(var_ws_dob_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                INTO var_dob;
                            SELECT
                                SUBSTRING(var_type, 1, 2)
                                INTO var_ws_event_type;
                            SELECT
                                to_char(var_ws_system_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                INTO var_comm_sys_date;
                            SELECT
                                to_char(var_ws_system_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                INTO var_ws_time_colon;
                            SELECT
                                CONCAT(SUBSTRING(var_ws_time_colon, 1, 2), SUBSTRING(var_ws_time_colon, 4, 2), SUBSTRING(var_ws_time_colon, 7, 2))
                                INTO var_comm_sys_time;
                            SELECT
                                var_comm_sys_date
                                INTO var_comm_tran_date;
                            SELECT
                                var_comm_sys_time
                                INTO var_comm_tran_time;
                            /* Get update address area for these update processes. */
                            IF var_type IN ('010', '030', '031', '034', '100', '300') THEN
                                BEGIN
                                    SELECT
                                        district_area
                                        INTO var_address_area
                                        FROM hkpmi_dbo.district
                                        WHERE district_code = var_address_dist;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount != 1 THEN
                                        SELECT
                                            NULL
                                            INTO var_address_area;
                                    END IF;
                                    SELECT
                                        district_area
                                        INTO var_nok_address_area
                                        FROM hkpmi_dbo.district
                                        WHERE district_code = var_nok_address_dist;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount != 1 THEN
                                        SELECT
                                            NULL
                                            INTO var_nok_address_area;
                                    END IF;
                                END;
                            END IF;
                            /* check the suspend_upload_log for previous error */
                            IF EXISTS (SELECT
                                *
                                FROM suspend_upload_log
                                WHERE (COALESCE(hkid, 'CUR') = COALESCE(var_ws_org_hkid, 'OLD') OR COALESCE(hkid, 'CUR') = COALESCE(var_ws_org_old_hkid, 'OLD') OR COALESCE(old_hkid, 'CUR') = COALESCE(var_ws_org_old_hkid, 'OLD') OR COALESCE(old_hkid, 'CUR') = COALESCE(var_ws_org_hkid, 'OLD')) AND (transaction_dtm < var_ws_system_datetime)) THEN
                                BEGIN
                                    SELECT
                                        CONCAT(var_type, ' ', var_case_no, ' ', var_hkid, ' ', var_ward_code, ' ', var_specialty_code, ' ', var_adm_date, ' ', var_adm_time)
                                        INTO var_ws_log;
                                    RAISE NOTICE 'PREV-FAIL: %', var_ws_log;
                                    SELECT
                                        999
                                        INTO var_return_code;
                                    EXIT check_status;
                                END;
                            /* --- Type 100 & 300: In-patient and A&E Registration --- */
                            ELSE
                                IF (var_type = '100') OR (var_type = '300') THEN
                                    BEGIN
                                        CALL hkpmi_check_hkid(pas_return_code, var_hosp_code, var_hkid, "var_RU_flag");

                                        IF "var_RU_flag" = 1 THEN
                                            BEGIN
                                                SELECT
                                                    '010'
                                                    INTO var_type; /* PMI Reg. */
                                                SELECT
                                                    CONCAT(var_hkid, ' ', CAST (var_patient_name AS CHAR(20)), ' ', var_sex, ' ', var_dob, ' (PMI Reg)')
                                                    INTO var_ws_log;
                                            END;
                                        ELSE
                                            BEGIN
                                                SELECT
                                                    '030'
                                                    INTO var_type; /* Update Demo. */
                                                SELECT
                                                    CONCAT(var_old_hkid, ' ', var_hkid, ' ', SUBSTRING(var_patient_name, 1, 24), ' ', var_dob, ' ', var_sex, ' (Demo Upd)')
                                                    INTO var_ws_log;
                                            END;
                                        END IF; /* End of if @RU_flag = 0 */
                                        RAISE NOTICE 'Adm/REG: %', var_ws_log;
                                        EXIT common_upload;
                                    END;
                                /* --- Type 010 : PMI Registration --- */
                                ELSE
                                    IF var_type = '010' THEN
                                        BEGIN
                                            SELECT
                                                SUBSTRING(CONCAT(LTRIM(var_nok_hkid), REPEAT(' ', 12)), 1, 12)
                                                INTO var_nok_hkid;
                                            SELECT
                                                CONCAT(var_hkid, ' ', CAST (var_patient_name AS CHAR(20)), ' ', var_sex, ' ', var_dob)
                                                INTO var_ws_log;
                                            RAISE NOTICE 'PMI REG: %', var_ws_log;
                                            EXIT common_upload;
                                        END;
                                    /* --- Type 030, 031, 034: Demographic data update --- */
                                    
                                    /* includes Update HKID and confidentiality */
                                    ELSE
                                        IF (var_type = '030') OR (var_type = '031') THEN
                                            BEGIN
                                                SELECT
                                                    var_hkid
                                                    INTO var_ws_temp_hkid;
                                                SELECT
                                                    var_old_hkid
                                                    INTO var_hkid;
                                                SELECT
                                                    var_ws_temp_hkid
                                                    INTO var_old_hkid;
                                                SELECT
                                                    CONCAT(var_old_hkid, ' ', var_hkid, ' ', SUBSTRING(var_patient_name, 1, 24), ' ', var_dob, ' ', var_sex)
                                                    INTO var_ws_log;

                                                IF var_type = '031' THEN
                                                    RAISE NOTICE 'Chg HKID: %', var_ws_log;
                                                ELSE
                                                    RAISE NOTICE 'Demo Upd: %', var_ws_log;
                                                END IF;
                                                EXIT common_upload;
                                            END;
                                        ELSE
                                            IF (var_type = '034') THEN
                                                BEGIN
                                                    RAISE NOTICE 'Upd Conf: %, %', var_hkid, var_pmi_access_code;
                                                    EXIT common_upload;
                                                END;
                                            /* --- Type 020: Request to Merge HKID --- */
                                            ELSE
                                                IF (var_type = '020') THEN
                                                    BEGIN
                                                        SELECT
                                                            to_char(var_ws_old_dob_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                                            INTO var_old_dob;
                                                        SELECT
                                                            var_hkid
                                                            INTO var_ws_temp_hkid;
                                                        SELECT
                                                            var_old_hkid
                                                            INTO var_hkid;
                                                        SELECT
                                                            var_ws_temp_hkid
                                                            INTO var_old_hkid;
                                                        SELECT
                                                            CONCAT(var_old_hkid, ' ', var_hkid, ' ', SUBSTRING(var_patient_name, 1, 24), ' ', var_dob, ' ', var_sex)
                                                            INTO var_ws_log;
                                                        RAISE NOTICE 'Merge HKID: %', var_ws_log;
                                                        EXIT common_upload;
                                                    END;
                                                /* --- Type 033: Update Death --- */
                                                ELSE
                                                    IF (var_type = '033') THEN
                                                        BEGIN
                                                            /*
                                                            19981007 - Transaction datetime has to be provided to perform CANCEL
                                                            DEATH transaction, so source_system_dtm is used.
                                                            */
                                                            IF var_death_indicator = NULL THEN
                                                                BEGIN
                                                                    SELECT
                                                                        to_char(var_source_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                                                        INTO var_comm_tran_date;
                                                                    SELECT
                                                                        to_char(var_source_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                                                        INTO var_ws_time_colon;
                                                                    SELECT
                                                                        CONCAT(SUBSTRING(var_ws_time_colon, 1, 2), SUBSTRING(var_ws_time_colon, 4, 2), SUBSTRING(var_ws_time_colon, 7, 2))
                                                                        INTO var_comm_tran_time;
                                                                    SELECT
                                                                        'N'
                                                                        INTO var_discharge_code;
                                                                END;
                                                            ELSE
                                                                BEGIN
                                                                    SELECT
                                                                        to_char(var_ws_death_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                                                        INTO var_comm_tran_date;
                                                                    SELECT
                                                                        to_char(var_ws_death_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                                                        INTO var_ws_time_colon;
                                                                    SELECT
                                                                        CONCAT(SUBSTRING(var_ws_time_colon, 1, 2), SUBSTRING(var_ws_time_colon, 4, 2), SUBSTRING(var_ws_time_colon, 7, 2))
                                                                        INTO var_comm_tran_time;
                                                                    SELECT
                                                                        'Y'
                                                                        INTO var_discharge_code;
                                                                END;
                                                            END IF;
                                                            /*
                                                            19981007 - source_system_dtm is used as system_dtm since some
                                                            server clocks are not synchronous with hkpmi server.
                                                            */
                                                            SELECT
                                                                to_char(var_source_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                                                INTO var_comm_sys_date;
                                                            SELECT
                                                                to_char(var_source_system_dtm::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                                                INTO var_ws_time_colon;
                                                            SELECT
                                                                CONCAT(SUBSTRING(var_ws_time_colon, 1, 2), SUBSTRING(var_ws_time_colon, 4, 2), SUBSTRING(var_ws_time_colon, 7, 2))
                                                                INTO var_comm_sys_time;
                                                            SELECT
                                                                CONCAT(var_hkid, ' ', SUBSTRING(var_patient_name, 1, 24), ' ', var_dob, ' ', var_sex, ' ', var_comm_tran_date, ' ', var_comm_tran_time)
                                                                INTO var_ws_log;
                                                            RAISE NOTICE 'Upd Death: %', var_ws_log;
                                                            EXIT common_upload;
                                                        END;
                                                    /* --- Other types --- */
                                                    ELSE
                                                        BEGIN
                                                            SELECT
                                                                0
                                                                INTO var_return_code;
                                                            SELECT
                                                                '*pass*'
                                                                INTO var_rpc_name;
                                                            RAISE NOTICE 'ADT exception type : % - %, %, %, %', var_type, var_ws_org_hkid, var_hosp_code, var_case_no, var_ws_system_datetime;
                                                            UPDATE transaction_log
                                                            SET upload_status = 'P'
                                                                WHERE system_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                                                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                            BEGIN
                                                                IF sql$rowcount != 1 THEN
                                                                    BEGIN
                                                                        SELECT
                                                                            1
                                                                            INTO var_failure_code;
                                                                        SELECT
                                                                            'Y'
                                                                            INTO var_stop_upload;
                                                                        INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                                                        VALUES (var_hosp_code, var_ws_system_datetime, 'Update Transaction_log error', var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                                                                        CONTINUE;
                                                                    END;
                                                                END IF;
                                                                EXCEPTION
                                                                    WHEN OTHERS THEN
                                                                        BEGIN
                                                                            SELECT
                                                                                1
                                                                                INTO var_failure_code;
                                                                            SELECT
                                                                                'Y'
                                                                                INTO var_stop_upload;
                                                                            INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                                                            VALUES (var_hosp_code, var_ws_system_datetime, 'Update Transaction_log error', var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                                                                            CONTINUE;
                                                                        END;
                                                            END;
                                                            SELECT
                                                                CONCAT(var_source_system, ' ', var_type, ' ', var_hkid)
                                                                INTO var_ws_log;
                                                            RAISE NOTICE 'OTH CASE: %', var_ws_log;
                                                            EXIT check_status;
                                                        END;
                                                    END IF;
                                                END IF;
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                            /* ------------------------------------------------------------ */
                            
                            /* common area for upload */
                        END;
                        SELECT
                            CONCAT(var_hosp_code, var_provider_id, var_db_id, var_type, COALESCE(CAST (var_comm_tran_date AS CHAR(8)), REPEAT(' ', 8)), COALESCE(CAST (var_comm_tran_time AS CHAR(6)), REPEAT(' ', 6)), COALESCE(CAST (var_comm_sys_date AS CHAR(8)), REPEAT(' ', 8)), COALESCE(CAST (var_comm_sys_time AS CHAR(6)), REPEAT(' ', 6)), COALESCE(CAST (var_user_id AS CHAR(8)), REPEAT(' ', 8)), REPEAT(' ', 255))
                            INTO var_comm_parm1;
                        /* Patient Demographic data */
                        SELECT
                            CONCAT(COALESCE(CAST (var_old_hkid AS CHAR(12)), REPEAT(' ', 12)), COALESCE(CAST (var_hkid AS CHAR(12)), REPEAT(' ', 12)), COALESCE(CAST (var_t_prk AS CHAR(8)), REPEAT(' ', 8)), COALESCE(CAST (var_patient_name AS CHAR(48)), REPEAT(' ', 48)), COALESCE(CAST (var_cccode1 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode2 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode3 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode4 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode5 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_cccode6 AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_sex AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_dob AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_dob_exact_flag AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_patient_type AS CHAR(03)), REPEAT(' ', 03)), COALESCE(CAST (var_mrn AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_address_building AS CHAR(37)), REPEAT(' ', 37)), COALESCE(CAST (var_address_dist AS CHAR(15)), REPEAT(' ', 15)), COALESCE(CAST (var_address_area AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_address_room AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_address_floor AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_address_block AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_marital_status AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_nationality AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_religion AS CHAR(03)), REPEAT(' ', 03)), COALESCE(CAST (var_other_docu_no AS CHAR(12)), REPEAT(' ', 12)), COALESCE(CAST (LTRIM(var_phone) AS CHAR(10)), REPEAT(' ', 10)), RIGHT(CONCAT('0000000000',
                            CASE CAST (var_pmi_access_code AS VARCHAR(10))
                                WHEN '' THEN ' '
                                ELSE CAST (var_pmi_access_code AS VARCHAR(10))
                            END), 10), REPEAT(' ', 255))
                            INTO var_comm_parm2;
                        /* print @comm_parm2 */
                        
                        /* comm-nok */
                        SELECT
                            CONCAT(COALESCE(CAST (var_nok_relation AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_nok_hkid AS CHAR(12)), REPEAT(' ', 12)), COALESCE(CAST (var_nok_name AS CHAR(48)), REPEAT(' ', 48)), COALESCE(CAST (var_nok_address_building AS CHAR(37)), REPEAT(' ', 37)), COALESCE(CAST (var_nok_address_dist AS CHAR(15)), REPEAT(' ', 15)), COALESCE(CAST (var_nok_address_area AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_nok_address_room AS CHAR(05)), REPEAT(' ', 05)), COALESCE(CAST (var_nok_address_floor AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (var_nok_address_block AS CHAR(02)), REPEAT(' ', 02)), COALESCE(CAST (LTRIM(var_nok_phone) AS CHAR(10)), REPEAT(' ', 10)), COALESCE(CAST (LTRIM(var_nok_bus_phone) AS CHAR(10)), REPEAT(' ', 10)), COALESCE(CAST (LTRIM(var_nok_bus_phone_ext) AS CHAR(04)), REPEAT(' ', 04)), REPEAT(' ', 255))
                            INTO var_comm_parm3;
                        /* comm-case */
                        SELECT
                            CONCAT(COALESCE(CAST (var_case_no AS CHAR(12)), REPEAT(' ', 12)), COALESCE(CAST (var_case_type AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_source_indicator AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_source_code AS CHAR(03)), REPEAT(' ', 03)), COALESCE(CAST (var_discharge_code AS CHAR(01)), REPEAT(' ', 1)), COALESCE(CAST (var_destination_code AS CHAR(05)), REPEAT(' ', 5)), COALESCE(CAST (var_ward_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_specialty_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_ward_class AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_bed_no AS CHAR(05)), REPEAT(' ', 5)), COALESCE(CAST (var_old_ward_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_old_specialty_code AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_old_ward_class AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_old_bed_no AS CHAR(05)), REPEAT(' ', 5)), RIGHT(CONCAT('0000',
                            CASE CAST (var_security_count AS VARCHAR(04))
                                WHEN '' THEN ' '
                                ELSE CAST (var_security_count AS VARCHAR(04))
                            END), 4), COALESCE(CAST (var_ae_ambulance AS CHAR(04)), REPEAT(' ', 04)), COALESCE(CAST (var_dba_flag AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_ae_case_type AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_ae_labour_case AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_ae_police AS CHAR(01)), REPEAT(' ', 01)), COALESCE(CAST (var_doctor_code AS CHAR(08)), REPEAT(' ', 08)), COALESCE(CAST (var_mrt_indicator AS CHAR(01)), REPEAT(' ', 1)), REPEAT(' ', 255))
                            INTO var_comm_parm4;
                        /*
                        [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
                        exec @return_code = @syup_gateway_cics
                                               @comm_parm1,
                                               @comm_parm2,
                                               @comm_parm3,
                                               @comm_parm4
                        */
                        /* ---- Check update status --- */
                    END;

                    IF var_return_code < 0 THEN /* ---> Gateway problem, retry after 1 min. */
                        BEGIN
                            CONTINUE /* goto skip_transaction */;
                        END;
                    ELSE
                        IF (var_return_code = 0) AND (var_rpc_name != '*pass*') THEN /* success */
                            BEGIN
                                UPDATE transaction_log
                                SET upload_status = 'S'
                                    WHERE system_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                BEGIN
                                    IF sql$rowcount != 1 THEN
                                        BEGIN
                                            SELECT
                                                1
                                                INTO var_failure_code;
                                            SELECT
                                                'Y'
                                                INTO var_stop_upload;
                                            INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                            VALUES (var_hosp_code, var_ws_system_datetime, 'Update Transaction_log error', var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                                            CONTINUE /* goto skip_transaction */;
                                        END;
                                    END IF;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            BEGIN
                                                SELECT
                                                    1
                                                    INTO var_failure_code;
                                                SELECT
                                                    'Y'
                                                    INTO var_stop_upload;
                                                INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                                VALUES (var_hosp_code, var_ws_system_datetime, 'Update Transaction_log error', var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                                                CONTINUE /* goto skip_transaction */;
                                            END;
                                END;
                            END;
                        ELSE
                            IF var_return_code > 0 THEN /* ---> Invalid data in uploaded record */
                                BEGIN
                                    INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                    VALUES (var_hosp_code, var_ws_system_datetime, CONCAT('hasp_upload_host: upload failure! ', 'event type = ', var_type, ', return code = ', CAST (var_return_code AS CHAR(5))), CONCAT(var_comm_parm1, var_comm_parm4), var_comm_parm2, var_comm_parm3, localtimestamp);
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF sql$rowcount != 1 THEN
                                        BEGIN
                                            SELECT
                                                2
                                                INTO var_failure_code;
                                            SELECT
                                                'Y'
                                                INTO var_stop_upload;
                                            CONTINUE;
                                        END;
                                    END IF;

                                    BEGIN
                                        UPDATE transaction_log
                                        SET upload_status = 'F'
                                            WHERE system_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                        IF sql$rowcount != 1 THEN
                                            BEGIN
                                                SELECT
                                                    1
                                                    INTO var_failure_code;
                                                SELECT
                                                    'Y'
                                                    INTO var_stop_upload;
                                                CONTINUE;
                                            END;
                                        END IF;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                BEGIN
                                                    SELECT
                                                        1
                                                        INTO var_failure_code;
                                                    SELECT
                                                        'Y'
                                                        INTO var_stop_upload;
                                                    CONTINUE;
                                                END;
                                    END;
                                    /* insert suspend_upload_log */
                                    IF NOT EXISTS (SELECT
                                        *
                                        FROM suspend_upload_log
                                        WHERE transaction_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code) THEN
                                        BEGIN
                                            BEGIN
                                                INSERT INTO suspend_upload_log (hospital_code, transaction_dtm, type, hkid, patient_key, old_hkid)
                                                VALUES (var_hosp_code, var_ws_system_datetime, var_type, var_ws_org_hkid, var_t_prk, var_ws_org_old_hkid);
                                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                IF sql$rowcount != 1 THEN
                                                    BEGIN
                                                        SELECT
                                                            3
                                                            INTO var_failure_code;
                                                        SELECT
                                                            'Y'
                                                            INTO var_stop_upload;
                                                        CONTINUE;
                                                    END;
                                                END IF;
                                                EXCEPTION
                                                    WHEN OTHERS THEN
                                                        BEGIN
                                                            SELECT
                                                                3
                                                                INTO var_failure_code;
                                                            SELECT
                                                                'Y'
                                                                INTO var_stop_upload;
                                                            CONTINUE;
                                                        END;
                                            END;
                                        END;
                                    END IF;
                                END;
                            END IF;
                        END IF;
                    END IF; /* End of Invalid data in uploaded record */

                    IF (var_return_code = 0) AND (var_rpc_name != '*pass*') AND /* Success */ (var_check_patient_key = 'Y') THEN
                        EXIT check_patient_key;
                    ELSE
                        /* Pass */
                        EXIT next_record;
                    END IF;
                END;
                SELECT
                    patient_key, type, hkid, NULL, NULL, adm_dtm, specialty_code, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, dob, exact_dob_flag, marital_status, patient_type, race, other_doc_no, mrn, building, room, floor, block, district, religion, phone1, phone2, address_indicator, nok_name, nok_hkid, nok_relationship, nok_room, nok_floor, nok_block, nok_building, nok_district, nok_phone1, nok_hone2, nok_address_indicator, old_hkid, update_by
                    INTO var_t_prk, var_type, var_hkid, var_case_no, var_case_type, var_ws_adm_datetime, var_specialty_code, var_patient_name, var_sex, var_cccode1, var_cccode2, var_cccode3, var_cccode4, var_cccode5, var_cccode6, var_ws_dob_datetime, var_dob_exact_flag, var_marital_status, var_patient_type, var_nationality, var_other_docu_no, var_mrn, var_address_building, var_address_room, var_address_floor, var_address_block, var_address_dist, var_religion, var_phone, var_office_phone, var_office_ext, var_nok_name, var_nok_hkid, var_nok_relation, var_nok_address_room, var_nok_address_floor, var_nok_address_block, var_nok_address_building, var_nok_address_dist, var_nok_phone, var_nok_bus_phone, var_nok_bus_phone_ext, var_old_hkid, var_user_id
                    FROM transaction_log
                    WHERE hospital_code = var_hosp_code AND system_dtm = var_ws_system_datetime;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount != 1 THEN
                    BEGIN
                        RAISE NOTICE 'Error - Retrieving from transaction_log';
                        INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                        VALUES (var_hosp_code, var_ws_system_datetime, 'Error - Retrieving from transaction_log', var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                        CONTINUE;
                    END;
                END IF;
                SELECT
                    CONCAT(var_user_id, REPEAT(' ', 4))
                    INTO var_user_id;
                SELECT
                    var_hkid
                    INTO var_ws_org_hkid;
                SELECT
                    var_old_hkid
                    INTO var_ws_org_old_hkid;
                SELECT
                    SUBSTRING(CONCAT(LTRIM(var_hkid), REPEAT(' ', 12)), 1, 12)
                    INTO var_hkid;
                SELECT
                    SUBSTRING(CONCAT(LTRIM(var_old_hkid), REPEAT(' ', 12)), 1, 12)
                    INTO var_old_hkid;
                SELECT
                    to_char(var_ws_dob_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                    INTO var_dob;
                SELECT
                    SUBSTRING(var_type, 1, 2)
                    INTO var_ws_event_type;
                SELECT
                    district_area
                    INTO var_address_area
                    FROM hkpmi_dbo.district
                    WHERE district_code = var_address_dist;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF (sql$rowcount != 1) THEN
                    SELECT
                        NULL
                        INTO var_address_area;
                END IF;
                SELECT
                    district_area
                    INTO var_nok_address_area
                    FROM hkpmi_dbo.district
                    WHERE district_code = var_nok_address_dist;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF (sql$rowcount != 1) THEN
                    SELECT
                        NULL
                        INTO var_nok_address_area;
                END IF;
                SELECT
                    var_type
                    INTO var_org_type;

                IF (var_type = '031' OR var_type = '020') THEN
                    BEGIN
                        SELECT
                            var_hkid
                            INTO var_other_docu_no;
                        SELECT
                            var_old_hkid
                            INTO var_hkid;
                    END;
                END IF;
                /* check the suspend_upload_log for previous error */
                IF EXISTS (SELECT
                    *
                    FROM suspend_upload_log
                    WHERE (COALESCE(hkid, 'CUR') = COALESCE(var_ws_org_hkid, 'OLD') OR COALESCE(hkid, 'CUR') = COALESCE(var_ws_org_old_hkid, 'OLD') OR COALESCE(old_hkid, 'CUR') = COALESCE(var_ws_org_old_hkid, 'OLD') OR COALESCE(old_hkid, 'CUR') = COALESCE(var_ws_org_hkid, 'OLD')) AND (transaction_dtm < var_ws_system_datetime)) THEN
                    BEGIN
                        SELECT
                            CONCAT(var_type, ' ', var_case_no, ' ', var_hkid, ' ', var_ward_code, ' ', var_specialty_code, ' ', var_adm_date, ' ', var_adm_time)
                            INTO var_ws_log;
                        RAISE NOTICE 'PREV-FAIL: %', var_ws_log;
                        SELECT
                            999
                            INTO var_return_code;
                        /* --www goto check_opas_status */
                    END;
                END IF;

                IF var_type IN ('030', '031', '020', '010', '100') THEN
                    BEGIN
                        IF (var_type = '030' OR var_type = '010') THEN
                            SELECT
                                '1'
                                INTO var_type;
                        ELSE
                            IF var_type = '031' THEN
                                SELECT
                                    '7'
                                    INTO var_type;
                            ELSE
                                IF var_type = '020' THEN
                                    SELECT
                                        '8'
                                        INTO var_type;
                                ELSE
                                    IF var_type = '100' THEN
                                        BEGIN
                                            SELECT
                                                '1'
                                                INTO var_type;
                                            SELECT
                                                REPEAT(' ', 12)
                                                INTO var_case_no;
                                            SELECT
                                                REPEAT(' ', 8)
                                                INTO var_adm_date;
                                            SELECT
                                                REPEAT(' ', 4)
                                                INTO var_adm_time;
                                            SELECT
                                                REPEAT(' ', 4)
                                                INTO var_specialty_code;
                                        END;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;

                        IF var_ws_system_datetime IS NOT NULL THEN
                            BEGIN
                                SELECT
                                    to_char(var_ws_system_datetime::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD')
                                    INTO var_update_date;
                                SELECT
                                    to_char(var_ws_system_datetime::TIMESTAMP WITHOUT TIME ZONE, 'HH24:MI:SS')
                                    INTO var_ws_time_colon;
                                SELECT
                                    CONCAT(SUBSTRING(var_ws_time_colon, 1, 2), SUBSTRING(var_ws_time_colon, 4, 2), SUBSTRING(var_ws_time_colon, 7, 2))
                                    INTO var_update_time;
                            END;
                        END IF;
                        SELECT
                            CONCAT(CAST (COALESCE(var_hosp_code, REPEAT(' ', 3)) AS CHAR(3)), CAST (COALESCE(var_update_date, REPEAT(' ', 8)) AS CHAR(8)), CAST (COALESCE(var_update_time, REPEAT(' ', 6)) AS CHAR(6)), CAST (COALESCE(var_case_no, REPEAT(' ', 12)) AS CHAR(12)), CAST (COALESCE(var_type, REPEAT(' ', 1)) AS CHAR(1)), CAST (COALESCE(var_hkid, REPEAT(' ', 12)) AS CHAR(12)), CAST (COALESCE(var_adm_date, REPEAT(' ', 8)) AS CHAR(8)), CAST (COALESCE(var_adm_time, REPEAT(' ', 4)) AS CHAR(4)), CAST (COALESCE(var_specialty_code, REPEAT(' ', 4)) AS CHAR(4)), CAST (COALESCE(var_other_docu_no, REPEAT(' ', 12)) AS CHAR(12)), CAST (COALESCE(var_patient_name, REPEAT(' ', 48)) AS CHAR(48)), CAST (COALESCE(var_cccode1, REPEAT(' ', 5)) AS CHAR(5)), CAST (COALESCE(var_cccode2, REPEAT(' ', 5)) AS CHAR(5)), CAST (COALESCE(var_cccode3, REPEAT(' ', 5)) AS CHAR(5)), CAST (COALESCE(var_cccode4, REPEAT(' ', 5)) AS CHAR(5)), CAST (COALESCE(var_cccode5, REPEAT(' ', 5)) AS CHAR(5)), CAST (COALESCE(var_cccode6, REPEAT(' ', 5)) AS CHAR(5)), CAST (COALESCE(var_mrn, REPEAT(' ', 8)) AS CHAR(8)), CAST (COALESCE(var_dob, '99999999') AS CHAR(8)), CAST (COALESCE(var_dob_exact_flag, 'Y') AS CHAR(1)), CAST (COALESCE(var_sex, REPEAT(' ', 01)) AS CHAR(1)), CAST (COALESCE(var_address_room, REPEAT(' ', 05)) AS CHAR(5)), CAST (COALESCE(var_address_floor, REPEAT(' ', 02)) AS CHAR(2)), CAST (COALESCE(var_address_block, REPEAT(' ', 02)) AS CHAR(2)), CAST (COALESCE(var_address_building, REPEAT(' ', 37)) AS CHAR(37)), CAST (COALESCE(var_address_dist, REPEAT(' ', 15)) AS CHAR(15)), CAST (COALESCE(var_address_area, REPEAT(' ', 01)) AS CHAR(1)))
                            INTO var_reg_parm1;
                        SELECT
                            CONCAT(CAST (COALESCE(var_phone, REPEAT(' ', 10)) AS CHAR(10)), CAST (COALESCE(var_office_phone, REPEAT(' ', 10)) AS CHAR(10)), CAST (COALESCE(var_office_ext, REPEAT(' ', 4)) AS CHAR(4)), CAST (COALESCE(var_marital_status, REPEAT(' ', 01)) AS CHAR(01)), CAST (COALESCE(var_patient_type, REPEAT(' ', 03)) AS CHAR(03)), CAST (COALESCE(var_nationality, REPEAT(' ', 02)) AS CHAR(02)), CAST (COALESCE(var_religion, REPEAT(' ', 03)) AS CHAR(03)), CAST (COALESCE(CONCAT(var_hosp_code, 'OPS  '), REPEAT(' ', 08)) AS CHAR(08)), CAST (COALESCE(var_t_prk, REPEAT(' ', 08)) AS CHAR(08)), REPEAT(' ', 22), CAST (COALESCE(var_nok_hkid, REPEAT(' ', 12)) AS CHAR(12)), CAST (COALESCE(var_nok_name, REPEAT(' ', 48)) AS CHAR(48)), CAST (COALESCE(var_nok_relation, REPEAT(' ', 03)) AS CHAR(03)), CAST (COALESCE(var_nok_address_room, REPEAT(' ', 05)) AS CHAR(05)), CAST (COALESCE(var_nok_address_floor, REPEAT(' ', 02)) AS CHAR(02)), CAST (COALESCE(var_nok_address_block, REPEAT(' ', 02)) AS CHAR(02)), CAST (COALESCE(var_nok_address_building, REPEAT(' ', 37)) AS CHAR(37)), CAST (COALESCE(var_nok_address_dist, REPEAT(' ', 15)) AS CHAR(15)), CAST (COALESCE(var_nok_address_area, REPEAT(' ', 01)) AS CHAR(01)), CAST (COALESCE(var_nok_phone, REPEAT(' ', 10)) AS CHAR(10)), CAST (COALESCE(var_nok_bus_phone, REPEAT(' ', 10)) AS CHAR(10)), CAST (COALESCE(var_nok_bus_phone_ext, REPEAT(' ', 04)) AS CHAR(04)))
                            INTO var_reg_parm2;
                        SELECT
                            REPEAT(' ', 50)
                            INTO var_upload_errmsg;
                        /* --- Update host --- */
                        
                        /*
                        [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
                        exec @return_code = @gateway_cics
                                   @reg_parm1, @reg_parm2, @upload_errmsg output
                        */
                        /* ---- Check update status --- */
                        OPEN p_refcur FOR
                        SELECT
                            SUBSTRING(var_reg_parm1, 1, 60), var_return_code;
                        RETURN NEXT p_refcur;
                        /* Gateway problem, retry after 1 min. */
                        IF var_return_code < 0 THEN
                            BEGIN
                                CONTINUE;
                            END;
                        /* Upload successful */
                        ELSE
                            IF var_return_code = 0 THEN
                                BEGIN
                                    BEGIN
                                        UPDATE transaction_log
                                        SET upload_status = 'S'
                                            WHERE system_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                        IF sql$rowcount != 1 THEN
                                            BEGIN
                                                SELECT
                                                    1
                                                    INTO var_failure_code;
                                                SELECT
                                                    'Y'
                                                    INTO var_stop_upload;
                                                CONTINUE /* goto skip_transaction */;
                                            END;
                                        END IF;
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                BEGIN
                                                    SELECT
                                                        1
                                                        INTO var_failure_code;
                                                    SELECT
                                                        'Y'
                                                        INTO var_stop_upload;
                                                    CONTINUE /* goto skip_transaction */;
                                                END;
                                    END;
                                END;
                            /* Something wrong with update */
                            ELSE
                                IF var_return_code > 0 THEN
                                    BEGIN
                                        IF var_upload_errmsg <> 'FUTURE REG. NOT ALLOWED ***' THEN
                                            BEGIN
                                                BEGIN
                                                    UPDATE transaction_log
                                                    SET upload_status = 'F'
                                                        WHERE system_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                    IF sql$rowcount != 1 THEN
                                                        BEGIN
                                                            SELECT
                                                                1
                                                                INTO var_failure_code;
                                                            SELECT
                                                                'Y'
                                                                INTO var_stop_upload;
                                                            CONTINUE /* goto skip_transaction */;
                                                        END;
                                                    END IF;
                                                    EXCEPTION
                                                        WHEN OTHERS THEN
                                                            BEGIN
                                                                SELECT
                                                                    1
                                                                    INTO var_failure_code;
                                                                SELECT
                                                                    'Y'
                                                                    INTO var_stop_upload;
                                                                CONTINUE /* goto skip_transaction */;
                                                            END;
                                                END;
                                                /* insert suspend_upload_log */
                                                IF NOT EXISTS (SELECT
                                                    *
                                                    FROM suspend_upload_log
                                                    WHERE transaction_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code) THEN
                                                    BEGIN
                                                        BEGIN
                                                            INSERT INTO suspend_upload_log (hospital_code, transaction_dtm, type, hkid, patient_key, old_hkid)
                                                            VALUES (var_hosp_code, var_ws_system_datetime, var_org_type, var_ws_org_hkid, var_t_prk, var_ws_org_old_hkid);
                                                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                            IF sql$rowcount != 1 THEN
                                                                BEGIN
                                                                    SELECT
                                                                        3
                                                                        INTO var_failure_code;
                                                                    SELECT
                                                                        'Y'
                                                                        INTO var_stop_upload;
                                                                    CONTINUE;
                                                                END;
                                                            END IF;
                                                            EXCEPTION
                                                                WHEN OTHERS THEN
                                                                    BEGIN
                                                                        SELECT
                                                                            3
                                                                            INTO var_failure_code;
                                                                        SELECT
                                                                            'Y'
                                                                            INTO var_stop_upload;
                                                                        CONTINUE;
                                                                    END;
                                                        END;
                                                    END;
                                                END IF;
                                                /* Insert errorlog here */
                                                BEGIN
                                                    INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                                                    VALUES (var_hosp_code, var_ws_system_datetime, CONCAT('hasp_upload_host: upload failure! ', 'event type = ', var_org_type, ', return code = ', CAST (var_return_code AS CHAR(5))), var_reg_parm1, var_reg_parm2, var_upload_errmsg, localtimestamp);
                                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                    IF sql$rowcount != 1 THEN
                                                        BEGIN
                                                            SELECT
                                                                2
                                                                INTO var_failure_code;
                                                            SELECT
                                                                'Y'
                                                                INTO var_stop_upload;
                                                            CONTINUE /* goto skip_transaction */;
                                                        END;
                                                    END IF;
                                                    EXCEPTION
                                                        WHEN OTHERS THEN
                                                            BEGIN
                                                                SELECT
                                                                    2
                                                                    INTO var_failure_code;
                                                                SELECT
                                                                    'Y'
                                                                    INTO var_stop_upload;
                                                                CONTINUE /* goto skip_transaction */;
                                                            END;
                                                END;
                                            END;
                                        END IF;
                                    END;
                                END IF;
                            END IF;
                        END IF; /* End of @return code */

                        <<check_opas_status>>
                        BEGIN
                            IF var_return_code = 0 AND var_check_patient_key = 'Y' THEN
                                EXIT check_patient_key;
                            ELSE
                                EXIT next_record;
                            END IF;
                        END;
                    END; /* @type in ('030', '031', '020', '010', '100') */
                ELSE
                    /* @type in ('030', '031', '020', '010', '100') */
                    BEGIN
                        SELECT
                            0
                            INTO var_return_code;
                        RAISE NOTICE 'OPAS exception type : % - %, %, %, %', var_type, var_ws_org_hkid, var_hosp_code, var_case_no, var_ws_system_datetime;

                        BEGIN
                            UPDATE transaction_log
                            SET upload_status = 'P'
                                WHERE system_dtm = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                            IF sql$rowcount != 1 THEN
                                BEGIN
                                    SELECT
                                        1
                                        INTO var_failure_code;
                                    SELECT
                                        'Y'
                                        INTO var_stop_upload;
                                    /* goto skip_transaction */
                                    CONTINUE;
                                END;
                            END IF;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    BEGIN
                                        SELECT
                                            1
                                            INTO var_failure_code;
                                        SELECT
                                            'Y'
                                            INTO var_stop_upload;
                                        /* goto skip_transaction */
                                        CONTINUE;
                                    END;
                        END;
                        EXIT next_record;
                    END;
                END IF; /* End if @type = '030' or @type='031' ...... */
            END;
            /*
            [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
            begin transaction
            */
            CALL hkpmi_check_patient_key(var_return_code, var_hosp_code, var_ws_org_hkid, var_t_prk);

            IF var_return_code <> 0 THEN
                BEGIN
                    ROLLBACK;

                    IF var_return_code = 3 THEN
                        SELECT
                            CONCAT('Update Unmatch patient key error - ', var_ws_org_hkid, '''s patient key in HKPMI', 'unmatched with UNIX''s patient key ', var_t_prk, ')')
                            INTO var_error_msg;
                    ELSE
                        SELECT
                            CONCAT('Update Unmatch patient key error - ', 'Patient key not found - (', var_t_prk, ') failed')
                            INTO var_error_msg;
                    END IF;
                    INSERT INTO upload_exception (hospital_code, transaction_dtm, error_detail, record1, record2, record3, update_dtm)
                    VALUES (var_hosp_code, var_ws_system_datetime, var_error_msg, NULL, NULL, NULL, localtimestamp);
                END;
            ELSE
                BEGIN
                    /*
                    [3058 - Severity CRITICAL - *COMMIT* was removed from inner level of nested transaction. Review your transformed code and modify it if necessary.]
                    commit transaction
                    */
                END;
            END IF;
        END;
    END LOOP;
    CLOSE hkpmi_check_patient_key$refcur_1; /* loop until server is shutdown */

    IF var_failure_code = 1 THEN
        RAISE NOTICE '---  Update transaction_log failure!!! ---';
    ELSE
        IF var_failure_code = 2 THEN
            RAISE NOTICE '---  Update upload_exception failure!!! ---';
        ELSE
            IF var_failure_code = 3 THEN
                RAISE NOTICE '---  Update suspend_upload_log failure!!! ---';
            END IF;
        END IF;
    END IF;
END;
$function$
;

ALTER FUNCTION "hkpmi_upload_to_mainframe" OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";