-- DROP PROCEDURE cpi_upload(inout int4);

CREATE OR REPLACE PROCEDURE cpi_upload(INOUT pas_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_upload_enable VARCHAR;
    var_rpc_name VARCHAR;
    var_return_code INTEGER;
    var_error INTEGER;
    var_failure_code INTEGER;
    var_move_episode_status VARCHAR;
    var_rpc_call VARCHAR;
    var_pgm_name VARCHAR;
    var_hkpmi_srvr VARCHAR;
    var_type VARCHAR;
    var_case_no VARCHAR;
    var_hkid VARCHAR;
    var_patient_name VARCHAR;
    var_sex VARCHAR;
    /* --@dob                   VARCHAR, */
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_dob_exact_flag VARCHAR;
    var_marital_status VARCHAR;
    var_patient_type VARCHAR;
    var_nationality VARCHAR;
    var_other_docu_no VARCHAR;
    var_address_room VARCHAR;
    var_address_floor VARCHAR;
    var_address_block VARCHAR;
    /* --@address_building       	char(37), */
    var_address_building VARCHAR;
    /* --@address_dist           	char(15), */
    var_address_dist VARCHAR;
    /* --@address_area           	char, */
    var_phone VARCHAR;
    var_other_phone VARCHAR(10);
    var_other_phone_ext VARCHAR(4);
    var_t_prk VARCHAR;
    var_hkpmi_tprk VARCHAR;
    var_nok_name VARCHAR(48);
    var_nok_hkid VARCHAR;
    var_nok_relation VARCHAR;
    var_nok_address_room VARCHAR;
    var_nok_address_floor VARCHAR;
    var_nok_address_block VARCHAR;
    var_nok_address_building VARCHAR(47);
    /* --@nok_address_dist       VARCHAR(15), */
    var_nok_address_dist VARCHAR(5);
    /* --@nok_address_area      VARCHAR, */
    var_nok_phone VARCHAR(10);
    var_nok_office_phone VARCHAR(10);
    var_nok_office_phone_ext VARCHAR;
    var_nok_other_phone VARCHAR(10);
    var_nok_other_phone_ext VARCHAR;
    /* --@adm_date               	char, */
    /* --@adm_time               	char, */
    var_source_indicator VARCHAR;
    var_source_code VARCHAR;
    /* --@dis_date               	char, */
    /* --@dis_time               	char, */
    var_ae_case_type VARCHAR;
    var_ae_labour_case VARCHAR;
    var_ae_ambulance VARCHAR;
    var_ae_police VARCHAR;
    var_ccc_1 VARCHAR;
    var_ccc_2 VARCHAR;
    var_ccc_3 VARCHAR;
    var_ccc_4 VARCHAR;
    var_ccc_5 VARCHAR;
    var_ccc_6 VARCHAR;
    var_mrn VARCHAR;
    /* --@temp_ward              	char, */
    var_religion VARCHAR;
    /* --@error_code             	char, */
    /* --@adm_diag               	char(15), */
    var_old_name VARCHAR(48);
    var_old_sex VARCHAR;
    /* --@old_dob               VARCHAR, */
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_hkid VARCHAR;
    var_old_ward_code VARCHAR;
    var_old_bed_no VARCHAR;
    var_old_specialty_code VARCHAR;
    var_old_ward_class VARCHAR;
    /* --@tmp_ward_code          	char, */
    /* --@tmp_bed_no             	char, */
    /* --@tmp_specialty_code     	char, */
    /* --@tmp_ward_class         	char(1), */
    var_ward_code VARCHAR(4);
    var_bed_no VARCHAR(5);
    var_specialty_code VARCHAR(4);
    var_ward_class VARCHAR(1);
    var_discharge_code VARCHAR(1);
    var_destination_code VARCHAR(5);
    var_case_type VARCHAR(1);
    var_user_id VARCHAR(8);
    var_hosp_code VARCHAR(3);
    var_doctor_code VARCHAR(8);
    var_old_doctor_code VARCHAR(8);
    var_pmi_access_code INTEGER;
    var_hkpmi_access_code INTEGER;
    var_security_count INTEGER;
    var_dba_flag VARCHAR(1);
    var_mrt_indicator VARCHAR(1); /* add mrt indicator */
    var_follow_up_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_document_flag VARCHAR(1);
    var_eh_code VARCHAR;
    var_old_patient_key VARCHAR;
    var_case_access_code INTEGER;
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_death_indicator VARCHAR(1);
    var_nb_old_prk VARCHAR(8);
    var_nb_case VARCHAR;
    var_nb_hosp VARCHAR(3);
    var_mo_hosp VARCHAR(3);
    var_old_mo_case VARCHAR;
    var_old_nb_case VARCHAR;
    var_source_hosp_code VARCHAR(3);
    var_source_case_no VARCHAR;
    var_body_category VARCHAR(1);
    var_hkic_symbol VARCHAR(1);
    var_hkic_symbol_clear VARCHAR(1);
    var_comm_parm1 VARCHAR(255);
    var_ws_adm_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_dis_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ws_tr_datetime TIMESTAMP WITHOUT TIME ZONE;
    /* --@ws_dob_datetime        datetime, */
    /* --@ws_old_dob_datetime    datetime, */
    var_ws_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    /* --@ws_time_colon          VARCHAR(8), */
    var_ws_event_type VARCHAR;
    var_ws_log VARCHAR(70);
    /* --@ws_org_hkid				char, */
    /* --@ws_temp_hkid				char, */
    /* --@ws_org_old_hkid			char, */
    /* --@org_type					char, */
    var_cnt INTEGER;
    var_stop_upload VARCHAR(1);
    var_prev_tran_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_source_system VARCHAR(5);
    var_sub_specialty_code VARCHAR(4);
    var_office_phone VARCHAR(10);
    var_office_ext VARCHAR(4);
    var_update_date VARCHAR(8);
    var_update_time VARCHAR(6);
    var_upload_errmsg VARCHAR(50);
    var_pp_code VARCHAR(8);
    var_uid_hkid VARCHAR;
    var_link_hkid VARCHAR;
    var_link_status VARCHAR;
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_update_hospital VARCHAR(3);
    var_error_msg VARCHAR(255);
    sql$rowcount BIGINT;
	var_return_hkid varchar;
	var_return_msg varchar;
	error_message text;
	p_refcurs refcursor;
	dblink_sql text;
	start_date TIMESTAMP WITHOUT TIME ZONE;
	end_date TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    /*
    ------------------------------------------------------------
    *  Store procedure: cpi_upload (HPI version)
    *  Purpose        : CPI Transaction Upload to ADT v1.0
    *  Last update    : 20-MAY-98
    * ------------------------------------------------------------
    * The description of upload_status:
    * F------Failed, rejected(R, for ADT)
    * Y------needed to upload(N, for ADT)
    * S------Success(S, for ADT)
    * P------Passed, no need to upload(P, for ADT)
    * K------Skip(K, for ADT)
    *
    *
    *
    *  Modification History -
    * Jan 1997 - Add routine to check the patient_key of HKPMI
    *            and v2 database. (Watson Tsui)
    * Feb 1997 - Change the move episode "040" rpc program from
    *            "IC10MOVE" to "IC15MOVE" for ADT records
    * Feb 1997 - Add move episode "040" rpc program "IC15MOVE"
    *            (same as ADT's) to OPAS
    * Api 1997 - Add routine to update the unmatched patient_key
    * Jul 1997 - Add upload '034' transaction to handle patient
    *				  confidentiality by Stephen CHAN
    * Aug 1997 - Add MRT indicator by Winnie Lau
    * Sep 1997 - do not upload tx if there is failed previous tx
    *            by Leo Lee
    * Dec 1997 - change to use common upload section for changed
    *					mainframe program will take out local db
    *            by Leo Lee
    * Dec 1997 - Add 010 for opas_upload
    * 				by Winnie Lau
    * Feb 1998 - Add 040 for opas_upload in common upload module
    * 			  and comment old upload module for '040'	by Leo Lee
    * Feb 1998 - do not check patient_key when the upload failed and
    *	           passed case
    * 			  by Leo Lee
    * May 1998 - HKPMI down sizing ( use rpc for all type upload )
    * 			  by Winnie LAU
    * Sep 1998 - re-upload if Msg = 300004 by Stephen CHAN
    * 19990719 - exit the program when @@error is not zero
    *            after calling HKPMI. It can prevent the
    *            program from looping to upload same record by Leo Lee
    * 20000502 - upload PMI DELETION tx (250) by Winnie LAU
    * LL001024 - add to ingore the error code 23505(duplicate key
    *            produce by inserting transaction_log) for system
    *             failure
    * 20011105 - add document verification flag by Philip Poon
    *  20020726 SL  -  tx=100,300,121,341 => eh_code = cpi_transaction.cpi_filler(3,8)
    *  20030612 SL - add new txn_type (260,261,262) for cpi_new_born's tx.
    *  20040812 CHU - add new txn_type 033 for death date/time
    *  20041101 LSCHU - add old patient key for 261 for updating new born prk
    *  20050622 LSCHU - call hkpmi_update_mother_baby_case for 26*
    * 20070331 SL - Linked episode
    * 20070808 YL - Add body_category and allow source_system = 'CMS'
    *20081202 SL  - new txn_type 265=update hkpmi_uid_table..
    * 20100928 SL - cpi_transaction.cpi_filler(29,1)
    * 20131009 Ricky Yuen - add move_episode_status for type ='040' CR 201300277
    -- 20171130 To prevent System Failure(Upload will be STOPPED) due to 515 error, marked this records as 'F'-failed
    * ------------------------------------------------------------
    */
    /* --- Declare variables for hkpmi down sizing --- */
    /* --- Instance variables for host interface --- */
    
    /*
    declare @system_date            	char,
    @system_time            	char,
    */
    /* --- Variables for formulating parameters --- */
    /* --- Working variables --- */
    
    /*
    declare @comm_tran_date        VARCHAR(8),
            @comm_tran_time        VARCHAR(6)
    
    declare @comm_sys_date        VARCHAR(8),
            @comm_sys_time        VARCHAR(6)
    */
    
    /* ---20101202 - CIS RPC */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of CIS_RPC_HANDLING clause of SET statement is not supported. Perform a manual conversion.]
    set cis_rpc_handling on
    */
    
    /*
    [3069 - Severity CRITICAL - Automatic conversion of TRANSACTIONAL_RPC clause of SET statement is not supported. Perform a manual conversion.]
    set transactional_rpc on
    */
	SELECT clock_timestamp() into start_date;
    raise notice 'start_date=>%',start_date;
    /* Init */
    SELECT
        'N'
        INTO var_hkic_symbol_clear;
    SELECT
        'N'
        INTO var_stop_upload;
	
    WHILE (var_stop_upload = 'N') LOOP
        <<check_status>>
        BEGIN
            SELECT
                COUNT(*)
                INTO var_cnt
                FROM upload_control_pg
                WHERE upload_enable = 'Y';
			raise notice '269var_cnt=%',var_cnt;
            IF (var_cnt = 0) THEN
                EXIT;
            END IF;
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 1
            */
            SELECT
                transaction_datetime, source_system, hospital_code
                INTO var_ws_system_datetime, var_source_system, var_hosp_code
                FROM cpi_transaction
                WHERE upload_status = 'Y'  limit 1;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
           	
            raise notice '285var_cnt=%',var_cnt;
            /* Winnie test */
            /* print "after read one record" */
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 0
            */
            IF var_cnt = 0 THEN
                begin
	                PERFORM pg_sleep(1);
                    CONTINUE;
                END;
            END IF;
            /* --- Get Gateway info --- */

            IF (var_source_system != 'ADT') AND (var_source_system != 'LRRDT') AND (var_source_system != 'PBRC') AND (var_source_system != 'OPAS') AND (var_source_system != 'CMS') THEN /* YL 20070820: for CMS to update body_category */
                BEGIN
                    UPDATE cpi_transaction
                    SET upload_status = 'P'
                        WHERE transaction_datetime = var_ws_system_datetime AND upload_status = 'Y';
                    CONTINUE;
                END;
            END IF;
            /* ---> select upload enable <---- */
            SELECT
                upload_enable
                INTO var_upload_enable
                FROM upload_control_pg
                WHERE hospital_code = var_hosp_code;
            /* --> get HKPMI server name <-- */
            SELECT
                RTRIM(hkpmi_server)
                INTO var_hkpmi_srvr
                FROM hkpmi_control;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount != 1 THEN
                BEGIN
                    RAISE NOTICE '...Cannot select HKPMI server name!!!...';
                    EXIT;
                END;
            END IF;
            SELECT
                var_hkpmi_srvr
                INTO var_rpc_call;
            /* ----> set LRRDT = ADT for upload ---- */
            IF var_source_system = 'LRRDT' THEN
                SELECT
                    'ADT'
                    INTO var_source_system;
            END IF;
            /* --- determine the rpc name --- */

            IF (var_upload_enable = 'N') THEN
                CONTINUE;
            END IF;
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 1 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 1
            */
            SELECT
                transaction_type, hkid, patient_name, sex,
                /* --@ws_dob_datetime      = dob, */
                dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, marital_status, race_code, other_document_no, medical_record_number, building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, patient_key, nok_name, nok_hkid, nok_relation_code, nok_room, nok_floor, nok_block, nok_building, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, case_no, admission_datetime, source_indicator, source_code, patient_type, discharge_code, discharge_datetime, transfer_datetime, destination_code, case_type, labour_case, police_case, ambulance_no, ae_case_type, ward_code, specialty_code, sub_specialty_code, bed_no, ward_class, old_name, old_hkid, old_sex, old_dob, old_ward_code, old_bed_no, old_specialty_code, old_ward_class, update_by, doctor_code, old_doctor_code, security_count, pmi_access_code, dba_flag, SUBSTRING(cpi_filler, 1, 1), SUBSTRING(cpi_filler, 2, 1), SUBSTRING(cpi_filler, 3, 8), pp_code, follow_up_datetime, old_patient_key, case_access_code, death_indicator, death_date, SUBSTRING(cpi_filler, 1, 8), SUBSTRING(cpi_filler, 11, 3), SUBSTRING(cpi_filler, 14, 3), SUBSTRING(cpi_filler, 17, 12), SUBSTRING(remark, 1, 12), SUBSTRING(remark, 13, 12), SUBSTRING(cpi_filler, 11, 3),
                /* --- only for 100/300/121/341 : NO conflict with @mo_hosp/@nb_case--- */
                SUBSTRING(cpi_filler, 14, 12), SUBSTRING(cpi_filler, 30, 1), LTRIM(RTRIM(cpi_filler)), /* for txn 265 ONLY */ update_datetime, /* for txn 265 */ update_hospital, /* for txn 265 */ SUBSTRING(cpi_filler, 29, 1), /* for txn 010/030/100/300 */ ward_class, /* for txn 030 ONLY */ cpi_filler
                INTO var_type, var_hkid, var_patient_name, var_sex, var_dob, var_dob_exact_flag, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_marital_status, var_nationality, var_other_docu_no, var_mrn, var_address_building, var_address_room, var_address_floor, var_address_block, var_address_dist, var_religion, var_phone, var_office_phone, var_office_ext, var_other_phone, var_other_phone_ext, var_t_prk, var_nok_name, var_nok_hkid, var_nok_relation, var_nok_address_room, var_nok_address_floor, var_nok_address_block, var_nok_address_building, var_nok_address_dist, var_nok_phone, var_nok_office_phone, var_nok_office_phone_ext, var_nok_other_phone, var_nok_other_phone_ext, var_case_no, var_ws_adm_datetime, var_source_indicator, var_source_code, var_patient_type, var_discharge_code, var_ws_dis_datetime, var_ws_tr_datetime, var_destination_code, var_case_type, var_ae_labour_case, var_ae_police, var_ae_ambulance, var_ae_case_type, var_ward_code, var_specialty_code, var_sub_specialty_code, var_bed_no, var_ward_class, var_old_name, var_old_hkid, var_old_sex, var_old_dob, var_old_ward_code, var_old_bed_no, var_old_specialty_code, var_old_ward_class, var_user_id, var_doctor_code, var_old_doctor_code, var_security_count, var_pmi_access_code, var_dba_flag, var_mrt_indicator, var_document_flag, var_eh_code, var_pp_code, var_follow_up_dtm, var_old_patient_key, var_case_access_code, var_death_indicator, var_death_date, var_nb_old_prk, var_mo_hosp, var_nb_hosp, var_nb_case, var_old_mo_case, var_old_nb_case, var_source_hosp_code, var_source_case_no, var_body_category, var_link_status, var_update_dtm, var_update_hospital, var_hkic_symbol, var_hkic_symbol_clear, var_move_episode_status /* for txn 040 ONLY 1 VARCHAR */
                FROM cpi_transaction
                WHERE hospital_code = var_hosp_code AND transaction_datetime = var_ws_system_datetime limit 1;
               --  and  transaction_type = '040'
            /* Winnie test */
            /* print "after read one record detail %1!", @type */
            /* set null if all space by Winnie LAU on 2 JUN 1998 */
            IF RTRIM(LTRIM(var_ccc_1)) = '' THEN
                SELECT
                    NULL
                    INTO var_ccc_1;
            END IF;

            IF RTRIM(LTRIM(var_ccc_2)) = '' THEN
                SELECT
                    NULL
                    INTO var_ccc_2;
            END IF;

            IF RTRIM(LTRIM(var_ccc_3)) = '' THEN
                SELECT
                    NULL
                    INTO var_ccc_3;
            END IF;

            IF RTRIM(LTRIM(var_ccc_4)) = '' THEN
                SELECT
                    NULL
                    INTO var_ccc_4;
            END IF;

            IF RTRIM(LTRIM(var_ccc_5)) = '' THEN
                SELECT
                    NULL
                    INTO var_ccc_5;
            END IF;

            IF RTRIM(LTRIM(var_ccc_6)) = '' THEN
                SELECT
                    NULL
                    INTO var_ccc_6;
            END IF;

            IF RTRIM(LTRIM(var_marital_status)) = '' THEN
                SELECT
                    NULL
                    INTO var_marital_status;
            END IF;

            IF RTRIM(LTRIM(var_nationality)) = '' THEN
                SELECT
                    NULL
                    INTO var_nationality;
            END IF;

            IF RTRIM(LTRIM(var_other_docu_no)) = '' THEN
                SELECT
                    NULL
                    INTO var_other_docu_no;
            END IF;

            IF RTRIM(LTRIM(var_mrn)) = '' THEN
                SELECT
                    NULL
                    INTO var_mrn;
            END IF;

            IF RTRIM(LTRIM(var_address_building)) = '' THEN
                SELECT
                    NULL
                    INTO var_address_building;
            END IF;

            IF RTRIM(LTRIM(var_address_room)) = '' THEN
                SELECT
                    NULL
                    INTO var_address_room;
            END IF;

            IF RTRIM(LTRIM(var_address_floor)) = '' THEN
                SELECT
                    NULL
                    INTO var_address_floor;
            END IF;

            IF RTRIM(LTRIM(var_address_block)) = '' THEN
                SELECT
                    NULL
                    INTO var_address_block;
            END IF;

            IF RTRIM(LTRIM(var_address_dist)) = '' THEN
                SELECT
                    NULL
                    INTO var_address_dist;
            END IF;

            IF RTRIM(LTRIM(var_religion)) = '' THEN
                SELECT
                    NULL
                    INTO var_religion;
            END IF;

            IF RTRIM(LTRIM(var_phone)) = '' THEN
                SELECT
                    NULL
                    INTO var_phone;
            END IF;

            IF RTRIM(LTRIM(var_office_phone)) = '' THEN
                SELECT
                    NULL
                    INTO var_office_phone;
            END IF;

            IF RTRIM(LTRIM(var_office_ext)) = '' THEN
                SELECT
                    NULL
                    INTO var_office_ext;
            END IF;

            IF RTRIM(LTRIM(var_other_phone)) = '' THEN
                SELECT
                    NULL
                    INTO var_other_phone;
            END IF;

            IF RTRIM(LTRIM(var_other_phone_ext)) = '' THEN
                SELECT
                    NULL
                    INTO var_other_phone_ext;
            END IF;

            IF RTRIM(LTRIM(var_nok_name)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_name;
            END IF;

            IF RTRIM(LTRIM(var_nok_hkid)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_hkid;
            END IF;

            IF RTRIM(LTRIM(var_nok_relation)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_relation;
            END IF;

            IF RTRIM(LTRIM(var_nok_address_room)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_address_room;
            END IF;

            IF RTRIM(LTRIM(var_nok_address_floor)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_address_floor;
            END IF;

            IF RTRIM(LTRIM(var_nok_address_block)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_address_block;
            END IF;

            IF RTRIM(LTRIM(var_nok_address_building)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_address_building;
            END IF;

            IF RTRIM(LTRIM(var_nok_address_dist)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_address_dist;
            END IF;

            IF RTRIM(LTRIM(var_nok_phone)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_phone;
            END IF;

            IF RTRIM(LTRIM(var_nok_office_phone)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_office_phone;
            END IF;

            IF RTRIM(LTRIM(var_nok_office_phone_ext)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_office_phone_ext;
            END IF;

            IF RTRIM(LTRIM(var_nok_other_phone)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_other_phone;
            END IF;

            IF RTRIM(LTRIM(var_nok_other_phone_ext)) = '' THEN
                SELECT
                    NULL
                    INTO var_nok_other_phone_ext;
            END IF;

            IF RTRIM(LTRIM(var_patient_type)) = '' THEN
                SELECT
                    NULL
                    INTO var_patient_type;
            END IF;

            IF RTRIM(LTRIM(var_destination_code)) = '' THEN
                SELECT
                    NULL
                    INTO var_destination_code;
            END IF;

            IF RTRIM(LTRIM(var_mrt_indicator)) = '' THEN
                SELECT
                    NULL
                    INTO var_mrt_indicator;
            END IF;

            IF RTRIM(LTRIM(var_document_flag)) = '' THEN
                SELECT
                    NULL
                    INTO var_document_flag;
            END IF;

            IF RTRIM(LTRIM(var_eh_code)) = '' THEN
                SELECT
                    NULL
                    INTO var_eh_code;
            END IF;

            IF RTRIM(LTRIM(var_old_patient_key)) = '' THEN
                SELECT
                    NULL
                    INTO var_old_patient_key;
            END IF;

            IF (RTRIM(LTRIM(var_source_hosp_code)) = '')  THEN
                SELECT
                    NULL
                    INTO var_source_hosp_code;
            END IF;

            IF (RTRIM(LTRIM(var_source_case_no)) = '') THEN
                SELECT
                    NULL
                    INTO var_source_case_no;
            END IF;

            IF (RTRIM(LTRIM(var_hkic_symbol)) = '')  THEN
                SELECT
                    NULL
                    INTO var_hkic_symbol;
            END IF;

            IF (RTRIM(LTRIM(var_hkic_symbol_clear)) = '') THEN
                SELECT
                    NULL
                    INTO var_hkic_symbol_clear;
            END IF;

            IF (RTRIM(LTRIM(var_move_episode_status)) = '') THEN
                SELECT
                    NULL
                    INTO var_move_episode_status;
            END IF;
            /* * prepare for check patient key * */
            SELECT
                var_t_prk
                INTO var_hkpmi_tprk;
            SELECT
                var_pmi_access_code
                INTO var_hkpmi_access_code;

            /* --> reset rpc name for each read cpi_tx record <-- */
            SELECT
                ''
                INTO var_rpc_name;
            /*
            select @rpc_name = space(8)
            	  select @user_id = @user_id + space(8)
            	  select @ws_org_hkid = @hkid
                 select @ws_org_old_hkid = @old_hkid
            	  select @hkid = substring(ltrim(@hkid)+space,1,12)
                 select @old_hkid = substring(ltrim(@old_hkid)+space,1,12)
                 select @dob = convert(char(8),@ws_dob_datetime,112)
            */
            SELECT
                SUBSTRING(var_type, 1, 2)
                INTO var_ws_event_type;
            /* check the cpi_suspend_upload_log for previous error */
            IF EXISTS (SELECT
                *
                FROM cpi_suspend_upload_log
                WHERE (COALESCE(hkid, 'CUR') = COALESCE(var_hkid, 'OLD') OR COALESCE(hkid, 'CUR') = COALESCE(var_old_hkid, 'OLD') OR COALESCE(case_no, 'CUR') = COALESCE(var_case_no, 'OLD') OR COALESCE(old_hkid, 'CUR') = COALESCE(var_old_hkid, 'OLD') OR COALESCE(old_hkid, 'CUR') = COALESCE(var_hkid, 'OLD')) AND (transaction_datetime < var_ws_system_datetime) AND (hospital_code = var_hosp_code)) THEN
                BEGIN
                    SELECT
                        CONCAT(var_type, ' ', var_case_no, ' ', var_hkid, ' ', var_ward_code, ' ', var_specialty_code, ' ', to_char(var_ws_adm_datetime,'YYYYMMDD HH24mi') )
                        INTO var_ws_log;
                    RAISE NOTICE 'PREV-FAIL: %', var_ws_log;
                    SELECT
                        999
                        INTO var_return_code;
                    EXIT check_status;
                END;
            ELSE
                /* --- Type 100 & 300: In-patient and A&E Registration --- */
            	raise notice 'var_type=%',var_type;
                IF (var_type = '100') OR (var_type = '300') OR (var_type = '090') THEN
                    BEGIN
                        SELECT
                            CONCAT(var_case_no, ' ', var_hkid, ' ', var_ward_code, ' ', var_specialty_code, ' ',concat(substring(to_char(var_ws_adm_datetime,'YYYY') ,1,2),' ',to_char(var_ws_adm_datetime,'HH24mi') ) )
                            INTO var_ws_log;

                        IF var_type = '090' THEN
                            BEGIN
                                SELECT
                                    CONCAT(var_ws_log, ' ',concat(substring(to_char(var_ws_adm_datetime,'YYYY') ,1,2),' ',to_char(var_ws_dis_datetime,'HH24mi') ) , var_discharge_code, ' ', var_destination_code)
                                    INTO var_ws_log;
                                RAISE NOTICE 'Conv/REG: %', var_ws_log;
                            END;
                        ELSE
                            RAISE NOTICE 'Adm/REG: %', var_ws_log;
                        END IF;
                        /* --- Update host --- */

                        SELECT
      						concat(schema_name,'.hkpmi_admission')  
						INTO var_pgm_name
						from hkpmi_control;
						raise notice 'call hkpmi_admission';
                        perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                        dblink_sql := 'call ' 
						|| var_pgm_name || '(' 
                        || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
						|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
						|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
						|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
						|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
						|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
						|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
						|| case when 	var_hkpmi_access_code	 is null then 0::int else var_hkpmi_access_code end || ','
						|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
						|| case when 	var_patient_name	 is null then 'null::bpchar' else concat('''', 	var_patient_name	, '''::bpchar') end || ','
						|| case when 	var_sex	 is null then 'null::bpchar' else concat('''', 	var_sex	, '''::bpchar') end || ','
						|| case when 	var_dob	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_dob	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
						|| case when 	var_dob_exact_flag	 is null then 'null::bpchar' else concat('''', 	var_dob_exact_flag	, '''::bpchar') end || ','
						|| case when 	var_ccc_1	 is null then 'null::bpchar' else concat('''', 	var_ccc_1	, '''::bpchar') end || ','
						|| case when 	var_ccc_2	 is null then 'null::bpchar' else concat('''', 	var_ccc_2	, '''::bpchar') end || ','
						|| case when 	var_ccc_3	 is null then 'null::bpchar' else concat('''', 	var_ccc_3	, '''::bpchar') end || ','
						|| case when 	var_ccc_4	 is null then 'null::bpchar' else concat('''', 	var_ccc_4	, '''::bpchar') end || ','
						|| case when 	var_ccc_5	 is null then 'null::bpchar' else concat('''', 	var_ccc_5	, '''::bpchar') end || ','
						|| case when 	var_ccc_6	 is null then 'null::bpchar' else concat('''', 	var_ccc_6	, '''::bpchar') end || ','
						|| case when 	var_marital_status	 is null then 'null::bpchar' else concat('''', 	var_marital_status	, '''::bpchar') end || ','
						|| case when 	var_nationality	 is null then 'null::bpchar' else concat('''', 	var_nationality	, '''::bpchar') end || ','
						|| case when 	var_other_docu_no	 is null then 'null::bpchar' else concat('''', 	var_other_docu_no	, '''::bpchar') end || ','
						|| case when 	var_address_building	 is null then 'null::bpchar' else concat('''', 	var_address_building	, '''::bpchar') end || ','
						|| case when 	var_address_room	 is null then 'null::bpchar' else concat('''', 	var_address_room	, '''::bpchar') end || ','
						|| case when 	var_address_floor	 is null then 'null::bpchar' else concat('''', 	var_address_floor	, '''::bpchar') end || ','
						|| case when 	var_address_block	 is null then 'null::bpchar' else concat('''', 	var_address_block	, '''::bpchar') end || ','
						|| case when 	var_address_dist	 is null then 'null::bpchar' else concat('''', 	var_address_dist	, '''::bpchar') end || ','
						|| case when 	var_religion	 is null then 'null::bpchar' else concat('''', 	var_religion	, '''::bpchar') end || ','
						|| case when 	var_phone	 is null then 'null::bpchar' else concat('''', 	var_phone	, '''::bpchar') end || ','
						|| case when 	var_office_phone	 is null then 'null::bpchar' else concat('''', 	var_office_phone	, '''::bpchar') end || ','
						|| case when 	var_office_ext	 is null then 'null::bpchar' else concat('''', 	var_office_ext	, '''::bpchar') end || ','
						|| case when 	var_other_phone	 is null then 'null::bpchar' else concat('''', 	var_other_phone	, '''::bpchar') end || ','
						|| case when 	var_other_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_other_phone_ext	, '''::bpchar') end || ','
						|| case when 	var_nok_name	 is null then 'null::bpchar' else concat('''', 	var_nok_name	, '''::bpchar') end || ','
						|| case when 	var_nok_hkid	 is null then 'null::bpchar' else concat('''', 	var_nok_hkid	, '''::bpchar') end || ','
						|| case when 	var_nok_relation	 is null then 'null::bpchar' else concat('''', 	var_nok_relation	, '''::bpchar') end || ','
						|| case when 	var_nok_address_building	 is null then 'null::bpchar' else concat('''', 	var_nok_address_building	, '''::bpchar') end || ','
						|| case when 	var_nok_address_room	 is null then 'null::bpchar' else concat('''', 	var_nok_address_room	, '''::bpchar') end || ','
						|| case when 	var_nok_address_floor	 is null then 'null::bpchar' else concat('''', 	var_nok_address_floor	, '''::bpchar') end || ','
						|| case when 	var_nok_address_block	 is null then 'null::bpchar' else concat('''', 	var_nok_address_block	, '''::bpchar') end || ','
						|| case when 	var_nok_address_dist	 is null then 'null::bpchar' else concat('''', 	var_nok_address_dist	, '''::bpchar') end || ','
						|| case when 	var_nok_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_phone	, '''::bpchar') end || ','
						|| case when 	var_nok_office_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_office_phone	, '''::bpchar') end || ','
						|| case when 	var_nok_office_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_nok_office_phone_ext	, '''::bpchar') end || ','
						|| case when 	var_nok_other_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_other_phone	, '''::bpchar') end || ','
						|| case when 	var_nok_other_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_nok_other_phone_ext	, '''::bpchar') end || ','
						|| case when 	var_mrn	 is null then 'null::bpchar' else concat('''', 	var_mrn	, '''::bpchar') end || ','
						|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
						|| case when 	var_case_type	 is null then 'null::bpchar' else concat('''', 	var_case_type	, '''::bpchar') end || ','
						|| case when 	var_security_count	 is null then 0::int else var_security_count end || ','
						|| case when 	var_ws_adm_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_adm_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
						|| case when 	var_source_indicator	 is null then 'null::bpchar' else concat('''', 	var_source_indicator	, '''::bpchar') end || ','
						|| case when 	var_source_code	 is null then 'null::bpchar' else concat('''', 	var_source_code	, '''::bpchar') end || ','
						|| case when 	var_patient_type	 is null then 'null::bpchar' else concat('''', 	var_patient_type	, '''::bpchar') end || ','
						|| case when 	var_ward_code	 is null then 'null::bpchar' else concat('''', 	var_ward_code	, '''::bpchar') end || ','
						|| case when 	var_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_specialty_code	, '''::bpchar') end || ','
						|| case when 	var_ward_class	 is null then 'null::bpchar' else concat('''', 	var_ward_class	, '''::bpchar') end || ','
						|| case when 	var_pp_code	 is null then 'null::bpchar' else concat('''', 	var_pp_code	, '''::bpchar') end || ','
						|| case when 	var_ae_ambulance	 is null then 'null::bpchar' else concat('''', 	var_ae_ambulance	, '''::bpchar') end || ','
						|| case when 	var_ae_police	 is null then 'null::bpchar' else concat('''', 	var_ae_police	, '''::bpchar') end || ','
						|| case when 	var_ae_labour_case	 is null then 'null::bpchar' else concat('''', 	var_ae_labour_case	, '''::bpchar') end || ','
						|| case when 	var_ae_case_type	 is null then 'null::bpchar' else concat('''', 	var_ae_case_type	, '''::bpchar') end || ','
						|| case when 	var_dba_flag	 is null then 'null::bpchar' else concat('''', 	var_dba_flag	, '''::bpchar') end || ','
						|| case when 	var_discharge_code	 is null then 'null::bpchar' else concat('''', 	var_discharge_code	, '''::bpchar') end || ','
						|| case when 	var_ws_dis_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_dis_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
						|| case when 	var_destination_code	 is null then 'null::bpchar' else concat('''', 	var_destination_code	, '''::bpchar') end || ','
						|| case when 	var_document_flag	 is null then 'null::bpchar' else concat('''', 	var_document_flag	, '''::bpchar') end || ','
						|| case when 	var_eh_code	 is null then 'null::bpchar' else concat('''', 	var_eh_code	, '''::bpchar') end || ','
						|| case when 	var_source_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_source_hosp_code	, '''::bpchar') end || ','
						|| case when 	var_source_case_no	 is null then 'null::bpchar' else concat('''', 	var_source_case_no	, '''::bpchar') end || ','
						|| case when 	var_hkic_symbol	 is null then 'null::bpchar' else concat('''', 	var_hkic_symbol	, '''::bpchar') end || ');';
						raise notice 'dblink_sql=%',dblink_sql;
--						EXIT check_status;
						select * from public.dblink('rpc_server'::text,dblink_sql::text)
										as t1(var_return_code int,var_hkpmi_tprk bpchar,var_hkpmi_access_code int)
										into var_return_code,var_hkpmi_tprk,var_hkpmi_access_code;
					perform public.dblink_disconnect('rpc_server'::text);
					exception
						when others then
						begin
						perform public.dblink_disconnect('rpc_server'::text);
						GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
						raise notice 'hkpmi_admission=>%',error_message;
						end;
					raise notice 'hkpmi_admission end';	
					EXIT check_status;
                    END;
                ELSE
                    IF var_type = '010' THEN
                        /* --- Type 010 : PMI Registration --- */
                        BEGIN
                            SELECT
                                CONCAT(var_hkid, ' ', CAST (var_patient_name AS VARCHAR(20)), ' ', var_sex, ' ',to_char(var_dob,'YYYYMMDD'))
                                INTO var_ws_log;
                            RAISE NOTICE 'PMI REG: %', var_ws_log;

                             SELECT
      							concat(schema_name,'.hkpmi_patient_create')  
							INTO var_pgm_name
							from hkpmi_control;
							raise notice 'call hkpmi_patient_create';
                            perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                           	dblink_sql := 'call ' 
							|| var_pgm_name || '(' 
                            || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
							|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
							|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
							|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
							|| case when 	var_patient_name	 is null then 'null::bpchar' else concat('''', 	var_patient_name	, '''::bpchar') end || ','
							|| case when 	var_sex	 is null then 'null::bpchar' else concat('''', 	var_sex	, '''::bpchar') end || ','
							|| case when 	var_dob	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_dob	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
							|| case when 	var_dob_exact_flag	 is null then 'null::bpchar' else concat('''', 	var_dob_exact_flag	, '''::bpchar') end || ','
							|| case when 	var_ccc_1	 is null then 'null::bpchar' else concat('''', 	var_ccc_1	, '''::bpchar') end || ','
							|| case when 	var_ccc_2	 is null then 'null::bpchar' else concat('''', 	var_ccc_2	, '''::bpchar') end || ','
							|| case when 	var_ccc_3	 is null then 'null::bpchar' else concat('''', 	var_ccc_3	, '''::bpchar') end || ','
							|| case when 	var_ccc_4	 is null then 'null::bpchar' else concat('''', 	var_ccc_4	, '''::bpchar') end || ','
							|| case when 	var_ccc_5	 is null then 'null::bpchar' else concat('''', 	var_ccc_5	, '''::bpchar') end || ','
							|| case when 	var_ccc_6	 is null then 'null::bpchar' else concat('''', 	var_ccc_6	, '''::bpchar') end || ','
							|| case when 	var_marital_status	 is null then 'null::bpchar' else concat('''', 	var_marital_status	, '''::bpchar') end || ','
							|| case when 	var_nationality	 is null then 'null::bpchar' else concat('''', 	var_nationality	, '''::bpchar') end || ','
							|| case when 	var_other_docu_no	 is null then 'null::bpchar' else concat('''', 	var_other_docu_no	, '''::bpchar') end || ','
							|| case when 	var_mrn	 is null then 'null::bpchar' else concat('''', 	var_mrn	, '''::bpchar') end || ','
							|| case when 	var_address_building	 is null then 'null::bpchar' else concat('''', 	var_address_building	, '''::bpchar') end || ','
							|| case when 	var_address_room	 is null then 'null::bpchar' else concat('''', 	var_address_room	, '''::bpchar') end || ','
							|| case when 	var_address_floor	 is null then 'null::bpchar' else concat('''', 	var_address_floor	, '''::bpchar') end || ','
							|| case when 	var_address_block	 is null then 'null::bpchar' else concat('''', 	var_address_block	, '''::bpchar') end || ','
							|| case when 	var_address_dist	 is null then 'null::bpchar' else concat('''', 	var_address_dist	, '''::bpchar') end || ','
							|| case when 	var_religion	 is null then 'null::bpchar' else concat('''', 	var_religion	, '''::bpchar') end || ','
							|| case when 	var_phone	 is null then 'null::bpchar' else concat('''', 	var_phone	, '''::bpchar') end || ','
							|| case when 	var_office_phone	 is null then 'null::bpchar' else concat('''', 	var_office_phone	, '''::bpchar') end || ','
							|| case when 	var_office_ext	 is null then 'null::bpchar' else concat('''', 	var_office_ext	, '''::bpchar') end || ','
							|| case when 	var_other_phone	 is null then 'null::bpchar' else concat('''', 	var_other_phone	, '''::bpchar') end || ','
							|| case when 	var_other_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_other_phone_ext	, '''::bpchar') end || ','
							|| case when 	var_patient_type	 is null then 'null::bpchar' else concat('''', 	var_patient_type	, '''::bpchar') end || ','
							|| case when 	var_hkpmi_access_code	 is null then 0::int else var_hkpmi_access_code end || ','
							|| case when 	var_nok_name	 is null then 'null::bpchar' else concat('''', 	var_nok_name	, '''::bpchar') end || ','
							|| case when 	var_nok_hkid	 is null then 'null::bpchar' else concat('''', 	var_nok_hkid	, '''::bpchar') end || ','
							|| case when 	var_nok_relation	 is null then 'null::bpchar' else concat('''', 	var_nok_relation	, '''::bpchar') end || ','
							|| case when 	var_nok_address_building	 is null then 'null::bpchar' else concat('''', 	var_nok_address_building	, '''::bpchar') end || ','
							|| case when 	var_nok_address_room	 is null then 'null::bpchar' else concat('''', 	var_nok_address_room	, '''::bpchar') end || ','
							|| case when 	var_nok_address_floor	 is null then 'null::bpchar' else concat('''', 	var_nok_address_floor	, '''::bpchar') end || ','
							|| case when 	var_nok_address_block	 is null then 'null::bpchar' else concat('''', 	var_nok_address_block	, '''::bpchar') end || ','
							|| case when 	var_nok_address_dist	 is null then 'null::bpchar' else concat('''', 	var_nok_address_dist	, '''::bpchar') end || ','
							|| case when 	var_nok_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_phone	, '''::bpchar') end || ','
							|| case when 	var_nok_office_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_office_phone	, '''::bpchar') end || ','
							|| case when 	var_nok_office_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_nok_office_phone_ext	, '''::bpchar') end || ','
							|| case when 	var_nok_other_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_other_phone	, '''::bpchar') end || ','
							|| case when 	var_nok_other_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_nok_other_phone_ext	, '''::bpchar') end || ','
							|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
							|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
							|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
							|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
							|| case when 	var_document_flag	 is null then 'null::bpchar' else concat('''', 	var_document_flag	, '''::bpchar') end || ','
							|| case when 	var_hkic_symbol	 is null then 'null::bpchar' else concat('''', 	var_hkic_symbol	, '''::bpchar') end || ');';
							raise notice 'dblink_sql=%',dblink_sql;
							select * from public.dblink('rpc_server'::text,dblink_sql::text)
							as t1(var_return_code int,var_hkpmi_tprk bpchar,var_hkpmi_access_code int)
							into var_return_code,var_hkpmi_tprk,var_hkpmi_access_code;
							perform public.dblink_disconnect('rpc_server'::text);
							exception
								when others then
									GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
									raise notice 'hkpmi_patient_create=>%',error_message;
									perform public.dblink_disconnect('rpc_server'::text);
							EXIT check_status;
                        END;
                    ELSE
                        IF var_ws_event_type = '13' OR var_ws_event_type = '33' THEN
                            /* --- Type 13% : In-patient discharge --- */
                            BEGIN
                                SELECT
                                    CONCAT(var_case_no, ' ', var_hkid, ' ', var_ward_code, ' ', var_specialty_code, ' ',to_char(var_ws_dis_datetime,'YYYYMMDD HH24mi') )
                                    INTO var_ws_log;
                                RAISE NOTICE 'Dischrg: %', var_ws_log;

                                SELECT
      								concat(schema_name,'.hkpmi_discharge')  
								INTO var_pgm_name
								from hkpmi_control;
                                raise notice 'call hkpmi_discharge';
                                perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                dblink_sql := 'call ' 
								|| var_pgm_name || '(' 
                                || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
								|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
								|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
								|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
								|| case when 	var_discharge_code	 is null then 'null::bpchar' else concat('''', 	var_discharge_code	, '''::bpchar') end || ','
								|| case when 	var_ws_dis_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_dis_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
								|| case when 	var_destination_code	 is null then 'null::bpchar' else concat('''', 	var_destination_code	, '''::bpchar') end || ','
								|| case when 	var_ward_code	 is null then 'null::bpchar' else concat('''', 	var_ward_code	, '''::bpchar') end || ','
								|| case when 	var_ward_class	 is null then 'null::bpchar' else concat('''', 	var_ward_class	, '''::bpchar') end || ','
								|| case when 	var_bed_no	 is null then 'null::bpchar' else concat('''', 	var_bed_no	, '''::bpchar') end || ','
								|| case when 	var_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_specialty_code	, '''::bpchar') end || ','
								|| case when 	var_doctor_code	 is null then 'null::bpchar' else concat('''', 	var_doctor_code	, '''::bpchar') end || ','
								|| case when 	var_mrt_indicator	 is null then 'null::bpchar' else concat('''', 	var_mrt_indicator	, '''::bpchar') end || ','
								|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
								|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
								|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
								|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
								|| case when 	var_body_category	 is null then 'null::bpchar' else concat('''', 	var_body_category	, '''::bpchar') end || ');';
								raise notice 'dblink_sql=%',dblink_sql;
								select * from public.dblink('rpc_server'::text,dblink_sql::text)
								as t1(return_code int)
								into var_return_code;
								perform public.dblink_disconnect('rpc_server'::text);
								exception
									when others then
										GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
										raise notice 'hkpmi_discharge=>%',error_message;
										perform public.dblink_disconnect('rpc_server'::text);
								/* --- Update host --- */
                                EXIT check_status;
                            END;
                        /* --- Type 140: Mass Transfer (out) --- */
                        /* Type 160: Trial Discharge     --- */
                        /* Type 170: Return from Trial Discharge --- */
                        /* Type 700: Bed assignment --- */
                        ELSE
                            IF (var_type = '140') OR (var_type = '160') OR (var_type = '170') OR (var_type = '700') THEN
                                BEGIN
                                    SELECT
                                        CONCAT(var_case_no, ' ', var_hkid, ' ', var_old_ward_code, ' ', var_old_specialty_code, ' ', var_old_bed_no, ' ', var_ward_code, ' ', var_specialty_code, ' ', var_bed_no, ' ',to_char(var_ws_dis_datetime,'YYYYMMDD HH24mi') )
                                        INTO var_ws_log;
                                    RAISE NOTICE 'Transfer: %', var_ws_log;

                                    SELECT
      									concat(schema_name,'.hkpmi_transfer')  
									INTO var_pgm_name
									from hkpmi_control;
									raise notice 'call hkpmi_transfer';
                                    perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                    dblink_sql := 'call ' 
									|| var_pgm_name || '(' 
                                    || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
									|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
									|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
									|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
									|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
									|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
									|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
									|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
									|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
									|| case when 	var_ws_tr_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_tr_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
									|| case when 	var_ward_code	 is null then 'null::bpchar' else concat('''', 	var_ward_code	, '''::bpchar') end || ','
									|| case when 	var_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_specialty_code	, '''::bpchar') end || ','
									|| case when 	var_ward_class	 is null then 'null::bpchar' else concat('''', 	var_ward_class	, '''::bpchar') end || ','
									|| case when 	var_bed_no	 is null then 'null::bpchar' else concat('''', 	var_bed_no	, '''::bpchar') end || ','
									|| case when 	var_old_ward_code	 is null then 'null::bpchar' else concat('''', 	var_old_ward_code	, '''::bpchar') end || ','
									|| case when 	var_old_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_old_specialty_code	, '''::bpchar') end || ','
									|| case when 	var_old_ward_class	 is null then 'null::bpchar' else concat('''', 	var_old_ward_class	, '''::bpchar') end || ','
									|| case when 	var_old_bed_no	 is null then 'null::bpchar' else concat('''', 	var_old_bed_no	, '''::bpchar') end || ','
									|| case when 	var_doctor_code	 is null then 'null::bpchar' else concat('''', 	var_doctor_code	, '''::bpchar') end || ');';
									raise notice 'dblink_sql=%',dblink_sql;
									select * from public.dblink('rpc_server'::text,dblink_sql::text)
									as t1(var_return_code int,var_hkpmi_tprk bpchar)
									into var_return_code,var_hkpmi_tprk;
									perform public.dblink_disconnect('rpc_server'::text);
										exception
												when others then
												GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
												raise notice 'hkpmi_transfer=>%',error_message;
												perform public.dblink_disconnect('rpc_server'::text);
									/* --- Update host --- */
                                    EXIT check_status;
                                END;
                            ELSE
                                /* --- Type 21% and 35% : Cancellation of discharge --- */
                                IF (var_ws_event_type = '21') OR (var_ws_event_type = '35') THEN
                                    BEGIN
                                        SELECT
                                            CONCAT(var_case_no, ' ', var_hkid, ' ', ' ', var_ward_code, ' ', var_specialty_code, ' ', to_char(var_ws_dis_datetime,'YYYYMMDD HH24mi') )
                                            INTO var_ws_log;
                                        RAISE NOTICE 'Canc Dis: %', var_ws_log;

                                        SELECT
      										concat(schema_name,'.hkpmi_cancel_discharge')  
										INTO var_pgm_name
										from hkpmi_control;
                                        raise notice 'call hkpmi_cancel_discharge';
                                        perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                        dblink_sql := 'call ' 
										|| var_pgm_name || '(' 
                                        || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
										|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
										|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
										|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
										|| case when 	var_ward_code	 is null then 'null::bpchar' else concat('''', 	var_ward_code	, '''::bpchar') end || ','
										|| case when 	var_ward_class	 is null then 'null::bpchar' else concat('''', 	var_ward_class	, '''::bpchar') end || ','
										|| case when 	var_bed_no	 is null then 'null::bpchar' else concat('''', 	var_bed_no	, '''::bpchar') end || ','
										|| case when 	var_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_specialty_code	, '''::bpchar') end || ','
										|| case when 	var_doctor_code	 is null then 'null::bpchar' else concat('''', 	var_doctor_code	, '''::bpchar') end || ','
										|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
										|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
										|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
										|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ');';
                                        raise notice 'dblink_sql=%',dblink_sql;
										select * from public.dblink('rpc_server'::text,dblink_sql::text)
										as t1(var_return_code int)
										into var_return_code;
										perform public.dblink_disconnect('rpc_server'::text);
										exception
											when others then
												GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
												raise notice 'hkpmi_cancel_discharge=>%',error_message;
												perform public.dblink_disconnect('rpc_server'::text);
										/* --- Update host --- */
                                        EXIT check_status;
                                    END;
                                /* --- Type 220: Cancellation of transfer --- */
                                
                                /* Type 230: Cancellation of trial discharge */
                                
                                /* Type 240: Cancellation of return from trial discharge */
                                
                                /* Type 710: Cancellation of bed assignment */
                                ELSE
                                    IF (var_type = '220') OR (var_type = '230') OR (var_type = '240') OR (var_type = '710') THEN
                                        BEGIN
                                            SELECT
                                                CONCAT(var_case_no, ' ', var_hkid, ' ', var_old_ward_code, ' ', var_old_specialty_code, ' ', var_old_bed_no, ' ', var_ward_code, ' ', var_specialty_code, ' ', var_bed_no, ' ', to_char(var_ws_dis_datetime,'YYYYMMDD HH24mi') )
                                                INTO var_ws_log;
                                            RAISE NOTICE 'Canc Txsf: %', var_ws_log;

                                             SELECT
      											concat(schema_name,'.hkpmi_cancel_transfer')  
											INTO var_pgm_name
											from hkpmi_control;
                                            raise notice 'call hkpmi_cancel_transfer';
                                            perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                            dblink_sql := 'call ' 
											|| var_pgm_name || '(' 
                                            || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
											|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
											|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
											|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
											|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
											|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
											|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
											|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
											|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
											|| case when 	var_ws_tr_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_tr_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
											|| case when 	var_old_ward_code	 is null then 'null::bpchar' else concat('''', 	var_old_ward_code	, '''::bpchar') end || ','
											|| case when 	var_old_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_old_specialty_code	, '''::bpchar') end || ','
											|| case when 	var_old_ward_class	 is null then 'null::bpchar' else concat('''', 	var_old_ward_class	, '''::bpchar') end || ','
											|| case when 	var_old_bed_no	 is null then 'null::bpchar' else concat('''', 	var_old_bed_no	, '''::bpchar') end || ','
											|| case when 	var_ward_code	 is null then 'null::bpchar' else concat('''', 	var_ward_code	, '''::bpchar') end || ','
											|| case when 	var_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_specialty_code	, '''::bpchar') end || ','
											|| case when 	var_ward_class	 is null then 'null::bpchar' else concat('''', 	var_ward_class	, '''::bpchar') end || ','
											|| case when 	var_bed_no	 is null then 'null::bpchar' else concat('''', 	var_bed_no	, '''::bpchar') end || ');';
                                            raise notice 'dblink_sql=%',dblink_sql;
											select * from public.dblink('rpc_server'::text,dblink_sql::text)
											as t1(var_return_code int,var_hkpmi_tprk bpchar )
											into var_return_code,var_hkpmi_tprk;
											perform public.dblink_disconnect('rpc_server'::text);
											exception
												when others then
													GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
													raise notice 'hkpmi_cancel_transfer=>%',error_message;
													perform public.dblink_disconnect('rpc_server'::text);
											/* --- Update host --- */
                                            EXIT check_status;
                                        END;
                                    /* --- Type 030: Demographic data update --- */
                                    ELSE
                                        IF (var_type = '030') OR (var_type = '031') THEN
                                            BEGIN
                                                SELECT
                                                    CONCAT(var_old_hkid, ' ', var_hkid, ' ', SUBSTRING(var_patient_name, 1, 24), ' ',to_char(var_dob,'YYYYMMDD')  , ' ', var_sex)
                                                    INTO var_ws_log;
                                                RAISE NOTICE 'Demo Upd: %', var_ws_log;

                                                SELECT
      												concat(schema_name,'.hkpmi_patient_update')  
												INTO var_pgm_name
												from hkpmi_control;
                                                raise notice 'call hkpmi_patient_update';
                                                perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                dblink_sql := 'call ' 
												|| var_pgm_name || '(' 
                                                || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
												|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
												|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
												|| case when 	var_old_hkid	 is null then 'null::bpchar' else concat('''', 	var_old_hkid	, '''::bpchar') end || ','
												|| case when 	var_patient_name	 is null then 'null::bpchar' else concat('''', 	var_patient_name	, '''::bpchar') end || ','
												|| case when 	var_sex	 is null then 'null::bpchar' else concat('''', 	var_sex	, '''::bpchar') end || ','
												|| case when 	var_dob	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_dob	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
												|| case when 	var_dob_exact_flag	 is null then 'null::bpchar' else concat('''', 	var_dob_exact_flag	, '''::bpchar') end || ','
												|| case when 	var_ccc_1	 is null then 'null::bpchar' else concat('''', 	var_ccc_1	, '''::bpchar') end || ','
												|| case when 	var_ccc_2	 is null then 'null::bpchar' else concat('''', 	var_ccc_2	, '''::bpchar') end || ','
												|| case when 	var_ccc_3	 is null then 'null::bpchar' else concat('''', 	var_ccc_3	, '''::bpchar') end || ','
												|| case when 	var_ccc_4	 is null then 'null::bpchar' else concat('''', 	var_ccc_4	, '''::bpchar') end || ','
												|| case when 	var_ccc_5	 is null then 'null::bpchar' else concat('''', 	var_ccc_5	, '''::bpchar') end || ','
												|| case when 	var_ccc_6	 is null then 'null::bpchar' else concat('''', 	var_ccc_6	, '''::bpchar') end || ','
												|| case when 	var_marital_status	 is null then 'null::bpchar' else concat('''', 	var_marital_status	, '''::bpchar') end || ','
												|| case when 	var_nationality	 is null then 'null::bpchar' else concat('''', 	var_nationality	, '''::bpchar') end || ','
												|| case when 	var_other_docu_no	 is null then 'null::bpchar' else concat('''', 	var_other_docu_no	, '''::bpchar') end || ','
												|| case when 	var_mrn	 is null then 'null::bpchar' else concat('''', 	var_mrn	, '''::bpchar') end || ','
												|| case when 	var_address_building	 is null then 'null::bpchar' else concat('''', 	var_address_building	, '''::bpchar') end || ','
												|| case when 	var_address_room	 is null then 'null::bpchar' else concat('''', 	var_address_room	, '''::bpchar') end || ','
												|| case when 	var_address_floor	 is null then 'null::bpchar' else concat('''', 	var_address_floor	, '''::bpchar') end || ','
												|| case when 	var_address_block	 is null then 'null::bpchar' else concat('''', 	var_address_block	, '''::bpchar') end || ','
												|| case when 	var_address_dist	 is null then 'null::bpchar' else concat('''', 	var_address_dist	, '''::bpchar') end || ','
												|| case when 	var_religion	 is null then 'null::bpchar' else concat('''', 	var_religion	, '''::bpchar') end || ','
												|| case when 	var_phone	 is null then 'null::bpchar' else concat('''', 	var_phone	, '''::bpchar') end || ','
												|| case when 	var_office_phone	 is null then 'null::bpchar' else concat('''', 	var_office_phone	, '''::bpchar') end || ','
												|| case when 	var_office_ext	 is null then 'null::bpchar' else concat('''', 	var_office_ext	, '''::bpchar') end || ','
												|| case when 	var_other_phone	 is null then 'null::bpchar' else concat('''', 	var_other_phone	, '''::bpchar') end || ','
												|| case when 	var_other_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_other_phone_ext	, '''::bpchar') end || ','
												|| case when 	var_patient_type	 is null then 'null::bpchar' else concat('''', 	var_patient_type	, '''::bpchar') end || ','
												|| case when 	var_hkpmi_access_code	 is null then 0::int else var_hkpmi_access_code end || ','
												|| case when 	var_nok_name	 is null then 'null::bpchar' else concat('''', 	var_nok_name	, '''::bpchar') end || ','
												|| case when 	var_nok_hkid	 is null then 'null::bpchar' else concat('''', 	var_nok_hkid	, '''::bpchar') end || ','
												|| case when 	var_nok_relation	 is null then 'null::bpchar' else concat('''', 	var_nok_relation	, '''::bpchar') end || ','
												|| case when 	var_nok_address_building	 is null then 'null::bpchar' else concat('''', 	var_nok_address_building	, '''::bpchar') end || ','
												|| case when 	var_nok_address_room	 is null then 'null::bpchar' else concat('''', 	var_nok_address_room	, '''::bpchar') end || ','
												|| case when 	var_nok_address_floor	 is null then 'null::bpchar' else concat('''', 	var_nok_address_floor	, '''::bpchar') end || ','
												|| case when 	var_nok_address_block	 is null then 'null::bpchar' else concat('''', 	var_nok_address_block	, '''::bpchar') end || ','
												|| case when 	var_nok_address_dist	 is null then 'null::bpchar' else concat('''', 	var_nok_address_dist	, '''::bpchar') end || ','
												|| case when 	var_nok_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_phone	, '''::bpchar') end || ','
												|| case when 	var_nok_office_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_office_phone	, '''::bpchar') end || ','
												|| case when 	var_nok_office_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_nok_office_phone_ext	, '''::bpchar') end || ','
												|| case when 	var_nok_other_phone	 is null then 'null::bpchar' else concat('''', 	var_nok_other_phone	, '''::bpchar') end || ','
												|| case when 	var_nok_other_phone_ext	 is null then 'null::bpchar' else concat('''', 	var_nok_other_phone_ext	, '''::bpchar') end || ','
												|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
												|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
												|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
												|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
												|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
												|| case when 	var_document_flag	 is null then 'null::bpchar' else concat('''', 	var_document_flag	, '''::bpchar') end || ','
												|| case when 	var_hkic_symbol	 is null then 'null::bpchar' else concat('''', 	var_hkic_symbol	, '''::bpchar') end || ','
												|| case when 	var_hkic_symbol_clear	 is null then 'null::bpchar' else concat('''', 	var_hkic_symbol_clear	, '''::bpchar') end || ');';
                                                raise notice 'dblink_sql=%',dblink_sql;
												select * from public.dblink('rpc_server'::text,dblink_sql::text)
												as t1(return_code int,var_hkpmi_tprk bpchar, var_hkpmi_access_code int)
												into var_return_code,var_hkpmi_tprk,var_hkpmi_access_code;
												perform public.dblink_disconnect('rpc_server'::text);
												exception
													when others then
														GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
														raise notice 'hkpmi_patient_update=>%',error_message;
														perform public.dblink_disconnect('rpc_server'::text);
												/* --- Update host --- */
                                                EXIT check_status;
                                            END;
                                        ELSE
                                            /* --- Type 20%: Cancellation of Admission --- */
                                            IF var_ws_event_type = '20' OR var_type = '080' THEN
                                                BEGIN
                                                    SELECT
                                                        CONCAT(var_case_no, ' ', var_hkid)
                                                        INTO var_ws_log;

                                                    IF var_type = '080' THEN
                                                        RAISE NOTICE 'Canc Conv: %', var_ws_log;
                                                    ELSE
                                                        RAISE NOTICE 'Canc Adm: %', var_ws_log;
                                                    END IF;

                                                    SELECT
      													concat(schema_name,'.hkpmi_cancel_admission')  
													INTO var_pgm_name
													from hkpmi_control;
                                                    raise notice 'call hkpmi_cancel_admission';
                                                    perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                    dblink_sql := 'call ' 
													|| var_pgm_name || '(' 
                                                    || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
													|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
													|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
													|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
													|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
													|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
													|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
													|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
													|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
													|| case when 	var_case_type	 is null then 'null::bpchar' else concat('''', 	var_case_type	, '''::bpchar') end || ','
													|| case when 	var_ws_adm_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_adm_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
													|| case when 	var_ward_code	 is null then 'null::bpchar' else concat('''', 	var_ward_code	, '''::bpchar') end || ','
													|| case when 	var_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_specialty_code	, '''::bpchar') end || ','
													|| case when 	var_ward_class	 is null then 'null::bpchar' else concat('''', 	var_ward_class	, '''::bpchar') end || ');';
                                                    raise notice 'dblink_sql=%',dblink_sql;
													select * from public.dblink('rpc_server'::text,dblink_sql::text)
													as t1(var_return_code int,var_hkpmi_tprk bpchar)
													into var_return_code,var_hkpmi_tprk;
													perform public.dblink_disconnect('rpc_server'::text);
														exception
															when others then
																GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																raise notice 'hkpmi_cancel_admission=>%',error_message;
																perform public.dblink_disconnect('rpc_server'::text);
													/* --- Update host --- */
                                                    EXIT check_status;
                                                END;
                                            ELSE
                                                /* --- Type 020: Request to Merge HKID --- */
                                                IF (var_type = '020') THEN
                                                    BEGIN
                                                        /* --select @old_dob = convert(char(8),@ws_old_dob_datetime,112) */
                                                        SELECT
                                                            CONCAT(var_old_hkid, ' ', var_hkid, ' ', SUBSTRING(var_patient_name, 1, 24), ' ', to_char(var_dob,'YYYYMMDD') , ' ', var_sex)
                                                            INTO var_ws_log;
                                                        RAISE NOTICE 'Merge HKID: %', var_ws_log;

                                                        SELECT
      													concat(schema_name,'.hkpmi_patient_merge')  
														INTO var_pgm_name
														from hkpmi_control;
                                                        raise notice 'call hkpmi_patient_merge';
                                                        perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                       dblink_sql := 'call ' 
														|| var_pgm_name || '(' 
                                                        || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
														|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
														|| case when 	var_old_hkid	 is null then 'null::bpchar' else concat('''', 	var_old_hkid	, '''::bpchar') end || ','
														|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
														|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
														|| case when 	var_hkpmi_access_code	 is null then 0::int else var_hkpmi_access_code end || ','
														|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
														|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
														|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
														|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ');';
														raise notice 'dblink_sql=%',dblink_sql;
														select * from public.dblink('rpc_server'::text,dblink_sql::text)
														as t1(var_return_code int,var_hkpmi_tprk bpchar,var_hkpmi_access_code int)
														into var_return_code,var_hkpmi_tprk,var_hkpmi_access_code;
														perform public.dblink_disconnect('rpc_server'::text);
														exception
															when others then
																GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																raise notice 'hkpmi_patient_merge=>%',error_message;
																perform public.dblink_disconnect('rpc_server'::text);
                                                        EXIT check_status;
                                                    END;
                                                ELSE
                                                    /*
                                                    ----Type 121/341: Update Admission Registration
                                                    (after updated)---
                                                    */
                                                    IF (var_type = '121') OR (var_type = '341') THEN
                                                        BEGIN
                                                            /*
                                                            Pass patient, nok and mrn information to CICS in order
                                                            to generate the demo. update transaction for projects
                                                            using Download server for In-patient
                                                            */
                                                            /* Following sql do not work originally */
                                                            /*
                                                            if (@type = '121')
                                                            begin
                                                            	select @patient_name       = patient_name,
                                                            		@sex                    = sex,
                                                            		@ccc_1                  = cccode1,
                                                            		@ccc_2                  = cccode2,
                                                            		@ccc_3                  = cccode3,
                                                            		@ccc_4                  = cccode4,
                                                            		@ccc_5                  = cccode5,
                                                            		@ccc_6                  = cccode6,
                                                            		@marital_status         = marital_status,
                                                            		@nationality            = race,
                                                            		@other_docu_no          = other_doc_no,
                                                            		@address_building       = building,
                                                            		@address_room           = room,
                                                            		@address_floor          = floor,
                                                            		@address_block          = block,
                                                            		@address_dist           = district,
                                                            		@religion               = religion,
                                                            		@phone                  = home_phone,
                                                            	   @office_phone		      = office_phone,
                                                            	   @office_ext			      = office_phone_ext,
                                                            		@other_phone 		      = other_phone,
                                                            	   @other_phone_ext        = other_phone_ext,
                                                            		@t_prk                  = patient_key
                                                            	from	cpi_patient
                                                            	where	hkid = @hkid
                                                            
                                                            	select @nok_name           = nok_name,
                                                            		@nok_hkid               = hkid,
                                                            		@nok_relation           = relationship,
                                                            		@nok_address_room       = room,
                                                            		@nok_address_floor      = floor,
                                                            		@nok_address_block      = block,
                                                            		@nok_address_building   = building,
                                                            		@nok_address_dist       = district,
                                                            		@nok_phone              = home_phone,
                                                            		@nok_office_phone       = office_phone,
                                                            		@nok_office_phone_ext   = office_phone_ext,
                                                            	   @nok_other_phone		   = other_phone,
                                                            	   @nok_other_phone_ext    = other_phone_ext
                                                            	from	cpi_nok
                                                            	where	patient_key = @t_prk
                                                            	and	major_nok = 'Y'
                                                            
                                                            	select @mrn = mrn
                                                            		from	cpi_patient_hospital_data
                                                            		where	hospital_code = @hosp_code
                                                            		and	patient_key = @t_prk
                                                            end
                                                            */
                                                            /*
                                                            End of coding for passing data to CICS for generate
                                                            corresponding download record
                                                            */
                                                            SELECT
                                                                SUBSTRING(CONCAT(LTRIM(var_nok_hkid), REPEAT(' ', 12)), 1, 12)
                                                                INTO var_nok_hkid;
                                                            SELECT
                                                                CONCAT(var_case_no, ' ', var_hkid, ' ', var_ward_class, ' ', var_ward_code, ' ', var_specialty_code, ' ', to_char(var_ws_adm_datetime,'YYYYMMDD HH24mi') )
                                                                INTO var_ws_log;
                                                            RAISE NOTICE 'Upd Adm/Reg: %', var_ws_log;

                                                            SELECT
      														concat(schema_name,'.hkpmi_update_admission')  
															INTO var_pgm_name
															from hkpmi_control;
                                                            raise notice 'call hkpmi_update_admission';
                                                            perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                            dblink_sql := 'call ' 
															|| var_pgm_name || '(' 
                                                            || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
															|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
															|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
															|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
															|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
															|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
															|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
															|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
															|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
															|| case when 	var_ws_adm_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_adm_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
															|| case when 	var_source_indicator	 is null then 'null::bpchar' else concat('''', 	var_source_indicator	, '''::bpchar') end || ','
															|| case when 	var_source_code	 is null then 'null::bpchar' else concat('''', 	var_source_code	, '''::bpchar') end || ','
															|| case when 	var_patient_type	 is null then 'null::bpchar' else concat('''', 	var_patient_type	, '''::bpchar') end || ','
															|| case when 	var_ward_code	 is null then 'null::bpchar' else concat('''', 	var_ward_code	, '''::bpchar') end || ','
															|| case when 	var_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_specialty_code	, '''::bpchar') end || ','
															|| case when 	var_ward_class	 is null then 'null::bpchar' else concat('''', 	var_ward_class	, '''::bpchar') end || ','
															|| case when 	var_old_ward_code	 is null then 'null::bpchar' else concat('''', 	var_old_ward_code	, '''::bpchar') end || ','
															|| case when 	var_old_specialty_code	 is null then 'null::bpchar' else concat('''', 	var_old_specialty_code	, '''::bpchar') end || ','
															|| case when 	var_old_ward_class	 is null then 'null::bpchar' else concat('''', 	var_old_ward_class	, '''::bpchar') end || ','
															|| case when 	var_pp_code	 is null then 'null::bpchar' else concat('''', 	var_pp_code	, '''::bpchar') end || ','
															|| case when 	var_ae_ambulance	 is null then 'null::bpchar' else concat('''', 	var_ae_ambulance	, '''::bpchar') end || ','
															|| case when 	var_ae_police	 is null then 'null::bpchar' else concat('''', 	var_ae_police	, '''::bpchar') end || ','
															|| case when 	var_ae_labour_case	 is null then 'null::bpchar' else concat('''', 	var_ae_labour_case	, '''::bpchar') end || ','
															|| case when 	var_ae_case_type	 is null then 'null::bpchar' else concat('''', 	var_ae_case_type	, '''::bpchar') end || ','
															|| case when 	var_dba_flag	 is null then 'null::bpchar' else concat('''', 	var_dba_flag	, '''::bpchar') end || ','
															|| case when 	var_document_flag	 is null then 'null::bpchar' else concat('''', 	var_document_flag	, '''::bpchar') end || ','
															|| case when 	var_eh_code	 is null then 'null::bpchar' else concat('''', 	var_eh_code	, '''::bpchar') end || ','
															|| case when 	var_source_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_source_hosp_code	, '''::bpchar') end || ','
															|| case when 	var_source_case_no	 is null then 'null::bpchar' else concat('''', 	var_source_case_no	, '''::bpchar') end || ');';
															raise notice 'dblink_sql=%',dblink_sql;
															select * from public.dblink('rpc_server'::text,dblink_sql::text)
															as t1(var_return_code int,var_hkpmi_tprk bpchar)
															into var_return_code,var_hkpmi_tprk;
															perform public.dblink_disconnect('rpc_server'::text);
															exception
																when others then
																	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																	raise notice 'hkpmi_update_admission=>%',error_message;
																	perform public.dblink_disconnect('rpc_server'::text);
															/* --- Update host --- */
                                                            EXIT check_status;
                                                        END;
                                                    /* --- Type 040 : Move cases between Patients --- */
                                                    ELSE
                                                        IF var_type = '040' THEN
                                                            BEGIN
                                                                SELECT
                                                                    CONCAT(var_old_hkid, ' ', var_hkid, ' ', var_case_no)
                                                                    INTO var_ws_log;
                                                                RAISE NOTICE 'Move case: %', var_ws_log;

                                                                SELECT
      															concat(schema_name,'.hkpmi_move_episode')  
																INTO var_pgm_name
																from hkpmi_control;
                                                                raise notice 'call hkpmi_move_episode';
                                                                perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                                dblink_sql := 'call ' 
																|| var_pgm_name || '(' 
                                                                || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
																|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
																|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
																|| case when 	var_old_hkid	 is null then 'null::bpchar' else concat('''', 	var_old_hkid	, '''::bpchar') end || ','
																|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
																|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
																|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
																|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
																|| case when 	var_move_episode_status	 is null then 'null::bpchar' else concat('''', 	var_move_episode_status	, '''::bpchar') end || ');';
                                                                raise notice 'dblink_sql=%',dblink_sql;
																select * from public.dblink('rpc_server'::text,dblink_sql::text)
																as t1( var_return_code int)
																into var_return_code;
																perform public.dblink_disconnect('rpc_server'::text);
																exception
																	when others then
																		GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																		raise notice 'hkpmi_move_episode=>%',error_message;
																		perform public.dblink_disconnect('rpc_server'::text);
																
                                                                /* --- Update host --- */
                                                                EXIT check_status;
                                                            END;
                                                        /* --- Type 034 : Set patient confidentiality */
                                                        ELSE
                                                            IF var_type = '034' THEN
                                                                BEGIN
                                                                    RAISE NOTICE 'Update Access code: %, %', var_hkid, var_pmi_access_code;

                                                                    SELECT
      																concat(schema_name,'.hkpmi_access_code_update')  
																	INTO var_pgm_name
																	from hkpmi_control;
                                                                    raise notice 'call hkpmi_access_code_update';
                                                                    
                                                                    perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                                   	 dblink_sql := 'call ' 
																	|| var_pgm_name || '(' 
                                                                    || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
																	|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
																	|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
																	|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																	|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
																	|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
																	|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
																	|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
																	|| case when 	var_patient_name	 is null then 'null::bpchar' else concat('''', 	var_patient_name	, '''::bpchar') end || ','
																	|| case when 	var_sex	 is null then 'null::bpchar' else concat('''', 	var_sex	, '''::bpchar') end || ','
																	|| case when 	var_dob	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_dob	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																	|| case when 	var_pmi_access_code	 is null then 0::int else var_pmi_access_code end || ','
																	|| concat('''', 	'Y'	, '''::bpchar') || ');';
																	raise notice '%',dblink_sql;
																	select * from public.dblink('rpc_server'::text,dblink_sql::text)
																	as t1( var_return_code int,var_hkpmi_tprk varchar)
																	into var_return_code,var_hkpmi_tprk;
																	perform public.dblink_disconnect('rpc_server'::text);
																	raise notice 'var_return_code=%',var_return_code;
																	exception
																		when others then
																			GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																			raise notice 'hkpmi_access_code_update=>%',error_message;
																			perform public.dblink_disconnect('rpc_server'::text);
																	/* --- Update host --- */
                                                                    EXIT check_status;
                                                                END;
                                                            /* --- start added by WL on 20000427 --- */
                                                            ELSE
                                                                IF var_type = '250' THEN
                                                                    BEGIN
                                                                        RAISE NOTICE 'PMI Deletion code: %, %', var_hkid, var_hkpmi_tprk;

                                                                        SELECT
      																	concat(schema_name,'.hkpmi_del_pmi')  
																		INTO var_pgm_name
																		from hkpmi_control;
                                                                        raise notice 'call hkpmi_del_pmi';
                                                                        perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                                        dblink_sql := 'call ' 
																		|| var_pgm_name || '(' 
                                                                        || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
																		|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
																		|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
																		|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																		|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
																		|| concat('''', 	'ADT'	, '''::bpchar') || ','
																		|| case when 	var_hkpmi_tprk	 is null then 'null::bpchar' else concat('''', 	var_hkpmi_tprk	, '''::bpchar') end || ','
																		|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
																		|| case when 	var_patient_name	 is null then 'null::bpchar' else concat('''', 	var_patient_name	, '''::bpchar') end || ','
																		|| case when 	var_sex	 is null then 'null::bpchar' else concat('''', 	var_sex	, '''::bpchar') end || ','
																		|| case when 	var_dob	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_dob	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																		|| case when 	var_ccc_1	 is null then 'null::bpchar' else concat('''', 	var_ccc_1	, '''::bpchar') end || ','
																		|| case when 	var_ccc_2	 is null then 'null::bpchar' else concat('''', 	var_ccc_2	, '''::bpchar') end || ','
																		|| case when 	var_ccc_3	 is null then 'null::bpchar' else concat('''', 	var_ccc_3	, '''::bpchar') end || ','
																		|| case when 	var_ccc_4	 is null then 'null::bpchar' else concat('''', 	var_ccc_4	, '''::bpchar') end || ','
																		|| case when 	var_ccc_5	 is null then 'null::bpchar' else concat('''', 	var_ccc_5	, '''::bpchar') end || ','
																		|| case when 	var_ccc_6	 is null then 'null::bpchar' else concat('''', 	var_ccc_6	, '''::bpchar') end || ');';
                                                                        raise notice 'dblink_sql=%',dblink_sql;
																		select * from public.dblink('rpc_server'::text,dblink_sql::text)
																		as t1( var_return_code int,var_hkpmi_tprk varchar)
																		into var_return_code,var_hkpmi_tprk;
																		perform public.dblink_disconnect('rpc_server'::text);
																		exception
																			when others then
																				GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																				raise notice 'hkpmi_del_pmi=>%',error_message;
																				perform public.dblink_disconnect('rpc_server'::text);
																		/* --- Update host --- */
                                                                        EXIT check_status;
                                                                    END;
                                                                /* ----- end added by WL on 20000427--- */
                                                                
                                                                /* * 20030612 SL : 260,261,262 */
                                                                ELSE
                                                                    IF (var_type = '260') OR (var_type = '261') OR (var_type = '262') THEN
                                                                        BEGIN
                                                                            IF var_nb_old_prk IN ('', REPEAT(' ', 1), REPEAT(' ', 8)) THEN
                                                                                SELECT
                                                                                    NULL
                                                                                    INTO var_nb_old_prk;
                                                                            END IF;

                                                                            IF var_mo_hosp IN ('', REPEAT(' ', 1), REPEAT(' ', 3)) THEN
                                                                                SELECT
                                                                                    NULL
                                                                                    INTO var_mo_hosp;
                                                                            END IF;

                                                                            IF var_nb_hosp IN ('', REPEAT(' ', 1), REPEAT(' ', 3)) THEN
                                                                                SELECT
                                                                                    NULL
                                                                                    INTO var_nb_hosp;
                                                                            END IF;

                                                                            IF var_nb_case IN ('', REPEAT(' ', 1), REPEAT(' ', 12)) THEN
                                                                                SELECT
                                                                                    NULL
                                                                                    INTO var_nb_case;
                                                                            END IF;

                                                                            IF var_old_nb_case IN ('', REPEAT(' ', 1), REPEAT(' ', 12)) THEN
                                                                                SELECT
                                                                                    NULL
                                                                                    INTO var_old_nb_case;
                                                                            END IF;

                                                                            IF var_old_mo_case IN ('', REPEAT(' ', 1), REPEAT(' ', 12)) THEN
                                                                                SELECT
                                                                                    NULL
                                                                                    INTO var_old_mo_case;
                                                                            END IF;
                                                                            SELECT
                                                                                CONCAT(var_case_no, ' ', var_hkid, ' ', var_type)
                                                                                INTO var_ws_log;
                                                                            RAISE NOTICE 'Upd new born: %', var_ws_log;
                                                                            /* --			select @pgm_name = "hkpmi_update_new_born" */

                                                                            SELECT
      																		concat(schema_name,'.hkpmi_update_mother_baby_case')  
																			INTO var_pgm_name
																			from hkpmi_control;
                                                                            raise notice 'call hkpmi_update_mother_baby_case';
                                                                            /* --			exec @return_code = @rpc_call */
                                                                            /* --				@hosp_code,             /*hospital code*/ */
                                                                            /* --				@type,                  /*txn type*/ */
                                                                            /* --				@ws_system_datetime,    /* source system dtm */ */
                                                                            /* --				@user_id,               /* update by */ */
                                                                            /* --				@source_system,         /* source system */ */
                                                                            /* --				@hkid,                  /*mother hkid*/ */
                                                                            /* --				@t_prk,                 /*mother key*/ */
                                                                            /* --				@case_no,               /*mother case no*/ */
                                                                            /* --				@pmi_access_code,     	/*birth_order = pmi_access_code */ */
                                                                            /* --				@case_access_code,     	/*pregnancy_number=case_access_code */ */
                                                                            /* --				@old_patient_key,       /*new born patient_key*/ */
                                                                            /* --				@old_hkid,              /*new born hkid*/ */
                                                                            /* --				@nb_old_prk    /* old new born patient key */ */
                                                                            /*
                                                                            source_indicator = birth_place
                                                                            source_code = birth_location
                                                                            */
																			perform public.dblink_connect('rpc_server'::text, var_rpc_call);
																			dblink_sql := 'call ' 
																			|| var_pgm_name || '(' 
                                                                            || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
																			|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
																			|| case when 	var_mo_hosp	 is null then 'null::bpchar' else concat('''', 	trim(var_mo_hosp)	, '''::bpchar') end || ','
																			|| case when 	var_case_no	 is null then 'null::bpchar' else concat('''', 	var_case_no	, '''::bpchar') end || ','
																			|| case when 	var_nb_hosp	 is null then 'null::bpchar' else concat('''', 	trim(var_nb_hosp)	, '''::bpchar') end || ','
																			|| case when 	var_nb_case	 is null then 'null::bpchar' else concat('''', 	var_nb_case	, '''::bpchar') end || ','
																			|| case when 	var_pmi_access_code	 is null then 0::int else var_pmi_access_code end || ','
																			|| case when 	var_case_access_code	 is null then 0::int else var_case_access_code end || ','
																			|| case when 	var_source_indicator	 is null then 'null::bpchar' else concat('''', 	var_source_indicator	, '''::bpchar') end || ','
																			|| case when 	var_source_code	 is null then 'null::bpchar' else concat('''', 	var_source_code	, '''::bpchar') end || ','
																			|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
																			|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
																			|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
																			|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																			|| case when 	var_mo_hosp	 is null then 'null::bpchar' else concat('''', 	trim(var_mo_hosp)	, '''::bpchar') end || ','
																			|| case when 	var_old_mo_case	 is null then 'null::bpchar' else concat('''', 	var_old_mo_case	, '''::bpchar') end || ','
																			|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
																			|| case when 	var_old_nb_case	 is null then 'null::bpchar' else concat('''', 	var_old_nb_case	, '''::bpchar') end || ','
																			|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
																			|| case when 	var_t_prk	 is null then 'null::bpchar' else concat('''', 	var_t_prk	, '''::bpchar') end || ','
																			|| case when 	var_old_hkid	 is null then 'null::bpchar' else concat('''', 	var_old_hkid	, '''::bpchar') end || ','
																			|| case when 	var_old_patient_key	 is null then 'null::bpchar' else concat('''', 	var_old_patient_key	, '''::bpchar') end || ','
																			|| case when 	var_nb_old_prk	 is null then 'null::bpchar' else concat('''', 	var_nb_old_prk	, '''::bpchar') end || ','
																			|| concat('''', 	'N'	, '''::bpchar') || ');';
																			raise notice 'dblink_sql=%',dblink_sql; 
																			select * from public.dblink('rpc_server'::text,dblink_sql::text)
																			as t1( var_return_code int)
																			into  var_return_code;
																			perform public.dblink_disconnect('rpc_server'::text);
																			exception
																				when others then
																					GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																					raise notice 'hkpmi_update_mother_baby_case=>%',error_message;
																					perform public.dblink_disconnect('rpc_server'::text);
                                                                            /* --- Update host --- */
                                                                            /* --- Update host --- */
                                                                            EXIT check_status;
                                                                        END; /* END of - if (@type = '260') or (@type = '261') or (@type = '262') */
                                                                    /* * END of - 20030612 SL : 260,261,262 */
                                                                    /* * 20081202 SL : 265 update uid table */
                                                                    ELSE
                                                                        IF (var_type = '265') THEN
                                                                            BEGIN
                                                                                SELECT
                                                                                    var_hkid
                                                                                    INTO var_uid_hkid;
                                                                                SELECT
                                                                                    var_other_docu_no
                                                                                    INTO var_link_hkid;
                                                                                SELECT
                                                                                    CONCAT(var_uid_hkid, ' ', var_type, ' ', var_link_hkid, ':', var_link_status)
                                                                                    INTO var_ws_log;
                                                                                RAISE NOTICE 'Upd uid table: %', var_ws_log;
                                                                                /* --			select @pgm_name = "hkpmi_update_new_born" */

                                                                                SELECT
      																			concat(schema_name,'.hkpmi_update_uid_table')  
																				INTO var_pgm_name
																				from hkpmi_control;
                                                                                raise notice 'call hkpmi_update_uid_table';
																				perform public.dblink_connect('rpc_server'::text, var_rpc_call);
																				dblink_sql := 'call ' 
																				|| var_pgm_name || '(' 
                                                                                || '0' || ','
																				|| concat('''', 	'U'	, '''::bpchar') || ','
																				|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
																				|| case when 	var_uid_hkid	 is null then 'null::bpchar' else concat('''', 	var_uid_hkid	, '''::bpchar') end || ','
																				|| case when 	var_link_hkid	 is null then 'null::bpchar' else concat('''', 	var_link_hkid	, '''::bpchar') end || ','
																				|| case when 	var_link_status	 is null then 'null::bpchar' else concat('''', 	var_link_status	, '''::bpchar') end || ','
																				|| 'null::TIMESTAMP WITHOUT TIME ZONE' || ','
																				|| 'null::bpchar' || ','
																				|| 'null::bpchar' || ','
																				|| 'null::bpchar' || ','
																				|| case when 	var_update_dtm	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_update_dtm	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																				|| case when 	var_update_hospital	 is null then 'null::bpchar' else concat('''', 	var_update_hospital	, '''::bpchar') end || ','
																				|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
																				|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
																				|| case when 	var_return_hkid	 is null then 'null::bpchar' else concat('''', 	var_return_hkid	, '''::bpchar') end || ','
																				|| case when 	var_return_code	 is null then 0::int else var_return_code end || ','
																				|| case when 	var_return_msg	 is null then 'null::bpchar' else concat('''', 	var_return_msg	, '''::bpchar') end || ','
																				|| 'null::refcursor' || ');';
																			    raise notice 'dblink_sql=%',dblink_sql;
																				select * from public.dblink('rpc_server'::text,dblink_sql::text)
																				as t1(pas_return_code int ,var_return_hkid bpchar, var_return_code int ,var_return_msg bpchar, p_refcurs refcursor)
																				into pas_return_code,var_return_hkid, var_return_code,var_return_msg,p_refcurs;
																				perform public.dblink_disconnect('rpc_server'::text);
																				exception
																					when others then
																						GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																						raise notice 'hkpmi_update_uid_table=>%',error_message;
																						perform public.dblink_disconnect('rpc_server'::text);
																				
																				/* --- Update host --- */
                                                                                EXIT check_status;
                                                                            END;
                                                                        /* * END of - 20081202 SL : 265 update uid table */
                                                                        /* * Start of - 20040812 : 033 */
                                                                        /* --- Type 033 : Update Death Date/Time */
                                                                        ELSE
                                                                            IF var_type = '033' THEN
                                                                                BEGIN
                                                                                    RAISE NOTICE 'Update Death Date/Time: %, %, %', var_hkid, var_death_indicator, var_death_date;

                                                                                    SELECT
      																					concat(schema_name,'.hkpmi_update_death')  
																					INTO var_pgm_name
																					from hkpmi_control;
                                                                                    raise notice 'call hkpmi_update_death';
                                                                                    perform public.dblink_connect('rpc_server'::text, var_rpc_call);
                                                                                    dblink_sql := 'call ' 
																					|| var_pgm_name || '(' 
                                                                                    || case when 	var_return_code	 is null then 0::int else var_return_code end || ','
																					|| case when 	var_hosp_code	 is null then 'null::bpchar' else concat('''', 	var_hosp_code	, '''::bpchar') end || ','
																					|| case when 	var_type	 is null then 'null::bpchar' else concat('''', 	var_type	, '''::bpchar') end || ','
																					|| case when 	var_ws_system_datetime	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_ws_system_datetime	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																					|| case when 	var_user_id	 is null then 'null::bpchar' else concat('''', 	var_user_id	, '''::bpchar') end || ','
																					|| case when 	var_source_system	 is null then 'null::bpchar' else concat('''', 	var_source_system	, '''::bpchar') end || ','
																					|| case when 	var_hkid	 is null then 'null::bpchar' else concat('''', 	var_hkid	, '''::bpchar') end || ','
																					|| case when 	var_death_indicator	 is null then 'null::bpchar' else concat('''', 	var_death_indicator	, '''::bpchar') end || ','
																					|| case when 	var_death_date	 is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', 	var_death_date	, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
																					|| case when 	var_body_category	 is null then 'null::bpchar' else concat('''', 	var_body_category	, '''::bpchar') end || ');';
                                                                                    raise notice 'dblink_sql=%',dblink_sql;
																					select * from public.dblink('rpc_server'::text,dblink_sql::text)
																					as t1(var_return_code int)
																					into var_return_code;
																					perform public.dblink_disconnect('rpc_server'::text);
																					exception
																						when others then
																							GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
																							raise notice 'hkpmi_update_death=>%',error_message;
																							perform public.dblink_disconnect('rpc_server'::text);
                                                                                    		
																					EXIT check_status;
                                                                                END;
                                                                            /* * End of - 20040812 : 033 */
                                                                            /* --- Other types --- */
                                                                            ELSE
                                                                                BEGIN
                                                                                    SELECT
                                                                                        0
                                                                                        INTO var_return_code;
                                                                                    SELECT
                                                                                        '*pass*'
                                                                                        INTO var_rpc_name;
                                                                                    UPDATE cpi_transaction
                                                                                    SET upload_status = 'P'
                                                                                        WHERE transaction_datetime = var_ws_system_datetime AND upload_status = 'Y';
                                                                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
																					raise notice '1637sql$rowcount=%',sql$rowcount;					
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
                                                                                    EXIT check_status;
                                                                                END;
                                                                            END IF;
                                                                        END IF;
                                                                    END IF;
                                                                END IF;
                                                            END IF;
                                                        END IF;
                                                    END IF;
                                                END IF;
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;
            /* End check cpi_suspend_upload_log */
            /* ---- Check update status --- */
        END;
		
        <<next_record>>
        begin

            <<check_patient_key>>
            BEGIN



            var_error := var_return_code;


        /* the error code from hkpmi upload SP is stsrt from 200000 */
        /* 1205 is deadlock */
        /* 23505 is deplicate key, it may return by inserting transaction_log */
        /* 515  : Attempt to insert NULL value into column :  baby registration (100) later than the mother baby relation (260) transaction. Therefore, the 260 transaction is failure (Attempt to insert NULL value into column 'new_born_patient_key) */
        
        IF var_error != 0 AND var_error < 200000  AND var_error != 1205 AND var_error != 23505 AND var_error != 23502 THEN
            /* 20171130 To prevent System Failure(Upload will be STOPPED) ==> marked this records as 'F' failed */
            BEGIN
                RAISE NOTICE 'ERROR code : %', var_error;
                SELECT
                    4
                    INTO var_failure_code;
                SELECT
                    'Y'
                    INTO var_stop_upload;
                CONTINUE;
            END;
        END IF;
        /* * Winnie Test * */
        /*
        select @comm_parm1 = convert(char(8), @return_code)
        print "Type  and return code = %1! %2!", @type, @comm_parm1
        */
        SELECT
            CONCAT(var_hosp_code, ' ', var_type, ' ',  TO_CHAR(timestamp_convert(localtimestamp), 'Mon DD YYYY HH:mi:ss:MSPM'), ' ', var_source_system, ' ', var_hkid, ' ', COALESCE(var_t_prk, REPEAT(' ', 8)), ' ', var_patient_name, ' ', var_sex, ' ',to_char(var_dob,'HH24:mi:ss')  )
            INTO var_comm_parm1;
		raise notice '1716var_return_code=%,var_rpc_name=%',var_return_code,var_rpc_name;
        IF var_return_code < 0 OR var_return_code = 300004 THEN
            /* ---> Gateway problem, retry after 1 min. */
            BEGIN
                /* goto skip_transaction */
                CONTINUE;
            END;
        ELSE
            IF (var_return_code = 0) AND (var_rpc_name != '*pass*') THEN /* success */
                begin
	                
                    UPDATE cpi_transaction
                    SET upload_status = 'S'
                        WHERE transaction_datetime = var_ws_system_datetime AND upload_status = 'Y';
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
					 raise notice '1726sql$rowcount=%',sql$rowcount;
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
                END;
            ELSE
                IF var_return_code > 0 THEN
                    /* ---> Invalid data in uploaded record */
                    BEGIN
                        INSERT INTO upload_exception (hospital_code, transaction_datetime, error_detail, record1, record2, record3, update_datetime)
                        VALUES (var_hosp_code, var_ws_system_datetime, CONCAT('cpi_upload: upload failure! ', 'event type = ', var_type, ', return code = ', CAST (var_return_code AS VARCHAR(8))), var_comm_parm1, NULL, NULL, timestamp_convert(localtimestamp));
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
						 raise notice '1746sql$rowcount=%',sql$rowcount;
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
                        UPDATE cpi_transaction
                        SET upload_status = 'F'
                            WHERE transaction_datetime = var_ws_system_datetime AND hospital_code = var_hosp_code AND upload_status = 'Y';
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
						raise notice '1761sql$rowcount=%',sql$rowcount;
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
                    END;
                END IF;
            END IF;
        END IF; /* end of update status checking */
                IF (var_return_code = 0) AND (var_rpc_name != '*pass*') THEN
                    EXIT check_patient_key;
                ELSE
                    EXIT next_record;
                END IF;
        END;
		IF (var_type IN ('100', '300', '010', '030', '031')) THEN
        BEGIN
            /*
            [3057 - Severity CRITICAL - PostgreSQL does not support BEGIN TRAN command. Perform a manual conversion.]
            begin transaction
            */
            CALL cpi_check_patient_key(var_return_code,var_hosp_code, var_type, var_ws_system_datetime, var_source_system, var_hkid, var_t_prk, /* cpi t_prk */ var_hkpmi_tprk, /* hkpmi tprk */ var_hkpmi_access_code);
            raise notice 'call cpi_check_patient_key1';	
			raise notice 'var_return_code=%',var_return_code;
            IF var_return_code <> 0 THEN
                begin
					raise exception '';  
                END;
            ELSE              
            END IF;
            exception
           		when others then
           			begin
	           			IF var_return_code = - 1 THEN
                        SELECT
                            CONCAT('Update Unmatch patient key error - ', var_hkid, '''s patient key in HKPMI', 'unmatched with CPI''s patient key ', var_t_prk, ')')
                            INTO var_error_msg;
                    ELSE
                        IF var_return_code = - 2 THEN
                            SELECT
                                CONCAT('Update Unmatch patient key error - ', 'update cpi_patient (', var_t_prk, ') failed')
                                INTO var_error_msg;
                        END IF;
                    END IF;
                    INSERT INTO upload_exception (hospital_code, transaction_datetime, error_detail, record1, record2, record3, update_datetime)
                    VALUES (var_hosp_code, var_ws_system_datetime, var_error_msg, NULL, NULL, NULL, timestamp_convert(localtimestamp));
	           		end;
        END;
    END IF;
        END;
    END LOOP /* loop until server is shutdown */;
	IF var_failure_code = 1 THEN
        RAISE NOTICE '---  Update cpi_transaction failure!!! ---';
    ELSE
        IF var_failure_code = 2 THEN
            RAISE NOTICE '---  Update upload_exception failure!!! ---';
        ELSE
            IF var_failure_code = 3 THEN
                RAISE NOTICE '---  Update cpi_suspend_upload_log failure!!! ---';
            ELSE
                IF var_failure_code = 4 THEN
                    RAISE NOTICE '--- System  failure!!! ---';
                END IF;
            END IF;
        END IF;
    END IF;
   SELECT clock_timestamp() into end_date;
    raise notice 'end_date=>%',end_date;
END; /* end of procedure */
$procedure$
;

;ALTER PROCEDURE "cpi_upload" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
