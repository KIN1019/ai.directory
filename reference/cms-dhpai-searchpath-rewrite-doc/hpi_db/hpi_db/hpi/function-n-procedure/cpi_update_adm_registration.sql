-- DROP PROCEDURE cpi_update_adm_registration(inout int4, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_update_adm_registration(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_case_no character varying, IN par_hkid character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_patient_type character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_ward_code character varying, IN par_ward_class character varying, IN par_bed_no character varying, IN par_specialty_code character varying, IN par_sub_specialty character varying, IN par_pp_code character varying, IN par_case_type character varying, IN par_txn_type character varying, IN par_update_type character varying, IN par_transaction_datetime timestamp without time zone, IN par_update_by character varying, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::bpchar, IN par_eh_code character varying DEFAULT NULL::bpchar, IN par_source_hosp_code character varying DEFAULT NULL::bpchar, IN par_source_case_no character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt                       INTEGER;
    var_status_code               VARCHAR(02);
    var_success_flag              VARCHAR(01);
    var_exit_flag                 VARCHAR(01);
    var_source_system_dtm         TIMESTAMP WITHOUT TIME ZONE;
    var_error                     INTEGER;
    var_rowcount                  INTEGER;
    var_return_error_code         INTEGER;
    var_movement_count            INTEGER;
    var_return                    INTEGER;
    var_rpc_name                  VARCHAR(80);
    var_treatment_location        VARCHAR(04);
    var_prev_ward_code            VARCHAR(04);
    var_prev_ward_class           VARCHAR(01);
    var_prev_specialty_code       VARCHAR(04);
    var_upload_status             VARCHAR(1);
    var_cpi_filler                VARCHAR(30);
    var_prev_eh_code              VARCHAR(08);
    var_prev_document_flag        VARCHAR(01);
    var_org_doc_flag              VARCHAR(1);
    var_lnk_case_patient_key      VARCHAR(12);
    var_patient_key               VARCHAR(12);
    var_old_source_hosp_code      VARCHAR(3);
    var_old_source_case_no        VARCHAR(12);
    var_rpc_call                  VARCHAR(400);
    var_valid_flag                VARCHAR(1);
    var_hkpmi_srvr                VARCHAR(300);
    var_return_code               INTEGER;
    var_insert_event_log_type     VARCHAR(3);
    var_insert_event_log_dtm      TIMESTAMP WITHOUT TIME ZONE;
    var_insert_event_log_prg      VARCHAR(35);
    var_insert_event_log_ret_code INTEGER;
    var_before_paycode            VARCHAR(3);
    var_pat_name                  VARCHAR(48);
    var_pat_sex                   VARCHAR(1);
    var_pat_dob                   TIMESTAMP WITHOUT TIME ZONE;
    var_pat_exact_dob_flag        VARCHAR(1);
    var_pat_ccc1                  VARCHAR(5);
    var_pat_ccc2                  VARCHAR(5);
    var_pat_ccc3                  VARCHAR(5);
    var_pat_ccc4                  VARCHAR(5);
    var_pat_ccc5                  VARCHAR(5);
    var_pat_ccc6                  VARCHAR(5);
    var_pat_martial_status        VARCHAR(1);
    var_pat_race                  VARCHAR(2);
    var_pat_other_doc_no          VARCHAR(12);
    var_pat_mrn                   VARCHAR(8);
    var_pat_bldg                  VARCHAR(47);
    var_pat_room                  VARCHAR(5);
    var_pat_floor                 VARCHAR(2);
    var_pat_block                 VARCHAR(2);
    var_pat_district_code         VARCHAR(5);
    var_pat_religion_code         VARCHAR(3);
    var_pat_phone1                VARCHAR(10);
    var_pat_mobile_phone1         VARCHAR(10);
    var_pat_mobile_phone1_ext     VARCHAR(4);
    var_pat_mobile_phone2         VARCHAR(10);
    var_pat_mobile_phone2_ext     VARCHAR(4);
    var_death_ind                 VARCHAR(1);
    var_death_dtm                 TIMESTAMP WITHOUT TIME ZONE;
    var_nok_name                  VARCHAR(48);
    var_nok_hkid                  VARCHAR(12);
    var_nok_relation_code         VARCHAR(2);
    var_nok_bldg                  VARCHAR(47);
    var_nok_room                  VARCHAR(5);
    var_nok_floor                 VARCHAR(2);
    var_nok_block                 VARCHAR(2);
    var_nok_district_code         VARCHAR(5);
    var_nok_phone1                VARCHAR(10);
    var_nok_mobile_phone1         VARCHAR(10);
    var_nok_mobile_phone1_ext     VARCHAR(4);
    var_nok_mobile_phone2         VARCHAR(10);
    var_nok_mobile_phone2_ext     VARCHAR(4);
    var_case_access_code          INTEGER;
    var_pmi_access_code           INTEGER;
    var_security_cnt              INTEGER;
    var_pat_key                   VARCHAR(8);
    var_movement_cnt              INTEGER;
    sql$rowcount                  BIGINT;
BEGIN
	RAISE NOTICE 'sp cpi_update_adm_registration start ,par_patient_type => %,par_update_type => %',par_patient_type,par_update_type;
    <<return_error>>
    BEGIN
        IF par_source_system = 'DNL' THEN
            SELECT 'N'
            INTO var_upload_status;
        ELSE
            SELECT 'Y'
            INTO var_upload_status;
        END IF;
        /*
        Assign the transaction_datetime of source system
        to source_system_dtm
        */
        SELECT par_transaction_datetime
        INTO var_source_system_dtm;
        /* Use a common datetime to update all tables */
        /* Use system date/time pass in by ADT as update_dtm */
        IF par_source_system <> 'ADT' THEN
            SELECT timestamp_convert(localtimestamp)
            INTO par_transaction_datetime;
        END IF;
        /* Set flags */
        SELECT 'Y'
        INTO var_success_flag;
        /* Validate key fields */
        IF NOT (
            (par_source_system = 'PBRC' AND par_update_type = 'P' AND par_case_type = 'I' AND par_txn_type = '121') OR
            (par_source_system = 'PBRC' AND par_update_type = 'P' AND par_case_type = 'A' AND par_txn_type = '341') OR
            (par_source_system = 'ADT' AND par_update_type IN ('P', 'A') AND par_case_type = 'I' AND
             par_txn_type = '121') OR
            (par_source_system = 'ADT' AND par_update_type IN ('P', 'A') AND par_case_type = 'A' AND
             par_txn_type = '341') OR (par_source_system = 'OPAS' AND par_case_type = 'O' AND par_txn_type = '121') OR
            (par_source_system = 'DNL' AND par_txn_type IN ('121', '341'))) THEN
            /* --			and @txn_type = '121')) */
            BEGIN
                SELECT 200006
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
        /* Check the existence of case */
        SELECT NULL,
               NULL,
               NULL
        INTO var_prev_ward_code, var_prev_ward_class, var_prev_specialty_code;
        SELECT COUNT(*)
        INTO var_cnt
        FROM cpi_case
        WHERE hospital_code = par_hospital_code
          AND case_no = par_case_no
          AND status_code != 'CC';

        IF var_cnt = 0 THEN
            BEGIN
                /*
                print Case does not exist in cpi_case,
                update admission registration is rejected!
                */
                SELECT 10001
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;

        IF par_document_flag IS NULL THEN
            BEGIN
                SELECT document_flag
                INTO var_org_doc_flag
                FROM cpi_case
                WHERE hospital_code = par_hospital_code
                  AND case_no = par_case_no;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount = 1 AND var_org_doc_flag IS NOT NULL THEN
                    SELECT var_org_doc_flag
                    INTO par_document_flag;
                END IF;
            END;
        END IF;

        IF NOT EXISTS (SELECT *
                       FROM cpi_patient AS p,
                            cpi_case AS c
                       WHERE c.case_no = par_case_no
                         AND c.patient_key = p.patient_key
                         AND p.hkid = par_hkid) THEN
            BEGIN
                SELECT 200001
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
        /*
        if @source_system = 'PBRC'
        begin
        	select @rpc_name = lower(rtrim(@hospital_code))
        							 + 'adt_db..hasp_pbrc_update_case'
        	exec @return = @rpc_name @case_no, @patient_type, 'PBRC',
        		  				@transaction_datetime
        	if @return != 0
        	begin
        		select @return_error_code = 10006
        		select @success_flag = N
        		goto return_error
        	end
        end
        */ /* end if (@case_type = I) */
        BEGIN
            IF (par_case_type = 'A') THEN
                BEGIN
                    IF par_source_system = 'PBRC' THEN
                        UPDATE cpi_case
                        SET patient_type = par_patient_type,
                            update_by    = par_update_by,
                            update_dtm   = par_transaction_datetime
                        WHERE hospital_code = par_hospital_code
                          AND case_no = par_case_no;
                    ELSE
                    	RAISE NOTICE 'cpi_update_adm_registration[212] - par_case_type = A, UPDATE cpi_case done';
                        UPDATE cpi_case
                        SET admission_dtm = par_admission_datetime,
                            patient_type  = par_patient_type,
                            update_by     = par_update_by,
                            update_dtm    = par_transaction_datetime,
                            pp_code       = par_pp_code, /* 20040315 SL */
                            document_flag = par_document_flag /* added by PP 011207 */
                        WHERE hospital_code = par_hospital_code
                          AND case_no = par_case_no;
                    END IF;
                END; /* end of if (@case_type = A) */
            ELSE
                IF (par_case_type = 'O') THEN
                    BEGIN
                        SELECT movement_count
                        INTO var_movement_count
                        FROM cpi_case
                        WHERE case_no = par_case_no
                          AND hospital_code = par_hospital_code;
                        /*
                        20070521 CHULS - remove checking for admission date/time update for OPAS
                        if @movement_count != 1
                        begin
                        	select @return_error_code = 10002
                        	select @success_flag = N
                        	goto return_error
                        end
                        */
                        SELECT last_specialty
                        INTO var_prev_specialty_code
                        FROM cpi_case
                        WHERE hospital_code = par_hospital_code
                          AND case_no = par_case_no
                          AND status_code != 'CC';
                        UPDATE cpi_case
                        SET admission_dtm      = par_admission_datetime,
                            patient_type       = par_patient_type,
                            last_specialty     = par_specialty_code,
                            last_sub_specialty = par_sub_specialty,
                            pp_code            = par_pp_code,
                            update_by          = par_update_by,
                            update_dtm         = par_transaction_datetime,
                            document_flag      = par_document_flag
                        /* added by PP 011206 */
                        WHERE hospital_code = par_hospital_code
                          AND case_no = par_case_no;
                    END;
                ELSE
                    IF (par_case_type = 'I') THEN
                        BEGIN
                            /* --- added by WL for insert event_log-- */
                            SELECT patient_type
                            INTO var_before_paycode
                            FROM cpi_case
                            WHERE hospital_code = par_hospital_code
                              AND case_no = par_case_no;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF (var_error != 0) OR (var_rowcount = 0) THEN
                                BEGIN
                                    /*
                                    print Fail to update cpi_case,
                                    update admission registration is rejected!
                                    */
                                    SELECT 10002
                                    INTO var_return_error_code;
                                    SELECT 'N'
                                    INTO var_success_flag;
                                    RAISE exception '';
                                END;
                            END IF;

                            IF (par_update_type = 'P') THEN
                                BEGIN
                                    IF par_source_system = 'ADT' THEN
                                        BEGIN
                                            UPDATE cpi_case
                                            SET patient_type     = par_patient_type,
                                                source_indicator = par_source_indicator,
                                                source_code      = par_source_code,
                                                update_by        = par_update_by,
                                                update_dtm       = par_transaction_datetime,
                                                /* --- added by WL on 28 SEP 1999 -- */
                                                pp_code          = par_pp_code,
                                                document_flag    = par_document_flag
                                            /* added by PP 011207 */
                                            WHERE hospital_code = par_hospital_code
                                              AND case_no = par_case_no;
                                        END;
                                    ELSE
                                        BEGIN
                                            UPDATE cpi_case
                                            SET patient_type  = par_patient_type,
                                                update_by     = par_update_by,
                                                update_dtm    = par_transaction_datetime,
                                                document_flag = par_document_flag
                                            /* added by PP 011207 */
                                            WHERE hospital_code = par_hospital_code
                                              AND case_no = par_case_no;
                                        END;
                                    END IF;
                                END;
                            ELSE
                                BEGIN
                                    /*
                                    leo 19980105 add to check the previous ward,class,specialty
                                    if all fields are the same write null to cpi_transaction(upload)
                                    */
                                    SELECT last_ward_code,
                                           last_ward_class,
                                           last_specialty
                                    INTO var_prev_ward_code, var_prev_ward_class, var_prev_specialty_code
                                    FROM cpi_case
                                    WHERE hospital_code = par_hospital_code
                                      AND case_no = par_case_no
                                      AND status_code != 'CC';

                                    IF var_prev_ward_code = par_ward_code AND var_prev_ward_class = par_ward_class AND
                                       var_prev_specialty_code = par_specialty_code THEN
                                        BEGIN
                                            SELECT NULL,
                                                   NULL,
                                                   NULL
                                            INTO var_prev_ward_code, var_prev_ward_class, var_prev_specialty_code;
                                        END;
                                    END IF;

                                    /* leo 19980105 end */
                                    UPDATE cpi_case
                                    SET admission_dtm      = par_admission_datetime,
                                        source_indicator   = par_source_indicator,
                                        source_code        = par_source_code,
                                        patient_type       = par_patient_type,
                                        last_ward_code     = par_ward_code,
                                        last_ward_class    = par_ward_class,
                                        last_bed_no        = par_bed_no,
                                        last_specialty     = par_specialty_code,
                                        last_sub_specialty = par_sub_specialty,
                                        pp_code            = par_pp_code,
                                        update_by          = par_update_by,
                                        update_dtm         = par_transaction_datetime,
                                        document_flag      = par_document_flag
                                    /* added by PP 011207 */
                                    WHERE hospital_code = par_hospital_code
                                      AND case_no = par_case_no;
                                END;
                            END IF /* end if (@update_type = P) */;
                        END;
                    END IF;
                END IF;
            END IF;
            /*var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;*/
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF (var_error != 0) OR (var_rowcount = 0) THEN
            BEGIN
                /*
                print Fail to update cpi_case,
                update admission registration is rejected!
                */
                SELECT 10002
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;
        /* --- added by WL for insert event log -- */

        IF par_source_system <> 'ADT' AND par_case_type = 'I' THEN
            begin

                /* -- get necessary data for insert eventlog -- */
                SELECT patient_name,
                       patient_key,
                       sex,
                       dob,
                       exact_dob_flag,
                       cccode1,
                       cccode2,
                       cccode3,
                       cccode4,
                       cccode5,
                       cccode6,
                       marital_status,
                       race,
                       other_doc_no,
                       building,
                       room,
                       floor,
                       block,
                       district,
                       religion,
                       phone1,
                       phone2,
                       address_indicator,
                       mobile_phone,
                       sms_language,
                       death_indicator,
                       death_date,
                       access_code
                INTO var_pat_name, var_pat_key, var_pat_sex, var_pat_dob, var_pat_exact_dob_flag, var_pat_ccc1, var_pat_ccc2, var_pat_ccc3, var_pat_ccc4, var_pat_ccc5, var_pat_ccc6, var_pat_martial_status, var_pat_race, var_pat_other_doc_no, var_pat_bldg, var_pat_room, var_pat_floor, var_pat_block, var_pat_district_code, var_pat_religion_code, var_pat_phone1, var_pat_mobile_phone1, var_pat_mobile_phone1_ext, var_pat_mobile_phone2, var_pat_mobile_phone2_ext, var_death_ind, var_death_dtm, var_pmi_access_code
                FROM cpi_patient
                WHERE hkid = par_hkid;
                SELECT nok_name,
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
                INTO var_nok_name, var_nok_hkid, var_nok_relation_code, var_nok_bldg, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_mobile_phone1, var_nok_mobile_phone1_ext, var_nok_mobile_phone2, var_nok_mobile_phone2_ext
                FROM cpi_nok
                WHERE patient_key = var_pat_key
                  AND major_nok = 'Y';
                SELECT Access_code,
                       Security_count,
                       Movement_count
                INTO var_case_access_code, var_security_cnt, var_movement_cnt
                FROM Case_view
                WHERE Case_no = par_case_no
                  AND Hospital_code = par_hospital_code;
                SELECT mrn
                INTO var_pat_mrn
                FROM cpi_patient_hospital_data
                WHERE patient_key = var_pat_key
                  AND hospital_code = par_hospital_code;
                SELECT 'hasp_insert_event_log'
                INTO var_insert_event_log_prg;
                SELECT '120'
                INTO var_insert_event_log_type;
                SELECT timestamp_convert(localtimestamp)
                INTO var_insert_event_log_dtm;
                /* -- avoid duplicate when insert event log, check first- */
                CALL hasp_get_event_log_dtm(var_return_code, par_hospital_code, var_insert_event_log_dtm);
                /* --- insert before image into event log--- */
                CALL hasp_insert_event_log(
                        var_insert_event_log_ret_code, var_insert_event_log_dtm,
                        var_insert_event_log_type, par_hkid, var_pat_name, var_pat_sex, var_pat_dob,
                        var_pat_exact_dob_flag, var_pat_ccc1, var_pat_ccc2, var_pat_ccc3,
                        var_pat_ccc4, var_pat_ccc5, var_pat_ccc6, var_pat_martial_status,
                        var_pat_race, var_pat_other_doc_no, var_pat_mrn, var_pat_bldg, var_pat_room,
                        var_pat_floor, var_pat_block, var_pat_district_code, var_pat_religion_code,
                        var_pat_phone1, var_pat_mobile_phone1, var_pat_mobile_phone1_ext,
                        var_pat_mobile_phone2, var_pat_mobile_phone2_ext, var_death_ind,
                        var_death_dtm, var_pat_key, var_nok_name, var_nok_hkid,
                        var_nok_relation_code, var_nok_bldg, var_nok_room, var_nok_floor,
                        var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_mobile_phone1,
                        var_nok_mobile_phone1_ext, var_nok_mobile_phone2, var_nok_mobile_phone2_ext,
                        par_case_no, par_admission_datetime, par_source_indicator, par_source_code,
                        var_before_paycode, NULL, /* disc code */ NULL, /* disc dtm */
                        NULL, /* dest code */ par_case_type, var_movement_cnt, var_security_cnt,
                        var_case_access_code, var_pmi_access_code, NULL, /* ambulance no */
                        NULL, /* police case */ NULL, /* labour case */ NULL, /* ae case type */
                        NULL, /* dba flag */ NULL, /* follow up dtm */ NULL, /* ward */
                        NULL, /* spec */ NULL, /* bed */ NULL, /* ward class */ var_pat_name,
                        par_hkid, var_pat_sex, var_pat_dob, par_ward_class, /* old ward class */
                        par_ward_code, /* old ward code */ par_specialty_code, /* old spec code */
                        par_bed_no, /* old bed no */ par_update_by, /* user id */
                        NULL, /* doctor code */ NULL, /* old doctor code */ NULL, /* old tprk */
                        NULL, /* mrts */ 'P'); /* upload status */


                IF var_insert_event_log_ret_code <> 0 THEN
                    BEGIN
                        /* print Fail to insert event log */
                        SELECT 200023
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
                /* --- insert after image into event log--- */
                SELECT '121'
                INTO var_insert_event_log_type;
                SELECT timestamp_convert(localtimestamp)
                INTO var_insert_event_log_dtm;
                /* -- avoid duplicate when insert eventlog, check first-- */
                CALL hasp_get_event_log_dtm(var_return_code, par_hospital_code, var_insert_event_log_dtm);
                CALL hasp_insert_event_log(
                        var_insert_event_log_ret_code, par_hospital_code, var_insert_event_log_dtm,
                        var_insert_event_log_type, par_hkid, var_pat_name, var_pat_sex, var_pat_dob,
                        var_pat_exact_dob_flag, var_pat_ccc1, var_pat_ccc2, var_pat_ccc3,
                        var_pat_ccc4, var_pat_ccc5, var_pat_ccc6, var_pat_martial_status,
                        var_pat_race, var_pat_other_doc_no, var_pat_mrn, var_pat_bldg, var_pat_room,
                        var_pat_floor, var_pat_block, var_pat_district_code, var_pat_religion_code,
                        var_pat_phone1, var_pat_mobile_phone1, var_pat_mobile_phone1_ext,
                        var_pat_mobile_phone2, var_pat_mobile_phone2_ext, var_death_ind,
                        var_death_dtm, var_pat_key, var_nok_name, var_nok_hkid,
                        var_nok_relation_code, var_nok_bldg, var_nok_room, var_nok_floor,
                        var_nok_block, var_nok_district_code, var_nok_phone1, var_nok_mobile_phone1,
                        var_nok_mobile_phone1_ext, var_nok_mobile_phone2, var_nok_mobile_phone2_ext,
                        par_case_no, par_admission_datetime, par_source_indicator, par_source_code,
                        par_patient_type, NULL, /* disc code */ NULL, /* disc dtm */
                        NULL, /* dest code */ par_case_type, var_movement_cnt, var_security_cnt,
                        var_case_access_code, var_pmi_access_code, NULL, /* ambulance no */
                        NULL, /* police case */ NULL, /* labour case */ NULL, /* ae case type */
                        NULL, /* dba flag */ NULL, /* follow up dtm */ par_ward_code, /* ward */
                        par_specialty_code, /* spec */ par_bed_no, /* bed */
                        par_ward_class, /* ward class */ var_pat_name, par_hkid, var_pat_sex,
                        var_pat_dob, NULL, /* old ward class */ NULL, /* old ward code */
                        NULL, /* old spec code */ NULL, /* old bed no */ par_update_by, /* user id */
                        NULL, /* doctor code */ NULL, /* old doctor code */ NULL, /* old tprk */
                        NULL, /* mrts */ 'P'); /* upload status */


                IF var_insert_event_log_ret_code <> 0 THEN
                    BEGIN
                        /* print Fail to insert event log */
                        SELECT 200023
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;
        /* ********************* */
        /* update cpi_movement */
        /* ********************* */
        IF par_case_type = 'O' THEN
            BEGIN
                begin


                    UPDATE cpi_movement
                    SET movement_dtm = par_admission_datetime,
                        specialty    = par_specialty_code,
                        update_dtm   = par_transaction_datetime,
                        update_by    = par_update_by
                    WHERE hospital_code = par_hospital_code
                      AND case_no = par_case_no
                      AND movement_count = 1;
                    var_error := 0;
                    /* EXCEPTION
                         WHEN OTHERS THEN
                             var_error := 1;*/
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 14005
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
            END;
        ELSE
            IF (par_case_type = 'A') THEN
                BEGIN
                    SELECT movement_count
                    INTO var_movement_count
                    FROM cpi_case
                    WHERE case_no = par_case_no
                      AND hospital_code = par_hospital_code;

                    IF var_movement_count != 1 AND coalesce(par_update_type, 'null') != 'P' THEN
                        BEGIN
                            SELECT 10002
                            INTO var_return_error_code;
                            SELECT 'N'
                            INTO var_success_flag;
                            RAISE exception '';
                        END;
                    END IF;
                    /* update cpi_movement only when update_type <> 'P' */
                    IF par_update_type <> 'P' THEN
                        BEGIN
                            BEGIN
                                UPDATE cpi_movement
                                SET movement_dtm = par_admission_datetime,
                                    update_dtm   = par_transaction_datetime,
                                    update_by    = par_update_by
                                WHERE hospital_code = par_hospital_code
                                  AND case_no = par_case_no
                                  AND movement_count = 1;
                                var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF (var_error != 0) OR (var_rowcount = 0) THEN
                                BEGIN
                                    SELECT 14005
                                    INTO var_return_error_code;
                                    SELECT 'N'
                                    INTO var_success_flag;
                                    RAISE exception '';
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            ELSE
                IF (par_case_type = 'I') THEN
                    BEGIN
                        SELECT movement_count
                        INTO var_movement_count
                        FROM cpi_case
                        WHERE case_no = par_case_no
                          AND hospital_code = par_hospital_code;

                        IF var_movement_count != 1 AND coalesce(par_update_type, 'null') != 'P' THEN
                            BEGIN
                                SELECT 10002
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                RAISE exception '';
                            END;
                        END IF;

                        IF par_update_type <> 'P' THEN
                            /* --- 20050725 for PBRC---- */
                            BEGIN
                                /* use sub-query instead of group by/having */
                                SELECT treatment_location
                                INTO var_treatment_location
                                FROM ward
                                WHERE ward_code = par_ward_code
                                  AND hospital_code = par_hospital_code
                                  AND effective_date = (SELECT MAX(effective_date)
                                                        FROM ward
                                                        WHERE ward_code = par_ward_code
                                                          AND hospital_code = par_hospital_code
                                                          AND effective_date <= par_admission_datetime
                                                          AND active_status = 'A');
                                /*
                                and effective_date <= @admission_datetime
                                group by ward_code
                                having effective_date = max(effective_date)
                                and active_status = A
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
                                        SELECT 10005
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        RAISE exception '';
                                    END;
                                END IF;
                            END;
                        END IF;
                        /* update cpi_movement only when update_type <> 'P' */
                        /* 20170223/M/Victor/allow to update the movement record when source system is ADT */
                        IF par_update_type <> 'P' OR par_source_system = 'ADT' THEN
                            BEGIN
                                BEGIN
                                    UPDATE cpi_movement
                                    SET movement_dtm       = par_admission_datetime,
                                        ward_code          = par_ward_code,
                                        ward_class         = par_ward_class,
                                        bed_no             = par_bed_no,
                                        specialty          = par_specialty_code,
                                        treatment_location = var_treatment_location,
                                        update_by          = par_update_by,
                                        update_dtm         = par_transaction_datetime
                                    WHERE hospital_code = par_hospital_code
                                      AND case_no = par_case_no
                                      AND movement_count = 1;
                                    var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                                END;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                var_rowcount := sql$rowcount;

                                IF (var_error != 0) OR (var_rowcount = 0) THEN
                                    BEGIN
                                        SELECT 14005
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        RAISE exception '';
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
            END IF;
        END IF;
        /* update Ward_list and HN_case_detail is not update patient type */
        IF par_case_type = 'I' AND par_update_type <> 'P' THEN
            BEGIN
                BEGIN
                    UPDATE Ward_list
                    SET Ward_code      = par_ward_code,
                        Specialty_code = par_specialty_code
                    WHERE Hospital_code = par_hospital_code
                      AND Case_no = par_case_no;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 10007
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;

                IF par_pp_code IS NOT NULL THEN
                    BEGIN
                        BEGIN
                            IF EXISTS (SELECT *
                                       FROM HN_case_detail
                                       WHERE Hospital_code = par_hospital_code
                                         AND Case_no = par_case_no) THEN
                                UPDATE HN_case_detail
                                SET PP_code = par_pp_code
                                WHERE Hospital_code = par_hospital_code
                                  AND Case_no = par_case_no;
                            ELSE
                                INSERT INTO HN_case_detail (hospital_code, case_no, internal_icd9_code,
                                                            external_icd9_code, pp_code)
                                VALUES (par_hospital_code, par_case_no, NULL, NULL, par_pp_code);
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
                                SELECT 10008
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                RAISE exception '';
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* Retrieve the case information if only patient type is updated */
        IF ((par_case_type = 'I') AND (par_update_type = 'P')) OR
           (par_case_type = 'A' AND par_update_type = 'P' AND par_source_system = 'PBRC') THEN
            BEGIN
                BEGIN
                    SELECT admission_dtm,
                           source_indicator,
                           source_code,
                           m.ward_code,
                           m.ward_class,
                           m.specialty,
                           last_sub_specialty,
                           m.bed_no,
                           discharge_code,
                           discharge_dtm,
                           destination_code
                    INTO par_admission_datetime, par_source_indicator, par_source_code, par_ward_code, par_ward_class, par_specialty_code, par_sub_specialty, par_bed_no, par_discharge_code, par_discharge_datetime, par_destination_code
                    FROM cpi_case AS c,
                         cpi_movement AS m
                    WHERE c.hospital_code = par_hospital_code
                      AND c.case_no = par_case_no
                      AND m.case_no = par_case_no
                      AND m.hospital_code = par_hospital_code
                      AND m.movement_count = 1;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 10001
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;
        /* Retrieve the case information if only patient type is updated */
        /*
        if (@case_type = A) and (@update_type = P)
        begin
           select @admission_datetime = admission_dtm,
                  @discharge_code = discharge_code,
                  @discharge_datetime = discharge_dtm,
                  @destination_code = destination_code,
                  @ambulance_no = ambulance_no,
                  @police_case = police_case,
                  @labour_case = labour_case_flag,
                  @ae_case_type = ae_case_type,
                  @dba_flag = dba_flag,
                  @follow_up_datetime = follow_up_datetime
           from  cpi_case c, cpi_ae_case_detail m
           where c.hospital_code = @hospital_code
             and c.case_no = @case_no
             and m.case_no = @case_no
             and m.hospital_code = @hospital_code
        
           select @error = @@error, @rowcount = @@rowcount
           if (@error != 0) or (@rowcount = 0)
           begin
              select @return_error_code = 10001
              select @success_flag = N
              goto return_error
           end
        end
        */
        /* ---20050830 ------------------ */
        IF (par_case_type = 'A') AND (par_update_type = 'P') THEN
            BEGIN
                /*
                and m.case_no = @case_no
                and m.hospital_code = @hospital_code
                */
                BEGIN
                    SELECT admission_dtm,
                           discharge_code,
                           discharge_dtm,
                           destination_code
                    INTO par_admission_datetime, par_discharge_code, par_discharge_datetime, par_destination_code
                    /*
                    @ambulance_no = ambulance_no
                    @police_case = police_case,
                    @labour_case = labour_case_flag,
                    @ae_case_type = ae_case_type,
                    @dba_flag = dba_flag,
                    */
                    /* @follow_up_datetime = follow_up_datetime */
                    FROM cpi_case /* c cpi_ae_case_detail m */
                    WHERE case_no = par_case_no
                      AND hospital_code = par_hospital_code;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 10001
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --- PBRC always =TRUE if ( @ambulance_no is  null  and  @police_case is null and @labour_case =null and @ae_case_type = null and   @dba_flag = null) */
        /* --- ADT alwasy =FALSE */

        IF (par_case_type = 'A') AND (par_update_type = 'P') AND par_source_system <> 'ADT' THEN
            /* --	and ( @ambulance_no is  null  and  @police_case is null and @labour_case =null and @ae_case_type = null and   @dba_flag = null) */
            BEGIN
                BEGIN
                    /*
                    @admission_datetime = admission_dtm,
                    @discharge_code = discharge_code,
                    @discharge_datetime = discharge_dtm,
                    @destination_code = destination_code
                    */
                    SELECT ambulance_no,
                           police_case,
                           labour_case_flag,
                           ae_case_type,
                           dba_flag,
                           follow_up_datetime
                    INTO par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba_flag, par_follow_up_datetime
                    FROM /* cpi_case , */ cpi_ae_case_detail
                    WHERE
                        /*
                        c.hospital_code = @hospital_code
                        and c.case_no = @case_no
                        */
                        case_no = par_case_no
                      AND hospital_code = par_hospital_code;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF (var_error != 0) OR (var_rowcount = 0) THEN
                    BEGIN
                        SELECT 10001
                        INTO var_return_error_code;
                        SELECT 'N'
                        INTO var_success_flag;
                        RAISE exception '';
                    END;
                END IF;
            END;
        END IF;
        /* ---20050830 ------------------ */
        IF (par_case_type = 'A') AND par_source_system <> 'PBRC' THEN
            BEGIN
                SELECT COUNT(*)
                INTO var_cnt
                FROM cpi_ae_case_detail
                WHERE hospital_code = par_hospital_code
                  AND case_no = par_case_no;

                IF (var_cnt = 1) THEN
                    BEGIN
                        BEGIN
                            UPDATE cpi_ae_case_detail
                            SET ambulance_no       = par_ambulance_no,
                                police_case        = par_police_case,
                                labour_case_flag   = par_labour_case,
                                ae_case_type       = par_ae_case_type,
                                dba_flag           = par_dba_flag,
                                follow_up_datetime = par_follow_up_datetime,
                                pp_code            = par_pp_code /* 20040315 SL */
                            WHERE hospital_code = par_hospital_code
                              AND case_no = par_case_no;
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
                                print Fail to update cpi_ae_case_detail,
                                update admission registration is rejected!
                                */
                                SELECT 10003
                                INTO var_return_error_code;
                                SELECT 'N'
                                INTO var_success_flag;
                                RAISE exception '';
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /*
        20020726 SL : update cpi_case_detail
        * error_msgs.error_code 10011 -Fail to update cpi_case_detail,update admission registration is rejected!
        *	update cpi_ae_case_detail/HN_case_detail.EH_code by PBL's DW
        */
        /* ---if (@case_type = A or @case_type=I) */
        IF (par_txn_type = '121' OR par_txn_type = '341') AND par_source_system <> 'PBRC' THEN
            BEGIN
                SELECT COUNT(*)
                INTO var_cnt
                FROM cpi_case_detail
                WHERE hospital_code = par_hospital_code
                  AND case_no = par_case_no;

                IF (var_cnt = 1) THEN
                    BEGIN
                        BEGIN
                            SELECT eh_code,
                                   document_flag
                            INTO var_prev_eh_code, var_prev_document_flag
                            FROM cpi_case_detail
                            WHERE hospital_code = par_hospital_code
                              AND case_no = par_case_no;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                        var_rowcount := sql$rowcount;

                        IF RTRIM(LTRIM(var_prev_eh_code)) is NULL THEN
                            SELECT NULL
                            INTO var_prev_eh_code;
                        END IF;
                        /*
                        if eh_code changed & inputed eh_code Can be Null
                        *	it will  update en_code to NULL
                        */
                        IF (var_rowcount = 1) AND
                           (COALESCE(var_prev_eh_code, 'null') != COALESCE(par_eh_code, 'null')) THEN /* and (@eh_code!=null) */
                            BEGIN
                                BEGIN
                                    UPDATE cpi_case_detail
                                    SET eh_code = par_eh_code
                                    WHERE hospital_code = par_hospital_code
                                      AND case_no = par_case_no;
                                  
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
                                        print Fail to update cpi_case_detail,
                                        update admission registration is rejected!
                                        */
                                        SELECT 10011
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        RAISE exception '';
                                    END;
                                END IF;
                            END;
                        END IF; /* if eh_code changed */

                        IF (var_rowcount = 1) AND (coalesce(var_prev_document_flag, 'null') != coalesce(par_document_flag, 'null')) THEN
                            BEGIN
                                BEGIN
                                    UPDATE cpi_case_detail
                                    SET document_flag = par_document_flag
                                    WHERE hospital_code = par_hospital_code
                                      AND case_no = par_case_no;
                                    raise notice 'cpi_update_adm_registration[UPDATE] cpi_case_detail case_no=%',par_case_no;
                                    var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                                END;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                var_rowcount := sql$rowcount;

                                IF (var_error != 0) OR (var_rowcount = 0) THEN
                                    BEGIN
                                        SELECT 10011
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        RAISE exception '';
                                    END;
                                END IF;
                            END;
                        END IF;
                    END; /* No case found in cpi_case_detail */
                ELSE
                    BEGIN
                        IF (par_eh_code IS NOT NULL) OR (par_document_flag IS NOT NULL) THEN
                            BEGIN
                                BEGIN
                                    INSERT INTO cpi_case_detail (hospital_code, case_no, document_flag, eh_code)
                                    VALUES (par_hospital_code, par_case_no, par_document_flag, par_eh_code);
                                    raise notice 'cpi_update_adm_registration[INSERT] cpi_case_detail case_no=%',par_case_no;
                                    var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS then
                                   
                                        var_error := 1;
                                END;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                var_rowcount := sql$rowcount;
						
                                IF (var_error != 0) OR (var_rowcount = 0) THEN
                                    begin
	                                  
                                        /*
                                        print Fail to insert cpi_case_detail,
                                        admission is rejected!
                                        */
                                        SELECT 1031
                                        INTO var_return_error_code;
                                        SELECT 'N'
                                        INTO var_success_flag;
                                        RAISE exception '';
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        
        /* Retrieve EH Code from cpi_case_detail if update by PBRC */
        IF (par_txn_type = '121' OR par_txn_type = '341') AND par_source_system = 'PBRC' THEN
            BEGIN
                BEGIN
                    SELECT eh_code
                    INTO par_eh_code
                    FROM cpi_case_detail
                    WHERE hospital_code = par_hospital_code
                      AND case_no = par_case_no;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT NULL
                        INTO par_eh_code;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        SELECT NULL
                        INTO par_eh_code;
                END;
            END;
        END IF;
        /* ---- 20020726 SL : update cpi_case_detail */

        /* ***************20070329 SL cpi_linked_case ********************** */

        /* Only enabled for IPAS, exclude OPAS/PBRC/DNL,etc */
        IF par_source_system IN ('PBRC', 'OPAS') AND (par_case_type IN ('A', 'I')) THEN
            BEGIN
                /* ---- will be used for cpi_filler && cpi_uplod --- */
                SELECT previous_hospital,
                       previous_case
                INTO par_source_hosp_code, par_source_case_no
                FROM cpi_linked_case
                WHERE hospital_code = par_hospital_code
                  AND case_no = par_case_no;
            END;
        END IF;
        IF (coalesce(par_source_system, 'null') <> 'DNL') AND (par_case_type IN ('A', 'I')) then

            BEGIN
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
                /* --- Insert/Update mode --- */

                IF (par_source_hosp_code IS NOT NULL) AND (par_source_case_no IS NOT NULL) THEN
                    begin
                        SELECT NULL,
                               NULL
                        INTO var_old_source_hosp_code, var_old_source_case_no;
                        SELECT previous_hospital,
                               previous_case
                        INTO var_old_source_hosp_code, var_old_source_case_no
                        FROM cpi_linked_case
                        WHERE hospital_code = par_hospital_code
                          AND case_no = par_case_no;
                        /* Validate the Linked case if the source case changed for Insert/Update */
                        IF (par_source_hosp_code <> var_old_source_hosp_code) OR
                           (par_source_case_no <> var_old_source_case_no) THEN
                            BEGIN
                                /* Check the input Source_case belong to same patient or not */
                                /* Check Local firstly */
                                IF par_hospital_code = par_source_hosp_code then

                                    BEGIN
                                        SELECT patient_key
                                        INTO var_lnk_case_patient_key
                                        FROM cpi_case
                                        WHERE hospital_code = par_source_hosp_code
                                          AND case_no = par_source_case_no
                                          AND status_code = 'AC';
                                        SELECT patient_key
                                        INTO var_patient_key
                                        FROM cpi_patient
                                        WHERE hkid = par_hkid;
                                        IF (var_lnk_case_patient_key is not null and var_lnk_case_patient_key <> var_patient_key) or (var_lnk_case_patient_key is null and var_patient_key is not null) THEN
                                            BEGIN
                                                SELECT 200038
                                                INTO var_return_error_code;
                                                SELECT 'N'
                                                INTO var_success_flag;
                                                RAISE exception '';
                                            END;
                                        END IF;
                                    END;
                                ELSE
                                    begin                                        
	                                    -- replace_dblink_by_fdw	
	                                    SELECT 'N' INTO var_valid_flag;                    
			                            CALL hkpmi.cpi_pq_validate_caseno(var_return_code,par_source_case_no, par_source_hosp_code, var_valid_flag, par_hkid);
			                           	SET search_path TO hpi,public;
			                           	IF COALESCE (var_valid_flag,'null') <> 'Y' THEN 
                                            BEGIN
                                                SELECT 200038
                                                INTO var_return_error_code;
                                                SELECT 'N'
                                                INTO var_success_flag;
                                                RAISE exception '';
                                            END;
                                        END IF;
                                    END;
                                END IF;
                            END;
                        END IF;
                        /* END of : Validate the Linked case if the source case changed for Insert/Update */
                        /* ---- Insert Mode ---- */
                        IF NOT EXISTS (SELECT *
                                       FROM cpi_linked_case
                                       WHERE hospital_code = par_hospital_code
                                         AND case_no = par_case_no) THEN
                            begin
                                BEGIN
                                    INSERT INTO cpi_linked_case (hospital_code, case_no, previous_hospital,
                                                                 previous_case, create_by, create_dtm, update_by,
                                                                 update_dtm)
                                    VALUES (par_hospital_code, par_case_no, par_source_hosp_code, par_source_case_no,
                                            par_update_by, timestamp_convert(localtimestamp), par_update_by, timestamp_convert(localtimestamp));
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
                                        RAISE exception '';
                                    END;
                                END IF;
                            END;
                            /* ------update mode ------ */
                        ELSE
                            begin
                                IF (par_source_hosp_code <> var_old_source_hosp_code) OR
                                   (par_source_case_no <> var_old_source_case_no) THEN
                                    begin
	                                    
	                                    BEGIN
                                            UPDATE cpi_linked_case
                                            SET previous_hospital = par_source_hosp_code,
                                                previous_case     = par_source_case_no,
                                                update_by         = par_update_by,
                                                update_dtm        = timestamp_convert(localtimestamp)
                                            WHERE hospital_code = par_hospital_code
                                              AND case_no = par_case_no;
                                            
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
                                                RAISE exception '';
                                            END;
                                        END IF;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                ELSE
                    /* --- delete mode --- ELSE of : if (@source_hosp_code is not null) and (@source_case_no is not null) */
                    begin

                        IF EXISTS (SELECT *
                                   FROM cpi_linked_case
                                   WHERE hospital_code = par_hospital_code
                                     AND case_no = par_case_no) THEN
                            BEGIN
                                begin
                                    DELETE
                                    FROM cpi_linked_case
                                    WHERE hospital_code = par_hospital_code
                                      AND case_no = par_case_no;
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
                                        RAISE exception '';
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* ***************** 20070329 SL ***************************** */
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
        */
        SELECT COUNT(*)
        INTO var_cnt
        FROM cpi_transaction
        WHERE hospital_code = par_hospital_code
          AND transaction_datetime = par_transaction_datetime;

        IF (var_cnt != 0) THEN
            BEGIN
                SELECT 'N'
                INTO var_exit_flag;

                WHILE (var_exit_flag = 'N')
                    LOOP
                        SELECT 1 * INTERVAL '1 second' + par_transaction_datetime::TIMESTAMP
                        INTO par_transaction_datetime;
                        SELECT COUNT(*)
                        INTO var_cnt
                        FROM cpi_transaction
                        WHERE hospital_code = par_hospital_code
                          AND transaction_datetime = par_transaction_datetime;

                        IF (var_cnt = 0) THEN
                            SELECT 'Y'
                            INTO var_exit_flag;
                        END IF;
                    END LOOP;
            END;
        END IF;
        /* 20020726 SL: */
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

        SELECT CONCAT(REPEAT(' ', 1),
                      SUBSTRING(CONCAT(par_document_flag, REPEAT(' ', 1)), 1, 1),
                      SUBSTRING(CONCAT(par_eh_code, REPEAT(' ', 8)), 1, 8),
                      SUBSTRING(CONCAT(par_source_hosp_code, REPEAT(' ', 3)), 1, 3),
                      SUBSTRING(CONCAT(par_source_case_no, REPEAT(' ', 12)), 1, 12))
        INTO var_cpi_filler;

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
            VALUES (par_hospital_code, par_transaction_datetime, par_txn_type, par_hkid, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_case_no,
                    par_admission_datetime, par_source_indicator, par_source_code, par_patient_type, par_discharge_code,
                    par_discharge_datetime, par_destination_code, NULL, par_case_type, NULL, NULL, NULL,
                    par_ambulance_no, par_police_case, par_labour_case, par_ae_case_type, par_dba_flag,
                    par_follow_up_datetime, par_ward_code, par_specialty_code, par_sub_specialty, par_bed_no,
                    par_ward_class, NULL, NULL, NULL, NULL, NULL, NULL, var_prev_ward_class, var_prev_ward_code,
                    var_prev_specialty_code, NULL, NULL, par_pp_code, par_hospital_code, par_update_by, timestamp_convert(localtimestamp),
                    par_source_system, var_success_flag, var_upload_status, var_source_system_dtm, var_cpi_filler);
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
                print Fail to insert cpi_transaction,
                update admission registration is rejected!
                */
                SELECT 10004
                INTO var_return_error_code;
                SELECT 'N'
                INTO var_success_flag;
                RAISE exception '';
            END;
        END IF;

        <<insert_transaction>>
        BEGIN
        END;
    END;
	 IF (var_success_flag = 'N') THEN
        begin
	        
            /*
            [9996 - Severity CRITICAL - Transformer error occurred in statement. Please submit report to developers.]
            rollback cpi_update_adm_registration
            */
			raise exception '';	
            pas_return_code := var_return_error_code;
            RETURN;
        END;
    else
   
        pas_return_code := 0;
        RETURN;
    END IF;
	EXCEPTION
		WHEN OTHERS then
		BEGIN
			IF var_return_error_code IS NOT NULL THEN
				RAISE NOTICE 'cpi_update_adm_registration var_return_error_code => %',var_return_error_code;
				pas_return_code := var_return_error_code;
			ELSE
				RAISE NOTICE 'cpi_update_adm_registration execute error => %',SQLERRM;
				RAISE EXCEPTION '%',SQLERRM;
			END IF;
		END;	
    RETURN;

END;
$procedure$
;

;ALTER PROCEDURE "cpi_update_adm_registration" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
