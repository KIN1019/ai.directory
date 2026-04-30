-- DROP PROCEDURE hpi.cpi_patient_update(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in int4, inout varchar, inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_patient_update(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_patient_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc_1 character varying, IN par_ccc_2 character varying, IN par_ccc_3 character varying, IN par_ccc_4 character varying, IN par_ccc_5 character varying, IN par_ccc_6 character varying, IN par_chi_name character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_reference character varying, IN par_medical_record_number character varying, IN par_remark character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_death_code character varying, IN par_card_holder integer, INOUT par_patient_key character varying, INOUT par_priority integer, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_txn_type character varying, IN par_access_code integer, IN par_security integer, IN par_transaction_datetime timestamp without time zone, IN par_update_hospital character varying, IN par_update_by character varying, IN par_last_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_document_flag character varying DEFAULT NULL::bpchar, IN par_hkic_symbol character varying DEFAULT NULL::bpchar, IN par_hkic_symbol_clear character varying DEFAULT 'N'::bpchar)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_int_value                 INTEGER;
    var_cnt                       INTEGER;
    var_new_patient_key           VARCHAR(8);
    var_return_status             INTEGER;
    var_n_prior                   INTEGER;
    var_major_nok                 VARCHAR(1);
    var_tmp_mrn                   VARCHAR(8);
    var_patient_no                INTEGER;
    var_rep_hospital              INTEGER;
    var_rep_clusters              INTEGER;
    var_success_flag              VARCHAR(1);
    var_exit_flag                 VARCHAR(1);
    var_tmp_phonetic              VARCHAR(48);
    var_chk_update_datetime       TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime           TIMESTAMP WITHOUT TIME ZONE;
    var_return_error_code         INTEGER;
    var_download_err_string       VARCHAR(255);
    var_source_system_dtm         TIMESTAMP WITHOUT TIME ZONE;
    var_error                     INTEGER;
    var_rowcount                  INTEGER;
    var_upload_status             VARCHAR(1);
    var_old_patient_name          VARCHAR(48);
    var_old_sex                   VARCHAR(01);
    var_old_dob                   TIMESTAMP WITHOUT TIME ZONE;
    var_old_update_hospital       VARCHAR(03);
    var_patient_exists            VARCHAR(01);
    var_old_hkid                  VARCHAR(12);
    var_tmp_priority              INTEGER;
    var_cpi_filler                VARCHAR(30);
    var_min_adm_dtm               TIMESTAMP WITHOUT TIME ZONE;
    var_old_hkic_symbol           VARCHAR(1);
    var_update_hkic_symbol        VARCHAR(1);
    var_insert_event_log_type     VARCHAR(3);
    var_insert_event_log_prg      VARCHAR(35);
    var_insert_event_log_dtm      TIMESTAMP WITHOUT TIME ZONE;
    var_insert_event_log_ret_code INTEGER;
    var_event_log_mrn             VARCHAR(8);
    var_is_schi_name              VARCHAR(01);
    var_case_no                   VARCHAR(12);
    var_rpc_call                  VARCHAR(100);
    var_return_code               INTEGER;
    var_exception_flag            VARCHAR(1);
    var_org_doc_code              VARCHAR(1);
    var_hkpmi_srvr                varchar;
    var_error_msg                 VARCHAR(255);
    var_pmi_prk                   VARCHAR(8);
    var_pmi_name                  VARCHAR(48);
    var_pmi_sex                   VARCHAR(1);
    var_pmi_dob                   TIMESTAMP WITHOUT TIME ZONE;
    var_pmi_exact_dob             VARCHAR(1);
    var_pmi_ccc_1                 VARCHAR(5);
    var_pmi_ccc_2                 VARCHAR(5);
    var_pmi_ccc_3                 VARCHAR(5);
    var_pmi_ccc_4                 VARCHAR(5);
    var_pmi_ccc_5                 VARCHAR(5);
    var_pmi_ccc_6                 VARCHAR(5);
    var_pmi_update_by             VARCHAR(8);
    var_pmi_src_system            VARCHAR(5);
    var_pmi_update_dtm            TIMESTAMP WITHOUT TIME ZONE;
    var_pmi_hosp_code             VARCHAR(3);
    var_pmi_document_flag         VARCHAR(1);
    sql$rowcount                  BIGINT;
    v_message                     TEXT;
    var_pgm                       VARCHAR(80);
    var_hkpmi_down_flag           VARCHAR(1);
    var_local_hosp                VARCHAR(3);
    db_sql                        TEXT;
BEGIN
    SET
        search_path TO hpi,PUBLIC;
    <<return_error>>
    BEGIN
        /* Declaration */
        /* --- added by WL for insert event log--- */
        /* 2006-12-12 Addeded by HK Fong SMR20015887 */

        /* 2011-05-11 Added by Eddie for dob > adm_dtm write exception */


        /* ---------------------Begin of 20051102 SL  -------------------------------------------- */

        IF
            par_source_system <> 'DNL' AND (par_txn_type IN ('010','031'))
        THEN
            begin
	            raise notice 'SUBSTRING(par_hkid,1,1)=%',SUBSTRING(par_hkid,1,1);
                /* ---1)	If HKID is changed or transaction type is PMI Registration with non-Pseudo HKID, reject update if primary HKPMI server is not available */

                IF
                    (SUBSTRING(par_hkid,1,1) != 'U')
                THEN
                    BEGIN
 
                        /*SELECT NULL
                        INTO var_hkpmi_srvr;
/* ---cis rpc --- */

                        CALL cpi_get_rpc_server(pas_return_code => var_return_code,par_server_type => 'HKPMI_SERVER',
                                                par_rpc_server => var_hkpmi_srvr);

--                                           SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;

                        IF
                            var_hkpmi_srvr IS NULL
                        THEN
                            BEGIN

                                SELECT 'Primary HKPMI server is not available, PMI Registration, Change HKID, Move Episode and Merge Patient functions are prohibited.'
                                INTO var_error_msg;
/* ---raiserror 200034 @error_msg */
                                pas_return_code
                                    := 200034;
                                RETURN;
                            END;
                        END IF;*/
                    END;
                END IF;

                /* ---2).If PMI Registration / HKID is changed, reject update if HKID is already exist in local or HKPMI */
                IF
                    EXISTS (SELECT *
                            FROM
                                cpi_patient
                            WHERE hkid = par_hkid)
                THEN
                    BEGIN

                        SELECT 'HKID already exist !'
                        INTO var_error_msg;
/* ----raiserror 9002 @error_msg */
                        pas_return_code
                            := 9002;
                        RETURN
                        /* ---- error_msg: 9002 New HKID already exists in CPI, change HKID is rejected! */
                        ;
                    END;
                END IF;
                /* --- check HKPMI patient -- */
                /* --if @txn_type <> '010' -- changed for OPAS temporarily  ----20090402 SL : enable checking */

                /* ---begin */

                SELECT NULL
                INTO var_pmi_prk;
				raise notice 'SUBSTRING(par_hkid,1,1)=%',SUBSTRING(par_hkid,1,1);
                CALL cpi_get_hkpmi_major_key(var_return_code,par_hkid,var_pmi_prk,var_pmi_name,var_pmi_sex,var_pmi_dob,
                                             var_pmi_exact_dob,var_pmi_ccc_1,var_pmi_ccc_2,var_pmi_ccc_3,var_pmi_ccc_4,
                                             var_pmi_ccc_5,var_pmi_ccc_6,var_pmi_update_by,var_pmi_src_system,
                                             var_pmi_update_dtm,var_pmi_hosp_code,var_pmi_document_flag);

                --				BEGIN
--			         perform public.dblink_connect('hkpmi'::text, var_hkpmi_srvr);
--			        RAISE NOTICE 'dblink connection established';
--
--			        SELECT '.hkpmi_get_major_key'
--			            INTO var_pgm; /* ---Default DB =download for HKPMI2 !!! */
--			        SELECT
--			            concat(schema_name, var_pgm)
--			        INTO var_rpc_call
--			        FROM hkpmi_control;
--
--
--		         begin
--			        perform public.dblink_connect('hkpmi'::text, var_hkpmi_srvr);
--
--		           db_sql := 'call ' || var_rpc_call || '('
--			        || case when var_return_code is null then 0 else var_return_code end || ','
--			        || case when par_new_hkid is null then 'null::varchar' else concat('''', par_new_hkid, '''::varchar') end || ','
--			        || case when var_pmi_prk is null then 'null::varchar' else concat('''', var_pmi_prk, '''::varchar') end || ','
--			        || case when var_pmi_name is null then 'null::varchar' else concat('''', var_pmi_name, '''::varchar') end || ','
--			        || case when var_pmi_sex is null then 'null::varchar' else concat('''', var_pmi_sex, '''::varchar') end || ','
--			        || case when var_pmi_dob is null then 'null::timestamp without time zone' else concat('''', to_char(var_pmi_dob,'YYYY-MM-DD HH24:MI:SS'), '''::timestamp without time zone') end || ','
--			        || case when var_pmi_exact_dob is null then 'null::varchar' else concat('''', var_pmi_exact_dob, '''::varchar') end || ','
--			        || case when var_pmi_ccc_1 is null then 'null::varchar' else concat('''', var_pmi_ccc_1, '''::varchar') end || ','
--			        || case when var_pmi_ccc_2 is null then 'null::varchar' else concat('''', var_pmi_ccc_2, '''::varchar') end || ','
--			        || case when var_pmi_ccc_3 is null then 'null::varchar' else concat('''', var_pmi_ccc_3, '''::varchar') end || ','
--			        || case when var_pmi_ccc_4 is null then 'null::varchar' else concat('''', var_pmi_ccc_4, '''::varchar') end || ','
--			        || case when var_pmi_ccc_5 is null then 'null::varchar' else concat('''', var_pmi_ccc_5, '''::varchar') end || ','
--			        || case when var_pmi_ccc_6 is null then 'null::varchar' else concat('''', var_pmi_ccc_6, '''::varchar') end || ','
--			        || case when var_pmi_update_by is null then 'null::varchar' else concat('''', var_pmi_update_by, '''::varchar') end || ','
--			        || case when var_pmi_src_system is null then 'null::varchar' else concat('''', var_pmi_src_system, '''::varchar') end || ','
--			        || case when var_pmi_update_dtm is null then 'null::timestamp without time zone' else concat('''', to_char(var_pmi_update_dtm,'YYYY-MM-DD HH24:MI:SS'), '''::timestamp without time zone') end || ','
--			        || case when var_pmi_hosp_code is null then 'null::varchar' else concat('''', var_pmi_hosp_code, '''::varchar') end || ','
--			        || case when var_pmi_document_flag is null then 'null::varchar' else concat('''', var_pmi_document_flag, '''::varchar') end || ');';
--			    raise notice '%', dblink_sql;
--		             select * from public.dblink('hkpmi'::text, dblink_sql::text)
--					 as t1(var_return_code INTEGER,var_pmi_prk varchar,var_pmi_name varchar,var_pmi_sex varchar,var_pmi_dob timestamp without time zone,var_pmi_exact_dob  varchar,var_pmi_ccc_1 varchar,var_pmi_ccc_2 varchar,var_pmi_ccc_3 varchar,var_pmi_ccc_4 varchar,var_pmi_ccc_5 varchar,var_pmi_ccc_6 varchar
--			          	,par_update_by varchar,par_src_system varchar,par_update_dtm timestamp without time zone,par_hosp_code varchar,par_document_flag varchar) into
--			          var_return_code,var_pmi_prk ,var_pmi_name ,var_pmi_sex ,var_pmi_dob  ,var_pmi_exact_dob ,var_pmi_ccc_1 ,var_pmi_ccc_2 ,var_pmi_ccc_3 ,var_pmi_ccc_4 ,var_pmi_ccc_5 ,var_pmi_ccc_6
--			          	,var_pmi_update_by ,var_pmi_src_system ,var_pmi_update_dtm ,var_pmi_hosp_code ,var_pmi_document_flag;
--          perform public.dblink_disconnect('hkpmi'::text);
--		        exception
--		            when others then
--		            perform public.dblink_disconnect('hkpmi'::text);
--		           RAISE NOTICE 'dblink error: %', SQLERRM;
--		        end;
			
                IF
                    var_pmi_prk IS NOT NULL
                THEN
                    /* --- HKPMI patient exist.. */
                    BEGIN

                        SELECT 'HKID already exist !'
                        INTO var_error_msg;
/* ----raiserror 9002 @error_msg */
                        pas_return_code
                            := 9002;
                        RETURN;
                    END;
                END IF;

                --			        EXCEPTION
--			        WHEN OTHERS THEN
--			            RAISE NOTICE 'dblink connection failed: %', SQLERRM;
--			    END;
                /* end */
            END;
        END IF;
        /* --if @source_system <> 'DNL' */
        /* ---------------------End OF : 20051102 SL --------------------------------------- */
        /* --- 20181112 Yorky: Prevent other_doc_no to  be updated as 'null' or 'NULL' value */

        IF
            par_other_document_no IN ('null','NULL')
        THEN
            BEGIN

                SELECT NULL
                INTO par_other_document_no;

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
        INTO var_cnt
        FROM
            cpi_patient
        WHERE patient_key = par_patient_key;

        IF
            (var_cnt != 0)
        THEN
            BEGIN

                SELECT 'Y'
                INTO var_patient_exists;

                SELECT update_dtm, patient_name, sex, dob, update_hospital, hkid, hkic_symbol
                INTO var_chk_update_datetime, var_old_patient_name, var_old_sex, var_old_dob, var_old_update_hospital, var_old_hkid, var_old_hkic_symbol
                FROM
                    cpi_patient
                WHERE patient_key = par_patient_key;

                IF
                    var_old_hkid != par_hkid
                THEN
                    BEGIN

                        SELECT 200007
                        INTO var_return_error_code;

                        SELECT 'N'
                        INTO var_success_flag;

                        RAISE
                            EXCEPTION 'rollback';
                    END;
                END IF;
            END;
        ELSE
            BEGIN

                SELECT COUNT(*)
                INTO var_cnt
                FROM
                    cpi_patient
                WHERE hkid = par_hkid;

                IF
                    (var_cnt != 0)
                THEN
                    BEGIN

                        SELECT 'Y'
                        INTO var_patient_exists;

                        SELECT update_dtm, patient_name, sex, dob, update_hospital, hkic_symbol
                        INTO var_chk_update_datetime, var_old_patient_name, var_old_sex, var_old_dob, var_old_update_hospital, var_old_hkic_symbol
                        FROM
                            cpi_patient
                        WHERE hkid = par_hkid;

                    END;
                ELSE
                    BEGIN

                        SELECT NULL, NULL, NULL, NULL, 'N', NULL, NULL
                        INTO var_old_patient_name, var_old_sex, var_old_dob, var_old_update_hospital, var_patient_exists, var_old_hkid, var_old_hkic_symbol;

                    END;
                END IF;
            END;
        END IF;
       
        /* ----20100928 SL HKIC symbol -- */
        IF
            LTRIM(RTRIM(par_hkic_symbol)) IS NULL OR LTRIM(RTRIM(par_hkic_symbol)) = ''
        THEN /* if pass-in hkic is null or N/A */

            SELECT var_old_hkic_symbol
            INTO par_hkic_symbol;

        END IF;
        /* --	if (@patient_exists = 'Y' and @txn_type != '030') or */
        /* --		(@patient_exists = 'N' and @txn_type != '010') */
        /* PasCr-2017/00257 YL: To enable source_system RIS to update patient for retrieve HKPMI patient to local hospital and create episode */

        IF
            ((var_patient_exists = 'Y' AND par_txn_type != '030') OR
             (var_patient_exists = 'N' AND par_txn_type != '010' AND par_source_system NOT IN ('OPAS','ADT','RIS')))
        THEN
            /* --		(@patient_exists = 'N' and @txn_type != '010' and @source_system <> 'ADT')) */
            BEGIN

                SELECT 200006
                INTO var_return_error_code;

                SELECT 'N'
                INTO var_success_flag;

                RAISE
                    EXCEPTION 'rollback';
            END;
        END IF;
        /* check hkid if it is an used unhkid for PMI registration 20040914 by Leo Lee */
        IF
            EXISTS (SELECT *
                    FROM
                        cpi_used_unhkid
                    WHERE hkid = par_hkid)
        THEN
            BEGIN
                /* ---reused Unhkid */
                IF
                    (SUBSTRING(par_hkid,1,1) = 'U') AND par_txn_type = '010'
                THEN
                    BEGIN

                        SELECT 200033
                        INTO var_return_error_code;
/* --- 200033 = HKID is being used before, Transaction is rejected! */
                        SELECT 'N'
                        INTO var_success_flag;

                        RAISE
                            EXCEPTION 'rollback';
                    END;
                END IF;
                /* ---Blocked HKID */
                IF
                    (SUBSTRING(par_hkid,1,1) <> 'U') AND (par_txn_type = '010' OR par_txn_type = '030')
                THEN
                    BEGIN

                        SELECT 210002
                        INTO var_return_error_code; /* ---210002 = HKID blocked, Transaction is rejected ! */
                        SELECT 'N'
                        INTO var_success_flag;

                        RAISE
                            EXCEPTION 'rollback';
                    END;
                END IF;
            END;
        END IF;
        /* check DOB if it is later than anyone registration date/time of the case(s) belonging to the patient by Philip */
        IF
            (par_dob IS NOT NULL AND par_txn_type = '030')
        THEN

            BEGIN
                /* select @min_adm_dtm=min(admission_dtm) from cpi_case where patient_key=@patient_key */
                /* handle for OPAS case */

                SELECT MIN(admission_dtm)
                INTO var_min_adm_dtm
                FROM
                    cpi_case
                WHERE
                    patient_key = par_patient_key AND NOT (case_type = 'O' AND admission_dtm < '19950101')
                                                  AND status_code = 'AC';

                IF
                    (var_min_adm_dtm IS NOT NULL) AND (par_dob > var_min_adm_dtm)
                THEN
                    BEGIN

                        SELECT case_no
                        INTO var_case_no
                        FROM
                            cpi_case
                        WHERE
                            patient_key = par_patient_key AND NOT (case_type = 'O' AND admission_dtm < '19950101')
                                                          AND status_code = 'AC' AND admission_dtm = var_min_adm_dtm;

                        /*IF
                            var_hkpmi_srvr IS NULL
                        THEN
                            BEGIN

                                CALL cpi_get_rpc_server(var_return_code,'HKPMI_SERVER',var_hkpmi_srvr);

                            END;
                        END IF;

                        IF
                            var_hkpmi_srvr IS NULL
                        THEN
                            BEGIN
                                /* --- 20110707 sl : IF HKPMI not avaiable --> show DOB > Adm dtm message --- */

                                /* ---select @error_msg = 'Primary HKPMI server is not available, Update Patient Demo functions are prohibited.' */
                                /* ------ raiserror 200034 @error_msg */

                                /* ---return 200034 */

                                SELECT 200036
                                INTO var_return_error_code;

                                SELECT 'N'
                                INTO var_success_flag;

                                RAISE
                                    EXCEPTION 'rollback';
                            END;
                        END IF;*/
                        /* handle for dob > adm_dtm to write exception */

                        SELECT 'N'
                        INTO var_exception_flag;
                      
                       -- replace_dblink_by_fdw
                   		CALL hkpmi.hkpmi_chk_exception_case(var_return_code, par_hospital_code, var_case_no, var_exception_flag);
                      	SET search_path TO hpi,public;
                    EXCEPTION
                        WHEN OTHERS THEN
                            IF
                                var_return_code <> 0 OR var_exception_flag = 'N'
                            THEN
                                BEGIN

                                    SELECT 200036
                                    INTO var_return_error_code;

                                    SELECT 'N'
                                    INTO var_success_flag;

                                    RAISE
                                        EXCEPTION 'rollback';
                                END;
                            END IF;
                    END;
                END IF;
            END;
        END IF;

        IF
            (par_source_system = 'DNL')
        THEN
            BEGIN
                IF
                    (var_chk_update_datetime IS NOT NULL) AND (var_chk_update_datetime >= par_transaction_datetime) AND
                    (EXISTS (SELECT *
                             FROM
                                 hospital
                             WHERE hospital_code = var_old_update_hospital))
                THEN
                    BEGIN

                        SELECT CONCAT(
                                       'Patient has been updated after transaction, patient update is rejected! - <Update Hospital code> = ',
                                       par_update_hospital,' <transaction datetime> = ',
                                       TO_CHAR(par_transaction_datetime,'Mon DD YYYY HH24:mi:ss'))
                        INTO var_download_err_string;

                        SELECT 7016
                        INTO var_return_error_code;

                        SELECT 'N'
                        INTO var_success_flag;

                        RAISE
                            EXCEPTION 'rollback';
                    END;
                END IF;
            END;
        ELSE
            BEGIN

                IF
                    (var_chk_update_datetime IS NOT NULL) AND
                    (timestamp_convert(var_chk_update_datetime) != timestamp_convert(par_last_update_datetime))
                THEN
                    BEGIN
                        /* print "Patient has been updated after transaction, patient update is rejected!" */

                        SELECT 7016
                        INTO var_return_error_code;

                        SELECT 'N'
                        INTO var_success_flag;

                        RAISE
                            EXCEPTION 'rollback';
                    END;
                END IF;
            END;
        END IF;
        /* Assign the transaction_datetime of source system to source_system_dtm */

        SELECT par_transaction_datetime
        INTO var_source_system_dtm;

        /* Use a common datetime to update all tables */
/*
if (@source_system = "DNL")
begin
    select	@update_datetime = @transaction_datetime
    select	@transaction_datetime = getdate()
end
else
begin
    select	@update_datetime = getdate()
    select	@transaction_datetime = @update_datetime
end
*/

        select timestamp_convert(localtimestamp)
        INTO var_update_datetime;

        SELECT var_update_datetime
        INTO par_transaction_datetime;
       raise notice 'par_transaction_datetime=%',par_transaction_datetime;
/* Set flags and variables */
        SELECT 'Y'
        INTO var_success_flag;

        IF
            (par_source_system = 'DNL')
        THEN

            SELECT 'N'
            INTO var_upload_status;

        ELSE

            SELECT 'Y'
            INTO var_upload_status;

        END IF;
    
        /* Get chinese name from ccc_unicode table */

        CALL cpi_get_phonetic_chin_name(var_return_code,par_ccc_1,par_ccc_2,par_ccc_3,par_ccc_4,par_ccc_5,par_ccc_6,
                                        var_tmp_phonetic,par_chi_name);
/* 2006-12-12 Addeded by HK Fong SMR20015887 - Start */
        IF
            COALESCE(par_chi_name,'') <> ''
        THEN
            BEGIN

                CALL cpi_check_schi_name(pas_return_code => pas_return_code,par_ccc1 => par_ccc_1,par_ccc2 => par_ccc_2,
                                         par_ccc3 => par_ccc_3,par_ccc4 => par_ccc_4,par_ccc5 => par_ccc_5,
                                         par_ccc6 => par_ccc_6,par_is_schi_name => var_is_schi_name);

                IF
                    var_is_schi_name = 'Y'
                THEN

                    SELECT NULL
                    INTO par_chi_name;

                END IF;
            END;
        END IF;
       
        /* 2006-12-12 Addeded by HK Fong SMR20015887 - End */
        /*
        if (@name_soundex is null)
        select	@name_soundex = soundex(@patient_name)
        */
        /* Validate key fields */
        /* Get replicate bit values */

        SELECT bit_value
        INTO var_rep_hospital
        FROM
            rep_cluster_bits
        WHERE hospital_code = par_hospital_code;

        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF
            (sql$rowcount = 0)
        THEN
            BEGIN
                /* print "Fail to get bit values from rep_cluster_bits, patient update is rejected!" */

                SELECT 7001
                INTO var_return_error_code;

                SELECT 'N'
                INTO var_success_flag;

                RAISE
                    EXCEPTION 'rollback';
            END;
        END IF;
        /*
        select	@init_source = bit_value
        	from	source_bits
        	where	source_system = @source_system

        	if (@@rowcount = 0)
        	begin
        /*		print "Fail to get init. bit values from source_bits, patient update is rejected!" */
        		select	@success_flag = "N"
        		goto return_error
        	end
        */
        /* If patient key is not given */
        /* --	if (@patient_key is null) */
        /* --	begin */
        /*
        Check to see whether HKID exists in cpi_patient.
        If HKID exists, get the patient key as the patient key
        */

        SELECT patient_key, rep_clusters
        INTO var_new_patient_key, var_rep_clusters
        FROM
            cpi_patient
        WHERE hkid = par_hkid;

        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF
            (sql$rowcount = 1)
        THEN
            BEGIN
                /* print "HKID already exists in cpi_patient, update patient information rather than insert a new one!" */

                SELECT 7002
                INTO var_return_error_code;

                SELECT var_new_patient_key
                INTO par_patient_key;

                SELECT var_rep_clusters | var_rep_hospital
                INTO var_rep_clusters;

                SELECT CAST(par_patient_key AS INTEGER)
                INTO var_patient_no;

                IF
                    par_hkic_symbol_clear = 'Y'
                THEN /* reset hkic symbol */

                    SELECT NULL
                    INTO var_update_hkic_symbol;

                ELSE

                    SELECT par_hkic_symbol
                    INTO var_update_hkic_symbol;

                END IF;

                /* update a patient record */
                BEGIN

                    UPDATE cpi_patient
                    SET patient_name    = par_patient_name, sex = par_sex, cccode1 = par_ccc_1, cccode2 = par_ccc_2,
                        cccode3         = par_ccc_3, cccode4 = par_ccc_4, cccode5 = par_ccc_5, cccode6 = par_ccc_6,
                        chi_name        = par_chi_name, dob = par_dob, exact_dob_flag = par_exact_dob_flag,
                        marital_status  = par_marital_status, race = par_race_code,
                        other_doc_no    = par_other_document_no, reference = par_reference, building = par_building,
                        room            = par_room, floor = par_floor, block = par_block,
                        district        = par_district_code, religion = par_religion_code, phone1 = par_phone1,
                        phone2          = par_phone2, address_indicator = par_address_indicator,
                        mobile_phone    = par_mobile_phone, sms_language = par_sms_language,
                        death_indicator = par_death_indicator, death_date = par_death_date,
                        death_code      = par_death_code, card_holder = par_card_holder,
                        /* --				access_code = @access_code, */
                        security        = par_security, patient_no = var_patient_no,
                        update_hospital = par_update_hospital, update_by = par_update_by,
                        update_dtm      = var_update_datetime, rep_clusters = var_rep_clusters,
                        hkic_symbol     = var_update_hkic_symbol
                    WHERE patient_key = par_patient_key;

                    RAISE
                        NOTICE 'cpi_patient_update[UPDATE]cpi_patient-567,patient_no=%,patient_key=%',var_patient_no,par_patient_key;

                    var_error
                        := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE NOTICE 'cpi_cancel_admission,err_msg=>%',sqlerrm;
                        var_error
                            := 1;
                END;

                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                var_rowcount
                    := sql$rowcount;

                IF
                    (var_error != 0) OR (var_rowcount = 0)
                THEN
                    BEGIN
                        /* print "Fail to update patient record, patient update is rejected!" */

                        SELECT 7003
                        INTO var_return_error_code;

                        SELECT 'N'
                        INTO var_success_flag;

                        RAISE
                            EXCEPTION 'rollback';
                    END;
                END IF;
              
                /* --- added by WL for insert event log--- */

                IF
                    par_source_system <> 'ADT'
                THEN
                    BEGIN

                        SELECT '030'
                        INTO var_insert_event_log_type;

                        SELECT 'hasp_insert_event_log'
                        INTO var_insert_event_log_prg;

                        IF
                            (par_source_system != 'DNL') OR (par_hospital_code = par_update_hospital)
                        THEN

                            SELECT par_medical_record_number
                            INTO var_event_log_mrn;

                        ELSE

                            SELECT NULL
                            INTO var_event_log_mrn;

                        END IF;

                        SELECT timestamp_convert(LOCALTIMESTAMP)
                        INTO var_insert_event_log_dtm;
/* -avoid duplicate when insert event log, check first-- */
                        CALL hasp_get_event_log_dtm(var_return_code,par_hospital_code,var_insert_event_log_dtm);

                        CALL hasp_insert_event_log(var_insert_event_log_ret_code,par_hospital_code,
                                                   var_insert_event_log_dtm,var_insert_event_log_type,par_hkid,
                                                   par_patient_name,par_sex,par_dob,par_exact_dob_flag,par_ccc_1,
                                                   par_ccc_2,par_ccc_3,par_ccc_4,par_ccc_5,par_ccc_6,par_marital_status,
                                                   par_race_code,par_other_document_no,var_event_log_mrn,par_building,
                                                   par_room,par_floor,par_block,par_district_code,par_religion_code,
                                                   par_phone1,par_phone2,par_address_indicator,par_mobile_phone,
                                                   par_sms_language,par_death_indicator,par_death_date,par_patient_key,
                                                   par_nok_name,par_nok_hkid,par_nok_relation_code,par_nok_building,
                                                   par_nok_room,par_nok_floor,par_nok_block,par_nok_district_code,
                                                   par_nok_phone1,par_nok_phone2,par_nok_address_indicator,
                                                   par_nok_mobile_phone,par_nok_sms_language,NULL, /* case no */
                                                   NULL, /* adm dtm */ NULL, /* source ind */ NULL, /* source code */
                                                   NULL, /* paycode */ NULL, /* disc code */ NULL, /* disc dtm */
                                                   NULL, /* dest code */ NULL, /* case type */ NULL, /* movement cnt */
                                                   NULL, /* security cnt */ NULL, /* case access code */
                                                   par_access_code, /* pmi access code */ NULL, /* ambulance no */
                                                   NULL, /* police case */ NULL, /* labour case */
                                                   NULL, /* ae case type */ NULL, /* dba flag */
                                                   NULL, /* follow up dtm */ NULL, /* ward */ NULL, /* spec */
                                                   NULL, /* bed no */ NULL, /* ward class */ var_old_patient_name,
                                                   var_old_hkid,var_old_sex,var_old_dob,NULL, /* old ward class */
                                                   NULL, /* old ward code */ NULL, /* old spec code */
                                                   NULL, /* old bed no */ par_update_by,NULL, /* doctor code */
                                                   NULL, /* old doctor code */ NULL, /* old tprk */ NULL, /* mrts */
                                                   'P'); /* upload status */

                        IF
                            var_insert_event_log_ret_code <> 0
                        THEN
                            BEGIN
                                /* print "Fail to insert into event log!" */

                                SELECT 200023
                                INTO var_return_error_code;

                                SELECT 'N'
                                INTO var_success_flag;

                                RAISE
                                    EXCEPTION 'rollback';
                            END;
                        END IF;
                    END;
                END IF;
               
                /* update nok record */
                IF
                    (par_nok_name IS NOT NULL)
                THEN
                    BEGIN

                        SELECT priority
                        -- INTO par_priority
                        INTO var_int_value
                        FROM
                            cpi_nok
                        WHERE patient_key = par_patient_key AND major_nok = 'Y';

                        IF FOUND
                        THEN
                            BEGIN
                                par_priority := var_int_value;
                                SELECT 'Y'
                                INTO var_major_nok;

                                BEGIN
                                    RAISE
                                        NOTICE 'cpi_patient_update-703[UPDATE]cpi_nok,par_patient_key=%,priority=%',par_patient_key,par_priority;

                                    UPDATE cpi_nok
                                    SET relationship    = par_nok_relation_code, nok_name = par_nok_name,
                                        hkid            = par_nok_hkid, building = par_nok_building,
                                        room            = par_nok_room, floor = par_nok_floor, block = par_nok_block,
                                        district        = par_nok_district_code, phone1 = par_nok_phone1,
                                        phone2          = par_nok_phone2, address_indicator = par_nok_address_indicator,
                                        mobile_phone    = par_nok_mobile_phone, sms_language = par_nok_sms_language,
                                        update_hospital = par_update_hospital, update_by = par_update_by,
                                        update_dtm      = var_update_datetime
                                    WHERE patient_key = par_patient_key AND priority = par_priority;

                                    var_error
                                        := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        RAISE NOTICE 'error';
                                        var_error
                                            := 1;
                                END;

                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                var_rowcount
                                    := sql$rowcount;

                                IF
                                    (var_error != 0) OR (var_rowcount = 0)
                                THEN
                                    BEGIN
                                        /* print "Fail to update cpi_nok, patient update is rejected!" */

                                        SELECT 7006
                                        INTO var_return_error_code;

                                        SELECT 'N'
                                        INTO var_success_flag;

                                        RAISE
                                            EXCEPTION 'rollback';
                                    END;
                                END IF;

                                IF
                                    ('ADT' = par_source_system OR 'OPAS' = par_source_system)
                                THEN
                                    BEGIN
                                        IF
                                            NOT EXISTS (SELECT 1
                                                        FROM
                                                            cpi_nok
                                                        WHERE patient_key = par_patient_key AND priority = 1)
                                        THEN
                                            BEGIN
                                                BEGIN

                                                    UPDATE cpi_nok
                                                    SET priority = 1
                                                    WHERE patient_key = par_patient_key AND priority = par_priority;

                                                    RAISE
                                                        NOTICE 'cpi_patient_update[UPDATE]cpi_nok,par_patient_key=%,par_priority=%',par_patient_key,par_priority;
                                                    var_error
                                                        := 0;
                                                EXCEPTION
                                                    WHEN OTHERS THEN
                                                        var_error := 1;
                                                END;

                                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                var_rowcount
                                                    := sql$rowcount;

                                                IF
                                                    (var_rowcount != 0)
                                                THEN

                                                    SELECT 1
                                                    INTO par_priority;

                                                END IF;

                                                IF
                                                    (var_error != 0) OR (var_rowcount = 0)
                                                THEN
                                                    BEGIN

                                                        SELECT 7006
                                                        INTO var_return_error_code;

                                                        SELECT 'N'
                                                        INTO var_success_flag;

                                                        RAISE
                                                            EXCEPTION 'rollback';
                                                    END;
                                                END IF;
                                            END;
                                        END IF;
                                    END;
                                END IF;
                            END;
                        ELSE
                            BEGIN
                                /* insert new nok if no major NOK is found */

                                SELECT 1
                                INTO var_n_prior;

                                SELECT COUNT(*)
                                INTO var_cnt
                                FROM
                                    cpi_nok
                                WHERE patient_key = par_patient_key;

                                IF
                                    (var_cnt != 0)
                                THEN
                                    BEGIN

                                        SELECT MAX(priority) + 1
                                        INTO var_n_prior
                                        FROM
                                            cpi_nok
                                        WHERE patient_key = par_patient_key;

                                        SELECT var_n_prior
                                        INTO par_priority;

                                    END;
                                END IF;
                                /* No major_NOK, so set this to "Y" */

                                SELECT 'Y'
                                INTO var_major_nok;

                                BEGIN

                                    INSERT INTO cpi_nok (patient_key,priority,major_nok,hkid,relationship,nok_name,
                                                         building,room,floor,block,district,phone1,phone2,
                                                         address_indicator,mobile_phone,sms_language,update_hospital,
                                                         update_by,update_dtm)
                                    VALUES (par_patient_key,var_n_prior,var_major_nok,par_nok_hkid,
                                            par_nok_relation_code,par_nok_name,par_nok_building,par_nok_room,
                                            par_nok_floor,par_nok_block,par_nok_district_code,par_nok_phone1,
                                            par_nok_phone2,par_nok_address_indicator,par_nok_mobile_phone,
                                            par_nok_sms_language,par_hospital_code,par_update_by,var_update_datetime);

                                    RAISE
                                        NOTICE 'cpi_patient_update[INSERT]cpi_nok,par_patient_key=%',par_patient_key;
                                    var_error
                                        := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                                END;

                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                var_rowcount
                                    := sql$rowcount;

                                IF
                                    (var_error != 0) OR (var_rowcount = 0)
                                THEN
                                    BEGIN
                                        /* print "Fail to insert into cpi_nok, patient update is rejected!" */

                                        SELECT 7004
                                        INTO var_return_error_code;

                                        SELECT 'N'
                                        INTO var_success_flag;

                                        RAISE
                                            EXCEPTION 'rollback';
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        BEGIN
                            RAISE
                                NOTICE 'cpi_patient_update [DELETE] cpi_nok patient_key=%', par_patient_key;

                            DELETE
                            FROM
                                cpi_nok
                            WHERE patient_key = par_patient_key AND major_nok = 'Y';

                            var_error
                                := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;

                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        var_rowcount
                            := sql$rowcount;

                        IF
                            (var_error != 0)
                        THEN
                            BEGIN

                                SELECT 11005
                                INTO var_return_error_code;

                                SELECT 'N'
                                INTO var_success_flag;

                                RAISE
                                    EXCEPTION 'rollback';
                            END;
                        END IF;

                        IF
                            EXISTS (SELECT *
                                    FROM
                                        cpi_nok
                                    WHERE patient_key = par_patient_key)
                        THEN
                            BEGIN

                                SELECT MIN(priority)
                                INTO var_tmp_priority
                                FROM
                                    cpi_nok
                                WHERE patient_key = par_patient_key;

                                BEGIN

                                    UPDATE cpi_nok
                                    SET major_nok = 'Y'
                                    WHERE patient_key = par_patient_key AND priority = var_tmp_priority;

                                    RAISE
                                        NOTICE 'cpi_patient_update[UPDATE]cpi_nok,par_patient_key=%,priority=%',par_patient_key,var_tmp_priority;
                                    var_error
                                        := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                                END;

                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                var_rowcount
                                    := sql$rowcount;

                                IF
                                    (var_error != 0) OR var_rowcount != 1
                                THEN
                                    BEGIN

                                        SELECT 11007
                                        INTO var_return_error_code;

                                        SELECT 'N'
                                        INTO var_success_flag;

                                        RAISE
                                            EXCEPTION 'rollback';
                                    END;
                                END IF;

                                SELECT priority, major_nok, nok_name, hkid, relationship, building, room, floor, block,
                                       district, phone1, phone2, address_indicator, mobile_phone, sms_language
                                INTO par_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language
                                FROM
                                    cpi_nok
                                WHERE patient_key = par_patient_key AND major_nok = 'Y';

                            END;
                        ELSE
                            BEGIN

                                SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL
                                INTO par_priority, var_major_nok, par_nok_name, par_nok_hkid, par_nok_relation_code, par_nok_building, par_nok_room, par_nok_floor, par_nok_block, par_nok_district_code, par_nok_phone1, par_nok_phone2, par_nok_address_indicator, par_nok_mobile_phone, par_nok_sms_language;

                            END;
                        END IF;
                    END;
                END IF;

                /*
                if transaction is issued by download (from other cluster),
                it is not required to insert/update mrn information
                */
                /* insert or update cpi_patient_hospital_data */
                IF
                    (par_source_system != 'DNL') OR par_hospital_code = par_update_hospital
                THEN

                    BEGIN

                        SELECT COUNT(*)
                        INTO var_cnt
                        FROM
                            cpi_patient_hospital_data
                        WHERE hospital_code = par_hospital_code AND patient_key = par_patient_key;

                        IF
                            (var_cnt = 0)
                        THEN
                            BEGIN
                                /* Check duplication of mrn */
                                IF
                                    (par_medical_record_number IS NOT NULL)
                                THEN
                                    BEGIN

                                        SELECT COUNT(*)
                                        INTO var_cnt
                                        FROM
                                            cpi_patient_hospital_data
                                        WHERE hospital_code = par_hospital_code AND mrn = par_medical_record_number;

                                        IF
                                            (var_cnt != 0)
                                        THEN
                                            BEGIN
                                                /* print "Duplicate mrn is found, admission is rejected!" */

                                                SELECT 7008
                                                INTO var_return_error_code;

                                                SELECT 'N'
                                                INTO var_success_flag;

                                                RAISE
                                                    EXCEPTION 'rollback';
                                            END;
                                        END IF;
                                    END;
                                END IF;

                                BEGIN

                                    INSERT INTO cpi_patient_hospital_data (patient_key,hospital_code,mrn,remark,
                                                                           create_by,create_dtm,update_by,update_dtm)
                                    VALUES (par_patient_key,par_hospital_code,par_medical_record_number,par_remark,
                                            par_update_by,var_update_datetime,par_update_by,var_update_datetime);

                                    RAISE
                                        NOTICE 'cpi_patient_update[INSERT]cpi_patient_hospital_data,par_patient_key=%',par_patient_key;
                                    var_error
                                        := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                                END;

                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                var_rowcount
                                    := sql$rowcount;

                                IF
                                    (var_error != 0) OR (var_rowcount = 0)
                                THEN
                                    BEGIN
                                        /* print "Fail to insert cpi_patient_hospital_data, patient update is rejected!" */

                                        SELECT 7009
                                        INTO var_return_error_code;

                                        SELECT 'N'
                                        INTO var_success_flag;

                                        RAISE
                                            EXCEPTION 'rollback';
                                    END;
                                END IF;
                            END;
                            /* End if (@cnt = 0) */
                        ELSE
                            BEGIN
                                /* Check duplication of mrn */

                                SELECT mrn
                                INTO var_tmp_mrn
                                FROM
                                    cpi_patient_hospital_data
                                WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;

                                RAISE
                                    NOTICE 'cpi_patient_update[test-3]par_medical_record_number=%,var_tmp_mrn=%',par_medical_record_number,var_tmp_mrn;
                                IF
                                    (par_medical_record_number IS NOT NULL) AND
                                    (COALESCE(var_tmp_mrn,'null') <> COALESCE(par_medical_record_number,'null'))
                                THEN
                                    BEGIN

                                        SELECT COUNT(*)
                                        INTO var_cnt
                                        FROM
                                            cpi_patient_hospital_data
                                        WHERE mrn = par_medical_record_number AND hospital_code = par_hospital_code;

                                        IF
                                            (var_cnt != 0)
                                        THEN
                                            BEGIN
                                                /* print "Duplicate mrn is found, admission is rejected!" */

                                                SELECT 7008
                                                INTO var_return_error_code;

                                                SELECT 'N'
                                                INTO var_success_flag;

                                                RAISE
                                                    EXCEPTION 'rollback';
                                            END;
                                        END IF;
                                    END;
                                END IF;
                                RAISE
                                    NOTICE 'cpi_patient_update[test-3]par_medical_record_number=%,par_remark=%,par_update_by=%,var_update_datetime=%,par_patient_key=%,par_hospital_code=%',par_medical_record_number,par_remark,par_update_by,var_update_datetime,par_patient_key,par_hospital_code;
                                BEGIN

                                    UPDATE cpi_patient_hospital_data
                                    SET mrn       = par_medical_record_number, remark = par_remark,
                                        update_by = par_update_by, update_dtm = var_update_datetime
                                    WHERE patient_key = par_patient_key AND hospital_code = par_hospital_code;

                                    RAISE
                                        NOTICE 'cpi_patient_update[UPDATE]cpi_patient_hospital_data,par_patient_key=%',par_patient_key;
                                    var_error
                                        := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        IF SQLSTATE IS NOT NULL
                                        THEN
                                            RAISE NOTICE 'SQLERRM=%,SQLERRM=% ',SQLSTATE,SQLERRM;
                                            RETURN;
                                        END IF;
                                        var_error
                                            := 1;
                                END;

                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                var_rowcount
                                    := sql$rowcount;
                                RAISE
                                    NOTICE 'cpi_patient_update[test-3]var_rowcount=%,var_error=%',var_rowcount,var_error;

                                IF
                                    (var_error != 0) OR (var_rowcount = 0)
                                THEN
                                    BEGIN
                                        /* print "Fail to update cpi_patient_hospital_data, patient update is rejected!" */

                                        SELECT 7010
                                        INTO var_return_error_code;

                                        SELECT 'N'
                                        INTO var_success_flag;

                                        RAISE
                                            EXCEPTION 'rollback';
                                    END;
                                END IF;
                            END;
                        END IF /* End else */;
                    END;
                END IF /* End if @source_system != "DNL" */;
            END; /* End if (@@rowcount = 1) - HKID exists and get by HKID */

        ELSE
            BEGIN
                /* Patient_key given is null, New patient */
                /* --			save transaction ins_patient */
                IF
                    par_patient_key IS NULL
                THEN
                    BEGIN

                        CALL cpi_pu_get_patient_key(pas_return_code => var_return_status,
                                                    par_hospital_code => par_hospital_code,
                                                    par_new_patient_key => var_new_patient_key);

                        RAISE
                            NOTICE 'cpi_patient_update-1005-par_hkic_symbol_clear=%,par_hkid=%',par_hkic_symbol_clear,var_new_patient_key;
                        IF
                            (var_return_status != 0)
                        THEN
                            BEGIN
                                /* print "Fail to get a new patient key, patient update is rejected!" */

                                SELECT 7011
                                INTO var_return_error_code;

                                SELECT 'N'
                                INTO var_success_flag;

                                RAISE
                                    EXCEPTION 'rollback';
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
                RAISE
                    NOTICE 'cpi_patient_update-par_hkic_symbol_clear=%',par_hkic_symbol_clear;
                IF
                    par_hkic_symbol_clear = 'Y'
                THEN /* reset hkic symbol */

                    SELECT NULL
                    INTO var_update_hkic_symbol;

                ELSE

                    SELECT par_hkic_symbol
                    INTO var_update_hkic_symbol;

                END IF;
                RAISE
                    NOTICE 'cpi_patient_update-par_hkic_symbol_clear=%,var_update_hkic_symbol=%',par_hkic_symbol_clear,var_update_hkic_symbol;
                /* --			if (@source_system in ('DNL', "OPAS")) */
                /* For OPAS, don't insert column access_code (use default) */
                /* Change to use input access code instead of default for OPAS */

                BEGIN
                    IF
                        (par_source_system IN ('DNL'))
                    THEN
                        INSERT INTO cpi_patient (patient_key,hkid,patient_name,sex,cccode1,cccode2,cccode3,cccode4,
                                                 cccode5,cccode6,chi_name,dob,exact_dob_flag,marital_status,race,
                                                 other_doc_no,reference,building,room,floor,block,district,religion,
                                                 phone1,phone2,address_indicator,mobile_phone,sms_language,
                                                 death_indicator,death_date,death_code,card_holder,SECURITY,patient_no,
                                                 create_hospital,create_by,create_dtm,update_hospital,update_by,
                                                 update_dtm,rep_clusters,hkic_symbol)
                        VALUES (par_patient_key,par_hkid,par_patient_name,par_sex,par_ccc_1,par_ccc_2,par_ccc_3,
                                par_ccc_4,par_ccc_5,par_ccc_6,par_chi_name,par_dob,par_exact_dob_flag,
                                par_marital_status,par_race_code,par_other_document_no,par_reference,par_building,
                                par_room,par_floor,par_block,par_district_code,par_religion_code,par_phone1,par_phone2,
                                par_address_indicator,par_mobile_phone,par_sms_language,par_death_indicator,
                                par_death_date,par_death_code,par_card_holder,par_security,var_patient_no,
                                par_hospital_code,par_update_by,var_update_datetime,par_hospital_code,par_update_by,
                                var_update_datetime,var_rep_clusters,var_update_hkic_symbol);
                        RAISE
                                NOTICE 'cpi_patient_update[INSERT]cpi_patient,var_update_datetime=%,par_patient_key=%,hkic_symbol=%',var_update_datetime,par_patient_key,var_update_hkic_symbol;
                        ELSE
                        /* For ADT, don't insert column security (use default) */

                        INSERT INTO cpi_patient (patient_key,hkid,patient_name,sex,cccode1,cccode2,cccode3,cccode4,
                                                 cccode5,cccode6,chi_name,dob,exact_dob_flag,marital_status,race,
                                                 other_doc_no,reference,building,room,floor,block,district,religion,
                                                 phone1,phone2,address_indicator,mobile_phone,sms_language,
                                                 death_indicator,death_date,death_code,card_holder,access_code,
                                                 patient_no,create_hospital,create_by,create_dtm,update_hospital,
                                                 update_by,update_dtm,rep_clusters,hkic_symbol)
                        VALUES (par_patient_key,par_hkid,par_patient_name,par_sex,par_ccc_1,par_ccc_2,par_ccc_3,
                                par_ccc_4,par_ccc_5,par_ccc_6,par_chi_name,par_dob,par_exact_dob_flag,
                                par_marital_status,par_race_code,par_other_document_no,par_reference,par_building,
                                par_room,par_floor,par_block,par_district_code,par_religion_code,par_phone1,par_phone2,
                                par_address_indicator,par_mobile_phone,par_sms_language,par_death_indicator,
                                par_death_date,par_death_code,par_card_holder,par_access_code,var_patient_no,
                                par_hospital_code,par_update_by,var_update_datetime,par_hospital_code,par_update_by,
                                var_update_datetime,var_rep_clusters,var_update_hkic_symbol);
                   RAISE
                                NOTICE 'cpi_patient_update[INSERT]cpi_patient,var_update_datetime=%,par_patient_key=%,hkic_symbol=%',var_update_datetime,par_patient_key,var_update_hkic_symbol;
                           END IF;
                    var_error
                        := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        GET STACKED DIAGNOSTICS v_message = MESSAGE_TEXT;
                        RAISE
                            NOTICE 'Error: %', v_message;
                        var_error
                            := 1;
                END;

                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                var_rowcount
                    := sql$rowcount;

                IF
                    (var_error != 0) OR (var_rowcount = 0)
                THEN
                    BEGIN
                        /* print "Fail to insert a new patient record, patient update is rejected!" */
                        /* --				rollback transaction ins_patient */

                        SELECT 7012
                        INTO var_return_error_code;

                        SELECT 'N'
                        INTO var_success_flag;

                        RAISE
                            EXCEPTION 'rollback';
                    END;
                END IF;
                /* insert nok record */
                IF
                    (par_nok_name IS NOT NULL)
                THEN
                    BEGIN

                        SELECT 1
                        INTO var_n_prior;

                        SELECT var_n_prior
                        INTO par_priority;

                        SELECT 'Y'
                        INTO var_major_nok;

                        BEGIN

                            INSERT INTO cpi_nok (patient_key,priority,major_nok,hkid,relationship,nok_name,building,
                                                 room,floor,block,district,phone1,phone2,address_indicator,mobile_phone,
                                                 sms_language,update_hospital,update_by,update_dtm)
                            VALUES (par_patient_key,var_n_prior,var_major_nok,par_nok_hkid,par_nok_relation_code,
                                    par_nok_name,par_nok_building,par_nok_room,par_nok_floor,par_nok_block,
                                    par_nok_district_code,par_nok_phone1,par_nok_phone2,par_nok_address_indicator,
                                    par_nok_mobile_phone,par_nok_sms_language,par_hospital_code,par_update_by,
                                    var_update_datetime);

                            RAISE
                                NOTICE 'cpi_patient_update[INSERT]cpi_nok,par_patient_key=%',par_patient_key;
                            var_error
                                := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;

                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        var_rowcount
                            := sql$rowcount;

                        IF
                            (var_error != 0) OR (var_rowcount = 0)
                        THEN
                            BEGIN
                                /* print "Fail to insert into cpi_nok, patient update is rejected!" */
                                /* --					rollback transaction ins_patient */

                                SELECT 7004
                                INTO var_return_error_code;

                                SELECT 'N'
                                INTO var_success_flag;

                                RAISE
                                    EXCEPTION 'rollback';
                            END;
                        END IF;
                    END;
                END IF;
                /*
                if transaction is issued by download (from other cluster),
                it is not required to insert/update mrn information
                */
                /* insert cpi_patient_hospital_data */
                /* Check duplication of mrn */
                IF
                    (par_source_system != 'DNL') OR par_hospital_code = par_update_hospital
                THEN
                    BEGIN
                        IF
                            (par_medical_record_number IS NOT NULL)
                        THEN
                            BEGIN

                                SELECT COUNT(*)
                                INTO var_cnt
                                FROM
                                    cpi_patient_hospital_data
                                WHERE hospital_code = par_hospital_code AND mrn = par_medical_record_number;

                                IF
                                    (var_cnt != 0)
                                THEN
                                    BEGIN
                                        /* print "Duplicate mrn is found, admissionis rejected!" */
                                        /* --						rollback transaction ins_patient */

                                        SELECT 7008
                                        INTO var_return_error_code;

                                        SELECT 'N'
                                        INTO var_success_flag;

                                        RAISE
                                            EXCEPTION 'rollback';
                                    END;
                                END IF;
                            END;
                        END IF;

                        BEGIN

                            INSERT INTO cpi_patient_hospital_data (patient_key,hospital_code,mrn,remark,create_by,
                                                                   create_dtm,update_by,update_dtm)
                            VALUES (par_patient_key,par_hospital_code,par_medical_record_number,par_remark,
                                    par_update_by,var_update_datetime,par_update_by,var_update_datetime);

                            RAISE
                                NOTICE 'cpi_patient_update[INSERT]cpi_patient_hospital_data,par_patient_key=%',par_patient_key;
                            var_error
                                := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;

                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        var_rowcount
                            := sql$rowcount;

                        IF
                            (var_error != 0) OR (var_rowcount = 0)
                        THEN
                            BEGIN
                                /* print "Fail to insert cpi_patient_hospital_data, patient update is rejected!" */
                                /* --					rollback transaction ins_patient */

                                SELECT 7009
                                INTO var_return_error_code;

                                SELECT 'N'
                                INTO var_success_flag;

                                RAISE
                                    EXCEPTION 'rollback';
                            END;
                        END IF;
                    END;
                END IF;
                /* End if (@source_system != "DNL") */
                /* commit transaction */
            END;
        END IF;
        /* End else - for New patient */
        /* --	end */
        /* --	else */
        /* If patient_key given is not null - existing patient */
        /* --	begin */
        /* --		select	@cnt = count(*) */
        /* --		from 	cpi_patient */
        /* --		where	patient_key = @patient_key */
        /* --		if @cnt = 0 */
        /* --		begin */
        /* print "Patient does not exist in CPI, patient update is rejected!" */
        /* --			select	@return_error_code = 7013 */
        /* --			select	@success_flag = "N" */
        /* --			goto return_error */
        /* --		end */
        /* update a patient record */
        /* --		select	@rep_clusters = rep_clusters */
        /* --		from	cpi_patient */
        /* --		where	patient_key = @patient_key */
        /* --		select 	@rep_clusters = @rep_clusters | @rep_hospital */
        /* --		select	@patient_no = convert(int, @patient_key) */
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
        /* --			access_code = @access_code, */

        /* --			security = @security, */

        /* --			patient_no = @patient_no, */

        /* --			update_hospital = @update_hospital, */

        /* --			update_by = @update_by, */

        /* --			update_dtm = @update_datetime, */

        /* --			rep_clusters = @rep_clusters */

        /* --		where	patient_key = @patient_key */

        /* --		select	@error = @@error, @rowcount = @@rowcount */

        /* --		if (@error != 0) or (@rowcount = 0) */

        /* --		begin */

        /* print "Fail to update patient record, patient update is rejected!" */

        /* --			select	@return_error_code = 7014 */

        /* --			select	@success_flag = "N" */

        /* --			goto return_error */

        /* --		end */

        /* update nok record */

        /* --		if (@nok_name is not null) */

        /* --		begin */

        /* --			select	@priority = priority */

        /* --				from	cpi_nok */

        /* --				where	patient_key = @patient_key */

        /* --					and	major_nok = 'Y' */

        /* --			if (@@rowcount = 0) */

        /* --			begin */

        /* insert new nok if no major NOK is found */

        /* --				select 	@n_prior = 1 */

        /* --				select	@cnt = count(*) */

        /* --					from	cpi_nok */

        /* --					where	patient_key = @patient_key */

        /* --				if (@cnt ! = 0) */

        /* --				begin */

        /* --					select 	@n_prior = max(priority) + 1 */

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

        /* --				@update_by, @update_datetime) */

        /* --				select	@error = @@error, @rowcount = @@rowcount */

        /* --				if (@error != 0) or (@rowcount = 0) */

        /* --				begin */

        /* print "Fail to insert into cpi_nok, patient update is rejected!" */

        /* --					select	@return_error_code = 7004 */

        /* --					select	@success_flag = "N" */

        /* --					goto return_error */

        /* --				end */

        /* --			end */

        /* End if no major NOK is found */

        /* --			else */

        /* If major NOK is found */

        /* --			begin */

        /* As this is the major_nok, set it for transaction use */

        /* --				select	@major_nok = "Y" */

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

        /* --					update_hospital = @update_hospital, */

        /* --					update_by = @update_by, */

        /* --					update_dtm =  @update_datetime */

        /* --				where	patient_key = @patient_key */

        /* --				and	priority = @priority */

        /* --				select	@error = @@error, @rowcount = @@rowcount */

        /* --				if (@error != 0) or (@rowcount = 0) */

        /* --				begin */

        /* print "Fail to update cpi_nok, patient update is rejected!" */

        /* --					select	@return_error_code = 7006 */

        /* --					select	@success_flag = "N" */

        /* --					goto return_error */

        /* --				end */

        /* --			end */

        /* End if major NOK is found */

        /* --		end */

        /* End if @nok_name is given */

        /* --		else */

        /* --		begin */

        /* --			delete cpi_nok */

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

        /*
        if transaction is issued by download (from other cluster),
        it is not required to insert/update mrn information
        */

        /* insert or update cpi_patient_hospital_data */

        /* --		if (@source_system != "DNL") */

        /* --		begin */

        /* --			select	@cnt = count(*) */

        /* --			from	cpi_patient_hospital_data */

        /* --			where	hospital_code = @hospital_code */

        /* --			and	patient_key = @patient_key */

        /* --			if (@cnt = 0) */

        /* --			begin */

        /* Check duplication of mrn */
        /* if (@medical_record_number is not null) */
        /* begin */
        /* select  @cnt = count(*) */
        /* from    cpi_patient_hospital_data */
        /* where   hospital_code = @hospital_code */
        /* and   mrn = @medical_record_number */
        /* if (@cnt != 0) */
        /* begin */

        /* print "Duplicate mrn is found, admissionis rejected!" */

        /* --						select	@return_error_code = 7008 */
        /* select  @success_flag = "N" */
        /* goto return_error */
        /* end */
        /* end */

        /* --				insert cpi_patient_hospital_data */

        /* --				(patient_key, hospital_code, */

        /* --				mrn, remark, create_by, */

        /* --				create_dtm, update_by, */

        /* --				update_dtm) */

        /* --				values */

        /* --				(@patient_key, @hospital_code, */

        /* --				@medical_record_number, @remark, @update_by, */

        /* --				@update_datetime, @update_by, */

        /* --				@update_datetime) */

        /* --				select	@error = @@error, @rowcount = @@rowcount */

        /* --				if (@error != 0) or (@rowcount = 0) */

        /* --				begin */

        /* print "Fail to insert cpi_patient_hospital_data, patient update is rejected!" */

        /* --					select	@return_error_code = 7009 */

        /* --					select	@success_flag = "N" */

        /* --					goto return_error */

        /* --				end */

        /* --			end */

        /* End if (@cnt = 0) - No existing patient_hospital_data */

        /* --			else */

        /* --			begin */

        /* If exists patient_hospital_data */

        /* Check duplication of mrn */
        /* select  @tmp_mrn = mrn */
        /* from    cpi_patient_hospital_data */
        /* where   patient_key = @patient_key */
        /* and   hospital_code = @hospital_code */
        /* if (@medical_record_number is not null) and */
        /* (@tmp_mrn != @medical_record_number) */
        /* begin */
        /* select  @cnt = count(*) */
        /* from    cpi_patient_hospital_data */
        /* where   mrn = @medical_record_number */
        /* and     hospital_code = @hospital_code */
        /* if (@cnt != 0) */
        /* begin */

        /* print "Duplicate mrn is found, patient update is rejected!" */

        /* --						select	@return_error_code = 7008 */
        /* select  @success_flag = "N" */
        /* goto return_error */
        /* end */
        /* end */

        /* --				update 	cpi_patient_hospital_data */

        /* --				set	mrn = @medical_record_number, */

        /* --					remark = @remark, */

        /* --					update_by = @update_by, */

        /* --					update_dtm = @update_datetime */

        /* --				where	patient_key = @patient_key */

        /* --				and	hospital_code = @hospital_code */

        /* --				select	@error = @@error, @rowcount = @@rowcount */

        /* --				if (@error != 0) or (@rowcount = 0) */

        /* --				begin */

        /* print "Fail to update cpi_patient_hospital_data, patient update is rejected!" */

        /* --					select	@return_error_code = 7010 */

        /* --					select @success_flag = "N" */

        /* --					goto return_error */

        /* --				end */

        /* --			end /*			End if exists patient_hospital_data */ */

        /* --		end /*		End if @source_system != "DNL" */ */

        /* --	end /*	End if existing patient */ */

        /* ------------------------------------------------------------------------------------------------ */

        /* --20141021 : update the local replicated table(HKPMI.patient_doc_info -->cpi.patient_doc_info) directly -- */
        /* Get Org Last doc code - */
        IF
            par_source_system IN ('OPAS')
        THEN
            BEGIN

                SELECT doc_code
                INTO var_org_doc_code
                FROM
                    patient_doc_info
                WHERE patient_key = par_patient_key;

                IF
                    RTRIM(LTRIM(var_org_doc_code)) = NULL OR (RTRIM(LTRIM(var_org_doc_code)) = '')
                THEN

                    SELECT NULL
                    INTO var_org_doc_code;

                END IF;

                IF
                    COALESCE(par_document_flag,'-') != COALESCE(var_org_doc_code,'-')
                THEN /* ---'-' NOT exists in document_type table ! -- */
                    BEGIN
                        RAISE
                            NOTICE 'cpi_patient_update[update] patient_doc_info patient_key=%', par_patient_key;

                        /*UPDATE patient_doc_info
                        SET doc_code = par_document_flag
                        WHERE patient_key = par_patient_key;*/
                       
                      	IF EXISTS (SELECT 1 FROM patient_doc_info_op WHERE patient_key = par_patient_key)
					    THEN 
					    	UPDATE patient_doc_info_op
					        SET doc_code = par_document_flag,upd_dtm = CLOCK_TIMESTAMP()
					        WHERE patient_key = par_patient_key;
					    ELSE 
					    	IF EXISTS (SELECT 1 FROM hkpmi.patient_doc_info_hkpmi WHERE patient_key = par_patient_key)
					    	THEN 
					    		INSERT INTO patient_doc_info_op SELECT * FROM hkpmi.patient_doc_info_hkpmi WHERE patient_key = par_patient_key;
					    		UPDATE patient_doc_info_op
					        	SET doc_code = par_document_flag,upd_dtm = CLOCK_TIMESTAMP()
					        	WHERE patient_key = par_patient_key;
					    	END IF ;
					    END IF ;

                    END;
                END IF;
            END;
        END IF;
        /* --20140721 -- */
        /* ------------------------------------------------------------------------------------------------ */
        /* insert transaction record */
        /*
        Prevent transaction time of different source
        system is the same.  Add seconds to the transaction time.
        */

        SELECT COUNT(*)
        INTO var_cnt
        FROM
            cpi_transaction
        WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

        IF
            (var_cnt != 0)
        THEN
            BEGIN

                SELECT 'N'
                INTO var_exit_flag;

                WHILE (var_exit_flag = 'N')
                LOOP

                    SELECT 3 * INTERVAL '1 millisecond' + par_transaction_datetime::TIMESTAMP
                    INTO par_transaction_datetime;

                    SELECT COUNT(*)
                    INTO var_cnt
                    FROM
                        cpi_transaction
                    WHERE hospital_code = par_hospital_code AND transaction_datetime = par_transaction_datetime;

                    IF
                        (var_cnt = 0)
                    THEN

                        SELECT 'Y'
                        INTO var_exit_flag;

                    END IF;
                END LOOP;
            END;
        END IF;
        /*
        if @document_flag is null
        	select @cpi_filler = null
        else
        	select @cpi_filler = space(1) + @document_flag
        */
        /* 20100928  SL */
        IF
            par_hkic_symbol_clear = 'Y'
        THEN /* reset hkic symbol */

            SELECT NULL
            INTO par_hkic_symbol;

        END IF;

        SELECT CONCAT(REPEAT(' ',1),SUBSTRING(CONCAT(par_document_flag,REPEAT(' ',1)),1,1),REPEAT(' ',26),
                      SUBSTRING(CONCAT(par_hkic_symbol,REPEAT(' ',1)),1,1))
        INTO var_cpi_filler; /* --hkic_symbol=cpi_filler(29,1) */

        IF
            (LTRIM(RTRIM(var_cpi_filler)) = '') OR (LTRIM(RTRIM(var_cpi_filler)) = NULL)
        THEN

            SELECT NULL
            INTO var_cpi_filler;

        END IF;

        BEGIN

            INSERT INTO cpi_transaction (hospital_code,transaction_datetime,transaction_type,hkid,patient_key,
                                         patient_name,sex,dob,exact_dob_flag,ccc_1,ccc_2,ccc_3,ccc_4,ccc_5,ccc_6,
                                         chi_name,marital_status,race_code,other_document_no,reference,
                                         medical_record_number,remark,building,room,floor,block,district_code,
                                         religion_code,phone1,phone2,address_indicator,mobile_phone,sms_language,
                                         death_indicator,death_date,death_code,card_holder,priority,major_nok,nok_name,
                                         nok_hkid,nok_relation_code,nok_building,nok_room,nok_floor,nok_block,
                                         nok_district_code,nok_phone1,nok_phone2,nok_address_indicator,nok_mobile_phone,
                                         nok_sms_language,case_no,admission_datetime,source_indicator,source_code,
                                         patient_type,discharge_code,discharge_datetime,destination_code,doctor_code,
                                         case_type,security_count,case_access_code,pmi_access_code,ambulance_no,
                                         police_case,labour_case,ae_case_type,dba_flag,follow_up_datetime,ward_code,
                                         specialty_code,sub_specialty_code,bed_no,ward_class,transfer_datetime,
                                         old_patient_key,old_name,old_hkid,old_sex,old_dob,old_ward_class,old_ward_code,
                                         old_specialty_code,old_bed_no,old_doctor_code,pp_code,update_hospital,
                                         update_by,update_datetime,source_system,success_indicator,upload_status,
                                         source_system_dtm,cpi_filler)
            VALUES (par_hospital_code,par_transaction_datetime,par_txn_type,par_hkid,par_patient_key,par_patient_name,
                    par_sex,par_dob,par_exact_dob_flag,par_ccc_1,par_ccc_2,par_ccc_3,par_ccc_4,par_ccc_5,par_ccc_6,
                    par_chi_name,par_marital_status,par_race_code,par_other_document_no,par_reference,
                    par_medical_record_number,par_remark,par_building,par_room,par_floor,par_block,par_district_code,
                    par_religion_code,par_phone1,par_phone2,par_address_indicator,par_mobile_phone,par_sms_language,
                    par_death_indicator,par_death_date,par_death_code,par_card_holder,par_priority,var_major_nok,
                    par_nok_name,par_nok_hkid,par_nok_relation_code,par_nok_building,par_nok_room,par_nok_floor,
                    par_nok_block,par_nok_district_code,par_nok_phone1,par_nok_phone2,par_nok_address_indicator,
                    par_nok_mobile_phone,par_nok_sms_language,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                       /* ---NULL, NULL, NULL, @old_patient_name, */
                    par_hkic_symbol_clear,NULL,NULL,
                    var_old_patient_name, /* ---unused 030's ward_class to as hkic_symbol_clear flag for cpi_upload --- */
                    par_hkid,var_old_sex,var_old_dob,NULL,NULL,NULL,NULL,NULL,NULL,par_update_hospital,par_update_by,
                    timestamp_convert(LOCALTIMESTAMP),par_source_system,var_success_flag,var_upload_status,
                    var_source_system_dtm,var_cpi_filler);

            RAISE
                NOTICE 'cpi_patient_update[INSERT]cpi_transaction,par_patient_key=%',par_patient_key;
            var_error
                := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        var_rowcount
            := sql$rowcount;

        IF
            (var_error != 0) OR (var_rowcount = 0)
        THEN
            BEGIN
                /* print "Fail to insert into cpi_transaction for patient update!" */

                SELECT 7015
                INTO var_return_error_code;

                SELECT 'N'
                INTO var_success_flag;

                RAISE
                    EXCEPTION 'rollback';
            END;
        END IF;
	EXCEPTION
        WHEN OTHERS THEN
            pas_return_code := var_return_error_code;
            RETURN;

    END;

    pas_return_code
        := 0;
    RETURN;

END;
$procedure$
;


;ALTER PROCEDURE "cpi_patient_update" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
