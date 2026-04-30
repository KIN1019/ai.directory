-- DROP PROCEDURE hpi.hasp_discharge(inout int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_discharge(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_t_datetime timestamp without time zone, IN par_t_case_no character varying, IN par_t_discharge_code character varying, IN par_t_destination character varying, IN par_t_remark character varying, IN par_t_ns_code character varying, IN par_t_doctor character varying, IN par_t_user_id character varying, IN par_t_case_timestamp timestamp without time zone, IN par_t_mrt_indicator character varying, IN par_t_deathdtm timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* ------------------------------------------------------------- */
/* This store procedure is developed base on the LRR/DT version */
/* Project  : IPAS/ADT v2.0 */
/* Server   : Sybase 10.0.2 */
/* O.S.     : AIX 3.2.5 */
/* : To perform In-patient discharge */
/* AIX file : sp_d.sql */
/* ------------------------------------------------------------- */
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_return_code INTEGER;
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_pat_key VARCHAR(16);
    var_return_error_code INTEGER;
    var_error_message VARCHAR(255);
    var_t_destination VARCHAR(6);
    var_ward_code VARCHAR(8);
    var_bed_no VARCHAR(10);
    var_specialty_code VARCHAR(8);
    var_ward_class VARCHAR(2);
    var_movement_type VARCHAR(2);
    var_movement_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_treatment_location VARCHAR(8);
    var_old_doctor_code VARCHAR(16);
    var_message VARCHAR(160);
    var_case_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_case_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_case_movement_count INTEGER;
    var_admission_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_source_indicator VARCHAR(2);
    var_source_code VARCHAR(6);
    var_hkid VARCHAR(24);
    var_district_code VARCHAR(10);
    var_pay_code VARCHAR(6);
    var_discharge_code VARCHAR(2);
    var_discharge_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_destination_code VARCHAR(6);
    var_case_type VARCHAR(2);
    var_status VARCHAR(2);
    var_bed_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_ward_list_timestamp TIMESTAMP WITHOUT TIME ZONE;
    var_transaction_type VARCHAR(6);
    var_occupied_bed_status VARCHAR(2);
    var_vacant_bed_status VARCHAR(2);
    var_last_update_hosp VARCHAR(6);
    sql$rowcount BIGINT;
    var_pmi_access INTEGER;
    var_security_flag VARCHAR(2);
    var_temp_bit VARCHAR(64);
    var_temp_int INTEGER;
    var_temp_val INTEGER;
    var_last_upd_pmi_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_patient_key VARCHAR(16);
    var_tx_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    /* --Sep-2022/patient privacy flag */
    /* --End - Sep-2022/patient privacy flag */
    /* Variables declared from IPAS v2.0 */
    /* discharge transaction type */
    SELECT
        'O'
        INTO var_occupied_bed_status;
    SELECT
        'V'
        INTO var_vacant_bed_status;
    /* Yorky 200907 */
    SELECT
        ''
        INTO var_last_update_hosp;
       
	-- CP2 & Harmonycloud on Jan-2025:
	-- Since the ownership of cmslrr_db and the migration approach are to be confirmed with other CMS teams (E.g. Related SPs may be changed to APIs),
	-- the following logic about cmslrr_db was not migrated to PG in this moment and was commented in PG DDL with this remark for record.
   	/*
    IF var_return_code != 0 THEN
        pas_return_code := var_return_code;
        RETURN;
    END IF;
    */

    select
        clock_timestamp()
        INTO var_system_datetime;
    /* validation start here */
    BEGIN
        SELECT
            Case_view.row_update_datetime, update_dtm, Case_view.Movement_count, Admission_datetime, Case_view.Source_indicator, Case_view.Source_code, HKID, Case_view.District_code, Pay_code, Case_view.Discharge_code, Discharge_datetime, Case_view.Destination_code, Case_view.Case_type,
            /* --Sep-2022/patient privacy flag */
            c1.patient_key
            INTO var_case_timestamp, var_case_system_datetime, var_case_movement_count, var_admission_datetime, var_source_indicator, var_source_code, var_hkid, var_district_code, var_pay_code, var_discharge_code, var_discharge_datetime, var_destination_code, var_case_type, var_pat_key
            /* --End - Sep-2022/patient privacy flag */
            FROM Case_view, cpi_case AS c1
            WHERE Case_view.Case_no = par_T_CASE_NO AND Case_view.Hospital_code = par_hosp_code AND Case_view.Case_no = c1.case_no AND Case_view.Hospital_code = c1.hospital_code;
        var_error := 0;
        EXCEPTION
            WHEN OTHERS THEN
                var_error := 1;
    END;

    IF var_error != 0 THEN
        BEGIN
            pas_return_code := var_error;
            RETURN;
        END;
    END IF;
    /* check In-patient Case */
    IF var_case_type != 'I' THEN
        BEGIN
	        RAISE NOTICE 'var_case_type => [%]',var_case_type;
            /* raiserror 102041 This is not an in-patient Case number!  */
            /* return 102041 */
            RAISE EXCEPTION 'This is not an in-patient Case number! ' USING ERRCODE := '40003';
            pas_return_code := 40003;
            RETURN;
        END;
    END IF;
    /* check timestamp */
    /* check date/time */
    /* check ward code */
    /* check discharge */
    /* update death indicator for death case */
    /* cpi version */
    /*
    if @T_DISCHARGE_CODE = '1'
    begin
    
    	update PMI
    		set Death_indicator = 'Y',
    		Death_date = @T_DATETIME
    		where HKID = @hkid
    
    end
    
    select @error = @@error
    if @error != 0
    begin
    	rollback transaction
    	return @error
    end
    */
    /* insert Movement */
    /*
    insert Movement
           (Case_no,
            Movement_count,
            Ward_code,
            Bed_no,
            Specialty_code,
            Ward_class,
            Movement_type,
            Movement_datetime,
            Treatment_location,
            System_datetime,
            User_ID,
            Doctor_code
            )
    values (@T_CASE_NO,
            @case_movement_count,
            @ward_code,
            @bed_no,
            @specialty_code,
            @ward_class,
            'D',
            @T_DATETIME,
            @treatment_location,
            @system_datetime,
            @T_USER_ID,
            @T_DOCTOR
            )
    select @error = @@error
    if @error != 0
    	begin
    		rollback transaction
    		return @error
    	end
    */
    /*
    update  Case_view
        set Movement_count		= @case_movement_count,
            Discharge_code		= @T_DISCHARGE_CODE,
            Destination_code	= @t_destination,
            Discharge_datetime	= @T_DATETIME,
            System_datetime		= @system_datetime,
            User_ID			= @T_USER_ID,
    	MRT_indicator		= @T_MRT_INDICATOR
    from    cpi..cpi_case c1
    where 	Case_no		= @T_CASE_NO
    and     c1.update_dtm = @case_system_datetime
    and     c1.case_no = Case_no
    and     c1.hospital_code = @hosp_code
    
    select @error = @@error
    if @error != 0
    	begin
    		rollback transaction
    		return @error
    	end
    */
    /* update Ward_list */
    /*
    delete	Ward_list
    where	Case_no= @T_CASE_NO
    and	timestamp = @ward_list_timestamp
    
    select @error = @@error
    if @error != 0
    	begin
    		rollback transaction
    		return @error
    	end
    */
    /* update Bed */
    /*
    update  Bed
    set 	Status = @vacant_bed_status
    where	Ward_code = @ward_code
    and     timestamp = @bed_timestamp
    and     Bed_no    = @bed_no
    
    select @error = @@error
    if @error != 0
    	begin
    		rollback transaction
    		return @error
    	end
    */
    /* insert Diagnosis */
    /* kar 3 Feb 00: keep content of old Diangosis & Ext Cause */
    /*
    delete Diagnosis
    where Hospital_code = @hosp_code and Case_no = @T_CASE_NO
    */
    /* end : kar 3 Feb 00 */
    /* kar9 Dec 99: discard diagnosis and external cause, add remark */
    /*
    if @T_DIAGNOSIS != null
    begin
    	insert	Diagnosis
           (	Hospital_code,
    		Case_no,
    		Diagnosis_type,
    		Diagnosis_text,
    		System_datetime,
    		User_ID
           )
    	values
    	(	@hosp_code,
    		@T_CASE_NO,
                	'D ',
               	@T_DIAGNOSIS,
               	@system_datetime,
                	@T_USER_ID
    	)
    	select @error = @@error
    	if @error != 0
    	begin
    		rollback transaction
    		return @error
    	end
    end
    
    if @T_EXTERNAL_CAUSE != null
    begin
    	insert	Diagnosis
    	(	Hospital_code,
    		Case_no,
    		Diagnosis_type,
    		Diagnosis_text,
    		System_datetime,
    		User_ID
    	)
    	values
    	(	@hosp_code,
    		@T_CASE_NO,
    		'DE',
    		@T_EXTERNAL_CAUSE,
    		@system_datetime,
    		@T_USER_ID
    	)
    	select @error = @@error
    	if @error != 0
    	begin
    		rollback transaction
    		return @error
    	end
    end
    */
    /* end : kar9 Dec 99 */
    /* Insert Transaction_log */
    /* Insert Event_log */
    /*
    Sep-2022/patient privacy flag/CP2 Max,Freda/
    Privacy flag will be auto-turned off after ALL the AE/HN cases had been discharged
    */
    /* End - Sep-2022/patient privacy flag */
    /* update by Karine 19 Oct 1999 */
    /* ----- reset the confidentiality flag --- */
    /* --- end reset the confidentiality flag -- */
    
    /* end by Karine 19 Oct 1999 */
    <<restart>>
    BEGIN
        SELECT
            CONCAT('13', par_T_DISCHARGE_CODE)
            INTO var_transaction_type;

        BEGIN
            SELECT
                Ward_code, Specialty_code, Bed_no, Ward_class, Movement_type, Movement_datetime, Treatment_location, Doctor_code
                INTO var_ward_code, var_specialty_code, var_bed_no, var_ward_class, var_movement_type, var_movement_datetime, var_treatment_location, var_old_doctor_code
                FROM Movement AS m, Case_view AS c
                WHERE m.Hospital_code = par_hosp_code AND m.Case_no = par_T_CASE_NO AND m.Hospital_code = c.Hospital_code AND m.Case_no = c.Case_no AND m.Movement_count = c.Movement_count;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                Status, row_update_datetime
                INTO var_status, var_bed_timestamp
                FROM Bed
                WHERE Hospital_code = par_hosp_code AND Ward_code = par_T_NS_CODE AND Bed_no = var_bed_no;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;

        BEGIN
            SELECT
                row_update_datetime
                INTO var_ward_list_timestamp
                FROM Ward_list
                WHERE Hospital_code = par_hosp_code AND Case_no = par_T_CASE_NO;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error != 0 THEN
            BEGIN
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;

        IF var_case_system_datetime != par_T_CASE_timestamp THEN
            BEGIN
                /* raiserror 102041 Case record has been modified by other user! */
                /* return 102041 */
                RAISE EXCEPTION 'Case record has been modified by other user!' USING ERRCODE := '40004';
                pas_return_code := 40004;
                RETURN;
            END;
        END IF;

        IF var_system_datetime < par_T_DATETIME THEN
            BEGIN
                /* raiserror 102044 Discharge datetime cannot be later than the system datetime! */
                /* return 102044 */
                RAISE EXCEPTION 'Discharge datetime cannot be later than the system datetime!' USING ERRCODE := '40001';
                pas_return_code := 40001;
                RETURN;
            END;
        END IF;

        IF var_movement_datetime > par_T_DATETIME THEN
            BEGIN
                /* raiserror 102045 Discharge datetime cannot be earlier than the last movement! */
                /* return 102045 */
                RAISE EXCEPTION 'Discharge datetime cannot be earlier than the last movement!' USING ERRCODE := '40000';
                pas_return_code := 40000;
                RETURN;
            END;
        END IF;

        IF var_ward_code != par_T_NS_CODE THEN
            BEGIN
                /* raiserror 102042 Patient not in this ward! */
                /* return 102042 */
                RAISE EXCEPTION 'Patient not in this ward!' USING ERRCODE := '40012';
                pas_return_code := 40012;
                RETURN;
            END;
        END IF;

        IF var_movement_type = 'D' THEN /* D ==> discharge */
            BEGIN
                /* raiserror 102043 Patient already discharged! */
                /* return 102043 */
                RAISE EXCEPTION 'Patient already discharged!' USING ERRCODE := '40010';
                pas_return_code := 40010;
                RETURN;
            END;
        END IF;
        SELECT
            var_case_movement_count + 1
            INTO var_case_movement_count;

        IF par_T_DISCHARGE_CODE = '0' OR par_T_DISCHARGE_CODE = '4' THEN
            BEGIN
                SELECT
                    par_T_DESTINATION
                    INTO var_t_destination;
            END;
        ELSE
            BEGIN
                SELECT
                    NULL
                    INTO var_t_destination;
            END;
        END IF;
        DELETE FROM Diagnosis
            WHERE Hospital_code = par_hosp_code AND Case_no = par_T_CASE_NO AND Diagnosis_type = 'RM';

        IF par_T_REMARK is not NULL THEN
            BEGIN
                BEGIN
                    INSERT INTO Diagnosis (hospital_code, case_no, diagnosis_type, diagnosis_text, system_datetime, user_id)
                    VALUES (par_hosp_code, par_T_CASE_NO, 'RM', par_T_REMARK, var_system_datetime, par_T_USER_ID);
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF var_error != 0 THEN
                    BEGIN
                        RAISE EXCEPTION '';
                        pas_return_code := var_return_code;
                        RETURN;
                    END;
                END IF;
            END;
        END IF;
        CALL hasp_insert_transaction_log(var_return_code, par_hosp_code, var_system_datetime, par_T_CASE_NO, par_T_NS_CODE, var_treatment_location, var_ward_class, var_bed_no, var_specialty_code, NULL, NULL, NULL, NULL, NULL, par_T_DATETIME, var_transaction_type, NULL, par_T_USER_ID, NULL, NULL);

        IF var_return_code != 0 THEN
            BEGIN
                RAISE EXCEPTION '';
                pas_return_code := var_error;
                RETURN;
            END;
        END IF;
        CALL hasp_insert_event_log(var_return_code, par_hosp_code, var_system_datetime, var_transaction_type, var_hkid, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_DEATHDTM, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_CASE_NO, var_admission_datetime, var_source_indicator, var_source_code, var_pay_code, par_T_DISCHARGE_CODE, par_T_DATETIME, var_t_destination, var_case_type, var_case_movement_count, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_NS_CODE, var_specialty_code, var_bed_no, var_ward_class, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, par_T_USER_ID, par_T_DOCTOR, var_old_doctor_code, NULL, par_T_MRT_INDICATOR);

        IF var_return_code != 0 THEN
            BEGIN
                RAISE EXCEPTION '';
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;
        CALL cpi_discharge(var_return_code, par_hosp_code, par_T_CASE_NO, var_hkid, par_T_DISCHARGE_CODE, par_T_DATETIME, var_t_destination, par_T_NS_CODE, var_ward_class, var_bed_no, var_specialty_code, NULL, par_T_DOCTOR, var_case_type, var_transaction_type, var_system_datetime, par_T_USER_ID, 'LRRDT', par_T_MRT_INDICATOR, NULL, par_T_DEATHDTM);

        IF var_return_code != 0 THEN
            BEGIN
                SELECT
                    messages
                    INTO var_message
                    FROM error_msgs
                    WHERE error_code = var_return_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_rowcount != 1 THEN
                    BEGIN
                        SELECT
                            CONCAT('Call cpi function failed with return code ',
                            CASE CAST (var_return_code AS VARCHAR(8))
                                WHEN '' THEN ''
                                ELSE CAST (var_return_code AS VARCHAR(8))
                            END)
                            INTO var_message;
                    END;
                END IF;
                RAISE EXCEPTION '%', var_message USING ERRCODE := var_return_code;
                pas_return_code := var_return_code;
                RETURN;
            END;
        END IF;

        IF NOT EXISTS (SELECT
            1
            FROM cpi_case
            WHERE patient_key = var_pat_key AND (case_type = 'I' OR case_type = 'A') AND status_code = 'AC' AND ((discharge_code IS NULL OR discharge_code = '') AND discharge_dtm IS NULL) AND case_no != par_T_CASE_NO /* --filter away this case no because the above update transaction */)
        /* --(to update discharge code) might not be committed yet */
        THEN
            BEGIN
                CALL cpi_update_patient_privacy(var_return_code, par_hosp_code, var_pat_key, 'N', par_T_CASE_NO, 'CMS', 105, par_T_USER_ID, var_return_error_code, var_error_message);
                /* --Comment below (don't goto return_error) so that if the updating privacy flag failed, */
                /* --the original discharge function is still not affected. */
                /*
                if (return_error_code != 0) begin
                	select	@success_flag = N
                	goto return_error
                end
                */
            END;
        END IF;

        IF SUBSTRING(var_transaction_type, 1, 2) = '13' THEN
            BEGIN
                SELECT
                    'YNNNNNNNNNYYYNNYYYNNNNNNNNNNNNNN'
                    INTO var_temp_bit;
                SELECT
                    Access_code
                    INTO var_pmi_access
                    FROM PMI
                    WHERE HKID = var_hkid AND PMI_hospital_code = par_hosp_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF (var_error != 0) OR (var_rowcount <> 1) THEN
                    BEGIN
                        SELECT
                            'Cannot retrieve Access Code from PMI'
                            INTO var_message;
                        SELECT
                            - 1
                            INTO var_return_code;
                        /* raiserror 200026, @message */
                        /* return @return_code */
                        RAISE EXCEPTION '%', var_message USING ERRCODE := '40005';
                        pas_return_code := 40005;
                        RETURN;
                    END;
                END IF;
                CALL hasp_get_int_by_bin(pas_return_code, var_temp_bit, var_temp_int);
                SELECT
                    var_temp_int & var_pmi_access
                    INTO var_temp_val;

                IF var_temp_val > 0 THEN /* not set on */
                    SELECT
                        'N'
                        INTO var_security_flag;
                ELSE
                    /* set on */
                    SELECT
                        'Y'
                        INTO var_security_flag;
                END IF;
                /* --- automatic set off confidential flag if it is on --- */
                SELECT
                    System_datetime, T_PRK
                    INTO var_last_upd_pmi_dtm, var_patient_key
                    FROM PMI
                    WHERE HKID = var_hkid AND PMI_hospital_code = par_hosp_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                BEGIN
                    var_rowcount := sql$rowcount;
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                END;

                IF (var_error != 0) OR (var_rowcount <> 1) THEN
                    BEGIN
                        SELECT
                            'Cannot retrieve Last update datetime from PMI'
                            INTO var_message;
                        SELECT
                            - 1
                            INTO var_return_code;
                        /* raiserror 200026, @message */
                        /* return @return_code */
                        RAISE EXCEPTION '%', var_message USING ERRCODE := '40007';
                        pas_return_code := 40007;
                        RETURN;
                    END;
                END IF;
                /* CR16249 Yorky 23 Jul 2009 */
                IF EXISTS (SELECT
                    patient_key
                    FROM cpi_access_changed
                    WHERE patient_key = var_patient_key) THEN
                    BEGIN
                        SELECT
                            update_hospital
                            INTO var_last_update_hosp
                            FROM cpi_access_changed
                            WHERE patient_key = var_patient_key AND update_dtm = (SELECT
                                MAX(update_dtm)
                                FROM cpi_access_changed
                                WHERE patient_key = var_patient_key);
                    END;
                END IF;

                IF (var_security_flag = 'Y' AND var_last_update_hosp = par_hosp_code) THEN
                    BEGIN
                        SELECT
                            localtimestamp
                            INTO var_tx_dtm;
                        SELECT
                            var_pmi_access | var_temp_int
                            INTO var_pmi_access;
                        CALL hasp_update_access(var_return_code, par_hosp_code, var_hkid, var_patient_key, var_pmi_access, var_tx_dtm, par_T_USER_ID, var_last_upd_pmi_dtm);

                        IF var_return_code <> 0 THEN
                            BEGIN
                                SELECT
                                    'Cannot Update Access Code in PMI table'
                                    INTO var_message;
                                SELECT
                                    - 1
                                    INTO var_return_code;
                                /* raiserror 200026, @message */
                                /* return @return_code */
                                RAISE EXCEPTION '%', var_message USING ERRCODE := '40013';
                                pas_return_code := 40013;
                                RETURN;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        pas_return_code := 0;
        RETURN;
    END;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";