-- DROP PROCEDURE hpi.hasp_admission(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in int4, in int4, in int4, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_admission(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_transaction_type character varying, IN par_hkid character varying, IN par_name character varying, IN par_sex character varying, IN par_dob timestamp without time zone, IN par_exact_dob_flag character varying, IN par_ccc1 character varying, IN par_ccc2 character varying, IN par_ccc3 character varying, IN par_ccc4 character varying, IN par_ccc5 character varying, IN par_ccc6 character varying, IN par_marital_status character varying, IN par_race_code character varying, IN par_other_document_no character varying, IN par_medical_record_number character varying, IN par_building character varying, IN par_room character varying, IN par_floor character varying, IN par_block character varying, IN par_district_code character varying, IN par_religion_code character varying, IN par_home_phone_no character varying, IN par_other_phone_no_1 character varying, IN par_other_phone_ext_1 character varying, IN par_other_phone_no_2 character varying, IN par_other_phone_ext_2 character varying, IN par_nok_name character varying, IN par_nok_hkid character varying, IN par_nok_relation_code character varying, IN par_nok_building character varying, IN par_nok_room character varying, IN par_nok_floor character varying, IN par_nok_block character varying, IN par_nok_district_code character varying, IN par_nok_home_phone character varying, IN par_nok_other_phone_no_1 character varying, IN par_nok_other_phone_ext_1 character varying, IN par_nok_other_phone_no_2 character varying, IN par_nok_other_phone_ext_2 character varying, IN par_death_indicator character varying, IN par_death_date timestamp without time zone, IN par_t_prk character varying, IN par_case_no character varying, IN par_admission_datetime timestamp without time zone, IN par_source_indicator character varying, IN par_source_code character varying, IN par_pay_code character varying, IN par_discharge_code character varying, IN par_discharge_datetime timestamp without time zone, IN par_destination_code character varying, IN par_case_type character varying, IN par_movement_count integer, IN par_security_count integer, IN par_case_access_code integer, IN par_pmi_access_code integer, IN par_ambulance_no character varying, IN par_police_case character varying, IN par_labour_case character varying, IN par_ae_case_type character varying, IN par_dba_flag character varying, IN par_follow_up_datetime timestamp without time zone, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_bed_no character varying, IN par_ward_class character varying, IN par_user_id character varying, IN par_pp_code character varying, IN par_last_system_datetime timestamp without time zone, IN par_last_updated_by character varying, IN par_terminal_id character varying, IN par_eh_code character varying DEFAULT NULL::character varying, IN par_document_flag character varying DEFAULT NULL::character varying, IN par_source_hosp_code character varying DEFAULT NULL::character varying, IN par_source_case_no character varying DEFAULT NULL::character varying, IN par_hkic_symbol character varying DEFAULT NULL::character varying, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* -- add hosp_code as input parm for HPI by WL on 27 July 1999 -- */
DECLARE
    var_retcode            INTEGER;
    var_rowcount           INTEGER;
    var_error              INTEGER;
    var_error_msg          VARCHAR(255);
    /* -- Remarked by WL on 27 July 1999, because it is -- */
    /* -- input parm --- */

    /* --@hosp_code				VARCHAR(03), */
    var_cpi_flag           VARCHAR(01);
    var_active_indicator   VARCHAR(01);
    var_movement_type      VARCHAR(01);
    var_movement_datetime  TIMESTAMP WITHOUT TIME ZONE;
    var_ops_security       INTEGER;
    var_treatment_location VARCHAR(04);
    var_prev_case          VARCHAR(12);
    var_nb_hkid            VARCHAR(12);
    var_birth_order        INTEGER;
    var_preg_no            INTEGER;
    var_chi_name           VARCHAR(12);
    var_reference          VARCHAR(20);
    var_remark             VARCHAR(255);
    var_death_code         VARCHAR(04);
    var_card_holder        INTEGER;
    var_sub_specialty      VARCHAR(04);
    var_eis_code           VARCHAR(3);
    sql$rowcount           BIGINT;
    nb_csr CURSOR FOR
        SELECT new_born_hkid,
               birth_order,
               pregnancy_number
        FROM new_born
        WHERE mother_hkid = par_hkid
          AND hospital_code = par_hosp_code
          AND mother_case_no = var_prev_case;
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
        SELECT Text_value
        INTO var_cpi_flag
        FROM Hospital_control
        WHERE Type = 'cpi_server'
          AND Hospital_code = par_hosp_code;

        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                SELECT var_error
                INTO var_retcode;
                EXIT error;
            END;
        END IF;

        IF var_rowcount != 1 THEN
            BEGIN
                SELECT 200026
                INTO var_retcode;
                RAISE EXCEPTION '% ', 'Invalid stored procedure for cpi server' USING ERRCODE := var_retcode;
                EXIT error;
            END;
        END IF;

        /* YL PasCr-2018/00113: To raise error if nok_name is invalid */
        IF par_nok_name IS NOT NULL AND par_transaction_type IN ('100', '300') THEN
            BEGIN
                IF par_nok_name NOT LIKE '[A-Z]%,%' THEN
                    BEGIN
                        SELECT 299999
                        INTO var_retcode;
                        SELECT 'Invalid major contact person name, first character should be an alphabet'
                        INTO var_error_msg;
                        RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;

        IF par_transaction_type = '100' THEN
            BEGIN
                SELECT IMIS_code
                INTO var_eis_code
                FROM (SELECT IMIS_code, Specialty_code, Effective_date
                      FROM Specialty
                      WHERE Specialty_code = par_specialty_code
                        AND Effective_date <= par_admission_datetime
                        AND Active_status = 'A'
                      ORDER BY Effective_date DESC) AS sub
                WHERE sub.Specialty_code = specialty_code
                LIMIT 1;

                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                EXCEPTION
                    WHEN OTHERS THEN
                        var_error := 1;
                END;

                IF var_error != 0 OR var_rowcount != 1 THEN
                    BEGIN
                        SELECT 200026
                        INTO var_retcode;
                        /* YL PasCr-2016/00191 */
                        RAISE EXCEPTION '% ', 'Invalid/Inactive specialty code is selected!' USING ERRCODE := var_retcode;
                        EXIT error;
                    END;
                END IF;

                IF par_admission_datetime > '20161101' THEN
                    BEGIN
                        IF var_eis_code = 'MIX' THEN
                            BEGIN
                                SELECT 299999
                                INTO var_retcode;
                                SELECT 'Patient admission to EIS MIX specialty is not allowed'
                                INTO var_error_msg;
                                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
                                EXIT error;
                            END;
                        END IF;

                        IF var_eis_code = 'SKD' AND par_hosp_code NOT IN ('PYN', 'QEH', 'PWH') THEN
                            BEGIN
                                SELECT 299999
                                INTO var_retcode;
                                SELECT 'Patient admission to EIS SKD specialty is not allowed'
                                INTO var_error_msg;
                                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
                                EXIT error;
                            END;
                        END IF;

                        IF var_eis_code = 'OTH' AND par_hosp_code NOT IN ('PWH', 'OLM', 'PYN') THEN
                            BEGIN
                                SELECT 299999
                                INTO var_retcode;
                                SELECT 'Patient admission to EIS OTH specialty is not allowed'
                                INTO var_error_msg;
                                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := var_retcode;
                                EXIT error;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;

        IF par_transaction_type = '300' THEN
            SELECT 'A'
            INTO par_case_type;
        ELSE
            SELECT 'I'
            INTO par_case_type;
        END IF;
        /* -- Remove cpi.. by WL on 27 July 1999 for HPI --- */
        SELECT chi_name,
               reference,
               death_code,
               card_holder,
               security
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

        IF var_error != 0 THEN
            BEGIN
                EXIT error;
            END;
        END IF;
        /* -- Remove cpi.. by WL on 27 July 1999 for HPI --- */

        /* --exec @retcode = cpi..cpi_admission */
        CALL cpi_admission(pas_return_code => var_retcode, par_hospital_code => par_hosp_code,
                           par_case_no => par_case_no,
                           par_hkid => par_hkid, par_patient_name => par_name, par_sex => par_sex,
                           par_dob => par_dob, par_exact_dob_flag => par_exact_dob_flag,
                           par_ccc_1 => par_ccc1, par_ccc_2 => par_ccc2, par_ccc_3 => par_ccc3,
                           par_ccc_4 => par_ccc4, par_ccc_5 => par_ccc5, par_ccc_6 => par_ccc6,
                           par_chi_name => var_chi_name, par_marital_status => par_marital_status,
                           par_race_code => par_race_code, par_other_document_no => par_other_document_no,
                           par_reference => var_reference,
                           par_medical_record_number => par_medical_record_number,
                           par_remark => var_remark, par_building => par_building, par_room => par_room,
                           par_floor => par_floor, par_block => par_block,
                           par_district_code => par_district_code, par_religion_code => par_religion_code,
                           par_home_phone_no => par_home_phone_no,
                           par_other_phone_no_1 => par_other_phone_no_1,
                           par_other_phone_ext_1 => par_other_phone_ext_1,
                           par_other_phone_no_2 => par_other_phone_no_2,
                           par_other_phone_ext_2 => par_other_phone_ext_2,
                           par_death_indicator => par_death_indicator, par_death_date => par_death_date,
                           par_death_code => var_death_code, par_card_holder => var_card_holder,
                           par_case_access_code => par_case_access_code,
                           par_pmi_access_code => par_pmi_access_code,
                           par_security_count => var_ops_security, par_patient_key => par_t_prk,
                           par_priority => 1, par_nok_name => par_nok_name, par_nok_hkid => par_nok_hkid,
                           par_nok_relation_code => par_nok_relation_code,
                           par_nok_building => par_nok_building, par_nok_room => par_nok_room,
                           par_nok_floor => par_nok_floor, par_nok_block => par_nok_block,
                           par_nok_district_code => par_nok_district_code,
                           par_nok_home_phone => par_nok_home_phone,
                           par_nok_other_phone_no_1 => par_nok_other_phone_no_1,
                           par_nok_other_phone_ext_1 => par_nok_other_phone_ext_1,
                           par_nok_other_phone_no_2 => par_nok_other_phone_no_2,
                           par_nok_other_phone_ext_2 => par_nok_other_phone_ext_2,
                           par_admission_datetime => par_admission_datetime,
                           par_source_indicator => par_source_indicator,
                           par_source_code => par_source_code, par_patient_type => par_pay_code,
                           par_discharge_code => par_discharge_code,
                           par_discharge_datetime => par_discharge_datetime,
                           par_destination_code => par_destination_code,
                           par_ambulance_no => par_ambulance_no, par_police_case => par_police_case,
                           par_labour_case => par_labour_case, par_ae_case_type => par_ae_case_type,
                           par_dba_flag => par_dba_flag, par_follow_up_datetime => par_follow_up_datetime,
                           par_ward_code => par_ward_code, par_specialty_code => par_specialty_code,
                           par_sub_specialty => var_sub_specialty, par_bed_no => par_bed_no,
                           par_ward_class => par_ward_class, par_pp_code => par_pp_code,
                           par_case_type => par_case_type, par_txn_type => par_transaction_type,
                           par_transaction_datetime => par_system_datetime, par_update_by => par_user_id,
                           par_last_update_datetime => par_last_system_datetime,
                           par_source_system => 'ADT', par_document_flag => par_document_flag,
                           par_eh_code => par_eh_code, par_source_hosp_code => par_source_hosp_code,
                           par_source_case_no => par_source_case_no, par_hkic_symbol => par_hkic_symbol);

        IF var_retcode != 0 THEN
            BEGIN
                /* -- Remove cpi.. by WL on 27 July 1999 for HPI --- */

                /* --select @error_msg = messages from cpi..error_msgs */
                SELECT messages
                INTO var_error_msg
                FROM error_msgs
                WHERE error_code = var_retcode;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT CONCAT('Call cpi function failed with return code ',
                                      CASE CAST(var_retcode AS VARCHAR(8))
                                          WHEN '' THEN ''
                                          ELSE CAST(var_retcode AS VARCHAR(8))
                                          END)
                        INTO var_error_msg;
                    END;
                END IF;
                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                EXIT error;
            END;
        END IF;
        /* Update ADT tables */
        /* insert case */
        IF par_transaction_type = '100' OR par_transaction_type = '300' THEN
            SELECT 'Y'
            INTO var_active_indicator;
        ELSE
            SELECT 'N'
            INTO var_active_indicator;
        END IF;
        /* -- Remarked by WL on 27 July 1999, becasue hasp_update_case -- */
        /* -- is obsolete for HPI --- */

        /* --exec @retcode = hasp_update_case */

        /* --			@update_flag = I, */

        /* --			@case_no = @case_no, */

        /* --			@admission_datetime = @admission_datetime, */

        /* --			@source_indicator = @source_indicator, */

        /* --			@source_code = @source_code, */

        /* --			@hkid = @hkid, */

        /* --			@district_code = @district_code, */

        /* --			@pay_code = @pay_code, */

        /* --			@discharge_code = @discharge_code, */

        /* --			@discharge_datetime = @discharge_datetime, */

        /* --			@destination_code = @destination_code, */

        /* --			@case_type = @case_type, */

        /* --			@active_indicator = @active_indicator, */

        /* --			@movement_count = @movement_count, */

        /* --			@security_count = @security_count, */

        /* --			@access_code = @case_access_code, */

        /* --			@system_datetime = @system_datetime, */

        /* --			@user_id = @user_id, */

        /* --			@t_prk = @t_prk, */

        /* --			@last_system_datetime = @system_datetime */

        /* --	if @retcode != 0 */

        /* --	begin */

        /* --		goto error */

        /* --	end */
        /* -- Remove local update by WL on 27 July 1999 for HPI-- */

        /* insert case detail */

        /* --if @case_type = A and @transaction_type = 300 */

        /* --	begin */

        /* --		insert AE_case_detail */

        /* --			(Case_no, */

        /* --			Ambulance_no, */

        /* --			Police_case, */

        /* --			Labour_case_flag, */

        /* --			AE_case_type, */

        /* --			DBA_flag, */

        /* --			Follow_up_datetime) */

        /* --		values(@case_no, */

        /* --			@ambulance_no, */

        /* --			@police_case, */

        /* --			@labour_case, */

        /* --			@ae_case_type, */

        /* --			@dba_flag, */

        /* --			@follow_up_datetime) */

        /* --		select @rowcount = @@rowcount,@error = @@error */

        /* --		if @error != 0 */

        /* --		begin */

        /* --			select @retcode = @error */

        /* --			goto error */

        /* --		end */

        /* --	end */

        /* --	if @case_type = I and @transaction_type = 100 */

        /* --	begin /* begin to insert HN case detail */ */

        /* --		if @pp_code != null */

        /* --		begin */

        /* --			insert HN_case_detail */

        /* --				(Case_no, */

        /* --				Internal_ICD9_code, */

        /* --				External_ICD9_code, */

        /* --				PP_code */

        /* --			values(@case_no, */

        /* --				null, */

        /* --				null, */

        /* --				@pp_code */

        /* --			select @rowcount = @@rowcount,@error = @error */

        /* --			if @error != 0 */

        /* --			begin */

        /* --				select @retcode = @error */

        /* --				goto error */

        /* --			end */

        /* --		end */

        /* --	end */

        /* --	/* insert movement */ */

        /* --	select @movement_type = A */

        /* --	select @movement_datetime = @admission_datetime */

        /* --	select @treatment_location = Treatment_location */

        /* --	from Ward */

        /* --	where Ward_code = @ward_code */

        /* --	and   Effective_date <= @admission_datetime */

        /* --	group by Ward_code */

        /* --	having Effective_date = max(Effective_date) */

        /* --	and Active_status = A */

        /* --	select @rowcount = @@rowcount, @error = @@error */

        /* --	if @rowcount != 1 */

        /* --	begin */

        /* --		select @retcode = @error */

        /* --		select @error_msg = Ward_code -  + @ward_code +  is not active on the admission date */

        /* --		raiserror 200026, @error_msg */

        /* --		goto error */

        /* --	end */

        /* --	insert Movement */

        /* --		(Case_no, */

        /* --		Movement_count, */

        /* --		Ward_code, */

        /* --		Bed_no, */

        /* --		Specialty_code, */

        /* --		Ward_class, */

        /* --		Movement_type, */

        /* --		Movement_datetime, */

        /* --		Treatment_location, */

        /* --		System_datetime, */

        /* --		User_ID, */

        /* --		Doctor_code) */

        /* --	values(@case_no, */

        /* --		@movement_count, */

        /* --		@ward_code, */

        /* --		@bed_no, */

        /* --		@specialty_code, */

        /* --		@ward_class, */

        /* --		@movement_type, */

        /* --		@movement_datetime, */

        /* --		@treatment_location, */

        /* --		@system_datetime, */

        /* --		@user_id, */

        /* --		null) */

        /* --	select @rowcount = @@rowcount,@error = @@error */

        /* --	if @error != 0 */

        /* --	begin */

        /* --		select @retcode = @error */

        /* --		goto error */

        /* --	end */

        /* --	if @transaction_type = 090 */

        /* --	begin */

        /* --		select @movement_type = D */

        /* --		select @movement_count = 2 */

        /* --		select @movement_datetime = @discharge_datetime */

        /* --		Update ADT_Case */

        /* --		Set Movement_count = @movement_count */

        /* --		where Case_no = @case_no */

        /* -- */

        /* --		select @rowcount = @@rowcount, @error = @@error */

        /* --		if @error != 0 */

        /* --		begin */
        /* select @retcode = @error */

        /* --			goto error */

        /* --	end */

        /* --	if @rowcount != 1 */

        /* --	begin */

        /* --		select @retcode = @error */

        /* --		select @error_msg = Cannot update Case table */

        /* --		raiserror 200026, @error_msg */

        /* --		goto error */

        /* --	end */

        /* --		insert Movement */

        /* --			(Case_no, */

        /* --			Movement_count, */

        /* --			Ward_code, */

        /* --			Bed_no, */

        /* --			Specialty_code, */

        /* --			Ward_class, */

        /* --		Movement_type, */

        /* --			Movement_datetime, */

        /* --			Treatment_location, */

        /* --			System_datetime, */

        /* --			User_ID, */

        /* --			Doctor_code) */

        /* --		values */

        /* --			(@case_no, */

        /* --			@movement_count, */

        /* --			@ward_code, */

        /* --			@bed_no, */

        /* --			@specialty_code, */

        /* --			@ward_class, */

        /* --			@movement_type, */

        /* --			@movement_datetime, */

        /* --			@treatment_location, */

        /* --			@system_datetime, */

        /* --			@user_id, */

        /* --			null) */

        /* --		select @rowcount = @@rowcount, @error = @@error */

        /* --		if @error != 0 */

        /* --		begin */

        /* --			select @retcode = @error */

        /* --			goto error */

        /* --		end */

        /* --	end */

        /* --	/* insert ward list */ */

        /* --	if @transaction_type = 100 or @transaction_type = 300 */

        /* --	begin */

        /* --		insert Ward_list */

        /* --			(Case_no, */

        /* --			Ward_code, */

        /* --			Bed_no, */

        /* --			Specialty_code) */

        /* --		values(@case_no, */

        /* --			@ward_code, */

        /* --			@bed_no, */

        /* --			@specialty_code) */

        /* --		select @rowcount = @@rowcount,@error = @@error */

        /* --		if @error != 0 */

        /* --		begin */

        /* --			select @retcode = @error */

        /* --			goto error */

        /* --		end */

        /* --	end */

        /*
        20050422 LSCHU update new born record for mother case number
        from A&E to Inpatient case
        */
        IF par_case_type = 'I' AND par_source_indicator = '3' AND par_source_code = par_hosp_code THEN
            BEGIN
                SELECT Case_no
                INTO var_prev_case
                FROM Case_view
                WHERE HKID = par_hkid
                  AND Hospital_code = par_hosp_code
                  AND Admission_datetime <= par_admission_datetime
                  AND Case_type = 'A'
                  AND Discharge_code IS NULL
                  AND Admission_datetime = (SELECT MAX(Admission_datetime)
                                            FROM Case_view
                                            WHERE HKID = par_hkid
                                              AND Hospital_code = par_hosp_code
                                              AND Admission_datetime <= par_admission_datetime
                                              AND Case_type = 'A'
                                              AND Discharge_code IS NULL);
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                IF sql$rowcount > 0 AND var_prev_case IS NOT NULL THEN
                    BEGIN
                        IF EXISTS (SELECT *
                                   FROM new_born
                                   WHERE mother_hkid = par_hkid
                                     AND hospital_code = par_hosp_code
                                     AND mother_case_no = var_prev_case) THEN
                            BEGIN
                                OPEN nb_csr;
                                FETCH nb_csr INTO var_nb_hkid, var_birth_order, var_preg_no;

                                WHILE (CASE
                                    WHEN FOUND THEN 0
                                    WHEN NOT FOUND THEN 2
                                    ELSE 1
                                    END) = 0
                                    LOOP
                                        CALL cpi_update_new_born(var_retcode, 'U', par_hosp_code, par_hkid,
                                                                 var_nb_hkid, par_case_no,
                                                                 var_birth_order, var_preg_no,
                                                                 par_user_id, par_system_datetime, NULL,
                                                                 NULL);

                                        IF var_retcode != 0 THEN
                                            BEGIN
                                                SELECT messages
                                                INTO var_error_msg
                                                FROM error_msgs
                                                WHERE error_code = var_retcode;
                                                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                                                var_rowcount := sql$rowcount;

                                                IF var_rowcount != 1 THEN
                                                    BEGIN
                                                        SELECT CONCAT('Call cpi function failed with return code ',
                                                                      CASE CAST(var_retcode AS VARCHAR(8))
                                                                          WHEN '' THEN ''
                                                                          ELSE CAST(var_retcode AS VARCHAR(8))
                                                                          END)
                                                        INTO var_error_msg;
                                                    END;
                                                END IF;
                                                RAISE EXCEPTION '%', var_error_msg USING ERRCODE := '200026';
                                                EXIT error;
                                            END;
                                        END IF;
                                        FETCH nb_csr INTO var_nb_hkid, var_birth_order, var_preg_no;
                                    END LOOP;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        OPEN p_refcur FOR
            SELECT par_t_prk;
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_admission" OWNER TO "HPI_SCHEMA_OWNER_ROLE";