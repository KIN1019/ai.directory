-- DROP PROCEDURE hpi.hasp_admission_woresult(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_admission_woresult(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_transaction_type character varying, IN par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_phone1 character varying, IN par_phone2 character varying, IN par_address_indicator character varying, IN par_mobile_phone character varying, IN par_sms_language character varying, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_phone1 character varying, IN par_nok_phone2 character varying, IN par_nok_address_indicator character varying, IN par_nok_mobile_phone character varying, IN par_nok_sms_language character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_t_prk character varying, IN par_case_no character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_pay_code character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_case_type character varying, IN par_movement_count integer, IN par_security_count integer, IN par_case_access_code integer, IN par_pmi_access_code integer, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_bed_no character varying, IN par_ward_class character varying, IN par_user_id character varying, IN par_pp_code character varying, IN par_last_system_datetime timestamp without time zone, IN par_last_updated_by character varying, IN par_terminal_id character varying, IN par_eh_code character varying DEFAULT NULL::bpchar, IN par_document_flag character varying DEFAULT NULL::bpchar, IN par_source_hosp_code character varying DEFAULT NULL::bpchar, IN par_source_case_no character varying DEFAULT NULL::bpchar, IN par_hkic_symbol character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
/* -- add hosp_code as input parm for HPI by WL on 27 July 1999 -- */
DECLARE
    var_priority INTEGER;
    var_retcode INTEGER;
    var_rowcount INTEGER;
    var_error INTEGER;
    var_error_msg VARCHAR(255);
    /* -- Remarked by WL on 27 July 1999, because it is -- */
    /* -- input parm --- */
    
    /* --@hosp_code				char(03), */
    var_cpi_flag VARCHAR(01);
    var_active_indicator VARCHAR(01);
    var_movement_type VARCHAR(01);
    var_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_ops_security INTEGER;
    var_treatment_location VARCHAR(04);
    var_prev_case VARCHAR(12);
    var_nb_hkid VARCHAR(12);
    var_birth_order INTEGER;
    var_preg_no INTEGER;
    var_chi_name CHAR varying;
    var_reference VARCHAR(20);
    var_remark VARCHAR(255);
    var_death_code VARCHAR(04);
    var_card_holder INTEGER;
    var_sub_specialty VARCHAR(04);
    var_eis_code VARCHAR(3);
    sql$rowcount BIGINT;
    "var_yrDiff" INTEGER;
    "var_monDiff" INTEGER;
	gjp_text text;
    nb_csr CURSOR FOR
    SELECT
        new_born_hkid, birth_order, pregnancy_number
        FROM new_born
        WHERE mother_hkid = par_hkid AND hospital_code = par_hosp_code AND mother_case_no = var_prev_case;
    -- cpi_update_new_born$refcur_1 refcursor;
    -- cpi_update_new_born$refcur_2 refcursor;
BEGIN
    <<error>>
    BEGIN
        /* variable declared for cpi */
        /* -- Remarked by WL on 27 July 1999 because it is input parm -- */
        
        /* Get hospital code */
        
        /*
        select @hosp_code = Hospital_code from Hospital
        select @rowcount = @@rowcount, @error = @@error
        if @error != 0
        begin
        	select @retcode = @error
        	goto error
        end
        if @rowcount != 1
        begin
        	select @retcode = 200016
        	raiserror @retcode
        	goto error
        end
        */
        /* --- add hosp_code by WL on 27 July 1999 for HPI--- */
        
        /* Get cpi flag */
        SELECT
            Text_value
            INTO var_cpi_flag
            FROM Hospital_control
            WHERE Type = 'cpi_server' AND Hospital_code = par_hosp_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
raise notice '[hasp_admission_woresult:85]';
        IF var_error != 0 THEN
            BEGIN
                SELECT
                    var_error
                    INTO var_retcode;
                EXIT error;
            END;
        END IF;
raise notice '[hasp_admission_woresult:94]';
        IF var_rowcount != 1 THEN
            BEGIN
                SELECT
                    200026
                    INTO var_retcode;
                RAISE EXCEPTION '% ', 'Invalid stored procedure for cpi server';
                EXIT error;
            END;
        END IF;
       raise notice '[hasp_admission_woresult:104]par_nok_name=>%,par_transaction_type=>%',par_nok_name,par_transaction_type;
        /* YL PasCr-2018/00113: To raise error if nok_name is invalid */
        IF par_nok_name IS NOT NULL AND par_transaction_type IN ('100', '300') THEN
            BEGIN
                IF par_nok_name NOT SIMILAR TO '[A-Z]%,%' then
                    raise notice '[hasp_admission_woresult:109]';
                    BEGIN
                        SELECT
                            299999
                            INTO var_retcode;
                        SELECT
                            'Invalid major contact person name, first varchar should be an alphabet'
                            INTO var_error_msg;
                        RAISE EXCEPTION '% ', var_error_msg ;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
       raise notice '[hasp_admission_woresult:122]';
        /* 20200616/JL/ to prevent pseudo ID patient with age > 11 register with paycode EP1 - START */
        IF SUBSTRING(par_hkid, 1, 1) = 'U' AND par_transaction_type IN ('100', '300') AND (par_other_document_no = '' OR par_other_document_no is NULL) AND par_pay_code = 'EP1' AND par_document_flag != 'F' THEN
            BEGIN
                SELECT
                    date_part('year', localtimestamp::TIMESTAMP) - date_part('year', par_dob::TIMESTAMP)
                    INTO "var_yrDiff";
                SELECT
                    date_part('month', localtimestamp::TIMESTAMP) - date_part('month', par_dob::TIMESTAMP)
                    INTO "var_monDiff";

                IF date_part('day', localtimestamp::DATE) - date_part('day', par_dob::DATE) < 0 THEN
                    SELECT
                        "var_monDiff" - 1
                        INTO "var_monDiff";
                END IF;

                IF "var_monDiff" < 0 THEN
                    SELECT
                        "var_yrDiff" - 1
                        INTO "var_yrDiff";
                END IF;
				raise notice '[hasp_admission_woresult:148]par_dob=>%,var_yrDiff=>%',par_dob,"var_yrDiff";
                IF par_dob is NULL OR "var_yrDiff" > 11 THEN
                    begin
	                    raise notice '[hasp_admission_woresult:148]';
                        SELECT
                            299999
                            INTO var_retcode;
                        SELECT
                            'Patient with Pseudo HKID, age > 11 and without other documents must not have pay code EP1'
                            INTO var_error_msg;
                        RAISE EXCEPTION '% ', var_error_msg ;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
       raise notice '[hasp_admission_woresult:159]';
        /* 20200616/JL/ to prevent pseudo ID patient with age > 11 register with paycode EP1 - END */
        IF par_transaction_type = '100' THEN
            BEGIN
                SELECT
                    IMIS_code
                    INTO var_eis_code
                    FROM (SELECT
                        IMIS_code, Specialty_code, Effective_date, Active_status
                        FROM Specialty) AS ungrouped_query
                    INNER JOIN (SELECT
                        Specialty_code, MAX(Effective_date) AS max_1
                        FROM Specialty
                        WHERE Specialty_code = par_specialty_code AND Effective_date <= par_admission_datetime
                        GROUP BY Specialty_code) AS grouped_query
                        ON (ungrouped_query.Specialty_code = grouped_query.Specialty_code OR (ungrouped_query.Specialty_code IS NULL AND grouped_query.Specialty_code IS NULL))
                    WHERE Effective_date = max_1 AND Active_status = 'A';
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;
raise notice '[hasp_admission_woresult:185]var_error:%,var_rowcount:%',var_error,var_rowcount;
                IF var_error != 0 OR var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            200026
                            INTO var_retcode;
                        /* YL PasCr-2016/00191 */
                        RAISE EXCEPTION '% ', 'Invalid/Inactive specialty code is selected!' ;
                        EXIT error;
                    END;
                END IF;
raise notice '[hasp_admission_woresult:196]par_admission_datetime=>%',par_admission_datetime;
                IF par_admission_datetime > '20161101' THEN
                    BEGIN
                        IF var_eis_code = 'MIX' THEN
                            BEGIN
                                SELECT
                                    299999
                                    INTO var_retcode;
                                    raise notice '[hasp_admission_woresult:203]';
                                SELECT
                                    'Patient admission to EIS MIX specialty is not allowed'
                                    INTO var_error_msg;
                                RAISE EXCEPTION '% ', var_error_msg ;
                                EXIT error;
                            END;
                        END IF;

                        IF var_eis_code = 'SKD' AND par_hosp_code NOT IN ('PYN', 'QEH', 'PWH') THEN
                            BEGIN
                                SELECT
                                    299999
                                    INTO var_retcode;
                                   raise notice '[hasp_admission_woresult:217]';
                                SELECT
                                    'Patient admission to EIS SKD specialty is not allowed'
                                    INTO var_error_msg;
                                RAISE EXCEPTION '% ', var_error_msg ;
                                EXIT error;
                            END;
                        END IF;

                        IF var_eis_code = 'OTH' AND par_hosp_code NOT IN ('PWH', 'OLM', 'PYN') AND par_specialty_code != 'DUMM' THEN
                            BEGIN
                                SELECT
                                    299999
                                    INTO var_retcode;
                                   raise notice '[hasp_admission_woresult:231]';
                                SELECT
                                    'Patient admission to EIS OTH specialty is not allowed'
                                    INTO var_error_msg;
                                RAISE EXCEPTION '% ', var_error_msg ;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF par_transaction_type = '300' THEN
            SELECT
                'A'
                INTO par_case_type;
        ELSE
            SELECT
                'I'
                INTO par_case_type;
        END IF;
        /* -- Remove cpi.. by WL on 27 July 1999 for HPI --- */
        SELECT
            chi_name, reference, death_code, card_holder, security
            INTO var_chi_name, var_reference, var_death_code, var_card_holder, var_ops_security
            /* --from cpi..cpi_patient */
            FROM cpi_patient
            WHERE hkid = par_hkid;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;
raise notice '[hasp_admission_woresult:268]var_error=>%',var_error;
        IF var_error != 0 THEN
            BEGIN
                EXIT error;
            END;
        END IF;
        /* -- Remove cpi.. by WL on 27 July 1999 for HPI --- */
        
        /* --exec @retcode = cpi..cpi_admission */
		var_priority := 1;
	    -- gjp_text := '[' || coalesce(par_hosp_code,'NULL-par_hosp_code') || '#@#' || coalesce(par_case_no,'NULL-par_case_no') || '#@#' || coalesce(par_hkid,'NULL-par_hkid') || '#@#' || coalesce(par_name,'NULL-par_name') || '#@#' || coalesce(par_sex,'NULL-par_sex') || '#@#' || to_char(coalesce(par_dob,current_timestamp), 'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_exact_dob_flag,'NULL-par_exact_dob_flag') || '#@#' || coalesce(par_ccc1,'NULL-par_ccc1') || '#@#' || coalesce(par_ccc2,'NULL-par_ccc2') || '#@#' || coalesce(par_ccc3,'NULL-par_ccc3') || '#@#' || coalesce(par_ccc4,'NULL-par_ccc4') || '#@#' || coalesce(par_ccc5,'NULL-par_ccc5') || '#@#' || coalesce(par_ccc6,'NULL-par_ccc6') || '#@#' || coalesce(var_chi_name,'NULL-var_chi_name') || '#@#' || coalesce(par_marital_status,'NULL-par_marital_status') || '#@#' || coalesce(par_race_code,'NULL-par_race_code') || '#@#' || coalesce(par_other_document_no,'NULL-par_other_document_no') || '#@#' || coalesce(var_reference,'NULL-var_reference') || '#@#' || coalesce(par_medical_record_number,'NULL-par_medical_record_number') || '#@#' || coalesce(var_remark,'NULL-var_remark') || '#@#' || coalesce(par_building,'NULL-par_building') || '#@#' || coalesce(par_room,'NULL-par_room') || '#@#' || coalesce(par_floor,'NULL-par_floor') || '#@#' || coalesce(par_block,'NULL-par_block') || '#@#' || coalesce(par_district_code,'NULL-par_district_code') || '#@#' || coalesce(par_religion_code,'NULL-par_religion_code') || '#@#' || coalesce(par_phone1,'NULL-par_phone1') || '#@#' || coalesce(par_phone2,'NULL-par_phone2') || '#@#' || coalesce(par_address_indicator,'NULL-par_address_indicator') || '#@#' || coalesce(par_mobile_phone,'NULL-par_mobile_phone') || '#@#' || coalesce(par_sms_language,'NULL-par_sms_language') || '#@#' || coalesce(par_death_indicator,'NULL-par_death_indicator') || '#@#' || to_char(coalesce(par_death_date,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(var_death_code,'NULL-var_death_code') || '#@#' || coalesce(var_card_holder::text,'null-var_card_holder') || '#@#' || coalesce(par_case_access_code::text,'null-par_case_access_code') || '#@#' || coalesce(par_pmi_access_code::text,'null-par_pmi_access_code') || '#@#' || coalesce(var_ops_security::text,'null-var_ops_security') || '#@#' || coalesce(par_t_prk,'NULL-par_t_prk') || '#@#' || coalesce(var_priority::text,'null-var_priority') || '#@#' || coalesce(par_nok_name,'NULL-par_nok_name') || '#@#' || coalesce(par_nok_hkid,'NULL-par_nok_hkid') || '#@#' || coalesce(par_nok_relation_code,'NULL-par_nok_relation_code') || '#@#' || coalesce(par_nok_building,'NULL-par_nok_building') || '#@#' || coalesce(par_nok_room,'NULL-par_nok_room') || '#@#' || coalesce(par_nok_floor,'NULL-par_nok_floor') || '#@#' || coalesce(par_nok_block,'NULL-par_nok_block') || '#@#' || coalesce(par_nok_district_code,'NULL-par_nok_district_code') || '#@#' || coalesce(par_nok_phone1,'NULL-par_nok_phone1') || '#@#' || coalesce(par_nok_phone2,'NULL-par_nok_phone2') || '#@#' || coalesce(par_nok_address_indicator,'NULL-par_nok_address_indicator') || '#@#' || coalesce(par_nok_mobile_phone,'NULL-par_nok_mobile_phone') || '#@#' || coalesce(par_nok_sms_language,'NULL-par_nok_sms_language') || '#@#' || to_char(coalesce(par_admission_datetime,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_source_indicator,'NULL-par_source_indicator') || '#@#' || coalesce(par_source_code,'NULL-par_source_code') || '#@#' || coalesce(par_pay_code,'NULL-par_pay_code') || '#@#' || coalesce(par_discharge_code,'NULL-par_discharge_code') || '#@#' || to_char(coalesce(par_discharge_datetime,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_destination_code,'NULL-par_destination_code') || '#@#' || coalesce(par_ambulance_no,'NULL-par_ambulance_no') || '#@#' || coalesce(par_police_case,'NULL-par_police_case') || '#@#' || coalesce(par_labour_case,'NULL-par_labour_case') || '#@#' || coalesce(par_ae_case_type,'NULL-par_ae_case_type') || '#@#' || coalesce(par_dba_flag,'NULL-par_dba_flag') || '#@#' || to_char(coalesce(par_follow_up_datetime,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_ward_code,'NULL-par_ward_code') || '#@#' || coalesce(par_specialty_code,'NULL-par_specialty_code') || '#@#' || coalesce(var_sub_specialty,'NULL-var_sub_specialty') || '#@#' || coalesce(par_bed_no,'NULL-par_bed_no') || '#@#' || coalesce(par_ward_class,'NULL-par_ward_class') || '#@#' || coalesce(par_pp_code,'NULL-par_pp_code') || '#@#' || coalesce(par_case_type,'NULL-par_case_type') || '#@#' || coalesce(par_transaction_type,'NULL-par_transaction_type') || '#@#' || to_char(coalesce(par_system_datetime,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || coalesce(par_user_id,'NULL-par_user_id') || '#@#' || to_char(coalesce(par_last_system_datetime,current_timestamp),'YYYY-MM-DD HH24:MI:SS') || '#@#' || 'ADT' || '#@#' || coalesce(par_document_flag,'NULL-par_document_flag') || '#@#' || coalesce(par_eh_code,'NULL-par_eh_code') || '#@#' || coalesce(par_source_hosp_code,'NULL-par_source_hosp_code') || '#@#' || coalesce(par_source_case_no,'NULL-par_source_case_no') || '#@#' || coalesce(par_hkic_symbol,'NULL-par_hkic_symbol') || '#@#' || coalesce(var_retcode::text,'null-var_retcode') || ']';
        
		CALL cpi_admission(par_hospital_code := par_hosp_code, par_case_no := par_case_no, par_hkid := par_hkid, par_patient_name := par_name, par_sex := par_sex, par_dob := par_dob, par_exact_dob_flag := par_exact_dob_flag, par_ccc_1 := par_ccc1, par_ccc_2 := par_ccc2, par_ccc_3 := par_ccc3, par_ccc_4 := par_ccc4, par_ccc_5 := par_ccc5, par_ccc_6 := par_ccc6, par_chi_name := var_chi_name, par_marital_status := par_marital_status, par_race_code := par_race_code, par_other_document_no := par_other_document_no, par_reference := var_reference, par_medical_record_number := par_medical_record_number, par_remark := var_remark, par_building := par_building, par_room := par_room, par_floor := par_floor, par_block := par_block, par_district_code := par_district_code, par_religion_code := par_religion_code, par_phone1 := par_phone1, par_phone2 := par_phone2, par_address_indicator := par_address_indicator, par_mobile_phone := par_mobile_phone, par_sms_language := par_sms_language, par_death_indicator := par_death_indicator, par_death_date := par_death_date, par_death_code := var_death_code, par_card_holder := var_card_holder, par_case_access_code := par_case_access_code, par_pmi_access_code := par_pmi_access_code, par_security_count := var_ops_security, par_patient_key => par_t_prk, par_priority => var_priority, par_nok_name := par_nok_name, par_nok_hkid := par_nok_hkid, par_nok_relation_code := par_nok_relation_code, par_nok_building := par_nok_building, par_nok_room := par_nok_room, par_nok_floor := par_nok_floor, par_nok_block := par_nok_block, par_nok_district_code := par_nok_district_code, par_nok_phone1 := par_nok_phone1, par_nok_phone2 := par_nok_phone2, par_nok_address_indicator := par_nok_address_indicator, par_nok_mobile_phone := par_nok_mobile_phone, par_nok_sms_language := par_nok_sms_language, par_admission_datetime := par_admission_datetime, par_source_indicator := par_source_indicator, par_source_code := par_source_code, par_patient_type := par_pay_code, par_discharge_code := par_discharge_code, par_discharge_datetime := par_discharge_datetime, par_destination_code := par_destination_code, par_ambulance_no := par_ambulance_no, par_police_case := par_police_case, par_labour_case := par_labour_case, par_ae_case_type := par_ae_case_type, par_dba_flag := par_dba_flag, par_follow_up_datetime := par_follow_up_datetime, par_ward_code := par_ward_code, par_specialty_code := par_specialty_code, par_sub_specialty := var_sub_specialty, par_bed_no := par_bed_no, par_ward_class := par_ward_class, par_pp_code := par_pp_code, par_case_type := par_case_type, par_txn_type := par_transaction_type, par_transaction_datetime := par_system_datetime, par_update_by := par_user_id, par_last_update_datetime := par_last_system_datetime, par_source_system := 'ADT', par_document_flag := par_document_flag, par_eh_code := par_eh_code, par_source_hosp_code := par_source_hosp_code, par_source_case_no := par_source_case_no, par_hkic_symbol := par_hkic_symbol,pas_return_code := var_retcode);
		
		raise notice '[hasp_admission_woresult:288]var_retcode=>%',var_retcode;
        IF var_retcode != 0 THEN
            BEGIN
                /* -- Remove cpi.. by WL on 27 July 1999 for HPI --- */
                
                /* --select @error_msg = messages from cpi..error_msgs */
                SELECT
                    messages
                    INTO var_error_msg
                    FROM error_msgs
                    WHERE error_code = var_retcode;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Call cpi function failed with return code ',
                            CASE CAST (var_retcode AS VARCHAR(8))
                                WHEN '' THEN ''
                                ELSE CAST (var_retcode AS VARCHAR(8))
                            END)
                            INTO var_error_msg;
                    END;
                END IF;
                -- changed by gjp
                -- RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                RAISE EXCEPTION '%', var_error_msg ;
                EXIT error;
            END;
        END IF;
        /* Update ADT tables */
        /* insert case */
        IF par_transaction_type = '100' OR par_transaction_type = '300' THEN
            SELECT
                'Y'
                INTO var_active_indicator;
        ELSE
            SELECT
                'N'
                INTO var_active_indicator;
        END IF;
        
        
        
        
        /*
        20050422 LSCHU update new born record for mother case number
        from A&E to Inpatient case
        */
        IF par_case_type = 'I' AND par_source_indicator = '3' AND par_source_code = par_hosp_code THEN
            BEGIN
                SELECT
                    Case_no
                    INTO var_prev_case
                    FROM Case_view
                    WHERE HKID = par_hkid AND Hospital_code = par_hosp_code AND Admission_datetime <= par_admission_datetime AND Case_type = 'A' AND Discharge_code IS NULL AND Admission_datetime = (SELECT
                        MAX(Admission_datetime)
                        FROM Case_view
                        WHERE HKID = par_hkid AND Hospital_code = par_hosp_code AND Admission_datetime <= par_admission_datetime AND Case_type = 'A' AND Discharge_code IS NULL);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount > 0 AND var_prev_case IS NOT NULL THEN
                    BEGIN
                        IF EXISTS (SELECT
                            *
                            FROM new_born
                            WHERE mother_hkid = par_hkid AND hospital_code = par_hosp_code AND mother_case_no = var_prev_case) THEN
                            BEGIN
                                OPEN nb_csr;
                                FETCH nb_csr INTO var_nb_hkid, var_birth_order, var_preg_no;

                                WHILE (CASE
                                    WHEN FOUND THEN 0
                                    WHEN NOT FOUND THEN 2
                                    ELSE 1
                                END) = 0 LOOP
                                    CALL cpi_update_new_born(pas_return_code, 'U'::varchar, par_hosp_code, par_hkid, var_nb_hkid, par_case_no, var_birth_order, var_preg_no, par_user_id, par_system_datetime, NULL::varchar, NULL::varchar);

                                    IF var_retcode != 0 THEN
                                        BEGIN
                                            SELECT
                                                messages
                                                INTO var_error_msg
                                                FROM error_msgs
                                                WHERE error_code = var_retcode;
                                            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                            var_rowcount := sql$rowcount;

                                            IF var_rowcount != 1 THEN
                                                BEGIN
                                                    SELECT
                                                        CONCAT('Call cpi function failed with return code ',
                                                        CASE CAST (var_retcode AS VARCHAR(8))
                                                            WHEN '' THEN ''
                                                            ELSE CAST (var_retcode AS VARCHAR(8))
                                                        END)
                                                        INTO var_error_msg;
                                                END;
                                            END IF;
                                            RAISE EXCEPTION '%', var_error_msg ;
                                            EXIT error;
                                        END;
                                    END IF;
                                    FETCH nb_csr INTO var_nb_hkid, var_birth_order, var_preg_no;
                                END LOOP;
                                -- CLOSE cpi_update_new_born$refcur_1;
                                -- CLOSE cpi_update_new_born$refcur_2;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /* --	select @t_prk */
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_admission_woresult" OWNER TO "HPI_SCHEMA_OWNER_ROLE";