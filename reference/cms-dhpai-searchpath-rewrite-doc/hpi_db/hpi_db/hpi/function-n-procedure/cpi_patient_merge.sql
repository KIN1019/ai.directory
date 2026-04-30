-- DROP PROCEDURE cpi_patient_merge(inout int4, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE cpi_patient_merge(INOUT pas_return_code integer, IN par_from_hkid character varying, IN par_to_hkid character varying, IN par_update_by character varying, IN par_source_system character varying, IN par_source_system_dtm timestamp without time zone, IN par_hospital_code character varying, IN par_txn_type character varying, IN par_update_hosp character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ----20060410 for cpi_download'020' */DECLARE
	var_check_type VARCHAR(8);
    var_return_error_code INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_from_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_from_patient_key VARCHAR(08);
    var_from_patient_name VARCHAR(48);
    var_from_sex VARCHAR(01);
    var_from_dob TIMESTAMP WITHOUT TIME ZONE;
    var_from_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_from_patient_type VARCHAR(03);
    /* @from_mrn           VARCHAR(8), */
    var_from_death_indicator VARCHAR(4);
    var_from_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_from_death_code VARCHAR(4);
    var_from_cccode1 VARCHAR(5);
    var_from_cccode2 VARCHAR(5);
    var_from_cccode3 VARCHAR(5);
    var_from_cccode4 VARCHAR(5);
    var_from_cccode5 VARCHAR(5);
    var_from_cccode6 VARCHAR(5);
    var_from_chi_name VARCHAR(12);
    var_from_create_by VARCHAR(8);
    var_from_create_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_from_hospital_code VARCHAR(3);
    var_from_update_by VARCHAR(8);
    var_begin_tran VARCHAR(01);
    var_return_code INTEGER;
    var_to_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_to_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_to_patient_key VARCHAR(8);
    var_to_patient_name VARCHAR(48);
    var_to_sex VARCHAR(01);
    var_to_dob TIMESTAMP WITHOUT TIME ZONE;
    var_to_cccode1 VARCHAR(5);
    var_to_cccode2 VARCHAR(5);
    var_to_cccode3 VARCHAR(5);
    var_to_cccode4 VARCHAR(5);
    var_to_cccode5 VARCHAR(5);
    var_to_cccode6 VARCHAR(5);
    var_to_create_by VARCHAR(8);
    var_to_create_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_to_chi_name VARCHAR(12);
    var_death_case VARCHAR(1);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_success_flag VARCHAR(1);
    var_last_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_case_cnt INTEGER;
    var_rpc_name VARCHAR(60);
    var_upload_status VARCHAR(1);
    var_count INTEGER;
    var_from_count INTEGER;
    var_to_count INTEGER;
    var_mo_hkid VARCHAR(12);
    var_mo_prk VARCHAR(8);
    var_nb_hkid VARCHAR(12);
    var_nb_prk VARCHAR(8);
    var_preg_number INTEGER;
    var_birth_order INTEGER;
    var_case_no VARCHAR(12);
    var_cnt INTEGER;
    var_exit_flag VARCHAR(1);
    var_from_body_category VARCHAR(1);
    var_to_body_category VARCHAR(1);
    /* @from_mrn_timestamp timestamp */
    var_from_access_code INTEGER; /* ---20090702 */
    var_new_access_code INTEGER;
    var_confidential_code INTEGER;
    var_to_hkic_symbol VARCHAR(1);
    var_cpi_filler VARCHAR(30);
    var_opas_db VARCHAR(30);
    var_hkpmi_srvr VARCHAR(255);
    var_pgm_name VARCHAR(30);
    var_rpc_call VARCHAR(60);
    var_retcode INTEGER;
    var_pmi_error INTEGER;
    var_error_msg VARCHAR(255);
    var_to_marital_status VARCHAR(1);
    var_to_race VARCHAR(2);
    var_to_other_doc_no VARCHAR(12);
    var_to_building VARCHAR(47);
    var_to_room VARCHAR(5);
    var_to_floor VARCHAR(2);
    var_to_block VARCHAR(2);
    var_to_district VARCHAR(5);
    var_to_religion VARCHAR(3);
    var_to_home_phone VARCHAR(10);
    var_to_office_phone VARCHAR(10);
    var_to_office_phone_ext VARCHAR(4);
    var_to_other_phone VARCHAR(10);
    var_to_other_phone_ext VARCHAR(4);
    var_to_death_indicator VARCHAR(1);
    var_to_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_to_death_code VARCHAR(4);
    var_to_access_code INTEGER;
    var_to_security INTEGER;
    var_to_reference VARCHAR(20);
    var_to_card_holder INTEGER;
    var_to_mrn VARCHAR(8);
    var_to_exact_dob_flag VARCHAR(1);
    var_nok_priority INTEGER;
    var_major_nok VARCHAR(1);
    var_nok_hkid VARCHAR(12);
    var_nok_name VARCHAR(48);
    var_nok_relation VARCHAR(2);
    var_nok_building VARCHAR(47);
    var_nok_room VARCHAR(5);
    var_nok_floor VARCHAR(2);
    var_nok_block VARCHAR(2);
    var_nok_district VARCHAR(5);
    var_nok_home_phone VARCHAR(10);
    var_nok_office_phone VARCHAR(10);
    var_nok_office_phone_ext VARCHAR(4);
    var_nok_other_phone VARCHAR(10);
    var_nok_other_phone_ext VARCHAR(4);
    sql$rowcount BIGINT;
	error_message text;
    db_sql text;
    var_mode varchar(4);
    cur_mo CURSOR FOR
    SELECT
        mother_case_no, new_born_patient_key
        FROM cpi_new_born
        WHERE mother_patient_key = var_from_patient_key AND hospital_code = par_hospital_code;

    var_insert_updatelog VARCHAR(1);
    var_temp_privacy_flag VARCHAR(1);
    var_del_privacy_flag VARCHAR(1);
    var_ins_privacy_flag VARCHAR(1);
    var_temp_fx_id INTEGER;
    var_temp_source_system VARCHAR(5);

BEGIN
    <<return_error>>
    BEGIN
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
        SET search_path TO hpi, public;
        SELECT
            CASE
                WHEN hospital_code IN ('QMH', 'UCH') THEN 'opsystem'
                ELSE CONCAT(RTRIM(LOWER(hospital_code)), 'opas_db')
            END
            INTO var_opas_db
            FROM hospital;
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */

        IF par_update_hosp IS NULL THEN
            SELECT
                par_hospital_code
                INTO par_update_hosp;
        END IF;
        raise notice 'cpi_patient_merge[1] var_opas_db=% par_source_system=%',var_opas_db,par_source_system;
        /* ---------------------Begin of 20051102 SL  -------------------------------------------- */
        IF par_source_system <> 'DNL' THEN
            BEGIN
                SELECT
                    NULL
                    INTO var_hkpmi_srvr;
                /* ---cis rpc ---7223 (login kill or existed abnormally) or 11206(server down) or 923 (dbo use only) */
                CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_SERVER', var_hkpmi_srvr, var_mode);
                IF var_hkpmi_srvr IS NULL THEN /* ---1). Reject update if primary HKPMI server is not available */
                    BEGIN
                        SELECT
                            'Primary HKPMI server is not available, PMI Registration, Change HKID, Move Episode and Merge Patient functions are prohibited.'
                            INTO var_error_msg;
                        /* ---raiserror 200034 @error_msg */
                        pas_return_code := 200034;
                        RETURN;
                    END;
                END IF;
                /* enable on 10-03-2006 -- remarked before jan 2006 */

                /*SELECT
      				concat(schema_name,'.hkpmi_check_merge')  
			    INTO var_rpc_call
			    from hkpmi_control;
                perform public.dblink_connect('rpc_server'::text, var_hkpmi_srvr);
--                CALL rpc_call(par_hospital_code, par_from_hkid, par_to_hkid, var_pmi_error, 'MERGE');
                db_sql := 'call ' 
				|| var_rpc_call || '(' 
                || case when var_retcode is null then '0' else var_retcode end || ','
               	|| case when par_hospital_code is null then 'null::varchar' else concat('''', par_hospital_code, '''::varchar') end || ','
				|| case when par_from_hkid is null then 'null::varchar' else concat('''', par_from_hkid, '''::varchar') end || ','
				|| case when par_to_hkid is null then 'null::varchar' else concat('''', par_to_hkid, '''::varchar') end || ','
				|| '0,'
				|| '''MERGE''' ||');'::text;
			    raise notice 'cpi_patient_merge[2] %', db_sql;
                select * from public.dblink('rpc_server'::text,db_sql)
				as t1(var_retcode int) into var_retcode;
				perform public.dblink_disconnect('rpc_server'::text);
			    raise notice 'cpi_patient_merge[3] var_retcode=%',var_retcode;
			    begin
				exception
					when others then
						begin
							GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
							raise notice 'cpi_patient_merge error %', error_message;
							perform public.dblink_disconnect('rpc_server'::text);
						end;
				end;*/
               
               	-- replace_dblink_by_fdw
               	var_check_type := 'MERGE';
               	CALL hkpmi.hkpmi_check_merge(var_retcode, par_hospital_code, par_from_hkid, par_to_hkid, var_pmi_error, var_check_type) ;
               	SET search_path TO hpi,public;
                IF var_retcode <> 0 THEN /* --2). Reject update if episode is found in other hospital for Merge From HKID (by calling hkpmi_check_merge) */
                    BEGIN
                        IF var_retcode = 1 THEN
                            SELECT
                                'Merge From HKID not exist'
                                INTO var_error_msg;
                        ELSE
                            IF var_retcode = 2 THEN
                                SELECT
                                    'Merge To HKID not exist'
                                    INTO var_error_msg;
                            ELSE
                                IF var_retcode = 3 THEN
                                    SELECT
                                        'Episode for Merge From HKID exists in other hospital, Merge HKID is rejected!'
                                        INTO var_error_msg;
                                ELSE
                                    IF var_retcode = 4 THEN
                                        SELECT
                                            'UID linkage problem, Merge HKID is rejected!'
                                            INTO var_error_msg;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                        /* ---raiserror 200035 @error_msg */
                        raise notice 'cpi_patient_merge[4] var_error_msg=%',var_error_msg;
                        pas_return_code := 200035;
                        RETURN;
                        /*
                        0 - No error    1 - Merge From HKID not exist
                        2 - Merge To HKID not exist  3 - Episode exists in other hospital for Merge From HKID
                        */
                    END;
                END IF;
            END;
        END IF; /* ---if @source_system <> 'DNL' */
        /* ---------------------End OF : 20051102 SL --------------------------------------- */
        /*
        [3057 - Severity CRITICAL - PostgreSQL does not support SAVE TRAN cpi_patient_merge command. Perform a manual conversion.]
        save transaction cpi_patient_merge
        */
        IF par_source_system = 'DNL' THEN
            SELECT
                'N'
                INTO var_upload_status;
        ELSE
            SELECT
                'Y'
                INTO var_upload_status;
        END IF;
        /* Pre-Checking and initializing */
        
        IF par_txn_type <> '020' THEN
            BEGIN
                SELECT
                    200018
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;

        IF par_from_hkid = par_to_hkid THEN
            BEGIN
                SELECT
                    200010
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;

        IF par_source_system NOT IN ('ADT', 'OPAS', 'OPAS2', 'DNL') THEN
            BEGIN
                SELECT
                    200020
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        SELECT
            patient_key, death_indicator, death_date, death_code, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, create_by, create_dtm, update_dtm, row_update_datetime, update_hospital, update_by, body_category, access_code
            INTO var_from_patient_key, var_from_death_indicator, var_from_death_date, var_from_death_code, var_from_patient_name, var_from_sex, var_from_dob, var_from_cccode1, var_from_cccode2, var_from_cccode3, var_from_cccode4, var_from_cccode5, var_from_cccode6, var_from_chi_name, var_from_create_by, var_from_create_dtm, var_from_update_dtm, var_from_timestamp, var_from_hospital_code, var_from_update_by, var_from_body_category, var_from_access_code
            FROM cpi_patient
            WHERE hkid = par_from_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
		
        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    200011
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;

        IF var_from_cccode1 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_from_cccode1;
        END IF;

        IF var_from_cccode2 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_from_cccode2;
        END IF;

        IF var_from_cccode3 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_from_cccode3;
        END IF;

        IF var_from_cccode4 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_from_cccode4;
        END IF;

        IF var_from_cccode5 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_from_cccode5;
        END IF;

        IF var_from_cccode6 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_from_cccode6;
        END IF;
        
        /* select @from_mrn = mrn, */
        /* @from_mrn_timestamp = timestamp */
        /* from cpi_patient_hospital_data */
        /* where patient_key = @from_patient_key and */
        /* hospital_code = @hospital_code */
        
        /* -- */
        /* if @@rowcount = 0 */
        /* select @from_mrn is null */
        SELECT
            patient_key, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, row_update_datetime, update_dtm, chi_name, create_by, create_dtm,
            /* ----20051102 -- */
            exact_dob_flag, marital_status, race, other_doc_no, building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, access_code, security, reference, card_holder, body_category,
            /* ----20051102 -- */
            hkic_symbol
            INTO var_to_patient_key, var_to_patient_name, var_to_sex, var_to_dob, var_to_cccode1, var_to_cccode2, var_to_cccode3, var_to_cccode4, var_to_cccode5, var_to_cccode6, var_to_timestamp, var_to_update_dtm, var_to_chi_name, var_to_create_by, var_to_create_dtm, var_to_exact_dob_flag, var_to_marital_status, var_to_race, var_to_other_doc_no, var_to_building, var_to_room, var_to_floor, var_to_block, var_to_district, var_to_religion, var_to_home_phone, var_to_office_phone, var_to_office_phone_ext, var_to_other_phone, var_to_other_phone_ext, var_to_death_indicator, var_to_death_date, var_to_death_code, var_to_access_code, var_to_security, var_to_reference, var_to_card_holder, var_to_body_category, var_to_hkic_symbol
            FROM cpi_patient
            WHERE hkid = par_to_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
		raise notice 'par_from_hkid=%,par_to_hkid=%',par_from_hkid,par_to_hkid;
        IF sql$rowcount = 0 THEN
            BEGIN
                SELECT
                    200012
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;

        IF var_to_cccode1 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_to_cccode1;
        END IF;

        IF var_to_cccode2 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_to_cccode2;
        END IF;

        IF var_to_cccode3 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_to_cccode3;
        END IF;

        IF var_to_cccode4 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_to_cccode4;
        END IF;

        IF var_to_cccode5 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_to_cccode5;
        END IF;

        IF var_to_cccode6 = REPEAT(' ', 1) THEN
            SELECT
                NULL
                INTO var_to_cccode6;
        END IF;
		
		
        IF var_from_sex <> var_to_sex OR var_from_patient_name <> var_to_patient_name OR var_from_dob <> var_to_dob OR COALESCE(var_from_cccode1,'') <> COALESCE(var_to_cccode1,'')   OR COALESCE(var_from_cccode2,'') <> COALESCE(var_to_cccode2,'') OR COALESCE(var_from_cccode3,'') <> COALESCE(var_to_cccode3,'') OR COALESCE(var_from_cccode4,'') <> COALESCE(var_to_cccode4,'') OR COALESCE(var_from_cccode5,'') <> COALESCE(var_to_cccode5,'') OR COALESCE(var_from_cccode6,'') <> COALESCE(var_to_cccode6,'') THEN
            begin
	           
                SELECT
                    200013
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
               
            END;
        END IF;
       	
       	
        /* No more than one active case */
        /*
        Modified for Sybase 12
        select @rowcount = count(*) from cpi_case
           where patient_key in (@from_patient_key, @to_patient_key) and
                 hospital_code = @hospital_code and
                 discharge_code is null and
                 case_type like "[AI]" and
                 status_code <> "CC"
        */
        SELECT
            COUNT(*)
            INTO var_from_count
            FROM cpi_case
            WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code AND discharge_code is null AND case_type in ('A','I') AND status_code <> 'CC';
        SELECT
            COUNT(*)
            INTO var_to_count
            FROM cpi_case
            WHERE patient_key = var_to_patient_key AND hospital_code = par_hospital_code AND discharge_code is null AND case_type in ('A','I') AND status_code <> 'CC';
        SELECT
            var_from_count + var_to_count
            INTO var_rowcount;
		
        IF var_rowcount > 1 THEN
            BEGIN
                SELECT
                    200014
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* Process */
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_update_dtm;
        
        /*
        if exists(select * from cpi_new_born
        		where mother_patient_key = @from_patient_key
        		and hospital_code = @hospital_code)
        		update cpi_new_born set
        			mother_patient_key = @to_patient_key
        			where mother_patient_key = @from_patient_key
        			and hospital_code = @hospital_code
           select @error = @@error, @rowcount = @@rowcount
           if @error != 0
           begin
              select @return_error_code = @error
              select @success_flag = "N"
              goto return_error
           end
        
        	if exists(select * from cpi_new_born
        		where new_born_patient_key = @from_patient_key
        		and hospital_code = @hospital_code)
        		update cpi_new_born set
        			new_born_patient_key = @to_patient_key
        			where new_born_patient_key = @from_patient_key
        			and hospital_code = @hospital_code
           select @error = @@error, @rowcount = @@rowcount
           if @error != 0
           begin
              select @return_error_code = @error
              select @success_flag = "N"
              goto return_error
           end
        */
        IF EXISTS (SELECT
            *
            FROM cpi_new_born
            WHERE new_born_patient_key = var_from_patient_key AND hospital_code = par_hospital_code) THEN
            BEGIN
                SELECT
                    mother_patient_key, birth_order, pregnancy_number, mother_case_no
                    INTO var_mo_prk, var_birth_order, var_preg_number, var_case_no
                    FROM cpi_new_born
                    WHERE new_born_patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
                SELECT
                    hkid
                    INTO var_mo_hkid
                    FROM cpi_patient
                    WHERE patient_key = var_mo_prk;
                CALL cpi_update_new_born(var_return_code, 'P', par_hospital_code, var_mo_hkid, par_to_hkid, var_case_no, var_birth_order, var_preg_number, par_update_by, var_update_dtm, var_from_patient_key, var_to_patient_key);


                IF var_return_code != 0 THEN
                    BEGIN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
        
        OPEN cur_mo;
        FETCH cur_mo INTO var_case_no, var_nb_prk;
		raise notice 'var_case_no=%,var_nb_prk=%',var_case_no,var_nb_prk;
        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            SELECT
                birth_order, pregnancy_number
                INTO var_birth_order, var_preg_number
                FROM cpi_new_born
                WHERE mother_patient_key = var_from_patient_key AND hospital_code = par_hospital_code AND mother_case_no = var_case_no AND new_born_patient_key = var_nb_prk;
            SELECT
                hkid
                INTO var_nb_hkid
                FROM cpi_patient
                WHERE patient_key = var_nb_prk;
            CALL cpi_update_new_born(var_return_code, 'U', par_hospital_code, par_to_hkid, var_nb_hkid, var_case_no, var_birth_order, var_preg_number, par_update_by, var_update_dtm, NULL, NULL);

            IF var_return_code != 0 THEN
                BEGIN
                    SELECT
                        var_return_code
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    raise exception '';
                END;
            END IF;
            FETCH cur_mo INTO var_case_no, var_nb_prk;
        END LOOP;

        CLOSE cur_mo;

        IF EXISTS (SELECT
            *
            FROM cpi_case
            WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code AND discharge_code = '1') THEN
            SELECT
                'Y'
                INTO var_death_case;
        ELSE
            SELECT
                'N'
                INTO var_death_case;
        END IF;
        /* select @update_dtm = getdate() */
        
        /* No. of cases for this patient in other hospitals */
        SELECT
            COUNT(*)
            INTO var_case_cnt
            FROM cpi_case
            WHERE patient_key = var_from_patient_key AND hospital_code != par_hospital_code;

        IF var_death_case = 'Y' THEN
            BEGIN
                SELECT
                    update_dtm
                    INTO var_last_update_dtm
                    FROM cpi_patient
                    WHERE patient_key = var_to_patient_key AND hkid = par_to_hkid;
                /* YL: Move body_category */
                SELECT
                    COALESCE(var_to_body_category, var_from_body_category)
                    INTO var_to_body_category;
                CALL cpi_patient_upd_death(var_return_code, par_hospital_code, par_to_hkid, var_to_patient_key, var_from_death_date, var_from_death_indicator, var_update_dtm, par_update_hosp, par_update_by, var_last_update_dtm, par_source_system, 'P', var_to_body_category);


                IF var_return_code != 0 THEN
                    BEGIN
                        SELECT
                            200017
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;

                IF var_case_cnt > 0 THEN
                    BEGIN
                        SELECT
                            update_dtm
                            INTO var_last_update_dtm
                            FROM cpi_patient
                            WHERE patient_key = var_from_patient_key AND hkid = par_from_hkid;
                        CALL cpi_patient_upd_death(var_return_code, par_hospital_code, par_from_hkid, var_from_patient_key, NULL, 'N', var_update_dtm, par_update_hosp, par_update_by, var_last_update_dtm, par_source_system);


                        IF var_return_code != 0 THEN
                            BEGIN
                                SELECT
                                    200017
                                    INTO var_return_error_code;
                                SELECT
                                    'N'
                                    INTO var_success_flag;
                                raise exception '';
                            END;
                        END IF;
                    END;
                END IF;
                /* set getdate to update_dtm after the upd death 20040317 LeoLee */
                /* --		select @update_dtm = getdate() */
            END;
        END IF;
        SELECT
            COUNT(*)
            INTO var_count
            FROM cpi_case
            WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
		raise notice 'var_count=%',var_count;
        IF var_count > 0 THEN
            BEGIN
                BEGIN
                    UPDATE cpi_case
                    SET patient_key = var_to_patient_key, update_by = par_update_by, update_dtm = var_update_dtm
                        WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS then
                        	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error != 0 THEN
                    BEGIN
                        SELECT
                            var_error
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* Update and Insert patient_key_changed! */
        /* remove duplicate row before update */
        IF EXISTS (SELECT
            *
            FROM cpi_patient_key_changed
            WHERE patient_key = var_from_patient_key AND original_hkid = par_to_hkid AND update_dtm IN (SELECT
                update_dtm
                FROM cpi_patient_key_changed
                WHERE patient_key = var_from_patient_key AND original_hkid = par_from_hkid)) THEN
            BEGIN
                DELETE FROM cpi_patient_key_changed
                    WHERE patient_key = var_from_patient_key AND original_hkid = par_to_hkid AND update_dtm IN (SELECT
                        update_dtm
                        FROM cpi_patient_key_changed
                        WHERE patient_key = var_from_patient_key AND original_hkid = par_from_hkid);
            END;
        END IF;
        /* remove duplicate row before update */
        BEGIN
            UPDATE cpi_patient_key_changed
            SET original_hkid = par_to_hkid
                WHERE patient_key = var_from_patient_key AND original_hkid = par_from_hkid;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS then
                	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
                    var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* insert from patient major key change information */
        /*
        if exists (select * from cpi_patient_key_changed where
                patient_key = @from_patient_key and
                original_hkid = @to_hkid and
                update_dtm = @from_update_dtm)
        select @from_update_dtm = dateadd(ms, 3, @from_update_dtm)
        */
        IF var_rowcount <= 0 THEN
            BEGIN
                BEGIN
                    INSERT INTO cpi_patient_key_changed (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm)
                    VALUES (var_from_patient_key, par_from_hkid, var_from_patient_name, var_from_sex, var_from_cccode1, var_from_cccode2, var_from_cccode3, var_from_cccode4, var_from_cccode5, var_from_cccode6, var_from_chi_name, var_from_dob, par_to_hkid, var_from_hospital_code, var_from_update_by, var_from_update_dtm);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS then
                        	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
                            var_error := 1;
                END;

                IF var_error != 0 THEN
                    BEGIN
                        SELECT
                            var_error
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* insert to patient major key change information */
        BEGIN
            INSERT INTO cpi_patient_key_changed (patient_key, hkid, patient_name, sex, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, dob, original_hkid, update_hospital, update_by, update_dtm)
            VALUES (var_from_patient_key, par_to_hkid, var_to_patient_name, var_to_sex, var_to_cccode1, var_to_cccode2, var_to_cccode3, var_to_cccode4, var_to_cccode5, var_to_cccode6, var_to_chi_name, var_to_dob, par_to_hkid, par_update_hosp, par_update_by, var_update_dtm);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS then
                	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* update access change */
        BEGIN
            UPDATE cpi_access_changed
            SET patient_key = var_to_patient_key
                WHERE patient_key = var_from_patient_key;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS then
                	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* case only exists in processing hospital */
        IF var_case_cnt = 0 THEN
            BEGIN
                BEGIN
                    DELETE FROM cpi_patient_hospital_data
                        WHERE patient_key = var_from_patient_key AND hospital_code = par_hospital_code;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS then
                        	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
                            var_error := 1;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error != 0 THEN
                    BEGIN
                        SELECT
                            var_error
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
				raise notice 'var_from_patient_key=%',var_from_patient_key;
                BEGIN
                    DELETE FROM cpi_patient
                        WHERE patient_key = var_from_patient_key AND row_update_datetime = var_from_timestamp;
                    
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS then
                        	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
                            var_error := 1;
                END;
                
				
                IF var_error != 0 THEN
                    BEGIN
                        SELECT
                            var_error
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
				
                IF var_rowcount != 1 THEN
                    BEGIN
                        /* Patient has been updated between retrieved and update." */
                        SELECT
                            200015
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* call ADT's stored procedure to update its T_PRK in Case table */
        /* --- Modified by WL on 3 SEP 1999 for HPI -- */
        
        /* --select @rpc_name=(lower(@hospital_code)) + "adt_db..hasp_merge_case" */
        
        /* remarked by LSCHU since no need to update adt_db */
        
        /*
        select @rpc_name="hasp_merge_case"
        
        exec @return_code = @rpc_name @hospital_code,@from_patient_key, @to_patient_key,
                            @update_by, @source_system_dtm
        if @return_code <> 0
        begin
           select @return_error_code = 200019
           select @success_flag = "N"
           goto return_error
        end
        */
        
        /* checking existence of OPAS system */
        
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
        
        /* select @return_code = db_id('opsystem') */
        SELECT
            to_regnamespace(var_opas_db)
            INTO var_return_code;
        /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
        raise notice 'var_opas_db=%,var_return_code=%',var_opas_db,var_return_code;
        IF var_return_code is not NULL THEN
            begin
	            
                /*
                [3061 - Severity CRITICAL - Unable to convert system object sysdatabases. Perform a manual conversion.]
                if exists (select name from master..sysdatabases
                /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
                /*                     where name = 'opsystem' and */
                                     where name = @opas_db and
                /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
                                        ( status & 0x800 > 0 or
                                          status & 0x1000 > 0 or
                                          status & 0x100 > 0 )
                                )
                      begin
                         select @return_error_code = -1
                         select @success_flag = 'N'
                --         print "!!!!! OPAS DB not ready."
                         goto return_error
                      end
                */
                /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - Start */
                /* select @rpc_name = 'opsystem..cpi_merge_hkid' */

                SELECT
      				concat(schema_name,'.cpi_merge_hkid')  
				INTO var_rpc_name
				from hkpmi_control;
                /* 2010-02-24 SMR20017773 fx - Fix hard-coded "opsystem" in stored procedure discovered from MSSQL to Sybase DB Migration - End */
--                CALL rpc_name(var_from_patient_key, par_from_hkid, var_to_patient_key, par_to_hkid, par_update_by, par_source_system, par_update_hosp);
                perform public.dblink_connect('rpc_server'::text, var_opas_db);
                select * from public.dblink('rpc_server'::text,'call ' 
				|| var_rpc_name || '(' 
                || case when var_return_code is null then 'null::int' else var_return_code end || ','
               	|| case when var_from_patient_key is null then 'null::varchar' else concat('''', var_from_patient_key, '''::varchar') end || ','
				|| case when par_from_hkid is null then 'null::varchar' else concat('''', par_from_hkid, '''::varchar') end || ','
				|| case when var_to_patient_key is null then 'null::varchar' else concat('''', var_to_patient_key, '''::varchar') end || ','
				|| case when par_to_hkid is null then 'null::varchar' else concat('''', par_to_hkid, '''::varchar') end || ','
				|| case when par_update_by is null then 'null::varchar' else concat('''', par_update_by, '''::varchar') end || ','
				|| case when par_source_system is null then 'null::varchar' else concat('''', par_source_system, '''::varchar') end || ','
				|| case when par_update_hosp is null then 'null::varchar' else concat('''', par_update_hosp, '''::varchar') end ||');'::text)
				as t1(var_return_code int) into var_retcode;
				perform public.dblink_disconnect('rpc_server'::text);
					exception
						when others then
						GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    	raise notice 'error_message=%',error_message;
						perform public.dblink_disconnect('rpc_server'::text);
                IF var_return_code != 0 THEN
                    BEGIN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        /* print "!!!!! Error in Call OPAS stored proc" */
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /*
        ***********************************************************
        Sep-2022/patient privacy flag/CP2 Max,Freda/
        Because the new tables for privacy flag have patient key, and patient key can be changed by IPAS Merge Patient function
        Reference:
        1. the above cpi_patient_location
        2. tU_patient in HKPMI for hkpmi_patient_travel_record and hkpmi_patient_travel_log
        */
        var_insert_updatelog := 'N';

        IF par_source_system IN ('ADT') THEN
            BEGIN
                /* If the patient key is NOT changed, do nothing! */
                IF var_to_patient_key != var_from_patient_key THEN
                    BEGIN
                        /* --if @ins_hkid != @del_hkid begin */
                        /* Check if Old/From patient key exists, and if yes, get the Old/From privacy flag */
                        SELECT
                            privacy_flag
                            INTO var_del_privacy_flag
                            FROM cpi_privacy_flag
                            WHERE patient_key = var_from_patient_key;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        IF sql$rowcount > 0 THEN
                            BEGIN
                                SELECT
                                    var_del_privacy_flag
                                    INTO var_temp_privacy_flag;
                                /* Check if New/To patient key exists, and if yes, get the New/To privacy flag */
                                SELECT
                                    privacy_flag
                                    INTO var_ins_privacy_flag
                                    FROM cpi_privacy_flag
                                    WHERE patient_key = var_to_patient_key;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF sql$rowcount > 0 THEN
                                    BEGIN
                                        /* Scenario 1 (New/To patient key exists in the table before merging patient) */
                                        IF var_ins_privacy_flag != var_del_privacy_flag THEN
                                            /* --and (@ins_privacy_flag = 'Y' or @del_privacy_flag = 'Y') */
                                            BEGIN
                                                /* Follow Patient Confidentiality Update Function behavior, as requested by HI */
                                                /* (Refer to Freda's email on 20-Sep-2022 about the Confidentiality testing result after merging patient) */
                                                UPDATE cpi_privacy_flag
                                                SET privacy_flag = 'Y'
                                                    /* --set privacy_flag = @del_privacy_flag */
                                                    WHERE patient_key = var_to_patient_key;
                                                SELECT
                                                    'Y'
                                                    INTO var_temp_privacy_flag;

                                                BEGIN
                                                    var_insert_updatelog := 'Y';
                                                    EXCEPTION
                                                        WHEN others THEN
                                                            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
									                    	raise notice 'error_message=%',error_message;
									                    	pas_return_code := 0;
                                                            RETURN;
                                                END;
                                            END;
                                        END IF;
                                        /* De-active the record with Old/From patient key */
                                        /* Later found the "active" column is not that useful as discussed, so delete the record simply */
                                        
                                        /*
                                        update cpi_privacy_flag
                                        set active = 'N'
                                        where patient_key = @del_patient_key
                                        */
                                        /* Delete the record with Old/From patient key */
                                        BEGIN
                                            DELETE FROM cpi_privacy_flag
                                                WHERE patient_key = var_from_patient_key;
                                            EXCEPTION
                                                WHEN others THEN
                                                    GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    								raise notice 'error_message=%',error_message;
                    								pas_return_code := 0;
                                                    RETURN;
                                        END;
                                    END;
                                ELSE
                                    BEGIN
                                        /* Scenario 2 (New/To patient key does NOT exist in the table before merging patient) */
                                        /* Only need to update the patient key of the record */
                                        /* (like the patient_key change handling in hkpmi..tU_patient for hkpmi..hkpmi_patient_travel_record) */
                                        UPDATE cpi_privacy_flag
                                        SET patient_key = var_to_patient_key
                                            WHERE patient_key = var_from_patient_key;

                                        BEGIN
                                            var_insert_updatelog := 'Y';
                                            EXCEPTION
                                                WHEN others THEN
                                                    GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    								raise notice 'error_message=%',error_message;
                    								pas_return_code := 0;
                                                    RETURN;
                                        END;
                                    END;
                                END IF;
                            END;
                        END IF;

                        IF 'Y' = var_insert_updatelog THEN
                            BEGIN
                                var_temp_fx_id := 0;

                                IF 'OPAS' = par_source_system THEN
                                    BEGIN
                                        var_temp_fx_id := 11620;
                                        var_temp_source_system := 'OPAS';
                                    END;
                                END IF;

                                IF 'ADT' = par_source_system THEN
                                    BEGIN
                                        var_temp_fx_id := 10020;
                                        var_temp_source_system := 'IPAS';
                                    END;
                                END IF;

                                IF 'OPAS2' = par_source_system THEN
                                    BEGIN
                                        var_temp_fx_id := 0;
                                        var_temp_source_system := 'OPAS2';
                                    END;
                                END IF;

                                IF 'DNL' = par_source_system THEN
                                    BEGIN
                                        var_temp_fx_id := 0;
                                        var_temp_source_system := 'DNL';
                                    END;
                                END IF;
                                INSERT INTO cpi_privacy_flag_update_log (hospital_code, patient_key, original_patient_key, case_no, privacy_flag, update_system, update_function_id, update_user_id, update_datetime)
                                VALUES (par_hospital_code, var_to_patient_key, var_from_patient_key, NULL, var_temp_privacy_flag, var_temp_source_system, var_temp_fx_id, par_update_by, timestamp_convert(localtimestamp));
                            END;
                        END IF;
                        /*
                        Points to note:
                        As discussed internally, unlike the above handling on cpi_privacy_flag,
                        keep the patient key unchanged in cpi_privacy_flag_update_log table
                        in order to facilitate the future debug/support.
                        */
                        /* As discussed internally, for the access log table below, it's ok to update the patient key simply */
                        IF EXISTS (SELECT
                            1
                            FROM cpi_privacy_flag_access_log
                            WHERE patient_key = var_from_patient_key) THEN
                            BEGIN
                                BEGIN
                                    UPDATE cpi_privacy_flag_access_log
                                    SET patient_key = var_to_patient_key
                                        WHERE patient_key = var_from_patient_key;
                                    EXCEPTION
                                        WHEN others THEN
                                            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                    						raise notice 'error_message=%',error_message;
                    						pas_return_code := 0;
                                            RETURN;
                                END;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* End - Sep-2022/patient privacy flag */
        /* ------------ 20051102 ----------------- */
        SELECT
            mrn
            INTO var_to_mrn
            FROM cpi_patient_hospital_data
            WHERE patient_key = var_to_patient_key AND hospital_code = par_hospital_code;
        SELECT
            priority, major_nok, hkid, nok_name, relationship, building, room, floor, block, district, phone1, phone2, address_indicator, mobile_phone, sms_language
            INTO var_nok_priority, var_major_nok, var_nok_hkid, var_nok_name, var_nok_relation, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_home_phone, var_nok_office_phone, var_nok_office_phone_ext, var_nok_other_phone, var_nok_other_phone_ext
            FROM cpi_nok
            WHERE patient_key = var_to_patient_key AND major_nok = 'Y';
        /* ------------ 20051102 ----------------- */
        
        /* ---20100928 SL */
        SELECT
            CONCAT(REPEAT(' ', 28), COALESCE(var_to_hkic_symbol, REPEAT(' ', 1)))
            INTO var_cpi_filler;

        IF (LTRIM(RTRIM(var_cpi_filler)) = '') OR (LTRIM(RTRIM(var_cpi_filler)) is null) THEN
            SELECT
                NULL
                INTO var_cpi_filler;
        END IF;

        WHILE 1 = 1 LOOP
            /* added to check existing of tranasction dtm before insert 20040317 LeoLee */
            /*
            if exists (select * from cpi_transaction where hospital_code = @hospital_code
            						and transaction_datetime = @update_dtm)
            		begin
                     select @update_dtm = dateadd(ms,3,@update_dtm)
            			continue
            		end
            */
            SELECT
                COUNT(*)
                INTO var_cnt
                FROM cpi_transaction
                WHERE hospital_code = par_hospital_code AND transaction_datetime = var_update_dtm;
			raise notice '1111var_cnt=%',var_cnt;
            IF (var_cnt != 0) THEN
                BEGIN
                    SELECT
                        'N'
                        INTO var_exit_flag;

                    WHILE (var_exit_flag = 'N') LOOP
                        SELECT
                            3 * INTERVAL '1 millisecond' + var_update_dtm::TIMESTAMP
                            INTO var_update_dtm;
                        SELECT
                            COUNT(*)
                            INTO var_cnt
                            FROM cpi_transaction
                            WHERE hospital_code = par_hospital_code AND transaction_datetime = var_update_dtm;

                        IF (var_cnt = 0) THEN
                            SELECT
                                'Y'
                                INTO var_exit_flag;
                        END IF;
                    END LOOP;
                END;
            END IF;
            /* - Modified by WL on 3 SEP 1999-- */
            /*
            --insert cpi..cpi_transaction
            insert cpi_transaction
               (hospital_code, transaction_datetime, transaction_type,
                hkid, patient_key, patient_name, sex, dob, exact_dob_flag,
                ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name,
                success_indicator, old_patient_key, old_name, old_hkid,
                old_sex, old_dob, update_by, source_system,
                source_system_dtm, update_hospital, update_datetime,
                upload_status)
             select
                @hospital_code, @update_dtm, @txn_type,
                hkid, patient_key, patient_name, sex, dob, exact_dob_flag,
                cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name,
                'Y', @from_patient_key, @from_patient_name, @from_hkid,
                @from_sex, @from_dob, @update_by, @source_system,
                @source_system_dtm, @hospital_code, getdate(),
                @upload_status
                from cpi_patient
                   where patient_key = @to_patient_key
            */
            BEGIN
                INSERT INTO cpi_transaction (hospital_code, transaction_datetime, transaction_type, hkid, patient_key, patient_name, sex, dob, exact_dob_flag, ccc_1, ccc_2, ccc_3, ccc_4, ccc_5, ccc_6, chi_name, success_indicator, old_patient_key, old_name, old_hkid, old_sex, old_dob, update_by, source_system, source_system_dtm, update_hospital, update_datetime, upload_status,
                /* ----20051102 -- */
                marital_status, race_code, other_document_no, reference, medical_record_number, /* remark, */ building, room, floor, block, district_code, religion_code, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder, priority, major_nok, nok_name, nok_hkid, nok_relation_code, nok_building, nok_room, nok_floor, nok_block, nok_district_code, nok_phone1, nok_phone2, nok_address_indicator, nok_mobile_phone, nok_sms_language, cpi_filler)
                /* security_count */
                VALUES (par_hospital_code, var_update_dtm, par_txn_type, par_to_hkid, var_to_patient_key, var_to_patient_name, var_to_sex, var_to_dob, var_to_exact_dob_flag, var_to_cccode1, var_to_cccode2, var_to_cccode3, var_to_cccode4, var_to_cccode5, var_to_cccode6, var_to_chi_name, 'Y', var_from_patient_key, var_from_patient_name, par_from_hkid, var_from_sex, var_from_dob, par_update_by, par_source_system, par_source_system_dtm, par_update_hosp, timestamp_convert(localtimestamp), var_upload_status,
                /* ---20051102 -- */
                var_to_marital_status, var_to_race, var_to_other_doc_no, var_to_reference, var_to_mrn, /* @to_remark, */ var_to_building, var_to_room, var_to_floor, var_to_block, var_to_district, var_to_religion, var_to_home_phone, var_to_office_phone, var_to_office_phone_ext, var_to_other_phone, var_to_other_phone_ext, var_to_death_indicator, var_to_death_date, var_to_death_code, var_to_card_holder, var_nok_priority, var_major_nok, var_nok_name, var_nok_hkid, var_nok_relation, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district, var_nok_home_phone, var_nok_office_phone, var_nok_office_phone_ext, var_nok_other_phone, var_nok_other_phone_ext, var_cpi_filler)
                /* @to_security */;
                var_error := 0;
                EXCEPTION
                    WHEN OTHERS then
                    	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT,var_error = RETURNED_SQLSTATE;  
                    	raise notice 'error_message=%',error_message;
                        
            END;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_rowcount := sql$rowcount;
			raise notice 'var_error=%,var_rowcount=%',var_error,var_rowcount;
            IF var_error = 23505 THEN
                BEGIN
                    SELECT
                        3 * INTERVAL '1 millisecond' + var_update_dtm::TIMESTAMP
                        INTO var_update_dtm;
                    CONTINUE;
                END;
            END IF;

            IF var_error != 0 THEN
                BEGIN
                    /* Fail to insert into transaction_log. */
                    SELECT
                        var_error
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    raise exception '';
                END;
            END IF;

            IF var_rowcount != 1 THEN
                BEGIN
                    SELECT
                        200016
                        INTO var_return_error_code;
                    SELECT
                        'N'
                        INTO var_success_flag;
                    raise exception '';
                END;
            END IF;
            EXIT;
        END LOOP; /* --while 1 = 1 */
        /* --20090702 SL : 	      ------ for IPAS confidential code:2147247102 /  bit 0 =0  => PMI confi flag ON.. -------- */

        IF var_from_access_code & 1 = 0 AND
        /* ----  bit 0 =0  => PMI confi flag ON.. -------- */
        var_to_access_code & 1 = 1 THEN /* ----To_HKID confidential flag off */
            BEGIN
                /* patient confidential  ==> 2147247102(1111111111111000110001111111110) */
                CALL cpi_get_int_by_bin(pas_return_code, 'NYYYYYYYYYNNNYYNNNYYYYYYYYYYYYY', var_confidential_code);
                /* ---- Prevent overwrite the orig @to_access_code value like : OPAS  bits  (19 to 26) ,problem_address_ind (bit2),etc */
                SELECT
                    var_to_access_code & var_confidential_code
                    INTO var_new_access_code;
                /* --- To prevent error 7016 from cpi_patient_upd_acess */
                SELECT
                    update_dtm
                    INTO var_last_update_dtm
                    FROM cpi_patient
                    WHERE patient_key = var_to_patient_key AND hkid = par_to_hkid;
                CALL cpi_patient_upd_access(var_return_code, par_hospital_code, par_to_hkid, var_to_patient_key, var_new_access_code, var_update_dtm, par_update_hosp, par_update_by, var_last_update_dtm, par_source_system);

				
                IF var_return_code != 0 THEN
                    BEGIN
                        SELECT
                            var_return_code
                            INTO var_return_error_code;
                        SELECT
                            'N'
                            INTO var_success_flag;
                        raise exception '';
                    END;
                END IF;
            END;
        END IF;
        /* --------end 20090702 -- */
        /* ---20120908 --- */
        BEGIN
            INSERT INTO cpi_pin_change_log (hosp_code, txn_dtm, txn_type, hkid, patient_key, old_hkid, old_patient_key, update_by, source_sys, source_sys_dtm, update_hosp)
            VALUES (par_hospital_code, var_update_dtm, par_txn_type, par_to_hkid, var_to_patient_key, par_from_hkid, var_from_patient_key, par_update_by, par_source_system, par_source_system_dtm, par_update_hosp);
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                	GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
                	raise notice 'error_message=%',error_message;    
                	var_error := 1;
        END;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
        var_rowcount := sql$rowcount;
        /* --- the uniqe key = hosp_code + txn_dtm + hkid  --> 2601 SHOULD NOT occurred */
        
        /*
        if @error = 2601
        begin
           select @update_dtm = dateadd(ms,3,@update_dtm)
           continue
        end
        */
        IF var_error != 0 THEN
            BEGIN
                /* Fail to insert into cpi_pin_change_log. */
                SELECT
                    var_error
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    200016
                    INTO var_return_error_code;
                SELECT
                    'N'
                    INTO var_success_flag;
                raise exception '';
            END;
        END IF;
        /* ---- END 20120908 --- */
     	exception
			when others then
				GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            	raise notice 'error_message=%',error_message;
				EXIT return_error;
    END;

    IF (var_success_flag = 'N') THEN
        BEGIN

            RAISE NOTICE '%', var_return_error_code;
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

;ALTER PROCEDURE "cpi_patient_merge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
