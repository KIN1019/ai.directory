-- DROP PROCEDURE hpi.cpi_download(inout int4, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.cpi_download(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_input_dnl_sys_dtm timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_retrieve_flag VARCHAR(1);
    var_return_code INTEGER;
    var_error_code INTEGER;
    var_download_enable VARCHAR(1);
    var_srce_ind VARCHAR(01);
    var_srce_code VARCHAR(03);
    var_tran_id VARCHAR(600);
    var_dnl_hospital_code VARCHAR(3);
    var_patient_last_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_prk_key VARCHAR(8);
    var_case_no VARCHAR(12);
    var_type VARCHAR(3);
    var_hkid VARCHAR(12);
    var_other_doc_no VARCHAR(12);
    var_patient_nam VARCHAR(48);
    var_exact_dob VARCHAR(1);
    var_sex_cde VARCHAR(1);
    var_home_phone VARCHAR(10);
    var_marital_cde VARCHAR(1);
    var_patient_type_cde VARCHAR(3);
    var_admit_tran_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_transfer_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_discharge_cde VARCHAR(1);
    var_case_type VARCHAR(1);
    var_ward_cde VARCHAR(4);
    var_specialty VARCHAR(4);
    var_bed_no VARCHAR(5);
    var_ward_class VARCHAR(1);
    var_destination_cde VARCHAR(5);
    var_nok_nam VARCHAR(48);
    var_nok_hk_id VARCHAR(12);
    var_nok_relationship VARCHAR(2);
    var_nok_building VARCHAR(47);
    var_nok_room VARCHAR(5);
    var_nok_floor VARCHAR(2);
    var_nok_block VARCHAR(2);
    var_nok_district_code VARCHAR(5);
    var_nok_home_phone VARCHAR(10);
    var_old_hkid VARCHAR(12);
    var_old_prk_key VARCHAR(8);
    var_old_patient_nam VARCHAR(48);
    var_old_sex VARCHAR(1);
    var_old_dob TIMESTAMP WITHOUT TIME ZONE;
    var_old_ward_cde VARCHAR(4);
    var_old_specialty VARCHAR(4);
    var_old_bed_no VARCHAR(5);
    var_old_ward_class VARCHAR(1);
    var_last_upd_by VARCHAR(12);
    var_update_hosp_cde VARCHAR(3);
    var_dnl_pmi_access_code INTEGER;
    var_ccc_1 VARCHAR(05);
    var_ccc_2 VARCHAR(05);
    var_ccc_3 VARCHAR(05);
    var_ccc_4 VARCHAR(05);
    var_ccc_5 VARCHAR(05);
    var_ccc_6 VARCHAR(05);
    var_chi_name VARCHAR(12);
    var_race_code VARCHAR(02);
    var_dob TIMESTAMP WITHOUT TIME ZONE;
    var_remark VARCHAR(255);
    var_reference VARCHAR(20);
    var_medical_record_number VARCHAR(08);
    var_room VARCHAR(05);
    var_floor VARCHAR(02);
    var_block VARCHAR(02);
    var_building VARCHAR(47);
    var_district_code VARCHAR(05);
    var_religion_code VARCHAR(03);
    var_priority INTEGER;
    var_major_nok VARCHAR(1);
    var_nok_other_phone_no_1 VARCHAR(10);
    var_nok_other_phone_ext_1 VARCHAR(04);
    var_nok_other_phone_no_2 VARCHAR(10);
    var_nok_other_phone_ext_2 VARCHAR(04);
    var_other_phone_no_1 VARCHAR(10);
    var_other_phone_ext_1 VARCHAR(4);
    var_other_phone_no_2 VARCHAR(10);
    var_other_phone_ext_2 VARCHAR(4);
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_death_indicator VARCHAR(1);
    var_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_death_code VARCHAR(4);
    var_card_holder INTEGER;
    var_access_code INTEGER;
    var_security INTEGER;
    var_cnt INTEGER;
    /* --@pmi_patient_name          VARCHAR(40), */
    var_pmi_patient_name VARCHAR(48);
    var_pmi_sex VARCHAR(01);
    var_pmi_dob TIMESTAMP WITHOUT TIME ZONE;
    var_pmi_access_code INTEGER;
    var_pmi_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_pmi_death_indicator VARCHAR(1);
    var_hex INTEGER;
    var_error_msg VARCHAR(255);
    var_last_update_hospital VARCHAR(03);
    var_filler VARCHAR(30);
    /* GL 19980121 */
    var_last_download_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_source_system VARCHAR(5);
    var_delay_time INTEGER;
    var_error INTEGER;
    var_rowcount INTEGER;
    var_poll_mode VARCHAR(1);
    var_tmp_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_download_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_i INTEGER;
    var_pp_code VARCHAR(8);
    var_eh_code VARCHAR(8);
    var_document_flag VARCHAR(1);
    var_opas_access_code INTEGER;
    var_hkic_symbol VARCHAR(1);
    var_hkic_symbol_clear VARCHAR(1);
    var_pmi_ccc1 VARCHAR(5);
    var_pmi_ccc2 VARCHAR(5);
    var_pmi_ccc3 VARCHAR(5);
    var_pmi_ccc4 VARCHAR(5);
    var_pmi_ccc5 VARCHAR(5);
    var_pmi_ccc6 VARCHAR(5);
   	error_message text;
    sql$rowcount BIGINT;
   	dblink_sql text;
    start_date TIMESTAMP WITHOUT TIME zone;
    end_date TIMESTAMP WITHOUT TIME zone;

BEGIN
    <<error_return>>
    BEGIN
        /* -- added by WL on 10 May 2000- */
        
        /* ---20101202 - CIS RPC */
		SELECT clock_timestamp() into start_date;
        /* Init */
        SELECT
            'N'
            INTO var_hkic_symbol_clear;
        SELECT
            hospital_code, last_download_system_datetime, dnl_server_name, download_enable, delay_time
            INTO var_dnl_hospital_code, var_last_download_system_datetime, var_tran_id, var_download_enable, var_delay_time
            FROM download_control
            WHERE hospital_code = par_hospital_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        IF sql$rowcount <> 1 THEN
            BEGIN
                RAISE EXCEPTION '% ', 'Cannot read hospital information!' USING ERRCODE := '99999';
                EXIT error_return;
            END;
        END IF;
--        SELECT
--            CONCAT(RTRIM(var_tran_id), '.download.hkpmi_polling_to_cpi')
--            INTO var_tran_id;

        IF par_input_dnl_sys_dtm is not NULL THEN
            SELECT
                'Y'
                INTO var_download_enable;
        END IF;
        /*
        select @stop_download = "N"
        select @download_enable = 'Y'
        
        while (@stop_download = "N")
        begin
        */
        WHILE (var_download_enable = 'Y') LOOP
            <<skip_records>>
            BEGIN
                /*
                select @dnl_hospital_code = hospital_code,
                       @last_download_system_datetime = last_download_system_datetime,
                       @tran_id = dnl_server_name,
                       @download_enable = download_enable,
                       @delay_time = delay_time
                   from download_hkpmi_control
                   where hospital_code = @hospital_code
                
                if @@rowcount <> 1
                begin
                   raiserror 999999, 'Cannot read hospital information!'
                   goto error_return
                end
                select @tran_id = rtrim(@tran_id) + '.download..hkpmi_polling_to_cpi'
                */
                IF par_input_dnl_sys_dtm is NULL THEN
                    BEGIN
                        SELECT
                            'B', var_last_download_system_datetime
                            INTO var_poll_mode, var_tmp_system_datetime;
                    END;
                ELSE
                    BEGIN
                        SELECT
                            'A', par_input_dnl_sys_dtm
                            INTO var_poll_mode, var_tmp_system_datetime;
                    END;
                END IF;
             begin  
               	perform public.dblink_connect('tran_id'::text, var_tran_id);
               dblink_sql := 'call ' 
			|| 'download.hkpmi_polling_to_cpi('
            || case when var_return_code is null then 0 else var_return_code end || ','
            || case when var_dnl_hospital_code is null then 'null::varchar' else concat('''', var_dnl_hospital_code, '''::varchar') end || ','
			|| case when var_tmp_system_datetime is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else  concat('''', var_tmp_system_datetime, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_poll_mode is null then 'null::varchar' else concat('''', var_poll_mode, '''::varchar') end || ','
			|| case when var_retrieve_flag is null then 'null::varchar' else concat('''', var_retrieve_flag, '''::varchar') end || ','
			|| case when var_download_system_datetime is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_download_system_datetime, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_type is null then 'null::varchar' else concat('''', var_type, '''::varchar') end || ','
			|| case when var_admit_tran_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_admit_tran_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_hkid is null then 'null::varchar' else concat('''', var_hkid, '''::varchar') end || ','
			|| case when var_prk_key is null then 'null::varchar' else concat('''', var_prk_key, '''::varchar') end || ','
			|| case when var_patient_nam is null then 'null::varchar' else concat('''', var_patient_nam, '''::varchar') end || ','
			|| case when var_sex_cde is null then 'null::varchar' else concat('''', var_sex_cde, '''::varchar') end || ','
			|| case when var_dob is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_dob, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_exact_dob is null then 'null::varchar' else concat('''', var_exact_dob, '''::varchar') end || ','
			|| case when var_ccc_1 is null then 'null::varchar' else concat('''', var_ccc_1, '''::varchar') end || ','
			|| case when var_ccc_2 is null then 'null::varchar' else concat('''', var_ccc_2, '''::varchar') end || ','
			|| case when var_ccc_3 is null then 'null::varchar' else concat('''', var_ccc_3, '''::varchar') end || ','
			|| case when var_ccc_4 is null then 'null::varchar' else concat('''', var_ccc_4, '''::varchar') end || ','
			|| case when var_ccc_5 is null then 'null::varchar' else concat('''', var_ccc_5, '''::varchar') end || ','
			|| case when var_ccc_6 is null then 'null::varchar' else concat('''', var_ccc_6, '''::varchar') end || ','
			|| case when var_chi_name is null then 'null::varchar' else concat('''', var_chi_name, '''::varchar') end || ','
			|| case when var_marital_cde is null then 'null::varchar' else concat('''', var_marital_cde, '''::varchar') end || ','
			|| case when var_race_code is null then 'null::varchar' else concat('''', var_race_code, '''::varchar') end || ','
			|| case when var_other_doc_no is null then 'null::varchar' else concat('''', var_other_doc_no, '''::varchar') end || ','
			|| case when var_building is null then 'null::varchar' else concat('''', var_building, '''::varchar') end || ','
			|| case when var_room is null then 'null::varchar' else concat('''', var_room, '''::varchar') end || ','
			|| case when var_floor is null then 'null::varchar' else concat('''', var_floor, '''::varchar') end || ','
			|| case when var_block is null then 'null::varchar' else concat('''', var_block, '''::varchar') end || ','
			|| case when var_district_code is null then 'null::varchar' else concat('''', var_district_code, '''::varchar') end || ','
			|| case when var_religion_code is null then 'null::varchar' else concat('''', var_religion_code, '''::varchar') end || ','
			|| case when var_home_phone is null then 'null::varchar' else concat('''', var_home_phone, '''::varchar') end || ','
			|| case when var_other_phone_no_1 is null then 'null::varchar' else concat('''', var_other_phone_no_1, '''::varchar') end || ','
			|| case when var_other_phone_ext_1 is null then 'null::varchar' else concat('''', var_other_phone_ext_1, '''::varchar') end || ','
			|| case when var_other_phone_no_2 is null then 'null::varchar' else concat('''', var_other_phone_no_2, '''::varchar') end || ','
			|| case when var_other_phone_ext_2 is null then 'null::varchar' else concat('''', var_other_phone_ext_2, '''::varchar') end || ','
			|| case when var_priority is null then 0 else var_priority end || ','
			|| case when var_major_nok is null then 'null::varchar' else concat('''', var_major_nok, '''::varchar') end || ','
			|| case when var_nok_nam is null then 'null::varchar' else concat('''', var_nok_nam, '''::varchar') end || ','  
			|| case when var_nok_hk_id is null then 'null::varchar' else concat('''', var_nok_hk_id, '''::varchar') end || ','
			|| case when var_nok_relationship is null then 'null::varchar' else concat('''', var_nok_relationship, '''::varchar') end || ','
			|| case when var_nok_building is null then 'null::varchar' else concat('''', var_nok_building, '''::varchar') end || ','
			|| case when var_nok_room is null then 'null::varchar' else concat('''', var_nok_room, '''::varchar') end || ','
			|| case when var_nok_floor is null then 'null::varchar' else concat('''', var_nok_floor, '''::varchar') end || ','
			|| case when var_nok_block is null then 'null::varchar' else concat('''', var_nok_block, '''::varchar') end || ','
			|| case when var_nok_district_code is null then 'null::varchar' else concat('''', var_nok_district_code, '''::varchar') end || ','
			|| case when var_nok_home_phone is null then 'null::varchar' else concat('''', var_nok_home_phone, '''::varchar') end || ','
			|| case when var_nok_other_phone_no_1 is null then 'null::varchar' else concat('''', var_nok_other_phone_no_1, '''::varchar') end || ','
			|| case when var_nok_other_phone_ext_1 is null then 'null::varchar' else concat('''', var_nok_other_phone_ext_1, '''::varchar') end || ','
			|| case when var_nok_other_phone_no_2 is null then 'null::varchar' else concat('''', var_nok_other_phone_no_2, '''::varchar') end || ','
			|| case when var_nok_other_phone_ext_2 is null then 'null::varchar' else concat('''', var_nok_other_phone_ext_2, '''::varchar') end || ','
			|| case when var_case_no is null then 'null::varchar' else concat('''', var_case_no, '''::varchar') end || ','
			|| case when var_srce_ind is null then 'null::varchar' else concat('''', var_srce_ind, '''::varchar') end || ','
			|| case when var_srce_code is null then 'null::varchar' else concat('''', var_srce_code, '''::varchar') end || ','
			|| case when var_patient_type_cde is null then 'null::varchar' else concat('''', var_patient_type_cde, '''::varchar') end || ','
			|| case when var_discharge_cde is null then 'null::varchar' else concat('''', var_discharge_cde, '''::varchar') end || ','
			|| case when var_destination_cde is null then 'null::varchar' else concat('''', var_destination_cde, '''::varchar') end || ','
			|| case when var_case_type is null then 'null::varchar' else concat('''', var_case_type, '''::varchar') end || ','
			|| case when var_ward_cde is null then 'null::varchar' else concat('''', var_ward_cde, '''::varchar') end || ','
			|| case when var_specialty is null then 'null::varchar' else concat('''', var_specialty, '''::varchar') end || ','
			|| case when var_bed_no is null then 'null::varchar' else concat('''', var_bed_no, '''::varchar') end || ','
			|| case when var_ward_class is null then 'null::varchar' else concat('''', var_ward_class, '''::varchar') end || ','
			|| case when var_old_prk_key is null then 'null::varchar' else concat('''', var_old_prk_key, '''::varchar') end || ','
			|| case when var_old_patient_nam is null then 'null::varchar' else concat('''', var_old_patient_nam, '''::varchar') end || ','
			|| case when var_old_hkid is null then 'null::varchar' else concat('''', var_old_hkid, '''::varchar') end || ','
			|| case when var_old_sex is null then 'null::varchar' else concat('''', var_old_sex, '''::varchar') end || ','
			|| case when var_old_dob is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_old_dob, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_old_ward_class is null then 'null::varchar' else concat('''', var_old_ward_class, '''::varchar') end || ','
			|| case when var_old_ward_cde is null then 'null::varchar' else concat('''', var_old_ward_cde, '''::varchar') end || ','
			|| case when var_old_specialty is null then 'null::varchar' else concat('''', var_old_specialty, '''::varchar') end || ','
			|| case when var_old_bed_no is null then 'null::varchar' else concat('''', var_old_bed_no, '''::varchar') end || ','
			|| case when var_last_upd_by is null then 'null::varchar' else concat('''', var_last_upd_by, '''::varchar') end || ','
			|| case when var_update_hosp_cde is null then 'null::varchar' else concat('''', var_update_hosp_cde, '''::varchar') end || ','
			|| case when var_filler is null then 'null::varchar' else concat('''', var_filler, '''::varchar') end || ','
			|| case when var_dnl_pmi_access_code is null then 0 else var_dnl_pmi_access_code end || ','
			|| case when var_death_indicator is null then 'null::varchar' else concat('''', var_death_indicator, '''::varchar') end || ','
			|| case when var_death_date is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_death_date, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_transfer_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_transfer_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_discharge_dtm is null then 'null::TIMESTAMP WITHOUT TIME ZONE' else concat('''', var_discharge_dtm, '''::TIMESTAMP WITHOUT TIME ZONE') end || ','
			|| case when var_source_system is null then 'null::varchar' else concat('''', var_source_system, '''::varchar') end || ','
			|| case when var_pp_code is null then 'null::varchar' else concat('''', var_pp_code, '''::varchar') end || ','
			|| case when var_medical_record_number is null then 'null::varchar' else concat('''', var_medical_record_number, '''::varchar') end ||');';
			raise notice 'dblink_sql=%',dblink_sql;
--                CALL download.hkpmi_polling_to_cpi(var_dnl_hospital_code, var_tmp_system_datetime, var_poll_mode, var_retrieve_flag, var_download_system_datetime, var_type, var_admit_tran_dtm, var_hkid, var_prk_key, var_patient_nam, var_sex_cde, var_dob, var_exact_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_cde, var_race_code, var_other_doc_no, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_priority, var_major_nok, var_nok_nam, var_nok_hk_id, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, var_case_no, var_srce_ind, var_srce_code, var_patient_type_cde, var_discharge_cde, var_destination_cde, var_case_type, var_ward_cde, var_specialty, var_bed_no, var_ward_class, var_old_prk_key, var_old_patient_nam, var_old_hkid, var_old_sex, var_old_dob, var_old_ward_class, var_old_ward_cde, var_old_specialty, var_old_bed_no, var_last_upd_by, var_update_hosp_cde, var_filler, var_dnl_pmi_access_code, var_death_indicator, var_death_date, var_transfer_dtm, var_discharge_dtm, var_source_system, var_pp_code, var_medical_record_number);
             select * from public.dblink('tran_id'::text,dblink_sql::text)
			as t1(var_return_code int,
            var_retrieve_flag varchar,
			var_download_system_datetime varchar,
			var_type varchar,
			var_admit_tran_dtm varchar,
			var_hkid varchar,
			var_prk_key varchar,
			var_patient_nam varchar,
			var_sex_cde varchar,
			var_dob varchar,
			var_exact_dob varchar,
			var_ccc_1 varchar,
			var_ccc_2 varchar,
			var_ccc_3 varchar,
			var_ccc_4 varchar,
			var_ccc_5 varchar,
			var_ccc_6 varchar,
			var_chi_name varchar,
			var_marital_cde varchar,
			var_race_code varchar,
			var_other_doc_no varchar,
			var_building varchar,
			var_room varchar,
			var_floor varchar,
			var_block varchar,
			var_district_code varchar,
			var_religion_code varchar,
			var_home_phone varchar,
			var_other_phone_no_1 varchar,
			var_other_phone_ext_1 varchar,
			var_other_phone_no_2 varchar,
			var_other_phone_ext_2 varchar,
			var_priority varchar,
			var_major_nok varchar,
			var_nok_nam varchar,
			var_nok_hk_id varchar,
			var_nok_relationship varchar,
			var_nok_building varchar,
			var_nok_room varchar,
			var_nok_floor varchar,
			var_nok_block varchar,
			var_nok_district_code varchar,
			var_nok_home_phone varchar,
			var_nok_other_phone_no_1 varchar,
			var_nok_other_phone_ext_1 varchar,
			var_nok_other_phone_no_2 varchar,
			var_nok_other_phone_ext_2 varchar,
			var_case_no varchar,
			var_srce_ind varchar,
			var_srce_code varchar,
			var_patient_type_cde varchar,
			var_discharge_cde varchar,
			var_destination_cde varchar,
			var_case_type varchar,
			var_ward_cde varchar,
			var_specialty varchar,
			var_bed_no varchar,
			var_ward_class varchar,
			var_old_prk_key varchar,
			var_old_patient_nam varchar,
			var_old_hkid varchar,
			var_old_sex varchar,
			var_old_dob varchar,
			var_old_ward_class varchar,
			var_old_ward_cde varchar,
			var_old_specialty varchar,
			var_old_bed_no varchar,
			var_last_upd_by varchar,
			var_update_hosp_cde varchar,
			var_filler varchar,
			var_dnl_pmi_access_code varchar,
			var_death_indicator varchar,
			var_death_date varchar,
			var_transfer_dtm varchar,
			var_discharge_dtm varchar,
			var_source_system varchar,
			var_pp_code varchar,
			var_medical_record_number varchar)
			into var_return_code, var_retrieve_flag, var_download_system_datetime, var_type, var_admit_tran_dtm, var_hkid, var_prk_key, var_patient_nam, var_sex_cde, var_dob, var_exact_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_cde, var_race_code, var_other_doc_no, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_priority, var_major_nok, var_nok_nam, var_nok_hk_id, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, var_case_no, var_srce_ind, var_srce_code, var_patient_type_cde, var_discharge_cde, var_destination_cde, var_case_type, var_ward_cde, var_specialty, var_bed_no, var_ward_class, var_old_prk_key, var_old_patient_nam, var_old_hkid, var_old_sex, var_old_dob, var_old_ward_class, var_old_ward_cde, var_old_specialty, var_old_bed_no, var_last_upd_by, var_update_hosp_cde, var_filler, var_dnl_pmi_access_code, var_death_indicator, var_death_date, var_transfer_dtm, var_discharge_dtm, var_source_system, var_pp_code, var_medical_record_number;
            perform public.dblink_disconnect('tran_id'::text);
			raise notice 'var_prk_key=%',var_prk_key;
           exception
				when others then
				 		GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
				 		raise notice  'error_message%',error_message;
						perform public.dblink_disconnect('tran_id'::text);  
			end;
			
			IF var_return_code != 0 THEN
                    SELECT
                        'F'
                        INTO var_retrieve_flag;
                END IF;
                IF var_retrieve_flag != 'T' THEN
                    BEGIN
                        IF par_input_dnl_sys_dtm is NULL THEN
                            BEGIN
                                SELECT
                                    0
                                    INTO var_i;

                                WHILE (var_i < var_delay_time) AND EXISTS (SELECT
                                    *
                                    FROM download_control
                                    WHERE hospital_code = par_hospital_code AND download_enable = 'Y') loop
                                    SELECT
                                        var_i + 1
                                        INTO var_i;
                                END LOOP;
                            END;
                        ELSE
                            BEGIN
                                RAISE NOTICE 'Specific download record not found';
                            END;
                        END IF;
                    END;
                ELSE
                    begin
                        SELECT
                            SUBSTRING(var_filler, 1, 1)
                            INTO var_document_flag;

                        IF var_document_flag = '' THEN
                            SELECT
                                NULL
                                INTO var_document_flag;
                        END IF;
                        SELECT
                            SUBSTRING(var_filler, 2, 8)
                            INTO var_eh_code;

                        IF var_eh_code = '' THEN
                            SELECT
                                NULL
                                INTO var_eh_code;
                        END IF;
                        SELECT
                            SUBSTRING(var_filler, 30, 1)
                            INTO var_hkic_symbol; /* --hkic = transaction_log,filler(30,1) */

                        IF var_hkic_symbol = '' THEN
                            SELECT
                                NULL
                                INTO var_hkic_symbol;
                        END IF;
                        SELECT
                            var_ward_class
                            INTO var_hkic_symbol_clear; /* For 030 Txn Only */

                        IF LTRIM(RTRIM(var_hkic_symbol_clear)) = '' OR LTRIM(RTRIM(var_hkic_symbol_clear)) is NULL THEN
                            SELECT
                                'N'
                                INTO var_hkic_symbol_clear;
                        END IF;
                        SELECT
                            var_download_system_datetime
                            INTO var_system_datetime;

                        IF var_source_system = 'OPAS2' THEN
                            BEGIN
                                SELECT
                                    'OPAS'
                                    INTO var_source_system;
                            END;
                        END IF;
                        SELECT
                            CONCAT(RTRIM(var_update_hosp_cde), RTRIM(var_source_system))
                            INTO var_last_upd_by;

                        IF var_ccc_1 = REPEAT(' ', 1) THEN
                            SELECT
                                NULL
                                INTO var_ccc_1;
                        END IF;

                        IF var_ccc_2 = REPEAT(' ', 1) THEN
                            SELECT
                                NULL
                                INTO var_ccc_2;
                        END IF;

                        IF var_ccc_3 = REPEAT(' ', 1) THEN
                            SELECT
                                NULL
                                INTO var_ccc_3;
                        END IF;

                        IF var_ccc_4 = REPEAT(' ', 1) THEN
                            SELECT
                                NULL
                                INTO var_ccc_4;
                        END IF;

                        IF var_ccc_5 = REPEAT(' ', 1) THEN
                            SELECT
                                NULL
                                INTO var_ccc_5;
                        END IF;

                        IF var_ccc_6 = REPEAT(' ', 1) THEN
                            SELECT
                                NULL
                                INTO var_ccc_6;
                        END IF;
                        raise notice 'var_type=%',var_type;
                        IF (var_type = '030') OR /* demo update */ (var_type = '031') THEN /* change hkid */
                            BEGIN
                                SELECT
                                    patient_key
                                    INTO var_prk_key
                                    FROM cpi_patient
                                    WHERE hkid = var_old_hkid;
                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                IF (sql$rowcount = 0) THEN
                                    BEGIN
                                        SELECT
                                            7013
                                            INTO var_error_code;
                                        raise notice 'var_error_code=%',var_error_code;
                                        EXIT skip_records;
                                    END;
                                END IF;
                                SELECT
                                    reference, death_indicator, death_date, death_code, card_holder, access_code, security, update_dtm
                                    INTO var_reference, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_access_code, var_security, var_patient_last_update_dtm
                                    FROM cpi_patient
                                    WHERE patient_key = var_prk_key;
								
                                IF var_patient_last_update_dtm = var_system_datetime THEN
                                    BEGIN
                                        SELECT
                                            3 * INTERVAL '1 millisecond' + var_system_datetime::TIMESTAMP
                                            INTO var_system_datetime;
                                    END;
                                END IF;
                                /* select @medical_record_number = NULL */
                                SELECT
                                    NULL
                                    INTO var_remark;
                                SELECT
                                    priority
                                    INTO var_priority
                                    FROM cpi_nok
                                    WHERE patient_key = var_prk_key AND major_nok = 'Y';
                                /* Nok relationship does not allow NULL */
                                IF (var_nok_nam IS NOT NULL) AND (var_nok_relationship IS NULL) THEN
                                    SELECT
                                        'OT'
                                        INTO var_nok_relationship;
                                END IF;
                               raise notice 'call cpi_patient_update';
                                CALL cpi_patient_update(var_return_code, var_dnl_hospital_code, var_old_hkid, var_patient_nam, var_sex_cde, var_dob, var_exact_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_cde, var_race_code, var_other_doc_no, var_reference, var_medical_record_number, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_prk_key, var_priority, var_nok_nam, var_nok_hk_id, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, '030', var_access_code, var_security, var_system_datetime, var_update_hosp_cde, var_last_upd_by, NULL, 'DNL', var_document_flag, var_hkic_symbol, var_hkic_symbol_clear);
								

                                IF (var_return_code != 0) THEN
                                    BEGIN
                                        SELECT
                                            var_return_code
                                            INTO var_error_code;
                                        EXIT skip_records;
                                    END;
                                END IF;

                                IF (var_hkid != var_old_hkid) THEN
                                    BEGIN
                                        SELECT
                                            update_dtm
                                            INTO var_patient_last_update_dtm
                                            FROM cpi_patient
                                            WHERE patient_key = var_prk_key;
                                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                        IF (sql$rowcount = 0) THEN
                                            BEGIN
                                                SELECT
                                                    9001
                                                    INTO var_error_code;
                                                EXIT skip_records;
                                            END;
                                        END IF;
                                        raise notice 'call cpi_change_hkid';
                                        CALL cpi_change_hkid(var_return_code, var_dnl_hospital_code, var_old_hkid, var_prk_key, var_hkid, '031', var_system_datetime, var_last_upd_by, var_patient_last_update_dtm, 'DNL', var_update_hosp_cde);


                                        IF (var_return_code != 0) THEN
                                            BEGIN
                                                SELECT
                                                    var_return_code
                                                    INTO var_error_code;
                                                EXIT skip_records;
                                            END;
                                        END IF /* cpi_change_hkid */;
                                    END;
                                END IF /* @hkid != @new_hkid */;
                            END; /* record_type = '1' */
                        ELSE
                            IF var_type = '034' THEN /* upd confidentialty */
                                BEGIN
                                    SELECT
                                        patient_key, patient_name, sex, dob, access_code, update_dtm, update_hospital
                                        INTO var_prk_key, var_pmi_patient_name, var_pmi_sex, var_pmi_dob, var_pmi_access_code, var_patient_last_update_dtm, var_last_update_hospital
                                        FROM cpi_patient
                                        WHERE hkid = var_hkid;
                                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                    IF (sql$rowcount = 0) THEN
                                        BEGIN
                                            SELECT
                                                7013
                                                INTO var_error_code;
                                            EXIT skip_records;
                                        END;
                                    END IF;

                                    IF var_patient_last_update_dtm > var_system_datetime AND EXISTS (SELECT
                                        *
                                        FROM hospital
                                        WHERE hospital_code = var_last_update_hospital) THEN
                                        BEGIN
                                            SELECT
                                                7016
                                                INTO var_error_code;
                                            EXIT skip_records;
                                        END;
                                    END IF;
									raise notice 'var_patient_nam=%,var_pmi_patient_name=%,var_sex_cde=%,var_pmi_sex=%,var_dob=%,var_pmi_dob=%',var_patient_nam,var_pmi_patient_name,var_sex_cde,var_pmi_sex,var_dob,var_pmi_dob;
                                    IF var_patient_nam != var_pmi_patient_name OR var_sex_cde != var_pmi_sex OR var_dob != var_pmi_dob THEN
                                        BEGIN
                                            SELECT
                                                200003
                                                INTO var_error_code;
                                            EXIT skip_records;
                                        END;
                                    END IF;
                                   	raise notice 'call cpi_get_int_by_bin';
                                    /* patient is confidential */
                                    IF var_dnl_pmi_access_code & 1 = 0 THEN
                                        BEGIN
                                            /* get integer which bit 0,15,16,17 is off */
                                            CALL cpi_get_int_by_bin(pas_return_code, 'NYYYYYYYYYNNNYYNNNYYYYYYYYYYYYY', var_hex);
                                            SELECT
                                                var_pmi_access_code & var_hex
                                                INTO var_pmi_access_code;
                                        END;
                                    ELSE
                                        BEGIN
                                            /* get integer which bit 0,15,16,17 is on */
                                            CALL cpi_get_int_by_bin(pas_return_code, 'YNNNNNNNNNYYYNNYYYNNNNNNNNNNNNN', var_hex);
                                            SELECT
                                                var_pmi_access_code | var_hex
                                                INTO var_pmi_access_code;
                                        END;
                                    END IF;
                                    /* set bits (19 - 26) for OPAS from downloaded access code */
                                    CALL cpi_get_int_by_bin(pas_return_code, 'NNNNNNNNNNNNNNNNNNNYYYYYYYYNNNN', var_hex);
                                    SELECT
                                        var_dnl_pmi_access_code & var_hex
                                        INTO var_opas_access_code;
                                    /* turn off OPAS bits (19 to 26) from patient access code */
                                    CALL cpi_get_int_by_bin(pas_return_code, 'YYYYYYYYYYYYYYYYYYYNNNNNNNNYYYY', var_hex);
                                    SELECT
                                        var_pmi_access_code & var_hex
                                        INTO var_pmi_access_code;
                                    /* set donloaded OPAS bits (19 to 26) to patient access code */
                                    SELECT
                                        var_pmi_access_code | var_opas_access_code
                                        INTO var_pmi_access_code;
                                    /* patient has problem address */
                                    IF var_dnl_pmi_access_code & 2 = 0 THEN
                                        BEGIN
                                            /* get integer which bit 1 is off */
                                            CALL cpi_get_int_by_bin(pas_return_code, 'YNYYYYYYYYYYYYYYYYYYYYYYYYYYYYY', var_hex);
                                            SELECT
                                                var_pmi_access_code & var_hex
                                                INTO var_pmi_access_code;
                                        END;
                                    ELSE
                                        IF var_dnl_pmi_access_code & 2 = 2 THEN
                                            BEGIN
                                                /* get integer which bit 1 is on */
                                                CALL cpi_get_int_by_bin(pas_return_code, 'NYNNNNNNNNNNNNNNNNNNNNNNNNNNNNN', var_hex);
                                                SELECT
                                                    var_pmi_access_code | var_hex
                                                    INTO var_pmi_access_code;
                                            END;
                                        END IF;
                                    END IF;
                                   	raise notice 'call cpi_patient_upd_access';
                                    CALL cpi_patient_upd_access(var_return_code, var_dnl_hospital_code, var_hkid, var_prk_key, var_pmi_access_code, var_system_datetime, var_update_hosp_cde, var_last_upd_by, var_patient_last_update_dtm, 'DNL');

                                    IF (var_return_code != 0) THEN
                                        BEGIN
                                            SELECT
                                                var_return_code
                                                INTO var_error_code;
                                            EXIT skip_records;
                                        END;
                                    END IF;
                                END;
                            /* --- start added by WL on 4 May 2000--- */
                            ELSE
                                IF var_type = '250' THEN /* pmi deletion */
                                    BEGIN
                                        SELECT
                                            patient_key, patient_name, sex, dob, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, update_dtm, update_hospital
                                            INTO var_prk_key, var_pmi_patient_name, var_pmi_sex, var_pmi_dob, var_pmi_ccc1, var_pmi_ccc2, var_pmi_ccc3, var_pmi_ccc4, var_pmi_ccc5, var_pmi_ccc6, var_patient_last_update_dtm, var_last_update_hospital
                                            FROM cpi_patient
                                            WHERE hkid = var_hkid;
                                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                        IF (sql$rowcount = 0) THEN
                                            BEGIN
                                                SELECT
                                                    7013
                                                    INTO var_error_code;
                                                EXIT skip_records;
                                            END;
                                        END IF;

                                        IF var_patient_last_update_dtm > var_system_datetime AND EXISTS (SELECT
                                            *
                                            FROM hospital
                                            WHERE hospital_code = var_last_update_hospital) THEN
                                            BEGIN
                                                SELECT
                                                    7016
                                                    INTO var_error_code;
                                                EXIT skip_records;
                                            END;
                                        END IF;

                                        IF var_pmi_ccc1 = REPEAT(' ', 1) THEN
                                            SELECT
                                                NULL
                                                INTO var_pmi_ccc1;
                                        END IF;

                                        IF var_pmi_ccc2 = REPEAT(' ', 1) THEN
                                            SELECT
                                                NULL
                                                INTO var_pmi_ccc2;
                                        END IF;

                                        IF var_pmi_ccc3 = REPEAT(' ', 1) THEN
                                            SELECT
                                                NULL
                                                INTO var_pmi_ccc3;
                                        END IF;

                                        IF var_pmi_ccc4 = REPEAT(' ', 1) THEN
                                            SELECT
                                                NULL
                                                INTO var_pmi_ccc4;
                                        END IF;

                                        IF var_pmi_ccc5 = REPEAT(' ', 1) THEN
                                            SELECT
                                                NULL
                                                INTO var_pmi_ccc5;
                                        END IF;

                                        IF var_pmi_ccc6 = REPEAT(' ', 1) THEN
                                            SELECT
                                                NULL
                                                INTO var_pmi_ccc6;
                                        END IF;
									    raise notice 'var_sex_cde=%,var_pmi_sex=%',var_sex_cde,var_pmi_sex;
                                        IF var_patient_nam != var_pmi_patient_name OR var_sex_cde != var_pmi_sex OR var_dob != var_pmi_dob OR var_ccc_1 != var_pmi_ccc1 OR var_ccc_2 != var_pmi_ccc2 OR var_ccc_3 != var_pmi_ccc3 OR var_ccc_4 != var_pmi_ccc4 OR var_ccc_5 != var_pmi_ccc5 OR var_ccc_6 != var_pmi_ccc6 THEN
                                            BEGIN
                                                SELECT
                                                    200003
                                                    INTO var_error_code;
                                                EXIT skip_records;
                                            END;
                                        END IF;

                                        IF EXISTS (SELECT
                                            *
                                            FROM cpi_case
                                            WHERE patient_key = var_prk_key AND status_code <> 'CC') THEN
                                            BEGIN
                                                /* patient has cases, PMI deletion reject */
                                                SELECT
                                                    200029
                                                    INTO var_error_code;
                                                EXIT skip_records;
                                            END;
                                        END IF;
                                        raise notice 'call cpi_del_pmi';
                                        CALL cpi_del_pmi(var_return_code, var_hkid, var_dnl_hospital_code, var_patient_nam, var_sex_cde, var_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_exact_dob, var_prk_key, var_system_datetime, /* tx dtm */ var_last_upd_by, /* user id */ 'DNL', /* source system */ var_update_hosp_cde);


                                        IF (var_return_code != 0) THEN
                                            BEGIN
                                                SELECT
                                                    var_return_code
                                                    INTO var_error_code;
                                                EXIT skip_records;
                                            END;
                                        END IF;
                                    END;
                                /* --- end  added by WL on 4 May 2000 - */
                                ELSE
                                    IF var_type = '033' THEN /* update death indicator */
                                        BEGIN
                                            SELECT
                                                patient_key, patient_name, sex, dob, death_indicator, death_date, update_dtm, update_hospital
                                                INTO var_prk_key, var_pmi_patient_name, var_pmi_sex, var_pmi_dob, var_pmi_death_indicator, var_pmi_death_date, var_patient_last_update_dtm, var_last_update_hospital
                                                FROM cpi_patient
                                                WHERE hkid = var_hkid;
                                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                            IF (sql$rowcount = 0) THEN
                                                BEGIN
                                                    SELECT
                                                        7013
                                                        INTO var_error_code;
                                                    EXIT skip_records;
                                                END;
                                            END IF;

                                            IF var_patient_last_update_dtm > var_system_datetime AND EXISTS (SELECT
                                                *
                                                FROM hospital
                                                WHERE hospital_code = var_last_update_hospital) THEN
                                                BEGIN
                                                    SELECT
                                                        7016
                                                        INTO var_error_code;
                                                    EXIT skip_records;
                                                END;
                                            END IF;

                                            IF var_patient_nam != var_pmi_patient_name OR var_sex_cde != var_pmi_sex OR var_dob != var_pmi_dob THEN
                                                BEGIN
                                                    SELECT
                                                        200003
                                                        INTO var_error_code;
                                                    EXIT skip_records;
                                                END;
                                            END IF;
	 										raise notice 'var_pmi_death_date=%,var_death_date=%,var_pmi_death_indicator=%,var_death_indicator=%',var_pmi_death_date,var_death_date,var_pmi_death_indicator,var_death_indicator;
                                            IF coalesce(var_pmi_death_date,localtimestamp) = coalesce(var_death_date,localtimestamp) AND var_pmi_death_indicator = var_death_indicator THEN
                                                BEGIN
                                                    SELECT
                                                        6009
                                                        INTO var_error_code;
                                                    EXIT skip_records;
                                                END;
                                            END IF;
                                            raise notice 'call cpi_patient_upd_death';
                                      
                                            CALL cpi_patient_upd_death(var_return_code,  var_dnl_hospital_code, var_hkid, var_prk_key, var_death_date, var_death_indicator, var_system_datetime, var_update_hosp_cde, var_last_upd_by, var_patient_last_update_dtm,'DNL','P', null);


                                            IF (var_return_code != 0) THEN
                                                BEGIN
                                                    SELECT
                                                        var_return_code
                                                        INTO var_error_code;
                                                    EXIT skip_records;
                                                END;
                                            END IF;
                                        END;
                                    ELSE
                                        IF var_type = '100' AND var_source_system = 'OPAS' THEN
                                            BEGIN
                                                SELECT
                                                    reference, remark, death_code, card_holder, security, p.update_dtm
                                                    INTO var_reference, var_remark, var_death_code, var_card_holder, var_security, var_patient_last_update_dtm
                                                    FROM cpi_patient AS p, cpi_patient_hospital_data AS h
                                                    WHERE p.patient_key = var_prk_key AND p.patient_key = h.patient_key;
                                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                IF sql$rowcount <> 1 THEN
                                                    BEGIN
                                                        SELECT
                                                            reference, remark, death_code, card_holder, security, p.update_dtm
                                                            INTO var_reference, var_remark, var_death_code, var_card_holder, var_security, var_patient_last_update_dtm
                                                            FROM cpi_patient AS p, cpi_patient_hospital_data AS h
                                                            WHERE hkid = var_hkid AND p.patient_key = h.patient_key;
                                                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                                                        IF sql$rowcount <> 1 THEN
                                                            SELECT
                                                                NULL, NULL, NULL, 0, 0, var_system_datetime
                                                                INTO var_reference, var_remark, var_death_code, var_card_holder, var_security, var_patient_last_update_dtm;
                                                        END IF;
                                                    END;
                                                END IF;
                                                raise notice 'call cpi_admission';
                                                CALL cpi_admission( var_return_code,var_dnl_hospital_code, var_case_no, var_hkid, var_patient_nam, var_sex_cde, var_dob, var_exact_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_cde, var_race_code, var_other_doc_no, var_reference, var_medical_record_number, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, 0, var_dnl_pmi_access_code, var_security, var_prk_key, var_priority, var_nok_nam, var_nok_hk_id, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, var_admit_tran_dtm, var_srce_ind, var_srce_code, var_patient_type_cde, var_discharge_cde, var_discharge_dtm, var_destination_cde, NULL, NULL, NULL, NULL, NULL, NULL, var_ward_cde, var_specialty, NULL, var_bed_no, var_ward_class, var_pp_code, var_case_type, var_type, var_system_datetime, var_last_upd_by, var_patient_last_update_dtm, 'DNL', var_document_flag, var_eh_code, NULL, /* @source_hosp_cod */ NULL, /* @source_case_no */ var_hkic_symbol);

												raise notice 'cpi_admission var_return_code=%',var_return_code;
                                                IF (var_return_code != 0) THEN
                                                    BEGIN
                                                        SELECT
                                                            var_return_code
                                                            INTO var_error_code;
                                                        EXIT skip_records;
                                                    END;
                                                END IF;
                                            END;
                                        ELSE
                                            IF var_type = '200' AND var_source_system = 'OPAS' THEN
                                                begin
	                                                raise notice 'call cpi_cancel_admission';
                                                    CALL cpi_cancel_admission( var_return_code,var_dnl_hospital_code, var_case_no, var_hkid, var_ward_cde, var_ward_class, var_bed_no, var_specialty, NULL, var_case_type, var_type, var_system_datetime, var_last_upd_by, 'DNL');

                                                    IF (var_return_code != 0) THEN
                                                        BEGIN
                                                            SELECT
                                                                var_return_code
                                                                INTO var_error_code;
                                                            EXIT skip_records;
                                                        END;
                                                    END IF;
                                                END;
                                            ELSE
                                                IF var_type LIKE '13%' AND var_source_system = 'OPAS' THEN
                                                    begin
	                                                    raise notice 'call cpi_discharge';
                                                        CALL cpi_discharge( var_return_code, var_dnl_hospital_code, var_case_no, var_hkid, var_discharge_cde, var_discharge_dtm, var_destination_cde, var_ward_cde, var_ward_class, var_bed_no, var_specialty, NULL, NULL, var_case_type, var_type, var_system_datetime, var_last_upd_by, 'DNL', NULL,NULL ,NULL);

                                                        IF (var_return_code != 0) THEN
                                                            BEGIN
                                                                SELECT
                                                                    var_return_code
                                                                    INTO var_error_code;
                                                                EXIT skip_records;
                                                            END;
                                                        END IF;
                                                    END;
                                                ELSE
                                                    IF var_type LIKE '21%' AND var_source_system = 'OPAS' THEN
                                                        begin
	                                                        raise notice 'call cpi_cancel_discharge';
                                                            CALL cpi_cancel_discharge( var_return_code, var_dnl_hospital_code, var_case_no, var_hkid, var_ward_cde, var_ward_class, var_bed_no, var_specialty, NULL, NULL, var_case_type, var_type, var_system_datetime, var_last_upd_by, 'DNL');


                                                            IF (var_return_code != 0) THEN
                                                                BEGIN
                                                                    SELECT
                                                                        var_return_code
                                                                        INTO var_error_code;
                                                                    EXIT skip_records;
                                                                END;
                                                            END IF;
                                                        END;
                                                    ELSE
                                                        IF var_type IN ('121', '341') AND var_source_system IN ('OPAS', 'PBRC') THEN
                                                            begin
	                                                            raise notice 'call cpi_update_adm_registration';
                                                                CALL cpi_update_adm_registration( var_return_code, var_dnl_hospital_code, var_case_no, var_hkid, var_admit_tran_dtm, var_srce_ind, var_srce_code, var_patient_type_cde, var_discharge_cde, var_discharge_dtm, var_destination_cde, NULL, NULL, NULL, NULL, NULL, NULL, var_ward_cde, var_ward_class, var_bed_no, var_specialty, NULL, var_pp_code, var_case_type, var_type, 'P', var_system_datetime, var_last_upd_by, 'DNL', var_document_flag, var_eh_code,null,null);

                                                                IF (var_return_code != 0) THEN
                                                                    BEGIN
                                                                        SELECT
                                                                            var_return_code
                                                                            INTO var_error_code;
                                                                        EXIT skip_records;
                                                                    END;
                                                                END IF;
                                                            END;
                                                        else
                                                        
                                                            IF var_type = '010' AND var_source_system = 'OPAS' THEN
                                                                BEGIN
                                                                    SELECT
                                                                        NULL, NULL, NULL, 0, 0
                                                                        INTO var_reference, var_remark, var_death_code, var_card_holder, var_security;
                                                                    	raise notice 'call cpi_insert_new_patient';
                                                                       CALL cpi_insert_new_patient( var_return_code,var_dnl_hospital_code, var_hkid, var_patient_nam, var_sex_cde, var_dob, var_exact_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_cde, var_race_code, var_other_doc_no, var_reference, var_medical_record_number, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_prk_key, var_priority, var_nok_nam, var_nok_hk_id, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, var_type, var_dnl_pmi_access_code, var_security, var_system_datetime, var_dnl_hospital_code, var_last_upd_by, NULL, 'DNL', var_hkic_symbol);

                                                                    IF (var_return_code != 0) THEN
                                                                        BEGIN
                                                                            SELECT
                                                                                var_return_code
                                                                                INTO var_error_code;
                                                                            EXIT skip_records;
                                                                        END;
                                                                    END IF;
                                                                END;
                                                            ELSE
                                                                IF var_type = '040' AND var_source_system = 'OPAS' THEN
                                                                    begin
	                                                                    raise notice 'call cpi_move_episodes';
                                                                        CALL cpi_move_episodes( var_return_code, var_dnl_hospital_code, var_case_no, var_old_hkid, var_old_prk_key, var_hkid, var_prk_key, var_case_type, var_type, var_system_datetime, var_last_upd_by, 'DNL',null,null,null,null);
																		raise notice 'var_return_code=%',var_return_code;
                                                                        IF (var_return_code != 0) THEN
                                                                            BEGIN
                                                                                SELECT
                                                                                    var_return_code
                                                                                    INTO var_error_code;
                                                                                EXIT skip_records;
                                                                            END;
                                                                        END IF;
                                                                    END;
                                                                else
                                                                	
                                                                    /* ----if @type = '020'  and @source_system = 'OPAS' */
                                                                    IF var_type = '020' AND (var_source_system = 'OPAS' OR var_source_system = 'ADT') THEN
                                                                        BEGIN
                                                                            /* --------- Begin of 20051102 --------- */
                                                                            /* ---print 'Type : = %1!, HKID = %2!, LUD = %3! ,OLD_HKID=%4! ', @type, @hkid, @download_system_datetime,@old_hkid */
                                                                            IF EXISTS (SELECT
                                                                                *
                                                                                FROM cpi_patient
                                                                                WHERE hkid = var_old_hkid) then
                                                                            
                                                                                BEGIN
                                                                                    IF NOT EXISTS (SELECT
                                                                                        *
                                                                                        FROM cpi_patient
                                                                                        WHERE hkid = var_hkid) then
                                                                                        /* --- >031=>032 >030 -- */
                                                                                        BEGIN
                                                                                            /* ----  '031' @from_hkid to @to_hkid  ---- */
                                                                                            SELECT
                                                                                                update_dtm
                                                                                                INTO var_patient_last_update_dtm
                                                                                                FROM cpi_patient
                                                                                                WHERE patient_key = var_old_prk_key;
                                 															raise notice 'call cpi_change_hkid';
                                                                                            
                                                                                            CALL cpi_change_hkid( var_return_code,var_dnl_hospital_code, var_old_hkid, /* ----@from_hkid */ var_old_prk_key, var_hkid, /* ---@to_hkid */ '031', var_system_datetime, /* ----cpi_trasaction.transaction_datetime */ var_last_upd_by, var_patient_last_update_dtm, 'DNL', var_update_hosp_cde);
                                                                                            raise notice  'line->var_return_code%',var_return_code;
                                                                                           IF (var_return_code != 0) THEN
                                                                                                BEGIN
                                                                                                    SELECT
                                                                                                        var_return_code
                                                                                                        INTO var_error_code;
                                                                                                    RAISE NOTICE 'error 031: % % % % %', var_old_hkid, var_old_prk_key, var_hkid, var_prk_key, var_patient_last_update_dtm;
                                                                                                    EXIT skip_records;
                                                                                                END;
                                                                                            END IF; /* cpi_change_hkid */
                                                                                            raise notice 'call cpi_check_patient_key';
                                                                                            CALL cpi_check_patient_key( var_return_code, var_dnl_hospital_code, '020', var_system_datetime, 'DNL', var_hkid, var_old_prk_key, var_prk_key, var_dnl_pmi_access_code);
                                                                                            

                                                                                            IF (var_return_code != 0) THEN
                                                                                                BEGIN
                                                                                                    SELECT
                                                                                                        var_return_code
                                                                                                        INTO var_error_code;
                                                                                                    RAISE NOTICE 'error 032: % % % % %', var_old_hkid, var_old_prk_key, var_hkid, var_prk_key, var_patient_last_update_dtm;
                                                                                                    EXIT skip_records;
                                                                                                END;
                                                                                            END IF;
                                                                                            /* ---- 030 upd new @to_hkd's demo --- */
                                                                                            SELECT
                                                                                                reference, death_code, card_holder, access_code, security, update_dtm
                                                                                                INTO var_reference, var_death_code, var_card_holder, var_access_code, var_security, var_patient_last_update_dtm
                                                                                                FROM cpi_patient
                                                                                                WHERE patient_key = var_prk_key;
                                                                                            /* Nok relationship does not allow NULL */
                                                                                            IF (var_nok_nam IS NOT NULL) AND (var_nok_relationship IS NULL) THEN
                                                                                                SELECT
                                                                                                    'OT'
                                                                                                    INTO var_nok_relationship;
                                                                                            END IF;
																							raise notice 'call cpi_patient_update';				
                                                                                            CALL cpi_patient_update(var_return_code,var_dnl_hospital_code, var_hkid, /* ---@to_hkid */ var_patient_nam, var_sex_cde, var_dob, var_exact_dob, var_ccc_1, var_ccc_2, var_ccc_3, var_ccc_4, var_ccc_5, var_ccc_6, var_chi_name, var_marital_cde, var_race_code, var_other_doc_no, var_reference, var_medical_record_number, var_remark, var_building, var_room, var_floor, var_block, var_district_code, var_religion_code, var_home_phone, var_other_phone_no_1, var_other_phone_ext_1, var_other_phone_no_2, var_other_phone_ext_2, var_death_indicator, var_death_date, var_death_code, var_card_holder, var_prk_key, /* ---@to_hkid prk -- */ var_priority, var_nok_nam, var_nok_hk_id, var_nok_relationship, var_nok_building, var_nok_room, var_nok_floor, var_nok_block, var_nok_district_code, var_nok_home_phone, var_nok_other_phone_no_1, var_nok_other_phone_ext_1, var_nok_other_phone_no_2, var_nok_other_phone_ext_2, '030', var_access_code, var_security, var_system_datetime, var_update_hosp_cde, var_last_upd_by, NULL, 'DNL', var_document_flag, var_hkic_symbol, var_hkic_symbol_clear );
                                                                                       
                                                                                            IF (var_return_code != 0) THEN
                                                                                                BEGIN
                                                                                                    SELECT
                                                                                                        var_return_code
                                                                                                        INTO var_error_code;
                                                                                                    RAISE NOTICE 'error 030: % % % % %', var_old_hkid, var_old_prk_key, var_hkid, var_prk_key, var_patient_last_update_dtm;
                                                                                                    EXIT skip_records;
                                                                                                END;
                                                                                            END IF;
                                                                                        END;
                                                                                    /* --------- End of 20051102 --------- */
                                                                                    ELSE
                                                                                        begin
	                                                                                        raise notice 'call cpi_patient_merge';	
                                                                                            /* --- call '020' if both @from_hkid & @to_hkid found --- */
                                                                                            CALL cpi_patient_merge( var_return_code, var_old_hkid, var_hkid, var_last_upd_by, 'DNL', var_system_datetime, var_dnl_hospital_code, var_type, var_update_hosp_cde);
                                                                                            /* ---20060410 */
																							raise notice 'var_return_code=%',var_return_code;			
                                                                                            IF (var_return_code != 0) THEN
                                                                                                BEGIN
                                                                                                    SELECT
                                                                                                        var_return_code
                                                                                                        INTO var_error_code;
                                                                                                    EXIT skip_records;
                                                                                                END;
                                                                                            END IF;
                                                                                        END;
                                                                                    END IF;
                                                                                END;
                                                                            END IF /* ----if  exists (select * from cpi_patient where hkid = @old_hkid) */;
                                                                        END; /* ----if @type = '020'  and @source_system = 'OPAS' */
                                                                    ELSE
                                                                        BEGIN
                                                                            SELECT
                                                                                200021
                                                                                INTO var_error_code;
                                                                            EXIT skip_records;
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
                    END;
                END IF; /* @return_code != 0 or @retrieve_flag != 'T' */
            END;
            
            raise notice '1var_error_code=%',var_error_code;
            IF var_error_code is not NULL THEN
                BEGIN
                    RAISE NOTICE 'error code : %', var_error_code;
                    RAISE NOTICE 'Type : = %, HKID = %, LUD = % - Fail!', var_type, var_hkid, var_download_system_datetime;
                    --rollback;
                    raise exception '';
                    SELECT
                        messages
                        INTO var_error_msg
                        FROM error_msgs
                        WHERE error_code = var_error_code;
                    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                    IF sql$rowcount = 0 THEN
                        SELECT
                            'Fail to retrieve error message from exception table!'
                            INTO var_error_msg;
                    END IF;

                    IF NOT EXISTS (SELECT
                        *
                        FROM dnl_exception
                        WHERE hospital_code = var_dnl_hospital_code AND download_system_datetime = var_download_system_datetime) THEN
                        begin
	                        raise notice 'var_prk_key=%',var_prk_key;
                            INSERT INTO dnl_exception (hospital_code, download_key, patient_key, hkid, error_code, error_msg, update_hospital, update_by, update_dtm, download_system_datetime)
                            VALUES (var_dnl_hospital_code, '', var_prk_key, var_hkid, var_error_code, var_error_msg, var_update_hosp_cde, var_last_upd_by, timestamp_convert(localtimestamp), var_download_system_datetime);
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        RAISE NOTICE 'Fail to insert record into dnl_exception table!';
                                        EXIT error_return;
                            
                                
                            
                        END;
                    ELSE
                        BEGIN
                            RAISE NOTICE 'This download trx already exists in dnl_excpetion!';
                        END;
                    END IF;
                    SELECT
                        NULL
                        INTO var_error_code;
                END; /* error code is null */
            ELSE
                IF var_return_code = 0 AND var_retrieve_flag = 'T' THEN
                    BEGIN
                        RAISE NOTICE 'Type : = %, HKID = %, LUD = % - Success!', var_type, var_hkid, var_download_system_datetime;
                    END;
                END IF;
            END IF;
            IF var_retrieve_flag = 'T' THEN
                BEGIN
                    IF par_input_dnl_sys_dtm is NULL THEN
                        BEGIN
                            begin
                                UPDATE download_control
                                SET last_download_system_datetime = var_download_system_datetime,
                                /* system_datetime = getdate() */
                                download_last_datetime = timestamp_convert(localtimestamp)
                                    WHERE hospital_code = var_dnl_hospital_code AND last_download_system_datetime = var_last_download_system_datetime;
                                var_error := 0;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        var_error := 1;
                            END;
                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_rowcount := sql$rowcount;

                            IF var_error != 0 THEN
                                BEGIN
                                    RAISE NOTICE 'Fail to update download_control table! %', var_error;
                                    EXIT error_return;
                                END;
                            END IF;

                            IF var_rowcount != 1 THEN
                                BEGIN
                                    RAISE NOTICE 'download_control has no row or row is updated by other process!';
                                    EXIT error_return;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            END IF;
 
 			
            IF par_input_dnl_sys_dtm is NULL THEN
                BEGIN
                    SELECT
                        download_enable, last_download_system_datetime
                        INTO var_download_enable, var_last_download_system_datetime
                        FROM download_control;
                END;
               
            ELSE
                SELECT
                    'N'
                    INTO var_download_enable;
            END IF;
            /* ----20140224 : clearing Variable before calling for Next Records  -- */
            SELECT
                NULL, NULL, NULL, NULL
                INTO var_retrieve_flag, var_type, var_hkid, var_prk_key;
        END LOOP; /* (@download_enable = 'Y') */
        /*
        select @cnt = count(*)
              from download_hkpmi_control
              where download_enable = "Y"
        
           if (@cnt = 0)
              select @stop_download = "Y"
        
           select @i = 0
        
           while @i < @delay_time
           begin
              waitfor delay "00:00:01"
              select @i = @i + 1
           end
           select @download_enable = 'Y'
        
        end /* (@stop_download = "N") */
        */
        pas_return_code := 0;
        SELECT clock_timestamp() into end_date;
		RAISE NOTICE 'insert download_log_test';
		insert into download_log_test (input_dnl_sys_dtm, start_time, end_time, duration, return_code)
		values (par_input_dnl_sys_dtm, start_date, end_date, EXTRACT(EPOCH FROM (end_date - start_date)) * 1000, pas_return_code);
        RETURN;
    END;
    --ROLLBACK;
    raise exception '';
SELECT clock_timestamp() into end_date;
RAISE NOTICE 'insert download_log_test';
insert into download_log_test (input_dnl_sys_dtm, start_time, end_time, duration, return_code)
values (par_input_dnl_sys_dtm, start_date, end_date, EXTRACT(EPOCH FROM (end_date - start_date)) * 1000, pas_return_code);
END; /* end of procedure */
/* --go */
$procedure$
;

;ALTER PROCEDURE "cpi_download" OWNER TO "HPI_SCHEMA_OWNER_ROLE";