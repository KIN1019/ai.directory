-- DROP PROCEDURE cpi_admission(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, in int4, in int4, in int4, inout varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_admission(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_chi_name character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_reference character varying, IN par_medical_record_number character varying, IN par_remark character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_death_code character varying, IN par_card_holder integer, IN par_case_access_code integer, IN par_pmi_access_code integer, IN par_security_count integer, INOUT par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_patient_type character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_bed_no character varying, IN par_ward_class character varying, IN par_pp_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::bpchar, IN par_eh_code character varying DEFAULT NULL::bpchar, IN par_source_hosp_code character varying DEFAULT NULL::bpchar, IN par_source_case_no character varying DEFAULT NULL::bpchar, IN par_hkic_symbol character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    result_int_value         INTEGER;
    var_cnt                  INTEGER;
    var_prev_patient_key     VARCHAR(08);
    var_new_patient_key      VARCHAR(08);
    var_patient_no           INTEGER;
    var_return_status        INTEGER;
    var_prev_hkid            VARCHAR(12);
    var_n_prior              INTEGER;
    var_major_nok            VARCHAR(01);
    var_tmp_mrn              VARCHAR(08);
    var_status_code          VARCHAR(02);
    var_rep_hospital         INTEGER;
    var_rep_clusters         INTEGER;
    var_success_flag         VARCHAR(01);
    var_exit_flag            VARCHAR(01);
    var_tmp_phonetic         VARCHAR(48);
    var_chk_update_datetime  TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code    INTEGER;
    var_source_system_dtm    TIMESTAMP WITHOUT TIME ZONE;
    var_rowcount             INTEGER;
    var_error                INTEGER;
    var_valid_flag           VARCHAR(2);
    var_treatment_location   VARCHAR(04);
    var_movement_cnt         INTEGER;
    var_return_code          INTEGER;
    var_old_patient_name     VARCHAR(48);
    var_old_sex              VARCHAR(01);
    var_old_dob              TIMESTAMP WITHOUT TIME ZONE;
    var_tmp_priority         INTEGER;
    var_active_ind           VARCHAR(1);
    var_upload_status        VARCHAR(1);
    var_cpi_filler           VARCHAR(30);
    var_lnk_case_patient_key VARCHAR(12);
    var_rpc_call             VARCHAR(400);
    var_old_hkic_symbol      VARCHAR(1);
    var_hkpmi_down_flag      VARCHAR(1);
    var_local_hosp           VARCHAR(3);
    var_hkpmi_srvr           varchar(255);
    var_error_msg            VARCHAR(255);
    var_is_schi_name         VARCHAR(01);
    sql$rowcount             BIGINT;
    gjp_text                 text;
    error_message            text;
    dblink_sql               text;
   var_row_count int;
BEGIN
    <<return_error>>
    begin
        raise notice 'cpi_admission  start';
        /* Declaration */
        SELECT 'N'
        INTO var_hkpmi_down_flag;
        SELECT NULL
        INTO var_hkpmi_srvr;
        /* 2006-12-12 Addeded by HK Fong SMR20015887 */
        /*
        if @@trancount = 0
           begin
              select   @return_error_code = 20000
              select   @success_flag = "N"
              goto return_error
           end
        */
        /* sp_addmessage 200063,"District cannot be NULL if address is not null!"  -- cpi..sysusermessages */
        IF (par_source_system <> 'DNL' AND par_district_code IS NULL AND
            (par_building IS NOT NULL OR par_room IS NOT NULL OR par_floor IS NOT NULL OR par_block IS NOT NULL OR
             par_building != ' ' OR par_room != ' ' OR par_floor != ' ' OR par_block != ' ')) THEN
            BEGIN
                SELECT 'District cannot be empty when other address data fields are not empty!'
                INTO var_error_msg;
                RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '200063';
                pas_return_code := 200063;
                RETURN;
            END;
        END IF;

        IF (LTRIM(RTRIM(par_source_hosp_code)) = '') OR (LTRIM(RTRIM(par_source_hosp_code)) is NULL) THEN
            SELECT NULL
            INTO par_source_hosp_code;
        END IF;

        IF (LTRIM(RTRIM(par_source_case_no)) = '') OR (LTRIM(RTRIM(par_source_case_no)) is NULL) THEN
            BEGIN
                SELECT NULL
                INTO par_source_hosp_code;
                SELECT NULL
                INTO par_source_case_no;
            END;
        END IF;
        /* ----------20120105 Check HKPMI down Flag-------------------- */
        SELECT 'N'
        INTO var_hkpmi_down_flag;
        SELECT hospital_code
        INTO var_local_hosp
        FROM hospital;
        raise notice 'var_local_hosp,%',var_local_hosp;
        SELECT appl_ctl_text_value
        INTO var_hkpmi_down_flag
        FROM pas_appl_control
        WHERE hospital_code = var_local_hosp
          AND appl_name = 'IPAS'
          AND appl_ctl_type = 'HKPMI_SP1_DOWN';
        /* ---------------------Begin of 20051102 SL  -------------------------------------------- */
        /* --if @source_system <> 'DNL' */
        IF (par_source_system <> 'DNL' AND var_hkpmi_down_flag <> 'Y') THEN /* ---if @hkpmi_down_flag ='Y'==> new patient info will retrieved from HKPMI Read Server */
            BEGIN
                /* ----------new patient ------ */
                IF (NOT EXISTS (SELECT *
                                FROM cpi_patient
                                WHERE hkid = par_hkid) AND (SUBSTRING(par_hkid, 1, 1) != 'U')) OR
                   ((par_source_hosp_code <> par_hospital_code) AND
                    (par_source_case_no IS NOT NULL)) THEN /* for  linked_case checking on HKPMI */
                    BEGIN
                        /* --declare  @hkpmi_srvr VARCHAR(30),@error_msg  varchar(255) */
                        SELECT NULL
                        INTO var_hkpmi_srvr;
                        /* ---cis rpc --- */

                        -- changed by gjp@2023/03,fixed var_hkpmi_srvr
                        -- CALL cpi_get_rpc_server('HKPMI_SERVER', var_hkpmi_srvr, var_return_code);
                        raise notice 'cpi_admission[127] cpi_get_rpc_server start';
                        CALL cpi_get_rpc_server(var_return_code, 'HKPMI_SERVER'::varchar, var_hkpmi_srvr, null);
                       	RAISE NOTICE 'cpi_admission[127] cpi_get_rpc_server done,var_hkpmi_srvr => %',var_hkpmi_srvr;

                        IF ((var_hkpmi_srvr IS NULL) AND (NOT EXISTS (SELECT *
                                                                      FROM cpi_patient
                                                                      WHERE hkid = par_hkid) AND
                                                          (SUBSTRING(par_hkid, 1, 1) != 'U'))) THEN
                            BEGIN
                                SELECT 'Primary HKPMI server is not available, PMI Registration, Change HKID, Move Episode and Merge Patient functions are prohibited.'
                                INTO var_error_msg;
                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '200034';
                                pas_return_code := 200034;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* ---------------------End OF : 20051102 SL --------------------------------------- */
        /* --- 20081230 SL:  temp Bug fix for OLD PBD on UID pay.code problem - */
        /* --- 20160108 Yorky: Prevent NC document type is used for HKID registration */
        IF (SUBSTRING(par_hkid, 1, 1) <> 'U') AND par_txn_type IN ('100', '300') THEN
            BEGIN
                IF par_patient_type = 'UID' THEN
                    BEGIN
                        SELECT 'The pay code (UID) is not allowed for non-pseudo ID'
                        INTO var_error_msg;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '2100005';
                        pas_return_code := 2100005;
                        RETURN;
                    END;
                END IF;
                /* Prevent HKID linking HKID */

                IF par_document_flag = 'F' THEN
                    BEGIN
                        SELECT 'The identity document (NC) is not allowed for non-pseudo ID!'
                        INTO var_error_msg;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '2100005';
                        pas_return_code := 2100005;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;
        /* --- 20181112 Yorky: Prevent other_doc_no to  be updated as 'null' or 'NULL' value */

        IF par_other_document_no IN ('null', 'NULL') THEN
            BEGIN
                SELECT NULL
                INTO par_other_document_no;
            END;
        END IF;
        /* ---------20081230---------------------------- */
        /* ---- 20141005 SL: validation on other_doc_no if doc_type NC ------------- */
        IF par_document_flag = 'F' AND par_txn_type IN ('100', '300') AND SUBSTRING(par_hkid, 1, 1) = 'U' THEN
            BEGIN
                CALL cpi_pq_validate_hkid(var_return_code, par_other_document_no, var_valid_flag);
                /* --- 20160108 Yorky: Prevent Pseudo ID linking Pseudo ID */

                IF (var_valid_flag = 'N' OR var_return_code != 0 OR SUBSTRING(par_other_document_no, 1, 1) = 'U') THEN
                    BEGIN
                        SELECT 'Invalid Other Doc Number for Claimed HKID (UID) Flow !'
                        INTO var_error_msg;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '2100005';
                        pas_return_code := 2100005;
                        RETURN;
                    END;
                END IF;
                /* 20160108 Yorky: Check claimed HKID exist in CPI and HKPMI */
                raise notice 'cpi_admission par_other_document_no=%', par_other_document_no;
                IF NOT EXISTS (SELECT 1
                               FROM cpi_patient
                               WHERE hkid = par_other_document_no) THEN
                    BEGIN
                        /* Check HKPMI only when claimed HKID not exist in CPI */
                        IF var_hkpmi_down_flag <> 'Y' THEN
                            BEGIN                               	                            
	                            -- replace_dblink_by_fdw
	                            CALL hkpmi.hkpmi_check_patient_detail_1(var_return_code, par_other_document_no, par_hospital_code);
	                           	SET search_path TO hpi,public;
	                           	
	                           	IF var_return_code = 2 THEN
                                    BEGIN
                                        SELECT 'Claimed HKID does not exist in HKPMI!'
                                        INTO var_error_msg;
                                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '2100006';
                                    END;
                                END IF;
                            EXCEPTION 
	                        	WHEN OTHERS THEN
	                        		RAISE NOTICE 'error in CALL hkpmi.hkpmi_check_patient_detail_1 , %',SQLERRM;
	                        		var_error_msg := 'error in CALL hkpmi.hkpmi_check_patient_detail_1' || var_error_msg;
	                        		RAISE EXCEPTION '%',var_error_msg;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* ---- 20141005 SL: ------------- */

        /*
        save transaction cpi_admission
        */
        -- SAVEPOINT cpi_admission;
        IF par_source_system = 'DNL' THEN
            SELECT 'N'
            INTO var_upload_status;
        ELSE
            SELECT 'Y'
            INTO var_upload_status;
        END IF;
        /* Start validate key field */
        IF NOT EXISTS (SELECT *
                       FROM hospital
                       WHERE hospital_code = par_hospital_code) THEN
            BEGIN
                SELECT 200002
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        raise notice 'var_success_flag=%', var_success_flag;
        /* check source system dtm with admission dtm */
        IF par_admission_datetime > par_transaction_datetime THEN
            BEGIN
                SELECT 200009
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        CALL cpi_pq_validate_hkid(var_return_code, par_hkid, var_valid_flag);
        raise notice '302cpi_admission,par_hkid=%',par_hkid;
        IF (var_valid_flag = 'N' OR var_return_code != 0) THEN
            BEGIN
                SELECT 200005
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* 20030812 SL: fix downtime record problem */
        SELECT LTRIM(RTRIM(par_document_flag))
        INTO par_document_flag;
        /* --- Episode base */

        IF par_document_flag = '' THEN
            SELECT NULL
            INTO par_document_flag;
        END IF;
        /* 20030812 */
        CALL cpi_pq_validate_caseno(var_return_code, par_case_no, par_hospital_code, var_valid_flag);

        IF (var_valid_flag = 'N' OR var_return_code != 0) THEN
            BEGIN
                SELECT 200004
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* check hkid whether it is an used unhkid */
        /* add checking for existence of unhkid in cpi_patient */

        IF EXISTS (SELECT *
                   FROM cpi_used_unhkid
                   WHERE hkid = par_hkid) THEN
            BEGIN
                /* --- resued Unhkid */
                IF SUBSTRING(par_hkid, 1, 1) = 'U' AND (NOT EXISTS (SELECT *
                                                                    FROM cpi_patient
                                                                    WHERE hkid = par_hkid)) THEN
                    BEGIN
                        SELECT 200033
                        INTO var_return_error_code;
                        /* --- 200033 = HKID is being used before, Transaction is rejected! */
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                /* ----Blocked HKID */
                IF SUBSTRING(par_hkid, 1, 1) <> 'U' THEN
                    BEGIN
                        SELECT 210002
                        INTO var_return_error_code; /* ---210002 = HKID blocked, Transaction is rejected ! */
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /*
        Check whether the patient has been updated after
        processing this transaction.  If so, reject the transaction.
        This makes sure the patient information is the most
        up-to-date.
        */
        SELECT NULL
        INTO var_chk_update_datetime;
        SELECT COUNT(*)
        -- INTO var_cnt
        INTO result_int_value
        FROM cpi_patient
        WHERE patient_key = par_patient_key;
        IF FOUND THEN
            var_cnt := result_int_value;
        END IF;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT update_dtm,
                       patient_name,
                       sex,
                       dob,
                       hkic_symbol
                INTO var_chk_update_datetime, var_old_patient_name, var_old_sex, var_old_dob, var_old_hkic_symbol
                FROM cpi_patient
                WHERE patient_key = par_patient_key;
            END;
        ELSE
            BEGIN
                SELECT COUNT(*)
                -- INTO var_cnt
                INTO result_int_value
                FROM cpi_patient
                WHERE hkid = par_hkid;
                IF FOUND THEN
                    var_cnt := result_int_value;
                END IF;

                IF (var_cnt != 0) THEN
                    BEGIN
                        SELECT update_dtm,
                               patient_name,
                               sex,
                               dob,
                               hkic_symbol
                        INTO var_chk_update_datetime, var_old_patient_name, var_old_sex, var_old_dob, var_old_hkic_symbol
                        FROM cpi_patient
                        WHERE hkid = par_hkid;
                    END;
                ELSE
                    BEGIN
                        SELECT NULL,
                               NULL,
                               NULL,
                               NULL
                        INTO var_old_patient_name, var_old_sex, var_old_dob, var_old_hkic_symbol;
                    END;
                END IF;
            END;
        END IF;
        /* --20100928 HKIC */
        IF par_hkic_symbol IS NULL OR LTRIM(RTRIM(par_hkic_symbol)) = '' THEN /* if pass-in hkic is null or N/A */
            SELECT var_old_hkic_symbol
            INTO par_hkic_symbol;
        END IF;
        /* 20140219 Yorky - update HKIC symbol to null for all Pseudo ID */
        IF SUBSTRING(par_hkid, 1, 1) = 'U' THEN
            BEGIN
                SELECT NULL
                INTO par_hkic_symbol;
            END;
        END IF;

        IF (var_chk_update_datetime IS NOT NULL) AND (var_chk_update_datetime != par_last_update_datetime) THEN
            BEGIN
                /*
                print "Patient has been updated after transaction,
                patient update is rejected!"
                */
                SELECT 7016
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /*
        Assign the transaction_datime of source system
        to source_system_dtm
        */
        SELECT par_transaction_datetime
        INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        /* Use system date/time from ADT as update_dtm */
        IF par_source_system <> 'ADT' THEN
            SELECT timestamp_convert(localtimestamp)
            INTO par_transaction_datetime;
        END IF;
        /* Set flags and variables */
        SELECT 'Y'
        INTO var_success_flag;

        /* Get chinese name from ccc_unicode table */
        CALL cpi_get_phonetic_chin_name(par_ccc1 => par_ccc_1, par_ccc2 => par_ccc_2, par_ccc3 => par_ccc_3,
                                        par_ccc4 => par_ccc_4, par_ccc5 => par_ccc_5, par_ccc6 => par_ccc_6,
                                        par_phonetic_name => var_tmp_phonetic, par_chinese_name => par_chi_name,
                                        pas_return_code => var_return_code);
        /* 2006-12-12 Addeded by HK Fong SMR20015887 - Start */
        IF COALESCE(par_chi_name, '') <> '' THEN
            BEGIN
                CALL cpi_check_schi_name(pas_return_code => pas_return_code, par_ccc1 => par_ccc_1,
                                         par_ccc2 => par_ccc_2, par_ccc3 => par_ccc_3, par_ccc4 => par_ccc_4,
                                         par_ccc5 => par_ccc_5, par_ccc6 => par_ccc_6,
                                         par_is_schi_name => var_is_schi_name);

                IF var_is_schi_name = 'Y' THEN
                    SELECT NULL
                    INTO par_chi_name;
                END IF;
            END;
        END IF;
        /* 2006-12-12 Addeded by HK Fong SMR20015887 - End */
        /* --	if (@name_soundex is null) */
        /* --		select	@name_soundex = soundex(@patient_name) */
        /* Validate key fields */

        IF (par_case_type = 'I') THEN
            BEGIN

                CALL cpi_pq_validate_ward(var_return_code, par_hospital_code, par_ward_code, par_ward_class,
                                          par_admission_datetime, var_valid_flag);

                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /*
                        print "Invalid ward information,
                        admission is rejected!"
                        */
                        SELECT 1021
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                CALL cpi_pq_validate_spec(var_return_code, par_hospital_code, par_specialty_code, par_case_type,
                                          par_admission_datetime, var_valid_flag);

                IF (var_valid_flag = 'N') THEN
                    BEGIN
                        /* print "Invalid specialty code, admission is rejected! */
                        SELECT 1022
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* Get replicated bit values */
        SELECT bit_value
        INTO var_rep_hospital
        FROM rep_cluster_bits
        WHERE hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF (sql$rowcount = 0) THEN
            BEGIN
                /*
                print "Fail to get bit values from cluster_bits,
                admission is rejected!"
                */
                SELECT 1001
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /* --	select	@init_source = bit_value */
        /* --	from	source_bits */
        /* --	where	source_system = @source_system */
        /* --	if (@@rowcount = 0) */
        /* --	begin */
        /* --		/*	print "Fail to get init. bit values from source_bits,*/ */
        /* --		admission is rejected!"* / */
        /* --		select	@success_flag = "N" */
        /* --		goto return_error */
        /* --	end */
        /* Check the existence of the case */
        SELECT COUNT(*)
        -- INTO var_cnt
        INTO result_int_value
        FROM cpi_case
        WHERE hospital_code = par_hospital_code
          AND case_no = par_case_no
          AND status_code != 'CC';
        IF FOUND THEN
            var_cnt := result_int_value;
        ELSE
            var_cnt := 0;
        END IF;
        raise notice 'par_hospital_code=%,par_case_no=%,var_cnt=%',par_hospital_code,par_case_no,var_cnt;
        IF var_cnt != 0 THEN
            BEGIN
                /*
                print "Case already exists in cpi_case,
                duplicate admission is rejected!"
                */
                SELECT 1002
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                raise notice '1002IF,var_cnt=%', var_cnt;
                EXIT return_error;
            END;
        END IF;

        SELECT COUNT(*)
        -- INTO var_cnt
        INTO result_int_value
        FROM cpi_case
        WHERE hospital_code = par_hospital_code
          AND case_no = par_case_no
          AND status_code = 'CC';
        IF FOUND THEN
            var_cnt := result_int_value;
        END IF;

        IF var_cnt = 1 THEN
            BEGIN
                SELECT patient_key
                INTO var_prev_patient_key
                FROM cpi_case
                WHERE hospital_code = par_hospital_code
                  AND case_no = par_case_no
                  AND status_code = 'CC';
                SELECT hkid
                INTO var_prev_hkid
                FROM cpi_patient
                WHERE patient_key = var_prev_patient_key;

                IF (var_prev_hkid != par_hkid) THEN
                    BEGIN
                        /*
                        print 'Do not allow re-admit patient not equal
                        to previous cancelled case, re-admission is rejected!'
                        */
                        SELECT 1003
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        /* 20061108 YL - Check there exist a case with source indicator = 8 (new born) if this is a new born admission case */
        raise notice 'cpi_admission[623]hkid=%', par_hkid;
        IF par_source_indicator = '8' THEN
            BEGIN
                SELECT COUNT(*)
                -- INTO var_cnt
                INTO result_int_value
                FROM cpi_patient AS p,
                     cpi_case AS c
                WHERE p.hkid = par_hkid
                  AND p.patient_key = c.patient_key
                  AND c.source_indicator = '8'
                  AND c.status_code != 'CC';
                IF FOUND THEN
                    var_cnt := result_int_value;
                END IF;

                IF var_cnt != 0 THEN
                    BEGIN
                        /*
                        Print 'Registration for one patient with more than one case
                        with Source Indicator = "8" is not allowed, admission is rejected!'
                        */
                        SELECT 1023
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        /* New patient */
        /* --	if (@patient_key is null) */
        /* --	begin */
        /*
        Check to see whether HKID exists in cpi_patient.
        If HKID exists, get the patient_key as the patient_key
        for admission
        */
        SELECT patient_key,
               rep_clusters
        INTO var_new_patient_key, var_rep_clusters
        FROM cpi_patient
        WHERE hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            SELECT count(1)into var_row_count
        
        FROM cpi_patient
        WHERE hkid = par_hkid;
raise notice '639var_row_count=%',var_row_count;

        IF (sql$rowcount = 1) THEN
            BEGIN
                /*
                print "HKID already exists in cpi_patient,
                use it as the patient_key for admission!"
                */
                SELECT 1004
                INTO var_return_error_code;
                SELECT var_new_patient_key
                INTO par_patient_key;
                SELECT var_rep_clusters | var_rep_hospital
                INTO var_rep_clusters;
                SELECT CAST(par_patient_key AS INTEGER)
                INTO var_patient_no;

                /* update patient information */
                begin
					raise notice 'cpi_admission=653';
                    UPDATE cpi_patient
                    SET patient_name      = par_patient_name,
                        sex               = par_sex,
                        cccode1           = par_ccc_1,
                        cccode2           = par_ccc_2,
                        cccode3           = par_ccc_3,
                        cccode4           = par_ccc_4,
                        cccode5           = par_ccc_5,
                        cccode6           = par_ccc_6,
                        chi_name          = par_chi_name,
                        dob               = par_dob,
                        exact_dob_flag    = par_exact_dob_flag,
                        marital_status    = par_marital_status,
                        race              = par_race_code,
                        other_doc_no      = par_other_document_no,
                        reference         = par_reference,
                        building          = par_building,
                        room              = par_room,
                        floor             = par_floor,
                        block             = par_block,
                        district          = par_district_code,
                        religion          = par_religion_code,
                        phone1            = par_phone1,
                        phone2            = par_phone2,
                        address_indicator = par_address_indicator,
                        mobile_phone      = par_mobile_phone,
                        sms_language      = par_sms_language,
                        death_indicator   = par_death_indicator,
                        death_date        = par_death_date,
                        death_code        = par_death_code,
                        card_holder       = par_card_holder,
                        /* --				access_code = @pmi_access_code, */
                        security          = par_security_count,
                        patient_no        = var_patient_no,
                        update_hospital   = par_hospital_code,
                        update_by         = par_update_by,
                        update_dtm        = timestamp_convert(par_transaction_datetime),
                        rep_clusters      = var_rep_clusters,
                        hkic_symbol       = par_hkic_symbol
                    WHERE patient_key = par_patient_key;
                    RAISE NOTICE 'Patient Name: %', par_patient_name;

                    raise notice 'cpi_admission(680)[UPDATE]cpi_patient,par_patient_key=%',par_patient_key;
                    var_error := 0;
                    /* EXCEPTION
                         WHEN OTHERS then
                             var_error := 1;*/
                END;

                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;
                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /*
                        print "Fail to update patient record,
                        admission is rejected!"
                        */
                        SELECT 1005
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;

                /* update nok record */
                IF (par_nok_name IS NOT NULL) THEN
                    BEGIN
                        SELECT priority
                        INTO par_priority
                        FROM cpi_nok
                        WHERE patient_key = par_patient_key
                          AND major_nok = 'Y';
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF (sql$rowcount = 0) THEN
                            BEGIN
                                /* insert new nok if major nok is not found */
                                SELECT 1
                                INTO var_n_prior;
                                SELECT COUNT(*)
                                -- INTO var_cnt
                                INTO result_int_value
                                FROM cpi_nok
                                WHERE patient_key = par_patient_key;
                                IF FOUND THEN
                                    var_cnt := result_int_value;
                                END IF;

                                IF (var_cnt != 0) THEN
                                    BEGIN
                                        SELECT MAX(priority) + 1
                                        INTO var_n_prior
                                        FROM cpi_nok
                                        WHERE patient_key = par_patient_key;
                                        SELECT var_n_prior
                                        INTO par_priority;
                                    END;
                                END IF;
                                /* No major_NOK, so set this to "Y" */
                                SELECT 'Y'
                                INTO var_major_nok;

                                BEGIN
                                    INSERT INTO cpi_nok (patient_key, priority, major_nok, hkid, relationship, nok_name,
                                                         building, room, floor, block, district, phone1, phone2,
                                                         address_indicator, mobile_phone, sms_language, update_hospital,
                                                         update_by, update_dtm)
                                    VALUES (par_patient_key, var_n_prior, var_major_nok, par_nok_hkid,
                                            par_nok_relation_code, par_nok_name, par_nok_building, par_nok_room,
                                            par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1,
                                            par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone,
                                            par_nok_sms_language, par_hospital_code, par_update_by,
                                            par_transaction_datetime);
                                    raise notice 'cpi_admission(746)[INSERT]cpi_nok-patient_key=%',par_patient_key;
                                    var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS then
                                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                                        raise notice '%',error_message;
                                        var_error := 1;
                                END;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                var_rowcount := sql$rowcount;
                                raise notice 'var_rowcount=%',var_rowcount;
                                IF (var_error != 0) OR (var_rowcount = 0) THEN
                                    BEGIN
                                        /*
                                        print "Fail to insert into cpi_nok,
                                        admission is rejected!"
                                        */
                                        SELECT 1006
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                /*
                                As this is the major_nok,
                                set it for transaction use
                                */
                                SELECT 'Y'
                                INTO var_major_nok;

                                BEGIN
                                    UPDATE cpi_nok
                                    SET relationship      = par_nok_relation_code,
                                        nok_name          = par_nok_name,
                                        hkid              = par_nok_hkid,
                                        building          = par_nok_building,
                                        room              = par_nok_room,
                                        floor             = par_nok_floor,
                                        block             = par_nok_block,
                                        district          = par_nok_district_code,
                                        phone1            = par_nok_phone1,
                                        phone2            = par_nok_phone2,
                                        address_indicator = par_nok_address_indicator,
                                        mobile_phone      = par_nok_mobile_phone,
                                        sms_language      = par_nok_sms_language,
                                        update_hospital   = par_hospital_code,
                                        update_by         = par_update_by,
                                        update_dtm        = par_transaction_datetime
                                    WHERE patient_key = par_patient_key
                                      AND priority = par_priority;
                                    raise notice 'cpi_admission(785)[UPDATE]cpi_nok,patient_key=%',par_patient_key;
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
                                        print "Fail to update cpi_nok,
                                        admission is rejected!"
                                        */
                                        SELECT 1008
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;

                                IF ('ADT' = par_source_system) THEN
                                    BEGIN
                                        IF NOT EXISTS (SELECT 1
                                                       FROM cpi_nok
                                                       WHERE patient_key = par_patient_key
                                                         AND priority = 1) THEN
                                            BEGIN
                                                BEGIN
                                                    UPDATE cpi_nok
                                                    SET priority = 1
                                                    WHERE patient_key = par_patient_key
                                                      AND priority = par_priority;
                                                    raise notice 'cpi_admission(821)[UPDATE]cpi_nok,patient_key=%',par_patient_key;
                                                    var_error := 0;
                                                EXCEPTION
                                                    WHEN OTHERS THEN
                                                        var_error := 1;
                                                END;
                                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                                var_rowcount := sql$rowcount;

                                                IF (var_rowcount != 0) THEN
                                                    SELECT 1
                                                    INTO par_priority;
                                                END IF;

                                                IF (var_error != 0) OR (var_rowcount = 0) THEN
                                                    BEGIN
                                                        SELECT 7006
                                                        INTO var_return_error_code;
                                                        SELECT 'N'
                                                        INTO var_success_flag;
                                                        EXIT return_error;
                                                    END;
                                                END IF;
                                            END;
                                        END IF;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        BEGIN
                            DELETE
                            FROM cpi_nok
                            WHERE patient_key = par_patient_key
                              AND major_nok = 'Y';
                            raise notice 'cpi_admission(859)[DELETE]cpi_nok,patient_key=%',par_patient_key;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) THEN
                            BEGIN
                                SELECT 11005
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;

                        IF EXISTS (SELECT *
                                   FROM cpi_nok
                                   WHERE patient_key = par_patient_key) THEN
                            BEGIN
                                SELECT MIN(priority)
                                INTO var_tmp_priority
                                FROM cpi_nok
                                WHERE patient_key = par_patient_key;

                                BEGIN
                                    UPDATE cpi_nok
                                    SET major_nok = 'Y'
                                    WHERE patient_key = par_patient_key
                                      AND priority = var_tmp_priority;
                                    raise notice 'cpi_admission(895)[UPDATE]cpi_nok,patient_key=%',par_patient_key;
                                    var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                                END;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                var_rowcount := sql$rowcount;

                                IF (var_error != 0) OR var_rowcount != 1 THEN
                                    BEGIN
                                        SELECT 11007
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;
                                SELECT priority,
                                       major_nok,
                                       nok_name,
                                       hkid,
                                       relationship,
                                       building,
                                       room,
                                       floor,
                                       block,
                                       district,
                                       phone1,
                                       phone2,
                                       address_indicator,
                                       mobile_phone,
                                       sms_language
                                INTO par_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language
                                FROM cpi_nok
                                WHERE patient_key = par_patient_key
                                  AND major_nok = 'Y';
                            END;
                        ELSE
                            BEGIN
                                SELECT NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL
                                INTO par_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language;
                            END;
                        END IF;
                    END;
                END IF;
                /* insert or update cpi_patient_hospital_data */
                SELECT COUNT(*)
                -- INTO var_cnt
                INTO result_int_value
                FROM cpi_patient_hospital_data
                WHERE hospital_code = par_hospital_code
                  AND patient_key = par_patient_key;
                IF FOUND THEN
                    var_cnt := result_int_value;
                END IF;

                IF (var_cnt = 0) THEN
                    BEGIN
                        /* Check duplication of mrn */
                        IF (par_medical_record_number IS NOT NULL) THEN
                            BEGIN
                                SELECT COUNT(*)
                                -- INTO var_cnt
                                INTO result_int_value
                                FROM cpi_patient_hospital_data
                                WHERE hospital_code = par_hospital_code
                                  AND mrn = par_medical_record_number;
                                IF FOUND THEN
                                    var_cnt := result_int_value;
                                END IF;

                                IF (var_cnt != 0) THEN
                                    BEGIN
                                        /*
                                        print "Duplicate mrn is found,
                                        admission is rejected!"
                                        */
                                        SELECT 1010
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                        END IF;

                        BEGIN
                            INSERT INTO cpi_patient_hospital_data (patient_key, hospital_code, mrn, remark, create_by,
                                                                   create_dtm, update_by, update_dtm)
                            VALUES (par_patient_key, par_hospital_code, par_medical_record_number, par_remark,
                                    par_update_by, par_transaction_datetime, par_update_by, par_transaction_datetime);
                            var_error := 0;
                            raise notice 'cpi_admission(970)[INSERT]cpi_patient_hospital_data,patient_key=%',par_patient_key;
                        EXCEPTION
                            WHEN OTHERS then
                                GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                                raise notice 'error_message=%',error_message;

                                var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                /*
                                print "Fail to insert cpi_patient_hospital_data,
                                admission is rejected!"
                                */
                                SELECT 1011
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        /* Check duplication of mrn */
                        SELECT mrn
                        INTO var_tmp_mrn
                        FROM cpi_patient_hospital_data
                        WHERE patient_key = par_patient_key
                          AND hospital_code = par_hospital_code;

                        IF (par_medical_record_number IS NOT NULL) AND (var_tmp_mrn != par_medical_record_number) THEN
                            BEGIN
                                SELECT COUNT(*)
                                -- INTO var_cnt
                                INTO result_int_value
                                FROM cpi_patient_hospital_data
                                WHERE mrn = par_medical_record_number
                                  AND hospital_code = par_hospital_code;
                                IF FOUND THEN
                                    var_cnt := result_int_value;
                                END IF;

                                IF (var_cnt != 0) THEN
                                    BEGIN
                                        /*
                                        print "Duplicate mrn is found,
                                        admission is rejected!"
                                        */
                                        SELECT 1010
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                        END IF;

                        BEGIN
                            UPDATE cpi_patient_hospital_data
                            SET mrn        = par_medical_record_number,
                                remark     = par_remark,
                                update_by  = par_update_by,
                                update_dtm = par_transaction_datetime
                            /* --	where	patient_key = @patient_key */
                            WHERE hospital_code = par_hospital_code
                              AND patient_key = par_patient_key;
                            raise notice 'cpi_admission(1037)[UPDATE]cpi_patient_hospital_data,patient_key=%',par_patient_key;
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
                                print "Fail to update cpi_patient_hospital_data,
                                admission is rejected!"
                                */
                                SELECT 1020
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        ELSE
            BEGIN
                /* get new patient key, insert a new patient */
                /* --			save transaction ins_patient */
                raise notice 'cpi_admission[1170]par_patient_key->%',par_patient_key;
                IF par_patient_key IS NULL THEN
                    begin
                        raise notice 'cpi_admission[1173] call cpi_pu_get_patient_key start';
                        CALL cpi_pu_get_patient_key(var_return_status, par_hospital_code, var_new_patient_key);
                       	RAISE NOTICE 'cpi_admission[1173] call cpi_pu_get_patient_key end ,var_new_patient_key = %',var_new_patient_key;

                        IF (var_return_status != 0) THEN
                            BEGIN
                                /*
                                print "Fail to get a new patient key,
                                admission with a new patient is rejected!"
                                */

                                SELECT 1012
                                INTO var_return_error_code;
                                SELECT var_return_status
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                        SELECT var_new_patient_key
                        INTO par_patient_key;
                    END;
                END IF;
                SELECT var_rep_hospital
                INTO var_rep_clusters;
                SELECT CAST(par_patient_key AS INTEGER)
                INTO var_patient_no;
                /* insert a new patient record */
                -- var_error is null :true
                /*
                 begin
                     gjp_text := '[' || coalesce(par_security_count::text,'NULL-par_security_count') || '#@#' || coalesce(par_source_system,'NULL-par_source_system') || '#@#' || coalesce(par_patient_key,'NULL-par_patient_key') || '#@#' || coalesce(par_hkid,'NULL-par_hkid') || '#@#' || coalesce(par_patient_name,'NULL-par_patient_name') || '#@#' || coalesce(par_sex,'NULL-par_sex') || '#@#' || coalesce(par_ccc_1,'NULL-par_ccc_1') || '#@#' || coalesce(par_ccc_2,'NULL-par_ccc_2') || '#@#' || coalesce(par_ccc_3,'NULL-par_ccc_3') || '#@#' || coalesce(par_ccc_4,'NULL-par_ccc_4') || '#@#' || coalesce(par_ccc_5,'NULL-par_ccc_5') || '#@#' || coalesce(par_ccc_6,'NULL-par_ccc_6') || '#@#' || coalesce(par_chi_name,'NULL-par_chi_name') || '#@#' || to_char(coalesce(par_dob,current_timestamp), 'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_exact_dob_flag,'NULL-par_exact_dob_flag') || '#@#' || coalesce(par_marital_status,'NULL-par_marital_status') || '#@#' || coalesce(par_race_code,'NULL-par_race_code') || '#@#' ||  coalesce(par_other_document_no,'NULL-par_other_document_no') || '#@#' ||  coalesce(par_reference, 'NULL-par_reference') || '#@#' || coalesce(par_building,'NULL-par_building') || '#@#' || coalesce(par_room,'NULL-par_room') || '#@#' || coalesce(par_floor,'NULL-par_floor') || '#@#' || coalesce(par_block,'NULL-par_block') || '#@#' || coalesce(par_district_code,'NULL-par_district_code') || '#@#' || coalesce(par_religion_code,'NULL-par_religion_code') || '#@#' || coalesce(par_phone1,'NULL-par_phone1') || '#@#' || coalesce(par_phone2,'NULL-par_phone2') || '#@#' || coalesce(par_address_indicator,'NULL-par_address_indicator') || '#@#' ||  coalesce(par_mobile_phone,'NULL-par_mobile_phone') || '#@#' || coalesce(par_sms_language,'NULL-par_sms_language') || '#@#' || coalesce(par_death_indicator,'NULL-par_death_indicator') || '#@#' || to_char(coalesce(par_death_date,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_death_code,'null-par_death_code') || '#@#' || coalesce(par_card_holder::text,'NULL-par_card_holder') || '#@#' || coalesce(var_patient_no::text,'NULL-var_patient_no') || '#@#' || coalesce(par_hospital_code,'NULL-par_hospital_code') || '#@#' || coalesce(par_update_by,'NULL-par_update_by') || '#@#' || to_char(coalesce(par_transaction_datetime,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_hospital_code,'NULL-par_hospital_code') || '#@#' || coalesce(par_update_by,'NULL-par_update_by') || '#@#' || to_char(coalesce(par_transaction_datetime,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(var_rep_clusters::text,'NULL-var_rep_clusters') || '#@#' || coalesce(par_hkic_symbol,'NULL-par_hkic_symbol') || ']';
                     insert into gjp_test(id,msg) values('240328N002',gjp_text);
                     commit;
                 end;
                 */
                BEGIN
	                RAISE NOTICE 'cpi_admission[1181] - start INSERT INTO cpi_patient';
                    IF (par_source_system IN ('DNL', 'OPAS')) THEN
                        /* For OPAS, don't insert default access_code */
                        INSERT INTO cpi_patient (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3,
                                                 cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag,
                                                 marital_status, race, other_doc_no, reference, building, room, floor,
                                                 block, district, religion, phone1, phone2, address_indicator,
                                                 mobile_phone, sms_language, death_indicator, death_date, death_code,
                                                 card_holder, security, patient_no, create_hospital, create_by,
                                                 create_dtm, update_hospital, update_by, update_dtm, rep_clusters,
                                                 hkic_symbol)
                        VALUES (par_patient_key, par_hkid, par_patient_name, par_sex, par_ccc_1, par_ccc_2, par_ccc_3,
                                par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_dob, par_exact_dob_flag,
                                par_marital_status, par_race_code, par_other_document_no, par_reference, par_building,
                                par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1,
                                par_phone2, par_address_indicator, par_mobile_phone, par_sms_language,
                                par_death_indicator, par_death_date, par_death_code, par_card_holder,
                                par_security_count, var_patient_no, par_hospital_code, par_update_by,
                                par_transaction_datetime, par_hospital_code, par_update_by, par_transaction_datetime,
                                var_rep_clusters, par_hkic_symbol);
                    else
                        /* For ADT, don't insert default security */

                        INSERT INTO cpi_patient (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3,
                                                 cccode4, cccode5, cccode6, chi_name, dob, exact_dob_flag,
                                                 marital_status, race, other_doc_no, reference, building, room, floor,
                                                 block, district, religion, phone1, phone2, address_indicator,
                                                 mobile_phone, sms_language, death_indicator, death_date, death_code,
                                                 card_holder,
                                                 patient_no, create_hospital, create_by, create_dtm, update_hospital,
                                                 update_by, update_dtm, rep_clusters, hkic_symbol)
                        VALUES (par_patient_key, par_hkid, par_patient_name, par_sex, par_ccc_1, par_ccc_2, par_ccc_3,
                                par_ccc_4, par_ccc_5, par_ccc_6, par_chi_name, par_dob, par_exact_dob_flag,
                                par_marital_status, par_race_code, par_other_document_no, par_reference, par_building,
                                par_room, par_floor, par_block, par_district_code, par_religion_code, par_phone1,
                                par_phone2, par_address_indicator, par_mobile_phone, par_sms_language,
                                par_death_indicator, par_death_date, par_death_code, par_card_holder,
                                var_patient_no, par_hospital_code, par_update_by, par_transaction_datetime,
                                par_hospital_code, par_update_by, par_transaction_datetime, var_rep_clusters,
                                par_hkic_symbol);

                    END IF;
                    var_error := 0;
                   	RAISE NOTICE 'cpi_admission[1181] - INSERT INTO cpi_patient done';
                EXCEPTION
                    WHEN OTHERS THEN
                    	RAISE NOTICE 'cpi_admission[1181] - INSERT INTO cpi_patient error => %',SQLERRM;
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /*
                        print "Fail to insert a new patient
                        record, admission is rejected!"
                        */
                        /* --				rollback transaction ins_patient */
                        SELECT 1013
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                /* insert nok record */
                IF (par_nok_name IS NOT NULL) THEN
                    BEGIN
                        SELECT 1
                        INTO var_n_prior;
                        SELECT var_n_prior
                        INTO par_priority;
                        SELECT 'Y'
                        INTO var_major_nok;

                        BEGIN
                            INSERT INTO cpi_nok (patient_key, priority, major_nok, hkid, relationship, nok_name,
                                                 building, room, floor, block, district, phone1, phone2,
                                                 address_indicator, mobile_phone, sms_language, update_hospital,
                                                 update_by, update_dtm)
                            VALUES (par_patient_key, var_n_prior, var_major_nok, par_nok_hkid, par_nok_relation_code,
                                    par_nok_name, par_nok_building, par_nok_room, par_nok_floor, par_nok_block,
                                    par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator,
                                    par_nok_mobile_phone, par_nok_sms_language, par_hospital_code, par_update_by,
                                    par_transaction_datetime);
                            raise notice 'cpi_admission(1293)[INSERT]cpi_nok,patient_key=%',par_patient_key;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS then
                                GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                                raise notice '%',error_message;
                                var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                /*
                                print "Fail to insert into cpi_nok,
                                admission is rejected!"
                                */
                                /* --					rollback transaction ins_patient */
                                SELECT 1006
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
                /* insert cpi_patient_hospital_data */
                /* Check duplication of mrn */
                IF (par_medical_record_number IS NOT NULL) THEN
                    BEGIN
                        SELECT COUNT(*)
                        -- INTO var_cnt
                        INTO result_int_value
                        FROM cpi_patient_hospital_data
                        /* --	where	hospital_code = @hospital_code */
                        WHERE mrn = par_medical_record_number
                          AND hospital_code = par_hospital_code;
                        IF FOUND THEN
                            var_cnt := result_int_value;
                        END IF;

                        IF (var_cnt != 0) THEN
                            BEGIN
                                /*
                                print "Duplicate mrn is found,
                                admission is rejected!"
                                */
                                /* --					rollback transaction ins_patient */
                                SELECT 1010
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;

                BEGIN
                    INSERT INTO cpi_patient_hospital_data (patient_key, hospital_code, mrn, remark, create_by,
                                                           create_dtm, update_by, update_dtm)
                    VALUES (par_patient_key, par_hospital_code, par_medical_record_number, par_remark, par_update_by,
                            par_transaction_datetime, par_update_by, par_transaction_datetime);
                    var_error := 0;
                    raise notice 'cpi_admission(1358)[INSERT]cpi_patient_hospital_data,patient_key=%',par_patient_key;
                EXCEPTION
                    WHEN OTHERS then
                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                        raise notice '[cpi_admission:1222]error_message=>%',error_message;
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /*
                        print "Fail to insert cpi_patient_hospital_data,
                        admission is rejected!"
                        */
                        /* --				rollback transaction ins_patient */
                        SELECT 1011
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
                /* commit transaction */
            END;
        END IF;
        /* --	end */
        /* --	else */
        /* --	begin */
        /* --		select	@cnt = count(*) */
        /* --		from	cpi_patient */
        /* --		where	patient_key = @patient_key */
        /* --		and	hkid = @hkid */
        /* --		if (@cnt = 0) */
        /* --		begin */
        /*
        print "Patient does not exist in patient record,
        admission is rejected!"
        */
        /* --			select	@return_error_code = 1014 */
        /* --			select	@success_flag = "N" */
        /* --			goto return_error */
        /* --		end */
        /* --		select	@rep_clusters = rep_clusters */
        /* --		from	cpi_patient */
        /* --		where	patient_key = @patient_key */
        /* --		select	@rep_clusters = @rep_clusters | @rep_hospital */
        /* --		select	@patient_no = convert(int, @patient_key) */
        /* update patient information */
        /* --		update	cpi_patient */
        /* --		set 	patient_name = @patient_name, */
        /* --			sex = @sex, */
        /* --			cccode1 = @ccc_1, */
        /* --			cccode2 = @ccc_2, */
        /* --			cccode3 = @ccc_3, */
        /* --			cccode4 = @ccc_4, */
        /* --			cccode5 = @ccc_5, */
        /* --			cccode6 = @ccc_6, */
        /* --			chi_name = @chi_name, */
        /* --			dob = @dob, */
        /* --			exact_dob_flag = @exact_dob_flag, */
        /* --			marital_status = @marital_status, */
        /* --			race = @race_code, */
        /* --			other_doc_no = @other_document_no, */
        /* --			reference = @reference, */
        /* --			building = @building, */
        /* --			room = @room, */
        /* --			floor = @floor, */
        /* --			block = @block, */
        /* --			district = @district_code, */
        /* --			religion = @religion_code, */
        /* --			phone1 = @phone1, */
        /* --			phone2 = @phone2, */
        /* --			address_indicator = @address_indicator, */
        /* --			mobile_phone = @mobile_phone, */
        /* --			sms_language = @sms_language, */
        /* --			death_indicator = @death_indicator, */
        /* --			death_date = @death_date, */
        /* --			death_code = @death_code, */
        /* --			card_holder = @card_holder, */
        /* --			access_code = @pmi_access_code, */
        /* --			security = @security_count, */
        /* --			patient_no = @patient_no, */
        /* --			update_hospital = @hospital_code, */
        /* --			update_by = @update_by, */
        /* --			update_dtm = @transaction_datetime, */
        /* --			rep_clusters = @rep_clusters */
        /* --		where	patient_key = @patient_key */
        /* --		select	@error = @@error, @rowcount = @@rowcount */
        /* --		if (@error != 0) or (@rowcount = 0) */
        /* --		begin */
        /*
        print "Fail to update patient record,
        admission is rejected!"
        */
        /* --			select	@return_error_code = 1015 */
        /* --			select	@success_flag = "N" */
        /* --			goto return_error */
        /* --		end */
        /* update nok record */
        /* --		if (@nok_name is not null) */
        /* --		begin */
        /* --			select	@priority = priority */
        /* --				from	cpi_nok */
        /* --				where	patient_key = @patient_key and */
        /* --						major_nok = 'Y' */
        /* --			if (@@rowcount = 0) */
        /* --			begin */
        /* --				/*	insert new nok if major nok is not found*/ */
        /* --				select 	@n_prior = 1 */
        /* --				select	@cnt = count(*) */
        /* --					from	cpi_nok */
        /* --					where	patient_key = @patient_key */
        /* --				if (@cnt ! = 0) */
        /* --				begin */
        /* --					select @n_prior = max(priority) + 1 */
        /* --						from	cpi_nok */
        /* --						where	patient_key = @patient_key */
        /* --					select	@priority = @n_prior */
        /* --				end */
        /* No major_NOK, so set this to "Y" */
        /* --				select	@major_nok = "Y" */
        /* --				insert cpi_nok */
        /* --				(patient_key, priority, major_nok, */
        /* --				hkid, relationship, */
        /* --				nok_name, building, room, */
        /* --				floor, block, */
        /* --				district, phone1, */
        /* --				phone2, */
        /* --				address_indicator, */
        /* --				mobile_phone, */
        /* --				sms_language, */
        /* --				update_hospital, */
        /* --				update_by, update_dtm) */
        /* --				values */
        /* --				(@patient_key, @n_prior, @major_nok, */
        /* --				@nok_hkid, @nok_relation_code, */
        /* --				@nok_name, @nok_building, @nok_room, */
        /* --				@nok_floor, @nok_block, */
        /* --				@nok_district_code, @nok_phone1, */
        /* --				@nok_phone2, */
        /* --				@nok_address_indicator, */
        /* --				@nok_mobile_phone, */
        /* --				@nok_sms_language, */
        /* --				@hospital_code, */
        /* --				@update_by, @transaction_datetime) */
        /* --				select @error = @@error, @rowcount = @@rowcount */
        /* --				if (@error != 0) or (@rowcount = 0) */
        /* --				begin */
        /*
        print "Fail to insert into cpi_nok,
        admission is rejected!"
        */
        /* --					select @return_error_code = 1006 */
        /* --					select @success_flag = "N" */
        /* --					goto return_error */
        /* --				end */
        /* --			end */
        /* --			else */
        /* --			begin */
        /* As this is the major_nok, set it for transaction use */
        /* --				select 	@major_nok = "Y" */
        /* --				update 	cpi_nok */
        /* --				set 	relationship = @nok_relation_code, */
        /* --					nok_name = @nok_name, */
        /* --					hkid = @nok_hkid, */
        /* --					building = @nok_building, */
        /* --					room = @nok_room, */
        /* --					floor = @nok_floor, */
        /* --					block = @nok_block, */
        /* --					district = @nok_district_code, */
        /* --					phone1 = @nok_phone1, */
        /* --					phone2 = @nok_phone2, */
        /* --					address_indicator = @nok_address_indicator, */
        /* --					mobile_phone = @nok_mobile_phone, */
        /* --					sms_language = @nok_sms_language, */
        /* --					update_hospital = @hospital_code, */
        /* --					update_by = @update_by, */
        /* --					update_dtm =  @transaction_datetime */
        /* --				where	patient_key = @patient_key */
        /* --				and	priority = @priority */
        /* --				select	@error = @@error, @rowcount = @@rowcount */
        /* --				if (@error != 0) or (@rowcount = 0) */
        /* --				begin */
        /*
        print "Fail to update cpi_nok,
        admission is rejected!"
        */
        /* --					select	@return_error_code = 1008 */
        /* --					select	@success_flag = "N" */
        /* --					goto return_error */
        /* --				end */
        /* --			end */
        /* --		end */
        /* --		else */
        /* --		begin */
        /* --				delete cpi_nok */
        /* --				where patient_key = @patient_key and */
        /* --						major_nok = 'Y' */
        /* --			select	@error = @@error, */
        /* --						@rowcount = @@rowcount */
        /* --			if (@error != 0) */
        /* --			begin */
        /* --				select	@return_error_code = 11005 */
        /* --				select	@success_flag = "N" */
        /* --				goto return_error */
        /* --			end */
        /* --			if exists */
        /* --					(select * */
        /* --					 from cpi_nok */
        /* --					 where patient_key = @patient_key) */
        /* --			begin */
        /* --				select @tmp_priority = min(priority) */
        /* --					 from cpi_nok */
        /* --					 where patient_key = @patient_key */
        /* --				update cpi_nok */
        /* --					set major_nok = 'Y' */
        /* --					where patient_key = @patient_key and */
        /* --							priority = @tmp_priority */
        /* --				select	@error = @@error, */
        /* --							@rowcount = @@rowcount */
        /* --				if (@error != 0) or @rowcount != 1 */
        /* --				begin */
        /* --					select	@return_error_code = 11007 */
        /* --					select	@success_flag = "N" */
        /* --					goto return_error */
        /* --				end */
        /* --				select @priority = priority, */
        /* --						 @major_nok = major_nok, */
        /* --						 @nok_name = nok_name, */
        /* --						 @nok_hkid = hkid, */
        /* --						 @nok_relation_code = relationship, */
        /* --						 @nok_building = building, */
        /* --						 @nok_room = room, */
        /* --						 @nok_floor = floor, */
        /* --						 @nok_block = block, */
        /* --						 @nok_district_code = district, */
        /* --						 @nok_phone1 = phone1, */
        /* --						 @nok_phone2 = phone2, */
        /* --						 @nok_address_indicator = address_indicator, */
        /* --						 @nok_mobile_phone = mobile_phone, */
        /* --						 @nok_sms_language = sms_language */
        /* --					from cpi_nok */
        /* --					where patient_key = @patient_key and */
        /* --							major_nok = 'Y' */
        /* --			end */
        /* --			else */
        /* --			begin */
        /* --				select @priority = null, */
        /* --						 @major_nok = null, */
        /* --						 @nok_name = null, */
        /* --						 @nok_hkid = null, */
        /* --						 @nok_relation_code = null, */
        /* --						 @nok_building = null, */
        /* --						 @nok_room = null, */
        /* --						 @nok_floor = null, */
        /* --						 @nok_block = null, */
        /* --						 @nok_district_code = null, */
        /* --						 @nok_phone1 = null, */
        /* --						 @nok_phone2 = null, */
        /* --						 @nok_address_indicator = null, */
        /* --						 @nok_mobile_phone = null, */
        /* --						 @nok_sms_language = null */
        /* --			end */
        /* --		end */
        /* insert or update cpi_patient_hospital_data */
        /* --		select	@cnt = count(*) */
        /* --		from	cpi_patient_hospital_data */
        /* -- */
        /* --		where	hospital_code = @hospital_code */
        /* --		and	patient_key = @patient_key */
        /* --		if (@cnt = 0) */
        /* --		begin */
        /* Check duplication of mrn */
        /* --			if (@medical_record_number is not null) */
        /* --			begin */
        /* --				select	@cnt = count(*) */
        /* --				from	cpi_patient_hospital_data */
        /* --				where	hospital_code = @hospital_code */
        /* --				and	mrn = @medical_record_number */
        /* --				if (@cnt != 0) */
        /* --				begin */
        /*
        print "Duplicate mrn is found,
        admission is rejected!"
        */
        /* --					select	@return_error_code = 1010 */
        /* --					select	@success_flag = "N" */
        /* --					goto return_error */
        /* --				end */
        /* --			end */
        /* --			insert cpi_patient_hospital_data */
        /* --			(patient_key, hospital_code, */
        /* --			mrn, remark, create_by, */
        /* --			create_dtm, update_by, */
        /* --			update_dtm) */
        /* --			values */
        /* --			(@patient_key, @hospital_code, */
        /* --			@medical_record_number, @remark, @update_by, */
        /* --			@transaction_datetime, @update_by, */
        /* --			@transaction_datetime) */
        /* --			select	@error = @@error, @rowcount = @@rowcount */
        /* --			if (@error != 0) or (@rowcount = 0) */
        /* --			begin */
        /*
        print "Fail to insert cpi_patient_hospital_data,
        admission is rejected!"
        */
        /* --				select	@return_error_code = 1011 */
        /* --				select	@success_flag = "N" */
        /* --				goto return_error */
        /* --			end */
        /* --		end */
        /* --		else */
        /* --		begin */
        /* Check duplication of mrn */
        /* --			select	@tmp_mrn = mrn */
        /* --			from	cpi_patient_hospital_data */
        /* --			where	patient_key = @patient_key */
        /* --			and	hospital_code = @hospital_code */
        /* --			if (@medical_record_number is not null) and */
        /* --			   (@tmp_mrn != @medical_record_number) */
        /* --			begin */
        /* --				select	@cnt = count(*) */
        /* --				from	cpi_patient_hospital_data */
        /* --				where	mrn = @medical_record_number */
        /* --				and	hospital_code = @hospital_code */
        /* --				if (@cnt != 0) */
        /* --				begin */
        /*
        print "Duplicate mrn is found,
        admission is rejected!"
        */
        /* --					select	@return_error_code = 1010 */
        /* --					select	@success_flag = "N" */
        /* --					goto return_error */
        /* --				end */
        /* --			end */
        /* --			update 	cpi_patient_hospital_data */
        /* --			set	mrn = @medical_record_number, */
        /* --				remark = @remark, */
        /* --				update_by = @update_by, */
        /* --				update_dtm = @transaction_datetime */
        /* --			where	patient_key = @patient_key */
        /* --			and	hospital_code = @hospital_code */
        /* --			select	@error = @@error, @rowcount = @@rowcount */
        /* --			if (@error != 0) or (@rowcount = 0) */
        /* --			begin */
        /*
        print "Fail to update cpi_patient_hospital_data,
        admission is rejected!"
        */
        /* --				select	@return_error_code = 1020 */
        /* --				select	@success_flag = "N" */
        /* --				goto return_error */
        /* --			end */
        /* --		end */
        /* --	end */
        /* --- add hospital code by WL on 16 AUG 99 for HPI -- */
        SELECT NULL
        INTO var_treatment_location;
       
        raise notice 'cpi_admission[1721]';

        IF par_case_type = 'I' THEN
            BEGIN
                /* Use sub-query instead of group by/having */
                SELECT treatment_location
                INTO var_treatment_location
                FROM ward
                WHERE hospital_code = par_hospital_code
                  AND ward_code = par_ward_code
                  AND effective_date = (SELECT MAX(effective_date)
                                        FROM ward
                                        WHERE hospital_code = par_hospital_code
                                          AND ward_code = par_ward_code
                                          AND effective_date <= par_admission_datetime
                                          AND active_status = 'A');
                /*
                effective_date <= @admission_datetime
                group by ward_code
                having effective_date = max(effective_date)
                and active_status = "A"
                */
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;

                IF (var_rowcount != 1) OR (var_error != 0) THEN
                    BEGIN
                        SELECT 1023
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* insert cpi_case */
        SELECT COUNT(*)
        -- INTO var_cnt
        INTO result_int_value
        FROM cpi_case
        WHERE hospital_code = par_hospital_code
          AND case_no = par_case_no;
        IF FOUND THEN
            var_cnt := result_int_value;
        END IF;

        IF par_txn_type = '090' THEN
            SELECT 2
            INTO var_movement_cnt;
        ELSE
            SELECT 1
            INTO var_movement_cnt;
        END IF;
        raise notice 'var_cnt=%',var_cnt;
        IF (var_cnt != 0) THEN
            /* It should be a cancelled case */
            BEGIN
                BEGIN
                    IF par_txn_type = '090' THEN
                        BEGIN
                            UPDATE cpi_case
                            SET status_code        = 'AC',
                                admission_dtm      = par_admission_datetime,
                                source_indicator   = par_source_indicator,
                                source_code        = par_source_code,
                                patient_type       = par_patient_type,
                                last_specialty     = par_specialty_code,
                                last_sub_specialty = par_sub_specialty,
                                last_ward_code     = par_ward_code,
                                last_ward_class    = par_ward_class,
                                last_bed_no        = par_bed_no,
                                discharge_dtm      = par_discharge_datetime,
                                discharge_code     = par_discharge_code,
                                update_by          = par_update_by,
                                update_dtm         = par_transaction_datetime,
                                movement_count     = var_movement_cnt,
                                district_code      = par_district_code,
                                pp_code            = par_pp_code
                            WHERE hospital_code = par_hospital_code
                              AND case_no = par_case_no
                              AND status_code = 'CC';
                            raise notice 'cpi_admission(1660)[UPDATE]cpi_case,case_no=%',par_case_no;
                        END;
                    ELSE
                        BEGIN
                            UPDATE cpi_case
                            SET status_code        = 'AC',
                                admission_dtm      = par_admission_datetime,
                                source_indicator   = par_source_indicator,
                                source_code        = par_source_code,
                                patient_type       = par_patient_type,
                                last_specialty     = par_specialty_code,
                                last_sub_specialty = par_sub_specialty,
                                last_ward_code     = par_ward_code,
                                last_ward_class    = par_ward_class,
                                last_bed_no        = par_bed_no,
                                update_by          = par_update_by,
                                update_dtm         = par_transaction_datetime,
                                movement_count     = var_movement_cnt,
                                district_code      = par_district_code,
                                pp_code            = par_pp_code
                            WHERE hospital_code = par_hospital_code
                              AND case_no = par_case_no
                              AND status_code = 'CC';
                            raise notice 'cpi_admission(1833)[UPDATE]cpi_case,case_no=%',par_case_no;
                        END;
                    END IF;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /* print "Fail to update cpi_case, admission is rejected!" */
                        SELECT 1016
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        ELSE
            begin
                raise notice 'var_cnt=%',var_cnt;
                /* --		save transaction ins_case */
                begin

                    INSERT INTO cpi_case (hospital_code, case_no, patient_key, case_type, admission_dtm,
                                          source_indicator, source_code, patient_type, discharge_code, discharge_dtm,
                                          destination_code, last_specialty, last_sub_specialty, last_ward_code,
                                          last_ward_class, last_bed_no, pp_code, access_code, status_code, create_by,
                                          create_dtm, update_by, update_dtm, movement_count, district_code,
                                          document_flag)
                    VALUES (par_hospital_code, par_case_no, par_patient_key, par_case_type, par_admission_datetime,
                            par_source_indicator, par_source_code, par_patient_type, par_discharge_code,
                            par_discharge_datetime, par_destination_code, par_specialty_code, par_sub_specialty,
                            par_ward_code, par_ward_class, par_bed_no, par_pp_code, par_case_access_code, 'AC',
                            par_update_by, par_transaction_datetime, par_update_by, par_transaction_datetime,
                            var_movement_cnt, par_district_code, par_document_flag);
                    raise notice 'cpi_admission(1873)[INSERT]cpi_case,case_no=%',par_case_no;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS then
                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                        raise notice '%',error_message;
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;
                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /*
                        print "Fail to insert into cpi_case,
                        admission is rejected!"
                        */
                        /* --			rollback transaction ins_case */
                        SELECT 1017
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* insert cpi_active_case */
        IF par_case_type IN ('I', 'A') THEN
            BEGIN
                IF par_txn_type = '090' THEN
                    SELECT 'N'
                    INTO var_active_ind;
                ELSE
                    SELECT 'Y'
                    INTO var_active_ind;
                END IF;

                BEGIN
                    IF EXISTS (SELECT *
                               FROM cpi_active_case
                               WHERE hospital_code = par_hospital_code
                                 AND case_no = par_case_no) THEN
                        UPDATE cpi_active_case
                        SET active_indicator = var_active_ind
                        WHERE hospital_code = par_hospital_code
                          AND case_no = par_case_no;
                        raise notice 'cpi_admission(1919)[UPDATE]cpi_active_case,case_no=%',par_case_no;
                    ELSE
                        INSERT INTO cpi_active_case (hospital_code, case_no, active_indicator)
                        VALUES (par_hospital_code, par_case_no, var_active_ind);
                        raise notice 'cpi_admission(1923)[INSERT]cpi_active_case,case_no=%',par_case_no;
                    END IF;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS then
                        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                        raise notice '%',error_message;
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;
                raise notice 'var_rowcount=%',var_rowcount;
                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /*
                        print "Fail to insert into cpi_active_case,
                        admission is rejected!"
                        */
                        SELECT 1025
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;

        BEGIN
            INSERT INTO cpi_movement (hospital_code, case_no, movement_count, ward_code, bed_no, specialty, ward_class,
                                      movement_type, movement_dtm, treatment_location, update_dtm, update_by,
                                      doctor_code)
            VALUES (par_hospital_code, par_case_no, 1, par_ward_code, par_bed_no, par_specialty_code, par_ward_class,
                    'A', par_admission_datetime, var_treatment_location, par_transaction_datetime, par_update_by, NULL);
            raise notice 'cpi_admission(1957)[INSERT]cpi_movement,case_no=%',par_case_no;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* --		rollback transaction ins_case */
                SELECT 14004
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
        /*
        For Conversion of Old Cases, insert ONE more Movement
        for handling discharge
        */
        IF (par_txn_type = '090') THEN
            BEGIN
                BEGIN
                    INSERT INTO cpi_movement (hospital_code, case_no, movement_count, ward_code, bed_no, specialty,
                                              ward_class, movement_type, movement_dtm, treatment_location, update_dtm,
                                              update_by, doctor_code)
                    VALUES (par_hospital_code, par_case_no, 2, par_ward_code, par_bed_no, par_specialty_code,
                            par_ward_class, 'D', par_discharge_datetime, var_treatment_location,
                            par_transaction_datetime, par_update_by, NULL);
                    raise notice 'cpi_admission(1809)[INSERT]cpi_movement,case_no=%',par_case_no;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /* rollback transaction ins_case */
                        SELECT 14004
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* insert ae_case_detail */
        IF (par_case_type = 'A') THEN
            BEGIN
                BEGIN
                    INSERT INTO cpi_ae_case_detail (case_no, hospital_code, ambulance_no, police_case, labour_case_flag,
                                                    ae_case_type, dba_flag, follow_up_datetime, eh_code,
                                                    pp_code) /* 20040315 SL */
                    VALUES (par_case_no, par_hospital_code, par_ambulance_no, par_police_case, par_labour_case,
                            par_ae_case_type, par_dba_flag, par_follow_up_datetime, par_eh_code, par_pp_code);
                    raise notice 'cpi_admission(1838)[INSERT]cpi_ae_case_detail,case_no=%',par_case_no;
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
                        print "Fail to insert cpi_ae_case_detail,
                        admission is rejected!"
                        */
                        /* --			rollback transaction ins_case */
                        SELECT 1018
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* insert HN_case_detail and Ward_list */
        raise notice 'cpi_admission[2043]';
       
        IF par_case_type = 'I' THEN
            BEGIN
                IF par_pp_code IS NOT NULL OR par_eh_code IS NOT NULL THEN
                    BEGIN
                        begin
                            INSERT INTO HN_case_detail (hospital_code, case_no, internal_icd9_code, external_icd9_code,
                                                        pp_code, eh_code)
                            VALUES (par_hospital_code, par_case_no, NULL, NULL, par_pp_code, par_eh_code);
                            raise notice 'cpi_admission(1873)[INSERT]HN_case_detail,case_no=%',par_case_no;
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
                                print "Fail to insert HN_case_detail,
                                admission is rejected!"
                                */
	                           
                                SELECT 1023
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF par_case_type IN ('A', 'I') AND par_txn_type <> '090' THEN
            BEGIN
                begin
	                raise notice 'cpi_admission-2056';
                    INSERT INTO Ward_list (hospital_code, case_no, ward_code, bed_no, specialty_code)
                    VALUES (par_hospital_code, par_case_no, par_ward_code, par_bed_no, par_specialty_code);
                    raise notice 'cpi_admission(1873)[INSERT]Ward_list,par_case_no=%',par_case_no;
                    var_error := 0;
                /*EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;*/
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /*
                        print "Fail to insert Ward_list,
                        admission is rejected!"
                        */
                        SELECT 1024
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /*
        20020726 SL: insert cpi_case_detail
        *
        * new error code : error_msgs.error_code=1031 - "Fail to insert cpi_case_detail, admission is rejected!"
        * CPI ver : insert HHHadt_db..AE_case_detail/HN_case_detail.EH_code by hasp_admission
        * HPI ver: insert cpi_ae_case_detail/HN_case_detail.EH_code by cpi_admission
        */
        
        IF (par_case_type = 'A' OR par_case_type = 'I') AND
           (par_eh_code IS NOT NULL OR par_document_flag IS NOT NULL) THEN
            BEGIN
                BEGIN
                    INSERT INTO cpi_case_detail (hospital_code, case_no, reference, document_flag, eh_code, case_flag1,
                                                 case_flag2, case_code1, case_code2, case_filler)
                    VALUES (par_hospital_code, par_case_no, NULL, par_document_flag, par_eh_code, NULL, NULL, NULL,
                            NULL, NULL);
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                    var_rowcount := sql$rowcount;
                    raise notice 'cpi_admission(1938)[INSERT]cpi_case_detail,case_no=%',par_case_no;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS then
                        BEGIN
                            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                            raise notice 'insert cpi_case_detail error: %', error_message;
                            var_error := 1;
                        END;
                END;
                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        /*
                        print "Fail to insert cpi_case_detail,
                        admission is rejected!"
                        */
                        SELECT 1031
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        EXIT return_error;
                    END;
                END IF;
            END;
        END IF;
        /* *************** 20070329 SL cpi_linked_case ********************** */
        /* Only enabled for IPAS, exclude OPAS/PBRC/DNL,etc */
        raise notice 'par_source_system=% par_case_type=% par_source_hosp_code=% par_source_case_no=%',par_source_system,par_case_type,par_source_hosp_code,par_source_case_no;
        IF (par_source_system <> 'DNL') AND (par_case_type IN ('A', 'I')) THEN
            BEGIN
                /* --- if Linked episode passed in ---- */
                IF (par_source_hosp_code IS NOT NULL) AND (par_source_case_no IS NOT NULL) THEN
                    BEGIN
                        IF NOT EXISTS (SELECT *
                                       FROM cpi_case
                                       WHERE case_no = par_case_no
                                         AND hospital_code = par_hospital_code
                                         AND status_code = 'AC') THEN
                            BEGIN
                                SELECT 200038
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                raise notice 'cpi_admission 200038 par_case_no=%,par_hospital_code=%',par_case_no,par_hospital_code;

                                EXIT return_error;
                            END;
                        END IF;

                        IF EXISTS (SELECT *
                                   FROM cpi_linked_case
                                   WHERE hospital_code = par_hospital_code
                                     AND case_no = par_case_no)
                            /* ---      and previous_hospital = @source_hosp_code */
                            /* ---      and previous_case = @source_case_no */
                        THEN
                            BEGIN
                                SELECT 200038
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                raise notice 'select cpi_linked_case error';

                                EXIT return_error;
                            END;
                        END IF;
                        /* Check the input Source_case belong to same patient or not */
                        /* check Local Firstly */
                        IF par_hospital_code = par_source_hosp_code THEN
                            BEGIN
                                SELECT patient_key
                                INTO var_lnk_case_patient_key
                                FROM cpi_case
                                WHERE hospital_code = par_source_hosp_code
                                  AND case_no = par_source_case_no
                                  AND status_code = 'AC';
                                raise notice 'select cpi_case error var_lnk_case_patient_key=% par_patient_key=% par_source_case_no=%',var_lnk_case_patient_key,par_patient_key,par_source_case_no;
                                IF var_lnk_case_patient_key <> par_patient_key THEN
                                    BEGIN
                                        SELECT 200038
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;

                                        EXIT return_error;
                                    END;
                                END IF;
                            END;
                            /* ------ if @hospital_code = @source_hosp_code */
                        ELSE                            
                            BEGIN                                	                            
	                            -- replace_dblink_by_fdw	                    
	                            CALL hkpmi.cpi_pq_validate_caseno(var_return_code,par_source_case_no, par_source_hosp_code, var_valid_flag, par_hkid);
	                           	SET search_path TO hpi,public;
	                           	
	                           	IF COALESCE (var_valid_flag,'null') <> 'Y' THEN
	                           		SELECT 200038
	                                INTO var_return_error_code;
	                                SELECT 'N'
	                                INTO var_success_flag;
	                                EXIT return_error;
	                           	END IF;	 
	                        EXCEPTION 
	                        	WHEN OTHERS THEN
	                        		RAISE NOTICE 'error in CALL hkpmi.cpi_pq_validate_caseno , %',SQLERRM;
	                        		RAISE EXCEPTION '%','error in CALL hkpmi.cpi_pq_validate_caseno,' || SQLERRM;
                            END;
                        END IF;

                        BEGIN
                            INSERT INTO cpi_linked_case (hospital_code, case_no, previous_hospital, previous_case,
                                                         create_by, create_dtm, update_by, update_dtm)
                            VALUES (par_hospital_code, par_case_no, par_source_hosp_code, par_source_case_no,
                                    par_update_by, timestamp_convert(localtimestamp), par_update_by,
                                    timestamp_convert(localtimestamp));
                            raise notice 'cpi_admission(2091)[INSERT]cpi_linked_case,case_no=%',par_case_no;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF (var_error != 0) OR (var_rowcount = 0) THEN
                            BEGIN
                                SELECT 200038
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                EXIT return_error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* ***************** EOF 20070329 SL ***************************** */
        /* insert cpi_transaction */
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
        */
        /* 20051006 : avoid upload problem : 260 before 100 */
        SELECT timestamp_convert(localtimestamp)
        INTO par_transaction_datetime;
        SELECT COUNT(*)
        -- INTO var_cnt
        INTO result_int_value
        FROM cpi_transaction
        WHERE hospital_code = par_hospital_code
          AND transaction_datetime = par_transaction_datetime;
        IF FOUND THEN
            var_cnt := result_int_value;
        END IF;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT 'N'
                INTO var_exit_flag;

                WHILE (var_exit_flag = 'N')
                    LOOP
                        SELECT 1 * INTERVAL '1 second' + par_transaction_datetime::TIMESTAMP
                        INTO par_transaction_datetime;
                        SELECT COUNT(*)
                        -- INTO var_cnt
                        INTO result_int_value
                        FROM cpi_transaction
                        WHERE hospital_code = par_hospital_code
                          AND transaction_datetime = par_transaction_datetime;
                        IF FOUND THEN
                            var_cnt := result_int_value;
                        END IF;

                        IF (var_cnt = 0) THEN
                            SELECT 'Y'
                            INTO var_exit_flag;
                        END IF;
                    END LOOP;
            END;
        END IF;
        /*
        20020726 SL:
        *	cpi_filler: mrt_indicator=(1,1),document_flag=(2,1),eh_code=(3,8)
        */
        /*
        if @document_flag is null
        	select @cpi_filler = null
        else
        	select @cpi_filler = space(1) + @document_flag
        */
        /*
        if (@document_flag is null) and (@eh_code is null)
        	select @cpi_filler=null
        else
        begin
        	if @document_flag=null
        		select @document_flag=space(1)
        	if @eh_code=null
        		select @eh_code=space(8)

        	select @cpi_filler=space(1)+@document_flag+@eh_code
        end
        */
        /* 20020726 SL: */
        /* 20070331 SL Tx=100/300/121/341 : source_hosp_code = cpi_filler(11,3), source_case_no=cpi_filler(14,12) */
        SELECT CONCAT(REPEAT(' ', 1), SUBSTRING(CONCAT(par_document_flag, REPEAT(' ', 1)), 1, 1),
                      SUBSTRING(CONCAT(par_eh_code, REPEAT(' ', 8)), 1, 8),
                      SUBSTRING(CONCAT(par_source_hosp_code, REPEAT(' ', 3)), 1, 3),
                      SUBSTRING(CONCAT(par_source_case_no, REPEAT(' ', 12)), 1, 12), REPEAT(' ', 3),
                      SUBSTRING(CONCAT(par_hkic_symbol, REPEAT(' ', 1)), 1, 1))
        INTO var_cpi_filler; /* --hkic_symbol=cpi_filler(29,1) */

        IF (LTRIM(RTRIM(var_cpi_filler)) = '') OR (LTRIM(RTRIM(var_cpi_filler)) is NULL) THEN
            SELECT NULL
            INTO var_cpi_filler;
        END IF;
        /* 20070331 SL */
        BEGIN
            INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key,
                                         patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5,
                                         ccc_6, chi_name, marital_status, race_code, other_document_no, reference,
                                         medical_record_number, remark, building, room, floor, block, district_code,
                                         religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language,
                                         death_indicator, death_date, death_code, card_holder, priority, major_nok,
                                         nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor,
                                         nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator,
                                         nok_mobile_phone, nok_sms_language, case_no, admission_datetime,
                                         source_indicator, source_code, patient_type, discharge_code,
                                         discharge_datetime, destination_code, doctor_code, case_type, security_count,
                                         case_access_code, pmi_access_code, ambulance_no, police_case, labour_case,
                                         ae_case_type, dba_flag, follow_up_datetime, ward_code, specialty_code,
                                         sub_specialty_code, bed_no, ward_class, transfer_datetime, old_patient_key,
                                         old_name, old_hkid, old_sex, old_dob, old_ward_class, old_ward_code,
                                         old_specialty_code, old_bed_no, old_doctor_code, pp_code, update_hospital,
                                         update_by, update_datetime, source_system, success_indicator, upload_status,
                                         source_system_dtm, cpi_filler)
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_hkid, par_patient_key,
                    par_patient_name, par_sex, par_dob, par_exact_dob_flag, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4,
                    par_ccc_5, par_ccc_6, par_chi_name, par_marital_status, par_race_code, par_other_document_no,
                    par_reference, par_medical_record_number, par_remark, par_building, par_room, par_floor, par_block,
                    par_district_code, par_religion_code, par_phone1, par_phone2, par_address_indicator,
                    par_mobile_phone, par_sms_language, par_death_indicator, par_death_date, par_death_code,
                    par_card_holder, par_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code,
                    par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1,
                    par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language, par_case_no,
                    par_admission_datetime, par_source_indicator, par_source_code, par_patient_type, par_discharge_code,
                    par_discharge_datetime, par_destination_code, NULL, par_case_type, par_security_count,
                    par_case_access_code, NULL, par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type,
                    par_dba_flag, par_follow_up_datetime, par_ward_code, par_specialty_code, par_sub_specialty,
                    par_bed_no, par_ward_class, NULL, NULL, var_old_patient_name, NULL, var_old_sex, var_old_dob, NULL,
                    NULL, NULL, NULL, NULL, par_pp_code, par_hospital_code, par_update_by,
                    timestamp_convert(localtimestamp), par_source_system, var_success_flag, var_upload_status,
                    var_source_system_dtm, var_cpi_filler);
            raise notice 'cpi_admission(2193)[INSERT]cpi_transaction,hkid=%',par_hkid;
            var_error := 0;
       /* EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;*/
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /* print "Fail to insert into cpi_transaction for admission!" */
                SELECT 1019
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                EXIT return_error;
            END;
        END IF;
--  	EXCEPTION
--    WHEN others THEN
--        BEGIN
--            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
--	        raise notice 'cpi_admission error var_return_error_code=% error_message=%', var_return_error_code, error_message;
--			RAISE EXCEPTION 'cpi_admission execute failed,%',error_message;
--        END;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN
	        RAISE NOTICE 'var_success_flag = N,var_return_error_code => %, will raise exception',var_return_error_code;
--            raise exception '';
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

;ALTER PROCEDURE "cpi_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";