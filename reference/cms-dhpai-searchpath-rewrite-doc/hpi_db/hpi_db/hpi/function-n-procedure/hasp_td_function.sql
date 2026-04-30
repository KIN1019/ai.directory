-- DROP PROCEDURE hpi.hasp_td_function(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in timestamp, in timestamp, in varchar, in timestamp, in timestamp, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hasp_td_function(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_type character varying, IN par_hkid character varying, IN par_case_no character varying, IN par_discharge_code character varying, IN par_destination_code character varying, IN par_movement_count integer, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_bed_no character varying, IN par_ward_class character varying, IN par_doctor_code character varying, IN par_old_ward_code character varying, IN par_old_specialty_code character varying, IN par_old_bed_no character varying, IN par_old_ward_class character varying, IN par_old_doctor_code character varying, IN par_treatment_location character varying, IN par_follow_up_datetime timestamp without time zone, IN par_discharge_datetime timestamp without time zone, IN par_transfer_datetime timestamp without time zone, IN par_user_id character varying, IN par_system_datetime timestamp without time zone, IN par_last_update_datetime timestamp without time zone, IN par_terminal_id character varying, IN par_mrt_indicator character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_case_type VARCHAR(01);
    var_pp_code VARCHAR(08);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_pmi_access INTEGER;
    var_security_flag VARCHAR(1);
    var_temp_bit VARCHAR(32);
    var_temp_int INTEGER;
    var_temp_val INTEGER;
    var_last_upd_pmi_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_patient_key VARCHAR(8);
    var_tx_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_last_update_hosp VARCHAR(03);
    var_last_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;
    
BEGIN
    <<end_exit>>
    BEGIN
        /* -- remark hosp_code by WL on 27 July 1999, because it is --- */
        /* -- input parm for HPI --- */
        
        /* --declare  @hosp_code           VARCHAR(03), */
        /* ----- Added by WL on 25 AUG 99 ----- */
        /* ----- Added by PP on 20040223 ----- */
        /* --- initialize return code by WL on 25 AUG 99 -- */
        SELECT
            0
            INTO var_retcode;
        /* --- remark by WL on 27 July 1999, because it is input parm-- */
        
        /* Get hospital_code */
        
        /*
        Select @hosp_code = Hospital_code from Hospital
        select @rowcount = @@rowcount
        if @rowcount != 1
        begin
        	select @retcode = 200016
        	raiserror @retcode
        	goto end_exit
        end
        */
        
        /* ****************** */
        
        /* Transfer */
        
        /* ****************** */
        IF par_Type = '140' OR /* Mass Transfer */ par_Type = '160' OR /* Trial Discharge */ par_Type = '170' THEN /* Return from Trial Discharge */
            BEGIN
                /* Update CPI Table */
                SELECT
                    'I'
                    INTO var_case_type;
                /* -- remove cpi.. by WL on 27 July 1999 for HPI -- */
                
                /* --exec @retcode = cpi..cpi_transfer */
                CALL cpi_transfer(par_hosp_code, par_Case_no, par_HKID, par_Old_ward_code,
                                               par_Old_ward_class, par_Old_bed_no, par_Old_specialty_code,
                                               par_Old_doctor_code, par_Ward_code, par_Ward_class, par_Bed_no,
                                               par_Specialty_code, par_Doctor_code, par_Treatment_location,
                                               par_Transfer_datetime, var_case_type, par_Type,
                                               par_System_datetime, par_User_ID, 'ADT'::bpchar, var_retcode);

                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 July 1999 for HPI --- */
                        
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
                                    CONCAT('Call CPI function failed with return code ',
                                    CASE CAST (var_retcode AS VARCHAR(8))
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '200026';
                        EXIT end_exit;
                    END;
                END IF;
                /* --- Remove local update by WL on 27 July 1999 for HPI -- */
                
                /* Update Case Table */
                
                /*
                Update Case
                      Set Movement_count = @Movement_count,
                          System_datetime = @System_datetime,
                          User_ID = @User_ID
                      where Case_no = @Case_no
                      and   System_datetime = @Last_update_datetime
                
                      select @rowcount = @@rowcount, @error = @@error
                      if @error != 0
                      begin
                         select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot update CASE table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                
                		/* Insert Movement Trx */
                		Insert Movement
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
                		 Doctor_code)
                		values
                		(@Case_no,
                		 @Movement_count,
                		 @Ward_code,
                		 @Bed_no,
                		 @Specialty_code,
                		 @Ward_class,
                		 'T',
                		 @Transfer_datetime,
                		 @Treatment_location,
                		 @System_datetime,
                		 @User_ID,
                		 @Doctor_code)
                
                      select @rowcount = @@rowcount, @error = @@error
                      if @error != 0
                      begin
                         select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot insert row into MOVEMENT table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                
                		/* Update Ward_list Table */
                		Update Ward_list
                		Set Ward_code = @Ward_code,
                			Specialty_code = @Specialty_code,
                			Bed_no = @Bed_no
                		where Case_no = @Case_no
                		and   Ward_code = @Old_ward_code
                		and   Specialty_code = @Old_specialty_code
                		and   Bed_no = @Old_bed_no
                
                		select @rowcount = @@rowcount, @error = @@error
                		if @error != 0
                		begin
                			select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot update WARD_LIST table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                
                		/* Update Bed Table */
                		if @Old_bed_no != null
                		begin
                			Update Bed
                			Set Status = 'V'
                			where Bed_no = @Old_bed_no
                			and   Ward_code = @Old_ward_code
                			and   Status = 'O'
                
                			select @rowcount = @@rowcount, @error = @@error
                			if @error != 0
                			begin
                				select @retcode = -1
                				goto end_exit
                			end
                			if @rowcount != 1
                			begin
                				select @error_msg = Cannot update BED table
                				select @retcode = -1
                				raiserror 200026, @error_msg
                				goto end_exit
                			end
                		end
                /* Leo --make the new transfer bed occupied */
                      if @Bed_no != null
                      begin
                         select @rowcount=count(*) from  Bed
                	         where Bed_no = @Bed_no
                   		      and   Ward_code = @Ward_code
                         		and   Status = 'V'
                
                         select @error = @@error
                         if @error != 0
                         begin
                            select @retcode = -1
                            goto end_exit
                         end
                         if @rowcount != 1
                         begin
                            select @error_msg = The bed is occupied by other patient
                            select @retcode = -1
                            raiserror 200026, @error_msg
                            goto end_exit
                         end
                         Update Bed
                         	Set Status = 'O'
                         	where Bed_no = @Bed_no
                         		and   Ward_code = @Ward_code
                         		and   Status = 'V'
                
                         select @rowcount = @@rowcount, @error = @@error
                         if @error != 0
                         begin
                            select @retcode = -1
                            goto end_exit
                         end
                         if @rowcount != 1
                         begin
                            select @error_msg = Cannot update BED table
                            select @retcode = -1
                            raiserror 200026, @error_msg
                            goto end_exit
                         end
                      end
                */
            END;
        END IF; /* end of transaction type */
        /* *************** */
        /* Discharge */
        /* ************** */
        IF SUBSTRING(par_Type, 1, 2) = '13' OR /* In-patient discharge */ SUBSTRING(par_Type, 1, 2) = '33' THEN /* A&E discharge */
            BEGIN
                /* Update CPI Table */
                IF SUBSTRING(par_Type, 1, 2) = '13' THEN
                    SELECT
                        'I'
                        INTO var_case_type;
                END IF;

                IF SUBSTRING(par_Type, 1, 2) = '33' THEN
                    SELECT
                        'A'
                        INTO var_case_type;
                END IF;
                /* -- remove cpi.. by WL on 27 July 1999 for HPI-- */
                
                /* ** put mrt indicator as input parameter by Winnie ** */
                
                /* --exec @retcode = cpi..cpi_discharge */
                CALL cpi_discharge(var_retcode, par_hosp_code, par_Case_no, par_HKID, par_Discharge_code,
                                                par_Discharge_datetime, par_Destination_code, par_Ward_code,
                                                par_Ward_class, par_Bed_no, par_Specialty_code, NULL::bpchar,
                                                par_Old_doctor_code, var_case_type, par_Type, par_System_datetime,
                                                par_User_ID, 'ADT'::bpchar, par_MRT_indicator, par_Follow_up_datetime,null::timestamp without time zone);
             /* added by WL on 9 SEP 99 */

                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 July 1999 for HPI -- */
                        
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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg; --USING ERRCODE = '200026';
                        EXIT end_exit;
                    END;
                END IF;
                /* -- Remove all local update by WL on 27 July 1999 for HPI-- */
                
                /* Update Case Table */
                
                /* ** update mrt indicator by Winnie ** */
                
                /*
                Update Case
                	Set Movement_count = @Movement_count,
                		Discharge_datetime = @Discharge_datetime,
                		System_datetime = @System_datetime,
                		Discharge_code = @Discharge_code,
                		Destination_code = @Destination_code,
                		User_ID = @User_ID,
                		MRT_indicator =  @MRT_indicator
                	where Case_no = @Case_no
                	and   System_datetime = @Last_update_datetime
                
                	select @rowcount = @@rowcount, @error = @@error
                	if @error != 0
                	begin
                		select @retcode = -1
                		goto end_exit
                	end
                	if @rowcount != 1
                	begin
                		select @error_msg = Cannot update CASE table
                		select @retcode = -1
                		raiserror 200026, @error_msg
                		goto end_exit
                	end
                
                	/* Insert Movement Trx */
                	Insert Movement
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
                	 Doctor_code)
                	values
                	(@Case_no,
                	 @Movement_count,
                	 @Ward_code,
                	 @Bed_no,
                	 @Specialty_code,
                	 @Ward_class,
                	 'D',
                	 @Discharge_datetime,
                	 @Treatment_location,
                	 @System_datetime,
                	 @User_ID,
                	 @Doctor_code)
                
                	select @rowcount = @@rowcount, @error = @@error
                	if @error != 0
                	begin
                		select @retcode = -1
                		goto end_exit
                	end
                	if @rowcount != 1
                	begin
                		select @error_msg = Cannot insert row into MOVEMENT table
                		select @retcode = -1
                		raiserror 200026, @error_msg
                		goto end_exit
                	end
                
                	/* Delete Row from Ward_list */
                	Delete Ward_list
                	where Case_no = @Case_no
                	and   Ward_code = @Ward_code
                	and   Specialty_code = @Specialty_code
                	and   Bed_no = @Bed_no
                
                	select @rowcount = @@rowcount, @error = @@error
                	if @error != 0
                	begin
                		select @retcode = -1
                		goto end_exit
                	end
                	if @rowcount != 1
                	begin
                		select @error_msg = Cannot delete record from WARD_LIST table
                		select @retcode = -1
                		raiserror 200026, @error_msg
                		goto end_exit
                	end
                
                	/* Update Bed Table for In-patient discharge */
                	if @case_type = 'I' and @Bed_no != null
                	begin
                		Update Bed
                		Set Status = 'V'
                		where Bed_no = @Bed_no
                		and   Ward_code = @Ward_code
                		and   Status = 'O'
                
                		select @rowcount = @@rowcount, @error = @@error
                		if @error != 0
                		begin
                			select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot update BED table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                	end
                
                	/* Update AE-case_detail for A&E discharge */
                	if @case_type = 'A' and @Follow_up_datetime != null
                	begin
                		Update AE_case_detail
                		Set Follow_up_datetime = @Follow_up_datetime
                		where Case_no = @Case_no
                
                		select @rowcount = @@rowcount, @error = @@error
                		if @error != 0
                		begin
                			select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot update AE_case_detail table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                	end
                */
                /* ----- Added by WL on 25 AUG  99 ---------------- */
                /* ----- check the confidentiality flag is set on or not --- */
                IF (SUBSTRING(par_Type, 1, 2) = '13') OR (SUBSTRING(par_Type, 1, 2) = '33' AND SUBSTRING(par_Type, 3, 1) <> '9') THEN
                    BEGIN
                        SELECT
                            'YNNNNNNNNNYYYNNYYYNNNNNNNNNNNNNN'
                            INTO var_temp_bit;
                        SELECT
                            Access_code
                            INTO var_pmi_access
                            FROM PMI_wo_MRN
                            WHERE HKID = par_HKID;
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
                                    INTO var_error_msg;
                                SELECT
                                    - 1
                                    INTO var_retcode;
                                --RAISE EXCEPTION '% ', var_error_msg USING ERRCODE = '200026';
                                EXIT end_exit;
                            END;
                        END IF;
                        CALL hasp_get_int_by_bin(pas_return_code, var_temp_bit, var_temp_int);
                        SELECT var_temp_int & var_pmi_access
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
                            FROM PMI_wo_MRN
                            WHERE HKID = par_HKID;
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
                                    INTO var_error_msg;
                                SELECT
                                    - 1
                                    INTO var_retcode;
                                RAISE EXCEPTION '% ', var_error_msg USING ERRCODE = '200026';
                                EXIT end_exit;
                            END;
                        END IF;

                        IF EXISTS (SELECT
                            *
                            FROM cpi_access_changed
                            WHERE patient_key = var_patient_key) THEN
                            BEGIN
                                SELECT
                                    MAX(update_dtm)
                                    INTO var_last_update_dtm
                                    FROM cpi_access_changed
                                    WHERE patient_key = var_patient_key;
                                SELECT
                                    update_hospital
                                    INTO var_last_update_hosp
                                    FROM cpi_access_changed
                                    WHERE patient_key = var_patient_key AND update_dtm = var_last_update_dtm;
                            END;
                        ELSE
                            SELECT
                                '   '
                                INTO var_last_update_hosp;
                        END IF;

                        IF ((var_security_flag = 'Y') AND (par_hosp_code = var_last_update_hosp)) THEN
                            BEGIN
                                SELECT
                                    timestamp_convert(localtimestamp)
                                    INTO var_tx_dtm;
                                SELECT
                                    var_pmi_access | var_temp_int
                                    INTO var_pmi_access;
                                /* --- add @hosp_code for HPI -- */
                                CALL hasp_update_access(var_retcode, par_hosp_code, par_HKID, var_patient_key,
                                                                     var_pmi_access, var_tx_dtm, par_User_ID,
                                                                     var_last_upd_pmi_dtm);

                                IF var_retcode <> 0 THEN
                                    BEGIN
                                        SELECT
                                            'Cannot Update Access Code in PMI table'
                                            INTO var_error_msg;
                                        SELECT
                                            - 1
                                            INTO var_retcode;
                                        RAISE EXCEPTION '% ', var_error_msg USING ERRCODE := '200026';
                                        EXIT end_exit;
                                    END;
                                END IF;
                            END;
                        END IF;
                    END;
                END IF;
                /* ---- End by WL on 25 AUG 99 ------ */
            END;
        END IF; /* end of transaction type */
        /* ************************** */
        /* Cancellation of Transfer */
        /* ************************** */
        IF par_Type = '220' OR /* Cancellation of Mass Transfer */ par_Type = '230' OR /* Cancellation of Trial Transfer */ par_Type = '240' THEN /* Cancellation of Return Trial Discharge */
            BEGIN
                /* Update CPI Table */
                SELECT
                    'I'
                    INTO var_case_type;
                /* -- remove cpi.. by WL on 27 July 1999 for HPI -- */
                
                /* --exec @retcode = cpi..cpi_cancel_transfer */
                CALL cpi_cancel_transfer(var_retcode, par_hosp_code, par_Case_no, par_HKID, par_Ward_code,
                                                      par_Ward_class, par_Bed_no, par_Specialty_code,
                                                      par_Doctor_code, par_Old_ward_code, par_Old_ward_class,
                                                      par_Old_bed_no, par_Old_specialty_code, par_Old_doctor_code,
                                                      par_Transfer_datetime, var_case_type, par_Type,
                                                      par_System_datetime, par_User_ID, 'ADT'::bpchar);
          
                IF var_retcode != 0 THEN
                    BEGIN
                        /* --- remove cpi.. by WL on 27 July 1999 for HPI --- */
                        
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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '200026';
                        EXIT end_exit;
                    END;
                END IF;
                /* --- Remove all local update by HPI by WL on 27 July 1999 --- */
                
                /* Update Case Table */
                /*
                Update Case
                		Set Movement_count = @Movement_count,
                			System_datetime = @System_datetime,
                			User_ID = @User_ID
                		where Case_no = @Case_no
                		and   System_datetime = @Last_update_datetime
                
                		select @rowcount = @@rowcount, @error = @@error
                		if @error != 0
                		begin
                			select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot update CASE table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                
                		/* Delete last transaction from Movement Table */
                		Delete Movement
                		where Case_no = @Case_no
                		and   Movement_count = @Movement_count + 1
                		and   Movement_type = 'T'
                		and   Ward_code = @Old_ward_code
                		and   Specialty_code = @Old_specialty_code
                		and   Bed_no = @Old_bed_no
                
                		select @rowcount = @@rowcount, @error = @@error
                		if @error != 0
                		begin
                			select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot delete row from MOVEMENT table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                
                		/* Update Ward_list Table */
                		Update Ward_list
                		Set Ward_code = @Ward_code,
                			Specialty_code = @Specialty_code,
                			Bed_no = @Bed_no
                		where Case_no = @Case_no
                		and   Ward_code = @Old_ward_code
                		and   Specialty_code = @Old_specialty_code
                		and   Bed_no = @Old_bed_no
                
                		select @rowcount = @@rowcount, @error = @@error
                		if @error != 0
                		begin
                			select @retcode = -1
                			goto end_exit
                		end
                		if @rowcount != 1
                		begin
                			select @error_msg = Cannot update WARD_LIST table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                
                		/* Update Bed Table */
                		if @Bed_no != null and @Bed_no != @Old_bed_no
                		begin
                      /* Leo -- check the bed is  vacant or not*/
                			select @rowcount=count(*) from  Bed
                				where Bed_no = @Bed_no
                					and   Ward_code = @Ward_code
                					and   Status = 'V'
                
                			select @error = @@error
                			if @error != 0
                			begin
                				select @retcode = -1
                				goto end_exit
                			end
                			if @rowcount != 1
                			begin
                				select @error_msg = The bed is occupied by other patient
                				select @retcode = -1
                				raiserror 200026, @error_msg
                				goto end_exit
                			end
                			Update Bed
                				Set Status = 'O'
                				where Bed_no = @Bed_no
                					and   Ward_code = @Ward_code
                					and   Status = 'V'
                
                			select @rowcount = @@rowcount, @error = @@error
                			if @error != 0
                			begin
                				select @retcode = -1
                				goto end_exit
                			end
                			if @rowcount != 1
                			begin
                				select @error_msg = Cannot update BED table
                				select @retcode = -1
                				raiserror 200026, @error_msg
                				goto end_exit
                			end
                		end
                /* Leo -- make the current bed to vacant */
                      if @Old_bed_no != null and @Old_bed_no != @Bed_no
                      begin
                         Update Bed
                        		Set Status = 'V'
                         	where Bed_no = @Old_bed_no
                 		     		and   Ward_code = @Old_ward_code
                     		   	and   Status = 'O'
                
                         select @rowcount = @@rowcount, @error = @@error
                         if @error != 0
                         begin
                            select @retcode = -1
                            goto end_exit
                         end
                         if @rowcount != 1
                         begin
                            select @error_msg = Cannot update BED table
                            select @retcode = -1
                            raiserror 200026, @error_msg
                            goto end_exit
                         end
                      end
                */
            END;
        END IF; /* end of transaction type */
        /* *************************** */
        /* Cancellation of Discharge */
        /* *************************** */
        IF SUBSTRING(par_Type, 1, 2) = '21' OR /* cancellation of HN discharge */
         SUBSTRING(par_Type, 1, 2) = '35' THEN /* cancellation of AE discharge */
            BEGIN
                /* Update CPI Table */
                IF SUBSTRING(par_Type, 1, 2) = '21' THEN
                    SELECT
                        'I'
                        INTO var_case_type;
                END IF;

                IF SUBSTRING(par_Type, 1, 2) = '35' THEN
                    SELECT
                        'A'
                        INTO var_case_type;
                END IF;
                /* -- Remove cpi.. by WL on 27 July 1999 for HPI -- */
                
                /* --exec @retcode = cpi..cpi_cancel_discharge */
                CALL cpi_cancel_discharge(var_retcode, par_hosp_code, par_Case_no, par_HKID, par_Ward_code,
                                                       par_Ward_class, par_Bed_no, par_Specialty_code, NULL::bpchar,
                                                       par_Doctor_code, var_case_type, par_Type,
                                                       par_System_datetime, par_User_ID, 'ADT'::bpchar);
                
                IF var_retcode != 0 THEN
                    BEGIN
                        /* -- remove cpi.. by WL on 27 July 1999 for HPI -- */
                        
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
                                        WHEN '' THEN ' '
                                        ELSE CAST (var_retcode AS VARCHAR(8))
                                    END)
                                    INTO var_error_msg;
                            END;
                        END IF;
                        RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '200026';
                        EXIT end_exit;
                    END;
                END IF;
                /* Update Case Table */
                /* -- Remove local update by WL for HPI on 27 July 1999 -- */
                /*
                Update Case
                      set Movement_count = @Movement_count,
                          Discharge_code = null,
                          Discharge_datetime = null,
                          Destination_code = null,
                          Active_indicator = 'Y',
                          System_datetime = @System_datetime,
                          User_ID = @User_ID
                      where Case_no = @Case_no
                      and   System_datetime = @Last_update_datetime
                
                      select @rowcount = @@rowcount, @error = @@error
                      if @error != 0
                      begin
                         select @retcode = -1
                         goto end_exit
                      end
                      if @rowcount != 1
                      begin
                			select @error_msg = Cannot update CASE table
                			select @retcode = -1
                			raiserror 200026, @error_msg
                			goto end_exit
                		end
                
                      /* Delete last transaction from Movement Table */
                      Delete Movement
                      where Case_no = @Case_no
                      and   Movement_count = @Movement_count + 1
                      and   Movement_type = 'D'
                      and   Ward_code = @Old_ward_code
                      and   Specialty_code = @Old_specialty_code
                      and   Bed_no = @Old_bed_no
                
                      select @rowcount = @@rowcount, @error = @@error
                      if @error != 0
                      begin
                         select @retcode = -1
                         goto end_exit
                      end
                      if @rowcount != 1
                      begin
                         select @error_msg = Cannot delete row from MOVEMENT table
                         select @retcode = -1
                         raiserror 200026, @error_msg
                         goto end_exit
                      end
                
                      /* Insert row into Ward_list Table */
                      Insert Ward_list
                      (Case_no,
                       Ward_code,
                       Bed_no,
                       Specialty_code)
                      values
                      (@Case_no,
                       @Ward_code,
                       @Bed_no,
                       @Specialty_code)
                
                      select @rowcount = @@rowcount, @error = @@error
                      if @error != 0
                      begin
                         select @retcode = -1
                         goto end_exit
                      end
                      if @rowcount != 1
                      begin
                         select @error_msg = Cannot insert row into WARD_LIST table
                         select @retcode = -1
                         raiserror 200026, @error_msg
                         goto end_exit
                      end
                
                      /* Update Bed Table */
                      if @Bed_no != null
                      begin
                      /* Leo -- check the bed is  vacant or not*/
                         select @rowcount=count(*) from Bed
                         	where Bed_no = @Bed_no
                         		and   Ward_code = @Ward_code
                         		and   Status = 'V'
                
                         select @error = @@error
                         if @error != 0
                         begin
                            select @retcode = -1
                            goto end_exit
                         end
                         if @rowcount != 1
                         begin
                            select @error_msg = The bed is occupied by other patient
                            select @retcode = -1
                            raiserror 200026, @error_msg
                            goto end_exit
                         end
                         Update Bed
                         	Set Status = 'O'
                         	where Bed_no = @Bed_no
                         		and   Ward_code = @Ward_code
                         		and   Status = 'V'
                
                         select @rowcount = @@rowcount, @error = @@error
                         if @error != 0
                         begin
                            select @retcode = -1
                            goto end_exit
                         end
                         if @rowcount != 1
                         begin
                            select @error_msg = Cannot update BED table
                            select @retcode = -1
                            raiserror 200026, @error_msg
                            goto end_exit
                         end
                		end
                
                		/* Update AE-case_detail for A&E case */
                      if @case_type = 'A'
                      begin
                         Update AE_case_detail
                         Set Follow_up_datetime = null
                         where Case_no = @Case_no
                
                         select @rowcount = @@rowcount, @error = @@error
                         if @error != 0
                         begin
                            select @retcode = -1
                            goto end_exit
                         end
                         if @rowcount != 1
                         begin
                            select @error_msg = Cannot update AE_CASE_DETAIL table
                            select @retcode = -1
                            raiserror 200026, @error_msg
                            goto end_exit
                         end
                		end
                
                      /* Update HN_case_detail for In-patient case */
                      if @case_type = 'I'
                		begin
                         Select @pp_code = PP_code
                         from HN_case_detail
                         where Case_no = @Case_no
                
                         select @rowcount = @@rowcount, @error = @@error
                         if @error != 0
                         begin
                            select @retcode = -1
                            goto end_exit
                         end
                			if @rowcount = 1
                			begin
                				if @pp_code = null
                				begin
                               Delete HN_case_detail
                               where Case_no = @Case_no
                
                               select @rowcount = @@rowcount, @error = @@error
                               if @error != 0
                               begin
                                  select @retcode = -1
                                  goto end_exit
                               end
                               if @rowcount != 1
                               begin
                                  select @error_msg = Cannot delete row from HN_CASE_DETAIL table
                                  select @retcode = -1
                                  raiserror 200026, @error_msg
                                  goto end_exit
                               end
                            end
                				else
                				begin
                            	Update HN_case_detail
                            	Set Internal_ICD9_code = null,
                                	 External_ICD9_code = null
                            	where Case_no = @Case_no
                
                           	 	select @rowcount = @@rowcount, @error = @@error
                            	if @error != 0
                          		begin
                               	select @retcode = -1
                               	goto end_exit
                            	end
                            	if @rowcount != 1
                            	begin
                						select @error_msg = Cannot update HN_CASE_DETAIL table
                						select @retcode = -1
                						raiserror 200026, @error_msg
                						goto end_exit
                					end
                				end
                			end
                		end
                */
            END;
        END IF; /* end of transaction type */
    END;
    pas_return_code := var_retcode;
    RETURN;
END;

$procedure$
;


;ALTER PROCEDURE "hasp_td_function" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
